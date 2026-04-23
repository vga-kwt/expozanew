<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class ExpoProduct extends Model
{
    use SoftDeletes;

    protected $fillable = [
        'expo_id',
        'product_id',
        'vendor_id',
        'slot_id',
    ];

    public function product()
    {
        return $this->belongsTo(Product::class, 'product_id');
    }

    public function expo()
    {
        return $this->belongsTo(Expo::class, 'expo_id');
    }

    public function vendor()
    {
        return $this->belongsTo(Vendor::class, 'vendor_id');
    }
    
    public function slot()
    {
        return $this->belongsTo(SlotBooking::class, 'slot_id');
    }
}
