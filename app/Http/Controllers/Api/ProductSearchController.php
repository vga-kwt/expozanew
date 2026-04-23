<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Api\Controller;
use App\Models\Expo;
use App\Models\ExpoProduct;
use App\Models\Product;
use Illuminate\Http\Request;

class ProductSearchController extends Controller
{
    /**
     * Search products with pagination.
     * Only returns products that are part of an active expo.
     * Products in inactive/upcoming expos or not in any expo are hidden.
     *
     * @OA\Get(
     *     path="/api/search/products",
     *     summary="Search products with pagination",
     *     tags={"Products"},
     *     @OA\Parameter(
     *         name="q",
     *         in="query",
     *         required=false,
     *         @OA\Schema(type="string")
     *     ),
     *     @OA\Parameter(
     *         name="category_id",
     *         in="query",
     *         required=false,
     *         @OA\Schema(type="integer")
     *     ),
     *     @OA\Parameter(
     *         name="page",
     *         in="query",
     *         required=false,
     *         @OA\Schema(type="integer")
     *     ),
     *     @OA\Parameter(
     *         name="per_page",
     *         in="query",
     *         required=false,
     *         @OA\Schema(type="integer")
     *     ),
     *     @OA\Response(
     *         response=200,
     *         description="Paginated product search results"
     *     )
     * )
     */
    public function search(Request $request)
    {
        $activeExpoIds = Expo::where('status', 'active')->pluck('id');
        $productIdsInActiveExpos = ExpoProduct::whereIn('expo_id', $activeExpoIds)->pluck('product_id')->unique()->values();

        $query = Product::with(['vendor', 'category'])
            ->whereNull('deleted_at')
            ->whereIn('id', $productIdsInActiveExpos);

        if ($request->has('search') && $request->search) {
            $search = $request->search;
            $query->where(function ($q) use ($search) {
                $q->where('name_en', 'like', "%{$search}%")
                  ->orWhere('name_ar', 'like', "%{$search}%")
                  ->orWhere('attributes', 'like', "%{$search}%")
                  ->orWhere('sale_price', 'like', "%{$search}%")
                  ->orWhere('description_en', 'like', "%{$search}%")
                  ->orWhere('description_ar', 'like', "%{$search}%");
            });
        }
        if ($request->has('category_id') && $request->category_id) {
            $query->where('category_id', $request->category_id);
        }

        $page = (int) $request->input('page', 1);
        $perPage = (int) $request->input('per_page', 15);
        $perPage = min(max($perPage, 1), 100);

        $products = $query->orderByDesc('created_at')->skip(($page - 1) * $perPage)->take($perPage)->get();

        return response()->json([
            'success' => true,
            'message' => 'Products search results',
            'data' => $products,
        ]);
    }
}
