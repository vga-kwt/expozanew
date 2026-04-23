<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\SoftDeletes;

class Order extends Model
{
    use HasFactory, SoftDeletes;

    protected $fillable = [
        'user_id',
        'vendor_id',
        'coupon_id',
        'order_code',
        'shipping_address',
        'billing_address',
        'total_items',
        'sub_total_amount',
        'tax_amount',
        'discount_amount',
        'total_amount',
        'order_status',
        'payment_status',
        'delivery_status',
        'refund_status',
        'refund_approved_by',
        'refund_requested_at',
        'refund_rejection_reason_en',
        'refund_rejection_reason_ar',
        'payment_method',
        'transaction_id',
        'shipping_fee',
        'order_summary',
        'payment_status',
        'refund_status',
        'transaction_id',
        'delivery_status',
        // Armada fields
        'armada_order_id',
        'armada_tracking_number',
        'armada_response',
        'is_armada_synced',
    ];

    protected $casts = [
        'armada_response' => 'array',
        'is_armada_synced' => 'boolean',
    ];

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function coupon(): BelongsTo
    {
        return $this->belongsTo(Coupon::class);
    }

    public function orderItems()
    {
        return $this->hasMany(OrderItem::class);
    }

    public function fulfillments()
    {
        return $this->hasMany(Fulfillment::class);
    }

    public function couponUsages()
    {
        return $this->hasMany(CouponUsage::class);
    }

    public function product()
    {
        return $this->hasManyThrough(
            Product::class,
            OrderItem::class,
            'order_id',
            'id',
            'id',
            'product_id'
        );
    }

    public function vendor()
    {
        return $this->belongsTo(Vendor::class);
    }

    public function expo()
    {
        return $this->belongsTo(Expo::class);
    }

    public function shippingAddress()
    {
        return $this->belongsTo(Address::class, 'address_id');
    }

    public function refundApprover()
    {
        return $this->belongsTo(User::class, 'refund_approved_by');
    }
    
}
