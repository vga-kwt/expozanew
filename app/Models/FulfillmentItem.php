<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class FulfillmentItem extends Model
{
    use HasFactory;

    protected $fillable = [
        'fullfilment_id',
        'item_id',
        'quantity',
    ];

    public function fulfillment()
    {
        return $this->belongsTo(Fulfillment::class, 'fullfilment_id');
    }

    public function orderItem()
    {
        return $this->belongsTo(OrderItem::class, 'item_id');
    }
} 