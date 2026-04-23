<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class ExpoProductCoupon extends Model
{
    protected $fillable = [
        'expo_id', 'product_id', 'vendor_id', 'discount'
    ];
} 