<?php

namespace App\Http\Controllers;

use App\Models\Vendor;
use App\Models\Address;
use App\Models\Country;
use App\Models\State;
use App\Models\City;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\Validator;
use Inertia\Inertia;
use Illuminate\Support\Str;
use Illuminate\Support\Facades\Log;

class VendorProfileController extends Controller
{
    /**
     * Show vendor profile management page
     */
    public function index()
    {
        $user = auth()->user();
        $vendor = $user->vendor;

        if (!$vendor) {
            return redirect()->route('dashboard')->with('error', 'Vendor profile not found');
        }

        // Get vendor address (role_name = 'vendor')
        $address = Address::where('user_id', $user->id)
            ->where('role_name', 'vendor')
            ->with(['country', 'state', 'city'])
            ->first();

        // Get countries, states, and cities for dropdowns
        $countries = Country::active()->orderBy('name_en')->get(['id', 'name_en', 'name_ar']);
        $states = State::active()->orderBy('name_en')->get(['id', 'name_en', 'name_ar', 'country_id']);
        $cities = City::active()->orderBy('name_en')->get(['id', 'name_en', 'name_ar', 'country_id', 'state_id']);

        return Inertia::render('Vendor/Profile/Index', [
            'user' => $user,
            'vendor' => $vendor,
            'kyc_status' => $vendor->kyc_status,
            'kyc_rejection_reason' => $vendor->kyc_rejection_reason,
            'address' => $address,
            'countries' => $countries,
            'states' => $states,
            'cities' => $cities,
        ]);
    }

    /**
     * Update vendor profile
     */
    public function update(Request $request)
    {
        $user = Auth::user();
        $vendor = $user->vendor;

        if (!$vendor) {
            return redirect()->back()->with('error', 'Vendor profile not found');
        }

        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'brand_name_en' => 'nullable|string|max:255',
            'brand_name_ar' => 'nullable|string|max:255',
            'email' => 'required|email|max:255|unique:vendors,email,' . $vendor->id,
            'mobile' => 'nullable|string|max:20',
            'phone' => ['required', 'regex:/^[0-9]{8,}$/'],
            'description_en' => 'nullable|string|max:1000',
            'description_ar' => 'nullable|string|max:1000',
            'use_armada_delivery' => 'nullable|boolean',
            'latitude' => 'nullable|numeric|between:-90,90',
            'longitude' => 'nullable|numeric|between:-180,180',
            'address_text' => 'nullable|string|max:500',
            // Address fields (country_id required when address line is provided - DB constraint)
            'address_full_name' => 'nullable|string|max:255',
            'address_phone' => 'nullable|string|max:20',
            'address_line_1' => 'nullable|string|max:255',
            'address_line_2' => 'nullable|string|max:255',
            'address_country_id' => 'required_with:address_line_1|nullable|integer|exists:countries,id',
            'address_state_id' => 'nullable|integer|exists:states,id',
            'address_city_id' => 'nullable|integer|exists:cities,id',
            'address_pincode' => 'nullable|string|max:20',
        ]);

        // Only update fields that exist on the Vendor model
        $vendorUpdateData = $validated;
        unset($vendorUpdateData['phone']); // Remove user fields
        unset($vendorUpdateData['address_full_name']);
        unset($vendorUpdateData['address_phone']);
        unset($vendorUpdateData['address_line_1']);
        unset($vendorUpdateData['address_line_2']);
        unset($vendorUpdateData['address_country_id']);
        unset($vendorUpdateData['address_state_id']);
        unset($vendorUpdateData['address_city_id']);
        unset($vendorUpdateData['address_pincode']);

        // Convert boolean checkbox value
        if (isset($vendorUpdateData['use_armada_delivery'])) {
            $vendorUpdateData['use_armada_delivery'] = (bool) $vendorUpdateData['use_armada_delivery'];
        }

        $vendor->update($vendorUpdateData);

        // Update user (only name, email, phone)
        $user->update([
            'full_name' => $validated['name'],
            'email' => $validated['email'],
            'phone' => $validated['phone'],
            'mobile' => $validated['mobile'],
        ]);

        // Handle address update/create (only when we have country_id - required by DB)
        if (!empty($request->address_line_1) && !empty($validated['address_country_id'])) {
            $address = Address::where('user_id', $user->id)
                ->where('role_name', 'vendor')
                ->first();

            $addressData = [
                'user_id' => $user->id,
                'role_name' => 'vendor',
                'full_name' => $validated['address_full_name'] ?? $user->full_name,
                'phone' => $validated['address_phone'] ?? $user->phone,
                'line_1' => $validated['address_line_1'],
                'line_2' => $validated['address_line_2'] ?? null,
                'country_id' => $validated['address_country_id'],
                'state_id' => $validated['address_state_id'] ?? null,
                'city_id' => $validated['address_city_id'] ?? null,
                'pincode' => $validated['address_pincode'] ?? null,
                'is_default' => true, // Vendor address is always default
            ];

            if ($address) {
                $address->update($addressData);
            } else {
                Address::create($addressData);
            }
        }

        // Armada: update existing branch or create branch if vendor has none
        if (config('armada.enabled', false) && $vendor->use_armada_delivery) {
            $vendor->refresh(); // ensure we have latest latitude, longitude, address_text from DB
            $armadaService = app(\App\Services\ArmadaService::class);
            if (!empty($vendor->armada_branch_id)) {
                $result = $armadaService->updateBranch($vendor);
                if (!$result['success']) {
                    Log::warning('Armada update branch failed on profile save', [
                        'vendor_id' => $vendor->id,
                        'error' => $result['error'] ?? 'Unknown error',
                    ]);
                }
            } else {
                $result = $armadaService->createBranch($vendor);
                if ($result['success']) {
                    $vendor->update([
                        'armada_branch_id' => $result['branch_id'],
                        'armada_branch_key' => $result['branch_key'],
                    ]);
                    Log::info('Armada branch created on profile save', [
                        'vendor_id' => $vendor->id,
                        'branch_id' => $result['branch_id'],
                    ]);
                } else {
                    Log::warning('Armada create branch failed on profile save', [
                        'vendor_id' => $vendor->id,
                        'error' => $result['error'] ?? 'Unknown error',
                    ]);
                }
            }
        }

        return redirect()->back()->with('success', 'Profile updated successfully');
    }

    /**
     * Upload/Update vendor logo
     */
    public function uploadLogo(Request $request)
    {
        $user = Auth::user();
        $vendor = $user->vendor;

        if (!$vendor) {
            return redirect()->back()->with('error', 'Vendor profile not found');
        }

        $request->validate([
            'logo' => 'required|image|mimes:jpeg,png,jpg,gif|max:2048|dimensions:min_width=300,min_height=300,max_width=800,max_height=800',
        ]);

        $disk = config('filesystems.default', 's3');

        // Delete old logo if exists
        if ($vendor->logo && Storage::disk($disk)->exists($vendor->logo)) {
            Storage::disk($disk)->delete($vendor->logo);
        }

        // Store new logo
        $logoPath = $request->file('logo')->store('vendor-logos', $disk);
        $vendor->update(['logo' => $logoPath]);

        // Redirect back with success message for Inertia
        return redirect()->back()->with('success', 'Logo uploaded successfully');
    }

    /**
     * Send OTP for password change
     */
    public function sendPasswordChangeOTP(Request $request)
    {
        $user = Auth::user();
        $vendor = $user->vendor;

        if (!$vendor) {
            return response('Vendor profile not found', 404);
        }

        // Always use the user's phone field for OTP
        $phone = $user->phone;
        if (!$phone) {
            return response('No phone number found in your profile. Please update your phone number.', 400);
        }
        if (!preg_match('/^[0-9]{8,}$/', $phone)) {
            return response('Phone number must be at least 8 digits.', 400);
        }

        // Frontend handles OTP generation now.
        // This endpoint might just be used for validation or legacy support.

        return response()->json([
            'success' => true,
            'message' => 'Ready to send OTP.',
        ]);
    }

    /**
     * Verify password change OTP
     */
    public function verifyPasswordOTP(Request $request)
    {
        // Frontend handles OTP verification
        // Just set the verified flag in session so password change can proceed
        $request->session()->put('otp_verified', true);

        return response()->json(['success' => true]);
    }

    /**
     * Change password with OTP verification
     */
    public function changePassword(Request $request)
    {
        $user = Auth::user();

        $request->validate([
            'new_password' => 'required|string|min:8|confirmed',
            'otp' => 'required|string',
        ]);

        // Check if OTP was verified by the frontend flow
        if (!$request->session()->get('otp_verified')) {
            return redirect()->back()->with('error', 'Please verify your phone number first.');
        }

        // Remove the flag
        $request->session()->forget('otp_verified');

        // Update password
        $user->update([
            'password' => Hash::make($request->new_password)
        ]);

        return redirect()->back()->with('success', 'Password changed successfully!');
    }

    /**
     * Delete vendor account
     */
    public function deleteAccount(Request $request)
    {
        $user = Auth::user();
        $vendor = $user->vendor;

        if (!$vendor) {
            return redirect()->back()->with('error', 'Vendor profile not found');
        }

        $request->validate([
            'confirmation' => 'required|string|in:DELETE',
        ]);

        $disk = config('filesystems.default', 's3');

        // Delete vendor logo if exists
        if ($vendor->logo && Storage::disk($disk)->exists($vendor->logo)) {
            Storage::disk($disk)->delete($vendor->logo);
        }

        // Armada: delete branch if vendor had one
        if (config('armada.enabled', false) && !empty($vendor->armada_branch_id)) {
            try {
                $armadaService = app(\App\Services\ArmadaService::class);
                $result = $armadaService->deleteBranch($vendor->armada_branch_id);
                if (!$result['success']) {
                    Log::warning('Armada delete branch failed on account deletion', [
                        'vendor_id' => $vendor->id,
                        'branch_id' => $vendor->armada_branch_id,
                        'error' => $result['error'] ?? 'Unknown error',
                    ]);
                }
            } catch (\Exception $e) {
                Log::error('Armada delete branch exception on account deletion', [
                    'vendor_id' => $vendor->id,
                    'error' => $e->getMessage(),
                ]);
            }
        }

        // Delete vendor profile
        $vendor->forceDelete();
        $vendor->user()->forceDelete();

        // Logout and redirect
        Auth::logout();
        $request->session()->invalidate();
        $request->session()->regenerateToken();

        return redirect()->route('login')->with('success', 'Account deleted successfully');
    }

    /**
     * View KYC status
     */
    public function kycStatus()
    {
        $user = Auth::user();
        $vendor = $user->vendor;

        if (!$vendor) {
            return redirect()->route('dashboard')->with('error', 'Vendor profile not found');
        }

        $disk = config('filesystems.default', 's3');
        $kyc_documents = $vendor->kyc_documents ?? [];
        // Convert file paths to URLs
        if (isset($kyc_documents['civil_id'])) {
            $kyc_documents['civil_id_url'] = $kyc_documents['civil_id'] ? \Storage::disk($disk)->url($kyc_documents['civil_id']) : null;
        }
        if (isset($kyc_documents['commercial_license'])) {
            $kyc_documents['commercial_license_url'] = $kyc_documents['commercial_license'] ? \Storage::disk($disk)->url($kyc_documents['commercial_license']) : null;
        }
        if (isset($kyc_documents['iban_certificate'])) {
            $kyc_documents['iban_certificate_url'] = $kyc_documents['iban_certificate'] ? \Storage::disk($disk)->url($kyc_documents['iban_certificate']) : null;
        }

        return Inertia::render('Vendor/Profile/KYCStatus', [
            'kyc_status' => $vendor->kyc_status,
            'kyc_rejection_reason_en' => $vendor->kyc_rejection_reason_en, // or whatever field holds the reason
            'kyc_documents' => $kyc_documents,
        ]);
    }

    /**
     * Resend KYC documents
     */
    public function resendKYC(Request $request)
    {
        $user = Auth::user();
        $vendor = $user->vendor;

        if (!$vendor) {
            return redirect()->back()->with('error', 'Vendor profile not found');
        }

        $request->validate([
            'civil_id' => 'required|file|mimes:pdf,jpg,jpeg,png|max:2048',
            'commercial_license' => 'required|file|mimes:pdf,jpg,jpeg,png|max:2048',
            'iban_certificate' => 'required|file|mimes:pdf,jpg,jpeg,png|max:2048',
        ]);

        $disk = config('filesystems.default', 's3');

        // Store documents
        $civilIdPath = $request->file('civil_id')->store('kyc-documents', $disk);
        $commercialLicensePath = $request->file('commercial_license')->store('kyc-documents', $disk);
        $ibanCertificatePath = $request->file('iban_certificate')->store('kyc-documents', $disk);

        // Update vendor KYC status
        $vendor->update([
            'kyc_status' => 'review',
            'kyc_rejection_reason' => null,
            'kyc_documents' => [
                'civil_id' => $civilIdPath,
                'commercial_license' => $commercialLicensePath,
                'iban_certificate' => $ibanCertificatePath,
            ],
        ]);

        return redirect()->back()->with('success', 'KYC documents submitted successfully. Please wait for approval.');
    }

    /**
     * Update individual KYC document
     */
    public function updateKYCDocument(Request $request)
    {
        $user = Auth::user();
        $vendor = $user->vendor;

        if (!$vendor) {
            return response()->json(['error' => 'Vendor profile not found'], 400);
        }

        $request->validate([
            'document_type' => 'required|in:civil_id,commercial_license,iban_certificate',
            'document' => 'required|file|mimes:pdf,jpg,jpeg,png|max:2048',
        ]);

        $disk = config('filesystems.default', 's3');
        $documentType = $request->input('document_type');
        $documentPath = $request->file('document')->store('kyc-documents', $disk);

        // Get existing documents
        $kycDocuments = $vendor->kyc_documents ?? [];

        // Update the specific document
        $kycDocuments[$documentType] = $documentPath;

        // Update vendor KYC status to review if it was approved/rejected
        $updateData = [
            'kyc_documents' => $kycDocuments,
        ];

        // If status is approved or rejected, change to review
        if (in_array($vendor->kyc_status, ['approved', 'rejected'])) {
            $updateData['kyc_status'] = 'review';
            $updateData['kyc_rejection_reason'] = null;
        }

        $vendor->update($updateData);

        return response()->json([
            'success' => true,
            'message' => ucfirst(str_replace('_', ' ', $documentType)) . ' updated successfully. Status changed to review.',
        ]);
    }
}
