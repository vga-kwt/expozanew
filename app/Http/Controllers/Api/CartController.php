<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Api\Controller;
use App\Models\Cart;
use App\Models\CartItem;
use App\Models\Product;
use App\Models\User;
use App\Services\CartSnapshotService;
use App\Services\CouponService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class CartController extends Controller
{
    public function __construct(
        private readonly CartSnapshotService $cartSnapshot,
        private readonly CouponService $couponService
    ) {}

    /**
     * @return array<string, mixed>
     */
    private function formatCartResponse(?Cart $cart, ?User $user = null): array
    {
        return $this->cartSnapshot->build($cart, $user);
    }

    /**
     * @OA\Get(
     *     path="/api/cart",
     *     summary="View current cart",
     *     tags={"Cart"},
     *     security={{"sanctum":{}}},
     *     @OA\Response(
     *         response=200,
     *         description="Current cart details"
     *     )
     * )
     */
    public function index(Request $request)
    {
        $cart = Cart::with(['items.product'])
            ->where('user_id', $request->user()->id)
            ->where('status', 'active')
            ->first();

        $cartData = $this->formatCartResponse($cart, $request->user());
        return $this->successResponse($cartData);
    }

    /**
     * @OA\Post(
     *     path="/api/cart/add",
     *     summary="Add product to cart",
     *     tags={"Cart"},
     *     security={{"sanctum":{}}},
     *     @OA\RequestBody(
     *         required=true,
     *         @OA\JsonContent(
     *             required={"product_id", "quantity"},
     *             @OA\Property(property="product_id", type="integer", example=1),
     *             @OA\Property(property="quantity", type="integer", example=2)
     *         )
     *     ),
     *     @OA\Response(
     *         response=201,
     *         description="Product added to cart"
     *     ),
     *     @OA\Response(
     *         response=409,
     *         description="You can only add products from one vendor at a time. Please clear your cart first."
     *     )
     * )
     */

    public function add(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'product_id' => 'required|exists:products,id',
            'quantity' => 'required|integer|min:1',
            'size' => 'nullable|string|max:255',
            'color' => 'nullable|string|max:255',
        ]);
        if ($validator->fails()) {
            return $this->validationErrorResponse($validator->errors());
        }

        $product = Product::find($request->product_id);
        $user = $request->user();
        $cart = Cart::where('user_id', $user->id)->where('status', 'active')->first();

        // Only check vendor_id if cart exists and has items
        if ($cart && $cart->items()->count() > 0 && $cart->vendor_id != $product->vendor_id) {
            return $this->errorResponse('You can only add products from one vendor at a time. Please clear your cart first.', 409);
        }

        if (!$cart) {
            $cart = Cart::create([
                'user_id' => $user->id,
                'vendor_id' => $product->vendor_id,
                'status' => 'active',
            ]);
        }

        // Get variant data from attributes (price, sale_price, size, color)
        // Handle empty strings as null
        $requestSize = !empty($request->size) ? trim($request->size) : null;
        $requestColor = !empty($request->color) ? trim($request->color) : null;

        // Get variant data from attributes
        $variantData = $this->cartSnapshot->getVariantData($product, $requestSize, $requestColor);
        $salePrice = (float) $variantData['sale_price'];
        $regularPrice = (float) $variantData['price'];
        $size = $variantData['size'];
        $color = $variantData['color'];

        // Ensure price is not 0 - if still 0, try to get from product directly or first variant
        if ($salePrice <= 0) {
            // Fallback 1: try product prices directly
            $salePrice = (float) ($product->sale_price ?? $product->regular_price ?? 0);
            $regularPrice = (float) ($product->regular_price ?? $product->sale_price ?? 0);

            // Fallback 2: if product price is also 0, try first variant from attributes
            if ($salePrice <= 0 && $product->attributes && is_array($product->attributes) && !empty($product->attributes)) {
                $firstVariant = $product->attributes[0];
                if (isset($firstVariant['price']) || isset($firstVariant['sale_price'])) {
                    $salePrice = (float) ($firstVariant['sale_price'] ?? $firstVariant['price'] ?? 0);
                    $regularPrice = (float) ($firstVariant['price'] ?? $firstVariant['sale_price'] ?? 0);

                    // Update color and size from first variant if not set
                    if (!$color && isset($firstVariant['color'])) {
                        $color = $firstVariant['color'];
                    }
                    if (!$size && isset($firstVariant['sizeStockPairs']) && is_array($firstVariant['sizeStockPairs']) && !empty($firstVariant['sizeStockPairs'])) {
                        $size = $firstVariant['sizeStockPairs'][0]['size'] ?? null;
                    }
                }
            }

            if ($salePrice <= 0) {
                return $this->errorResponse('Product price is not available. Please contact support.', 400);
            }
        }

        $discount = $regularPrice > 0 && $regularPrice > $salePrice ? ($regularPrice - $salePrice) : 0;

        // Check if same variant already exists in cart (handle NULL values properly)
        $cartItemQuery = $cart->items()->where('product_id', $product->id);

        if ($size !== null) {
            $cartItemQuery->where('size', $size);
        } else {
            $cartItemQuery->whereNull('size');
        }

        if ($color !== null) {
            $cartItemQuery->where('color', $color);
        } else {
            $cartItemQuery->whereNull('color');
        }

        $cartItem = $cartItemQuery->first();

        if ($cartItem) {
            $cartItem->quantity += $request->quantity;
            $cartItem->price = $salePrice * $cartItem->quantity;
            // Update size and color if they were not set before
            if ($size && !$cartItem->size) {
                $cartItem->size = $size;
            }
            if ($color && !$cartItem->color) {
                $cartItem->color = $color;
            }
            $cartItem->save();
        } else {
            $cartItem = $cart->items()->create([
                'product_id' => $product->id,
                'quantity' => $request->quantity,
                'price' => $salePrice * $request->quantity,
                'size' => $size ?: null, // Convert empty string to null
                'color' => $color ?: null, // Convert empty string to null
            ]);
        }

        // Reload cart with all items to return full cart response
        $cart->refresh();
        $cartData = $this->formatCartResponse($cart, $user);

        return $this->successResponse($cartData, 'Product added to cart', 201);
    }

    /**
     * @OA\Post(
     *     path="/api/cart/update/{id}",
     *     summary="Update cart item quantity",
     *     tags={"Cart"},
     *     security={{"sanctum":{}}},
     *     @OA\Parameter(
     *         name="id",
     *         in="path",
     *         required=true,
     *         description="Cart ID",
     *         @OA\Schema(type="integer")
     *     ),
     *     @OA\RequestBody(
     *         required=true,
     *         @OA\JsonContent(
     *             required={"product_id", "quantity"},
     *             @OA\Property(property="product_id", type="integer", example=1),
     *             @OA\Property(property="quantity", type="integer", example=3),
     *             @OA\Property(property="size", type="string", example="M"),
     *             @OA\Property(property="color", type="string", example="RED")
     *         )
     *     ),
     *     @OA\Response(
     *         response=200,
     *         description="Cart updated"
     *     ),
     *     @OA\Response(
     *         response=404,
     *         description="Cart not found or Product variant not in cart"
     *     )
     * )
     */
    public function update(Request $request, $id)
    {
        $validator = Validator::make($request->all(), [
            'product_id' => 'required|exists:products,id',
            'quantity' => 'required|integer|min:1',
            'size' => 'nullable|string|max:255',
            'color' => 'nullable|string|max:255',
        ]);
        if ($validator->fails()) {
            return $this->validationErrorResponse($validator->errors());
        }

        $cart = Cart::where('id', $id)
            ->where('user_id', $request->user()->id)
            ->where('status', 'active')
            ->first();

        if (!$cart) {
            return $this->notFoundResponse('Cart not found');
        }

        // Handle empty strings as null, similar to add method
        $requestSize = !empty($request->size) ? trim($request->size) : null;
        $requestColor = !empty($request->color) ? trim($request->color) : null;

        // Find cart item by product_id AND variant (size/color), similar to add method
        $cartItemQuery = $cart->items()->where('product_id', $request->product_id);

        if ($requestSize !== null) {
            $cartItemQuery->where('size', $requestSize);
        } else {
            $cartItemQuery->whereNull('size');
        }

        if ($requestColor !== null) {
            $cartItemQuery->where('color', $requestColor);
        } else {
            $cartItemQuery->whereNull('color');
        }

        $cartItem = $cartItemQuery->first();

        if (!$cartItem) {
            return $this->notFoundResponse('Product variant not in cart');
        }

        $cartItem->quantity = $request->quantity;

        // Reload cart item with product relationship
        $cartItem->load('product');
        $product = $cartItem->product;

        if (!$product) {
            return $this->errorResponse('Product is no longer available.', 400);
        }

        // Get variant price from attributes
        $variantData = $this->cartSnapshot->getVariantData($product, $cartItem->size, $cartItem->color);
        $cartItem->price = $variantData['sale_price'] * $request->quantity;
        $cartItem->save();

        // Reload cart with all items to return full cart response
        $cart->refresh();
        $cartData = $this->formatCartResponse($cart, $request->user());

        return $this->successResponse($cartData, 'Cart updated');
    }

    /**
     * @OA\Post(
     *     path="/api/cart/remove/{id}",
     *     summary="Remove product from cart",
     *     tags={"Cart"},
     *     security={{"sanctum":{}}},
     *     @OA\Parameter(
     *         name="id",
     *         in="path",
     *         required=true,
     *         description="Cart Item ID",
     *         @OA\Schema(type="integer")
     *     ),
     *     @OA\Response(
     *         response=200,
     *         description="Product removed from cart"
     *     ),
     *     @OA\Response(
     *         response=404,
     *         description="Cart item not found"
     *     )
     * )
     */
    public function remove(Request $request, $id)
    {
        // $id is the cart item id, not the cart id
        $cartItem = CartItem::where('id', $id)
            ->whereHas('cart', function ($query) use ($request) {
                $query->where('user_id', $request->user()->id)
                    ->where('status', 'active');
            })
            ->first();

        if (!$cartItem) {
            return $this->notFoundResponse('Cart item not found');
        }

        $cartItem->delete();

        // Fetch updated cart items for the user
        $cart = Cart::with(['items.product'])
            ->where('user_id', $request->user()->id)
            ->where('status', 'active')
            ->first();

        $cartData = $this->formatCartResponse($cart, $request->user());
        return $this->successResponse($cartData, 'Product removed from cart', 200);
    }

    /**
     * @OA\Post(
     *     path="/api/cart/clear",
     *     summary="Clear cart",
     *     tags={"Cart"},
     *     security={{"sanctum":{}}},
     *     @OA\Response(
     *         response=200,
     *         description="Cart cleared"
     *     )
     * )
     */
    public function clear(Request $request)
    {
        $cart = Cart::where('user_id', $request->user()->id)->where('status', 'active')->first();

        if ($cart) {
            $cart->items()->delete();
            $cart->delete();
        }
        return $this->successResponse(null, 'Cart cleared');
    }

    public function validateCoupon(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'code' => 'required|string|max:64',
        ]);
        if ($validator->fails()) {
            return $this->validationErrorResponse($validator->errors());
        }

        $user = $request->user();
        $cart = Cart::with(['items.product'])
            ->where('user_id', $user->id)
            ->where('status', 'active')
            ->first();

        if (! $cart || $cart->items->isEmpty()) {
            return $this->errorResponse('Your cart is empty.', 400);
        }

        $coupon = $this->couponService->findByCode($request->input('code'));
        [$ok, $message, $validCoupon] = $this->couponService->validateForUser($coupon, $user);
        if (! $ok || ! $validCoupon) {
            return $this->errorResponse($message ?? 'Invalid coupon.', 422);
        }

        $cart->update([
            'coupon_id' => $validCoupon->id,
            'coupon_code' => $validCoupon->code,
        ]);
        $cart->refresh();

        $cartData = $this->formatCartResponse($cart, $user);

        return $this->successResponse($cartData, 'Coupon applied successfully.');
    }

    public function removeCoupon(Request $request)
    {
        $cart = Cart::where('user_id', $request->user()->id)
            ->where('status', 'active')
            ->first();

        if ($cart) {
            $cart->update([
                'coupon_id' => null,
                'coupon_code' => null,
            ]);
            $cart->refresh();
        }

        $cartData = $this->formatCartResponse($cart, $request->user());

        return $this->successResponse($cartData, 'Coupon removed.');
    }
}