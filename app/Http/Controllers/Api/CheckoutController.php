<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Api\Controller;
use App\Models\Cart;
use App\Models\CouponUsage;
use App\Models\FinanceTransaction;
use App\Models\Order;
use App\Models\Address;
use App\Services\CartSnapshotService;
use App\Services\InventoryService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\DB;
use App\Models\Notification;

class CheckoutController extends Controller
{
    public function __construct(
        private readonly CartSnapshotService $cartSnapshot
    ) {}

    /**
     * @OA\Post(
     *     path="/api/checkout/confirm",
     *     summary="Create or confirm an order (checkout + payment)",
     *     tags={"Checkout"},
     *     security={{"sanctum":{}}},
     *     @OA\RequestBody(
     *         required=true,
     *         @OA\JsonContent(
     *             required={"payment_method"},
     *             @OA\Property(property="order_id", type="integer", example=123, description="Order ID for confirmation (omit for new order)"),
     *             @OA\Property(property="address_id", type="integer", example=1, description="Address ID for new order (required for new order)"),
     *             @OA\Property(property="payment_method", type="string", enum={"card","knet","myfatoorah"}, example="card", description="Payment method"),
     *             @OA\Property(property="payment_details", type="object", nullable=true, description="Additional payment details")
     *         )
     *     ),
     *     @OA\Response(
     *         response=201,
     *         description="Order created or confirmed successfully",
     *         @OA\JsonContent(
     *             type="object",
     *             @OA\Property(property="success", type="boolean", example=true),
     *             @OA\Property(property="data", type="object",
     *                 @OA\Property(property="order_id", type="integer", example=123),
     *                 @OA\Property(property="order_number", type="string", example="0005"),
     *                 @OA\Property(property="transaction_id", type="string", example="A1B2C3D4E5F6"),
     *                 @OA\Property(property="total", type="number", format="float", example=241.81),
     *                 @OA\Property(property="payment_status", type="string", example="paid")
     *             ),
     *             @OA\Property(property="message", type="string", example="Order created successfully. Please proceed to payment.")
     *         )
     *     ),
     *     @OA\Response(
     *         response=400,
     *         description="Your cart is empty.",
     *         @OA\JsonContent(
     *             type="object",
     *             @OA\Property(property="success", type="boolean", example=false),
     *             @OA\Property(property="message", type="string", example="Your cart is empty.")
     *         )
     *     ),
     *     @OA\Response(
     *         response=422,
     *         description="Validation error",
     *         @OA\JsonContent(
     *             type="object",
     *             @OA\Property(property="success", type="boolean", example=false),
     *             @OA\Property(property="message", type="string", example="Validation error details")
     *         )
     *     ),
     *     @OA\Response(
     *         response=500,
     *         description="Server error",
     *         @OA\JsonContent(
     *             type="object",
     *             @OA\Property(property="success", type="boolean", example=false),
     *             @OA\Property(property="message", type="string", example="An error occurred while processing the order. Please try again.")
     *         )
     *     )
     * )
     */
    public function checkoutOrConfirm(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'transaction_id' => 'required|string',
            'address_id' => 'required|exists:addresses,id',
            'payment_method' => 'required|string|in:ap,vm,kn',
            'payment_details' => 'nullable|array'
        ]);

        // fullform
        // [ Apple Pay, VISA/MASTER, KNET]

        if ($validator->fails()) {
            return $this->validationErrorResponse($validator->errors());
        }

        $user = $request->user();
        $transaction_id = $request->transaction_id;
        DB::beginTransaction();
        try {

            // Create new order (checkout)
            $cart = Cart::with(['items.product', 'coupon'])
                ->where('user_id', $user->id)
                ->where('status', 'active')
                ->lockForUpdate()
                ->first();
            if (! $cart || $cart->items->isEmpty()) {
                DB::rollBack();

                return $this->errorResponse('Your cart is empty.', 400);
            }

            $snapshot = $this->cartSnapshot->build($cart, $user);
            if (! empty($snapshot['coupon_notice'])) {
                DB::rollBack();

                return $this->errorResponse(
                    $snapshot['coupon_notice'].' Please refresh your cart and try again.',
                    422
                );
            }

            $address = Address::where('user_id', $user->id)->findOrFail($request->address_id);

            $sub_total_amount = (float) $snapshot['subtotal'];
            $shippingFee = (float) $snapshot['shipping_fee'];
            $discount_amount = (float) $snapshot['discount_amount'];
            $tax_amount = 0;
            $total_items = $cart->items->sum('quantity');
            $total_amount = max(0.0, round((float) $snapshot['grand_total'] + $tax_amount, 2));

            $couponIdForOrder = ! empty($snapshot['coupon']) ? $cart->fresh()->coupon_id : null;

            // Create a clean address string without JSON objects
            $shipping_address = trim(
                implode(', ', array_filter([
                    $address->line_1,
                    $address->line_2,
                    $address->city ? $address->city->name_en : null,
                    $address->state ? $address->state->name_en : null,
                    $address->country ? $address->country->name_en : null,
                    $address->pincode,
                    $address->phone,
                ]))
            );

            $billing_address = $shipping_address; // You may want to allow a separate billing address

            // Truncate to 255 chars to fit VARCHAR(255) columns
            $shipping_address = mb_substr($shipping_address, 0, 255);
            $billing_address = mb_substr($billing_address, 0, 255);

            // Use 'pending' as it's in the allowed enum values
            $order_status = 'pending';
            $order_code = str_pad((Order::count() + 1), 4, '0', STR_PAD_LEFT);

            // Determine vendor_id from cart items' products (more reliable than cart->vendor_id)
            $vendorId = $cart->items->first()?->product?->vendor_id ?? $cart->vendor_id;
            if (! $vendorId) {
                DB::rollBack();

                return $this->errorResponse('Unable to determine vendor for this order', 400);
            }

            $order = Order::create([
                'user_id' => $user->id,
                'order_code' => $order_code,
                'vendor_id' => $vendorId,
                'coupon_id' => $couponIdForOrder,
                'shipping_address' => $shipping_address,
                'billing_address' => $billing_address,
                'total_items' => $total_items,
                'sub_total_amount' => $sub_total_amount,
                'tax_amount' => $tax_amount,
                'discount_amount' => $discount_amount,
                'total_amount' => $total_amount,
                'order_status' => 'pending',
                'payment_status' => 'paid',
                'payment_method' => $request->payment_method == 'kn' ? 'knet' : ($request->payment_method == 'ap' ? 'apple pay' : ($request->payment_method == 'vm' ? 'visa/master' : 'knet')),
                'shipping_fee' => $shippingFee,
                'order_summary' => null, // You can fill this with more details if needed
                'transaction_id' => $transaction_id,
            ]);

            // Initialize InventoryService
            $inventoryService = new InventoryService();

            // Create order items and decrease stock
            foreach ($cart->items as $item) {
                $product = $item->product;

                // Skip if product is null (deleted product)
                if (! $product) {
                    DB::rollBack();

                    return $this->errorResponse(
                        "Product with ID {$item->product_id} is no longer available. Please remove it from your cart.",
                        400
                    );
                }

                // Check stock availability before creating order item
                $size = $item->size ?? null;
                $color = $item->color ?? null;

                if (! $inventoryService->hasEnoughStock($product, $item->quantity, $size, $color)) {
                    DB::rollBack();

                    return $this->errorResponse(
                        "Insufficient stock for product: {$product->name_en}. Available stock is less than requested quantity.",
                        400
                    );
                }

                // Decrease stock from inventory
                $inventoryService->decreaseStock($product, $item->quantity, $size, $color);

                // Create order item
                // Note: $item->price already contains (unit_price * quantity)
                // So unit_price = $item->price / $item->quantity
                $unitPrice = $item->quantity > 0 ? $item->price / $item->quantity : $item->price;
                $order->orderItems()->create([
                    'product_id' => $item->product_id,
                    'quantity' => $item->quantity,
                    'amount' => $unitPrice, // Unit price per item
                    'total_amount' => $item->price, // Total for this line item (already calculated)
                    'size' => $size,
                    'color' => $color,
                ]);
            }

            if ($couponIdForOrder) {
                CouponUsage::create([
                    'coupon_id' => $couponIdForOrder,
                    'order_id' => $order->id,
                    'user_id' => $user->id,
                    'discount_amount' => $discount_amount,
                ]);
            }

            // For now, we'll simulate a successful payment
            $cart->update(['status' => 'completed']);

            // Armada order creation is intentionally deferred until vendor/admin clicks
            // "Deliver Now" (orders.confirm) to avoid auto-sync at checkout.

            DB::commit();

            $notification = Notification::create([
                'user_id' => $user->id,
                'order_id' => $order->id,
                'type' => 'order',
                // 'status' => 'active',
                'title' => 'Order Placed',
                'body' => 'Your order has been placed successfully.',
                'content' => 'Your order has been placed successfully.',
                'icon_image' => null,
                'is_read' => false,
            ]);

            // Set FinanceTransaction status based on order status
            // Order is created as 'pending', so transaction should also be 'pending'
            // It will be updated to 'completed' or 'Success' when order is delivered
            $transactionStatus = 'pending'; // Match order status

            $transaction = FinanceTransaction::create([
                'user_id' => $user->id,
                'vendor_id' => $vendorId,
                'user_type' => 'user',
                'transaction_id' => $order->transaction_id,
                'type' => 'order',
                'summery' => 'Order Placed',
                'payment_processor' => $request->payment_method == 'kn' ? 'knet' : ($request->payment_method == 'ap' ? 'apple pay' : ($request->payment_method == 'vm' ? 'visa/master' : 'knet')),
                'payment_reference_id' => $order->transaction_id,
                'amount' => $order->total_amount,
                'charge' => 0,
                'attempted_at' => now(),
                'attempt_status' => $transactionStatus,
            ]);

            return $this->successResponse([
                'order_id' => $order->id,
                'order_code' => $order->order_code,
                'transaction_id' => $order->transaction_id,
                'subtotal' => $order->sub_total_amount,
                'shipping_fee' => $order->shipping_fee,
                'discount' => $order->discount_amount,
                'tax' => $order->tax_amount,
                'total' => $order->total_amount,
                'payment_status' => $order->payment_status
            ], 'Order created successfully. Please proceed to payment.', 201);
        } catch (\Exception $e) {
            DB::rollBack();
            return $this->errorResponse('An error occurred while processing the order. Please try again. ' . $e->getMessage(), 500);
        }
    }

}