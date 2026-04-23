<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class ExpoSlot extends Model
{
    use HasFactory;

    protected $fillable = [
        'expo_id',
        'name',
        'vendor_slot_capacity',
        'product_capacity_per_slot',
        'slot_pricing',
        'status',
    ];

    protected $casts = [
        'slot_pricing' => 'decimal:2',
    ];

    public function expo()
    {
        return $this->belongsTo(Expo::class);
    }
} 