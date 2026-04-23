<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;
use App\Models\Order;
use App\Models\OrderItem;

class Vendor extends Model
{
    use SoftDeletes;
    use HasFactory;

    protected $fillable = [
        'category_id',
        'name',
        'brand_name_en',
        'brand_name_ar',
        'email',
        'mobile',
        'status',
        'commission',
        'kyc_status',
        'kyc_rejection_reason_en',
        'kyc_rejection_reason_ar',
        'kyc_documents',
        'description_en',
        'description_ar',
        'logo',
        'subscription_id',
        'user_id',
        'use_armada_delivery',
        'armada_branch_id',
        'armada_branch_key',
        'latitude',
        'longitude',
        'address_text',
    ];

    protected $casts = [
        'kyc_documents' => 'array',
        'use_armada_delivery' => 'boolean',
        'latitude' => 'decimal:7',
        'longitude' => 'decimal:7',
    ];

    protected $appends = ['logo_url', 'kyc_documents_urls'];

    /**
     * Get the full URL for the vendor logo
     */
    public function getLogoUrlAttribute()
    {
        if (!$this->logo) {
            return null;
        }

        $disk = config('filesystems.default', 's3');

        if ($disk === 's3') {
            return \Storage::disk('s3')->url($this->logo);
        }

        return asset('storage/' . $this->logo);
    }

    /**
     * Get full URLs for KYC documents
     */
    public function getKycDocumentsUrlsAttribute()
    {
        if (!$this->kyc_documents || !is_array($this->kyc_documents)) {
            return [];
        }

        $disk = config('filesystems.default', 's3');
        $urls = [];

        foreach ($this->kyc_documents as $key => $path) {
            if ($path) {
                if ($disk === 's3') {
                    $urls[$key] = \Storage::disk('s3')->url($path);
                } else {
                    $urls[$key] = asset('storage/' . $path);
                }
            }
        }

        return $urls;
    }

    /**
     * Get the user that owns the vendor.
     */
    public function user()
    {
        return $this->belongsTo(User::class, 'user_id');
    }

    /**
     * Get the subscription for the vendor.
     */
    public function subscription()
    {
        return $this->belongsTo(Subscription::class);
    }

    /**
     * Get the subscription history for the vendor.
     */
    public function subscriptions()
    {
        return $this->hasMany(VendorSubscription::class);
    }

    /**
     * Get the orders for the vendor through products.
     */
    public function orders()
    {
        return $this->hasMany(Order::class);
    }

    /**
     * Get the products for the vendor.
     */
    public function products()
    {
        return $this->hasMany(Product::class);
    }

    public function expoproducts()
    {
        return $this->hasMany(ExpoProduct::class);
    }


    /**
     * Get the sections for the vendor.
     */
    public function sections()
    {
        return $this->hasMany(Section::class);
    }

    /**
     * Get the expo participations for the vendor.
     */
    public function expoParticipations()
    {
        return $this->belongsToMany(Expo::class, 'expo_vendor')
            ->withPivot(['slot', 'status', 'joined_at'])
            ->withTimestamps();
    }

    /**
     * Get the expos that the vendor has joined.
     */
    public function expos()
    {
        return $this->belongsToMany(Expo::class, 'expo_vendor')
            ->withPivot(['slot', 'status', 'joined_at', 'products_count', 'approved_at']);
    }

    public function getOrdersAttribute()
    {
        return Order::whereHas('orderItems.product', function ($query) {
            $query->where('vendor_id', $this->id);
        })->get();
    }

    public function categories()
    {
        return $this->belongsTo(Category::class, 'category_id');
    }

    /**
     * Check if vendor has an active subscription
     */
    public function hasActiveSubscription(): bool
    {
        $activeSubscription = $this->subscriptions()
            ->where('status', 'active')
            ->where('end_date', '>=', now())
            ->where('payment_status', 'paid')
            ->orderByDesc('end_date')
            ->first();

        return $activeSubscription !== null;
    }

    /**
     * Get the current active subscription
     */
    public function getActiveSubscription()
    {
        return $this->subscriptions()
            ->where('status', 'active')
            ->where('end_date', '>=', now())
            ->where('payment_status', 'paid')
            ->orderByDesc('end_date')
            ->first();
    }

    /**
     * Transform array output: replace logo with logo_url and kyc_documents with kyc_documents_urls
     */
    public function toArray()
    {
        $array = parent::toArray();

        // Replace logo with logo_url
        if (isset($array['logo_url'])) {
            $array['logo'] = $array['logo_url'];
            unset($array['logo_url']);
        }

        // Replace kyc_documents with kyc_documents_urls
        if (isset($array['kyc_documents_urls']) && is_array($array['kyc_documents_urls'])) {
            unset($array['kyc_documents']); // Remove original first
            $array['kyc_documents'] = $array['kyc_documents_urls']; // Set with URLs
            unset($array['kyc_documents_urls']); // Remove the _urls field
        }

        return $array;
    }
}
