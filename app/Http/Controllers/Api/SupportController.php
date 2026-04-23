<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Api\Controller;
use App\Models\SupportRequest;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class SupportController extends Controller
{
    /**
     * Submit support request (contact us form)
     *
     * @OA\Post(
     *     path="/api/contact-support",
     *     summary="Submit support request (contact us form)",
     *     tags={"Support"},
     *     @OA\RequestBody(
     *         required=true,
     *         @OA\JsonContent(
     *             required={"name", "subject", "message", "contact_info"},
     *             @OA\Property(property="name", type="string", example="John Doe"),
     *             @OA\Property(property="subject", type="string", example="Order Issue"),
     *             @OA\Property(property="message", type="string", example="I have a problem with my order."),
     *             @OA\Property(property="contact_info", type="string", example="user@email.com or 9876543210")
     *         )
     *     ),
     *     @OA\Response(
     *         response=201,
     *         description="Support request submitted"
     *     )
     * )
     */
    public function contact(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'name' => 'required|string|max:255',
            'subject' => 'required|string|max:255',
            'message' => 'required|string',
            'contact_info' => 'required|string|max:255',
        ]);
        if ($validator->fails()) {
            return $this->validationErrorResponse($validator->errors());
        }
        $support = SupportRequest::create([
            'user_id' => $request->user()?->id,
            'name' => $request->name,
            'subject' => $request->subject,
            'message' => $request->message,
            'contact_info' => $request->contact_info,
            'status' => 'pending',
        ]);
        return $this->successResponse($support, 'Support request submitted', 201);
    }
} 