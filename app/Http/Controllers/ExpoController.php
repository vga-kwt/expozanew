<?php

namespace App\Http\Controllers;

use App\Models\Expo;
use App\Models\ExpoProduct;
use App\Models\ExpoSection;
use App\Models\ExpoVendor;
use App\Models\FinanceTransaction;
use App\Models\Product;
use App\Models\Section;
use App\Models\SectionProduct;
use App\Models\SlotBooking;
use App\Models\Vendor;
use App\Services\SlotBookingService;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;
use Inertia\Inertia;
use MyFatoorah\Library\API\Payment\MyFatoorahPayment;

class ExpoController extends Controller
{
    protected $slotBookingService;

    public function __construct(SlotBookingService $slotBookingService)
    {
        $this->slotBookingService = $slotBookingService;
    }

    public function index(Request $request)
    {
        // Auto-mark expired expos
        Expo::where('end_date', '<', now())->where('status', '!=', 'expired')->update(['status' => 'expired']);

        // Exclude soft deleted expos
        $query = Expo::query()->whereNull('deleted_at');

        // Name search (search param)
        if ($request->filled('search')) {
            $search = $request->input('search');
            $query->where(function ($q) use ($search) {
                $q->whereRaw('LOWER(name_en) LIKE ?', ['%' . strtolower($search) . '%'])
                    ->orWhereRaw('LOWER(name_ar) LIKE ?', ['%' . strtolower($search) . '%']);
            });
        }

        // Status filter
        $status = $request->input('status');
        if ($status && strtolower($status) !== 'all') {
            $query->whereRaw('LOWER(status) = ?', [strtolower($status)]);
        }

        // From date filter
        $from = $request->input('from');
        if ($from) {
            $query->whereDate('start_date', '>=', $from);
        }

        // To date filter
        $to = $request->input('to');
        if ($to) {
            $query->whereDate('end_date', '<=', $to);
        }

        $expos = $query->orderByDesc('id')
            ->with(['expoVendors.vendor', 'expoProducts.product.category:id,name_en', 'expoProducts.vendor'])
            ->paginate(10)
            ->withQueryString();

        // Add vendors and expo_products to each expo (for details modal)
        $expos->getCollection()->transform(function ($expo) {
            $expoArr = $expo->toArray();

            // Booked slots sum from expo_vendors
            $expoArr['booked_slots'] = ExpoVendor::where('expo_id', $expo->id)->sum('slot');

            // Total amount sum from slot_bookings
            $expoArr['total_amount'] = SlotBooking::where('expo_id', $expo->id)->sum('total_amount');

            $expoArr['vendors'] = collect($expo->expoVendors)->map(function ($ev) {
                return $ev->vendor;
            })->filter()->values();
            $expoArr['expo_products'] = $expo->expoProducts->map(function ($ep) {
                return [
                    'id' => $ep->id,
                    'product' => $ep->product ? [
                        'id' => $ep->product->id,
                        'name' => $ep->product->name_en,
                        'price' => $ep->product->regular_price,
                        'stock' => $ep->product->stock,
                        'category' => $ep->product->category ?
                            $ep->product->category->name_en
                            : null,
                        'status' => $ep->product->status,
                    ] : null,
                    'vendor' => $ep->vendor ? [
                        'id' => $ep->vendor->id,
                        'name' => $ep->vendor->name,
                        'brand_name_en' => $ep->vendor->brand_name_en,
                        'brand_name_ar' => $ep->vendor->brand_name_ar,
                        'email' => $ep->vendor->email,
                    ] : null,
                ];
            })->values();

            // Slot pricing logic
            $slotPrices = [];
            if ($expo->slot_prices) {
                // slot_prices: [{"slot":1,"price":"100"},{"slot":2,"price":"97"},...]
                $slotPrices = json_decode($expo->slot_prices, true);
            } elseif ($expo->range_slot_prices) {
                // range_slot_prices: [{"slot":1,"price":"200"},{"slot":2,"price":"250"}]
                $slotPrices = json_decode($expo->range_slot_prices, true);
            }
            $expoArr['slot_prices'] = $slotPrices;

            return $expoArr;
        });

        return Inertia::render('Expos/Index', [
            'expos' => $expos,
            'filters' => [
                'search' => $request->input('search', ''),
                'status' => $request->input('status', 'all'),
                'from' => $request->input('from', ''),
                'to' => $request->input('to', ''),
            ],
        ]);
    }

    public function store(Request $request): RedirectResponse
    {
        $validated = $request->validate([
            'name_en' => 'required|string|max:255',
            'name_ar' => 'required|string|max:255',
            'description_en' => 'nullable|string',
            'description_ar' => 'nullable|string',
            'background_color' => 'nullable|string|max:20',
            'background_image' => 'nullable|image|mimes:jpeg,png,jpg,gif,svg|max:2048',
            'font_style' => 'nullable|string|max:50',
            'font_size' => 'nullable|string|max:10',
            'font_weight' => 'nullable|string|max:10',
            'banner_image' => 'nullable|image|mimes:jpeg,png,jpg,gif,svg|max:2048',
            'start_date' => ['required', 'date', 'after_or_equal:2015-01-01'],
            'end_date' => ['required', 'date', 'after:start_date', 'after_or_equal:2015-01-01'],
            'vendor_slot_capacity' => 'required|integer|min:1',
            'product_capacity_per_slot' => 'required|integer|min:1',
            'slot_pricing' => 'required|json',
            'status' => 'required|string|in:active,inactive,suspended,expired,upcoming',
            'free_participation' => 'nullable|boolean',

        ]);

        $disk = config('filesystems.default', 's3');

        // Handle image uploads
        if ($request->hasFile('background_image')) {
            $validated['background_image'] = $request->file('background_image')->store('expos', $disk);
        }
        if ($request->hasFile('banner_image')) {
            $validated['banner_image'] = $request->file('banner_image')->store('expos', $disk);
        }

        // Convert free_participation to boolean
        // Handle string values like "1", "0", "true", "false", or empty string
        if (isset($validated['free_participation'])) {
            $value = $validated['free_participation'];
            if (is_string($value)) {
                $validated['free_participation'] = in_array(strtolower($value), ['1', 'true', 'on', 'yes'], true);
            } else {
                $validated['free_participation'] = (bool) $value;
            }
        } else {
            // If not set, default to false
            $validated['free_participation'] = false;
        }

        $expo = Expo::create($validated);

        // Log expo creation
        $this->auditLogCreate('expo', "Created new expo: {$expo->name_en}", [
            'expo_id' => $expo->id,
            'name_en' => $expo->name_en,
            'status' => $expo->status,
            'start_date' => $expo->start_date,
            'end_date' => $expo->end_date,
        ]);

        return redirect()->route('expos.index');
    }

    public function update(Request $request, Expo $expo): RedirectResponse
    {
        $validated = $request->validate([
            'name_en' => 'required|string|max:255',
            'name_ar' => 'required|string|max:255',
            'description_en' => 'nullable|string',
            'description_ar' => 'nullable|string',
            'background_color' => 'nullable|string|max:20',
            'background_image' => 'nullable|image|mimes:jpeg,png,jpg,gif,svg',
            'font_family' => 'nullable',
            'font_color' => 'nullable',
            'font_style' => 'nullable|string|max:50',
            'font_size' => 'nullable|string|max:10',
            'font_weight' => 'nullable|string|max:10',
            'banner_image' => 'nullable|image|mimes:jpeg,png,jpg,gif,svg',
            'start_date' => 'nullable|date',
            'end_date' => 'nullable|date|after_or_equal:start_date',
            'vendor_slot_capacity' => 'required|integer|min:1',
            'product_capacity_per_slot' => 'required|integer|min:1',
            'slot_pricing' => 'required|json',
            'status' => 'required|string|in:active,inactive,suspended,expired,upcoming',
            'free_participation' => 'nullable|boolean',
        ]);

        $disk = config('filesystems.default', 's3');

        // Handle image uploads
        if ($request->hasFile('background_image')) {
            $validated['background_image'] = $request->file('background_image')->store('expos', $disk);
        } else {
            unset($validated['background_image']);
        }
        if ($request->hasFile('banner_image')) {
            $validated['banner_image'] = $request->file('banner_image')->store('expos', $disk);
        } else {
            unset($validated['banner_image']);
        }

        // Convert free_participation to boolean
        // Handle string values like "1", "0", "true", "false", or empty string
        if (isset($validated['free_participation'])) {
            $value = $validated['free_participation'];
            if (is_string($value)) {
                $validated['free_participation'] = in_array(strtolower($value), ['1', 'true', 'on', 'yes'], true);
            } else {
                $validated['free_participation'] = (bool) $value;
            }
        } else {
            // If not set, default to false
            $validated['free_participation'] = false;
        }

        $oldData = $expo->only(['name_en', 'name_ar', 'status', 'start_date', 'end_date', 'vendor_slot_capacity', 'product_capacity_per_slot']);
        $expo->update($validated);

        // Log expo update
        $this->auditLogUpdate('expo', "Updated expo: {$expo->name_en}", [
            'expo_id' => $expo->id,
            'old' => $oldData,
            'new' => $expo->only(['name_en', 'name_ar', 'status', 'start_date', 'end_date', 'vendor_slot_capacity', 'product_capacity_per_slot']),
        ]);

        return redirect()->route('expos.index');
    }

    public function destroy(Expo $expo): RedirectResponse
    {
        $expoData = [
            'expo_id' => $expo->id,
            'name_en' => $expo->name_en,
            'name_ar' => $expo->name_ar,
            'status' => $expo->status,
        ];

        $expo->deleted_at = now();
        $expo->save();

        // Log expo deletion (soft delete)
        $this->auditLogDelete('expo', "Deleted expo: {$expo->name_en}", $expoData);

        return redirect()->route('expos.index');
    }

    /**
     * List all live/upcoming expos for vendors
     */
    public function vendorList(Request $request)
    {
        $today = Carbon::today();
        $user = $request->user();
        $vendor = method_exists($user, 'vendor') ? $user->vendor : null;
        $joinedExpoIds = $vendor ? ExpoVendor::where('vendor_id', $vendor->id)->pluck('expo_id')->toArray() : [];
        $expos = Expo::where('end_date', '>=', $today)
            ->whereIn('status', ['active', 'upcoming'])
            ->whereNull('deleted_at') // Exclude soft deleted expos
            ->orderBy('start_date')
            ->get()
            ->map(function ($expo) use ($joinedExpoIds, $vendor) {
                $totalSlots = $expo->vendor_slot_capacity;
                $filledSlots = ExpoVendor::where('expo_id', $expo->id)->sum('slot');
                $availableSlots = max(0, $totalSlots - $filledSlots);
                $remainingTime = Carbon::parse($expo->end_date)->diffForHumans(null, true);
                // Extract slot fee from slot_pricing array
                $slotFee = 0;
                if (is_array($expo->slot_pricing) && !empty($expo->slot_pricing)) {
                    $firstPricing = $expo->slot_pricing[0] ?? null;
                    if (is_array($firstPricing) && isset($firstPricing['price'])) {
                        $slotFee = floatval($firstPricing['price']);
                    }
                }
                $vendorSlotCount = 0;
                if ($vendor) {
                    $expoVendor = ExpoVendor::where('expo_id', $expo->id)->where('vendor_id', $vendor->id)->first();
                    $vendorSlotCount = $expoVendor ? $expoVendor->slot : 0;
                }

                return [
                    'id' => $expo->id,
                    'title_en' => $expo->name_en,
                    'description_en' => $expo->description_en,
                    'start_date' => $expo->start_date,
                    'end_date' => $expo->end_date,
                    'total_slots' => $totalSlots,
                    'filled_slots' => $filledSlots,
                    'available_slots' => $availableSlots,
                    'remaining_time' => $remainingTime,
                    'slot_fee' => $slotFee,
                    'status' => $expo->status,
                    'already_joined' => in_array($expo->id, $joinedExpoIds),
                    'vendor_slot_count' => $vendorSlotCount,
                ];
            });

        return Inertia::render('Expos/VendorIndex', [
            'expos' => $expos,
        ]);
    }

    /**
     * Get expo details for vendor
     */
    public function vendorExpoDetails($expoId)
    {
        $expo = Expo::whereNull('deleted_at') // Exclude soft deleted expos
            ->with(['categories'])
            ->findOrFail($expoId);

        $slotPricing = collect($expo->slot_pricing)->mapWithKeys(function ($price, $slot) {
            return [(int) $slot => $price];
        });

        $totalSlots = $expo->vendor_slot_capacity;

        // Get booked slots from SlotBooking table (check both slot_number and booked_slots fields)
        // IMPORTANT: Only get bookings with payment_status = 'paid' to ensure we count confirmed bookings
        // Also ensure integer type casting for proper comparison
        $bookedSlotsFromSlotNumber = SlotBooking::where('expo_id', $expo->id)
            ->where('payment_status', 'paid')
            ->whereNotNull('slot_number')
            ->pluck('slot_number')
            ->map(function ($slot) {
                return (int) $slot; // Ensure integer type for comparison
            })
            ->unique()
            ->values()
            ->toArray();

        $bookedSlotsFromArray = SlotBooking::where('expo_id', $expo->id)
            ->where('payment_status', 'paid')
            ->get()
            ->flatMap(function ($booking) {
                $slots = $booking->booked_slots ?? [];

                return array_map(function ($slot) {
                    return (int) $slot; // Ensure integer type
                }, is_array($slots) ? $slots : []);
            })
            ->unique()
            ->values()
            ->toArray();

        $bookedSlots = array_unique(array_merge($bookedSlotsFromSlotNumber, $bookedSlotsFromArray));
        $bookedSlots = array_map(function ($slot) {
            return (int) $slot; // Ensure all are integers for proper comparison
        }, $bookedSlots);

        // Now compute available slots (e.g., [2, 4, 5...])
        $allSlots = range(1, $expo->vendor_slot_capacity);
        $availableSlotList = array_values(array_diff($allSlots, $bookedSlots));

        // Filter to only show slots that have explicit pricing
        $slotPricing = $expo->slot_pricing;
        if (is_string($slotPricing)) {
            $slotPricing = json_decode($slotPricing, true);
        }

        if (is_array($slotPricing) && !empty($slotPricing)) {
            $slotsWithPricing = [];
            foreach ($availableSlotList as $slotNumber) {
                $hasPricing = false;

                // Check for slot-specific pricing (handle both string and integer slot numbers)
                foreach ($slotPricing as $pricing) {
                    if (isset($pricing['slot'])) {
                        $pricingSlot = is_numeric($pricing['slot']) ? (int) $pricing['slot'] : $pricing['slot'];
                        $slotNum = is_numeric($slotNumber) ? (int) $slotNumber : $slotNumber;
                        if ($pricingSlot == $slotNum) {
                            $hasPricing = true;
                            break;
                        }
                    }
                    // Check for range-based pricing
                    if (isset($pricing['from']) && isset($pricing['to'])) {
                        $from = is_numeric($pricing['from']) ? (int) $pricing['from'] : $pricing['from'];
                        $to = is_numeric($pricing['to']) ? (int) $pricing['to'] : $pricing['to'];
                        $slotNum = is_numeric($slotNumber) ? (int) $slotNumber : $slotNumber;
                        if ($slotNum >= $from && $slotNum <= $to) {
                            $hasPricing = true;
                            break;
                        }
                    }
                }

                if ($hasPricing) {
                    $slotsWithPricing[] = $slotNumber;
                }
            }
            $availableSlotList = $slotsWithPricing;
        }

        // Calculate available slots count based on filtered list (slots with pricing)
        $availableSlots = count($availableSlotList);
        $filledSlots = count($bookedSlots);

        // Calculate total slots with pricing (for display)
        $totalSlotsWithPricing = $totalSlots;
        if (is_array($slotPricing) && !empty($slotPricing)) {
            $allSlotsWithPricing = [];
            for ($i = 1; $i <= $totalSlots; $i++) {
                foreach ($slotPricing as $pricing) {
                    // Check for slot-specific pricing (handle both string and integer)
                    if (isset($pricing['slot'])) {
                        $pricingSlot = is_numeric($pricing['slot']) ? (int) $pricing['slot'] : $pricing['slot'];
                        if ($pricingSlot == $i) {
                            $allSlotsWithPricing[] = $i;
                            break;
                        }
                    }
                    // Check for range-based pricing
                    if (isset($pricing['from']) && isset($pricing['to'])) {
                        $from = is_numeric($pricing['from']) ? (int) $pricing['from'] : $pricing['from'];
                        $to = is_numeric($pricing['to']) ? (int) $pricing['to'] : $pricing['to'];
                        if ($i >= $from && $i <= $to) {
                            $allSlotsWithPricing[] = $i;
                            break;
                        }
                    }
                }
            }
            $totalSlotsWithPricing = count(array_unique($allSlotsWithPricing));
        }

        $user = request()->user();
        $vendor = method_exists($user, 'vendor') ? $user->vendor : null;
        $vendorSlotCount = 0;

        if ($vendor) {
            $expoVendor = ExpoVendor::where('expo_id', $expo->id)
                ->where('vendor_id', $vendor->id)
                ->first();
            $vendorSlotCount = $expoVendor ? $expoVendor->slot : 0;
        }

        return Inertia::render('Expos/ExpoDetails', [
            'expo' => [
                'id' => $expo->id,
                'title_en' => $expo->name_en,
                'title_ar' => $expo->name_ar,
                'description_en' => $expo->description_en,
                'description_ar' => $expo->description_ar,
                'start_date' => $expo->start_date,
                'end_date' => $expo->end_date,
                'slot_pricing' => $expo->slot_pricing,
                'free_participation' => $expo->free_participation ?? false,
                'total_slots' => $totalSlotsWithPricing,
                'filled_slots' => $filledSlots,
                'available_slots' => $availableSlots,
                'availableSlotlist' => $availableSlotList, // Fixed
                'remaining_time' => Carbon::parse($expo->end_date)->diffForHumans(null, true),
                'categories' => $expo->categories,
                'vendor_slot_count' => $vendorSlotCount,
                'slot_prices' => $slotPricing,
            ],
        ]);
    }

    /**
     * Vendor joins an expo (select slot, pay fee)
     */
    public function joinExpo($expoId, Request $request)
    {
        $user = $request->user();
        $vendor = method_exists($user, 'vendor') ? $user->vendor : null;
        if (!$vendor) {
            return redirect()->back()->with('error', 'Vendor profile not found.');
        }

        $expo = Expo::findOrFail($expoId);
        $slots = $request->input('slot');

        if (empty($slots)) {
            return redirect()->back()->with('error', 'No slots selected.');
        }

        $newSlots = is_array($slots) ? $slots : [$slots];
        $joinedAny = false;
        $errors = [];

        // Check if vendor already has an entry in expo_vendor for this expo
        $expoVendor = ExpoVendor::where('expo_id', $expo->id)
            ->where('vendor_id', $vendor->id)
            ->first();

        if ($expoVendor) {
            // Update slot count
            $expoVendor->slot += count($newSlots);
            $expoVendor->joined_at = now();
            $expoVendor->save();
            $joinedAny = true;
        } else {
            // Create new entry
            ExpoVendor::create([
                'expo_id' => $expo->id,
                'vendor_id' => $vendor->id,
                'slot' => count($newSlots),
                'joined_at' => now(),
                'name' => $vendor->name,
                'email' => $vendor->email,
                'mobile' => $vendor->phone,
                'description' => $vendor->description_en,
                'status' => 'pending',
            ]);
            $joinedAny = true;
        }

        // Handle slot booking
        $expoVendor = ExpoVendor::where('expo_id', $expo->id)
            ->where('vendor_id', $vendor->id)
            ->first();

        $booking = SlotBooking::where('expo_id', $expo->id)
            ->where('vendor_id', $vendor->id)
            ->first();

        $pricePerSlot = $this->getSlotPrice($expo);
        $finalBookedSlots = [];
        if (!$booking) {
            // New booking
            $finalBookedSlots = $newSlots;
            SlotBooking::create([
                'expo_id' => $expo->id,
                'vendor_expo_id' => $expoVendor ? $expoVendor->id : null,
                'vendor_id' => $vendor->id,
                'booked_slots' => $finalBookedSlots,
                'total_amount' => count($finalBookedSlots) * $pricePerSlot,
                'payment_status' => 'pending',
                'transaction_id' => 'TXN_' . time() . '_' . rand(1000, 9999),
            ]);
        } else {
            // Update existing booking
            $bookedSlots = $booking->booked_slots ?? [];
            $finalBookedSlots = array_unique(array_merge($bookedSlots, $newSlots));
            $booking->update([
                'booked_slots' => $finalBookedSlots,
                'total_amount' => count($finalBookedSlots) * $pricePerSlot,
            ]);
        }

        // Update ExpoVendor slot count to total unique slots
        $expoVendor = ExpoVendor::where('expo_id', $expo->id)
            ->where('vendor_id', $vendor->id)
            ->first();
        if ($expoVendor) {
            $expoVendor->slot = count($finalBookedSlots);
            $expoVendor->joined_at = now();
            $expoVendor->save();
        }

        if ($joinedAny) {
            return redirect()->back()->with('success', 'Joined expo successfully.');
        } else {
            return redirect()->back()->with('error', 'No slot joined.');
        }
    }

    /**
     * Book slots for an expo (creates booking, returns data for payment if needed)
     */
    public function bookSlots($expo, Request $request)
    {
        try {
            $user = $request->user();
            $vendor = method_exists($user, 'vendor') ? $user->vendor : null;
            if (!$vendor) {
                return response()->json(['error' => 'Vendor profile not found.'], 400);
            }

            if (trim((string) ($vendor->name ?? '')) === '') {
                \Log::info('BookSlots: Vendor name is empty, returning vendor_name_required error', [
                    'vendor_id' => $vendor->id,
                    'vendor_name' => $vendor->name,
                ]);
                return response()->json([
                    'error' => 'To book the expo slots you need to first fill in the name.',
                    'code' => 'vendor_name_required',
                ], 422);
            }

            $expo = Expo::findOrFail($expo);
            $selectedSlots = $request->input('slots', []);

            if (empty($selectedSlots)) {
                return response()->json(['error' => 'No slots selected.'], 400);
            }

            $newSlots = is_array($selectedSlots) ? $selectedSlots : [$selectedSlots];
            $totalAmount = $this->slotBookingService->calculateSlotPrice($expo, $newSlots);
            $isFreeParticipation = (bool) $expo->free_participation;
            $totalAmount = floatval($totalAmount);

            // Free participation or zero amount
            if ($isFreeParticipation || $totalAmount <= 0.01) {
                $result = $this->slotBookingService->bookFreeSlots($expo, $vendor, $user, $newSlots);

                return response()->json($result, 200, [], JSON_NUMERIC_CHECK);
            }

            // Paid booking
            $result = $this->slotBookingService->getPaidBookingData($expo, $newSlots, $totalAmount);

            return response()->json($result);
        } catch (\Exception $e) {
            return response()->json(['error' => 'An error occurred while booking slots: ' . $e->getMessage()], 500);
        }
    }

    /**
     * Verify that bookings exist in database
     */
    public function verifyBookings($expo, Request $request)
    {
        try {
            $user = $request->user();
            $vendor = method_exists($user, 'vendor') ? $user->vendor : null;
            if (!$vendor) {
                return response()->json(['error' => 'Vendor profile not found.'], 400);
            }

            $bookingIds = $request->input('booking_ids', []);

            if (!is_array($bookingIds)) {
                $bookingIds = [$bookingIds];
            }

            $result = $this->slotBookingService->verifyBookings($expo, $vendor->id, $bookingIds);

            $statusCode = $result['success'] ? 200 : ($result['message'] === 'No booking IDs provided' ? 400 : 404);

            return response()->json($result, $statusCode);
        } catch (\Exception $e) {
            return response()->json(['error' => 'Error verifying bookings: ' . $e->getMessage()], 500);
        }
    }

    public function processPayment($booking, Request $request)
    {
        $user = $request->user();
        $vendor = method_exists($user, 'vendor') ? $user->vendor : null;
        if (!$vendor) {
            return response()->json(['error' => 'Vendor profile not found.'], 400);
        }

        $expo = Expo::findOrFail($booking);
        $selectedSlots = $request->input('slots', []);
        $paymentMethod = $request->input('payment_method', 'cash'); // Default to cash if not provided

        if (empty($selectedSlots)) {
            return response()->json(['error' => 'No slots selected.'], 400);
        }

        $newSlots = is_array($selectedSlots) ? $selectedSlots : [$selectedSlots];
        $expoVendor = ExpoVendor::firstOrCreate(
            [
                'expo_id' => $expo->id,
                'vendor_id' => $vendor->id,
            ],
            [
                'slot' => count($newSlots),
                'joined_at' => now(),
                'name' => $vendor->name,
                'email' => $vendor->email,
                'mobile' => $vendor->phone,
                'description' => $vendor->description_en,
                'status' => 'paid',
            ]
        );
        $finalBookedSlots = $newSlots;
        $totalAmount = $this->slotBookingService->calculateSlotPrice($expo, $finalBookedSlots);

        // Create individual slot booking records for each slot
        $createdBookings = [];
        foreach ($finalBookedSlots as $slotNumber) {
            $booking = SlotBooking::create([
                'expo_id' => $expo->id,
                'vendor_expo_id' => $expoVendor ? $expoVendor->id : null,
                'vendor_id' => $vendor->id,
                'booked_slots' => [$slotNumber],
                'slot_number' => $slotNumber,
                'total_amount' => $this->slotBookingService->calculateSlotPrice($expo, [$slotNumber]),
                'payment_status' => 'paid',
                'transaction_id' => 'TXN_' . time() . '_' . $slotNumber . '_' . rand(1000, 9999),
            ]);
            $createdBookings[] = $booking;
        }

        // Create finance transactions for each slot booking
        $allTransactions = [];
        foreach ($createdBookings as $index => $booking) {
            $transactionId = 'TXN' . strtoupper(bin2hex(random_bytes(8)));
            $referenceId = 'REF' . strtoupper(bin2hex(random_bytes(8)));

            $transaction = FinanceTransaction::create([
                'transaction_id' => $transactionId,
                'user_type' => 'vendor',
                'type' => 'expo_booking',
                'status' => 'completed',
                'amount' => $booking->total_amount,
                'payment_processor' => $paymentMethod,
                'payment_reference_id' => $referenceId,
                'transactionable_type' => SlotBooking::class,
                'transactionable_id' => $booking->id,
                'user_id' => $user->id,
                'vendor_id' => $vendor->id,
                'summery' => 'Vendor expo slot ' . $booking->slot_number . ' booking payment',
                'metadata' => $booking->metadata ?? [],
                'attempt_status' => 'success',
                'attempted_at' => now(),
                'processed_at' => now(),
            ]);
            $allTransactions[] = $transaction;
        }

        // Update vendor slot count
        $allBookings = SlotBooking::where('expo_id', $expo->id)
            ->where('vendor_id', $vendor->id)
            ->get();

        $allBookedSlots = [];
        foreach ($allBookings as $bookingRecord) {
            if (isset($bookingRecord->slot_number)) {
                $allBookedSlots[] = $bookingRecord->slot_number;
            } else {
                // Fallback for old array format
                $allBookedSlots = array_merge($allBookedSlots, $bookingRecord->booked_slots ?? []);
            }
        }
        $uniqueSlots = array_unique($allBookedSlots);

        $expoVendor->slot = count($uniqueSlots);
        $expoVendor->joined_at = now();
        $expoVendor->save();

        // Prepare response data
        $totalAmountSum = array_sum(array_column($createdBookings, 'total_amount'));
        $bookedSlotNumbers = array_column($createdBookings, 'slot_number');

        return response()->json([
            'success' => true,
            'booking_ids' => array_column($createdBookings, 'id'),
            'total_amount' => $totalAmountSum,
            'total_slots_booked' => count($createdBookings),
            'booked_slots' => $bookedSlotNumbers,
            'individual_bookings' => array_map(function ($booking) {
                return [
                    'id' => $booking->id,
                    'slot_number' => $booking->slot_number,
                    'amount' => $booking->total_amount,
                    'transaction_id' => $booking->transaction_id,
                ];
            }, $createdBookings),
            'message' => 'Successfully booked ' . count($newSlots) . ' slots individually. Payment completed.',
        ]);
    }

    /**
     * Get available slots for an expo
     */
    public function getAvailableSlots($expoId)
    {
        $expo = Expo::findOrFail($expoId);
        $totalSlots = $expo->vendor_slot_capacity ?? 0;

        // Get booked slots from SlotBooking table (check both slot_number and booked_slots fields)
        $bookedSlotsFromSlotNumber = SlotBooking::where('expo_id', $expo->id)
            ->where('payment_status', 'paid')
            ->whereNotNull('slot_number')
            ->pluck('slot_number')
            ->unique()
            ->values()
            ->toArray();

        $bookedSlotsFromArray = SlotBooking::where('expo_id', $expo->id)
            ->where('payment_status', 'paid')
            ->get()
            ->flatMap(function ($booking) {
                return $booking->booked_slots ?? [];
            })
            ->unique()
            ->values()
            ->toArray();

        $bookedSlots = array_unique(array_merge($bookedSlotsFromSlotNumber, $bookedSlotsFromArray));

        $availableSlots = [];
        for ($i = 1; $i <= $totalSlots; $i++) {
            if (!in_array($i, $bookedSlots)) {
                $availableSlots[] = $i;
            }
        }

        // Filter to only show slots that have explicit pricing
        $slotPricing = $expo->slot_pricing;
        if (is_string($slotPricing)) {
            $slotPricing = json_decode($slotPricing, true);
        }

        if (is_array($slotPricing) && !empty($slotPricing)) {
            $slotsWithPricing = [];
            foreach ($availableSlots as $slotNumber) {
                $hasPricing = false;

                // Check for slot-specific pricing (handle both string and integer slot numbers)
                foreach ($slotPricing as $pricing) {
                    if (isset($pricing['slot'])) {
                        $pricingSlot = is_numeric($pricing['slot']) ? (int) $pricing['slot'] : $pricing['slot'];
                        $slotNum = is_numeric($slotNumber) ? (int) $slotNumber : $slotNumber;
                        if ($pricingSlot == $slotNum) {
                            $hasPricing = true;
                            break;
                        }
                    }
                    // Check for range-based pricing
                    if (isset($pricing['from']) && isset($pricing['to'])) {
                        $from = is_numeric($pricing['from']) ? (int) $pricing['from'] : $pricing['from'];
                        $to = is_numeric($pricing['to']) ? (int) $pricing['to'] : $pricing['to'];
                        $slotNum = is_numeric($slotNumber) ? (int) $slotNumber : $slotNumber;
                        if ($slotNum >= $from && $slotNum <= $to) {
                            $hasPricing = true;
                            break;
                        }
                    }
                }

                if ($hasPricing) {
                    $slotsWithPricing[] = $slotNumber;
                }
            }
            $availableSlots = $slotsWithPricing;
        }

        return response()->json([
            'available_slots' => $availableSlots,
            'total_slots' => $totalSlots,
            'booked_slots' => $bookedSlots,
        ]);
    }

    /**
     * Assign products to expo slots for a vendor
     */
    public function assignProducts($expoId, Request $request)
    {
        $user = $request->user();
        $vendor = method_exists($user, 'vendor') ? $user->vendor : null;
        if (!$vendor) {
            return redirect()->back()->with('error', 'Vendor profile not found.');
        }

        $productIds = $request->input('products', []);
        $expo = Expo::findOrFail($expoId);
        $slotCount = ExpoVendor::where('expo_id', $expoId)->where('vendor_id', $vendor->id)->count();
        $capacityPerSlot = $expo->product_capacity_per_slot ?? 1;
        $maxProducts = $slotCount * $capacityPerSlot;

        if (count($productIds) > $maxProducts) {
            return redirect()->back()->with('error', 'Product limit exceeded. You can assign up to ' . $maxProducts . ' products.');
        }

        // Assign selected products to this expo
        $vendor->products()->whereIn('id', $productIds)->update(['expo_id' => $expo->id]);
        // Unassign products that were previously assigned to this expo but not selected now
        $vendor->products()->where('expo_id', $expo->id)->whereNotIn('id', $productIds)->update(['expo_id' => null]);

        return redirect()->back()->with('success', 'Products assigned to expo slots.');
    }

    /**
     * Create section under category with products for a vendor in an expo
     */
    public function createSection($expoId, Request $request)
    {
        $user = $request->user();
        $vendor = method_exists($user, 'vendor') ? $user->vendor : null;
        if (!$vendor) {
            return redirect()->back()->withErrors(['section' => 'Vendor profile not found.']);
        }
        $categoryId = $request->input('category_id');
        $sectionName = $request->input('section_name');
        $productIds = $request->input('products', []);
        if (!$sectionName || !$categoryId) {
            return redirect()->back()->withErrors(['section' => 'Section name and category are required.']);
        }
        if (count($productIds) < 1) {
            return redirect()->back()->withErrors(['section' => 'A section must have at least one product.']);
        }
        // Create section
        $section = \App\Models\Section::create([
            'name_en' => $sectionName,
            'name_ar' => $sectionName, // You can update this for multi-language
            'category_id' => $categoryId,
            'expo_id' => $expoId,
            'vendor_id' => $vendor->id,
        ]);
        // Assign products to section
        $vendor->products()->whereIn('id', $productIds)->update(['section_id' => $section->id]);

        return redirect()->back()->with('success', 'Section created for expo.');
    }

    /**
     * Add coupon/discount for a product in expo
     */
    public function addCoupon($expoId, Request $request)
    {
        $user = $request->user();
        $vendor = method_exists($user, 'vendor') ? $user->vendor : null;
        if (!$vendor) {
            return redirect()->back()->withErrors(['coupon' => 'Vendor profile not found.']);
        }
        $productId = $request->input('product_id');
        $discount = $request->input('discount');
        if (!$productId || !$discount) {
            return redirect()->back()->withErrors(['coupon' => 'Product and discount are required.']);
        }
        // Create or update coupon
        \App\Models\ExpoProductCoupon::updateOrCreate(
            [
                'expo_id' => $expoId,
                'product_id' => $productId,
                'vendor_id' => $vendor->id,
            ],
            [
                'discount' => $discount,
            ]
        );

        return redirect()->back();
    }

    /**
     * List expos the vendor has joined (exclude expired)
     */
    public function myExpos(Request $request)
    {
        $user = $request->user();
        $vendor = method_exists($user, 'vendor') ? $user->vendor : null;
        if (!$vendor) {
            return redirect()->route('vendor.profile.index')->with('error', 'Vendor profile not found.');
        }
        $result = Expo::whereHas('expoVendors', function ($query) use ($vendor) {
            $query->where('vendor_id', $vendor->id);
        })
            ->whereIn('status', ['active', 'upcoming'])
            ->whereNull('deleted_at') // Exclude soft deleted expos
            ->where(function ($query) {
                $query->whereNull('end_date')
                    ->orWhere('end_date', '>=', now());
            })
            ->with([
                'categories',
                'expoVendors' => function ($query) use ($vendor) {
                    $query->where('vendor_id', $vendor->id);
                },
            ])
            ->get()
            ->map(function ($expo) use ($vendor) {
                // Get assigned products for this expo
                $assignedProducts = $vendor->expoproducts()
                    ->where('expo_id', $expo->id)
                    ->with([
                        'product' => function ($q) {
                        $q->select('id', 'name_en', 'name_ar', 'category_id');
                    },
                    ])
                    ->get()
                    ->map(function ($expoProduct) {
                    $product = $expoProduct->product;

                    return [
                        'id' => $product->id,
                        'name_en' => $product->name_en,
                        'name_ar' => $product->name_ar,
                        'category_id' => $product->category_id,
                        'status' => $product->status,
                        'assigned_slot' => $expoProduct->slot_id ?? null, // Add slot_id as assigned_slot
                    ];
                });

                $sections = ExpoSection::where('expo_id', $expo->id)
                    ->where('vendor_id', $vendor->id)
                    ->with(['section.category:id,name_en'])
                    ->get()
                    ->map(function ($expoSection) use ($vendor, $expo) {
                        $section = $expoSection->section;

                        // Calculate products in this section
                        $productsInSection = $vendor->expoproducts()
                            ->where('expo_id', $expo->id)
                            ->whereHas('product.sectionProducts', function ($q) use ($section) {
                            $q->where('section_id', $section->id);
                        })
                            ->count();

                        // Calculate total available products for this vendor in this expo
                        $slotCount = SlotBooking::where('expo_id', $expo->id)
                            ->where('vendor_id', $vendor->id)
                            ->count();
                        $capacityPerSlot = $expo->product_capacity_per_slot ?? 20;
                        $totalAvailableProducts = $slotCount * $capacityPerSlot;
                        // dd($slotCount, $capacityPerSlot, $totalAvailableProducts);
                        $assignedexpoperslotproduct = ExpoProduct::where('expo_id', $expo->id)
                            ->where('vendor_id', $vendor->id)
                            ->count();

                        // Calculate remaining products that can be added to this section
                        $totalAssignedProducts = $vendor->expoproducts()
                            ->where('expo_id', $expo->id)
                            ->count();
                        $remainingProducts = max(0, $totalAvailableProducts - $totalAssignedProducts);

                        return [
                            'id' => $section->id,
                            'name' => $section->name,
                            'name_en' => $section->name_en,
                            'name_ar' => $section->name_ar,
                            'category_id' => $section->category_id,
                            'category' => $section->category,
                            'status' => $section->status,
                            'products_in_section' => $productsInSection,
                            'total_available_products' => $totalAvailableProducts,
                            'remaining_products' => $remainingProducts,
                            'assigned_expo_products' => $assignedexpoperslotproduct,
                        ];
                    });

                $slotCount = SlotBooking::where('expo_id', $expo->id)->where('vendor_id', $vendor->id)->count();
                $capacityPerSlot = $expo->product_capacity_per_slot ?? 20;
                $maxProducts = $slotCount * $capacityPerSlot;

                // Calculate total products for each slot (including section products)
                $slotProducts = [];
                for ($slotNumber = 1; $slotNumber <= $slotCount; $slotNumber++) {
                    // Count direct products in this slot
                    $directProducts = ExpoProduct::where('expo_id', $expo->id)
                        ->where('vendor_id', $vendor->id)
                        ->where('slot_id', $slotNumber)
                        ->count();

                    // Count products from sections assigned to this slot
                    $assignedSections = ExpoSection::where('expo_id', $expo->id)
                        ->where('vendor_id', $vendor->id)
                        ->where('slot_id', $slotNumber)
                        ->pluck('section_id')
                        ->toArray();

                    $sectionProducts = 0;
                    if (!empty($assignedSections)) {
                        $sectionProducts = SectionProduct::whereIn('section_id', $assignedSections)->count();
                    }

                    // Total products in this slot
                    $totalSlotProducts = $directProducts + $sectionProducts;

                    $slotProducts[] = [
                        'id' => $slotNumber,
                        'slot_number' => $slotNumber,
                        'max_products' => $capacityPerSlot,
                        'assigned_products' => $totalSlotProducts,
                        'assigned_expo_section_product' => $sectionProducts,
                        'total_assigned' => $totalSlotProducts,
                        'current_products' => $totalSlotProducts,
                        'remaining_products' => max(0, $capacityPerSlot - $totalSlotProducts),
                        'utilization_percentage' => $capacityPerSlot > 0 ? round(($totalSlotProducts / $capacityPerSlot) * 100) : 0,
                        'is_full' => $totalSlotProducts >= $capacityPerSlot,
                        'products' => $assignedProducts->filter(function ($product) use ($slotNumber) {
                            return isset($product['assigned_slot']) && $product['assigned_slot'] == $slotNumber;
                        })->values()->toArray(),
                    ];
                }

                return [
                    'id' => $expo->id,
                    'title_en' => $expo->name_en,
                    'title_ar' => $expo->name_ar,
                    'start_date' => $expo->start_date,
                    'end_date' => $expo->end_date,
                    'products' => $assignedProducts,
                    'sections' => $sections,
                    'categories' => $expo->categories()->select('categories.id', 'categories.name_en', 'categories.name_ar')->get(),
                    'expired' => false,
                    'status' => $expo->status,
                    'maxProducts' => $maxProducts,
                    'slotCount' => $slotCount,
                    'vendor_slot_capacity' => $expo->vendor_slot_capacity,
                    'capacityPerSlot' => $capacityPerSlot,
                    'slots' => $slotProducts,
                ];
            });

        return Inertia::render('Expos/MyExpos', [
            'myExpos' => $result,
        ]);
    }

    /**
     * Toggle status (Suspend/Activate) for an expo
     */
    public function toggleStatus(Request $request, Expo $expo)
    {
        $newStatus = $request->input('status');
        if (!in_array($newStatus, ['active', 'suspended'])) {
            return redirect()->back()->with('error', 'Invalid status');
        }
        // If activating, block if expired
        if ($newStatus === 'active') {
            if ($expo->end_date && \Carbon\Carbon::parse($expo->end_date)->lt(now())) {
                return redirect()->back()->with('error', 'Cannot activate: Expo has already expired.');
            }
        }
        $expo->status = $newStatus;
        $expo->save();

        return redirect()->back()->with('success', 'Expo status updated!');
    }

    public function create()
    {
        return Inertia::render('Expos/Create');
    }

    public function edit(Expo $expo)
    {
        return Inertia::render('Expos/Edit', [
            'expo' => $expo,
        ]);
    }

    public function export(Request $request)
    {
        // Apply the same filters as in index()
        $query = Expo::query()->whereNull('deleted_at');

        // Name search (search param)
        if ($request->filled('search')) {
            $search = $request->input('search');
            $query->where(function ($q) use ($search) {
                $q->whereRaw('LOWER(name_en) LIKE ?', ['%' . strtolower($search) . '%'])
                    ->orWhereRaw('LOWER(name_ar) LIKE ?', ['%' . strtolower($search) . '%']);
            });
        }

        // Status filter
        $status = $request->input('status');
        if ($status && strtolower($status) !== 'all') {
            $query->whereRaw('LOWER(status) = ?', [strtolower($status)]);
        }

        // From date filter
        $from = $request->input('from');
        if ($from) {
            $query->whereDate('start_date', '>=', $from);
        }

        // To date filter
        $to = $request->input('to');
        if ($to) {
            $query->whereDate('end_date', '<=', $to);
        }

        $expos = $query->orderByDesc('id')->get();

        $headers = [
            'ID',
            'Name (EN)',
            'Name (AR)',
            'Description (EN)',
            'Description (AR)',
            'Start Date',
            'End Date',
            'Status',
            'Background Color',
            'Font Style',
            'Font Size',
            'Font Weight',
            'Vendor Slot Capacity',
            'Product Capacity Per Slot',
            'Slot Pricing',
            'Background Image',
            'Banner Image',
            'Created At',
            'Updated At',
        ];

        $data = $expos->map(function ($expo) {
            return [
                $expo->id,
                $expo->name_en,
                $expo->name_ar,
                strip_tags($expo->description_en ?? ''),
                strip_tags($expo->description_ar ?? ''),
                $expo->start_date ? date('Y-m-d H:i:s', strtotime($expo->start_date)) : '',
                $expo->end_date ? date('Y-m-d H:i:s', strtotime($expo->end_date)) : '',
                $expo->status,
                $expo->background_color ?? '',
                $expo->font_style ?? '',
                $expo->font_size ?? '',
                $expo->font_weight ?? '',
                $expo->vendor_slot_capacity ?? 0,
                $expo->product_capacity_per_slot ?? 0,
                $expo->slot_pricing ?? '',
                $expo->background_image ?? '',
                $expo->banner_image ?? '',
                $expo->created_at ? date('Y-m-d H:i:s', strtotime($expo->created_at)) : '',
                $expo->updated_at ? date('Y-m-d H:i:s', strtotime($expo->updated_at)) : '',
            ];
        });

        return \App\Helpers\ExportService::streamCsv($data, 'expos.csv', $headers);
    }

    public function removeProduct($expoId, $productId, Request $request)
    {
        $expo = Expo::findOrFail($expoId);
        $product = Product::findOrFail($productId);
        $expoProduct = ExpoProduct::where('expo_id', $expoId)->where('product_id', $productId)->where('vendor_id', $request->user()->vendor->id)->first();

        // dd('expoProduct', $expoProduct, 'expoId', $expoId, 'productId', $productId, 'vendorId', $request->user()->vendor->id);

        // Optionally, check if the current user/vendor owns this expo
        if (!$expoProduct) {
            return redirect()->back()->with('error', 'You are not authorized to remove this product from this expo.');
        }
        // Detach the product from the expo (assuming many-to-many)
        $expoProduct->delete();

        return redirect()->back()->with('success', 'Product removed from expo.');
    }

    public function removeSlot($expoId, $vendorId, $slotToRemove)
    {
        $booking = SlotBooking::where('expo_id', $expoId)
            ->where('vendor_id', $vendorId)
            ->first();
        if ($booking && is_array($booking->booked_slots)) {
            $updatedSlots = array_diff($booking->booked_slots, [$slotToRemove]);
            $booking->update([
                'booked_slots' => array_values($updatedSlots),
                'total_amount' => count($updatedSlots) * $this->getSlotPrice(Expo::findOrFail($expoId)),
            ]);
            // Update ExpoVendor slot count
            $expoVendor = ExpoVendor::where('expo_id', $expoId)
                ->where('vendor_id', $vendorId)
                ->first();
            if ($expoVendor) {
                $expoVendor->slot = count($updatedSlots);
                $expoVendor->save();
            }
        }
        // ...rest of your logic (redirect/response)
    }

    /**
     * Get vendor products for expo management
     */
    public function getVendorProducts($expoId, Request $request)
    {
        $user = $request->user();
        $vendor = method_exists($user, 'vendor') ? $user->vendor : null;
        if (!$vendor) {
            return response()->json(['error' => 'Vendor profile not found.'], 403);
        }

        $slotId = $request->input('slot_id');

        // Get all vendor products
        $allProducts = $vendor->products()
            ->select('id', 'name_en', 'name_ar', 'category_id', 'status')
            ->with(['category:id,name_en'])
            ->where('status', 'active')
            ->get();

        // Get products already assigned to this expo and slot
        $assignedProductsQuery = ExpoProduct::where('expo_id', $expoId)
            ->where('vendor_id', $vendor->id);

        if ($slotId) {
            $assignedProductsQuery->where('slot_id', $slotId);
        }

        $assignedProducts = $assignedProductsQuery
            ->with(['product:id,name_en,name_ar'])
            ->get()
            ->map(function ($expoProduct) {
                return [
                    'id' => $expoProduct->product->id,
                    'name_en' => $expoProduct->product->name_en,
                    'name_ar' => $expoProduct->product->name_ar,
                    'category_id' => $expoProduct->product->category_id,
                    'status' => $expoProduct->product->status,
                    'assigned_at' => $expoProduct->created_at,
                ];
            });

        // Count products from sections assigned to this slot
        $sectionProductsCount = 0;
        if ($slotId) {
            $assignedSectionIds = ExpoSection::where('expo_id', $expoId)
                ->where('vendor_id', $vendor->id)
                ->where('slot_id', $slotId)
                ->pluck('section_id')
                ->toArray();

            if (!empty($assignedSectionIds)) {
                $sectionProductsCount = SectionProduct::whereIn('section_id', $assignedSectionIds)->count();
            }
        }

        return response()->json([
            'all_products' => $allProducts,
            'assigned_products' => $assignedProducts,
            'section_products_count' => $sectionProductsCount,
        ]);
    }

    /**
     * Add product to expo
     */
    public function addProductToExpo($expoId, Request $request)
    {
        $user = $request->user();
        $vendor = method_exists($user, 'vendor') ? $user->vendor : null;
        if (!$vendor) {
            return response()->json(['error' => 'Vendor profile not found.'], 403);
        }

        $productIds = $request->input('product_ids');
        $slotId = $request->input('slot_id');

        if (!$productIds) {
            return response()->json(['error' => 'Product IDs are required.'], 400);
        }

        if (!$slotId) {
            return response()->json(['error' => 'Slot ID is required.'], 400);
        }

        // Check if product belongs to vendor
        $products = $vendor->products()->whereIn('id', $productIds)->get();
        if ($products->isEmpty()) {
            return response()->json(['error' => 'One or more products not found or not owned by vendor.'], 404);
        }

        $expo = Expo::findOrFail($expoId);
        $slotbooking = SlotBooking::where('expo_id', $expoId)
            ->where('vendor_id', $vendor->id)
            ->first();
        if (!$slotbooking) {
            return response()->json(['error' => 'You have not booked any slots for this expo.'], 400);
        }

        // Get slot capacity
        $capacityPerSlot = $expo->product_capacity_per_slot ?? 20;

        // Check if product is already assigned to this expo
        $existingAssignment = ExpoProduct::where('expo_id', $expoId)
            ->whereIn('product_id', $productIds)
            ->where('vendor_id', $vendor->id)
            ->where('slot_id', $slotId)
            ->first();

        if ($existingAssignment) {
            return response()->json(['error' => 'One or more products are already assigned to this expo.'], 400);
        }

        // Count direct products in this slot
        $currentAssignedCount = ExpoProduct::where('expo_id', $expoId)
            ->where('vendor_id', $vendor->id)
            ->where('slot_id', $slotId)
            ->count();

        // Count products from sections assigned to this slot
        $assignedSectionIds = \App\Models\ExpoSection::where('expo_id', $expoId)
            ->where('vendor_id', $vendor->id)
            ->where('slot_id', $slotId)
            ->pluck('section_id')
            ->toArray();

        $sectionProductsCount = 0;
        if (!empty($assignedSectionIds)) {
            $sectionProductsCount = \App\Models\SectionProduct::whereIn('section_id', $assignedSectionIds)->count();
        }

        // Total products in the slot (direct + section products)
        $totalSlotProducts = $currentAssignedCount + $sectionProductsCount;

        if (($totalSlotProducts + count($productIds)) > $capacityPerSlot) {
            $remaining = max(0, $capacityPerSlot - $totalSlotProducts);

            return response()->json(['error' => 'Product limit exceeded. You can assign up to ' . $capacityPerSlot . ' products in this slot. Remaining: ' . $remaining], 400);
        }

        // SECTION CAPACITY CHECK
        $sectionId = $request->input('section_id'); // If you send a single section_id for all products
        if ($sectionId) {
            $currentSectionCount = ExpoProduct::where('expo_id', $expoId)
                ->where('vendor_id', $vendor->id)
                ->where('section_id', $sectionId)
                ->count();
            $productsToAddCount = count($productIds);
            if (($currentSectionCount + $productsToAddCount) > $capacityPerSlot) {
                return response()->json([
                    'error' => "Section product limit exceeded. You can assign up to $capacityPerSlot products in this section.",
                ], 400);
            }
        }

        // Assign product to expo with slot capacity check
        foreach ($productIds as $productId) {
            ExpoProduct::create([
                'expo_id' => $expoId,
                'product_id' => $productId,
                'vendor_id' => $vendor->id,
                'slot_id' => $slotId,
            ]);
        }

        return response()->json(['message' => 'Products added to expo successfully.']);
    }

    /**
     * Remove product from expo
     */
    public function removeProductFromExpo($expoId, $productId, Request $request)
    {
        $user = $request->user();
        $vendor = method_exists($user, 'vendor') ? $user->vendor : null;
        if (!$vendor) {
            return response()->json(['error' => 'Vendor profile not found.'], 403);
        }

        $slotId = $request->input('slot_id');
        if (!$slotId) {
            return response()->json(['error' => 'Slot ID is required.'], 400);
        }

        $expoProduct = ExpoProduct::where('expo_id', $expoId)
            ->where('product_id', $productId)
            ->where('vendor_id', $vendor->id)
            ->where('slot_id', $slotId)
            ->first();

        if (!$expoProduct) {
            return response()->json(['error' => 'Product assignment not found.'], 404);
        }

        $expoProduct->forceDelete();

        return response()->json(['message' => 'Product removed from expo successfully.']);
    }

    /**
     * Get expo products for vendor
     */
    public function getExpoProducts($expoId, Request $request)
    {
        $user = $request->user();
        $vendor = method_exists($user, 'vendor') ? $user->vendor : null;
        if (!$vendor) {
            return response()->json(['error' => 'Vendor profile not found.'], 403);
        }

        $assignedProducts = ExpoProduct::where('expo_id', $expoId)
            ->where('vendor_id', $vendor->id)
            ->with(['product:id,name_en,name_ar,category_id,status'])
            ->get()
            ->map(function ($expoProduct) {
                return [
                    'id' => $expoProduct->product->id,
                    'name_en' => $expoProduct->product->name_en,
                    'name_ar' => $expoProduct->product->name_ar,
                    'category_id' => $expoProduct->product->category_id,
                    'status' => $expoProduct->product->status,
                    'assigned_at' => $expoProduct->created_at,
                ];
            });

        return response()->json(['products' => $assignedProducts]);
    }

    /**
     * Get vendor sections for expo management
     */
    public function getVendorSections($expoId, Request $request)
    {
        $user = $request->user();
        $vendor = method_exists($user, 'vendor') ? $user->vendor : null;
        if (!$vendor) {
            return response()->json(['error' => 'Vendor profile not found.'], 403);
        }

        $slotId = $request->input('slot_id');

        // Get sections already assigned to this expo and slot (if slot_id provided)
        $assignedSectionQuery = ExpoSection::where('expo_id', $expoId)
            ->where('vendor_id', $vendor->id);

        if ($slotId) {
            $assignedSectionQuery->where('slot_id', $slotId);
        }

        $assignedSectionIds = $assignedSectionQuery->pluck('section_id')->toArray();

        // Get all vendor sections (excluding already assigned ones)
        $allSections = $vendor->sections()
            ->select('id', 'name', 'category_id', 'status')
            ->with(['category:id,name_en'])
            ->where('status', 'active')
            ->whereNotIn('id', $assignedSectionIds)
            ->get();

        // Get sections already assigned to this expo and slot (if slot_id provided) with full details
        $assignedSectionsQuery = ExpoSection::where('expo_id', $expoId)
            ->where('vendor_id', $vendor->id);

        if ($slotId) {
            $assignedSectionsQuery->where('slot_id', $slotId);
        }

        $assignedSections = $assignedSectionsQuery
            ->with(['section.category:id,name_en'])
            ->get()
            ->map(function ($expoSection) {
                $section = $expoSection->section;

                return [
                    'id' => $section->id,
                    'name' => $section->name,
                    'name_en' => $section->name_en,
                    'name_ar' => $section->name_ar,
                    'category_id' => $section->category_id,
                    'category' => $section->category,
                    'status' => $section->status,
                    'assigned_at' => $expoSection->created_at,
                    'slot_id' => $expoSection->slot_id,
                ];
            });

        return response()->json([
            'all_sections' => $allSections,
            'assigned_sections' => $assignedSections,
        ]);
    }

    /**
     * Add section to expo
     */
    public function SectionaddToExpo($expoId, Request $request)
    {
        $user = $request->user();
        $vendor = method_exists($user, 'vendor') ? $user->vendor : null;
        if (!$vendor) {
            return response()->json(['error' => 'Vendor profile not found.'], 403);
        }

        $sectionIds = $request->input('section_ids');
        $slotId = $request->input('slot_id');

        if (!$sectionIds || !is_array($sectionIds) || empty($sectionIds)) {
            return response()->json(['error' => 'Section IDs array is required.'], 400);
        }

        if (!$slotId) {
            return response()->json(['error' => 'Slot ID is required.'], 400);
        }

        $addedSections = [];
        $skippedSections = [];
        $errors = [];
        $sections = Section::whereIn('id', $sectionIds)->get();

        // Get expo product capacity per slot
        $expo = Expo::find($expoId);
        if (!$expo) {
            return response()->json(['error' => 'Expo not found.'], 404);
        }
        $productCapacity = $expo->product_capacity_per_slot;

        // Count products already in the slot (including products from sections)
        $currentSlotProducts = ExpoProduct::where('slot_id', $slotId)->where('expo_id', $expoId)->where('vendor_id', $vendor->id)->count();

        // Count products from sections already assigned to this slot
        $assignedSections = ExpoSection::where('expo_id', $expoId)
            ->where('vendor_id', $vendor->id)
            ->where('slot_id', $slotId)
            ->pluck('section_id')
            ->toArray();

        $sectionProductsCount = 0;
        if (!empty($assignedSections)) {
            $sectionProductsCount = SectionProduct::whereIn('section_id', $assignedSections)->count();
        }

        // Total products in the slot (direct + section products)
        $totalCurrentSlotProducts = $currentSlotProducts + $sectionProductsCount;

        // Count total products in all sections being added
        $totalNewProducts = 0;
        $sectionProductCounts = [];
        foreach ($sections as $sectionItem) {
            $productCount = SectionProduct::where('section_id', $sectionItem->id)->count();
            $totalNewProducts += $productCount;
            $sectionProductCounts[] = [
                'section_id' => $sectionItem->id,
                'section_name' => $sectionItem->name_en ?? $sectionItem->name ?? "Section {$sectionItem->id}",
                'total_products' => $productCount,
            ];
        }

        // Calculate total after adding new sections
        $totalAfterAdding = $totalCurrentSlotProducts + $totalNewProducts;

        // Check if adding these sections would exceed the limit
        if ($totalAfterAdding > $productCapacity) {
            return response()->json([
                'error' => 'Product limit exceeded!',
                'message' => "Cannot add sections. Total products would be {$totalAfterAdding}, but slot capacity is {$productCapacity}.",
                'current_products' => $totalCurrentSlotProducts,
                'new_products' => $totalNewProducts,
                'capacity' => $productCapacity,
                'section_details' => $sectionProductCounts,
            ], 400);
        }

        // If within limit, proceed to add sections
        foreach ($sectionIds as $sectionId) {
            try {
                // Check if section belongs to vendor
                $section = $vendor->sections()->find($sectionId);
                if (!$section) {
                    $errors[] = "Section ID {$sectionId} not found or not owned by vendor.";

                    continue;
                }

                // Check if section is already assigned to this expo and slot
                $existingAssignment = ExpoSection::where('expo_id', $expoId)
                    ->where('section_id', $sectionId)
                    ->where('vendor_id', $vendor->id)
                    ->where('slot_id', $slotId)
                    ->first();

                if ($existingAssignment) {
                    $skippedSections[] = $section->name_en ?? $section->name ?? "Section {$sectionId}";

                    continue;
                }

                // Create expo section assignment
                ExpoSection::create([
                    'expo_id' => (int) $expoId,
                    'section_id' => (int) $sectionId,
                    'vendor_id' => (int) $vendor->id,
                    'slot_id' => (int) $slotId,
                ]);

                $addedSections[] = $section->name_en ?? $section->name ?? "Section {$sectionId}";
            } catch (\Exception $e) {
                $errors[] = "Error adding section ID {$sectionId}: " . $e->getMessage();
            }
        }

        // Prepare response message
        $message = '';
        if (!empty($addedSections)) {
            $message .= 'Successfully added ' . count($addedSections) . ' section(s): ' . implode(', ', $addedSections) . '. ';
        }
        if (!empty($skippedSections)) {
            $message .= count($skippedSections) . ' section(s) were already assigned: ' . implode(', ', $skippedSections) . '. ';
        }
        if (!empty($errors)) {
            $message .= 'Errors: ' . implode(', ', $errors);
        }

        return response()->json([
            'success' => true,
            'message' => $message,
            'added_count' => count($addedSections),
            'skipped_count' => count($skippedSections),
            'error_count' => count($errors),
            'current_products' => $totalCurrentSlotProducts,
            'new_products' => $totalNewProducts,
            'total_products' => $totalAfterAdding,
            'capacity' => $productCapacity,
            'section_details' => $sectionProductCounts,
        ]);
    }

    /**
     * Add multiple sections to expo
     */
    public function addSectionsToExpo($expoId, Request $request)
    {
        $user = $request->user();
        $vendor = method_exists($user, 'vendor') ? $user->vendor : null;
        if (!$vendor) {
            return response()->json(['error' => 'Vendor profile not found.'], 403);
        }

        $sectionIds = $request->input('section_ids');
        if (!$sectionIds || !is_array($sectionIds) || empty($sectionIds)) {
            return response()->json(['error' => 'Section IDs array is required.'], 400);
        }

        $addedSections = [];
        $skippedSections = [];
        $errors = [];

        foreach ($sectionIds as $sectionId) {
            try {
                // Check if section belongs to vendor
                $section = $vendor->sections()->find($sectionId);
                if (!$section) {
                    $errors[] = "Section ID {$sectionId} not found or not owned by vendor.";

                    continue;
                }

                // Check if section is already assigned to this expo
                $existingAssignment = ExpoSection::where('expo_id', $expoId)
                    ->where('section_id', $sectionId)
                    ->where('vendor_id', $vendor->id)
                    ->first();

                if ($existingAssignment) {
                    $skippedSections[] = $section->name_en ?? $section->name ?? "Section {$sectionId}";

                    continue;
                }

                // Create expo section assignment
                ExpoSection::create([
                    'expo_id' => $expoId,
                    'section_id' => $sectionId,
                    'vendor_id' => $vendor->id,
                ]);

                $addedSections[] = $section->name_en ?? $section->name ?? "Section {$sectionId}";
            } catch (\Exception $e) {
                $errors[] = "Error adding section ID {$sectionId}: " . $e->getMessage();
            }
        }

        // Prepare response message
        $message = '';
        if (!empty($addedSections)) {
            $message .= 'Successfully added ' . count($addedSections) . ' section(s): ' . implode(', ', $addedSections) . '. ';
        }
        if (!empty($skippedSections)) {
            $message .= count($skippedSections) . ' section(s) were already assigned: ' . implode(', ', $skippedSections) . '. ';
        }
        if (!empty($errors)) {
            $message .= 'Errors: ' . implode(', ', $errors);
        }

        if (empty($addedSections) && !empty($errors)) {
            return response()->json(['error' => $message], 400);
        }

        return response()->json([
            'message' => $message,
            'added_count' => count($addedSections),
            'skipped_count' => count($skippedSections),
            'error_count' => count($errors),
        ]);
    }

    /**
     * Remove section from expo
     */
    public function removeSectionFromExpo($expoId, $sectionId, Request $request)
    {
        $user = $request->user();
        $vendor = method_exists($user, 'vendor') ? $user->vendor : null;
        if (!$vendor) {
            return response()->json(['error' => 'Vendor profile not found.'], 403);
        }

        $slotId = $request->input('slot_id');

        $expoSectionQuery = ExpoSection::where('expo_id', $expoId)
            ->where('section_id', $sectionId)
            ->where('vendor_id', $vendor->id);

        if ($slotId) {
            $expoSectionQuery->where('slot_id', $slotId);
        }

        $expoSection = $expoSectionQuery->first();

        if (!$expoSection) {
            return response()->json(['error' => 'Section assignment not found.'], 404);
        }

        // Hard delete the expo section assignment
        $expoSection->forceDelete();

        return response()->json(['message' => 'Section removed from expo successfully.']);
    }

    /**
     * Get expo sections for vendor
     */
    public function getExpoSections($expoId, Request $request)
    {
        $user = $request->user();
        $vendor = method_exists($user, 'vendor') ? $user->vendor : null;
        if (!$vendor) {
            return response()->json(['error' => 'Vendor profile not found.'], 403);
        }
        $assignedSections = ExpoSection::where('expo_id', $expoId)
            ->where('vendor_id', $vendor->id)
            ->with(['section.category:id,name_en'])
            ->get()
            ->map(function ($expoSection) {
                $section = $expoSection->section;

                return [
                    'id' => $section->id,
                    'name' => $section->name,
                    'name_en' => $section->name_en,
                    'name_ar' => $section->name_ar,
                    'category_id' => $section->category_id,
                    'category' => $section->category,
                    'status' => $section->status,
                    'assigned_at' => $expoSection->created_at,
                ];
            });

        return response()->json(['sections' => $assignedSections]);
    }

    /**
     * Create new section for expo
     */
    public function createSectionForExpo($expoId, Request $request)
    {
        $user = $request->user();
        $vendor = method_exists($user, 'vendor') ? $user->vendor : null;
        if (!$vendor) {
            return response()->json(['error' => 'Vendor profile not found.'], 403);
        }

        $name = $request->input('name');
        $categoryId = $request->input('category_id');
        $productIds = $request->input('product_ids', []);
        $slotId = $request->input('slot_id');

        if (!$name || !$categoryId) {
            return response()->json(['error' => 'Section name and category are required.'], 400);
        }

        if (!$slotId) {
            return response()->json(['error' => 'Slot ID is required.'], 400);
        }

        // Create section
        $section = Section::create([
            'name' => $name,
            'name_en' => $name,
            'name_ar' => $name,
            'category_id' => $categoryId,
            'vendor_id' => $vendor->id,
            'status' => 'active',
        ]);

        // Assign products to section if provided
        if (!empty($productIds)) {
            $vendor->products()->whereIn('id', $productIds)->update(['section_id' => $section->id]);
        }

        // Create expo section assignment
        ExpoSection::create([
            'expo_id' => $expoId,
            'section_id' => $section->id,
            'vendor_id' => $vendor->id,
            'slot_id' => $slotId,
        ]);

        return response()->json([
            'message' => 'Section created successfully.',
            'section' => $section->load('category:id,name_en'),
        ]);
    }

    public function payWithMyFatoorah(Request $request)
    {
        $user = $request->user();
        $vendor = method_exists($user, 'vendor') ? $user->vendor : null;
        if (!$vendor) {
            return response()->json(['error' => 'Vendor profile not found.'], 400);
        }

        $expoId = $request->input('expo_id');
        $slots = $request->input('slots', []);
        $price = $request->input('price');
        $paymentMethod = $request->input('payment_method');
        $callbackUrl = route('vendor.expoBooking.callback');
        $errorUrl = route('vendor.expoBooking.error');

        $data = [
            'CustomerName' => $user->full_name ?? 'Customer',
            'NotificationOption' => 'Lnk',
            'InvoiceValue' => (float) $price,
            'DisplayCurrencyIso' => 'KWD',
            'MobileCountryCode' => '+965',
            'CustomerMobile' => $user->phone ?? '12345678',
            'CustomerEmail' => $user->email,
            'CallBackUrl' => $callbackUrl,
            'ErrorUrl' => $errorUrl,
            'Language' => 'en',
            'CustomerReference' => json_encode([
                'vendor_id' => $vendor->id,
                'expo_id' => $expoId,
                'slots' => $slots,
            ]),
            'UserDefinedField' => 'expo_booking',
        ];
        try {
            Log::info('Initiating MyFatoorah Payment for Expo', [
                'vendor_id' => $vendor->id,
                'expo_id' => $expoId,
                'price' => $price,
                'callback_url' => $callbackUrl,
            ]);

            // Use MyFatoorah Library - Following official documentation pattern
            $mfConfig = [
                'apiKey' => trim(config('myfatoorah.api_key')),
                'isTest' => config('myfatoorah.test_mode'), // false for live mode
                'countryCode' => strtoupper(config('myfatoorah.country_iso')),
                'loggerObj' => storage_path('logs/myfatoorah.log'),
                'loggerFunc' => null,
            ];

            if (empty($mfConfig['apiKey'])) {
                Log::error('MyFatoorah API Key Missing', ['config' => config('myfatoorah')]);

                return response()->json([
                    'success' => false,
                    'message' => 'Payment configuration error. Please contact support.',
                ], 500);
            }

            // Log config for debugging
            Log::info('MyFatoorah Config for Expo', [
                'api_key_length' => strlen($mfConfig['apiKey']),
                'api_key_preview' => substr($mfConfig['apiKey'], 0, 20) . '...',
                'mode' => $mfConfig['isTest'] ? 'TEST' : 'LIVE',
                'country_code' => $mfConfig['countryCode'],
            ]);
            // dd(config('services.myfatoorah.api_key'));

            try {
                $mfPayment = new MyFatoorahPayment($mfConfig);

                // Log the API URL that will be used
                $apiUrl = $mfPayment->getApiURL();
                $fullApiUrl = $apiUrl . '/v2/SendPayment';

                Log::info('MyFatoorah API URL for Expo', [
                    'base_url' => $apiUrl,
                    'full_url' => $fullApiUrl,
                ]);

                // First, test the API key with a direct HTTP call to get actual error
                try {
                    // Log request data for debugging
                    Log::info('MyFatoorah Request Data for Expo', [
                        'api_url' => $fullApiUrl,
                        'api_key_preview' => substr($mfConfig['apiKey'], 0, 20) . '...' . substr($mfConfig['apiKey'], -10),
                        'api_key_length' => strlen($mfConfig['apiKey']),
                        'request_data' => $data,
                    ]);

                    $testResponse = Http::withHeaders([
                        'Authorization' => 'Bearer ' . $mfConfig['apiKey'],
                        'Content-Type' => 'application/json',
                    ])
                        ->timeout(15)
                        ->post($fullApiUrl, $data);

                    $httpStatus = $testResponse->status();
                    $responseBody = $testResponse->body();
                    $responseJson = $testResponse->json();

                    Log::info('MyFatoorah Direct HTTP Test for Expo', [
                        'http_status' => $httpStatus,
                        'response_length' => strlen($responseBody),
                        'response_preview' => substr($responseBody, 0, 500),
                        'is_success' => $responseJson['IsSuccess'] ?? false,
                        'message' => $responseJson['Message'] ?? null,
                    ]);

                    // If direct HTTP works, return the payment URL
                    if ($httpStatus === 200 && isset($responseJson['IsSuccess']) && $responseJson['IsSuccess']) {
                        return response()->json([
                            'success' => true,
                            'payment_url' => $responseJson['Data']['InvoiceURL'] ?? null,
                        ]);
                    }

                    // Return actual error from MyFatoorah API
                    if ($httpStatus !== 200 || !isset($responseJson['IsSuccess']) || !$responseJson['IsSuccess']) {
                        Log::error('MyFatoorah API Error for Expo', [
                            'http_status' => $httpStatus,
                            'response' => $responseJson,
                            'response_body' => $responseBody,
                            'api_url' => $fullApiUrl,
                            'mode' => $mfConfig['isTest'] ? 'TEST' : 'LIVE',
                            'country_code' => $mfConfig['countryCode'],
                        ]);

                        return response()->json([
                            'success' => false,
                            'message' => $responseJson['Message'] ?? "HTTP {$httpStatus} error from MyFatoorah API",
                            'error_details' => [
                                'http_status' => $httpStatus,
                                'is_success' => $responseJson['IsSuccess'] ?? false,
                                'message' => $responseJson['Message'] ?? null,
                                'validation_errors' => $responseJson['ValidationErrors'] ?? null,
                                'full_response' => $responseJson,
                            ],
                        ], $httpStatus !== 200 ? $httpStatus : 500);
                    }
                } catch (\Exception $httpEx) {
                    Log::warning('MyFatoorah Direct HTTP Test Failed for Expo', [
                        'exception' => $httpEx->getMessage(),
                    ]);
                    // Continue to library call as fallback
                }

                // Use library to send payment (fallback)
                $paymentData = $mfPayment->sendPayment($data);

                Log::info('MyFatoorah Payment Success', [
                    'invoice_id' => $paymentData->InvoiceId ?? null,
                    'invoice_url' => $paymentData->InvoiceURL ?? null,
                ]);

                return response()->json([
                    'success' => true,
                    'payment_url' => $paymentData->InvoiceURL,
                ]);
            } catch (\Exception $e) {
                Log::error('MyFatoorah Payment Exception', [
                    'exception' => $e->getMessage(),
                    'trace' => $e->getTraceAsString(),
                    'file' => $e->getFile(),
                    'line' => $e->getLine(),
                    'request_data' => $data,
                    'api_url' => $apiUrl ?? 'N/A',
                    'api_key_length' => strlen($mfConfig['apiKey']),
                ]);

                return response()->json([
                    'success' => false,
                    'message' => $e->getMessage(),
                    'error_details' => [
                        'exception' => get_class($e),
                        'message' => $e->getMessage(),
                        'file' => $e->getFile(),
                        'line' => $e->getLine(),
                    ],
                ], 500);
            }
        } catch (\Exception $e) {
            Log::error('MyFatoorah Payment Outer Exception', [
                'exception' => $e->getMessage(),
                'trace' => $e->getTraceAsString(),
            ]);

            return response()->json([
                'success' => false,
                'message' => 'Payment initiation failed: ' . $e->getMessage(),
            ], 500);
        }
    }

    public function myFatoorahCallback(Request $request)
    {
        $paymentId = $request->paymentId;

        if (empty($paymentId)) {
            return redirect()->route('vendor.expoBooking.error')
                ->with('error', 'Payment ID is missing.');
        }

        $apiKey = config('myfatoorah.api_key');
        $testMode = config('myfatoorah.test_mode');
        // API URL based on test/live mode
        $baseUrl = $testMode
            ? 'https://apitest.myfatoorah.com/'
            : 'https://api.myfatoorah.com/';

        try {
            $httpResponse = Http::withHeaders([
                'Authorization' => 'Bearer ' . $apiKey,
                'Content-Type' => 'application/json',
            ])
                ->timeout(15)
                ->post($baseUrl . 'v2/GetPaymentStatus', [
                    'Key' => $paymentId,
                    'KeyType' => 'PaymentId',
                ]);

            $response = $httpResponse->json();

            // Check if response is valid
            if (!$response || !is_array($response)) {
                Log::error('MyFatoorah Callback - Invalid Response', [
                    'payment_id' => $paymentId,
                    'http_status' => $httpResponse->status(),
                    'response_body' => $httpResponse->body(),
                ]);

                return redirect()->route('vendor.expoBooking.error')
                    ->with('error', 'Invalid response from payment gateway.');
            }

            // Check if response has required keys
            if (!isset($response['IsSuccess']) || !isset($response['Data'])) {
                Log::error('MyFatoorah Callback - Missing Response Keys', [
                    'payment_id' => $paymentId,
                    'response' => $response,
                ]);

                return redirect()->route('vendor.expoBooking.error')
                    ->with('error', 'Invalid payment response structure.');
            }

            $customerReference = $response['Data']['CustomerReference'] ?? null;
            $decodedReference = is_string($customerReference) ? json_decode($customerReference, true) : [];

            // Log decoded reference for debugging
            Log::info('MyFatoorah Callback - Decoded Reference', [
                'customer_reference' => $customerReference,
                'decoded_reference' => $decodedReference,
                'is_array' => is_array($decodedReference),
            ]);

            $expoId = $decodedReference['expo_id'] ?? null;
            $vendorId = $decodedReference['vendor_id'] ?? null;
            $slots = $decodedReference['slots'] ?? [];

            // Log slots data
            Log::info('MyFatoorah Callback - Slots Data', [
                'slots_raw' => $slots,
                'slots_type' => gettype($slots),
                'is_array' => is_array($slots),
                'slots_count' => is_array($slots) ? count($slots) : 0,
            ]);

            $invoiceStatus = $response['Data']['InvoiceStatus'] ?? null;

            if ($response['IsSuccess'] && $invoiceStatus == 'Paid') {
                $expo = Expo::findOrFail($expoId);
                $vendor = Vendor::findOrFail($vendorId);
                $user = $vendor->user;

                // Handle different slot formats (array, string, JSON string)
                if (is_string($slots)) {
                    // Try to decode if it's a JSON string
                    $decodedSlots = json_decode($slots, true);
                    if (json_last_error() === JSON_ERROR_NONE && is_array($decodedSlots)) {
                        $slots = $decodedSlots;
                    } else {
                        // If it's a comma-separated string, convert to array
                        $slots = array_map('trim', explode(',', $slots));
                    }
                }

                $newSlots = is_array($slots) ? $slots : (is_numeric($slots) ? [(int) $slots] : []);

                // Validate slots are numeric and filter out empty values
                $newSlots = array_filter($newSlots, function ($slot) {
                    return is_numeric($slot) && $slot > 0;
                });
                $newSlots = array_map('intval', $newSlots); // Convert to integers
                $newSlots = array_values(array_unique($newSlots)); // Re-index and remove duplicates

                if (empty($newSlots)) {
                    Log::error('MyFatoorah Callback - Empty or invalid slots', [
                        'expo_id' => $expoId,
                        'vendor_id' => $vendorId,
                        'original_slots' => $decodedReference['slots'] ?? null,
                        'decoded_reference' => $decodedReference,
                    ]);
                    return redirect()->route('vendor.expoBooking.error')
                        ->with('error', 'No valid slots found in payment response. Please contact support.');
                }

                Log::info('MyFatoorah Callback - Processing Slots', [
                    'expo_id' => $expoId,
                    'vendor_id' => $vendorId,
                    'slots_count' => count($newSlots),
                    'slots' => $newSlots,
                ]);
                $expoVendor = ExpoVendor::firstOrCreate(
                    [
                        'expo_id' => $expo->id,
                        'vendor_id' => $vendor->id,
                    ],
                    [
                        'slot' => count($newSlots),
                        'joined_at' => now(),
                        'name' => $vendor->name,
                        'email' => $vendor->email,
                        'mobile' => $vendor->phone,
                        'description' => $vendor->description_en,
                        'status' => 'paid',
                    ]
                );
                $finalBookedSlots = $newSlots;
                $totalAmount = $this->slotBookingService->calculateSlotPrice($expo, $finalBookedSlots);

                // Get transaction data safely
                $invoiceTransactions = $response['Data']['InvoiceTransactions'] ?? [];
                $firstTransaction = !empty($invoiceTransactions) && isset($invoiceTransactions[0]) && is_array($invoiceTransactions[0]) ? $invoiceTransactions[0] : [];
                $transactionIdValue = $firstTransaction['TransactionId'] ?? null;

                // Create individual slot booking records for each slot
                // Check for existing bookings to avoid duplicates
                $createdBookings = [];
                foreach ($finalBookedSlots as $slotNumber) {
                    // Check if this slot is already booked for this vendor and expo
                    $existingBooking = SlotBooking::where('expo_id', $expo->id)
                        ->where('vendor_id', $vendor->id)
                        ->where('slot_number', $slotNumber)
                        ->where('payment_status', 'paid')
                        ->first();

                    if ($existingBooking) {
                        // Slot already booked, update vendor_expo_id if needed and use existing booking
                        if (!$existingBooking->vendor_expo_id && $expoVendor) {
                            $existingBooking->vendor_expo_id = $expoVendor->id;
                            $existingBooking->save();
                        }
                        $createdBookings[] = $existingBooking;
                        Log::info('Slot already booked, using existing booking', [
                            'slot_number' => $slotNumber,
                            'booking_id' => $existingBooking->id,
                            'expo_id' => $expo->id,
                            'vendor_id' => $vendor->id
                        ]);
                        continue;
                    }

                    // Create new booking only if slot is not already booked
                    $booking = SlotBooking::create([
                        'expo_id' => $expo->id,
                        'vendor_expo_id' => $expoVendor ? $expoVendor->id : null,
                        'vendor_id' => $vendor->id,
                        'booked_slots' => [$slotNumber],
                        'slot_number' => $slotNumber,
                        'total_amount' => $this->slotBookingService->calculateSlotPrice($expo, [$slotNumber]),
                        'payment_status' => 'paid',
                        'transaction_id' => $transactionIdValue ? 'TXN_' . $transactionIdValue : null,
                    ]);
                    $createdBookings[] = $booking;
                    Log::info('New slot booking created', [
                        'slot_number' => $slotNumber,
                        'booking_id' => $booking->id,
                        'expo_id' => $expo->id,
                        'vendor_id' => $vendor->id
                    ]);
                }

                // Create finance transaction for EACH slot booking (not just one for all)
                $referenceId = isset($firstTransaction['ReferenceId']) ? 'REF' . $firstTransaction['ReferenceId'] : null;
                // Extract payment details from MyFatoorah response
                $paymentGateway = $firstTransaction['PaymentGateway'] ?? null;
                $transactionStatus = $firstTransaction['TransactionStatus'] ?? null;

                // Create a FinanceTransaction for each slot booking
                // Only create finance transaction if it doesn't already exist for this booking
                foreach ($createdBookings as $booking) {
                    // Check if finance transaction already exists for this booking
                    $existingTransaction = FinanceTransaction::where('transactionable_type', SlotBooking::class)
                        ->where('transactionable_id', $booking->id)
                        ->where('status', 'completed')
                        ->first();

                    if ($existingTransaction) {
                        Log::info('Finance transaction already exists for booking', [
                            'booking_id' => $booking->id,
                            'slot_number' => $booking->slot_number,
                            'existing_transaction_id' => $existingTransaction->id
                        ]);
                        continue; // Skip creating duplicate finance transaction
                    }

                    // Generate unique transaction ID for each slot
                    $transactionId = $transactionIdValue
                        ? 'TXN' . $transactionIdValue . '_' . $booking->slot_number
                        : 'TXN_' . time() . '_' . $booking->slot_number;

                    FinanceTransaction::create([
                        'transaction_id' => $transactionId,
                        'user_type' => 'vendor',
                        'type' => 'expo_booking',
                        'status' => 'completed',
                        'amount' => $booking->total_amount, // Individual slot amount, not total
                        'payment_processor' => $paymentGateway,
                        'payment_reference_id' => $referenceId,
                        'transactionable_type' => SlotBooking::class,
                        'transactionable_id' => $booking->id,
                        'user_id' => $user->id,
                        'vendor_id' => $vendor->id,
                        'summery' => 'Vendor expo slot booking payment',
                        'metadata' => array_merge($response['Data'] ?? [], ['slot_number' => $booking->slot_number]),
                        'attempt_status' => $transactionStatus,
                        'attempted_at' => isset($firstTransaction['TransactionDate']) ? $firstTransaction['TransactionDate'] : now(),
                        'processed_at' => now(),
                    ]);

                    Log::info('Finance transaction created for booking', [
                        'booking_id' => $booking->id,
                        'slot_number' => $booking->slot_number,
                        'transaction_id' => $transactionId
                    ]);
                }

                // Update vendor slot count
                $allBookings = SlotBooking::where('expo_id', $expo->id)
                    ->where('vendor_id', $vendor->id)
                    ->get();

                $allBookedSlots = [];
                foreach ($allBookings as $bookingRecord) {
                    if (isset($bookingRecord->slot_number)) {
                        $allBookedSlots[] = $bookingRecord->slot_number;
                    } else {
                        // Fallback for old array format
                        $allBookedSlots = array_merge($allBookedSlots, $bookingRecord->booked_slots ?? []);
                    }
                }
                $uniqueSlots = array_unique($allBookedSlots);

                $expoVendor->slot = count($uniqueSlots);
                $expoVendor->joined_at = now();
                $expoVendor->save();

                return redirect()->route('vendor.my-expos.index')->with('success', 'Expo slot payment successful!');
            } else {
                return redirect()->route('vendor.my-expos.index')->with('error', 'Payment failed or not completed.');
            }
        } catch (\Exception $e) {
            Log::error('MyFatoorah Callback Exception', [
                'payment_id' => $paymentId ?? null,
                'exception' => $e->getMessage(),
                'file' => $e->getFile(),
                'line' => $e->getLine(),
                'trace' => $e->getTraceAsString(),
            ]);

            return redirect()->route('vendor.expoBooking.error')
                ->with('error', 'Payment processing error: ' . $e->getMessage());
        }
    }

    public function myFatoorahError()
    {
        return redirect()->route('vendor.my-expos.index')->with('error', 'Payment failed or not completed.');
    }
}
