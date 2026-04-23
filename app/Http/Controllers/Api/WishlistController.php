<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Api\Controller;
use App\Models\Wishlist;
use App\Models\Product;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class WishlistController extends Controller
{
    /**
     * List all wishlist products for authenticated user
     *
     * @OA\Get(
     *     path="/api/wishlist",
     *     summary="List all wishlist products for authenticated user",
     *     tags={"Wishlist"},
     *     security={{"sanctum":{}}},
     *     @OA\Response(
     *         response=200,
     *         description="List of wishlist products",
     *         @OA\JsonContent(
     *             type="object",
     *             @OA\Property(property="success", type="boolean", example=true),
     *             @OA\Property(property="data", type="array",
     *                 @OA\Items(
     *                     @OA\Property(property="wishlist_id", type="integer", example=1, description="Wishlist item ID"),
     *                     @OA\Property(property="id", type="integer", example=1, description="Product ID"),
     *                     @OA\Property(property="name_en", type="string", example="Product Name EN"),
     *                     @OA\Property(property="name_ar", type="string", example="Product Name AR"),
     *                     @OA\Property(property="image", type="string", example="/images/product.jpg"),
     *                     @OA\Property(property="regular_price", type="number", format="float", example=100),
     *                     @OA\Property(property="sale_price", type="number", format="float", example=80),
     *                     @OA\Property(property="discount", type="number", format="float", example=20),
     *                     @OA\Property(property="status", type="string", example="available"),
     *                     @OA\Property(property="product", type="object")
     *                 )
     *             )
     *         )
     *     )
     * )
     */
    public function index(Request $request)
    {
        $perPage = 10;
        $wishlistQuery = Wishlist::with('product')
            ->where('deleted_at', null)
            ->where('user_id', $request->user()->id);

        $paginated = $wishlistQuery->paginate($perPage);

        $wishlistItems = collect($paginated->items())
            ->map(function ($item) {
                $product = $item->product;
                if (!$product) {
                    return null;
                }

                // Handle images (decode JSON if needed)
                $images = null;
                if (is_string($product->images)) {
                    $decoded = json_decode($product->images, true);
                    if (is_array($decoded)) {
                        $images = $decoded;
                    }
                }

                // Remove vendor if present in product array
                $productArr = $product->toArray();
                if (isset($productArr['vendor'])) {
                    unset($productArr['vendor']);
                }

                return [
                    'wishlist_id' => $item->id, // Add wishlist id here
                    'id' => $product->id,
                    'name_en' => $product->name_en,
                    'name_ar' => $product->name_ar,
                    'image' => (is_array($images) && isset($images[0]) && is_string($images[0])) ? $images[0] : null,
                    'regular_price' => $product->regular_price ?? null,
                    'sale_price' => $product->sale_price ?? null,
                    'discount' => (isset($product->regular_price, $product->sale_price) && $product->regular_price > 0)
                        ? round($product->regular_price - $product->sale_price, 2)
                        : 0,
                    'status' => $product->status === 'active' ? 'available' : 'not_available',
                    'product' => $productArr,
                ];
            })
            ->filter() // Remove nulls if any product is missing
            ->values();

            $response = [
                'success' => true,
                'message' => 'Wishlist items retrieved successfully',
                'data' => $wishlistItems,
                'current_page' => $paginated->currentPage(),
                'last_page' => $paginated->lastPage(),
                'per_page' => $paginated->perPage(),
                'total' => $paginated->total(),
            ];
    

         return response()->json( $response);
    }

    /**
     * Add product to wishlist
     *
     * @OA\Post(
     *     path="/api/wishlist",
     *     summary="Add product to wishlist",
     *     tags={"Wishlist"},
     *     security={{"sanctum":{}}},
     *     @OA\RequestBody(
     *         required=true,
     *         @OA\JsonContent(
     *             required={"product_id"},
     *             @OA\Property(property="product_id", type="integer", example=1)
     *         )
     *     ),
     *     @OA\Response(
     *         response=201,
     *         description="Product added to wishlist",
     *         @OA\JsonContent(
     *             type="object",
     *             @OA\Property(property="success", type="boolean", example=true),
     *             @OA\Property(property="data", type="object",
     *                 @OA\Property(property="id", type="integer", example=1),
     *                 @OA\Property(property="product_id", type="integer", example=1),
     *                 @OA\Property(property="user_id", type="integer", example=2),
     *                 @OA\Property(property="product", type="object"),
     *                 @OA\Property(property="added_at", type="string", format="date-time", example="2024-06-27T12:00:00Z")
     *             ),
     *             @OA\Property(property="message", type="string", example="Product added to wishlist")
     *         )
     *     ),
     *     @OA\Response(
     *         response=409,
     *         description="Product already in wishlist",
     *         @OA\JsonContent(
     *             type="object",
     *             @OA\Property(property="success", type="boolean", example=false),
     *             @OA\Property(property="data", type="object",
     *                 @OA\Property(property="message", type="string", example="Product already in wishlist"),
     *                 @OA\Property(property="product_id", type="integer", example=1),
     *                 @OA\Property(property="in_wishlist", type="boolean", example=true)
     *             )
     *         )
     *     )
     * )
     */
    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'product_id' => 'required|exists:products,id',
        ]);
        if ($validator->fails()) {
            return $this->validationErrorResponse($validator->errors());
        }

        $userId = $request->user()->id;
        $productId = $request->product_id;

        $exists = Wishlist::where('user_id', $userId)
            ->where('deleted_at', null)
            ->where('product_id', $productId)
            ->exists();

        if ($exists) {
            return $this->errorResponse([
                'message' => 'Product already in wishlist',
                'product_id' => $productId,
                'in_wishlist' => true
            ], 409);
        }

        $wishlist = Wishlist::create([
            'user_id' => $userId,
            'product_id' => $productId,
        ]);

        // Optionally, return the wishlist item with product details
        $wishlistItem = Wishlist::where('deleted_at', null)->with('product')->find($wishlist->id);

        $responseData = [
            'id' => $wishlistItem->id,
            'product_id' => $wishlistItem->product_id,
            'user_id' => $wishlistItem->user_id,
            'product' => $wishlistItem->product ? [
                'id' => $wishlistItem->product->id,
                'name_en' => $wishlistItem->product->name_en,
                'name_ar' => $wishlistItem->product->name_ar,
                'price' => $wishlistItem->product->sale_price,
                'status' => $wishlistItem->product->status,
            ] : null,
            'added_at' => $wishlistItem->created_at,
        ];

        return $this->successResponse($responseData, 'Product added to wishlist', 201);
    }

    /**
     * Remove product from wishlist
     *
     * @OA\Delete(
     *     path="/api/wishlist/{product_id}",
     *     summary="Remove product from wishlist",
     *     tags={"Wishlist"},
     *     security={{"sanctum":{}}},
     *     @OA\Parameter(
     *         name="product_id",
     *         in="path",
     *         required=true,
     *         description="ID of the product to remove from wishlist",
     *         @OA\Schema(type="integer")
     *     ),
     *     @OA\Response(
     *         response=200,
     *         description="Product removed from wishlist",
     *         @OA\JsonContent(
     *             type="object",
     *             @OA\Property(property="success", type="boolean", example=true),
     *             @OA\Property(property="data", type="object",
     *                 @OA\Property(property="product_id", type="integer", example=1)
     *             ),
     *             @OA\Property(property="message", type="string", example="Product removed from wishlist")
     *         )
     *     ),
     *     @OA\Response(
     *         response=404,
     *         description="Product not in wishlist",
     *         @OA\JsonContent(
     *             type="object",
     *             @OA\Property(property="success", type="boolean", example=false),
     *             @OA\Property(property="message", type="string", example="Product not in wishlist")
     *         )
     *     )
     * )
     */
    public function destroy(Request $request, $product_id)
    {
        $wishlist = Wishlist::where('user_id', $request->user()->id)
            ->where('product_id', $product_id)
            ->where('deleted_at', null)
            ->first();
        if (!$wishlist) {
            return $this->notFoundResponse('Product not in wishlist');
        }
        $wishlist->delete();
        return $this->successResponse(['product_id' => $product_id], 'Product removed from wishlist');
    }

    /**
     * Clear all wishlist items for the authenticated user
     *
     * @OA\Delete(
     *     path="/api/wishlist/clear",
     *     summary="Clear all wishlist items for the authenticated user",
     *     tags={"Wishlist"},
     *     security={{"sanctum":{}}},
     *     @OA\Response(
     *         response=200,
     *         description="Wishlist cleared",
     *         @OA\JsonContent(
     *             type="object",
     *             @OA\Property(property="success", type="boolean", example=true),
     *             @OA\Property(property="data", type="object", nullable=true),
     *             @OA\Property(property="message", type="string", example="Wishlist cleared")
     *         )
     *     )
     * )
     */
    public function clear(Request $request)
    {
        Wishlist::where('user_id', $request->user()->id)->where('deleted_at', null)->delete();
        return $this->successResponse(null, 'Wishlist cleared');
    }

    /**
     * List all wishlist items for authenticated user (simplified view)
     *
     * @OA\Get(
     *     path="/api/all-wishlist",
     *     summary="List all wishlist items for authenticated user (simplified view)",
     *     tags={"Wishlist"},
     *     security={{"sanctum":{}}},
     *     @OA\Response(
     *         response=200,
     *         description="All wishlist items for authenticated user",
     *         @OA\JsonContent(
     *             type="object",
     *             @OA\Property(property="success", type="boolean", example=true),
     *             @OA\Property(property="data", type="array",
     *                 @OA\Items(
     *                     @OA\Property(property="wishlist_id", type="integer", example=1, description="Wishlist item ID"),
     *                     @OA\Property(property="product_id", type="integer", example=1, description="Product ID")
     *                 )
     *             )
     *         )
     *     )
     * )
     */
    public function allWishlist(Request $request)
    {
        $userId = $request->user()->id;

        // Get all wishlist items for the authenticated user, with product relation
        $wishlistItems = Wishlist::with('product')
            ->where('user_id', $userId)
            ->where('deleted_at', null)
                ->get()
            ->map(function ($item) {
                return  $item->product->id;
            });

        return $this->successResponse($wishlistItems);
    }
}
