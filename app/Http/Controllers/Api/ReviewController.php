<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Api\Controller;
use App\Models\Review;
use App\Models\Product;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\Auth;
use App\Models\OrderItem;
use App\Models\Order;

/**
 * @OA\Schema(
 *   schema="Review",
 *   type="object",
 *   @OA\Property(property="id", type="integer"),
 *   @OA\Property(property="user_id", type="integer"),
 *   @OA\Property(property="product_id", type="integer"),
 *   @OA\Property(property="rating", type="integer", minimum=1, maximum=5),
 *   @OA\Property(property="comment", type="string"),
 *   @OA\Property(property="status", type="string"),
 *   @OA\Property(property="created_at", type="string", format="date-time"),
 *   @OA\Property(property="updated_at", type="string", format="date-time"),
 *   @OA\Property(property="user", type="object"),
 *   @OA\Property(property="product", type="object")
 * )
 */

class ReviewController extends Controller
{
    /**
     * @OA\Get(
     *     path="/api/reviews/product/{productId}",
     *     summary="Get product reviews",
     *     tags={"Reviews"},
     *     @OA\Parameter(
     *         name="productId",
     *         in="path",
     *         required=true,
     *         @OA\Schema(type="integer")
     *     ),
     *     @OA\Response(
     *         response=200,
     *         description="List of product reviews",
     *         @OA\JsonContent(
     *             type="object",
     *             @OA\Property(property="success", type="boolean"),
     *             @OA\Property(property="data", type="array", @OA\Items(ref="#/components/schemas/Review")),
     *             @OA\Property(property="message", type="string")
     *         )
     *     )
     * )
     */
    public function productReviews($productId)
    {
        $reviews = Review::where('product_id', $productId)
            ->where('deleted_at', null)
            ->where('status', 'approved')
            ->with(['user:id,full_name'])
            ->orderBy('created_at', 'desc')
            ->get();
        
            return $this->successResponse($reviews);
    }

    /**
     * @OA\Get(
     *     path="/api/reviews",
     *     summary="Get user reviews",
     *     tags={"Reviews"},
     *     security={{"bearerAuth":{}}},
     *     @OA\Response(
     *         response=200,
     *         description="List of user reviews",
     *         @OA\JsonContent(
     *             type="object",
     *             @OA\Property(property="success", type="boolean"),
     *             @OA\Property(property="data", type="array", @OA\Items(ref="#/components/schemas/Review")),
     *             @OA\Property(property="message", type="string")
     *         )
     *     )
     * )
     */
    public function index()
    {
        $reviews = Review::where('user_id', Auth::id()) 
            ->where('deleted_at', null)
            ->with(['product:id,name_en,name_ar'])
            ->orderBy('created_at', 'desc')
            ->paginate(10);
            
        return $this->successResponse($reviews);
    }

    /**
     * @OA\Get(
     *     path="/api/reviews/{id}",
     *     summary="Get specific review",
     *     tags={"Reviews"},
     *     security={{"bearerAuth":{}}},
     *     @OA\Parameter(
     *         name="id",
     *         in="path",
     *         required=true,
     *         @OA\Schema(type="integer")
     *     ),
     *     @OA\Response(
     *         response=200,
     *         description="Review details",
     *         @OA\JsonContent(
     *             type="object",
     *             @OA\Property(property="success", type="boolean"),
     *             @OA\Property(property="data", ref="#/components/schemas/Review"),
     *             @OA\Property(property="message", type="string")
     *         )
     *     ),
     *     @OA\Response(
     *         response=404,
     *         description="Review not found"
     *     )
     * )
     */
    public function show($id)
    {
        $review = Review::where('user_id', Auth::id())
            ->where('deleted_at', null)
            ->with(['product:id,name_en,name_ar'])
            ->find($id);
            
        if (!$review) {
            return $this->errorResponse('Review not found', 404);
        }
        
        return $this->successResponse($review);
    }

    /**
     * @OA\Post(
     *     path="/api/reviews",
     *     summary="Create a new review",
     *     tags={"Reviews"},
     *     security={{"bearerAuth":{}}},
     *     @OA\RequestBody(
     *         required=true,
     *         @OA\JsonContent(
     *             required={"product_id", "rating"},
     *             @OA\Property(property="product_id", type="integer"),
     *             @OA\Property(property="rating", type="integer", minimum=1, maximum=5),
     *             @OA\Property(property="comment", type="string")
     *         )
     *     ),
     *     @OA\Response(
     *         response=201,
     *         description="Review created successfully",
     *         @OA\JsonContent(
     *             type="object",
     *             @OA\Property(property="success", type="boolean"),
     *             @OA\Property(property="data", ref="#/components/schemas/Review"),
     *             @OA\Property(property="message", type="string")
     *         )
     *     ),
     *     @OA\Response(
     *         response=422,
     *         description="Validation error"
     *     )
     * )
     */
    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'product_id' => 'required|exists:products,id',
            'rating' => 'required|integer|min:1|max:5',
            'comment' => 'nullable|string|max:1000'
        ]);

        if ($validator->fails()) {
            return $this->errorResponse($validator->errors(), 422);
        }

        // Check if user already reviewed this product
        $existingReview = Review::where('user_id', Auth::id())
            ->where('product_id', $request->product_id)
            ->where('deleted_at', null)
            ->first();

        if ($existingReview) {
            return $this->errorResponse('You have already reviewed this product', 422);
        }

        $review = Review::create([
            'user_id' => Auth::id(),
            'product_id' => $request->product_id,
            'rating' => $request->rating,
            'note' => $request->comment,
            'status' => 'approved'
        ]);

        $review->load(['product:id,name_en,name_ar']);

        return $this->successResponse($review, 'Review created successfully', 201);
    }

    /**
     * @OA\Put(
     *     path="/api/reviews/{id}",
     *     summary="Update a review",
     *     tags={"Reviews"},
     *     security={{"bearerAuth":{}}},
     *     @OA\Parameter(
     *         name="id",
     *         in="path",
     *         required=true,
     *         @OA\Schema(type="integer")
     *     ),
     *     @OA\RequestBody(
     *         required=true,
     *         @OA\JsonContent(
     *             @OA\Property(property="rating", type="integer", minimum=1, maximum=5),
     *             @OA\Property(property="comment", type="string")
     *         )
     *     ),
     *     @OA\Response(
     *         response=200,
     *         description="Review updated successfully",
     *         @OA\JsonContent(
     *             type="object",
     *             @OA\Property(property="success", type="boolean"),
     *             @OA\Property(property="data", ref="#/components/schemas/Review"),
     *             @OA\Property(property="message", type="string")
     *         )
     *     ),
     *     @OA\Response(
     *         response=404,
     *         description="Review not found"
     *     )
     * )
     */
    public function update(Request $request, $id)
    {
        $review = Review::where('user_id', Auth::id())->where('deleted_at', null)->find($id);
        
        if (!$review) {
            return $this->errorResponse('Review not found', 404);
        }

        $validator = Validator::make($request->all(), [
            'rating' => 'sometimes|integer|min:1|max:5',
            'note' => 'nullable|string|max:1000'
        ]);

        if ($validator->fails()) {
            return $this->errorResponse($validator->errors(), 422);
        }

        $review->update($request->only(['rating', 'comment']));
        $review->load(['product:id,name_en,name_ar']);

        return $this->successResponse($review, 'Review updated successfully');
    }

    /**
     * @OA\Delete(
     *     path="/api/reviews/{id}",
     *     summary="Delete a review",
     *     tags={"Reviews"},
     *     security={{"bearerAuth":{}}},
     *     @OA\Parameter(
     *         name="id",
     *         in="path",
     *         required=true,
     *         @OA\Schema(type="integer")
     *     ),
     *     @OA\Response(
     *         response=200,
     *         description="Review deleted successfully",
     *         @OA\JsonContent(
     *             type="object",
     *             @OA\Property(property="success", type="boolean"),
     *             @OA\Property(property="message", type="string")
     *         )
     *     ),
     *     @OA\Response(
     *         response=404,
     *         description="Review not found"
     *     )
     * )
     */
    public function destroy($id)
    {
        $review = Review::where('user_id', Auth::id())->where('deleted_at', null)->find($id);
        
        if (!$review) {
            return $this->errorResponse('Review not found', 404);
        }

        $review->delete();

        return $this->successResponse(null, 'Review deleted successfully');
    }

    /**
     * Submit review for multiple order items (same review for each)
     * Endpoint: POST /order-items/review
     * Body: { "order_item_ids": [1,2], "rating": 5, "comment": "Great!" }
     */
    public function reviewOrderItems(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'order_item_ids' => 'required|array|min:1',
            'order_item_ids.*' => 'required|integer|exists:order_items,id',
            'rating' => 'required|integer|min:1|max:5',
            'comment' => 'nullable|string|max:1000',
        ]);

        if ($validator->fails()) {
            return $this->errorResponse($validator->errors(), 422);
        }

        $userId = Auth::id();
        $created = [];
        foreach ($request->order_item_ids as $orderItemId) {
            $orderItem = OrderItem::find($orderItemId);
            if (!$orderItem) continue;
            $productId = $orderItem->product_id;
            // Check if review already exists for this user and product
            $existingReview = Review::where('user_id', $userId)
                ->where('product_id', $productId)
                ->where('deleted_at', null)
                ->first();
            if ($existingReview) continue;
            $review = Review::create([
                'user_id' => $userId,
                'product_id' => $productId,
                'rating' => $request->rating,
                'note' => $request->comment,
                'status' => 'approved',
            ]);
            $created[] = $review;
        }
        return $this->successResponse($created, 'Reviews submitted successfully');
    }
    public function orderItemsReviewStatus(Request $request, $order_id)
    {
        $userId = Auth::id();
        $order = Order::where('id', $order_id)
            ->where('deleted_at', null)
            ->where('user_id', $userId)
            ->with(['orderItems.product'])
            ->first();
        if (!$order) {
            return $this->errorResponse('Order not found', 404);
        }
        $result = [];
        foreach ($order->orderItems as $item) {
            $review = Review::where('user_id', $userId)
                ->where('product_id', $item->product_id)
                ->where('deleted_at', null)
                ->first();
            $result[] = [
                'order_item_id' => $item->id,
                'product' => $item->product,
                'reviewed' => $review ? true : false,
                'review' => $review,
            ];
        }
        return $this->successResponse($result, 'Order item review status fetched successfully');
    }
}
