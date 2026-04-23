<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Api\Controller;
use App\Models\User;
use App\Rules\UnicodeStrongPassword;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Storage;

class ProfileController extends Controller
{
    /**
     * Get profile
     * @OA\Get(
     *     path="/api/profile",
     *     summary="Get user profile",
     *     tags={"Profile"},
     *     security={{"sanctum":{}}},
     *     @OA\Response(
     *         response=200,
     *         description="User profile data"
     *     )
     * )
     */
    public function show(Request $request)
    {
        return $this->successResponse($request->user());
    }

    /**
     * Update profile (full_name, image)
     *
     * @OA\Post(
     *     path="/api/profile",
     *     summary="Update user profile",
     *     tags={"Profile"},
     *     security={{"sanctum":{}}},
     *     @OA\RequestBody(
     *         required=true,
     *         @OA\MediaType(
     *             mediaType="multipart/form-data",
     *             @OA\Schema(
     *                 required={},
     *                 @OA\Property(
     *                     property="full_name",
     *                     type="string",
     *                     maxLength=255,
     *                     example="John Doe"
     *                 ),
     *                 @OA\Property(
     *                     property="image",
     *                     type="string",
     *                     format="binary",
     *                     description="Profile image (max 3MB, image file)"
     *                 )
     *             )
     *         )
     *     ),
     *     @OA\Response(
     *         response=200,
     *         description="Profile updated",
     *         @OA\JsonContent(
     *             @OA\Property(property="success", type="boolean", example=true),
     *             @OA\Property(property="message", type="string", example="Profile updated"),
     *             @OA\Property(property="data", type="object",
     *                 @OA\Property(property="id", type="integer", example=1),
     *                 @OA\Property(property="full_name", type="string", example="John Doe"),
     *                 @OA\Property(property="image", type="string", example="profile_images/abc123.jpg"),
     *             )
     *         )
     *     ),
     *     @OA\Response(
     *         response=422,
     *         description="Validation error",
     *         @OA\JsonContent(
     *             @OA\Property(property="success", type="boolean", example=false),
     *             @OA\Property(property="message", type="string", example="Validation error"),
     *             @OA\Property(property="errors", type="object")
     *         )
     *     )
     * )
     */
    public function update(Request $request)
    {
        $user = $request->user();

        $validator = Validator::make($request->all(), [
            'full_name' => 'nullable|string|max:255',
            'image' => 'nullable|image|mimes:jpeg,png,jpg,gif,svg|max:3072', // max 3MB
        ]);

        if ($validator->fails()) {
            return $this->validationErrorResponse($validator->errors());
        }

        $disk = config('filesystems.default', 's3');
        $data = $validator->validated();
        
        // Handle image upload
        if ($request->hasFile('image')) {
            $imagePath = $request->file('image')->store('profile_images', $disk);
            
            // Get full S3 URL instead of just path
            if ($disk === 's3') {
                $data['image'] = Storage::disk('s3')->url($imagePath);
            } else {
                $data['image'] = asset('storage/' . $imagePath);
            }
            
            // Delete old image if needed (extract path from URL if it's a full URL)
            if ($user->image) {
                $oldImagePath = $user->image;
                // If it's a full URL, extract the path
                if (strpos($oldImagePath, 'amazonaws.com/') !== false || strpos($oldImagePath, 'http') === 0) {
                    // Extract path from URL: https://bucket.s3.region.amazonaws.com/path/to/file.png
                    $parsedUrl = parse_url($oldImagePath);
                    $oldImagePath = isset($parsedUrl['path']) ? ltrim($parsedUrl['path'], '/') : $oldImagePath;
                }
                // Try to delete the old image
                try {
                    Storage::disk($disk)->delete($oldImagePath);
                } catch (\Exception $e) {
                    // Log error but don't fail the update
                    Log::warning('Failed to delete old profile image: ' . $e->getMessage());
                }
            }
        }

        $user->update($data);

        // Do not return image path or URL
        $responseData = $user;

        return $this->successResponse($responseData, 'Profile updated');
    }

    /**
     * Send OTP for mobile/password change
     *
     * @OA\Post(
     *     path="/api/profile/send-otp",
     *     summary="Send OTP for mobile or password change",
     *     tags={"Profile"},
     *     security={{"sanctum":{}}},
     *     @OA\RequestBody(
     *         required=true,
     *         @OA\JsonContent(
     *             required={"purpose"},
     *             @OA\Property(property="purpose", type="string", enum={"mobile","password"}),
     *             @OA\Property(property="mobile", type="string", example="98765432")
     *         )
     *     ),
     *     @OA\Response(
     *         response=200,
     *         description="OTP sent successfully (mocked)"
     *     )
     * )
     */
    public function sendOtp(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'purpose' => 'required|in:mobile,password',
            'mobile' => 'required_if:purpose,mobile|digits:8',
        ]);
        if ($validator->fails()) {
            return $this->validationErrorResponse($validator->errors());
        }
        $mobile = $request->purpose === 'mobile' ? $request->mobile : $request->user()->mobile;
        $otp = rand(100000, 999999);
        Cache::put('profile_otp_' . $mobile, $otp, now()->addMinutes(5));
        
        // Send OTP via SMSBox
        $message = "Your OTP is: {$otp}";
        Log::info('Api\ProfileController: Sending OTP via SMS', [
            'phone' => $mobile,
            'message' => $message
        ]);
        $smsSent = send_sms($mobile, $message);
        
        if ($smsSent) {
            return $this->successResponse(null, 'OTP sent successfully');
        } else {
            return $this->successResponse(null, 'OTP sent successfully (SMS service may be unavailable)');
        }
    }

    /**
     * Change mobile (OTP verify)
     *
     * @OA\Post(
     *     path="/api/profile/change-mobile",
     *     summary="Change user mobile (OTP verify)",
     *     tags={"Profile"},
     *     security={{"sanctum":{}}},
     *     @OA\RequestBody(
     *         required=true,
     *         @OA\JsonContent(
     *             required={"mobile", "otp"},
     *             @OA\Property(property="mobile", type="string", example="98765432"),
     *             @OA\Property(property="otp", type="string", example="123456")
     *         )
     *     ),
     *     @OA\Response(
     *         response=200,
     *         description="Mobile updated"
     *     ),
     *     @OA\Response(
     *         response=400,
     *         description="Invalid OTP"
     *     )
     * )
     */
    public function changeMobile(Request $request)
    {
        $user = $request->user();
        $validator = Validator::make($request->all(), [
            'mobile' => 'required|digits:8|unique:users,mobile,' . $user->id,
            'otp' => 'required|digits:6',
        ]);
        if ($validator->fails()) {
            return $this->validationErrorResponse($validator->errors());
        }
        $cachedOtp = Cache::get('profile_otp_' . $request->mobile);
        if ($cachedOtp != $request->otp) {
            return $this->errorResponse('Invalid OTP', 400);
        }
        $user->update(['mobile' => $request->mobile]);
        Cache::forget('profile_otp_' . $request->mobile);
        return $this->successResponse($user, 'Mobile updated');
    }

    /**
     * Change password
     *
     * @OA\Post(
     *     path="/api/profile/change-password",
     *     summary="Change user password",
     *     tags={"Profile"},
     *     security={{"sanctum":{}}},
     *     @OA\RequestBody(
     *         required=true,
     *         @OA\JsonContent(
     *             required={"old_password", "new_password"},
     *             @OA\Property(property="old_password", type="string", example="OldPassword123"),
     *             @OA\Property(property="new_password", type="string", example="NewPassword123")
     *         )
     *     ),
     *     @OA\Response(
     *         response=200,
     *         description="Password updated"
     *     ),
     *     @OA\Response(
     *         response=400,
     *         description="Invalid old password"
     *     )
     * )
     */
    public function changePassword(Request $request)
    {
        $user = $request->user();
        $validator = Validator::make($request->all(), [
            'old_password' => 'required|string',
            'new_password' => ['required', new UnicodeStrongPassword],
        ]);
        if ($validator->fails()) {
            return $this->validationErrorResponse($validator->errors());
        }
        if (!Hash::check($request->old_password, $user->password)) {
            return $this->errorResponse('Invalid old password', 400);
        }
        $user->update(['password' => Hash::make($request->new_password)]);
        return $this->successResponse(null, 'Password updated');
    }

    /**
     * Delete account
     *
     * @OA\Delete(
     *     path="/api/profile",
     *     summary="Delete user account",
     *     tags={"Profile"},
     *     security={{"sanctum":{}}},
     *     @OA\Response(
     *         response=200,
     *         description="Account deleted"
     *     )
     * )
     */
    public function destroy(Request $request)
    {
        $user = $request->user();
        $user->delete();
        return $this->successResponse(null, 'Account deleted');
    }

    /**
     * Change language
     *
     * @OA\Post(
     *     path="/api/profile/change-language",
     *     summary="Change user language",
     *     tags={"Profile"},
     *     security={{"sanctum":{}}},
     *     @OA\RequestBody(
     *         required=true,
     *         @OA\JsonContent(
     *             required={"language"},
     *             @OA\Property(property="language", type="string", enum={"en","ar"})
     *         )
     *     ),
     *     @OA\Response(
     *         response=200,
     *         description="Language updated"
     *     )
     * )
     */
    public function changeLanguage(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'language' => 'required|in:en,ar',
        ]);
    
        if ($validator->fails()) {
            return response()->json([
                'status' => false,
                'errors' => $validator->errors(),
            ], 422);
        }
    
        // Try to get authenticated user
        $user = $request->user();
    
        if ($user) {
            $user->update(['language' => $request->language]);
    
            return response()->json([
                'status' => true,
                'message' => 'Language updated successfully',
                'data' => $user,
            ]);
        }
    
        // If no token/user, just return success without updating
        return response()->json([
            'status' => true,
            'message' => 'Language preference saved (guest)',
        ]);
    }
} 