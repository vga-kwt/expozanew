<?php

namespace App\Http\Controllers;

use App\Models\FinanceTransaction;
use App\Models\Vendor;
use App\Models\Order;
use App\Models\Subscription;
use App\Models\User;
use App\Models\VendorSubscription;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Log;
use Inertia\Inertia;
use App\Models\Setting;

class VendorController extends Controller
{
    // List & search vendors
    public function index(Request $request)
    {
        $query = Vendor::with('user');
        if ($search = $request->input('search')) {
            $query->where(function ($q) use ($search) {
                $q->where('name', 'like', "%$search%")
                    ->orWhere('email', 'like', "%$search%")
                    ->orWhere('mobile', 'like', "%$search%");
            });
        }
        if ($status = $request->input('status')) {
            $query->where('status', $status);
        }
        if ($kycStatus = $request->input('kycStatus')) {
            $query->where('kyc_status', $kycStatus);
        }
        if ($from = $request->input('from')) {
            $query->whereDate('created_at', '>=', $from);
        }
        if ($to = $request->input('to')) {
            $query->whereDate('created_at', '<=', $to);
        }
        $vendors = $query->orderByDesc('id')->paginate(10)->withQueryString();
        $defaultCommission = Setting::where('key', 'vendor_commission')->value('value');
        return Inertia::render('Vendors/Index', [
            'vendors' => $vendors,
            'filters' => $request->only(['search', 'status', 'from', 'to', 'kycStatus']),
            'defaultCommission' => $defaultCommission,
        ]);
    }

    // Show vendor profile + history
    public function show(Request $request, Vendor $vendor)
    {
        $orders = Order::whereHas('orderItems.product', function ($query) use ($vendor) {
            $query->where('vendor_id', $vendor->id);
        })->with('user', 'orderItems.product')->orderByDesc('id')->paginate(10);
        // TODO: Add product listings, expo participation if needed
        return response()->json([
            'vendor' => $vendor,
            'orders' => $orders,
        ]);
    }

    // Vendor details for modal tabs (orders, products, expos)
    public function details(Request $request, Vendor $vendor)
    {
        $ordersPage = $request->input('orders_page', 1);
        $productsPage = $request->input('products_page', 1);
        $exposPage = $request->input('expos_page', 1);

        $orders = Order::whereHas('orderItems.product', function ($query) use ($vendor) {
            $query->where('vendor_id', $vendor->id);
        })
            ->with('user', 'orderItems.product')
            ->orderByDesc('id')
            ->paginate(10, ['*'], 'orders_page', $ordersPage);

        $products = $vendor->products()
            ->with('category') // eager load category
            ->orderByDesc('id')
            ->paginate(10, ['*'], 'products_page', $productsPage);

        $expos = $vendor->expos()
            ->orderByDesc('expos.id')
            ->paginate(10, ['*'], 'expos_page', $exposPage);

        // Get current subscription and subscription history
        $currentSubscription = $vendor->subscription;
        $currentVendorSubscription = $vendor->subscriptions()
            ->with('subscription')
            ->where('status', 'active')
            ->latest()
            ->first();
        $subscriptionHistory = $vendor->subscriptions()
            ->with('subscription')
            ->orderByDesc('created_at')
            ->get();

        return response()->json([
            'orders' => $orders,
            'products' => $products,
            'expos' => $expos,
            'subscriptions' => [
                'current' => $currentSubscription,
                'currentVendorSubscription' => $currentVendorSubscription,
                'history' => $subscriptionHistory
            ],
        ]);
    }

    // Update vendor profile
    public function update(Request $request, Vendor $vendor)
    {
        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'brand_name_en' => 'nullable|string|max:255',
            'brand_name_ar' => 'nullable|string|max:255',
            'description_en' => 'nullable|string',
            'description_ar' => 'nullable|string',
            'email' => 'required|email|unique:vendors,email,' . $vendor->id . ',id',
            'mobile' => 'nullable|string|max:20',
            'phone' => 'nullable|string|max:20',
            'status' => 'required|string|in:active,suspended',
            'commission' => 'nullable|numeric|min:0|max:100',
            'kyc_status' => 'nullable|string|in:pending,approved,rejected',
            'kyc_rejection_reason' => 'nullable|string',
            'kyc_rejection_reason_en' => 'nullable|string',
            'kyc_rejection_reason_ar' => 'nullable|string',
            'logo' => 'nullable|image',
        ]);

        $disk = config('filesystems.default', 's3');
        
        // Handle logo upload if present
        if ($request->hasFile('logo')) {
            $logoPath = $request->file('logo')->store('vendor-logos', $disk);
            $validated['logo'] = $logoPath;
        }

        // Update user fields
        $userData = [
            'full_name' => $validated['name'],
            'email' => $validated['email'] ?? null,
            'phone' => $validated['phone'] ?? null,
        ];
        $vendor->user()->update($userData);

        // Only update mobile in vendor
        $vendor->update([
            'name' => $validated['name'],
            'email' => $validated['email'] ?? null,
            'mobile' => $validated['mobile'] ?? null,
            'brand_name_en' => $validated['brand_name_en'] ?? null,
            'brand_name_ar' => $validated['brand_name_ar'] ?? null,
            'description_en' => $validated['description_en'] ?? null,
            'description_ar' => $validated['description_ar'] ?? null,
            'status' => $validated['status'],
            'commission' => $validated['commission'] ?? null,
            'kyc_status' => $validated['kyc_status'] ?? null,
            'kyc_rejection_reason' => $validated['kyc_rejection_reason'] ?? null,
            'kyc_rejection_reason_en' => $validated['kyc_rejection_reason_en'] ?? null,
            'kyc_rejection_reason_ar' => $validated['kyc_rejection_reason_ar'] ?? null,
            'logo' => $validated['logo'] ?? $vendor->logo,
        ]);

        return redirect()->back()->with('success', 'Vendor updated successfully.');
    }

    // Toggle vendor status (suspend/activate)
    public function toggleStatus(Vendor $vendor)
    {
        if ($vendor->status === 'suspended') {
            $vendor->update(['status' => 'active']);
            return redirect()->back()->with('success', 'Vendor activated successfully.');
        } else {
            $vendor->update(['status' => 'suspended']);
            return redirect()->back()->with('success', 'Vendor suspended successfully.');
        }
    }

    // Delete vendor

    public function destroy(Vendor $vendor)
    {
        // Armada: delete branch if vendor had one
        if (config('armada.enabled', false) && !empty($vendor->armada_branch_id)) {
            try {
                $armadaService = app(\App\Services\ArmadaService::class);
                $result = $armadaService->deleteBranch($vendor->armada_branch_id);
                if (!$result['success']) {
                    Log::warning('Armada delete branch failed on admin vendor delete', [
                        'vendor_id' => $vendor->id,
                        'branch_id' => $vendor->armada_branch_id,
                        'error' => $result['error'] ?? 'Unknown error',
                    ]);
                }
            } catch (\Exception $e) {
                Log::error('Armada delete branch exception on admin vendor delete', [
                    'vendor_id' => $vendor->id,
                    'error' => $e->getMessage(),
                ]);
            }
        }

        $vendor->forceDelete();
        $vendor->user()->forceDelete();
        return redirect()->back()->with('success', 'Vendor deleted successfully.');
    }

    // Approve KYC
    public function kycApprove(Vendor $vendor)
    {
        $vendor->update(['kyc_status' => 'approved', 'kyc_rejection_reason' => null]);

        // Create Armada branch for vendor if enabled and not already created
        if (!config('armada.enabled', false)) {
            Log::info('Armada branch skipped: Armada is disabled', ['vendor_id' => $vendor->id]);
        } elseif (!$vendor->use_armada_delivery) {
            Log::info('Armada branch skipped: vendor does not use Armada delivery', ['vendor_id' => $vendor->id]);
        } elseif (!empty($vendor->armada_branch_id)) {
            Log::info('Armada branch skipped: vendor already has a branch', ['vendor_id' => $vendor->id]);
        } else {
            try {
                $armadaService = app(\App\Services\ArmadaService::class);
                $result = $armadaService->createBranch($vendor);

                if ($result['success']) {
                    $vendor->update([
                        'armada_branch_id' => $result['branch_id'],
                        'armada_branch_key' => $result['branch_key'],
                    ]);
                    Log::info('Armada branch created on KYC approval', [
                        'vendor_id' => $vendor->id,
                        'branch_id' => $result['branch_id'],
                    ]);
                } else {
                    Log::warning('Armada branch creation failed on KYC approval', [
                        'vendor_id' => $vendor->id,
                        'error' => $result['error'] ?? 'Unknown error',
                    ]);
                }
            } catch (\Exception $e) {
                Log::error('Armada branch creation exception on KYC approval', [
                    'vendor_id' => $vendor->id,
                    'error' => $e->getMessage(),
                ]);
            }
        }

        return redirect()->back()->with('success', 'KYC approved.');
    }

    /**
     * Manually create Armada branch for a vendor (e.g. when they were approved before branch creation ran).
     */
    public function createArmadaBranch(Vendor $vendor)
    {
        if (!config('armada.enabled', false)) {
            return redirect()->back()->with('error', 'Armada is disabled.');
        }
        if (!$vendor->use_armada_delivery) {
            return redirect()->back()->with('error', 'Vendor does not use Armada delivery.');
        }
        if (!empty($vendor->armada_branch_id)) {
            return redirect()->back()->with('info', 'Vendor already has an Armada branch.');
        }

        try {
            $armadaService = app(\App\Services\ArmadaService::class);
            $result = $armadaService->createBranch($vendor);

            if ($result['success']) {
                $vendor->update([
                    'armada_branch_id' => $result['branch_id'],
                    'armada_branch_key' => $result['branch_key'],
                ]);
                Log::info('Armada branch created (manual)', [
                    'vendor_id' => $vendor->id,
                    'branch_id' => $result['branch_id'],
                ]);
                return redirect()->back()->with('success', 'Armada branch created successfully.');
            }

            Log::warning('Armada branch creation failed (manual)', [
                'vendor_id' => $vendor->id,
                'error' => $result['error'] ?? 'Unknown error',
            ]);
            return redirect()->back()->with('error', 'Failed to create Armada branch: ' . ($result['error'] ?? 'Unknown error'));
        } catch (\Exception $e) {
            Log::error('Armada branch creation exception (manual)', [
                'vendor_id' => $vendor->id,
                'error' => $e->getMessage(),
            ]);
            return redirect()->back()->with('error', 'Error: ' . $e->getMessage());
        }
    }

    // Reject KYC
    public function kycReject(Request $request, Vendor $vendor)
    {
        $validated = $request->validate([
            'kyc_rejection_reason_en' => 'required|string',
            'kyc_rejection_reason_ar' => 'nullable|string',
        ]);
        $vendor->update([
            'kyc_status' => 'rejected',
            'kyc_rejection_reason_en' => $validated['kyc_rejection_reason_en'],
            'kyc_rejection_reason_ar' => $validated['kyc_rejection_reason_ar'] ?? null,
        ]);
        return redirect()->back()->with('success', 'KYC rejected.');
    }

    // Assign/Change subscription
    public function assignSubscription(Request $request, Vendor $vendor)
    {
        $validated = $request->validate([
            'subscription_id' => 'required|exists:subscriptions,id',
            'start_date' => 'nullable|date',
            'end_date' => 'nullable|date|after_or_equal:start_date',
            'payment_status' => 'nullable|string',
        ]);
        $subscription = Subscription::find($validated['subscription_id']);
        
        // Use provided dates or calculate based on subscription duration
        $startDate = $validated['start_date'] ? \Carbon\Carbon::parse($validated['start_date']) : now();
        if ($validated['end_date']) {
            $endDate = \Carbon\Carbon::parse($validated['end_date']);
        } else {
            // Calculate end date based on subscription duration if not provided
        if ($subscription && $subscription->duration === 'yearly') {
            $endDate = $startDate->copy()->addYear();
        } else {
            $endDate = $startDate->copy()->addMonth();
        }
        }

        // Generate unique transaction IDs
        $transactionId = 'TXN' . strtoupper(bin2hex(random_bytes(8)));
        $paymentReferenceId = 'REF' . strtoupper(bin2hex(random_bytes(8)));

        $vendorSubscription = VendorSubscription::create([
            'subscription_id' => $subscription->id,
            'vendor_id' => $vendor->id,
            'start_date' => $startDate,
            'end_date' => $endDate,
            'status' => 'active',
            'transaction_id' => $transactionId,
            'payment_status' => $validated['payment_status'] ?? 'paid',
        ]);

        FinanceTransaction::create([    
            'transaction_id' => $transactionId,
            'user_type' => 'vendor',
            'type' => 'subscription',
            'status' => 'completed',
            'amount' => $subscription->price,
            'payment_processor' => 'myfatoorah',
            'payment_reference_id' => $paymentReferenceId,
            'transactionable_type' => VendorSubscription::class,
            'transactionable_id' => $vendorSubscription->id,
            'user_id' => $vendor->user->id,
            'vendor_id' => $vendor->id,
            'summery' => 'Vendor subscription purchase payment',
            'metadata' => $vendor->metadata ?? [],
            'attempt_status' => 'success',
            'attempted_at' => now(),
            'processed_at' => now(),
        ]);

        // Always return redirect for Inertia compatibility
        return redirect()->back()->with('success', 'Subscription updated successfully.');
    }

    // Set custom commission
    public function setCommission(Request $request, Vendor $vendor)
    {
        $validated = $request->validate([
            'commission' => 'required|numeric|min:0|max:100',
        ]);
        $vendor->update(['commission' => $validated['commission']]);
        return redirect()->back()->with('success', 'Commission updated.');
    }

    // Update vendor subscription
    public function updateSubscription(Request $request, Vendor $vendor)
    {
        dd('asd');
        $validated = $request->validate([
            'subscription_id' => 'required|exists:subscriptions,id',
            'start_date' => 'required|date',
            'end_date' => 'required|date|after_or_equal:start_date',
        ]);

        // Store a new VendorSubscription record
        $vendorSubscription = $vendor->subscriptions()->create([
            'subscription_id' => $validated['subscription_id'],
            'start_date' => $validated['start_date'],
            'end_date' => $validated['end_date'],
            'status' => 'active',
            'payment_status' => 'paid',
            // Add 'transaction_id' if you have it, otherwise remove this line
        ]);

        // Optionally update the vendor's current subscription_id
        $vendor->update(['subscription_id' => $validated['subscription_id']]);

        return response()->json([
            'success' => true,
            'message' => 'Subscription updated successfully',
            'subscription' => $vendorSubscription,
        ]);
    }

    // Get available subscriptions for vendor (only active subscriptions)
    public function getAvailableSubscriptions()
    {
        $subscriptions = Subscription::where('status', 'active')
            ->orderBy('sort_order')
            ->get();
        return response()->json($subscriptions);
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'brand_name_en' => 'nullable|string|max:255',
            'brand_name_ar' => 'nullable|string|max:255',
            'description_en' => 'nullable|string',
            'description_ar' => 'nullable|string',
            'email' => 'required|email|unique:users,email',
            'mobile' => 'nullable|string|max:20',
            'phone' => 'nullable|string|max:20',
            'status' => 'required|string|in:active,suspended',
            'commission' => 'nullable|numeric|min:0|max:100',
            'kyc_status' => 'nullable|string|in:pending,approved,rejected',
            'logo' => 'nullable|image',
            'password' => [
                'required',
                'string',
                'min:8',
                'regex:/[A-Z]/', // at least one uppercase
                'regex:/[0-9]/', // at least one number
            ],
            'password_confirmation' => 'required|same:password',
        ]);

        $disk = config('filesystems.default', 's3');
        
        // Handle logo upload if present
        if ($request->hasFile('logo')) {
            $logoPath = $request->file('logo')->store('vendor-logos', $disk);
            $validated['logo'] = $logoPath;
        }

        // Fetch default commission from settings if not provided
        if (!isset($validated['commission']) || $validated['commission'] === null || $validated['commission'] === '') {
            $defaultCommission = Setting::where('key', 'vendor_commission')->value('value');
            if ($defaultCommission !== null) {
                $validated['commission'] = $defaultCommission;
            }
        }

        // Create user
        $user = User::create([
            'full_name' => $validated['name'],
            'email' => $validated['email'],
            'password' => Hash::make($validated['password']),
            'mobile' => $validated['mobile'] ?? null,
            'phone' => $validated['phone'] ?? null,
            'email_verified_at' =>now(),
            'role' => 'vendor',
            'status' => 'active',
        ]);

        $user->assignRole('vendor');


        // Create vendor and link to user
        $vendor = Vendor::create([
            'name' => $validated['name'],
            'brand_name_en' => $validated['brand_name_en'] ?? null,
            'brand_name_ar' => $validated['brand_name_ar'] ?? null,
            'description_en' => $validated['description_en'] ?? null,
            'description_ar' => $validated['description_ar'] ?? null,
            'email' => $validated['email'],
            'mobile' => $validated['mobile'] ?? null,
            'status' => $validated['status'],
            'commission' => $validated['commission'] ?? null,
            'kyc_status' => $validated['kyc_status'] ?? 'pending',
            'logo' => $validated['logo'] ?? null,
            'user_id' => $user->id,
        ]);

        return redirect()->back()->with('success', 'Vendor created successfully.');
    }
}
