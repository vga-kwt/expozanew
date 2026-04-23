<?php

namespace App\Http\Controllers\Vendor;

use App\Http\Controllers\Controller;
use App\Models\Ad;
use App\Models\Product;
use App\Models\Vendor;
use App\Models\Expo;
use App\Models\VendorSubscription;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Inertia\Inertia;
use Inertia\Response;
use Illuminate\Support\Facades\Log;

class AdController extends Controller
{
    /**
     * Display a listing of the vendor's ads.
     */
    public function index(Request $request)
    {
        $user = $request->user();
        $vendor = $user->vendor;

        if (!$vendor) {
            return redirect()->route('vendor.profile.index')
                ->with('error', 'Vendor profile not found.');
        }

        // Check subscription and ad limits
        $subscriptionInfo = $this->getSubscriptionInfo($vendor);

        $query = Ad::where('vendor_id', $vendor->id)
            ->with(['product', 'linkedVendor', 'expo']);

        // Search functionality
        if ($request->filled('search')) {
            $search = $request->get('search');
            $query->where(function ($q) use ($search) {
                $q->where('title_en', 'like', "%{$search}%")
                    ->orWhere('title_ar', 'like', "%{$search}%")
                    ->orWhere('description_en', 'like', "%{$search}%")
                    ->orWhere('description_ar', 'like', "%{$search}%");
            });
        }

        // Filter by status
        if ($request->filled('status') && $request->get('status') !== 'all') {
            $query->where('status', $request->get('status'));
        }

        // Filter by link type
        if ($request->filled('link_type') && $request->get('link_type') !== 'all') {
            $query->where('link_type', $request->get('link_type'));
        }

        // Filter by date range
        if ($request->filled('from_date')) {
            $query->where('start_date', '>=', $request->get('from_date'));
        }
        if ($request->filled('to_date')) {
            $query->where('end_date', '<=', $request->get('to_date'));
        }




        $ads = $query->paginate(10)->withQueryString();

        // Get options for link types
        $linkTypeOptions = [
            ['value' => 'product', 'label' => 'Product Page'],
            ['value' => 'vendor', 'label' => 'Vendor Profile'],
            ['value' => 'expo', 'label' => 'Expo View'],
            ['value' => 'external', 'label' => 'External Link'],
        ];

        $statusOptions = [
            ['value' => 'draft', 'label' => 'Draft'],
            ['value' => 'active', 'label' => 'Active'],
            ['value' => 'suspended', 'label' => 'Suspended'],
        ];

        // Provide vendor's products, expos for modal form
        $products = $vendor->products()->select('id', 'name_en', 'name_ar')->get();
        $expos = $vendor->expos()->select('expos.id', 'expos.name_en as title_en', 'expos.name_ar as title_ar')->get();

        return Inertia::render('Vendor/Ads/Index', [
            'ads' => $ads,
            'filters' => $request->only(['search', 'status', 'link_type', 'sort_by', 'sort_order']),
            'linkTypeOptions' => $linkTypeOptions,
            'statusOptions' => $statusOptions,
            'products' => $products,
            'expos' => $expos,
            'subscriptionInfo' => $subscriptionInfo,
            'isAdmin' => false, // Vendor users
        ]);
    }

    /**
     * Show the form for creating a new ad.
     */
    public function create(Request $request)
    {
        $user = $request->user();
        $vendor = $user->vendor;

        if (!$vendor) {
            return redirect()->route('vendor.profile.index')
                ->with('error', 'Vendor profile not found.');
        }

        // Check subscription and ad limits
        $subscriptionInfo = $this->getSubscriptionInfo($vendor);

        if ($subscriptionInfo['currentAds'] >= $subscriptionInfo['adLimit']) {
            return redirect()->route('vendor.ads.index')
                ->with('error', 'You have reached your ad limit for your current subscription plan.');
        }

        // Get vendor's products and expos for form
        $products = $vendor->products()->select('id', 'name_en', 'name_ar')->get();
        $expos = $vendor->expos()->select('expos.id', 'expos.name_en as title_en', 'expos.name_ar as title_ar')->get();

        $linkTypeOptions = [
            ['value' => 'product', 'label' => 'Product Page'],
            ['value' => 'vendor', 'label' => 'Vendor Profile'],
            ['value' => 'expo', 'label' => 'Expo View'],
            ['value' => 'external', 'label' => 'External Link'],
        ];

        return Inertia::render('Vendor/Ads/Create', [
            'products' => $products,
            'expos' => $expos,
            'linkTypeOptions' => $linkTypeOptions,
            'subscriptionInfo' => $subscriptionInfo,
        ]);
    }

    /**
     * Store a newly created ad.
     */
    public function store(Request $request)
    {
        $user = $request->user();
        $vendor = $user->vendor;

        if (!$vendor) {
            return redirect()->back()->withErrors(['error' => 'Vendor profile not found.']);
        }

        // Check subscription and ad limits
        $subscriptionInfo = $this->getSubscriptionInfo($vendor);

        if ($subscriptionInfo['currentAds'] >= $subscriptionInfo['adLimit']) {
            return redirect()->back()->withErrors(['error' => 'You have reached your ad limit for your current subscription plan.']);
        }
        $validated = $request->validate([
            'title_en' => 'required|string|max:255',
            'title_ar' => 'required|string|max:255',
            'description_en' => 'nullable|string',
            'description_ar' => 'nullable|string',
            'banners' => 'required|image|mimes:jpeg,png,jpg,gif|max:5120',
            'link_type' => 'nullable|in:product,vendor,expo,external',
            'link_id' => 'nullable|integer|exists:' . $this->getLinkTable($request->link_type) . ',id',
            'external_link' => 'nullable|url|required_if:link_type,external',
            'status' => 'required|in:draft,active,suspended',
            'priority' => 'required|integer|min:0|max:100',
            'start_date' => 'nullable|date:Y-m-d H:i|after:now',
            'end_date' => 'nullable|date:Y-m-d H:i|after:start_date',
        ]);

        // Validate that the linked item belongs to the vendor
        if ($request->link_type === 'product') {
            $product = $vendor->products()->find($request->link_id);
            if (!$product) {
                return redirect()->back()->withErrors(['link_id' => 'Selected product does not belong to your account.']);
            }
        } elseif ($request->link_type === 'expo') {
            $expo = $vendor->expos()->find($request->link_id);
            if (!$expo) {
                return redirect()->back()->withErrors(['link_id' => 'Selected expo does not belong to your account.']);
            }
        }

        $disk = config('filesystems.default', 's3');

        // Handle image upload
        if ($request->hasFile('banners')) {
            $imagePath = $request->file('banners')->store('ads/banners', $disk);
            $validated['banners'] = $imagePath;
        }

        // Clear link_id if link_type is external
        if ($validated['link_type'] === 'external') {
            $validated['link_id'] = null;
        }

        // Set vendor_id
        $validated['vendor_id'] = $vendor->id;

        Ad::create($validated);

        return redirect()->route('vendor.ads.index')
            ->with('success', 'Ad created successfully.');
    }

    /**
     * Show the form for editing the specified ad.
     */
    public function edit(Ad $ad): Response
    {
        $ad->load(['product', 'vendor', 'expo']);

        // Get options for linkable items with more details
        $products = Product::select('id', 'name_en', 'name_ar', 'description_en', 'description_ar', 'vendor_id', 'regular_price', 'sale_price')
            ->with('vendor:id,name')
            ->get()
            ->map(function ($product) {
                $vendorName = $product->vendor ? $product->vendor->name : 'N/A';
                $price = $product->sale_price ?? $product->regular_price ?? 'N/A';
                return [
                    'id' => $product->id,
                    'name_en' => $product->name_en,
                    'name_ar' => $product->name_ar,
                    'description_en' => $product->description_en,
                    'description_ar' => $product->description_ar,
                    'vendor_name' => $vendorName,
                    'price' => $price,
                    'display_text' => "{$product->name_en} - KD {$price} ({$vendorName})"
                ];
            });

        $vendors = Vendor::select('id', 'name', 'brand_name_en', 'email', 'mobile', 'kyc_status')
            ->get()
            ->map(function ($vendor) {
                return [
                    'id' => $vendor->id,
                    'name' => $vendor->name,
                    'brand_name_en' => $vendor->brand_name_en,
                    'name_en' => $vendor->brand_name_en ?? $vendor->name,
                    'name_ar' => $vendor->name,
                    'email' => $vendor->email,
                    'mobile' => $vendor->mobile,
                    'kyc_status' => $vendor->kyc_status,
                    'display_text' => ($vendor->brand_name_en ?? $vendor->name) . " ({$vendor->email}) - {$vendor->kyc_status}"
                ];
            });

        $expos = Expo::select('id', 'name_en as title_en', 'name_ar as title_ar', 'description_en', 'description_ar', 'start_date', 'end_date')
            ->get()
            ->map(function ($expo) {
                return [
                    'id' => $expo->id,
                    'title_en' => $expo->title_en,
                    'title_ar' => $expo->title_ar,
                    'description_en' => $expo->description_en,
                    'description_ar' => $expo->description_ar,
                    'start_date' => $expo->start_date,
                    'end_date' => $expo->end_date,
                    'display_text' => "{$expo->title_en} ({$expo->start_date} - {$expo->end_date})"
                ];
            });

        $linkTypeOptions = [
            ['value' => 'product', 'label' => 'Product Page'],
            ['value' => 'vendor', 'label' => 'Vendor Profile'],
            ['value' => 'expo', 'label' => 'Expo View'],
            ['value' => 'external', 'label' => 'External Link'],
        ];

        return Inertia::render('Vendor/Ads/Edit', [
            'ad' => $ad,
            'products' => $products,
            'vendors' => $vendors,
            'expos' => $expos,
            'linkTypeOptions' => $linkTypeOptions,
        ]);
    }

    /**
     * Update the specified ad.
     */
    public function update(Request $request, Ad $ad)
    {
        $user = $request->user();
        $vendor = $user->vendor;

        if (!$vendor || $ad->vendor_id !== $vendor->id) {
            return redirect()->route('vendor.ads.index')
                ->with('error', 'Ad not found or access denied.');
        }
        $validated = $request->validate([
            'title_en' => 'required|string|max:255',
            'title_ar' => 'required|string|max:255',
            'description_en' => 'nullable|string',
            'description_ar' => 'nullable|string',
            'banners' => 'nullable|image|mimes:jpeg,png,jpg,gif|max:5120',
            'link_type' => 'nullable|in:product,vendor,expo,external',
            'link_id' => 'nullable|integer|exists:' . $this->getLinkTable($request->link_type) . ',id',
            'external_link' => 'nullable|url|required_if:link_type,external',
            'status' => 'required|in:draft,active,suspended',
            'priority' => 'required|integer|min:0|max:100',
            'start_date' => 'nullable',
            'end_date' => 'nullable',
        ]);


        // Validate that the linked item belongs to the vendor
        if ($request->link_type === 'product') {
            $product = $vendor->products()->find($request->link_id);
            if (!$product) {
                return redirect()->back()->withErrors(['link_id' => 'Selected product does not belong to your account.']);
            }
        } elseif ($request->link_type === 'expo') {
            $expo = $vendor->expos()->find($request->link_id);
            if (!$expo) {
                return redirect()->back()->withErrors(['link_id' => 'Selected expo does not belong to your account.']);
            }
        }

        $disk = config('filesystems.default', 's3');

        // Handle image upload
        if ($request->hasFile('banners')) {
            // Delete old image
            if ($ad->banners) {
                Storage::disk($disk)->delete($ad->banners);
            }

            $imagePath = $request->file('banners')->store('ads/banners', $disk);
            $validated['banners'] = $imagePath;
        } else {
            // Keep the old image if not uploading a new one
            $validated['banners'] = $ad->banners;
        }

        // Clear link_id if link_type is external
        if ($validated['link_type'] === 'external') {
            $validated['link_id'] = null;
        }

        $ad->update($validated);

        return redirect()->route('vendor.ads.index')
            ->with('success', 'Ad updated successfully.');
    }

    /**
     * Remove the specified ad.
     */
    public function destroy(Request $request, Ad $ad)
    {
        $user = $request->user();
        $vendor = $user->vendor;

        if (!$vendor || $ad->vendor_id !== $vendor->id) {
            return redirect()->route('vendor.ads.index')
                ->with('error', 'Ad not found or access denied.');
        }

        $disk = config('filesystems.default', 's3');

        // Delete banner image
        if ($ad->banners) {
            Storage::disk($disk)->delete($ad->banners);
        }

        $ad->delete();

        return redirect()->route('vendor.ads.index')
            ->with('success', 'Ad deleted successfully.');
    }

    /**
     * Toggle ad status
     */
    public function toggleStatus(Request $request, Ad $ad)
    {
        $user = $request->user();
        $vendor = $user->vendor;

        if (!$vendor || $ad->vendor_id !== $vendor->id) {
            return redirect()->route('vendor.ads.index')
                ->with('error', 'Ad not found or access denied.');
        }

        $newStatus = $ad->status === 'active' ? 'suspended' : 'active';
        $ad->update(['status' => $newStatus]);

        return redirect()->route('vendor.ads.index')
            ->with('success', "Ad status updated to {$newStatus}.");
    }

    /**
     * Get subscription information for the vendor
     */
    private function getSubscriptionInfo(Vendor $vendor): array
    {
        $activeSubscription = VendorSubscription::where('vendor_id', $vendor->id)
            ->where('status', 'active')
            ->where('end_date', '>', now())
            ->with('subscription')
            ->first();

        $currentAds = Ad::where('vendor_id', $vendor->id)->count();

        if (!$activeSubscription) {
            return [
                'hasSubscription' => false,
                'planName' => 'No Active Plan',
                'adLimit' => 0,
                'currentAds' => $currentAds,
                'remainingAds' => 0,
            ];
        }

        $adLimit = $activeSubscription->subscription->ad_limit ?? 0;

        return [
            'hasSubscription' => true,
            'planName' => $activeSubscription->subscription->title_en,
            'adLimit' => $adLimit,
            'currentAds' => $currentAds,
            'remainingAds' => max(0, $adLimit - $currentAds),
        ];
    }

    /**
     * Get the appropriate table name for link validation
     */
    private function getLinkTable(?string $linkType): string
    {
        return match ($linkType) {
            'product' => 'products',
            'vendor' => 'vendors',
            'expo' => 'expos',
            default => 'products', // fallback
        };
    }

    public function export(Request $request)
    {
        try {
            $user = $request->user();
            $vendor = $user->vendor;
            if (!$vendor) {
                return response()->json(['error' => 'Vendor profile not found.'], 404);
            }
            $query = Ad::where('vendor_id', $vendor->id)
                ->with(['product', 'linkedVendor', 'expo']);

            // Apply the same filters as the index method
            if ($request->filled('search')) {
                $search = $request->get('search');
                $query->where(function ($q) use ($search) {
                    $q->where('title_en', 'like', "%{$search}%")
                        ->orWhere('title_ar', 'like', "%{$search}%")
                        ->orWhere('description_en', 'like', "%{$search}%")
                        ->orWhere('description_ar', 'like', "%{$search}%")
                        ->orWhere('external_link', 'like', "%{$search}%")
                        // Linked Product
                        ->orWhere(function ($q2) use ($search) {
                            $q2->where('link_type', 'product')
                                ->whereHas('product', function ($q3) use ($search) {
                                    $q3->where('name_en', 'like', "%$search%")
                                        ->orWhere('name_ar', 'like', "%$search%");
                                });
                        })
                        // Linked Vendor
                        ->orWhere(function ($q2) use ($search) {
                            $q2->where('link_type', 'vendor')
                                ->whereHas('linkedVendor', function ($q3) use ($search) {
                                    $q3->where('name', 'like', "%$search%");
                                });
                        })
                        // Linked Expo
                        ->orWhere(function ($q2) use ($search) {
                            $q2->where('link_type', 'expo')
                                ->whereHas('expo', function ($q3) use ($search) {
                                    $q3->where('title_en', 'like', "%$search%")
                                        ->orWhere('title_ar', 'like', "%$search%");
                                });
                        });
                });
            }

            // Filter by status
            if ($request->filled('status') && $request->get('status') !== 'all') {
                $query->where('status', $request->get('status'));
            }

            // Filter by link type
            if ($request->filled('link_type') && $request->get('link_type') !== 'all') {
                $query->where('link_type', $request->get('link_type'));
            }

            // Filter by date range
            if ($request->filled('from_date')) {
                $query->where('start_date', '>=', $request->get('from_date'));
            }
            if ($request->filled('to_date')) {
                $query->where('end_date', '<=', $request->get('to_date'));
            }

            // Filter by linked item name
            if ($request->filled('linked_item')) {
                $name = $request->linked_item;
                $query->where(function ($q) use ($name) {
                    $q->where(function ($q2) use ($name) {
                        $q2->where('link_type', 'product')
                            ->whereHas('product', function ($q3) use ($name) {
                                $q3->where('name_en', 'like', "%$name%")
                                    ->orWhere('name_ar', 'like', "%$name%");
                            });
                    })
                        ->orWhere(function ($q2) use ($name) {
                            $q2->where('link_type', 'vendor')
                                ->whereHas('linkedVendor', function ($q3) use ($name) {
                                    $q3->where('name', 'like', "%$name%");
                                });
                        })
                        ->orWhere(function ($q2) use ($name) {
                            $q2->where('link_type', 'expo')
                                ->whereHas('expo', function ($q3) use ($name) {
                                    $q3->where('title_en', 'like', "%$name%")
                                        ->orWhere('title_ar', 'like', "%$name%");
                                });
                        });
                });
            }

            // Sort functionality with validation
            $sortBy = $request->get('sort_by', 'created_at');
            if (empty($sortBy)) {
                $sortBy = 'created_at';
            }
            $sortOrder = strtolower($request->get('sort_order', 'desc'));
            if (!in_array($sortOrder, ['asc', 'desc'])) {
                $sortOrder = 'desc';
            }

            if ($sortBy === 'priority') {
                $query->orderBy('priority', $sortOrder);
            } elseif ($sortBy === 'date_range') {
                $query->orderBy('start_date', $sortOrder);
            } else {
                $query->orderBy($sortBy, $sortOrder);
            }

            $ads = $query->get();
            $filename = 'ads_export_' . date('Y-m-d_H-i-s') . '.csv';

            $headers = [
                'Content-Type' => 'text/csv; charset=UTF-8',
                'Content-Disposition' => 'attachment; filename="' . $filename . '"',
                'Cache-Control' => 'no-cache, must-revalidate',
                'Pragma' => 'no-cache',
            ];

            $callback = function () use ($ads) {
                $file = fopen('php://output', 'w');

                // Add BOM for UTF-8
                fprintf($file, chr(0xEF) . chr(0xBB) . chr(0xBF));

                // CSV Headers
                fputcsv($file, [
                    '#', // Serial number
                    'ID',
                    'Title (English)',
                    'Title (Arabic)',
                    'Description (English)',
                    'Description (Arabic)',
                    'Link Type',
                    'Linked Item',
                    'External Link',
                    'Status',
                    'Priority',
                    'Start Date',
                    'End Date',
                    'Created At',
                    'Updated At'
                ]);

                // CSV Data
                $i = 1;
                foreach ($ads as $ad) {
                    $linkedItem = '';
                    if ($ad->link_type === 'external') {
                        $linkedItem = $ad->external_link;
                    } else {
                        $item = $ad->product ?? $ad->linkedVendor ?? $ad->expo;
                        if ($item) {
                            if (property_exists($item, 'name_en')) {
                                $linkedItem = $item->name_en . ' (' . $item->name_ar . ')';
                            } else {
                                $linkedItem = $item->title_en . ' (' . $item->title_ar . ')';
                            }
                        }
                    }

                    fputcsv($file, [
                        $i++,
                        $ad->id,
                        $ad->title_en,
                        $ad->title_ar,
                        $ad->description_en,
                        $ad->description_ar,
                        $ad->link_type,
                        $linkedItem,
                        $ad->external_link,
                        $ad->status,
                        $ad->priority,
                        $ad->start_date,
                        $ad->end_date,
                        $ad->created_at,
                        $ad->updated_at
                    ]);
                }

                fclose($file);
            };

            return response()->stream($callback, 200, $headers);
        } catch (\Exception $e) {
            Log::error('Ads export failed', [
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString(),
                'filters' => $request->all()
            ]);

            return response()->json([
                'error' => 'Export failed. Please try again.',
                'message' => $e->getMessage()
            ], 500);
        }
    }
}
