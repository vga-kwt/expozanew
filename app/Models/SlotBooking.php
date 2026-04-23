<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class SlotBooking extends Model
{
    protected $fillable = [
        'expo_id',
        'vendor_id',
        'vendor_expo_id',
        'booked_slots',
        'slot_number',
        'total_amount',
        'payment_status',
        'transaction_id'
    ];

    protected $casts = [
        'booked_slots' => 'array',
    ];

    public function expo()
    {
        return $this->belongsTo(Expo::class);
    }
    public function vendor()
    {
        return $this->belongsTo(Vendor::class);
    }

    
   
}
