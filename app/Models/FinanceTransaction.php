<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class FinanceTransaction extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'vendor_id',
        'user_type',
        'transaction_id',
        'type',
        'summery',
        'payment_processor',
        'payment_reference_id',
        'amount',
        'charge',
        'attempted_at',
        'attempt_status',
    ];

    protected $casts = [
        'metadata' => 'array',
        'processed_at' => 'datetime',
    ];

    public function transactionable()
    {
        return $this->morphTo();
    }

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function vendor()
    {
        return $this->belongsTo(Vendor::class);
    }

    public function scopeCompleted($query)
    {
        return $query->where('attempt_status', 'completed');
    }

    public function scopePending($query)
    {
        return $query->where('attempt_status', 'pending');
    }

    public function scopeByType($query, $type)
    {
        return $query->where('type', $type);
    }
} 