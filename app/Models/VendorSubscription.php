<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class VendorSubscription extends Model
{
    use HasFactory;

    protected $fillable = [
        'vendor_id',
        'subscription_id',
        'start_date',
        'end_date',
        'status',
        'payment_status',
        'transaction_id',
        'price',
        'type',
    ];

    public function vendor()
    {
        return $this->belongsTo(Vendor::class);
    }

    public function subscription()
    {
        return $this->belongsTo(Subscription::class);
    }

    public function transactions()
    {
        return $this->morphMany(FinanceTransaction::class, 'transactionable');
    }
} 