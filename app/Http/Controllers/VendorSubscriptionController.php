<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Inertia\Inertia;
use App\Models\VendorSubscription;
use App\Models\Subscription;
use Illuminate\Support\Carbon;
use App\Models\Vendor;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Str;
use App\Models\FinanceTransaction;
use MyFatoorah\Library\API\Payment\MyFatoorahPayment;

class VendorSubscriptionController extends Controller
{
    // Show current subscription and available plans
    public function show(Request $request)
    {
        // Get the currently authenticated vendor user
        $user = $request->user();
        $vendor = method_exists($user, 'vendor') ? $user->vendor : null;
        if (!$vendor) {
            return redirect()->back()->withErrors(['error' => 'Vendor profile not found.']);
        }

        // Get the vendor's current active subscription
        $activeSub = VendorSubscription::where('vendor_id', $vendor->id)
            ->where('status', 'active')
            ->orderByDesc('end_date')
            ->first();

        $currentSubscription = null;
        if ($activeSub && $activeSub->subscription) {
            $currentSubscription = [
                'id' => $activeSub->subscription->id,
                'title' => $activeSub->subscription->title_en,
                'expiry' => Carbon::parse($activeSub->end_date)->format('Y-m-d'),
                'price' => $activeSub->subscription->price,
                'duration' => $activeSub->subscription->duration,
            ];
        }

        // Get all available plans
        $plans = Subscription::where('status', 'active')->orderBy('sort_order')->get()->map(function ($plan) {
            return [
                'id' => $plan->id,
                'title' => $plan->title_en,
                'description' => $plan->description_en,
                'features' => $plan->features,
                'duration' => $plan->duration,
                'price' => $plan->price,
            ];
        });

        return Inertia::render('Subscriptions/Vendor', [
            'currentSubscription' => $currentSubscription,
            'plans' => $plans,
        ]);
    }

    // Renew subscription (placeholder)
    public function renew(Request $request)
    {
        $user = $request->user();
        $vendor = method_exists($user, 'vendor') ? $user->vendor : null;
        if (!$vendor) {
            return redirect()->back()->with('error', 'Vendor profile not found.');
        }

        // Allow renew if latest subscription is 'active' or 'expired'
        $latestSub = VendorSubscription::where('vendor_id', $vendor->id)
            ->whereIn('status', ['active', 'expired'])
            ->orderByDesc('end_date')
            ->first();
        $subscription = Subscription::find($latestSub->subscription_id);
        if (!$latestSub) {
            return redirect()->back()->with('error', 'No subscription to renew.');
        }
        $duration = $latestSub->subscription->duration ?? 'monthly';
        $add = $duration === 'yearly' ? 12 : 1;
        $now = Carbon::now();
        $currentEnd = Carbon::parse($latestSub->end_date);

        if ($currentEnd->lt($now)) {
            // Mark old as expired if not already
            if ($latestSub->status !== 'expired') {
                $latestSub->status = 'expired';
                $latestSub->save();

            }
            // Create new subscription record
            $newStart = $now;
            $newEnd = (clone $newStart)->addMonths($add);
            VendorSubscription::create([
                'vendor_id' => $vendor->id,
                'subscription_id' => $latestSub->subscription_id,
                'start_date' => $newStart,
                'end_date' => $newEnd,
                'price' => $subscription->price,
                'payment_status' => 'paid',
                'transaction_id' => Str::upper(Str::random(10)),
                'status' => 'active',
            ]);

            $transactionId = 'TXN' . strtoupper(bin2hex(random_bytes(8)));
            $referenceId = 'REF' . strtoupper(bin2hex(random_bytes(8)));

            // 2. FinanceTransaction create
            FinanceTransaction::create([
                'transaction_id' => $transactionId,
                'user_type' => 'vendor',
                'type' => 'subscription',
                'status' => 'completed',
                'amount' => $subscription->price,
                'payment_processor' => $request->payment_method,
                'payment_reference_id' => $referenceId,
                'transactionable_type' => VendorSubscription::class,
                'transactionable_id' => $latestSub->id, // TODO: check if this is correct
                'user_id' => $user->id,
                'vendor_id' => $vendor->id,
                'summery' => 'Vendor subscription renewal payment',
                'metadata' => $latestSub->metadata ?? [], // TODO: check if this is correct
                'attempt_status' => 'success',
                'attempted_at' => now(),
                'processed_at' => now(),
            ]);
        } else {
            // Still active, just extend end_date
            $latestSub->end_date = Carbon::parse($latestSub->end_date)->addMonths($add);
            $latestSub->save();

            $transactionId = 'TXN' . strtoupper(bin2hex(random_bytes(8)));
            $referenceId = 'REF' . strtoupper(bin2hex(random_bytes(8)));

            // 2. FinanceTransaction create
            FinanceTransaction::create([
                'transaction_id' => $transactionId,
                'user_type' => 'vendor',
                'type' => 'subscription',
                'status' => 'completed',
                'amount' => $subscription->price,
                'payment_processor' => $request->payment_method,
                'payment_reference_id' => $referenceId,
                'transactionable_type' => VendorSubscription::class,
                'transactionable_id' => $latestSub->id, // TODO: check if this is correct
                'user_id' => $user->id,
                'vendor_id' => $vendor->id,
                'summery' => 'Vendor subscription renewal payment',
                'metadata' => $latestSub->metadata ?? [], // TODO: check if this is correct
                'attempt_status' => 'success',
                'attempted_at' => now(),
                'processed_at' => now(),
            ]);
        }
        return redirect()->back()->with('success', 'Subscription renewed successfully.');
    }

    // Upgrade subscription (placeholder)
    public function upgrade(Request $request)
    {
        $user = $request->user();
        $vendor = method_exists($user, 'vendor') ? $user->vendor : null;

        if (!$vendor) {
            return redirect()->back()->with('error', 'Vendor profile not found.');
        }

        $planId = $request->input('plan_id');
        $newPlan = Subscription::find($planId);
        if (!$newPlan) {
            return redirect()->back()->with('error', 'Selected plan not found.');
        }
        // dd($vendor->id);
        $activeSub = VendorSubscription::where('vendor_id', $vendor->id)
            ->where('status', 'active')
            ->orderByDesc('end_date')
            ->first();
        if (!$activeSub) {
            return redirect()->back()->with('error', 'No active subscription to upgrade.');
        }

        if ($newPlan->price <= $activeSub->price) {
            return redirect()->back()->with('error', 'Can only upgrade to a higher-priced plan.');
        }

        // Prorate remaining value
        $today = Carbon::today();
        $end = Carbon::parse($activeSub->end_date);
        $remainingDays = $today->diffInDays($end, false);
        $totalDays = Carbon::parse($activeSub->start_date)->diffInDays($end);

        $unusedValue = $remainingDays > 0 ? ($activeSub->price * $remainingDays / max($totalDays, 1)) : 0;
        $amountToPay = $newPlan->price - $unusedValue;

        // End current subscription
        $activeSub->status = 'upgraded';
        $activeSub->end_date = $today;
        $activeSub->save();

        // Start new subscription
        $duration = $newPlan->duration === 'yearly' ? 12 : 1;
        $newStart = $today;
        $newEnd = (clone $newStart)->addMonths($duration);

        $newVendorSub = VendorSubscription::create([
            'vendor_id' => $vendor->id,
            'subscription_id' => $newPlan->id,
            'start_date' => $newStart,
            'end_date' => $newEnd,
            'price' => $newPlan->price,
            'prorated_amount' => $unusedValue,
            'payment_status' => 'paid',
            'transaction_id' => Str::upper(Str::random(10)),
            'status' => 'active',
        ]);

        $transactionId = 'TXN' . strtoupper(bin2hex(random_bytes(8)));
        $referenceId = 'REF' . strtoupper(bin2hex(random_bytes(8)));

        // 2. FinanceTransaction create
        FinanceTransaction::create([
            'transaction_id' => $transactionId,
            'user_type' => 'vendor',
            'type' => 'subscription',
            'status' => 'completed',
            'amount' => $newPlan->price,
            'payment_processor' => $request->payment_method,
            'payment_reference_id' => $referenceId,
            'transactionable_type' => VendorSubscription::class,
            'transactionable_id' => $newVendorSub->id, // TODO: check if this is correct
            'user_id' => $user->id,
            'vendor_id' => $vendor->id,
            'summery' => 'Vendor subscription upgrade payment',
            'metadata' => $newVendorSub->metadata ?? [], // TODO: check if this is correct
            'attempt_status' => 'success',
            'attempted_at' => now(),
            'processed_at' => now(),
        ]);

        return redirect()->back()->with('success', 'Subscription upgraded successfully. Amount to pay: ' . round($amountToPay, 2) . ', Prorated discount: ' . round($unusedValue, 2));
    }

    // Cancel subscription (placeholder)
    public function cancel(Request $request)
    {
        $user = $request->user();
        $vendor = method_exists($user, 'vendor') ? $user->vendor : null;
        if (!$vendor) {
            return redirect()->back()->with('error', 'Vendor profile not found.');
        }
        $activeSub = VendorSubscription::where('vendor_id', $vendor->id)
            ->where('status', 'active')
            ->orderByDesc('end_date')
            ->first();
        if (!$activeSub) {
            return redirect()->back()->with('error', 'No active subscription to cancel.');
        }
        $activeSub->status = 'cancelled';
        $activeSub->end_date = Carbon::today();
        $activeSub->save();
        return redirect()->back()->with('success', 'Subscription cancelled successfully.');
    }

    public function subscribe(Request $request)
    {
        $user = $request->user();
        $vendor = method_exists($user, 'vendor') ? $user->vendor : null;
        if (!$vendor) {
            return redirect()->back()->with('error', 'Vendor profile not found.');
        }

        $planId = $request->input('plan_id');
        $plan = Subscription::find($planId);
        if (!$plan) {
            return redirect()->back()->with('error', 'Selected plan not found.');
        }

        // Initiate MyFatoorah payment (see previous messages for code)
        // On payment success callback:
        // 1. Create VendorSubscription
        $duration = $plan->duration === 'yearly' ? 12 : 1;
        $start = now();
        $end = (clone $start)->addMonths($duration);

        $vendorSub = VendorSubscription::create([
            'vendor_id' => $vendor->id,
            'subscription_id' => $plan->id,
            'start_date' => $start,
            'end_date' => $end,
            'price' => $plan->price,
            'payment_status' => 'paid',
            'transaction_id' => Str::upper(Str::random(10)),
            'status' => 'active',
        ]);

        $transactionId = 'TXN' . strtoupper(bin2hex(random_bytes(8)));
        $referenceId = 'REF' . strtoupper(bin2hex(random_bytes(8)));

        // 2. FinanceTransaction create
        FinanceTransaction::create([
            'transaction_id' => $transactionId,
            'user_type' => 'vendor',
            'type' => 'subscription',
            'status' => 'completed',
            'amount' => $plan->price,
            'payment_processor' => $request->payment_method,
            'payment_reference_id' => $referenceId,
            'transactionable_type' => VendorSubscription::class,
            'transactionable_id' => $vendorSub->id, // TODO: check if this is correct
            'user_id' => $user->id,
            'vendor_id' => $vendor->id,
            'summery' => 'Vendor subscription purchase payment',
            'metadata' => $vendorSub->metadata ?? [], // TODO: check if this is correct
            'attempt_status' => 'success',
            'attempted_at' => now(),
            'processed_at' => now(),
        ]);

        // 2. Create FinanceTransaction (see previous messages for code)

        return redirect()->route('dashboard')->with('success', 'Subscription activated!');
    }

    // Mock payment endpoint for local/dev
    public function pay(Request $request)
    {
        $request->validate([
            'subscription_id' => 'required|exists:subscriptions,id',
            'payment_method' => 'required|string',
        ]);

        // MOCK: Simulate payment success
        $paymentSuccess = true;

        if ($paymentSuccess) {
            $user = $request->user();
            $vendor = method_exists($user, 'vendor') ? $user->vendor : null;
            if (!$vendor) {
                return redirect()->back()->with('error', 'Vendor profile not found.');
            }
            $plan = Subscription::find($request->subscription_id);
            $duration = $plan->duration === 'yearly' ? 12 : 1;
            $start = now();
            $end = (clone $start)->addMonths($duration);
            $randomTransactionId = Str::upper(Str::random(10));
            
            // Handle upgrade case - cancel current active subscription
            $currentActiveSubscription = VendorSubscription::where('vendor_id', $vendor->id)
                ->where('status', 'active')
                ->orderByDesc('end_date')
                ->first();
                
            if ($currentActiveSubscription) {
                $currentActiveSubscription->status = 'cancelled';
                $currentActiveSubscription->save();
                Log::info('Cancelled previous subscription for upgrade', [
                    'vendor_id' => $vendor->id,
                    'cancelled_subscription_id' => $currentActiveSubscription->id
                ]);
            }
            
            $vendorSub = VendorSubscription::create([
                'vendor_id' => $vendor->id,
                'subscription_id' => $plan->id,
                'start_date' => $start,
                'end_date' => $end,
                'price' => $plan->price,
                'payment_status' => 'paid',
                'transaction_id' => $randomTransactionId,
                'status' => 'active',
                'type' => 'subscription upgrade',
            ]);

            $transactionId = 'TXN' . strtoupper(bin2hex(random_bytes(8)));
            $referenceId = 'REF' . strtoupper(bin2hex(random_bytes(8)));

            // 2. FinanceTransaction create
            FinanceTransaction::create([
                'transaction_id' => $transactionId,
                'user_type' => 'vendor',
                'type' => 'subscription upgrade',
                'status' => 'completed',
                'amount' => $plan->price,
                'payment_processor' => $request->payment_method,
                'payment_reference_id' => $referenceId,
                'transactionable_type' => VendorSubscription::class,
                'transactionable_id' => $vendorSub->id,
                'user_id' => $user->id,
                'vendor_id' => $vendor->id,
                'summery' => 'Vendor subscription upgrade payment',
                'metadata' => $vendorSub->metadata ?? [],
                'attempt_status' => 'success',
                'attempted_at' => now(),
                'processed_at' => now(),
            ]);
            return redirect()->route('vendor.subscription')->with('success', 'Subscription upgraded successfully!');
        } else {
            return redirect()->back()->with('error', 'Payment failed');
        }
    }

    /**
     * Activate free subscription directly without payment processing
     */
    private function activateFreeSubscription($vendor, $plan, $type, $price)
    {
        try {
            $user = $vendor->user;
            
            // Handle upgrade case - cancel current active subscription
            if ($type === 'upgrade' || $type === 'subscription upgrade') {
                $currentActiveSubscription = VendorSubscription::where('vendor_id', $vendor->id)
                    ->where('status', 'active')
                    ->orderByDesc('end_date')
                    ->first();
                    
                if ($currentActiveSubscription) {
                    $currentActiveSubscription->status = 'cancelled';
                    $currentActiveSubscription->save();
                    Log::info('Cancelled previous subscription for free upgrade', [
                        'vendor_id' => $vendor->id,
                        'cancelled_subscription_id' => $currentActiveSubscription->id
                    ]);
                }
            }
            
            // Calculate duration
            $duration = $plan->duration === 'yearly' ? 12 : 1;
            $startDate = now();
            $endDate = (clone $startDate)->addMonths($duration);
            
            // Handle renew case - extend from current subscription end date
            if ($type === 'renew' || $type === 'subscription renew') {
                $latestSubscription = VendorSubscription::where('vendor_id', $vendor->id)
                    ->where('subscription_id', $plan->id)
                    ->where('status', 'active')
                    ->orderByDesc('end_date')
                    ->first();
                    
                if ($latestSubscription && Carbon::parse($latestSubscription->end_date)->gt(now())) {
                    $startDate = Carbon::parse($latestSubscription->end_date);
                    if ($duration === 12) {
                        $endDate = Carbon::parse($latestSubscription->end_date)->copy()->addYear();
                    } else {
                        $endDate = Carbon::parse($latestSubscription->end_date)->copy()->addMonth();
                    }
                }
            }
            
            // Determine subscription type
            $subscriptionType = $type === 'first' ? 'subscription' : ($type === 'upgrade' ? 'subscription upgrade' : 'subscription renew');
            
            // Create VendorSubscription - use direct assignment to bypass fillable restrictions
            $vendorSubscription = new VendorSubscription();
            $vendorSubscription->vendor_id = $vendor->id;
            $vendorSubscription->subscription_id = $plan->id;
            $vendorSubscription->start_date = $startDate;
            $vendorSubscription->end_date = $endDate;
            $vendorSubscription->status = 'active';
            $vendorSubscription->payment_status = 'paid';
            $vendorSubscription->transaction_id = 'FREE-' . Str::upper(Str::random(10));
            
            // Set price and type using setAttribute (bypasses fillable)
            $vendorSubscription->setAttribute('price', $price);
            $vendorSubscription->setAttribute('type', $subscriptionType);
            
            $vendorSubscription->save();
            
            Log::info('Free VendorSubscription created successfully', [
                'vendor_subscription_id' => $vendorSubscription->id,
                'vendor_id' => $vendor->id,
                'subscription_id' => $plan->id,
                'type' => $type
            ]);
            
            // Create FinanceTransaction for free subscription
            $transactionId = 'TXN' . strtoupper(bin2hex(random_bytes(8)));
            $referenceId = 'REF' . strtoupper(bin2hex(random_bytes(8)));
            
            FinanceTransaction::create([
                'transaction_id' => $transactionId,
                'user_type' => 'vendor',
                'type' => $subscriptionType,
                'status' => 'completed',
                'amount' => $price,
                'payment_processor' => 'free',
                'payment_reference_id' => $referenceId,
                'transactionable_type' => VendorSubscription::class,
                'transactionable_id' => $vendorSubscription->id,
                'user_id' => $user->id,
                'vendor_id' => $vendor->id,
                'summery' => 'Free ' . $subscriptionType . ' activation',
                'metadata' => ['free_subscription' => true],
                'attempt_status' => 'success',
                'attempted_at' => now(),
                'processed_at' => now(),
            ]);
            
            Log::info('Free FinanceTransaction created successfully', [
                'finance_transaction_id' => $transactionId,
                'vendor_id' => $vendor->id,
                'amount' => $price
            ]);
            
            return response()->json([
                'success' => true,
                'message' => 'Free subscription activated successfully!',
                'free' => true,
            ]);
        } catch (\Exception $e) {
            Log::error('Failed to activate free subscription', [
                'vendor_id' => $vendor->id,
                'subscription_id' => $plan->id,
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString(),
            ]);
            
            return response()->json([
                'success' => false,
                'message' => 'Failed to activate free subscription. Please try again.',
            ], 500);
        }
    }

    public function payWithMyFatoorah(Request $request)
    {
        $user = $request->user();
        $vendor = method_exists($user, 'vendor') ? $user->vendor : null;
        if (!$vendor) {
            return response()->json([
                'success' => false,
                'message' => 'Vendor profile not found.',
            ], 400);
        }

        $planId = $request->input('subscription_id');
        $plan = Subscription::find($planId);
        if (!$plan) {
            return response()->json([
                'success' => false,
                'message' => 'Selected plan not found.',
            ], 404);
        }
        
        // Use price from request for all cases (first, upgrade, renew)
        $price = $request->input('price', $plan->price);
        $type = $request->input('type', 'first'); // 'first', 'upgrade', 'renew'
        
        // Convert price to float for comparison
        $priceFloat = (float) $price;
        
        // Check if subscription is free (price is 0 or less than 0.01)
        if ($priceFloat <= 0 || $priceFloat < 0.01) {
            // Handle free subscription - directly activate without payment
            Log::info('Free subscription detected', [
                'vendor_id' => $vendor->id,
                'subscription_id' => $plan->id,
                'price' => $price,
                'price_float' => $priceFloat,
                'type' => $type
            ]);
            return $this->activateFreeSubscription($vendor, $plan, $type, $priceFloat);
        }
        
        // Always require real payment - no simulation mode
        
        $callbackUrl = route('vendor.subscribe.callback');
        $errorUrl = route('vendor.subscribe.error');
        
        Log::info('MyFatoorah Payment URLs', [
            'callback_url' => $callbackUrl,
            'error_url' => $errorUrl
        ]);

        $data = [
            'CustomerName' => $user->full_name ?? 'Customer',
            'NotificationOption' => 'Lnk',
            'InvoiceValue' => (float) $price,
            'DisplayCurrencyIso' => 'KWD',
            'MobileCountryCode' => '+965',
            'CustomerMobile' => $user->phone ?? $user->mobile ?? '12345678',
            'CustomerEmail' => $user->email,
            'CallBackUrl' => $callbackUrl,
            'ErrorUrl' => $errorUrl,
            'Language' => 'en',
            // Encode vendor_id and subscription_id in CustomerReference as JSON
            'CustomerReference' => json_encode([
                'vendor_id' => $vendor->id,
                'subscription_id' => $plan->id,
            ]),
            'UserDefinedField' => $type,
        ];
        try {
            Log::info('Initiating MyFatoorah Payment', [
                'vendor_id' => $vendor->id,
                'subscription_id' => $plan->id,
                'price' => $price,
                'type' => $type,
                'callback_url' => $callbackUrl,
                'error_url' => $errorUrl
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
            Log::info('MyFatoorah Config', [
                'api_key_length' => strlen($mfConfig['apiKey']),
                'api_key_preview' => substr($mfConfig['apiKey'], 0, 20) . '...',
                'is_test' => $mfConfig['isTest'],
                'mode' => $mfConfig['isTest'] ? 'TEST' : 'LIVE',
                'country_code' => $mfConfig['countryCode'],
            ]);
            
            try {
                $mfPayment = new MyFatoorahPayment($mfConfig);
                
                // Log the API URL that will be used
                $apiUrl = $mfPayment->getApiURL();
                $fullApiUrl = $apiUrl . '/v2/SendPayment';
                
                Log::info('MyFatoorah API URL', [
                    'base_url' => $apiUrl,
                    'full_url' => $fullApiUrl,
                ]);
                
                // First, test the API key with a direct HTTP call to get actual error
                try {
                    $testResponse = Http::withHeaders([
                        'Authorization' => 'Bearer ' . $mfConfig['apiKey'],
                        'Content-Type' => 'application/json',
                    ])
                        ->timeout(15)
                        ->post($fullApiUrl, $data);
                    
                    $httpStatus = $testResponse->status();
                    $responseBody = $testResponse->body();
                    $responseJson = $testResponse->json();
                    
                    Log::info('MyFatoorah Direct HTTP Test', [
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
                        Log::error('MyFatoorah API Error', [
                            'http_status' => $httpStatus,
                            'response' => $responseJson,
                            'response_body' => $responseBody,
                            'api_url' => $fullApiUrl,
                            'test_mode' => $mfConfig['isTest'],
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
                    Log::warning('MyFatoorah Direct HTTP Test Failed', [
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
                'message' => $e->getMessage() ?: 'Payment initiation failed due to server error!',
            ], 500);
        }
    }

    public function myFatoorahCallback(Request $request)
    {
        $paymentId = $request->paymentId;
        
        Log::info('MyFatoorah Callback Received', [
            'payment_id' => $paymentId,
            'request_data' => $request->all()
        ]);
        
        try {
            $apiKey = config('myfatoorah.api_key');
            $testMode = config('myfatoorah.test_mode');
            // API URL based on test/live mode
            $baseUrl = $testMode
                ? 'https://apitest.myfatoorah.com/'
                : 'https://api.myfatoorah.com/';
                
            $httpResponse = Http::withHeaders([
                'Authorization' => 'Bearer ' . $apiKey,
                'Content-Type' => 'application/json',
            ])
                ->timeout(15)
                ->post($baseUrl . 'v2/GetPaymentStatus', [
                    'Key' => $paymentId,
                    'KeyType' => 'PaymentId'
                ]);
            
            $httpStatus = $httpResponse->status();
            $responseBody = $httpResponse->body();
            $response = $httpResponse->json();
                
            Log::info('MyFatoorah Payment Status Response', [
                'payment_id' => $paymentId,
                'http_status' => $httpStatus,
                'response' => $response,
                'response_body' => $responseBody,
                'base_url' => $baseUrl
            ]);
            
            // Check HTTP status first
            if ($httpStatus !== 200) {
                Log::error('MyFatoorah API returned non-200 status', [
                    'payment_id' => $paymentId,
                    'http_status' => $httpStatus,
                    'response_body' => $responseBody,
                    'base_url' => $baseUrl
                ]);
                return redirect()->route('vendor.subscription')->with('error', 'Payment verification failed. HTTP Status: ' . $httpStatus);
            }
            
            // Check if response is valid JSON and has required data
            if (!$response || !is_array($response)) {
                Log::error('Invalid MyFatoorah response - not valid JSON or null', [
                    'payment_id' => $paymentId,
                    'http_status' => $httpStatus,
                    'response_body' => $responseBody,
                    'response' => $response,
                    'base_url' => $baseUrl
                ]);
                return redirect()->route('vendor.subscription')->with('error', 'Invalid payment response. Please contact support.');
            }
            
            // Check if response has Data field
            if (!isset($response['Data'])) {
                Log::error('Invalid MyFatoorah response - missing Data field', [
                    'payment_id' => $paymentId,
                    'http_status' => $httpStatus,
                    'response' => $response,
                    'response_body' => $responseBody
                ]);
                return redirect()->route('vendor.subscription')->with('error', 'Invalid payment response structure. Please contact support.');
            }
        } catch (\Exception $e) {
            Log::error('MyFatoorah API call failed', [
                'payment_id' => $paymentId,
                'error' => $e->getMessage()
            ]);
            return redirect()->route('vendor.subscription')->with('error', 'Payment verification failed. Please contact support.');
        }
        // Decode CustomerReference to extract vendor_id and subscription_id
        $customerReference = $response['Data']['CustomerReference'] ?? null;
        $decodedReference = is_string($customerReference) ? json_decode($customerReference, true) : [];
        $subscriptionId = $decodedReference['subscription_id'] ?? null;

        // subscription_id is NOT in $request, get it from MyFatoorah response
        $subscription = Subscription::find($subscriptionId);

        if (!$subscription) {
            return redirect()->route('dashboard')->with('error', 'Subscription information missing. Please contact support.');
        }

        // Determine type for VendorSubscription
        $type = null;
        if (($response['Data']['UserDefinedField'] ?? null) === 'upgrade') {
            $type = 'subscription upgrade';
        } elseif (($response['Data']['UserDefinedField'] ?? null) === 'renew') {
            $type = 'subscription renew';
        } else {
            $type = 'subscription';
        }

        // Get duration from the subscription plan
        $duration = $subscription->duration ?? 'monthly'; // fallback to monthly if not set
        // Calculate start_date and end_date based on duration
        $startDate = now();
        $endDate = null;
        if ($duration === 'yearly') {
            $endDate = now()->addYear();
        } else { // monthly or default
            $endDate = now()->addMonth();
        }
        if ($type === 'subscription renew') {
            // Find latest active subscription for this vendor
            $latestSubscription = VendorSubscription::where('vendor_id', $decodedReference['vendor_id'])
                ->where('subscription_id', $subscription->id)
                ->where('status', 'active')
                ->orderByDesc('end_date')
                ->first();
            if ($latestSubscription && Carbon::parse($latestSubscription->end_date)->gt(now())) {
                $startDate = Carbon::parse($latestSubscription->end_date);
                if ($duration === 'yearly') {
                    $endDate = Carbon::parse($latestSubscription->end_date)->copy()->addYear();
                } else {
                    $endDate = Carbon::parse($latestSubscription->end_date)->copy()->addMonth();
                }
            }
        }

        if ($response['IsSuccess'] && $response['Data']['InvoiceStatus'] == 'Paid') {
            // Get vendor_id from the decoded reference
            $vendorId = $decodedReference['vendor_id'] ?? null;
            if (!$vendorId) {
                Log::error('Vendor ID not found in MyFatoorah callback', [
                    'customer_reference' => $customerReference,
                    'decoded_reference' => $decodedReference,
                    'response_data' => $response['Data'] ?? []
                ]);
                return redirect()->route('dashboard')->with('error', 'Vendor information missing. Please contact support.');
            }
            
            $vendor = \App\Models\Vendor::find($vendorId);
            if (!$vendor) {
                Log::error('Vendor not found in database', ['vendor_id' => $vendorId]);
                return redirect()->route('dashboard')->with('error', 'Vendor not found. Please contact support.');
            }
            
            $user = $vendor->user;

            // Handle upgrade case - cancel current active subscription
            if ($type === 'subscription upgrade') {
                $currentActiveSubscription = VendorSubscription::where('vendor_id', $vendor->id)
                    ->where('status', 'active')
                    ->orderByDesc('end_date')
                    ->first();
                    
                if ($currentActiveSubscription) {
                    $currentActiveSubscription->status = 'cancelled';
                    $currentActiveSubscription->save();
                    Log::info('Cancelled previous subscription for upgrade', [
                        'vendor_id' => $vendor->id,
                        'cancelled_subscription_id' => $currentActiveSubscription->id
                    ]);
                }
            }

            // 1. VendorSubscription create
            $vendorSubscription = VendorSubscription::create([
                'vendor_id' => $vendor->id,
                'subscription_id' => $subscription->id,
                'start_date' => $startDate,
                'end_date' => $endDate, // calculated above
                'price' => $response['Data']['InvoiceValue'], // Store actual paid amount
                'status' => 'active',
                'payment_status' => $response['Data']['InvoiceStatus'],
                'transaction_id' => $paymentId,
                'type' => $type,
            ]);
            
            Log::info('VendorSubscription created successfully', [
                'vendor_subscription_id' => $vendorSubscription->id,
                'vendor_id' => $vendor->id,
                'subscription_id' => $subscription->id,
                'type' => $type
            ]);

            // Extract payment details from MyFatoorah response
            $transactionData = $response['Data']['InvoiceTransactions'][0] ?? [];
            $paymentGateway = $transactionData['PaymentGateway'] ?? null;
            $referenceId = $transactionData['ReferenceId'] ?? null;
            $transactionId = $transactionData['TransactionId'] ?? null;
            $trackId = $transactionData['TrackId'] ?? null;
            $authId = $transactionData['AuthorizationId'] ?? null;
            $transactionStatus = $transactionData['TransactionStatus'] ?? null;
            $paidCurrency = $transactionData['PaidCurrency'] ?? null;
            $paidCurrencyValue = $transactionData['PaidCurrencyValue'] ?? null;

            // 2. FinanceTransaction create
            $financeTransaction = FinanceTransaction::create([
                'transaction_id' => 'TXN' . $transactionId,
                'user_type' => 'vendor',
                'type' => $type,
                'status' => $transactionStatus === 'Succss' ? 'completed' : 'failed',
                'amount' => $response['Data']['InvoiceValue'], // Store actual paid amount
                'payment_processor' => $paymentGateway,
                'payment_reference_id' => 'REF' . $referenceId,
                'transactionable_type' => VendorSubscription::class,
                'transactionable_id' => $vendorSubscription->id,
                'user_id' => $user->id,
                'vendor_id' => $vendor->id,
                'summery' => $type . ' purchase payment',
                'metadata' => $response['Data'] ?? [],
                'attempt_status' => $transactionStatus,
                'attempted_at' => $transactionData['TransactionDate'] ?? now(),
                'processed_at' => now(),
                'gateway_track_id' => $trackId,
                'gateway_auth_id' => $authId,
                'paid_currency' => $paidCurrency,
                'paid_currency_value' => $paidCurrencyValue,
            ]);

            Log::info('FinanceTransaction created successfully', [
                'finance_transaction_id' => $financeTransaction->id,
                'vendor_id' => $vendor->id,
                'amount' => $response['Data']['InvoiceValue']
            ]);

            return redirect()->route('vendor.subscription', ['reload' => '1'])->with('success', 'Subscription activated successfully!');
        } else {
            Log::error('Payment not successful in callback', [
                'payment_id' => $paymentId,
                'response' => $response
            ]);
            return redirect()->route('vendor.subscription', ['reload' => '1'])->with('error', 'Payment failed or not completed.');
        }
    }

    public function myFatoorahError(Request $request)
    {
        Log::error('MyFatoorah Error Callback', [
            'request_data' => $request->all(),
            'headers' => $request->headers->all()
        ]);
        
        // Try to get payment status even from error callback
        $paymentId = $request->paymentId ?? $request->Id;
        if ($paymentId) {
            try {
                $apiKey = config('myfatoorah.api_key');
                $testMode = config('myfatoorah.test_mode');
                // API URL based on test/live mode
                $baseUrl = $testMode
                    ? 'https://apitest.myfatoorah.com/'
                    : 'https://api.myfatoorah.com/';
                
                Log::info('Checking Payment Status in Error Callback', [
                    'payment_id' => $paymentId,
                    'base_url' => $baseUrl,
                    'test_mode' => $testMode,
                ]);
                    
                $httpResponse = Http::withHeaders([
                    'Authorization' => 'Bearer ' . $apiKey,
                    'Content-Type' => 'application/json',
                ])
                    ->timeout(15)
                    ->post($baseUrl . 'v2/GetPaymentStatus', [
                        'Key' => $paymentId,
                        'KeyType' => 'PaymentId'
                    ]);
                
                $httpStatus = $httpResponse->status();
                $responseBody = $httpResponse->body();
                $response = $httpResponse->json();
                    
                Log::info('Payment Status from Error Callback', [
                    'payment_id' => $paymentId,
                    'http_status' => $httpStatus,
                    'response' => $response,
                    'response_body' => $responseBody,
                ]);
                
                // Check if response is valid
                if (!$response || !is_array($response)) {
                    Log::error('Invalid response from GetPaymentStatus', [
                        'payment_id' => $paymentId,
                        'http_status' => $httpStatus,
                        'response_body' => $responseBody,
                    ]);
                } elseif (isset($response['IsSuccess']) && $response['IsSuccess'] && 
                    isset($response['Data']['InvoiceStatus']) && $response['Data']['InvoiceStatus'] == 'Paid') {
                    Log::info('Payment was actually successful, processing...');
                    return $this->processSuccessfulPayment($response, $paymentId);
                } else {
                    // Extract transaction error details
                    $invoiceTransactions = $response['Data']['InvoiceTransactions'] ?? [];
                    $firstTransaction = !empty($invoiceTransactions) && isset($invoiceTransactions[0]) && is_array($invoiceTransactions[0]) ? $invoiceTransactions[0] : [];
                    $transactionStatus = $firstTransaction['TransactionStatus'] ?? null;
                    $errorMessage = $firstTransaction['Error'] ?? null;
                    $errorCode = $firstTransaction['ErrorCode'] ?? null;
                    $invoiceStatus = $response['Data']['InvoiceStatus'] ?? null;
                    
                    Log::info('Payment status check result', [
                        'is_success' => $response['IsSuccess'] ?? false,
                        'invoice_status' => $invoiceStatus,
                        'transaction_status' => $transactionStatus,
                        'error' => $errorMessage,
                        'error_code' => $errorCode,
                        'message' => $response['Message'] ?? null,
                    ]);
                    
                    // Build user-friendly error message
                    $userErrorMessage = 'Payment was cancelled or failed.';
                    if ($errorMessage) {
                        if ($errorCode === 'MF001' || $errorMessage === 'AUTHENTICATION_UNSUCCESSFUL') {
                            $userErrorMessage = 'Payment authentication failed. Please check your card details and try again.';
                        } elseif ($errorMessage) {
                            $userErrorMessage = 'Payment failed: ' . $errorMessage;
                        }
                    } elseif ($transactionStatus === 'Failed') {
                        $userErrorMessage = 'Payment transaction failed. Please try again with a different payment method.';
                    } elseif ($invoiceStatus === 'Pending') {
                        $userErrorMessage = 'Payment is still pending. Please complete the payment or try again.';
                    }
                    
                    return redirect()->route('vendor.subscription')->with('error', $userErrorMessage);
                }
            } catch (\Exception $e) {
                Log::error('Failed to check payment status from error callback', [
                    'error' => $e->getMessage(),
                    'file' => $e->getFile(),
                    'line' => $e->getLine(),
                    'payment_id' => $paymentId
                ]);
            }
        }
        
        return redirect()->route('vendor.subscription')->with('error', 'Payment was cancelled or failed.');
    }
    
    // Process successful payment (extracted from callback)
    private function processSuccessfulPayment($response, $paymentId)
    {
        // Decode CustomerReference to extract vendor_id and subscription_id
        $customerReference = $response['Data']['CustomerReference'] ?? null;
        $decodedReference = is_string($customerReference) ? json_decode($customerReference, true) : [];
        $subscriptionId = $decodedReference['subscription_id'] ?? null;

        $subscription = Subscription::find($subscriptionId);
        if (!$subscription) {
            Log::error('Subscription not found in successful payment', ['subscription_id' => $subscriptionId]);
            return redirect()->route('vendor.subscription')->with('error', 'Subscription information missing.');
        }

        // Determine type for VendorSubscription
        $type = null;
        if (($response['Data']['UserDefinedField'] ?? null) === 'upgrade') {
            $type = 'subscription upgrade';
        } elseif (($response['Data']['UserDefinedField'] ?? null) === 'renew') {
            $type = 'subscription renew';
        } else {
            $type = 'subscription';
        }

        // Get duration from the subscription plan
        $duration = $subscription->duration ?? 'monthly';
        $startDate = now();
        $endDate = null;
        if ($duration === 'yearly') {
            $endDate = now()->addYear();
        } else {
            $endDate = now()->addMonth();
        }

        // Get vendor_id from the decoded reference
        $vendorId = $decodedReference['vendor_id'] ?? null;
        if (!$vendorId) {
            Log::error('Vendor ID not found in successful payment', ['decoded_reference' => $decodedReference]);
            return redirect()->route('vendor.subscription')->with('error', 'Vendor information missing.');
        }
        
        $vendor = \App\Models\Vendor::find($vendorId);
        if (!$vendor) {
            Log::error('Vendor not found in successful payment', ['vendor_id' => $vendorId]);
            return redirect()->route('vendor.subscription')->with('error', 'Vendor not found.');
        }

        // Handle upgrade case - cancel current active subscription
        if ($type === 'subscription upgrade') {
            $currentActiveSubscription = VendorSubscription::where('vendor_id', $vendor->id)
                ->where('status', 'active')
                ->orderByDesc('end_date')
                ->first();
                
            if ($currentActiveSubscription) {
                $currentActiveSubscription->status = 'cancelled';
                $currentActiveSubscription->save();
                Log::info('Cancelled previous subscription for upgrade', [
                    'vendor_id' => $vendor->id,
                    'cancelled_subscription_id' => $currentActiveSubscription->id
                ]);
            }
        }

        // Create VendorSubscription
        $vendorSubscription = VendorSubscription::create([
            'vendor_id' => $vendor->id,
            'subscription_id' => $subscription->id,
            'start_date' => $startDate,
            'end_date' => $endDate,
            'price' => $response['Data']['InvoiceValue'],
            'status' => 'active',
            'payment_status' => $response['Data']['InvoiceStatus'],
            'transaction_id' => $paymentId,
            'type' => $type,
        ]);

        // Create FinanceTransaction
        $transactionData = $response['Data']['InvoiceTransactions'][0] ?? [];
        $paymentGateway = $transactionData['PaymentGateway'] ?? null;
        $referenceId = $transactionData['ReferenceId'] ?? null;
        $transactionId = $transactionData['TransactionId'] ?? null;
        $trackId = $transactionData['TrackId'] ?? null;
        $authId = $transactionData['AuthorizationId'] ?? null;
        $transactionStatus = $transactionData['TransactionStatus'] ?? null;
        $paidCurrency = $transactionData['PaidCurrency'] ?? null;
        $paidCurrencyValue = $transactionData['PaidCurrencyValue'] ?? null;

        FinanceTransaction::create([
            'transaction_id' => 'TXN' . $transactionId,
            'user_type' => 'vendor',
            'type' => $type,
            'status' => $transactionStatus === 'Succss' ? 'completed' : 'failed',
            'amount' => $response['Data']['InvoiceValue'],
            'payment_processor' => $paymentGateway,
            'payment_reference_id' => 'REF' . $referenceId,
            'transactionable_type' => VendorSubscription::class,
            'transactionable_id' => $vendorSubscription->id,
            'user_id' => $vendor->user->id,
            'vendor_id' => $vendor->id,
            'summery' => $type . ' purchase payment',
            'metadata' => $response['Data'] ?? [],
            'attempt_status' => $transactionStatus,
            'attempted_at' => $transactionData['TransactionDate'] ?? now(),
            'processed_at' => now(),
            'gateway_track_id' => $trackId,
            'gateway_auth_id' => $authId,
            'paid_currency' => $paidCurrency,
            'paid_currency_value' => $paidCurrencyValue,
        ]);

        Log::info('Successfully processed payment from error callback', [
            'vendor_subscription_id' => $vendorSubscription->id,
            'vendor_id' => $vendor->id,
            'subscription_id' => $subscription->id
        ]);

        return redirect()->route('vendor.subscription')->with('success', 'Payment successful! Subscription activated.');
    }
    
    
    // Test method to check MyFatoorah configuration
    public function testMyFatoorah()
    {
        try {
            $apiKey = config('myfatoorah.api_key');
            $testMode = config('myfatoorah.test_mode');
            // API URL based on test/live mode
            $baseUrl = $testMode
                ? 'https://apitest.myfatoorah.com/'
                : 'https://api.myfatoorah.com/';
                
            $response = Http::withHeaders([
                'Authorization' => 'Bearer ' . $apiKey,
                'Content-Type' => 'application/json',
            ])
                ->post($baseUrl . 'SendPayment', [
                    'CustomerName' => 'Test Customer',
                    'NotificationOption' => 'Lnk',
                    'InvoiceValue' => 1.0,
                    'DisplayCurrencyIso' => 'KWD',
                    'MobileCountryCode' => '+965',
                    'CustomerMobile' => '12345678',
                    'CustomerEmail' => 'test@example.com',
                    'CallBackUrl' => route('vendor.subscribe.callback'),
                    'ErrorUrl' => route('vendor.subscribe.error'),
                    'Language' => 'en',
                    'CustomerReference' => json_encode(['test' => true]),
                    'UserDefinedField' => 'test',
                ])
                ->json();
                
            return response()->json([
                'success' => true,
                'config' => [
                    'api_key' => $apiKey ? 'Set' : 'Not Set',
                    'base_url' => $baseUrl,
                    'mode' => $testMode ? 'TEST' : 'LIVE',
                ],
                'response' => $response
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'error' => $e->getMessage(),
                'config' => [
                    'api_key' => config('myfatoorah.api_key') ? 'Set' : 'Not Set',
                    'base_url' => config('myfatoorah.test_mode') ? 'https://apitest.myfatoorah.com/' : 'https://api.myfatoorah.com/',
                    'mode' => config('myfatoorah.test_mode') ? 'TEST' : 'LIVE',
                ]
            ]);
        }
    }
        
    // Debug callback method (no auth required)
    public function debugCallback(Request $request)
    {
        Log::info('Debug Callback Received', [
            'request_data' => $request->all(),
            'headers' => $request->headers->all()
        ]);
        
        return response()->json([
            'success' => true,
            'message' => 'Debug callback received',
            'data' => $request->all()
        ]);
    }
}
