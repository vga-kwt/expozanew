<?php

namespace App\Http\Controllers\Auth;

use App\Http\Controllers\Controller;
use App\Models\User;
use App\Models\Vendor;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Str;
use Inertia\Inertia;


class VendorAuthController extends Controller
{
    /**
     * Show vendor registration form
     */
    public function showRegistrationForm()
    {
        return Inertia::render('auth/vendor-register');
    }

    /**
     * Send OTP for vendor registration
     */
    public function sendOTP(Request $request)
    {
        $request->validate([
            'brand_name_en' => 'required|string|max:255',
            'brand_name_ar' => 'required|string|max:255',
            'email' => 'required|email|unique:users,email',
            'phone' => 'required|string|size:8|unique:users,phone',
            'accept_terms' => 'accepted',
            'use_armada_delivery' => 'accepted',
            'latitude' => 'nullable|numeric|between:-90,90',
            'longitude' => 'nullable|numeric|between:-180,180',
            'address_text' => 'nullable|string|max:500',
            'password' => [
                'required',
                'string',
                'min:8',
                'confirmed',
                'regex:/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#$%^&*(),.?":{}|<>]).+$/'
            ],
        ], [
            'password.regex' => 'Password must contain at least one uppercase letter, one lowercase letter, one number, and one special character.',
            'email.unique' => 'This email is already registered. Please use a different email or try logging in.',
            'phone.unique' => 'This phone number is already registered. Please use a different number or try logging in.',
            'phone.size' => 'Phone number must be exactly 8 digits.',
        ]);

        // Store registration data in session
        $request->session()->put('vendor_registration', $request->only([
            'brand_name_en',
            'brand_name_ar',
            'email',
            'phone',
            'password',
            'password_confirmation',
            'accept_terms',
            'use_armada_delivery',
            'latitude',
            'longitude',
            'address_text',
        ]));

        // OTP generation and sending is now handled on frontend
        // Just return success to proceed to OTP step
        return back()->with('success', 'Please enter the OTP sent to your phone.');
    }

    /**
     * Verify OTP and proceed to KYC
     * Note: OTP verification is now handled on frontend
     * This endpoint just marks OTP as verified in session
     */
    public function verifyOTP(Request $request)
    {
        // OTP verification is handled on frontend
        // Just mark as verified and allow to proceed
        $request->session()->put('vendor_otp_verified', true);

        Log::info('OTP Verified (Frontend)', [
            'phone' => $request->session()->get('vendor_registration.phone')
        ]);

        return back()->with('success', 'OTP verified. Please complete your registration.');
    }

    /**
     * Complete vendor registration with KYC documents
     */

    public function completeRegistration(Request $request)
    {
        // Ensure OTP was verified (this is set by the verify-otp endpoint called by frontend)
        if (!$request->session()->get('vendor_otp_verified')) {
            return back()->withErrors(['otp' => 'OTP verification required.']);
        }

        // Validate the incoming request data since session data might be missing
        $validated = $request->validate([
            'brand_name_en' => ['required', 'string', 'max:255'],
            'brand_name_ar' => ['required', 'string', 'max:255'],
            'email' => ['required', 'string', 'email', 'max:255', 'unique:users'],
            'phone' => ['required', 'string', 'size:8', 'unique:users,phone'], // Assuming 8 digits for phone
            'password' => ['required', 'confirmed', 'min:8'],
            // Add other necessary validations
        ]);

        $data = $request->all();

        // Create the user
        $user = User::create([
            'full_name' => $data['brand_name_en'], // Use brand name as user name
            'email' => $data['email'],
            'phone' => $data['phone'],
            'password' => bcrypt($data['password']),
            'role' => 'vendor',
            'mobile_verified_at' => now(),
            'email_verified_at' => now(),
        ]);
        $user->assignRole('vendor');

        // Create the vendor record
        Vendor::create([
            'user_id' => $user->id,
            'brand_name_en' => $data['brand_name_en'],
            'brand_name_ar' => $data['brand_name_ar'],
            'email' => $data['email'],
            'mobile' => $data['phone'],
            'phone' => $data['phone'],
            'use_armada_delivery' => $data['use_armada_delivery'] ?? false,
            'latitude' => $data['latitude'] ?? null,
            'longitude' => $data['longitude'] ?? null,
            'address_text' => $data['address_text'] ?? null,
        ]);

        // Clear session
        $request->session()->forget(['vendor_registration', 'vendor_otp', 'vendor_otp_verified']);

        // 🔐 Auto-login the user
        Auth::login($user);

        // ✅ Redirect to vendor dashboard
        return redirect()->route('dashboard')->with('success', 'Registration complete! Welcome to your dashboard.');
    }


    /**
     * Show vendor login form
     */
    public function showLoginForm()
    {
        return Inertia::render('auth/vendor-login', [
            'canResetPassword' => true,
            'error' => session('error'),
        ]);
    }

    /**
     * Handle vendor login
     */
    public function login(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'identifier' => 'required|string',
            'password' => 'required|string',
        ], [
            'identifier.required' => 'Email or phone is required',
            'password.required' => 'Password is required',
        ]);

        if ($validator->fails()) {
            return back()->withErrors($validator)->withInput();
        }

        $identifier = $request->identifier;
        $password = $request->password;

        // Try to find user by email or phone
        $user = filter_var($identifier, FILTER_VALIDATE_EMAIL)
            ? User::where('email', $identifier)->first()
            : User::where('phone', $identifier)->first();

        if (!$user) {
            return back()->withErrors(['identifier' => 'Email or phone number not found'])->withInput();
        }

        // Check password
        if (!Hash::check($password, $user->password)) {
            return back()->withErrors(['password' => 'Incorrect password'])->withInput();
        }

        // Check vendor role
        if (!$user->hasRole('vendor')) {
            return back()->withErrors(['identifier' => 'This account is not registered as a vendor'])->withInput();
        }

        // Clear cache to prevent showing previous vendor's products
        Cache::flush();

        // Login user
        Auth::login($user, $request->boolean('remember'));
        $request->session()->regenerate();

        return redirect()->intended(route('dashboard'));
    }

    /**
     * Show forgot password form
     */
    public function showForgotPasswordForm()
    {
        return Inertia::render('auth/vendor-forgot-password');
    }

    /**
     * Send password reset email
     */
    public function sendPasswordResetEmail(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'phone' => 'required|string|size:8',
        ]);

        if ($validator->fails()) {
            return back()->withErrors($validator)->withInput();
        }

        $user = User::where('phone', $request->phone)->whereHas('roles', function ($query) {
            $query->where('role', 'vendor');
        })->first();

        if (!$user) {
            return back()->withErrors(['phone' => 'No vendor account found with this phone number']);
        }

        // User exists. Return success so frontend can generate and send OTP.
        return back()->with('success', 'User verification successful.');
    }

    /**
     * Show password reset form
     */
    public function showPasswordResetForm(Request $request, $token)
    {
        $user = User::where('password_reset_token', $token)
            ->where('password_reset_at', '>', now())
            ->whereHas('roles', function ($query) {
                $query->where('role', 'vendor');
            })
            ->first();
        // dd($user);
        if (!$user) {
            return redirect()->route('vendor.login')->with('error', 'Invalid or expired reset token');
        }

        return Inertia::render('auth/vendor-reset-password', [
            'token' => $token,
            'email' => $user->email,
        ]);
    }

    /**
     * Verify OTP for forgot password and return reset token
     */
    public function verifyForgotOtp(Request $request)
    {
        // dd($request->all());
        $request->validate([
            'phone' => 'required|string|size:8',
            'otp' => 'required|string|size:6',
        ]);

        $user = User::where('phone', $request->phone)->whereHas('roles', function ($query) {
            $query->where('role', 'vendor');
        })->first();

        // dd($user);
        if (!$user) {
            return back()->withErrors(['phone' => 'No vendor account found with this phone number']);
        }

        // Frontend handles verification via useOtp hook.
        // We trust the request at this stage as per design requirement.

        // Generate a short-lived reset token
        $token = Str::random(60);
        $user->update([
            'password_reset_token' => $token,
            'password_reset_at' => now()->addMinutes(15),
        ]);
        session()->forget('vendor_forgot_otp');

        return back()->with([
            'success' => 'OTP verified successfully.',
            'token' => $token
        ]);
    }

    /**
     * Reset password with phone, token, and new password
     */
    public function resetPassword(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'phone' => 'required|string|size:8',
            'token' => 'required|string',
            'password' => [
                'required',
                'string',
                'min:8',
                'confirmed',
                'regex:/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#$%^&*(),.?":{}|<>]).+$/'
            ],
        ], [
            'password.regex' => 'Password must contain at least one uppercase letter, one lowercase letter, one number, and one special character.',
        ]);

        if ($validator->fails()) {
            return back()->withErrors($validator)->withInput();
        }

        $user = User::where('phone', $request->phone)
            ->where('password_reset_token', $request->token)
            ->where('password_reset_at', '>', now())
            ->whereHas('roles', function ($query) {
                $query->where('role', 'vendor');
            })
            ->first();

        if (!$user) {
            return back()->withErrors(['email' => 'Invalid reset token or email']);
        }

        $user->update([
            'password' => Hash::make($request->password),
            'password_reset_token' => null,
            'password_reset_at' => null,
        ]);

        return redirect()->route('vendor.login')->with('success', 'Password reset successfully');
    }

    /**
     * Logout vendor
     */
    public function logout(Request $request)
    {
        // Clear all caches to prevent showing products after logout
        Cache::flush();

        // Logout the user first
        Auth::guard('web')->logout();

        // Clear all session data
        $request->session()->flush();

        // Invalidate the session completely
        $request->session()->invalidate();

        // Regenerate CSRF token
        $request->session()->regenerateToken();

        // Redirect to login page with success message
        return redirect()->route('vendor.login')
            ->with('success', 'You have been logged out successfully.');
    }
}
