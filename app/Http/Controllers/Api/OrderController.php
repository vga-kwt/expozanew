<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Api\Controller;
use App\Models\Order;
use App\Models\Cart;
use App\Models\Address;
use App\Models\Setting;
use App\Services\ArmadaService;
use Illuminate\Http\Request;
use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\Log;

class OrderController extends Controller
{
    /**
     * List all orders for the authenticated user
     *
     * @OA\Get(
     *     path="/api/orders",
     *     summary="List all orders for the authenticated user",
     *     tags={"Order"},
     *     security={{"sanctum":{}}},
     *     @OA\Parameter(
     *         name="status",
     *         in="query",
     *         required=false,
     *         @OA\Schema(type="string", enum={"ongoing","past"})
     *     ),
     *     @OA\Response(
     *         response=200,
     *         description="List of orders"
     *     )
     * )
     */
    public function index(Request $request)
    {
        $query = $request->user()->orders()->where('deleted_at', null)->with([
            'orderItems.product' => function ($q) {
                $q->select('id', 'name_en', 'name_ar', 'vendor_id', 'category_id')
                    ->with('category:id,name_en,name_ar');
            },
            'orderItems.product.vendor:id,use_armada_delivery',
            'vendor:id,use_armada_delivery'
        ]);

        if ($request->status === 'ongoing') {
            $query->whereNotIn('order_status', ['delivered', 'cancelled', 'refunded']);
        } elseif ($request->status === 'past') {
            $query->whereIn('order_status', ['delivered', 'cancelled', 'refunded']);
        }

        // Apply pagination
        $perPage = $request->get('per_page', 10);
        $orders = $query->latest()->paginate($perPage);

        // Custom structure
        return response()->json([
            'success' => true,
            'message' => 'Orders retrieved successfully',
            'data' => $orders->items(),
            'pagination' => [
                'current_page' => $orders->currentPage(),
                'per_page' => $orders->perPage(),
                'total' => $orders->total(),
                'last_page' => $orders->lastPage(),
                'has_more_pages' => $orders->hasMorePages()
            ]
        ]);
    }

    public function allOrders(Request $request)
    {
        $perPage = $request->get('per_page', 10);
        $query = $request->user()->orders()->where('deleted_at', null)->with([
            'orderItems.product.vendor:id,use_armada_delivery',
            'vendor:id,use_armada_delivery'
        ]);
        $orders = $query->latest()->paginate($perPage);
        return response()->json([
            'success' => true,
            'message' => 'Orders retrieved successfully',
            'data' => $orders->items(),
            'pagination' => [
                'current_page' => $orders->currentPage(),
                'per_page' => $orders->perPage(),
                'total' => $orders->total(),
                'last_page' => $orders->lastPage(),
                'has_more_pages' => $orders->hasMorePages()
            ]
        ]);
    }


    public function OrdersStatus($id)
    {
        $order = Order::where('deleted_at', null)->with(['fulfillments'])->findOrFail($id);

        // Get the latest fulfillment (if any)
        $fulfillment = $order->fulfillments()->latest()->first();

        return response()->json([
            'success' => true,
            'message' => 'Order status retrieved successfully',
            'data' => [
                'order_id' => $order->id,
                'order_status' => $order->order_status,
                'delivery_status' => $order->delivery_status,
                'fulfillment' => $fulfillment,
            ]
        ]);
    }

    /**
     * Show a single order's details
     *
     * @OA\Get(
     *     path="/api/orders/{id}",
     *     summary="Show a single order's details",
     *     tags={"Order"},
     *     security={{"sanctum":{}}},
     *     @OA\Parameter(
     *         name="id",
     *         in="path",
     *         required=true,
     *         @OA\Schema(type="integer")
     *     ),
     *     @OA\Response(
     *         response=200,
     *         description="Order details"
     *     )
     * )
     */
    public function show(Request $request, $id)
    {
        $order = $request->user()->orders()->where('deleted_at', null)->with([
            'orderItems.product.vendor:id,use_armada_delivery',
            'vendor:id,use_armada_delivery'
        ])->findOrFail($id);

        // Refund eligibility logic (e.g., delivered within 15 days)
        $isRefundable = false;
        if ($order->order_status === 'delivered') {
            $deliveryDate = Carbon::parse($order->updated_at); // Assuming updated_at marks delivery
            if ($deliveryDate->diffInDays(now()) <= 15) {
                $isRefundable = true;
            }
        }

        $order->is_refundable = $isRefundable;

        // TODO: Get real-time delivery status from a third-party service
        $order->delivery_status = 'In Transit (Mocked)';

        return $this->successResponse($order);
    }

    /**
     * Request a refund for an order
     *
     * @OA\Post(
     *     path="/api/orders/{id}/refund",
     *     summary="Request a refund for an order",
     *     tags={"Order"},
     *     security={{"sanctum":{}}},
     *     @OA\Parameter(
     *         name="id",
     *         in="path",
     *         required=true,
     *         @OA\Schema(type="integer")
     *     ),
     *     @OA\Response(
     *         response=200,
     *         description="Refund request submitted successfully."
     *     ),
     *     @OA\Response(
     *         response=403,
     *         description="This order is not eligible for a refund."
     *     ),
     *     @OA\Response(
     *         response=409,
     *         description="A refund request has already been submitted for this order."
     *     )
     * )
     */
    public function requestRefund(Request $request, $id)
    {
        $order = $request->user()->orders()->where('deleted_at', null)->findOrFail($id);

        // Refund eligibility checks
        if ($order->order_status !== 'delivered') {
            return $this->errorResponse('Only delivered orders are eligible for a refund.', 403);
        }

        if (Carbon::parse($order->updated_at)->diffInDays(now()) > 15) {
            return $this->errorResponse('The refund period of 15 days has expired for this order.', 403);
        }

        if ($order->refund_status) {
            return $this->errorResponse('A refund request has already been submitted for this order.', 409);
        }

        // Mark refund request
        $order->update([
            'refund_requested_at' => now(),
            'refund_status' => 'pending',
        ]);

        // TODO: Notify admin/vendor about the refund request

        return $this->successResponse(null, 'Refund request submitted successfully.');
    }


    /**
     * Get invoice data for an order
     *
     * @OA\Get(
     *     path="/api/orders/{id}/invoice",
     *     summary="Get invoice data for an order",
     *     tags={"Order"},
     *     security={{"sanctum":{}}},
     *     @OA\Parameter(
     *         name="id",
     *         in="path",
     *         required=true,
     *         @OA\Schema(type="integer")
     *     ),
     *     @OA\Response(
     *         response=200,
     *         description="Invoice data"
     *     )
     * )
     */
    public function getInvoice(Request $request, $id)
    {
        $order = $request->user()->orders()->where('deleted_at', null)->with('orderItems.product.vendor', 'user', 'shippingAddress')->findOrFail($id);

        // Get first vendor from order items
        $vendor = $order->orderItems->first()?->product->vendor;

        // You can format this data as needed for your PDF/HTML invoice on the frontend
        $invoiceData = [
            'order_identifier' => $order->id,
            'order_date' => $order->created_at->toFormattedDateString(),
            'customer' => [
                'name' => $order->user->full_name,
                'address' => $order->shippingAddress,
            ],
            'vendor' => [
                'name' => $vendor ? $vendor->name : 'N/A',
                'address' => $vendor ? $vendor->address : 'N/A',
            ],
            'items' => $order->orderItems,
            'subtotal' => $order->sub_total_amount,
            'discount' => $order->discount_amount,
            'shipping' => $order->shipping_fee ?? 0,
            'total' => $order->total_amount,
        ];

        return $this->successResponse($invoiceData);
    }

    /**
     * @OA\Get(
     *     path="/api/past-orders",
     *     summary="Get past orders",
     *     tags={"Order"},
     *     security={{"sanctum":{}}},
     *     @OA\Response(
     *         response=200,
     *         description="List of past orders"
     *     )
     * )
     */
    public function pastOrders(Request $request)
    {
        $query = $request->user()->orders()
            ->where('deleted_at', null)
            ->with('orderItems.product.vendor')
            ->whereIn('order_status', ['delivered', 'cancelled', 'refunded'])
            ->latest();

        $perPage = $request->get('per_page', 10);
        $orders = $query->paginate($perPage);

        return response()->json([
            'success' => true,
            'message' => 'Past orders retrieved successfully',
            'data' => $orders->items(),
            'pagination' => [
                'current_page' => $orders->currentPage(),
                'per_page' => $orders->perPage(),
                'total' => $orders->total(),
                'last_page' => $orders->lastPage(),
                'has_more_pages' => $orders->hasMorePages()
            ]
        ]);
    }


    /**
     * @OA\Post(
     *     path="/api/orders/place",
     *     summary="Place new order",
     *     tags={"Order"},
     *     security={{"sanctum":{}}},
     *     @OA\RequestBody(
     *         required=true,
     *         @OA\JsonContent(
     *             required={"address_id", "payment_method"},
     *             @OA\Property(property="address_id", type="integer"),
     *             @OA\Property(property="payment_method", type="string", enum={"cash_on_delivery", "credit_card", "paypal"}),
     *             @OA\Property(property="notes", type="string")
     *         )
     *     ),
     *     @OA\Response(
     *         response=201,
     *         description="Order placed successfully"
     *     ),
     *     @OA\Response(
     *         response=422,
     *         description="Validation error"
     *     )
     * )
     */
    public function place(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'address_id' => 'required|exists:addresses,id',
            'payment_method' => 'required|in:cash_on_delivery,credit_card,paypal',
            'notes' => 'nullable|string|max:500'
        ]);

        if ($validator->fails()) {
            return $this->errorResponse($validator->errors(), 422);
        }

        // Get user's active cart
        $cart = Cart::where('user_id', $request->user()->id)
            ->where('deleted_at', null)
            ->where('status', 'active')
            ->with('items.product')
            ->first();

        if (!$cart || $cart->items->isEmpty()) {
            return $this->errorResponse('Cart is empty', 422);
        }

        // Get address
        $address = Address::where('user_id', $request->user()->id)->findOrFail($request->address_id);

        // Create a clean address string
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
        $billing_address = $shipping_address;

        // Truncate to 255 chars to fit VARCHAR(255) columns
        $shipping_address = mb_substr($shipping_address, 0, 255);
        $billing_address = mb_substr($billing_address, 0, 255);

        // Calculate totals
        // Note: $item->price already contains (unit_price * quantity), so just sum the prices
        $subtotal = $cart->items->sum('price');

        $totalItems = $cart->items->sum('quantity');

        // Get base delivery fee and free delivery threshold from settings
        $baseDeliveryFee = (float) Setting::where('key', 'base_delivery_fee')->value('value') ?? 0;
        $freeDeliveryThreshold = (float) Setting::where('key', 'free_delivery_threshold')->value('value') ?? 0;

        // Apply free delivery: if calculated threshold > 0 AND subtotal >= threshold, free delivery
        // If threshold is 0 (disabled), ALWAYS charge base delivery fee
        $shippingFee = ($freeDeliveryThreshold > 0 && $subtotal >= $freeDeliveryThreshold) ? 0 : $baseDeliveryFee;

        // Calculate total amount including delivery fee
        $discountAmount = 0;
        $taxAmount = 0;
        $totalAmount = $subtotal - $discountAmount + $shippingFee + $taxAmount;

        // Determine vendor_id from cart items' products (more reliable than cart->vendor_id)
        $vendorId = $cart->items->first()?->product?->vendor_id ?? $cart->vendor_id;
        if (!$vendorId) {
            return $this->errorResponse('Unable to determine vendor for this order', 422);
        }

        // Create order
        $order = Order::create([
            'user_id' => $request->user()->id,
            'vendor_id' => $vendorId,
            'order_code' => str_pad((Order::count() + 1), 4, '0', STR_PAD_LEFT),
            'shipping_address' => $shipping_address,
            'billing_address' => $billing_address,
            'total_items' => $totalItems,
            'sub_total_amount' => $subtotal,
            'discount_amount' => $discountAmount,
            'shipping_fee' => $shippingFee,
            'tax_amount' => $taxAmount,
            'total_amount' => $totalAmount,
            'payment_method' => $request->payment_method,
            'payment_status' => 'pending',
            'order_status' => 'pending',
            'order_summary' => $request->notes
        ]);

        // Initialize InventoryService
        $inventoryService = new \App\Services\InventoryService();

        // Create order items and decrease stock
        foreach ($cart->items as $cartItem) {
            $product = $cartItem->product;

            // Skip if product is null (deleted product)
            if (!$product) {
                return $this->errorResponse(
                    "Product with ID {$cartItem->product_id} is no longer available. Please remove it from your cart.",
                    422
                );
            }

            // Check stock availability before creating order item
            $size = $cartItem->size ?? null;
            $color = $cartItem->color ?? null;

            if (!$inventoryService->hasEnoughStock($product, $cartItem->quantity, $size, $color)) {
                return $this->errorResponse(
                    "Insufficient stock for product: {$product->name_en}. Available stock is less than requested quantity.",
                    422
                );
            }

            // Decrease stock from inventory
            $inventoryService->decreaseStock($product, $cartItem->quantity, $size, $color);

            // Create order item
            // Note: $cartItem->price already contains (unit_price * quantity)
            // So unit_price = $cartItem->price / $cartItem->quantity
            $unitPrice = $cartItem->quantity > 0 ? $cartItem->price / $cartItem->quantity : $cartItem->price;
            $order->orderItems()->create([
                'product_id' => $cartItem->product_id,
                'quantity' => $cartItem->quantity,
                'amount' => $unitPrice, // Unit price per item
                'total_amount' => $cartItem->price, // Total for this line item (already calculated)
                'size' => $size,
                'color' => $color,
            ]);
        }

        // Clear cart
        $cart->items()->delete();
        $cart->delete();

        $order->load('orderItems.product');

        return $this->successResponse($order, 'Order placed successfully', 201);
    }

    /**
     * @OA\Post(
     *     path="/api/orders/cancel/{id}",
     *     summary="Cancel order",
     *     tags={"Order"},
     *     security={{"sanctum":{}}},
     *     @OA\Parameter(
     *         name="id",
     *         in="path",
     *         required=true,
     *         @OA\Schema(type="integer")
     *     ),
     *     @OA\Response(
     *         response=200,
     *         description="Order cancelled successfully"
     *     ),
     *     @OA\Response(
     *         response=404,
     *         description="Order not found"
     *     ),
     *     @OA\Response(
     *         response=422,
     *         description="Order cannot be cancelled"
     *     )
     * )
     */
    public function cancel(Request $request, $id)
    {
        $order = $request->user()->orders()->where('deleted_at', null)->find($id);

        if (!$order) {
            return $this->errorResponse('Order not found', 404);
        }

        // Check if order can be cancelled
        if (in_array($order->order_status, ['shipped', 'delivered', 'cancelled', 'refunded'])) {
            return $this->errorResponse('Order cannot be cancelled', 422);
        }

        // Cancel order in Armada if synced and vendor uses Armada
        $order->load('vendor');
        $vendorUsesArmada = $order->vendor && $order->vendor->use_armada_delivery;

        if (config('armada.enabled', false) && $vendorUsesArmada && $order->is_armada_synced && $order->armada_order_id) {
            try {
                $armadaService = app(ArmadaService::class);
                $armadaResult = $armadaService->cancelOrder($order->armada_order_id, 'Cancelled by customer');

                if (!$armadaResult['success']) {
                    Log::warning('Armada cancel order failed', [
                        'order_id' => $order->id,
                        'error' => $armadaResult['error'] ?? 'Unknown error',
                    ]);
                }
            } catch (\Exception $e) {
                Log::error('Armada cancel order error', [
                    'order_id' => $order->id,
                    'error' => $e->getMessage(),
                ]);
            }
        }

        $order->update([
            'order_status' => 'cancelled',
            'cancelled_at' => now()
        ]);

        // Update FinanceTransaction status when order is cancelled
        $financeTransaction = \App\Models\FinanceTransaction::where('transaction_id', $order->transaction_id)
            ->where('type', 'order')
            ->where('vendor_id', $order->vendor_id)
            ->first();

        if ($financeTransaction && !in_array($financeTransaction->attempt_status, ['cancelled', 'Cancelled', 'failed', 'Failed'])) {
            $financeTransaction->update([
                'attempt_status' => 'cancelled'
            ]);
        }

        return $this->successResponse($order, 'Order cancelled successfully');
    }

    /**
     * Track order via Armada
     * 
     * @param Request $request
     * @param int $id
     * @return \Illuminate\Http\JsonResponse
     */
    public function track(Request $request, $id)
    {
        $order = $request->user()->orders()->where('deleted_at', null)->with('vendor')->findOrFail($id);

        // Check if vendor uses Armada delivery
        $vendorUsesArmada = $order->vendor && $order->vendor->use_armada_delivery;

        if (!config('armada.enabled', false) || !$vendorUsesArmada || !$order->is_armada_synced) {
            return $this->errorResponse('Order tracking not available', 404);
        }

        if (!$order->armada_tracking_number && !$order->armada_order_id) {
            return $this->errorResponse('Tracking information not available', 404);
        }

        try {
            $armadaService = app(ArmadaService::class);
            $trackingNumber = $order->armada_tracking_number ?? $order->armada_order_id;
            $result = $armadaService->trackOrder($trackingNumber);

            if ($result['success']) {
                // Update order status based on tracking
                $trackingData = $result['data'];
                if (isset($trackingData['status'])) {
                    $orderStatus = $armadaService->mapArmadaStatusToOrderStatus($trackingData['status']);
                    $order->update([
                        'order_status' => $orderStatus,
                        'delivery_status' => $trackingData['status'],
                    ]);
                }

                return $this->successResponse([
                    'order' => $order->fresh(),
                    'tracking' => $trackingData,
                ], 'Tracking information retrieved successfully');
            }

            return $this->errorResponse($result['error'] ?? 'Failed to track order', 400);
        } catch (\Exception $e) {
            return $this->errorResponse('Error tracking order: ' . $e->getMessage(), 500);
        }
    }
}