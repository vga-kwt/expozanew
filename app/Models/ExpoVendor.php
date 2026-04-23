<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class ExpoVendor extends Model
{
    protected $table = 'expo_vendor';
    public $incrementing = false;
    public $timestamps = true;

    // Add your fillable fields here:
    protected $fillable = [
        'expo_id',
        'vendor_id',
        'name',
        'description',
        'address_id',
        'email',
        'mobile',
        'slot',
        'status',
        'products_count',
        'notes',
        'approved_at',
        'joined_at',
    ];

    protected $casts = [
        'approved_at' => 'datetime',
        'joined_at' => 'datetime',
        'created_at' => 'datetime',
        'updated_at' => 'datetime',
    ];

    public function expo()
    {
        return $this->belongsTo(Expo::class, 'expo_id');
    }

    public function vendor()
    {
        return $this->belongsTo(Vendor::class, 'vendor_id');
    }

    public function products()
    {
        return $this->hasMany(Product::class, 'vendor_id', 'vendor_id');
    }

    public function categories()
    {
        return $this->hasMany(Category::class, 'vendor_id', 'vendor_id');
    }
    public function products_count()
    {
        return $this->products()->count();
    }

    public function expoProducts()
    {
        return $this->hasMany(Product::class, 'vendor_id', 'vendor_id');
    }
}
