<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Api\Controller;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Str;
use App\Models\Otp;
use App\Rules\UnicodeDisplayName;
use App\Rules\UnicodeStrongPassword;
use Illuminate\Support\Facades\Log;

/**
 * @OA\SecurityScheme(
 *     securityScheme="sanctum",
 *     type="http",
 *     scheme="bearer",
 *     bearerFormat="JWT"
 * )
 */
class OtpController extends Controller
{

    public function checkValidated(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'mobile' => 'required|string',
            'email' => 'required|email',
        ]);
        if ($validator->fails()) {
            return $this->validationErrorResponse($validator->errors());
        }
        $userByMobile = User::where('mobile', $request->mobile)->first();
        $userByEmail = User::where('email', $request->email)->first();
        if ($userByMobile) {
            return response()->json([
                'status' => false,
                'message' => 'Phone number already exists',
            ]);
        }
        if ($userByEmail) {
            return response()->json([
                'status' => false,
                'message' => 'Email already exists',
            ]);
        }
        // If neither exists, user is not found
        return response()->json([
            'status' => true,
        ]);
    }

    /**
     * Send OTP to mobile (for signup, forgot password)
     *
     * @OA\Post(
     *     path="/api/send-otp",
     *     summary="Send OTP to user (signup or forgot password)",
     *     description="Step 1: User enters mobile, receives OTP via SMS. Use this for both signup and forgot password.",
     *     tags={"Auth"},
     *     @OA\RequestBody(
     *         required=true,
     *         @OA\JsonContent(
     *             required={"mobile", "purpose"},
     *             @OA\Property(property="mobile", type="string", example="9876543210"),
     *             @OA\Property(property="purpose", type="string", enum={"signup","forgot"})
     *         )
     *     ),
     *     @OA\Response(
     *         response=200,
     *         description="OTP sent successfully",
     *         @OA\JsonContent(
     *             @OA\Property(property="otp", type="string", example="123456")
     *         )
     *     )
     * )
     */
    public function sendOtp(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'mobile' => 'required',
            'purpose' => 'required|in:signup,forgot',
        ]);
        if ($validator->fails()) {
            return $this->validationErrorResponse($validator->errors());
        }
        // Generate random 6-digit OTP
        $otpCode = rand(100000, 999999);
        // Find or create user by mobile (for signup, user may not exist yet)
        $user = User::where('mobile', $request->mobile)->first();
        if (!$user && $request->purpose === 'signup') {
            // Create user with dummy email for now, password will be set after OTP verification
            $user = User::create([
                'mobile' => $request->mobile,
                'name' => '',
                'email' => 'user' . $request->mobile . '@example.com',
                'password' => '',
            ]);
        }
        if (!$user) {
            return response()->json([
                'status' => false,
                'message' => 'User not found',
            ]);
        }
        // Always create a new OTP record (do not update old)
        Otp::create([
            'user_id' => $user->id,
            'role' => $user->role ?? 'user',
            'otp' => $otpCode,
            'expires_in' => now()->addMinutes(5),
        ]);
        // Try to send SMS via SMSBox (optional - if fails, still use 123456)
        try {
            $message = "Your OTP is: " . $otpCode;
            Log::info('Api\OtpController: Sending OTP via SMS', [
                'phone' => $request->mobile,
                'message' => $message
            ]);
            send_sms($request->mobile, $message);
        } catch (\Exception $e) {
            // Ignore SMS sending errors, still return OTP 123456
        }
        return $this->successResponse(['otp' => $otpCode], 'OTP sent successfully');
    }

    public function resendOtp(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'mobile' => 'required|string',

        ]);
        if ($validator->fails()) {
            return $this->validationErrorResponse($validator->errors());
        }
        $user = User::where('mobile', $request->mobile)->first();
        if (!$user) {
            return $this->notFoundResponse('User not found');
        }
        // Generate random 6-digit OTP
        $otpCode = rand(100000, 999999);
        Otp::create([
            'user_id' => $user->id,
            'role' => $user->role ?? 'user',
            'otp' => $otpCode,
            'expires_in' => now()->addMinutes(5),
        ]);
        // Try to send SMS via SMSBox (optional - if fails, still use 123456)
        try {
            $message = "Your OTP is: " . $otpCode;
            Log::info('Api\OtpController: Resending OTP via SMS', [
                'phone' => $request->mobile,
                'message' => $message
            ]);
            send_sms($request->mobile, $message);
        } catch (\Exception $e) {
            // Ignore SMS sending errors, still return OTP 123456
        }
        return response()->json([
            'status' => true,
            "message" => "OTP sent successfully",
            'otp' => $otpCode
        ], 200);
    }

    /**
     * Verify OTP (for signup, forgot password)
     *
     * @OA\Post(
     *     path="/api/verify-otp",
     *     summary="Verify OTP for user (signup or forgot password)",
     *     description="Step 2: User enters mobile and OTP. If OTP is valid, returns a temp_token (required for signup).",
     *     tags={"Auth"},
     *     @OA\RequestBody(
     *         required=true,
     *         @OA\JsonContent(
     *             required={"mobile", "otp"},
     *             @OA\Property(property="mobile", type="string", example="9876543210"),
     *             @OA\Property(property="otp", type="string", example="123456")
     *         )
     *     ),
     *     @OA\Response(
     *         response=200,
     *         description="OTP verified successfully. Returns temp_token for next step.",
     *         @OA\JsonContent(
     *             @OA\Property(property="temp_token", type="string", example="a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6q7r8s9t0")
     *         )
     *     ),
     *     @OA\Response(
     *         response=400,
     *         description="Invalid or expired OTP"
     *     )
     * )
     */
    public function verifyOtp(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'mobile' => 'required|string',
            'otp' => 'required|digits:6',
            'purpose' => 'nullable|string', // signup / forgot
            'email' => 'nullable|email', // email optional for signup purpose
        ]);

        if ($validator->fails()) {
            return $this->validationErrorResponse($validator->errors());
        }

        // Check if mobile already registered (only for signup purpose)
        if ($request->purpose === 'signup') {
            $mobileExists = User::where('mobile', $request->mobile)
                ->whereNotNull('password') // already completed signup
                ->exists();

            if ($mobileExists) {
                return $this->errorResponse('Mobile number already registered', 409);
            }

            if ($request->filled('email')) {
                $emailExists = User::where('email', $request->email)->exists();
                if ($emailExists) {
                    return $this->errorResponse('Email already registered', 409);
                }
            }
        }

        // Find user (may be temp user created earlier for OTP sending)
        $user = User::where('mobile', $request->mobile)->first();
        if (!$user) {
            return $this->notFoundResponse('User not found');
        }

        // Validate OTP
        $otp = Otp::where('user_id', $user->id)
            ->where('otp', $request->otp)
            ->where('expires_in', '>', now())
            ->latest()
            ->first();

        if (!$otp) {
            return $this->errorResponse('Invalid or expired OTP', 400);
        }

        // Mark OTP as used
        $otp->delete();

        if ($request->purpose === 'forgot') {
            // Generate reset token
            $resetToken = Str::random(40);
            $user->password_reset_token = $resetToken;
            $user->save();
            return $this->successResponse(['password_reset_token' => $resetToken], 'OTP verified for password reset');
        }

        // For signup purpose, generate temp_token
        $signupToken = Str::random(40);
        $user->remember_token = $signupToken;
        $user->save();

        return $this->successResponse(['temp_token' => $signupToken], 'OTP verified successfully');
    }

    /**
     * Signup with mobile + temp_token (after OTP verified)
     *
     * @OA\Post(
     *     path="/api/signup",
     *     summary="Signup with mobile, temp_token, name, password (after OTP verified)",
     *     description="Step 3: User enters mobile, temp_token (from verify-otp), name, password, and optional email. Completes signup and receives login token.",
     *     tags={"Auth"},
     *     @OA\RequestBody(
     *         required=true,
     *         @OA\JsonContent(
     *             required={"mobile", "temp_token", "full_name", "password"},
     *             @OA\Property(property="mobile", type="string", example="9876543210"),
     *             @OA\Property(property="temp_token", type="string", example="a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6q7r8s9t0"),
     *             @OA\Property(property="full_name", type="string", example="محمد أحمد or Jane Doe"),
     *             @OA\Property(property="email", type="string", example="john@example.com"),
     *             @OA\Property(property="password", type="string", description="Min 8 chars; letter (any script), number, symbol", example="Password123!")
     *         )
     *     ),
     *     @OA\Response(
     *         response=201,
     *         description="Signup successful. Returns user and login token.",
     *         @OA\JsonContent(
     *             @OA\Property(property="user", type="object"),
     *             @OA\Property(property="token", type="string", example="token123")
     *         )
     *     ),
     *     @OA\Response(
     *         response=400,
     *         description="Invalid or expired signup token"
     *     )
     * )
     */
    public function signup(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'mobile' => 'required|string',
            'temp_token' => 'required|string',
            'full_name' => ['required', new UnicodeDisplayName],
            'email' => 'nullable|email',
            'password' => ['required', new UnicodeStrongPassword],
        ]);

        if ($validator->fails()) {
            return $this->validationErrorResponse($validator->errors());
        }


        // Find user (who has only temp_token & mobile stored from OTP step)
        $user = User::where('mobile', $request->mobile)->first();
        if (!$user) {
            return $this->notFoundResponse('User not found');
        }

        // Check temp_token
        if ($user->remember_token !== $request->temp_token) {
            return $this->errorResponse('Invalid or expired signup token', 400);
        }

        // Update user details and set password
        $user->full_name = trim($request->full_name);
        $user->email = $request->email ?? $user->email;
        $user->password = Hash::make($request->password);
        $user->remember_token = null; // Clear after use
        $user->save();

        $token = $user->createToken('auth-token')->plainTextToken;

        return $this->successResponse([
            'user' => $user,
            'token' => $token,
        ], 'Signup successful', 201);
    }

    /**
     * Login with mobile and password
     *
     * @OA\Post(
     *     path="/api/login",
     *     summary="Login with email or mobile and password",
     *     tags={"Auth"},
     *     @OA\RequestBody(
     *         required=true,
     *         @OA\JsonContent(
     *             required={"login", "password"},
     *             @OA\Property(property="login", type="string", example="user@example.com or 9876543210"),
     *             @OA\Property(property="password", type="string", example="Password123")
     *         )
     *     ),
     *     @OA\Response(
     *         response=200,
     *         description="Login successful. Returns user and login token.",
     *         @OA\JsonContent(
     *             @OA\Property(property="user", type="object"),
     *             @OA\Property(property="token", type="string", example="token123")
     *         )
     *     ),
     *     @OA\Response(
     *         response=401,
     *         description="Invalid password"
     *     ),
     *     @OA\Response(
     *         response=404,
     *         description="User not found"
     *     )
     * )
     */
    public function login(Request $request)
    {
        // Socialite login
        if ($request->has('google_id')) {
            $user = User::where('google_id', $request->google_id)->first();
            if (!$user) {
                return $this->notFoundResponse('User with this Google account not found.');
            }
            $token = $user->createToken('auth-token')->plainTextToken;
            return $this->successResponse(['user' => $user, 'token' => $token], 'Login successful');
        }

        if ($request->has('apple_id')) {
            $user = User::where('apple_id', $request->apple_id)->first();
            if (!$user) {
                return $this->notFoundResponse('User with this Apple account not found.');
            }
            $token = $user->createToken('auth-token')->plainTextToken;
            return $this->successResponse(['user' => $user, 'token' => $token], 'Login successful');
        }

        // Standard login
        $validator = Validator::make($request->all(), [
            'login' => 'required', // can be email or mobile
            'password' => 'required|string',
        ]);
        if ($validator->fails()) {
            return $this->validationErrorResponse($validator->errors());
        }

        $login = $request->login;
        $user = filter_var($login, FILTER_VALIDATE_EMAIL)
            ? User::where('email', $login)->first()
            : User::where('mobile', $login)->first();

        if (!$user) {
            return $this->notFoundResponse('User not found');
        }

        // Check if the user has a password. If not, they likely signed up via social media.
        if (!$user->password) {
            return $this->unauthorizedResponse('You have registered using a social account. Please use Google or Apple to sign in.');
        }

        if (!Hash::check($request->password, $user->password)) {
            return $this->unauthorizedResponse('Invalid password');
        }

        $token = $user->createToken('auth-token')->plainTextToken;
        return $this->successResponse([
            'user' => $user,
            'token' => $token,
        ], 'Login successful');
    }

    public function googleSignIn(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'full_name' => 'required|string|max:255',
            'email' => 'required|string|email|max:255',
            'phone' => 'nullable|string|max:255',
            'google_id' => 'required|string',
        ]);

        if ($validator->fails()) {
            return $this->validationErrorResponse($validator->errors());
        }

        // First, check if user with this google_id already exists
        $user = User::where('google_id', $request->google_id)->first();

        if ($user) {
            // User exists with this google_id, update their info
            $user->update([
                'full_name' => $request->full_name,
                'email' => $request->email,
                'phone' => $request->phone,
            ]);
        } else {
            // Check if email already exists for a different user
            $existingUser = User::where('email', $request->email)->first();

            if ($existingUser) {
                // Email exists but no google_id - link this google_id to existing account
                $existingUser->update([
                    'google_id' => $request->google_id,
                    'full_name' => $request->full_name,
                    'phone' => $request->phone ?? $existingUser->phone,
                ]);
                $user = $existingUser;
            } else {
                // Create new user
                $user = User::create([
                    'google_id' => $request->google_id,
                    'full_name' => $request->full_name,
                    'email' => $request->email,
                    'phone' => $request->phone,
                ]);
            }
        }

        $token = $user->createToken('auth-token')->plainTextToken;

        return $this->successResponse([
            'user' => $user,
            'token' => $token,
        ], 'Login successful');
    }

    public function appleSignIn(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'full_name' => 'required|string|max:255',
            'email' => 'required|string|email|max:255',
            'phone' => 'nullable|string|max:255',
            'apple_id' => 'required|string',
            'access_token' => 'required|string',
        ]);

        if ($validator->fails()) {
            return $this->validationErrorResponse($validator->errors());
        }

        // First, check if user with this apple_id already exists
        $user = User::where('apple_id', $request->apple_id)->first();

        if ($user) {
            // User exists with this apple_id, update their info
            $user->update([
                'full_name' => $request->full_name,
                'email' => $request->email,
                'phone' => $request->phone,
                'remember_token' => $request->access_token,
            ]);
        } else {
            // Check if email already exists for a different user
            $existingUser = User::where('email', $request->email)->first();

            if ($existingUser) {
                // Email exists but no apple_id - link this apple_id to existing account
                $existingUser->update([
                    'apple_id' => $request->apple_id,
                    'full_name' => $request->full_name,
                    'phone' => $request->phone ?? $existingUser->phone,
                    'remember_token' => $request->access_token,
                ]);
                $user = $existingUser;
            } else {
                // Create new user
                $user = User::create([
                    'apple_id' => $request->apple_id,
                    'full_name' => $request->full_name,
                    'email' => $request->email,
                    'phone' => $request->phone,
                    'remember_token' => $request->access_token,
                ]);
            }
        }

        $token = $user->createToken('auth-token')->plainTextToken;

        return $this->successResponse([
            'user' => $user,
            'token' => $token,
        ], 'Login successful');
    }

    /**
     * Forgot password (request OTP, then reset)
     *
     * @OA\Post(
     *     path="/api/forgot-password",
     *     summary="Reset password using OTP",
     *     tags={"Auth"},
     *     @OA\RequestBody(
     *         required=true,
     *         @OA\JsonContent(
     *             required={"mobile", "password_reset_token", "new_password"},
     *             @OA\Property(property="mobile", type="string", example="9876543210", description="User's registered mobile number"),
     *             @OA\Property(property="password_reset_token", type="string", example="abcdef123456", description="Password reset token sent via OTP"),
     *             @OA\Property(property="new_password", type="string", example="Password123!", description="Min 8 chars; letter (any script), number, symbol")
     *         )
     *     ),
     *     @OA\Response(
     *         response=200,
     *         description="Password reset successful",
     *         @OA\JsonContent(
     *             @OA\Property(property="success", type="boolean", example=true),
     *             @OA\Property(property="message", type="string", example="Password reset successful")
     *         )
     *     ),
     *     @OA\Response(
     *         response=400,
     *         description="Invalid or expired password reset token",
     *         @OA\JsonContent(
     *             @OA\Property(property="success", type="boolean", example=false),
     *             @OA\Property(property="message", type="string", example="Invalid or expired password reset token")
     *         )
     *     ),
     *     @OA\Response(
     *         response=404,
     *         description="User not found",
     *         @OA\JsonContent(
     *             @OA\Property(property="success", type="boolean", example=false),
     *             @OA\Property(property="message", type="string", example="User not found")
     *         )
     *     ),
     *     @OA\Response(
     *         response=422,
     *         description="Validation error",
     *         @OA\JsonContent(
     *             @OA\Property(property="success", type="boolean", example=false),
     *             @OA\Property(property="message", type="string", example="The given data was invalid."),
     *             @OA\Property(property="errors", type="object")
     *         )
     *     )
     * )
     */
    public function forgotPassword(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'mobile' => 'required|exists:users,mobile',
            'password_reset_token' => 'required|string',
            'new_password' => ['required', new UnicodeStrongPassword],
        ]);
        if ($validator->fails()) {
            return $this->validationErrorResponse($validator->errors());
        }
        $user = User::where('mobile', $request->mobile)->first();
        if (!$user) {
            return $this->notFoundResponse('User not found');
        }
        if ($user->remember_token !== $request->password_reset_token) {
            return $this->errorResponse('Invalid or expired password reset token', 400);
        }
        $user->password = Hash::make($request->new_password);
        $user->remember_token = null; // Clear after use
        $user->save();
        return $this->successResponse(null, 'Password reset successful');
    }
}