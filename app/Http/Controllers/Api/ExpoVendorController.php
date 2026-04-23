<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Expo;
use App\Models\ExpoVendor;
use App\Models\SlotBooking;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

/**
 * @OA\Schema(
 *   schema="ExpoVendor",
 *   type="object",
 *   @OA\Property(property="id", type="integer"),
 *   @OA\Property(property="expo_id", type="integer"),
 *   @OA\Property(property="vendor_id", type="integer"),
 *   @OA\Property(property="vendor_name", type="string"),
 *   @OA\Property(property="logo_url", type="string"),
 *   @OA\Property(property="is_premium", type="boolean"),
 *   @OA\Property(property="booth_number", type="string"),
 *   @OA\Property(property="status", type="string"),
 *   @OA\Property(property="created_at", type="string", format="date-time"),
 *   @OA\Property(property="updated_at", type="string", format="date-time")
 * )
 */

class ExpoVendorController extends Controller
{
    /**
     * @OA\Get(
     *     path="/api/expo-vendors/{expoId}",
     *     summary="Get expo vendors list with logo",
     *     tags={"Expo Vendors"},
     *     @OA\Parameter(
     *         name="expoId",
     *         in="path",
     *         required=true,
     *         @OA\Schema(type="integer")
     *     ),
     *     @OA\Response(
     *         response=200,
     *         description="List of expo vendors",
     *         @OA\JsonContent(
     *             type="object",
     *             @OA\Property(property="success", type="boolean"),
     *             @OA\Property(property="data", type="array", @OA\Items(ref="#/components/schemas/ExpoVendor")),
     *             @OA\Property(property="message", type="string")
     *         )
     *     )
     * )
     */
    public function index(Request $request, $expoId)
    {
        $userId = $request->user()->id ?? null;

        // Base query
        $query = ExpoVendor::with(['vendor.categories', 'vendor.products'])
            ->where('deleted_at', null)
            ->where('expo_id', $expoId);

        // 🔍 Vendor name search
        if ($request->filled('search')) {
            $searchTerm = $request->input('search');
            $query->whereHas('vendor', function ($q) use ($searchTerm) {
                $q->where('name', 'like', "%{$searchTerm}%");
            });
        }

        // Sorting
        $sortBy = $request->input('sort_by');

        if ($sortBy === 'alphabetic') {
            $query->join('vendors', 'expo_vendor.vendor_id', '=', 'vendors.id')
                ->orderBy('vendors.name', 'asc')
                ->select('expo_vendor.*');
        } elseif ($sortBy === 'number_of_products') {
            $query->join('vendors', 'expo_vendor.vendor_id', '=', 'vendors.id')
                ->join('products', 'vendors.id', '=', 'products.vendor_id')
                ->select('expo_vendor.*', DB::raw('MAX(products.sale_price) as max_price'))
                ->groupBy('expo_vendor.id')
                ->orderBy('max_price', 'desc');
        } elseif ($sortBy === 'favourites' && $userId) {
            $query->join('favourite_vendors', function ($join) use ($userId) {
                $join->on('expo_vendor.vendor_id', '=', 'favourite_vendors.vendor_id')
                    ->where('favourite_vendors.user_id', '=', $userId);
            })
                ->select('expo_vendor.*', 'favourite_vendors.created_at as fav_date')
                ->orderBy('fav_date', 'desc');
        } elseif ($sortBy === 'all') {
            $query->join('vendors', 'expo_vendor.vendor_id', '=', 'vendors.id')
                ->select('expo_vendor.*')
                ->orderBy('expo_vendor.id', 'desc');
        }

        // Price filtering
        $minPrice = $request->input('min_price');
        if ($minPrice !== null) {
            $query->whereHas('vendor.products', function ($q) use ($minPrice) {
                $q->where('sale_price', '>=', $minPrice);
            });
        }

        $maxPrice = $request->input('max_price');
        if ($maxPrice !== null) {
            $query->whereHas('vendor.products', function ($q) use ($maxPrice) {
                $q->where('sale_price', '<=', $maxPrice);
            });
        }

        // Pagination
        $perPage = $request->input('per_page', 10);
        $vendors = $query->paginate($perPage);

        // Transform data
        $data = $vendors->getCollection()->map(function ($expoVendor) {
            return [
                'id' => $expoVendor->id,
                'vendor' => $expoVendor->vendor,
                'products_count' => $expoVendor->vendor ? $expoVendor->vendor->products->count() : 0,
            ];
        });

        return response()->json([
            'success' => true,
            'data' => $data,
            'pagination' => [
                'total' => $vendors->total(),
                'per_page' => $vendors->perPage(),
                'current_page' => $vendors->currentPage(),
                'last_page' => $vendors->lastPage(),
                'from' => $vendors->firstItem(),
                'to' => $vendors->lastItem()
            ]
        ]);
    }





    /**
     * @OA\Get(
     *     path="/api/expo-featured-vendors/{expoId}",
     *     summary="Get premium expo vendors list",
     *     tags={"Expo Vendors"},
     *     @OA\Parameter(
     *         name="expoId",
     *         in="path",
     *         required=true,
     *         @OA\Schema(type="integer")
     *     ),
     *     @OA\Response(
     *         response=200,
     *         description="List of premium expo vendors",
     *         @OA\JsonContent(
     *             type="object",
     *             @OA\Property(property="success", type="boolean"),
     *             @OA\Property(property="data", type="array", @OA\Items(ref="#/components/schemas/ExpoVendor")),
     *             @OA\Property(property="message", type="string")
     *         )
     *     )
     * )
     */
    public function featuredVendors(Request $request, $expoId)
    {
        $featuredVendors = ExpoVendor::where('expo_id', $expoId)
            ->where('deleted_at', null)
            ->with(['vendor.categories'])
            ->orderBy('created_at', 'desc')
            ->paginate(10);

        $data = $featuredVendors->getCollection()->transform(function ($expoVendor) {
            $vendor = $expoVendor->vendor;
            return [
                'id' => $expoVendor->id,
                'vendor' => $vendor,
            ];
        });

        return response()->json([
            'success' => true,
            'data' => $data,
            'pagination' => [
                'total' => $featuredVendors->total(),
                'per_page' => $featuredVendors->perPage(),
                'current_page' => $featuredVendors->currentPage(),
                'last_page' => $featuredVendors->lastPage(),
                'from' => $featuredVendors->firstItem(),
                'to' => $featuredVendors->lastItem()
            ]
        ]);
    }
}
