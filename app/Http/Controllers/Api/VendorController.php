<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Api\Controller;
use App\Models\Vendor;
use App\Models\User;
use App\Models\Subscription;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Log;

class VendorController extends Controller
{
    /**
     * Admin: List all vendors
     */
    public function index(Request $request)
    {
        $vendors = Vendor::with(['user', 'subscription'])
            ->where('deleted_at', null)
            ->when($request->search, function ($query, $search) {
                $query->where('company_name', 'like', "%{$search}%")
                      ->orWhereHas('user', function ($q) use ($search) {
                          $q->where('name', 'like', "%{$search}%")
                            ->orWhere('email', 'like', "%{$search}%");
                      });
            })
            ->when($request->kyc_status, function ($query, $status) {
                $query->where('kyc_status', $status);
            })
            ->when($request->subscription_status, function ($query, $status) {
                $query->whereHas('subscription', function ($q) use ($status) {
                    $q->where('status', $status);
                });
            })
            ->latest()
            ->paginate(10);

        return $this->successResponse($vendors);
    }

    /**
     * Admin: Show vendor details
     */
    public function show($id)
    {
        $vendor = Vendor::with(['user', 'subscription', 'expoParticipations'])
            ->findOrFail($id);

        return $this->successResponse($vendor);
    }

    /**
     * Public: Get vendor details for API
     */
    public function details($vendorId)
    {
        $vendor = Vendor::with(['user', 'subscription', 'expoParticipations'])
            ->where('id', $vendorId)
            ->where('deleted_at', null)
            ->first();

        if (!$vendor) {
            return $this->errorResponse('Vendor not found', 404);
        }

        // Return only public information
        $vendorData = [
            'id' => $vendor->id,
            'company_name' => $vendor->company_name,
            'name' => $vendor->name,
            'email' => $vendor->email,
            'phone' => $vendor->phone,
            'address' => $vendor->address,
            'description' => $vendor->description,
            'description_ar' => $vendor->description_ar,
            'logo' => $vendor->logo ? asset('storage/' . $vendor->logo) : null,
            'website' => $vendor->website,
            'social_media' => $vendor->social_media,
            'status' => $vendor->status,
            'created_at' => $vendor->created_at,
            'user' => [
                'id' => $vendor->user->id,
                'name' => $vendor->user->name,
                'email' => $vendor->user->email,
            ],
            'subscription' => $vendor->subscription ? [
                'id' => $vendor->subscription->id,
                'name' => $vendor->subscription->name,
                'status' => $vendor->subscription->status,
            ] : null,
            'expo_participations' => $vendor->expoParticipations->map(function ($expo) {
                return [
                    'id' => $expo->pivot->id ?? $expo->id,
                    'expo' => [
                        'id' => $expo->id,
                        'name_en' => $expo->name_en,
                        'name_ar' => $expo->name_ar,
                        'start_date' => $expo->start_date,
                        'end_date' => $expo->end_date,
                    ],
                    'slot' => $expo->pivot->slot ?? 0,
                    'joined_at' => $expo->pivot->joined_at ?? $expo->created_at,
                ];
            }),
        ];

        return $this->successResponse([
            "id" => $vendor->id,
            "vendor" => $vendorData,
        ]);
    }

    /**
     * Admin: Update vendor
     */
    public function update(Request $request, $id)
    {
        $vendor = Vendor::findOrFail($id);

        $validator = Validator::make($request->all(), [
            'company_name' => 'required|string|max:255',
            'phone' => 'required|string|max:20',
            'address' => 'required|string',
            'kyc_status' => 'required|in:pending,approved,rejected',
            'commission_rate' => 'nullable|numeric|min:0|max:100',
        ]);

        if ($validator->fails()) {
            return $this->validationErrorResponse($validator->errors());
        }

        $vendor->update($validator->validated());

        return $this->successResponse($vendor->load(['user', 'subscription']), 'Vendor updated successfully');
    }

    /**
     * Admin: Delete vendor
     */
    public function destroy($id)
    {
        $vendor = Vendor::findOrFail($id);

        // Armada: delete branch if vendor had one
        if (config('armada.enabled', false) && !empty($vendor->armada_branch_id)) {
            try {
                $armadaService = app(\App\Services\ArmadaService::class);
                $result = $armadaService->deleteBranch($vendor->armada_branch_id);
                if (!$result['success']) {
                    Log::warning('Armada delete branch failed on admin vendor delete (API)', [
                        'vendor_id' => $vendor->id,
                        'branch_id' => $vendor->armada_branch_id,
                        'error' => $result['error'] ?? 'Unknown error',
                    ]);
                }
            } catch (\Exception $e) {
                Log::error('Armada delete branch exception on admin vendor delete (API)', [
                    'vendor_id' => $vendor->id,
                    'error' => $e->getMessage(),
                ]);
            }
        }

        $vendor->delete();

        return $this->successResponse(null, 'Vendor deleted successfully');
    }

    /**
     * Admin: Suspend vendor
     */
    public function suspend($id)
    {
        $vendor = Vendor::findOrFail($id);
        $vendor->update(['status' => 'suspended']);

        return $this->successResponse(null, 'Vendor suspended successfully');
    }

    /**
     * Admin: Approve KYC
     */
    public function kycApprove($id)
    {
        $vendor = Vendor::findOrFail($id);
        $vendor->update(['kyc_status' => 'approved']);

        // Create Armada branch for vendor if enabled and not already created
        if (!config('armada.enabled', false)) {
            \Log::info('Armada branch skipped: Armada is disabled', ['vendor_id' => $vendor->id]);
        } elseif (!$vendor->use_armada_delivery) {
            \Log::info('Armada branch skipped: vendor does not use Armada delivery', ['vendor_id' => $vendor->id]);
        } elseif (!empty($vendor->armada_branch_id)) {
            \Log::info('Armada branch skipped: vendor already has a branch', ['vendor_id' => $vendor->id]);
        } else {
            try {
                $armadaService = app(\App\Services\ArmadaService::class);
                $result = $armadaService->createBranch($vendor);

                if ($result['success']) {
                    $vendor->update([
                        'armada_branch_id' => $result['branch_id'],
                        'armada_branch_key' => $result['branch_key'],
                    ]);
                    \Log::info('Armada branch created on KYC approval (API)', [
                        'vendor_id' => $vendor->id,
                        'branch_id' => $result['branch_id'],
                    ]);
                } else {
                    \Log::warning('Armada branch creation failed on KYC approval (API)', [
                        'vendor_id' => $vendor->id,
                        'error' => $result['error'] ?? 'Unknown error',
                    ]);
                }
            } catch (\Exception $e) {
                \Log::error('Armada branch creation exception on KYC approval (API)', [
                    'vendor_id' => $vendor->id,
                    'error' => $e->getMessage(),
                ]);
            }
        }

        return $this->successResponse(null, 'KYC approved successfully');
    }

    /**
     * Admin: Reject KYC
     */
    public function kycReject($id)
    {
        $vendor = Vendor::findOrFail($id);
        $vendor->update(['kyc_status' => 'rejected']);

        return $this->successResponse(null, 'KYC rejected successfully');
    }

    /**
     * Admin: Assign subscription
     */
    public function assignSubscription($id, Request $request)
    {
        $vendor = Vendor::findOrFail($id);

        $validator = Validator::make($request->all(), [
            'subscription_id' => 'required|exists:subscriptions,id',
            'start_date' => 'required|date',
            'end_date' => 'required|date|after:start_date',
        ]);

        if ($validator->fails()) {
            return $this->validationErrorResponse($validator->errors());
        }

        // Create or update vendor subscription
        $vendor->subscription()->updateOrCreate(
            ['vendor_id' => $vendor->id],
            [
                'subscription_id' => $request->subscription_id,
                'start_date' => $request->start_date,
                'end_date' => $request->end_date,
                'status' => 'active',
            ]
        );

        return $this->successResponse(null, 'Subscription assigned successfully');
    }

    /**
     * Admin: Set commission rate
     */
    public function setCommission($id, Request $request)
    {
        $vendor = Vendor::findOrFail($id);

        $validator = Validator::make($request->all(), [
            'commission_rate' => 'required|numeric|min:0|max:100',
        ]);

        if ($validator->fails()) {
            return $this->validationErrorResponse($validator->errors());
        }

        $vendor->update(['commission_rate' => $request->commission_rate]);

        return $this->successResponse(null, 'Commission rate updated successfully');
    }

    /**
     * Vendor: Get own profile
     */
    public function profile(Request $request)
    {
        $user = $request->user();
        $vendor = $user->vendor;

        if (!$vendor) {
            return $this->forbiddenResponse('User is not a vendor');
        }

        return $this->successResponse($vendor->load(['user', 'subscription']));
    }

    /**
     * Vendor: Update own profile
     */
    public function updateProfile(Request $request)
    {
        $user = $request->user();
        $vendor = $user->vendor;

        if (!$vendor) {
            return $this->forbiddenResponse('User is not a vendor');
        }

        $validator = Validator::make($request->all(), [
            'company_name' => 'required|string|max:255',
            'phone' => 'required|string|max:20',
            'address' => 'required|string',
            'description' => 'nullable|string',
            'website' => 'nullable|url',
            'social_media' => 'nullable|json',
        ]);

        if ($validator->fails()) {
            return $this->validationErrorResponse($validator->errors());
        }

        $vendor->update($validator->validated());

        return $this->successResponse($vendor->load(['user', 'subscription']), 'Profile updated successfully');
    }

    /**
     * Vendor: Upload logo
     */
    public function uploadLogo(Request $request)
    {
        $user = $request->user();
        $vendor = $user->vendor;

        if (!$vendor) {
            return $this->forbiddenResponse('User is not a vendor');
        }

        $validator = Validator::make($request->all(), [
            'logo' => 'required|image|mimes:jpeg,png,jpg,gif,svg|max:2048',
        ]);

        if ($validator->fails()) {
            return $this->validationErrorResponse($validator->errors());
        }

        $disk = config('filesystems.default', 's3');
        
        // Delete old logo if exists
        if ($vendor->logo) {
            Storage::disk($disk)->delete($vendor->logo);
        }
        
        // Upload new logo
        $logoPath = $request->file('logo')->store('vendor-logos', $disk);
        $vendor->update(['logo' => $logoPath]);

        return $this->successResponse(['logo_url' => Storage::disk($disk)->url($logoPath)], 'Logo uploaded successfully');
    }

    /**
     * Vendor: Send password change OTP
     */
    public function sendPasswordChangeOTP(Request $request)
    {
        $user = $request->user();
        $vendor = $user->vendor;

        if (!$vendor) {
            return $this->forbiddenResponse('User is not a vendor');
        }

        // Generate random 6-digit OTP
        $otp = rand(100000, 999999);
        
        // Store OTP in cache for 10 minutes
        $cacheKey = 'vendor_password_otp_' . $user->id;
        \Illuminate\Support\Facades\Cache::put($cacheKey, $otp, now()->addMinutes(10));
        
        // Try to send OTP via SMSBox (optional - if fails, still use 123456)
        $phone = $vendor->mobile ?? $user->mobile;
        if ($phone) {
            try {
                $message = "Your OTP for password change is: {$otp}";
                Log::info('Api\VendorController: Sending Password Change OTP via SMS', [
                    'phone' => $phone,
                    'message' => $message
                ]);
                send_sms($phone, $message);
            } catch (\Exception $e) {
                // Ignore SMS sending errors, still use OTP 123456
            }
        }
        
        return $this->successResponse(null, 'OTP sent successfully to your phone number');
    }

    /**
     * Vendor: Change password
     */
    public function changePassword(Request $request)
    {
        $user = $request->user();
        $vendor = $user->vendor;

        if (!$vendor) {
            return $this->forbiddenResponse('User is not a vendor');
        }

        $validator = Validator::make($request->all(), [
            'current_password' => 'required|string',
            'password' => 'required|string|min:8|confirmed',
            'otp' => 'required|string',
        ]);

        if ($validator->fails()) {
            return $this->validationErrorResponse($validator->errors());
        }

        // Verify OTP from cache
        $cacheKey = 'vendor_password_otp_' . $user->id;
        $cachedOtp = \Illuminate\Support\Facades\Cache::get($cacheKey);
        
        // Strict verification
        if (!$cachedOtp || (string)$cachedOtp !== (string)$request->otp) {
            return $this->errorResponse('Invalid or expired OTP', 400);
        }
        
        // Clear OTP after successful verification
        \Illuminate\Support\Facades\Cache::forget($cacheKey);

        if (!Hash::check($request->current_password, $user->password)) {
            return $this->errorResponse('Current password is incorrect', 400);
        }

        $user->update(['password' => Hash::make($request->password)]);

        return $this->successResponse(null, 'Password changed successfully');
    }

    /**
     * Vendor: Delete account
     */
    public function deleteAccount(Request $request)
    {
        $user = $request->user();
        $vendor = $user->vendor;

        if (!$vendor) {
            return $this->forbiddenResponse('User is not a vendor');
        }

        // TODO: Add confirmation logic and data cleanup
        $vendor->delete();
        $user->delete();

        return $this->successResponse(null, 'Account deleted successfully');
    }

    /**
     * Vendor: Get KYC status
     */
    public function kycStatus(Request $request)
    {
        $user = $request->user();
        $vendor = $user->vendor;

        if (!$vendor) {
            return $this->forbiddenResponse('User is not a vendor');
        }

        return $this->successResponse([
            'kyc_status' => $vendor->kyc_status,
            'kyc_notes' => $vendor->kyc_notes,
        ]);
    }

    /**
     * Vendor: Resend KYC
     */
    public function resendKYC(Request $request)
    {
        $user = $request->user();
        $vendor = $user->vendor;

        if (!$vendor) {
            return $this->forbiddenResponse('User is not a vendor');
        }

        $validator = Validator::make($request->all(), [
            'kyc_documents' => 'required|array',
            'kyc_documents.*' => 'required|file|mimes:pdf,jpg,jpeg,png|max:5120',
        ]);

        if ($validator->fails()) {
            return $this->validationErrorResponse($validator->errors());
        }

        // TODO: Handle KYC document upload and processing
        $vendor->update(['kyc_status' => 'pending']);

        return $this->successResponse(null, 'KYC documents submitted successfully');
    }
} 