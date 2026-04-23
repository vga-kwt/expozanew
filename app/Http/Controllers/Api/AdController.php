<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Api\Controller;
use App\Models\Ad;
use Illuminate\Http\Request;

/**
 * @OA\Schema(
 *   schema="Ad",
 *   type="object",
 *   @OA\Property(property="id", type="integer"),
 *   @OA\Property(property="title", type="string"),
 *   @OA\Property(property="description", type="string"),
 *   @OA\Property(property="image_url", type="string"),
 *   @OA\Property(property="link_url", type="string"),
 *   @OA\Property(property="type", type="string"),
 *   @OA\Property(property="status", type="string"),
 *   @OA\Property(property="start_date", type="string", format="date"),
 *   @OA\Property(property="end_date", type="string", format="date"),
 *   @OA\Property(property="created_at", type="string", format="date-time"),
 *   @OA\Property(property="updated_at", type="string", format="date-time")
 * )
 */

class AdController extends Controller
{
    /**
     * @OA\Get(
     *     path="/api/banner-ads",
     *     summary="Get all active banner ads",
     *     tags={"Ads"},
     *     @OA\Response(
     *         response=200,
     *         description="A list of active banner ads",
     *         @OA\JsonContent(
     *             type="object",
     *             @OA\Property(property="success", type="boolean"),
     *             @OA\Property(property="data", type="array", @OA\Items(ref="#/components/schemas/Ad")),
     *             @OA\Property(property="message", type="string")
     *         )
     *     )
     * )
     */
    public function activeBannerAds()
    {
        $bannerAds = Ad::with(['product', 'vendor', 'linkedVendor'])->where('status', 'active')
            ->where('start_date', '<=', now())
            ->where('end_date', '>=', now())
            ->orderBy('created_at', 'desc')
            ->where('deleted_at', null)
            ->get();
        
        // Transformation is now handled automatically in the models (Ad, Product, Vendor)
        // via their toArray() methods, so no manual transformation needed here
        return $this->successResponse($bannerAds);
    }
}
