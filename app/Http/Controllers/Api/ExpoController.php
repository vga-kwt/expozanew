<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Api\Controller;
use App\Models\Expo;
use App\Models\Vendor;
use App\Models\Section;
use App\Models\ExpoProductCoupon;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Carbon;

/**
 * @OA\Schema(
 *   schema="Expo",
 *   type="object",
 *   @OA\Property(property="id", type="integer"),
 *   @OA\Property(property="name_en", type="string"),
 *   @OA\Property(property="name_ar", type="string"),
 *   @OA\Property(property="description_en", type="string"),
 *   @OA\Property(property="description_ar", type="string"),
 *   @OA\Property(property="background_color", type="string"),
 *   @OA\Property(property="background_image", type="string"),
 *   @OA\Property(property="font_family", type="string"),
 *   @OA\Property(property="font_color", type="string"),
 *   @OA\Property(property="font_style", type="string"),
 *   @OA\Property(property="font_size", type="string"),
 *   @OA\Property(property="font_weight", type="string"),
 *   @OA\Property(property="banner_image", type="string"),
 *   @OA\Property(property="start_date", type="string", format="date"),
 *   @OA\Property(property="end_date", type="string", format="date"),
 *   @OA\Property(property="status", type="string"),
 *   @OA\Property(property="created_at", type="string", format="date-time"),
 *   @OA\Property(property="updated_at", type="string", format="date-time"),
 *   @OA\Property(property="vendor_slot_capacity", type="integer"),
 *   @OA\Property(property="product_capacity_per_slot", type="integer"),
 *   @OA\Property(property="slot_pricing", type="string")
 * )
 */

class ExpoController extends Controller
{


    /**
     * @OA\Get(
     *     path="/api/expos/active",
     *     summary="Get all active expos",
     *     tags={"Expo"},
     *     @OA\Response(
     *         response=200,
     *         description="A list of active expos",
     *         @OA\JsonContent(
     *             type="object",
     *             @OA\Property(property="success", type="boolean"),
     *             @OA\Property(property="data", type="array", @OA\Items(ref="#/components/schemas/Expo")),
     *             @OA\Property(property="message", type="string")
     *         )
     *     )
     * )
     */
    public function activeExpos()
    {
        $activeExpos = Expo::where('status', 'active')
        ->where('deleted_at', null)
            ->get();
        return $this->successResponse($activeExpos);
    }

    /**
     * @OA\Get(
     *     path="/api/expos/upcoming",
     *     summary="Get all upcoming expos",
     *     tags={"Expo"},
     *     @OA\Response(
     *         response=200,
     *         description="A list of upcoming expos",
     *         @OA\JsonContent(
     *             type="object",
     *             @OA\Property(property="success", type="boolean"),
     *             @OA\Property(property="data", type="array", @OA\Items(ref="#/components/schemas/Expo")),
     *             @OA\Property(property="message", type="string")
     *         )
     *     )
     * )
     */
    public function upcomingExpos()
    {
        $upcomingExpos = Expo::where('status', 'upcoming')
        ->where('deleted_at', null)
                ->get();
        return $this->successResponse($upcomingExpos);
    }

    /**
     * @OA\Get(
     *     path="/api/expo-details/{expoId}",
     *     summary="Get expo details with reviews",
     *     tags={"Expo"},
     *     @OA\Parameter(
     *         name="expoId",
     *         in="path",
     *         required=true,
     *         @OA\Schema(type="integer")
     *     ),
     *     @OA\Response(
     *         response=200,
     *         description="Expo details with reviews",
     *         @OA\JsonContent(
     *             type="object",
     *             @OA\Property(property="success", type="boolean"),
     *             @OA\Property(property="data", ref="#/components/schemas/Expo"),
     *             @OA\Property(property="message", type="string")
     *         )
     *     ),
     *     @OA\Response(
     *         response=404,
     *         description="Expo not found"
     *     )
     * )
     */
    public function details($expoId)
    {
        $expo = Expo::with(['vendors'])->where('deleted_at', null)->find($expoId);
        
        if (!$expo) {
            return $this->errorResponse('Expo not found', 404);
        }
        
        return $this->successResponse($expo);
    }
}
