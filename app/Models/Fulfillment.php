<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Fulfillment extends Model
{
    use HasFactory;

    protected $fillable = [
        'order_id',
        'courier_partner',
        'tracking_number',
        'is_ready',
        'is_ready_at',
        'is_dispatched',
        'is_dispatched_at',
        'in_transit',
        'in_transit_at',
        'is_delivered',
        'is_delivered_at',
        'is_rto',
        'is_rto_at',
        'is_rto_recieved',
        'is_rto_recieved_at',
        'status',
    ];

    public function order()
    {
        return $this->belongsTo(Order::class);
    }

    public function fulfillmentItems()
    {
        return $this->hasMany(FulfillmentItem::class, 'fullfilment_id');
    }
} 