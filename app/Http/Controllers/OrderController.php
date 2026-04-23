<?php

namespace App\Http\Controllers;

use App\Models\Fulfillment;
use App\Models\Order;
use App\Models\Address;
use App\Models\FinanceTransaction;
use App\Services\ArmadaService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use Inertia\Inertia;
use App\Notifications\RefundApprovedNotification;
use App\Notifications\RefundRejectedNotification;
use Symfony\Component\HttpFoundation\StreamedResponse;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Mail;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Schema;
use App\Models\Notification;

class OrderController extends Controller
{
    /**
     * Update FinanceTransaction status based on order status
     */
    private function updateFinanceTransactionStatus(Order $order, string $orderStatus)
    {
        // Get vendor from order
        $vendor = $order->vendor;
        if (!$vendor) {
            // Try to get vendor from order items
            $vendor = $order->orderItems->first()?->product?->vendor;
        }

        // Find FinanceTransaction - try multiple ways to find it
        $financeTransaction = null;

        // First try: by transaction_id
        if ($order->transaction_id) {
            $financeTransaction = FinanceTransaction::where('transaction_id', $order->transaction_id)
                ->where('type', 'order')
                ->when($vendor, function ($query) use ($vendor) {
                    $query->where('vendor_id', $vendor->id);
                })
                ->first();
        }

        // Second try: by order amount and vendor (if transaction_id not found)
        if (!$financeTransaction && $vendor) {
            $financeTransaction = FinanceTransaction::where('type', 'order')
                ->where('vendor_id', $vendor->id)
                ->where('user_id', $order->user_id)
                ->where('amount', $order->total_amount)
                ->whereDate('created_at', $order->created_at->toDateString())
                ->first();
        }

        // If FinanceTransaction doesn't exist, create it
        if (!$financeTransaction && $order->transaction_id && $vendor) {
            $financeTransaction = FinanceTransaction::create([
                'user_id' => $order->user_id,
                'vendor_id' => $vendor->id,
                'user_type' => 'user',
                'transaction_id' => $order->transaction_id,
                'type' => 'order',
                'summery' => 'Order #' . str_pad($order->id, 4, '0', STR_PAD_LEFT) . ' - ' . ucfirst($orderStatus),
                'payment_processor' => $order->payment_method ?? 'system',
                'payment_reference_id' => $order->transaction_id,
                'amount' => $order->total_amount,
                'charge' => 0,
                'attempted_at' => now(),
                'attempt_status' => $orderStatus === 'cancelled' ? 'cancelled' : 'pending',
            ]);
        }

        if (!$financeTransaction) {
            return;
        }

        // Update status based on order status
        if ($orderStatus === 'delivered') {
            // Order delivered = transaction completed
            // Use 'completed' status to match all query filters
            if (!in_array($financeTransaction->attempt_status, ['Success', 'completed', 'Succss', 'success'])) {
                $financeTransaction->update([
                    'attempt_status' => 'completed',
                    'status' => 'completed',
                    'summery' => 'Order Delivered - Order #' . str_pad($order->id, 4, '0', STR_PAD_LEFT),
                    'processed_at' => now(),
                ]);
            }
        } elseif ($orderStatus === 'cancelled') {
            // Order cancelled = transaction cancelled
            if (!in_array($financeTransaction->attempt_status, ['cancelled', 'Cancelled', 'failed', 'Failed'])) {
                $financeTransaction->update([
                    'attempt_status' => 'cancelled',
                    'summery' => 'Order Cancelled - Order #' . str_pad($order->id, 4, '0', STR_PAD_LEFT),
                ]);
            }
        }
    }

    /**
     * Display a listing of the resource.
     * Note: Soft deleted orders are excluded by default (SoftDeletes enabled).
     */
    public function index(Request $request)
    {
        $orders = Order::with([
            'user:id,full_name,email,mobile,phone',
            'vendor:id,name,brand_name_en,email,mobile,use_armada_delivery,user_id',
            'vendor.user.addresses' => function ($q) {
                $q->where('role_name', 'vendor')->with(['country', 'state', 'city']);
            },
            'refundApprover:id,full_name,email',
            'orderItems:id,order_id,product_id,quantity,amount',
            'orderItems.product:id,name_en,name_ar,vendor_id',
            'orderItems.product.vendor:id,name,brand_name_en,email,mobile,use_armada_delivery,user_id',
            'orderItems.product.vendor.user.addresses' => function ($q) {
                $q->where('role_name', 'vendor')->with(['country', 'state', 'city']);
            }
        ])
            ->when($request->input('search'), function ($query, $search) {
                $query->where(function ($q) use ($search) {
                    $q->where('id', 'like', "%{$search}%")
                        ->orWhere('order_code', 'like', "%{$search}%")
                        ->orWhereHas('user', function ($userQuery) use ($search) {
                            $userQuery->where('full_name', 'like', "%{$search}%");
                        })
                        ->orWhereHas('orderItems.product.vendor', function ($vendorQuery) use ($search) {
                            $vendorQuery->where('name', 'like', "%{$search}%");
                        });
                });
            })
            ->when($request->input('status'), function ($query, $status) {
                $query->where('order_status', $status);
            })
            ->when($request->input('payment_status'), function ($query, $paymentStatus) {
                $query->where('payment_status', $paymentStatus);
            })
            ->when($request->input('date_from'), function ($query, $date_from) {
                $query->whereDate('created_at', '>=', $date_from);
            })
            ->when($request->input('date_to'), function ($query, $date_to) {
                $query->whereDate('created_at', '<=', $date_to);
            })
            ->latest()
            ->paginate(10)
            ->withQueryString();

        // Transform orders to ensure vendor_name and orderItems are properly available
        $transformedOrders = $orders->through(function ($order) {
            // Always ensure orderItems relationship is loaded (even if empty)
            if (!$order->relationLoaded('orderItems')) {
                $order->load('orderItems:id,order_id,product_id,quantity,amount');
            }

            // Transform each order item to ensure product and vendor_name are available
            if ($order->orderItems && $order->orderItems->count() > 0) {
                $order->orderItems = $order->orderItems->map(function ($item) {
                    // Ensure product is loaded
                    if (!$item->relationLoaded('product') && $item->product_id) {
                        $item->load('product:id,name_en,name_ar,vendor_id');
                    }

                    if ($item->product) {
                        // Ensure vendor relationship is loaded
                        if (!$item->product->relationLoaded('vendor') && $item->product->vendor_id) {
                            $item->product->load('vendor:id,name,brand_name_en,email,mobile,use_armada_delivery');
                        }
                        // vendor_name accessor will work automatically since it's in $appends
                        // Just make sure it's visible
                        $item->product->makeVisible(['vendor_name']);
                        $item->product->setAttribute('business_name', $item->product->vendor ? ($item->product->vendor->brand_name_en ?: $item->product->vendor->name) : 'N/A');
                    }
                    return $item;
                });
            }
            return $order;
        });

        return Inertia::render('Orders/Index', [
            'orders' => $transformedOrders,
            'filters' => $request->only(['search', 'status', 'payment_status', 'date_from', 'date_to']),
        ]);
    }

    // Refund: Request
    public function requestRefund(Request $request, Order $order)
    {
        $order->update([
            'refund_requested_at' => now(),
            'refund_status' => 'pending',
            'refund_rejection_reason_en' => null,
            'refund_rejection_reason_ar' => null,
            'refund_approved_by' => null,
        ]);
        return redirect()->back()->with('success', 'Refund requested.');
    }

    // Refund: Approve
    public function approveRefund(Request $request, $id)
    {
        $order = Order::with('orderItems.product.vendor')->findOrFail($id);

        // Initialize InventoryService to increase stock
        $inventoryService = new \App\Services\InventoryService();

        // Increase stock for all order items
        foreach ($order->orderItems as $orderItem) {
            $product = $orderItem->product;
            $size = $orderItem->size ?? null;
            $color = $orderItem->color ?? null;

            // Increase stock back
            try {
                $inventoryService->increaseStock($product, $orderItem->quantity, $size, $color);
            } catch (\Exception $e) {
                Log::error("Failed to increase stock for product {$product->id} on refund: " . $e->getMessage());
                // Continue with other items even if one fails
            }
        }

        $order->refund_status = 'approved';
        $order->payment_status = 'refunded';
        $order->refund_approved_by = $request->user()->id; // Store the approver's user ID
        $order->save();

        // Get vendor from order
        $vendor = $order->vendor;
        if (!$vendor) {
            // Try to get vendor from order items
            $vendor = $order->orderItems->first()?->product?->vendor;
        }

        // Find or create FinanceTransaction for refund
        // First, find the original order transaction
        $originalTransaction = FinanceTransaction::where('transaction_id', $order->transaction_id)
            ->where('type', 'order')
            ->where('vendor_id', $vendor?->id)
            ->first();

        // Create refund FinanceTransaction
        $refundTransactionId = 'TXN' . strtoupper(bin2hex(random_bytes(8)));
        $refundTransaction = FinanceTransaction::create([
            'user_id' => $order->user_id,
            'vendor_id' => $vendor?->id,
            'user_type' => 'user',
            'transaction_id' => $refundTransactionId,
            'type' => 'refund',
            'summery' => 'Refund for Order #' . str_pad($order->id, 4, '0', STR_PAD_LEFT),
            'payment_processor' => $originalTransaction?->payment_processor ?? 'system',
            'payment_reference_id' => $order->transaction_id ?? 'REF' . strtoupper(bin2hex(random_bytes(8))),
            'amount' => $order->total_amount,
            'charge' => 0,
            'attempted_at' => now(),
            'attempt_status' => 'Success', // Refund approved = success
        ]);

        // Update original transaction status if found
        if ($originalTransaction) {
            // Optionally mark original transaction as refunded
            // You can add a field or just leave it as is
        }

        // Notify user (Laravel notification)
        // Custom notification (user)
        Notification::create([
            'type' => 'order',
            'title' => 'Refund Approved',
            'body' => 'Your refund for order #' . $order->id . ' has been approved.',
            'content' => 'Order #' . $order->id . ' refund has been approved.',
            'icon_image' => 'refund-approved.png',
            'status' => 'active',
            'user_id' => $order->user_id,
            'is_read' => 0,
        ]);
        // Get vendor through order items
        $vendors = $order->orderItems->map(function ($item) {
            return $item->product->vendor;
        })->unique('id');

        foreach ($vendors as $vendorItem) {
            if ($vendorItem) {
                // Custom notification (vendor)
                Notification::create([
                    'type' => 'order',
                    'title' => 'Refund Approved',
                    'body' => 'Refund for order #' . $order->id . ' has been approved.',
                    'content' => 'Order #' . $order->id . ' refund has been approved.',
                    'icon_image' => 'refund-approved.png',
                    'status' => 'active',
                    'user_id' => $vendorItem->user_id,
                    'is_read' => 0,
                ]);
            }
        }

        return back()->with('success', 'Refund approved successfully.');
    }

    // Refund: Reject
    public function rejectRefund(Request $request, $id)
    {
        $order = Order::findOrFail($id);
        $order->refund_status = 'rejected';
        $order->refund_rejection_reason_en = $request->input('refund_rejection_reason_en');
        $order->refund_rejection_reason_ar = $request->input('refund_rejection_reason_ar');
        $order->refund_approved_by = $request->user()->id; // Store the rejector's user ID
        $order->save();

        // Custom notification (user)
        Notification::create([
            'type' => 'order',
            'title' => 'Refund Rejected',
            'body' => 'Your refund for order #' . $order->id . ' has been rejected.',
            'content' => 'Reason: ' . $request->input('refund_rejection_reason_en'),
            'icon_image' => 'refund-rejected.png',
            'status' => 'active',
            'user_id' => $order->user_id,
            'is_read' => 0,
        ]);
        // Get vendor through order items
        $vendors = $order->orderItems->map(function ($item) {
            return $item->product->vendor;
        })->unique('id');

        foreach ($vendors as $vendor) {
            if ($vendor) {
                // Custom notification (vendor)
                Notification::create([
                    'type' => 'order',
                    'title' => 'Refund Rejected',
                    'body' => 'Refund for order #' . $order->id . ' has been rejected.',
                    'content' => 'Reason: ' . $request->input('refund_rejection_reason_en'),
                    'icon_image' => 'refund-rejected.png',
                    'status' => 'active',
                    'user_id' => $vendor->user_id,
                    'is_read' => 0,
                ]);
            }
        }

        return back()->with('success', 'Refund rejected successfully.');
    }

    public function vendorIndex(Request $request)
    {
        $vendor = $request->user()->vendor;
        $status = $request->query('status');
        $search = $request->query('search');
        $dateFrom = $request->query('date_from');
        $dateTo = $request->query('date_to');
        $filterStatus = $request->query('filter_status');
        $paymentStatus = $request->query('payment_status');
        $query = $vendor->orders()->with([
            'user:id,full_name,email,mobile,phone',
            'vendor:id,name,brand_name_en,email,mobile,use_armada_delivery,user_id',
            'vendor.user.addresses' => function ($q) {
                $q->where('role_name', 'vendor')->with(['country', 'state', 'city']);
            },
            'refundApprover:id,full_name,email',
            'orderItems:id,order_id,product_id,quantity,amount',
            'orderItems.product:id,name_en,name_ar,vendor_id',
            'orderItems.product.vendor:id,name,brand_name_en,email,mobile,use_armada_delivery,user_id',
            'orderItems.product.vendor.user.addresses' => function ($q) {
                $q->where('role_name', 'vendor')->with(['country', 'state', 'city']);
            }
        ]);
        if ($status === 'current') {
            $query->whereIn('order_status', ['pending', 'processing']);
        } elseif ($status === 'completed') {
            $query->whereIn('order_status', ['completed', 'refunded']);
        }
        if ($search) {
            $query->where(function ($q) use ($search) {
                $q->where('order_code', 'like', "%{$search}%")
                    ->orWhereHas('user', function ($uq) use ($search) {
                        $uq->where('full_name', 'like', "%{$search}%");
                    })
                    ->orWhereHas('orderItems.product', function ($pq) use ($search) {
                        $pq->where('name_en', 'like', "%{$search}%")
                            ->orWhere('name_ar', 'like', "%{$search}%");
                    });
            });
        }
        if ($dateFrom) {
            $query->whereDate('created_at', '>=', $dateFrom);
        }
        if ($dateTo) {
            $query->whereDate('created_at', '<=', $dateTo);
        }
        if ($filterStatus) {
            $query->where('order_status', $filterStatus);
        }
        if ($paymentStatus) {
            $query->where('payment_status', $paymentStatus);
        }
        $orders = $query->latest()->paginate(15)->withQueryString();

        // Transform orders to ensure orderItems and product are properly available
        $transformedOrders = $orders->through(function ($order) {
            // Always ensure orderItems relationship is loaded (even if empty)
            if (!$order->relationLoaded('orderItems')) {
                $order->load('orderItems:id,order_id,product_id,quantity,amount');
            }

            // Transform each order item to ensure product and vendor_name are available
            if ($order->orderItems && $order->orderItems->count() > 0) {
                $order->orderItems = $order->orderItems->map(function ($item) {
                    // Ensure product is loaded
                    if (!$item->relationLoaded('product') && $item->product_id) {
                        $item->load('product:id,name_en,name_ar,vendor_id');
                    }

                    if ($item->product) {
                        // Ensure vendor relationship is loaded
                        if (!$item->product->relationLoaded('vendor') && $item->product->vendor_id) {
                            $item->product->load([
                                'vendor:id,name,brand_name_en,email,mobile,use_armada_delivery,user_id',
                                'vendor.user.addresses' => function ($q) {
                                    $q->where('role_name', 'vendor')->with(['country', 'state', 'city']);
                                }
                            ]);
                        }
                        // vendor_name accessor will work automatically since it's in $appends
                        // Just make sure it's visible
                        $item->product->makeVisible(['vendor_name']);
                        $item->product->setAttribute('business_name', $item->product->vendor ? ($item->product->vendor->brand_name_en ?: $item->product->vendor->name) : 'N/A');
                    }
                    return $item;
                });
            }
            return $order;
        });

        return Inertia::render('Orders/VendorIndex', [
            'orders' => $transformedOrders,
            'filters' => $request->only(['search', 'date_from', 'date_to', 'filter_status', 'status', 'payment_status']),
        ]);
    }

    public function show($id)
    {
        $order = Order::with([
            'user',
            'refundApprover',
            'orderItems.product.vendor',
            'vendor.user.addresses' => function ($q) {
                $q->where('role_name', 'vendor')->with(['country', 'state', 'city']);
            }
        ])->findOrFail($id);

        $trackingInfo = null;
        $armadaTrackingInfo = null;

        // Get Armada tracking if order is synced with Armada
        if (config('armada.enabled', false) && $order->is_armada_synced && $order->armada_tracking_number) {
            try {
                $armadaService = app(ArmadaService::class);
                $trackingResult = $armadaService->trackOrder($order->armada_tracking_number);

                if ($trackingResult['success']) {
                    $armadaTrackingInfo = $trackingResult['data'];

                    // Auto-sync status from Armada
                    if (isset($armadaTrackingInfo['status'])) {
                        $armadaStatus = $armadaTrackingInfo['status'];
                        $mappedStatus = $armadaService->mapArmadaStatusToOrderStatus($armadaStatus);

                        if ($order->order_status !== $mappedStatus) {
                            $order->order_status = $mappedStatus;
                            $order->delivery_status = $armadaStatus;
                            $order->save();
                        }
                    }
                }
            } catch (\Exception $e) {
                Log::error('Armada tracking error in show method', [
                    'order_id' => $order->id,
                    'error' => $e->getMessage(),
                ]);
            }
        }

        // Legacy ShipRocket tracking (if exists)
        $trackingNumber = $order->tracking_number;
        if ($trackingNumber && !$armadaTrackingInfo) {
            $response = Http::withHeaders([
                'Authorization' => 'Bearer ' . config('services.shiprocket.token'),
            ])->get("https://apiv2.shiprocket.in/v1/external/courier/track?awb=$trackingNumber");

            if ($response->ok()) {
                $trackingInfo = $response->json();
            }
        }

        return response()->json([
            'order' => $order->fresh(),
            'tracking' => $trackingInfo,
            'armada_tracking' => $armadaTrackingInfo,
            'is_armada_synced' => $order->is_armada_synced,
            'armada_order_id' => $order->armada_order_id,
            'armada_tracking_number' => $order->armada_tracking_number,
        ]);
    }

    public function generateInvoice($id)
    {
        $order = Order::with(['user', 'refundApprover', 'orderItems.product.vendor'])->findOrFail($id);

        // Import the PDF facade if not already imported
        // use Barryvdh\DomPDF\Facade\Pdf;

        $pdf = \Barryvdh\DomPDF\Facade\Pdf::loadView('pdf.invoice', compact('order'));
        return $pdf->download('invoice_' . $order->id . '.pdf');
    }

    public function export(Request $request)
    {
        $query = Order::with([
            'user',
            'refundApprover',
            'orderItems.product.vendor'
        ]);

        // Apply filters
        if ($search = $request->input('search')) {
            $query->where(function ($q) use ($search) {
                $q->where('id', 'like', "%{$search}%")
                    ->orWhere('order_code', 'like', "%{$search}%")
                    ->orWhereHas('user', function ($userQuery) use ($search) {
                        $userQuery->where('full_name', 'like', "%{$search}%");
                    })
                    ->orWhereHas('orderItems.product.vendor', function ($vendorQuery) use ($search) {
                        $vendorQuery->where('name', 'like', "%{$search}%");
                    });
            });
        }
        if ($status = $request->input('status')) {
            $query->where('order_status', $status);
        }
        if ($paymentStatus = $request->input('payment_status')) {
            $query->where('payment_status', $paymentStatus);
        }
        if ($dateFrom = $request->input('date_from')) {
            $query->whereDate('created_at', '>=', $dateFrom);
        }
        if ($dateTo = $request->input('date_to')) {
            $query->whereDate('created_at', '<=', $dateTo);
        }

        $orders = $query->get();

        $headers = [
            'Content-Type' => 'text/csv',
            'Content-Disposition' => 'attachment; filename="orders.csv"',
        ];

        $callback = function () use ($orders) {
            $handle = fopen('php://output', 'w');
            // CSV header
            fputcsv($handle, [
                'Order ID',
                'User Name',
                'User Email',
                'Vendor Name',
                'Coupon ID',
                'Shipping Address',
                'Billing Address',
                'Total Items',
                'Subtotal',
                'Tax',
                'Discount',
                'Shipping Fee',
                'Total Amount',
                'Order Summary',
                'Order Status',
                'Payment Status',
                'Delivery Status',
                'Refund Status',
                'Transaction ID',
                'Payment Method',
                'Refund Approved By',
                'Refund Requested At',
                'Refund Rejection Reason (EN)',
                'Refund Rejection Reason (AR)',
                'Order Items',
                'Created At',
                'Updated At',
            ]);
            foreach ($orders as $order) {
                $vendor = $order->orderItems->first()?->product->vendor;
                $orderItemsArr = $order->orderItems->map(function ($item) {
                    return [
                        'product' => $item->product->name_en ?? '',
                        'quantity' => $item->quantity,
                        'amount' => $item->amount,
                        'tax_amount' => $item->tax_amount,
                        'discount_applied' => $item->discount_applied,
                        'total_amount' => $item->total_amount,
                        'delivery_status' => $item->delivery_status,
                    ];
                });
                fputcsv($handle, [
                    $order->id,
                    $order->user->full_name ?? '',
                    $order->user->email ?? '',
                    $vendor ? $vendor->name : 'N/A',
                    $order->coupon_id,
                    $order->shipping_address,
                    $order->billing_address,
                    $order->total_items,
                    $order->sub_total_amount,
                    $order->tax_amount,
                    $order->discount_amount,
                    $order->shipping_fee,
                    $order->total_amount,
                    $order->order_summary,
                    $order->order_status,
                    $order->payment_status,
                    $order->delivery_status,
                    $order->refund_status,
                    $order->transaction_id,
                    $order->payment_method,
                    $order->refund_approved_by,
                    $order->refund_requested_at,
                    $order->refund_rejection_reason_en,
                    $order->refund_rejection_reason_ar,
                    json_encode($orderItemsArr),
                    $order->created_at ? $order->created_at->format('d/m/Y') : '',
                    $order->updated_at ? $order->updated_at->format('d/m/Y') : '',
                ]);
            }
            fclose($handle);
        };

        return new \Symfony\Component\HttpFoundation\StreamedResponse($callback, 200, $headers);
    }

    public function vendorExport(Request $request)
    {
        $vendor = $request->user()->vendor;
        $query = $vendor->orders()->with([
            'user:id,full_name,email,mobile,phone',
            'refundApprover:id,full_name,email',
            'orderItems:id,order_id,product_id,quantity,amount',
            'orderItems.product:id,name_en,name_ar,vendor_id',
            'orderItems.product.vendor:id,name,brand_name_en,email,mobile,user_id',
            'orderItems.product.vendor.user.addresses' => function ($q) {
                $q->where('role_name', 'vendor')->with(['country', 'state', 'city']);
            }
        ]);

        if ($search = $request->input('search')) {
            $query->where(function ($q) use ($search) {
                $q->where('id', 'like', "%{$search}%")
                    ->orWhere('order_code', 'like', "%{$search}%")
                    ->orWhereHas('user', function ($userQuery) use ($search) {
                        $userQuery->where('full_name', 'like', "%{$search}%");
                    })
                    ->orWhereHas('orderItems.product.vendor', function ($vendorQuery) use ($search) {
                        $vendorQuery->where('name', 'like', "%{$search}%");
                    });
            });
        }
        if ($status = $request->input('status')) {
            $query->where('order_status', $status);
        }
        if ($paymentStatus = $request->input('payment_status')) {
            $query->where('payment_status', $paymentStatus);
        }
        if ($dateFrom = $request->input('date_from')) {
            $query->whereDate('created_at', '>=', $dateFrom);
        }
        if ($dateTo = $request->input('date_to')) {
            $query->whereDate('created_at', '<=', $dateTo);
        }

        $orders = $query->get();

        $headers = [
            'Content-Type' => 'text/csv',
            'Content-Disposition' => 'attachment; filename="vendor_orders.csv"',
        ];

        $callback = function () use ($orders) {
            $handle = fopen('php://output', 'w');
            // CSV header
            fputcsv($handle, [
                '#',
                'Order Code',
                'User Name',
                'User Email',
                'Vendor Name',
                'Coupon ID',
                'Shipping Address',
                'Billing Address',
                'Total Items',
                'Subtotal',
                'Tax',
                'Discount',
                'Shipping Fee',
                'Total Amount',
                'Order Summary',
                'Order Status',
                'Payment Status',
                'Delivery Status',
                'Refund Status',
                'Transaction ID',
                'Payment Method',
                'Refund Approved By',
                'Refund Requested At',
                'Refund Rejection Reason (EN)',
                'Refund Rejection Reason (AR)',
                'Order Items',
                'Created At',
                'Updated At',
            ]);
            foreach ($orders as $order) {
                $vendor = $order->orderItems->first()?->product->vendor;
                $orderItemsArr = $order->orderItems->map(function ($item) {
                    return [
                        'product' => $item->product->name_en ?? '',
                        'quantity' => $item->quantity,
                        'amount' => $item->amount,
                        'tax_amount' => $item->tax_amount,
                        'discount_applied' => $item->discount_applied,
                        'total_amount' => $item->total_amount,
                        'delivery_status' => $item->delivery_status,
                    ];
                });
                static $rowNumber = 1;
                fputcsv($handle, [
                    $rowNumber++,
                    $order->order_code,
                    $order->user->full_name ?? '',
                    $order->user->email ?? '',
                    $vendor ? $vendor->name : 'N/A',
                    $order->coupon_id,
                    $order->shipping_address,
                    $order->billing_address,
                    $order->total_items,
                    $order->sub_total_amount,
                    $order->tax_amount,
                    $order->discount_amount,
                    $order->shipping_fee,
                    $order->total_amount,
                    $order->order_summary,
                    $order->order_status,
                    $order->payment_status,
                    $order->delivery_status,
                    $order->refund_status,
                    $order->transaction_id,
                    $order->payment_method,
                    $order->refund_approved_by,
                    $order->refund_requested_at,
                    $order->refund_rejection_reason_en,
                    $order->refund_rejection_reason_ar,
                    json_encode($orderItemsArr),
                    $order->created_at ? $order->created_at->format('d/m/Y') : '',
                    $order->updated_at ? $order->updated_at->format('d/m/Y') : '',
                ]);
            }
            fclose($handle);
        };

        return new \Symfony\Component\HttpFoundation\StreamedResponse($callback, 200, $headers);
    }

    /**
     * Send email to customer
     */
    public function sendEmailToCustomer(Request $request, $id)
    {
        try {
            $order = Order::with([
                'user:id,full_name,email,mobile,phone',
                'refundApprover:id,full_name,email',
                'orderItems.product.vendor:id,name,brand_name_en'
            ])->findOrFail($id);

            $request->validate([
                'subject' => 'required|string|max:255',
                'message' => 'required|string',
            ]);

            $subject = trim((string) $request->input('subject'));
            $messageBody = trim((string) $request->input('message'));

            if (empty($subject) || empty($messageBody)) {
                return back()->with('error', 'Subject and message cannot be empty');
            }

            if (!$order->user || !$order->user->email) {
                return back()->with('error', 'Customer email not found');
            }

            // Get vendor name from first order item (if exists)
            $vendorName = 'N/A';
            if (
                $order->orderItems &&
                count($order->orderItems) > 0 &&
                $order->orderItems[0]->product &&
                $order->orderItems[0]->product->vendor
            ) {
                $vendorName = $order->orderItems[0]->product->vendor->name;
            }

            $emailData = [
                'order_id' => $order->id,
                'user_name' => $order->user->full_name ?? 'Customer',
                'order_date' => $order->created_at ? $order->created_at->format('d M Y, H:i') : 'N/A',
                'total_amount' => $order->total_amount ? number_format($order->total_amount, 2) : '0.00',
                'order_status' => $order->order_status ? ucfirst($order->order_status) : 'Unknown',
                'vendor_name' => $vendorName,
                'subject' => $subject,
                'message_body' => $messageBody,
            ];


            try {
                Mail::send('emails.order-notification', $emailData, function ($message) use ($order, $subject) {
                    $message->to($order->user->email, $order->user->full_name)
                        ->subject($subject);
                });
            } catch (\Exception $mailException) {
                throw $mailException;
            }

            return redirect()->back()->with('success', 'Email sent successfully!');
        } catch (\Illuminate\Validation\ValidationException $e) {
            return back()->withErrors($e->errors())->with('error', 'Validation error occurred');
        } catch (\Exception $e) {
            return back()->with('error', 'Failed to send email: ' . $e->getMessage());
        }
    }

    /**
     * Contact vendor about order
     */
    public function contactVendor(Request $request, $id)
    {
        try {
            $order = Order::with([
                'user:id,full_name,email,mobile',
                'refundApprover:id,full_name,email',
                'orderItems.product.vendor:id,name,user_id'
            ])->findOrFail($id);

            // Load vendor users separately to avoid relationship issues
            $order->load('orderItems.product.vendor.user:id,full_name,email');

            $request->validate([
                'subject' => 'required|string|max:255',
                'message' => 'required|string',
            ]);

            // Ensure we have clean string data
            $subject = trim((string) $request->input('subject'));
            $messageBody = trim((string) $request->input('message'));


            if (empty($subject) || empty($messageBody)) {
                return back()->with('error', 'Subject and message cannot be empty');
            }

            // Get vendors from order items
            $vendors = $order->orderItems->map(function ($item) {
                return $item->product->vendor;
            })->unique('id')->filter();

            if ($vendors->isEmpty()) {
                return back()->with('error', 'No vendors found for this order');
            }

            $sentCount = 0;
            foreach ($vendors as $vendor) {
                if ($vendor->user && $vendor->user->email) {
                    // Prepare email data - use simple array to avoid circular references
                    $emailData = [
                        'order_id' => $order->id,
                        'vendor_name' => $vendor->user->full_name ?? 'Vendor',
                        'vendor_email' => $vendor->user->email ?? '',
                        'customer_name' => $order->user->full_name ?? 'N/A',
                        'customer_email' => $order->user->email ?? 'N/A',
                        'customer_phone' => $order->user->mobile ?? 'Not provided',
                        'order_date' => $order->created_at ? $order->created_at->format('d M Y, H:i') : 'N/A',
                        'total_amount' => $order->total_amount ? number_format($order->total_amount, 2) : '0.00',
                        'order_status' => $order->order_status ? ucfirst($order->order_status) : 'Unknown',
                        'subject' => $subject,
                        'message_body' => $messageBody,
                    ];

                    // Send email to vendor
                    try {
                        Mail::send('emails.vendor-notification', $emailData, function ($message) use ($vendor, $subject) {
                            $message->to($vendor->user->email, $vendor->user->full_name)
                                ->subject($subject);
                        });
                    } catch (\Exception $mailException) {
                        throw $mailException;
                    }
                    $sentCount++;
                }
            }

            return redirect()->back()->with('success', 'Email sent successfully!');
        } catch (\Illuminate\Validation\ValidationException $e) {
            return back()->withErrors($e->errors())->with('error', 'Validation error occurred');
        } catch (\Exception $e) {
            return back()->with('error', 'Failed to send email: ' . $e->getMessage());
        }
    }

    // tracking store 
    public function updateTracking(Request $request, $orderId)
    {

        $order = Order::with(['orderItems', 'fulfillments.fulfillmentItems'])->findOrFail($orderId);

        // Update or create fulfillment first
        $fulfillment = $order->fulfillments()->latest()->first();
        if (!$fulfillment) {
            $fulfillment = $order->fulfillments()->create([
                'order_id' => $order->id,
                'tracking_number' => $request->input('tracking_number'),
                'courier_partner' => $request->input('courier_partner'),
                'is_ready' => $request->input('is_ready', 0),
                'is_ready_at' => $request->input('is_ready_at'),
                'is_dispatched' => $request->input('is_dispatched', 0),
                'is_dispatched_at' => $request->input('is_dispatched_at'),
                'in_transit' => $request->input('in_transit', 0),
                'in_transit_at' => $request->input('in_transit_at'),
                'is_delivered' => $request->input('is_delivered', 0),
                'is_delivered_at' => $request->input('is_delivered_at'),
                'is_rto' => $request->input('is_rto', 0),
                'is_rto_at' => $request->input('is_rto_at'),
                'is_rto_recieved' => $request->input('is_rto_recieved', 0),
                'is_rto_recieved_at' => $request->input('is_rto_recieved_at'),
                'status' => 'processing', // will set below
            ]);
        } else {
            $fulfillment->tracking_number = $request->input('tracking_number');
            $fulfillment->courier_partner = $request->input('courier_partner');
            $fulfillment->is_ready = $request->input('is_ready', 0);
            $fulfillment->is_ready_at = $request->input('is_ready_at');
            $fulfillment->is_dispatched = $request->input('is_dispatched', 0);
            $fulfillment->is_dispatched_at = $request->input('is_dispatched_at');
            $fulfillment->in_transit = $request->input('in_transit', 0);
            $fulfillment->in_transit_at = $request->input('in_transit_at');
            $fulfillment->is_delivered = $request->input('is_delivered', 0);
            $fulfillment->is_delivered_at = $request->input('is_delivered_at');
            $fulfillment->is_rto = $request->input('is_rto', 0);
            $fulfillment->is_rto_at = $request->input('is_rto_at');
            $fulfillment->is_rto_recieved = $request->input('is_rto_recieved', 0);
        }

        // Set *_at fields only if status is true and *_at is not already set
        if ($fulfillment->is_ready && !$fulfillment->is_ready_at) {
            $fulfillment->is_ready_at = now();
            Notification::create([
                'order_id' => $order->id,
                'user_id' => $order->user_id,
                'message' => 'Order is ready for processing.',
                'type' => 'order_ready',
                'status' => 'active',
                'title' => 'Order Ready',
                'body' => 'Order is ready for processing.',
                'content' => 'Order is ready for processing.',
                'icon_image' => 'order-ready.png',
                'is_read' => 0,
            ]);
        }
        if ($fulfillment->is_dispatched && !$fulfillment->is_dispatched_at) {
            $fulfillment->is_dispatched_at = now();
            Notification::create([
                'order_id' => $order->id,
                'user_id' => $order->user_id,
                'message' => 'Order has been dispatched.',
                'type' => 'order_dispatched',
                'status' => 'active',
                'title' => 'Order Dispatched',
                'body' => 'Order has been dispatched.',
                'content' => 'Order has been dispatched.',
                'icon_image' => 'order-dispatched.png',
                'is_read' => 0,
            ]);
        }
        if ($fulfillment->in_transit && !$fulfillment->in_transit_at) {
            $fulfillment->in_transit_at = now();
            Notification::create([
                'order_id' => $order->id,
                'user_id' => $order->user_id,
                'message' => 'Order is in transit.',
                'type' => 'order_in_transit',
                'status' => 'active',
                'title' => 'Order In Transit',
                'body' => 'Order is in transit.',
                'content' => 'Order is in transit.',
                'icon_image' => 'order-in-transit.png',
                'is_read' => 0,
            ]);
        }
        if ($fulfillment->is_delivered && !$fulfillment->is_delivered_at) {
            $fulfillment->is_delivered_at = now();
            Notification::create([
                'order_id' => $order->id,
                'user_id' => $order->user_id,
                'message' => 'Order delivered successfully.',
                'type' => 'order_delivered',
                'status' => 'active',
                'title' => 'Order Delivered',
                'body' => 'Order delivered successfully.',
                'content' => 'Order delivered successfully.',
                'icon_image' => 'order-delivered.png',
                'is_read' => 0,
            ]);
        }
        if ($fulfillment->is_rto && !$fulfillment->is_rto_at) {
            $fulfillment->is_rto_at = now();
            Notification::create([
                'order_id' => $order->id,
                'user_id' => $order->user_id,
                'message' => 'Order marked as RTO.',
                'type' => 'order_rto',
                'status' => 'active',
                'title' => 'Order RTO',
                'body' => 'Order marked as RTO.',
                'content' => 'Order marked as RTO.',
                'icon_image' => 'order-rto.png',
                'is_read' => 0,
            ]);
        }
        if ($fulfillment->is_rto_recieved && !$fulfillment->is_rto_recieved_at) {
            $fulfillment->is_rto_recieved_at = now();
            Notification::create([
                'order_id' => $order->id,
                'user_id' => $order->user_id,
                'message' => 'RTO received for order.',
                'type' => 'order_rto_received',
                'status' => 'active',
                'title' => 'RTO Received',
                'body' => 'RTO received for order.',
                'content' => 'RTO received for order.',
                'icon_image' => 'order-rto-received.png',
                'is_read' => 0,
            ]);
        }
        // Set status, delivery_status, order_status based on latest state
        if ($fulfillment->is_rto_recieved) {
            $status = 'rto_received';
            $delivery_status = 'returned';
            $order_status = 'returned';
        } elseif ($fulfillment->is_rto) {
            $status = 'rto';
            $delivery_status = 'returned';
            $order_status = 'returned';
        } elseif ($fulfillment->is_delivered) {
            $status = 'delivered';
            $delivery_status = 'delivered';
            $order_status = 'delivered';
        } elseif ($fulfillment->in_transit) {
            $status = 'in_transit';
            $delivery_status = 'out_for_delivery';
            $order_status = 'out_for_delivery';
        } elseif ($fulfillment->is_dispatched) {
            $status = 'shipped';
            $delivery_status = 'shipped';
            $order_status = 'shipped';
        } elseif ($fulfillment->is_ready) {
            $status = 'processing';
            $delivery_status = 'processing';
            $order_status = 'processing';
        } else {
            $inputStatus = $request->input('tracking_status', $status ?? 'processing');
            // Map fulfillment status to valid order_status enum values
            $statusMap = [
                'ready' => 'processing',
                'dispatched' => 'shipped',
                'in_transit' => 'out_for_delivery',
                'delivered' => 'delivered',
                'rto' => 'returned',
                'rto_received' => 'returned',
            ];

            $status = $inputStatus;
            $delivery_status = $statusMap[strtolower($inputStatus)] ?? $inputStatus;
            $order_status = $statusMap[strtolower($inputStatus)] ?? 'processing';

            // Ensure order_status is a valid enum value
            $validOrderStatuses = ['pending', 'confirmed', 'processing', 'ready_for_pickup', 'shipped', 'out_for_delivery', 'delivered', 'cancelled', 'returned', 'failed'];
            if (!in_array($order_status, $validOrderStatuses)) {
                $order_status = 'processing';
            }

            // Ensure delivery_status is a valid enum value
            $validDeliveryStatuses = ['pending', 'processing', 'shipped', 'out_for_delivery', 'delivered', 'returned', 'failed'];
            if (!in_array($delivery_status, $validDeliveryStatuses)) {
                $delivery_status = 'processing';
            }
        }
        $fulfillment->status = $status;
        $fulfillment->save();

        // Now update order and orderItems with the same status
        $order->order_status = $order_status;
        $order->delivery_status = $delivery_status;
        $order->save();

        // Update FinanceTransaction status based on order status
        $this->updateFinanceTransactionStatus($order, $order_status);

        foreach ($order->orderItems as $item) {
            $item->delivery_status = $delivery_status;
            $item->save();
        }

        // If order is synced with Armada, sync status from Armada instead of manual update
        if (config('armada.enabled', false) && $order->is_armada_synced && $order->armada_order_id) {
            try {
                $armadaService = app(ArmadaService::class);

                // Get latest status from Armada
                $armadaOrder = $armadaService->getOrder($order->armada_order_id);

                if ($armadaOrder['success'] && isset($armadaOrder['data']['status'])) {
                    $armadaData = $armadaOrder['data'];
                    // Update order status based on Armada's status
                    $armadaStatus = $armadaData['status'];
                    $mappedStatus = $armadaService->mapArmadaStatusToOrderStatus($armadaStatus);

                    // Get tracking number from Armada
                    $trackingNumber = $armadaData['trackingNumber'] ?? $armadaData['tracking_number'] ?? $order->armada_tracking_number;

                    // Update order with Armada's status
                    $order->order_status = $mappedStatus;
                    $order->delivery_status = $armadaStatus;
                    if ($trackingNumber) {
                        $order->armada_tracking_number = $trackingNumber;
                    }
                    $order->save();

                    // Update fulfillment with Armada tracking data
                    if ($trackingNumber) {
                        $fulfillment->tracking_number = $trackingNumber;
                    }
                    if (!$fulfillment->courier_partner || $fulfillment->courier_partner !== 'Armada') {
                        $fulfillment->courier_partner = 'Armada';
                    }

                    // Get fulfillment flags from Armada status
                    $fulfillmentFlags = $armadaService->getFulfillmentFlagsFromArmadaStatus($armadaStatus);
                    $fulfillment->status = $armadaStatus;
                    $fulfillment->is_ready = $fulfillmentFlags['is_ready'];
                    $fulfillment->is_dispatched = $fulfillmentFlags['is_dispatched'];
                    $fulfillment->in_transit = $fulfillmentFlags['in_transit'];
                    $fulfillment->is_delivered = $fulfillmentFlags['is_delivered'];
                    $fulfillment->is_rto = $fulfillmentFlags['is_rto'];
                    $fulfillment->is_rto_recieved = $fulfillmentFlags['is_rto_recieved'];

                    // Update timestamps
                    $now = now();
                    if ($fulfillment->is_ready && !$fulfillment->is_ready_at) {
                        $fulfillment->is_ready_at = $now;
                    }
                    if ($fulfillment->is_dispatched && !$fulfillment->is_dispatched_at) {
                        $fulfillment->is_dispatched_at = $now;
                    }
                    if ($fulfillment->in_transit && !$fulfillment->in_transit_at) {
                        $fulfillment->in_transit_at = $now;
                    }
                    if ($fulfillment->is_delivered && !$fulfillment->is_delivered_at) {
                        $fulfillment->is_delivered_at = $now;
                    }
                    if ($fulfillment->is_rto && !$fulfillment->is_rto_at) {
                        $fulfillment->is_rto_at = $now;
                    }
                    if ($fulfillment->is_rto_recieved && !$fulfillment->is_rto_recieved_at) {
                        $fulfillment->is_rto_recieved_at = $now;
                    }

                    $fulfillment->save();

                    // Update order items
                    foreach ($order->orderItems as $item) {
                        $item->delivery_status = $armadaStatus;
                        $item->save();
                    }
                } else {
                    // If can't get from Armada, update Armada with our status
                    $armadaStatus = $this->mapOrderStatusToArmadaStatus($order_status);
                    if ($armadaStatus) {
                        $armadaService->updateOrderStatus($order->armada_order_id, $armadaStatus);
                    }
                }
            } catch (\Exception $e) {
                Log::error('Armada status sync error', [
                    'order_id' => $order->id,
                    'status' => $order_status,
                    'error' => $e->getMessage(),
                ]);
            }
        }

        return back()->with('success', 'Order tracking status updated successfully.');
    }

    /**
     * Return tracking info for an order (from first fulfillment)
     */
    public function tracking($id)
    {
        $order = Order::with(['fulfillments'])->findOrFail($id);
        $fulfillment = $order->fulfillments->first();
        if (!$fulfillment) {
            return response()->json(['message' => 'No fulfillment found'], 404);
        }
        return response()->json([
            'tracking_number' => $fulfillment->tracking_number,
            'courier_partner' => $fulfillment->courier_partner,
            'delivery_status' => $fulfillment->status,
            'is_ready' => $fulfillment->is_ready,
            'is_dispatched' => $fulfillment->is_dispatched,
            'in_transit' => $fulfillment->in_transit,
            'is_delivered' => $fulfillment->is_delivered,
            'is_rto' => $fulfillment->is_rto,
            'is_rto_recieved' => $fulfillment->is_rto_recieved,
        ]);
    }

    /**
     * Cancel an order (set status to 'cancelled')
     */
    public function cancel($id)
    {
        $order = Order::with(['orderItems.product.vendor', 'vendor'])->findOrFail($id);
        if ($order->order_status === 'cancelled') {
            return back()->with('info', 'Order is already cancelled.');
        }
        if (in_array($order->order_status, ['delivered', 'refunded'])) {
            return back()->with('error', 'Order cannot be cancelled.');
        }

        // Initialize InventoryService to increase stock
        $inventoryService = new \App\Services\InventoryService();

        // Increase stock for all order items when order is cancelled
        foreach ($order->orderItems as $orderItem) {
            $product = $orderItem->product;
            $size = $orderItem->size ?? null;
            $color = $orderItem->color ?? null;

            // Increase stock back
            try {
                $inventoryService->increaseStock($product, $orderItem->quantity, $size, $color);
            } catch (\Exception $e) {
                Log::error("Failed to increase stock for product {$product->id} on cancellation: " . $e->getMessage());
                // Continue with other items even if one fails
            }
        }

        // Cancel order in Armada if synced
        if (config('armada.enabled', false) && $order->is_armada_synced && $order->armada_order_id) {
            try {
                $armadaService = app(ArmadaService::class);
                $armadaResult = $armadaService->cancelOrder($order->armada_order_id, 'Cancelled by admin/vendor');

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

        $order->order_status = 'cancelled';
        $order->save();

        // Update FinanceTransaction status when order is cancelled
        // This will create FinanceTransaction if it doesn't exist
        $this->updateFinanceTransactionStatus($order, 'cancelled');

        return back()->with('success', 'Order cancelled successfully.');
    }

    public function confirm($id)
    {
        $order = Order::with(['user', 'refundApprover', 'orderItems.product', 'vendor'])->findOrFail($id);

        // Only allow confirmation if order is pending
        if ($order->order_status !== 'pending') {
            return back()->with('error', 'Only pending orders can be confirmed.');
        }

        $order->order_status = 'confirmed'; // or whatever status you want after confirmation
        $order->save();

        // Get vendor from order
        $vendor = $order->vendor;
        if (!$vendor) {
            // Try to get vendor from order items
            $vendor = $order->orderItems->first()?->product?->vendor;
        }

        // Check if FinanceTransaction exists for this order
        $financeTransaction = FinanceTransaction::where('transaction_id', $order->transaction_id)
            ->where('type', 'order')
            ->where('vendor_id', $vendor?->id)
            ->first();

        // If FinanceTransaction doesn't exist, create it
        if (!$financeTransaction && $order->transaction_id) {
            $financeTransaction = FinanceTransaction::create([
                'user_id' => $order->user_id,
                'vendor_id' => $vendor?->id,
                'user_type' => 'user',
                'transaction_id' => $order->transaction_id,
                'type' => 'order',
                'summery' => 'Order Confirmed - Order #' . str_pad($order->id, 4, '0', STR_PAD_LEFT),
                'payment_processor' => $order->payment_method ?? 'system',
                'payment_reference_id' => $order->transaction_id,
                'amount' => $order->total_amount,
                'charge' => 0,
                'attempted_at' => now(),
                'attempt_status' => 'pending', // Keep as pending until delivered
            ]);
        } elseif ($financeTransaction) {
            // Update existing FinanceTransaction - order is confirmed but still pending delivery
            // Status remains 'pending' until order is delivered
            // Just update the summary to reflect confirmation
            $financeTransaction->update([
                'summery' => 'Order Confirmed - Order #' . str_pad($order->id, 4, '0', STR_PAD_LEFT),
            ]);
        }

        // Create fulfillment record with only order_id (will be updated with Armada data)
        $fulfillment = new Fulfillment();
        $fulfillment->order_id = $order->id;
        $fulfillment->status = 'confirmed';
        $fulfillment->save();

        // Send confirmation email to customer
        try {
            if ($order->user && $order->user->email) {
                // Get vendor name
                $vendorName = 'N/A';
                if ($order->vendor) {
                    $vendorName = $order->vendor->name;
                } elseif ($order->orderItems && count($order->orderItems) > 0 && $order->orderItems[0]->product && $order->orderItems[0]->product->vendor) {
                    $vendorName = $order->orderItems[0]->product->vendor->name;
                }

                $emailData = [
                    'order_id' => $order->id,
                    'user_name' => $order->user->full_name ?? 'Customer',
                    'order_date' => $order->created_at ? $order->created_at->format('d M Y, h:i A') : 'N/A',
                    'total_amount' => $order->total_amount ? number_format($order->total_amount, 2) : '0.00',
                    'payment_status' => $order->payment_status ? ucfirst($order->payment_status) : 'Pending',
                    'vendor_name' => $vendorName,
                    'order_url' => url('/orders/' . $order->id),
                ];

                Mail::send('emails.order-confirmed', $emailData, function ($message) use ($order) {
                    $message->to($order->user->email, $order->user->full_name ?? 'Customer')
                        ->subject('Order Confirmed - Order #' . str_pad($order->id, 4, '0', STR_PAD_LEFT));
                });

                Log::info('Order confirmation email sent', [
                    'order_id' => $order->id,
                    'user_email' => $order->user->email,
                ]);
            }
        } catch (\Exception $e) {
            // Log error but don't fail the order confirmation
            Log::error('Failed to send order confirmation email', [
                'order_id' => $order->id,
                'error' => $e->getMessage(),
            ]);
        }

        // Check if vendor uses Armada delivery
        $vendorUsesArmada = $order->vendor ? $order->vendor->use_armada_delivery : false;

        // If vendor doesn't use Armada, skip Armada integration
        if (!$vendorUsesArmada) {
            return back()->with('success', 'Order confirmed successfully. Vendor will handle delivery manually.');
        }

        // Integrate with Armada API - Create order in Armada when confirmed (only if vendor uses Armada)
        if (config('armada.enabled', false)) {
            // Use vendor's branch key for Armada
            $vendorBranchKey = $order->vendor->armada_branch_key ?? null;

            if (!$vendorBranchKey) {
                Log::warning('Vendor has no Armada branch key for order confirmation', [
                    'order_id' => $order->id,
                    'vendor_id' => $order->vendor->id ?? null,
                    'branch_key_set' => !empty($vendorBranchKey),
                ]);
            }

            try {
                // Get address from order
                $address = null;

                // First try: Check if order has address_id column (might be added later)
                if (Schema::hasColumn('orders', 'address_id') && $order->address_id) {
                    $address = Address::with(['city', 'state', 'country'])->find($order->address_id);
                    Log::info('Address found from order address_id', [
                        'order_id' => $order->id,
                        'address_id' => $order->address_id,
                        'address_found' => $address !== null,
                    ]);
                }

                // Second try: Try to get address from shippingAddress relationship
                if (!$address) {
                    try {
                        $order->load('shippingAddress');
                        if ($order->shippingAddress) {
                            $address = $order->shippingAddress;
                            $address->load(['city', 'state', 'country']);
                            Log::info('Address found from shippingAddress relationship', [
                                'order_id' => $order->id,
                                'address_id' => $address->id,
                            ]);
                        }
                    } catch (\Exception $e) {
                        Log::warning('Error loading shippingAddress relationship', [
                            'order_id' => $order->id,
                            'error' => $e->getMessage(),
                        ]);
                    }
                }

                // Third try: Get user's default address
                if (!$address) {
                    $address = Address::where('user_id', $order->user_id)
                        ->where('is_default', true)
                        ->with(['city', 'state', 'country'])
                        ->first();
                    Log::info('Address search from user default', [
                        'order_id' => $order->id,
                        'user_id' => $order->user_id,
                        'address_found' => $address !== null,
                    ]);
                }

                // Fourth try: Get any address for the user
                if (!$address) {
                    $address = Address::where('user_id', $order->user_id)
                        ->with(['city', 'state', 'country'])
                        ->first();
                    Log::info('Address search from any user address', [
                        'order_id' => $order->id,
                        'user_id' => $order->user_id,
                        'address_found' => $address !== null,
                    ]);
                }

                if ($address) {
                    $armadaService = app(ArmadaService::class);

                    // If not already synced, create order in Armada
                    if (!$order->is_armada_synced) {
                        // Prepare order data for Armada
                        $armadaOrderData = $armadaService->prepareOrderData($order, $address);

                        // Log prepared data
                        Log::info('Prepared Armada Order Data', [
                            'order_id' => $order->id,
                            'order_code' => $order->order_code,
                            'armada_order_data' => $armadaOrderData,
                        ]);

                        // Create order in Armada using vendor's branch key
                        $armadaResult = $armadaService->createOrder($armadaOrderData, $vendorBranchKey);

                        // Log result
                        Log::info('Armada Create Order Result', [
                            'order_id' => $order->id,
                            'success' => $armadaResult['success'] ?? false,
                            'armada_result' => $armadaResult,
                        ]);

                        if ($armadaResult['success']) {
                            $armadaData = $armadaResult['data'] ?? [];

                            // Debug: Log Armada response
                            Log::info('Armada API Response', [
                                'order_id' => $order->id,
                                'armada_result' => $armadaResult,
                                'armada_data' => $armadaData,
                            ]);

                            // Get status from Armada response (orderStatus field)
                            $armadaStatus = $armadaData['orderStatus'] ?? $armadaData['status'] ?? $armadaData['deliveryStatus'] ?? 'pending';
                            $mappedStatus = $armadaService->mapArmadaStatusToOrderStatus($armadaStatus);

                            // Get tracking number from Armada (check multiple possible fields)
                            $trackingNumber = $armadaResult['tracking_number']
                                ?? $armadaResult['trackingNumber']
                                ?? $armadaData['trackingNumber']
                                ?? $armadaData['tracking_number']
                                ?? $armadaData['code']  // Armada uses 'code' as tracking identifier
                                ?? $armadaData['id']
                                ?? $armadaResult['armada_order_id']
                                ?? null;

                            // Get Armada order ID
                            $armadaOrderId = $armadaResult['armada_order_id']
                                ?? $armadaData['id']
                                ?? $armadaData['orderId']
                                ?? $armadaData['code']  // Use code as order ID if id not available
                                ?? null;

                            // Map Armada status to valid delivery_status enum
                            $deliveryStatus = $armadaService->mapArmadaStatusToDeliveryStatus($armadaStatus);

                            // Prepare update data
                            $updateData = [
                                'armada_order_id' => $armadaOrderId,
                                'armada_tracking_number' => $trackingNumber,
                                'armada_response' => $armadaData,
                                'is_armada_synced' => true,
                                'delivery_status' => $deliveryStatus,
                            ];

                            // Only update order_status if it's not already confirmed
                            // If order was just confirmed, keep it as 'confirmed' instead of overwriting with Armada's 'pending'
                            if ($order->order_status !== 'confirmed') {
                                $updateData['order_status'] = $mappedStatus;
                            }

                            // Update order with Armada data
                            $order->update($updateData);

                            // Refresh order to get latest data from database
                            $order->refresh();

                            // Log order update confirmation
                            Log::info('Order updated with Armada data in database', [
                                'order_id' => $order->id,
                                'armada_order_id' => $order->armada_order_id,
                                'armada_tracking_number' => $order->armada_tracking_number,
                                'is_armada_synced' => $order->is_armada_synced,
                                'armada_response_stored' => !empty($order->armada_response),
                                'armada_response_keys' => $order->armada_response ? array_keys($order->armada_response) : [],
                                'order_status' => $order->order_status,
                                'delivery_status' => $order->delivery_status,
                            ]);

                            // Reload fulfillment to ensure we have the latest instance
                            $fulfillment->refresh();

                            // Automatically populate fulfillment with Armada tracking data
                            $fulfillment->tracking_number = $trackingNumber;
                            $fulfillment->courier_partner = 'Armada';
                            // Use mapped delivery status for fulfillment status
                            $fulfillment->status = $deliveryStatus;

                            // Get fulfillment flags from Armada status
                            $fulfillmentFlags = $armadaService->getFulfillmentFlagsFromArmadaStatus($armadaStatus);
                            $fulfillment->is_ready = $fulfillmentFlags['is_ready'] ? 1 : 0;
                            $fulfillment->is_dispatched = $fulfillmentFlags['is_dispatched'] ? 1 : 0;
                            $fulfillment->in_transit = $fulfillmentFlags['in_transit'] ? 1 : 0;
                            $fulfillment->is_delivered = $fulfillmentFlags['is_delivered'] ? 1 : 0;
                            $fulfillment->is_rto = $fulfillmentFlags['is_rto'] ? 1 : 0;
                            $fulfillment->is_rto_recieved = $fulfillmentFlags['is_rto_recieved'] ? 1 : 0;

                            // Set timestamps based on status
                            $now = now();
                            if ($fulfillment->is_ready && !$fulfillment->is_ready_at) {
                                $fulfillment->is_ready_at = $now;
                            }
                            if ($fulfillment->is_dispatched && !$fulfillment->is_dispatched_at) {
                                $fulfillment->is_dispatched_at = $now;
                            }
                            if ($fulfillment->in_transit && !$fulfillment->in_transit_at) {
                                $fulfillment->in_transit_at = $now;
                            }
                            if ($fulfillment->is_delivered && !$fulfillment->is_delivered_at) {
                                $fulfillment->is_delivered_at = $now;
                            }
                            if ($fulfillment->is_rto && !$fulfillment->is_rto_at) {
                                $fulfillment->is_rto_at = $now;
                            }
                            if ($fulfillment->is_rto_recieved && !$fulfillment->is_rto_recieved_at) {
                                $fulfillment->is_rto_recieved_at = $now;
                            }

                            // Save fulfillment with all data
                            $saved = $fulfillment->save();

                            Log::info('Fulfillment updated with Armada data', [
                                'order_id' => $order->id,
                                'fulfillment_id' => $fulfillment->id,
                                'tracking_number' => $trackingNumber,
                                'courier_partner' => $fulfillment->courier_partner,
                                'status' => $armadaStatus,
                                'saved' => $saved,
                                'fulfillment_data' => $fulfillment->toArray(),
                            ]);

                            Log::info('Order created in Armada successfully with tracking', [
                                'order_id' => $order->id,
                                'armada_order_id' => $armadaResult['armada_order_id'] ?? $armadaData['id'] ?? null,
                                'tracking_number' => $trackingNumber,
                                'status' => $armadaStatus,
                            ]);
                        } else {
                            Log::warning('Armada order creation failed during confirmation', [
                                'order_id' => $order->id,
                                'error' => $armadaResult['error'] ?? 'Unknown error',
                                'armada_result' => $armadaResult,
                            ]);
                        }
                    } else {
                        // Already synced orders should never recreate Armada orders from this action.
                        // We only nudge status/consistency on the existing Armada order.
                        if ($order->armada_order_id) {
                            $existingOrder = $armadaService->getOrder($order->armada_order_id);

                            if ($existingOrder['success']) {
                                $armadaService->updateOrderStatus($order->armada_order_id, 'confirmed');
                            } else {
                                Log::warning('Armada order not found for already-synced order; skipping recreation', [
                                    'order_id' => $order->id,
                                    'armada_order_id' => $order->armada_order_id,
                                ]);
                            }
                        } else {
                            Log::warning('Order marked as Armada-synced without armada_order_id; skipping recreation', [
                                'order_id' => $order->id,
                            ]);
                        }
                    }
                } else {
                    Log::warning('Address not found for Armada order creation', [
                        'order_id' => $order->id,
                    ]);
                }
            } catch (\Exception $e) {
                Log::error('Armada integration error during order confirmation', [
                    'order_id' => $order->id,
                    'error' => $e->getMessage(),
                    'trace' => $e->getTraceAsString(),
                ]);
            }
        }

        // Reload order and fulfillment to get latest data
        $order->refresh();
        $fulfillment->refresh();

        if ($fulfillment) {
            $notification = Notification::create([
                'order_id' => $order->id,
                'user_id' => $order->user_id,
                'message' => 'Order confirmed successfully.',
                'type' => 'order_confirmed',
                'status' => 'active',
                'title' => 'Order confirmed successfully.',
                'body' => 'Order confirmed successfully.',
                'content' => 'Order confirmed successfully.',
                'icon_image' => 'order-confirmed.png',
                'is_read' => 0,
            ]);
        }

        // Check if Armada is enabled and if order was synced
        $armadaEnabled = config('armada.enabled', false);
        $isSynced = $order->is_armada_synced ?? false;

        if ($armadaEnabled && $isSynced) {
            return back()->with('success', 'Order confirmed successfully. Tracking information has been automatically populated from Armada.');
        } else if ($armadaEnabled && !$isSynced) {
            return back()->with('warning', 'Order confirmed, but Armada sync failed. Please check logs for details.');
        }

        return back()->with('success', 'Order confirmed successfully.');
    }

    /**
     * Soft delete an order
     */
    public function destroy($id)
    {
        $order = Order::findOrFail($id);

        // Only allow soft delete if not already deleted
        if ($order->trashed()) {
            return back()->with('error', 'Order already deleted.');
        }

        $order->delete();

        return back();
    }

    /**
     * Sync order status from Armada
     * 
     * @param int $id
     * @return \Illuminate\Http\RedirectResponse
     */
    public function syncFromArmada($id)
    {
        $order = Order::findOrFail($id);

        if (!config('armada.enabled', false)) {
            return back()->with('error', 'Armada integration is not enabled.');
        }

        if (!$order->is_armada_synced || !$order->armada_order_id) {
            return back()->with('error', 'Order is not synced with Armada.');
        }

        try {
            $armadaService = app(ArmadaService::class);
            $armadaOrder = $armadaService->getOrder($order->armada_order_id);

            if ($armadaOrder['success'] && isset($armadaOrder['data'])) {
                $armadaData = $armadaOrder['data'];
                $armadaStatus = $armadaData['status'] ?? $order->delivery_status;
                $mappedStatus = $armadaService->mapArmadaStatusToOrderStatus($armadaStatus);

                // Get tracking number from Armada
                $trackingNumber = $armadaData['trackingNumber'] ?? $armadaData['tracking_number'] ?? $order->armada_tracking_number;

                // Update order
                $order->update([
                    'order_status' => $mappedStatus,
                    'delivery_status' => $armadaStatus,
                    'armada_response' => $armadaData,
                    'armada_tracking_number' => $trackingNumber,
                ]);

                // Update fulfillment with Armada tracking data
                $fulfillment = $order->fulfillments()->latest()->first();
                if ($fulfillment) {
                    // Update tracking information
                    if ($trackingNumber) {
                        $fulfillment->tracking_number = $trackingNumber;
                    }
                    if (!$fulfillment->courier_partner || $fulfillment->courier_partner !== 'Armada') {
                        $fulfillment->courier_partner = 'Armada';
                    }

                    // Get fulfillment flags from Armada status
                    $fulfillmentFlags = $armadaService->getFulfillmentFlagsFromArmadaStatus($armadaStatus);
                    $fulfillment->status = $armadaStatus;
                    $fulfillment->is_ready = $fulfillmentFlags['is_ready'];
                    $fulfillment->is_dispatched = $fulfillmentFlags['is_dispatched'];
                    $fulfillment->in_transit = $fulfillmentFlags['in_transit'];
                    $fulfillment->is_delivered = $fulfillmentFlags['is_delivered'];
                    $fulfillment->is_rto = $fulfillmentFlags['is_rto'];
                    $fulfillment->is_rto_recieved = $fulfillmentFlags['is_rto_recieved'];

                    // Update timestamps
                    $now = now();
                    if ($fulfillment->is_ready && !$fulfillment->is_ready_at) {
                        $fulfillment->is_ready_at = $now;
                    }
                    if ($fulfillment->is_dispatched && !$fulfillment->is_dispatched_at) {
                        $fulfillment->is_dispatched_at = $now;
                    }
                    if ($fulfillment->in_transit && !$fulfillment->in_transit_at) {
                        $fulfillment->in_transit_at = $now;
                    }
                    if ($fulfillment->is_delivered && !$fulfillment->is_delivered_at) {
                        $fulfillment->is_delivered_at = $now;
                    }
                    if ($fulfillment->is_rto && !$fulfillment->is_rto_at) {
                        $fulfillment->is_rto_at = $now;
                    }
                    if ($fulfillment->is_rto_recieved && !$fulfillment->is_rto_recieved_at) {
                        $fulfillment->is_rto_recieved_at = $now;
                    }

                    $fulfillment->save();
                }

                // Update order items
                foreach ($order->orderItems as $item) {
                    $item->delivery_status = $armadaStatus;
                    $item->save();
                }

                return back()->with('success', 'Order status synced from Armada successfully.');
            } else {
                return back()->with('error', 'Failed to sync order from Armada: ' . ($armadaOrder['error'] ?? 'Unknown error'));
            }
        } catch (\Exception $e) {
            Log::error('Armada sync error', [
                'order_id' => $order->id,
                'error' => $e->getMessage(),
            ]);

            return back()->with('error', 'Error syncing order from Armada: ' . $e->getMessage());
        }
    }

    /**
     * Map order status to Armada status
     * 
     * @param string $orderStatus
     * @return string|null
     */
    protected function mapOrderStatusToArmadaStatus(string $orderStatus): ?string
    {
        $statusMap = [
            'pending' => 'pending',
            'confirmed' => 'confirmed',
            'processing' => 'picked_up',
            'shipped' => 'in_transit',
            'out_for_delivery' => 'out_for_delivery',
            'delivered' => 'delivered',
            'cancelled' => 'cancelled',
            'failed' => 'failed',
            'returned' => 'returned',
        ];

        return $statusMap[strtolower($orderStatus)] ?? null;
    }
}
