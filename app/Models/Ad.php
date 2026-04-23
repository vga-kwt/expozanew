<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\SoftDeletes;

class Ad extends Model
{
    use HasFactory, SoftDeletes;

    protected $fillable = [
        'vendor_id',
        'title_en',
        'title_ar',
        'description_en',
        'description_ar',
        'banners',
        'link_type',
        'link_id',
        'external_link',
        'status',
        'priority',
        'start_date',
        'end_date',
    ];

    protected $casts = [
        'banners' => 'string',
        'start_date' => 'date:Y-m-d',
        'end_date' => 'date:Y-m-d',
        'priority' => 'integer',
        'link_id' => 'integer',
    ];

    protected $appends = ['banner_url', 'full_link'];

    /**
     * Get the full URL for the banner image
     */
    public function getBannerUrlAttribute()
    {
        if (!$this->banners) {
            return null;
        }

        $disk = config('filesystems.default', 's3');
        
        if ($disk === 's3') {
            return \Storage::disk('s3')->url($this->banners);
        }
        
        return asset('storage/' . $this->banners);
    }

    /**
     * Get the vendor that owns this ad
     */
    public function vendor(): BelongsTo
    {
        return $this->belongsTo(Vendor::class, 'link_id');
    }

    /**
     * Get the product this ad links to (if link_type is 'product')
     */
    public function product(): BelongsTo
    {
        return $this->belongsTo(Product::class, 'link_id');
    }

    /**
     * Get the vendor this ad links to (if link_type is 'vendor')
     */
    public function linkedVendor(): BelongsTo
    {
        return $this->belongsTo(Vendor::class, 'link_id');
    }

    /**
     * Get the expo this ad links to (if link_type is 'expo')
     */
    public function expo(): BelongsTo
    {
        return $this->belongsTo(Expo::class, 'link_id');
    }

    /**
     * Get the linked item based on link_type
     */
    public function linkedItem()
    {
        return match ($this->link_type) {
            'product' => $this->product,
            'vendor' => $this->linkedVendor,
            'expo' => $this->expo,
            default => null,
        };
    }

    /**
     * Get the full link URL
     */
    public function getFullLinkAttribute(): ?string
    {
        if ($this->link_type === 'external') {
            return $this->external_link;
        }

        $item = $this->linkedItem();
        if ($item) {
            return match ($this->link_type) {
                'product' => "/products/{$item->id}",
                'vendor' => "/vendors/{$item->id}",
                'expo' => "/expos/{$item->id}",
                default => null,
            };
        }

        return null;
    }

    /**
     * Scope for active ads
     */
    public function scopeActive($query)
    {
        return $query->where('status', 'active')
            ->where(function ($q) {
                $q->whereNull('start_date')
                    ->orWhere('start_date', '<=', now());
            })
            ->where(function ($q) {
                $q->whereNull('end_date')
                    ->orWhere('end_date', '>=', now());
            });
    }

    /**
     * Scope for ordering by priority
     */
    public function scopeByPriority($query)
    {
        return $query->orderBy('display_priority', 'desc')
            ->orderBy('created_at', 'desc');
    }

    public function getStartDateAttribute($value)
    {
        return \Carbon\Carbon::parse($value)->format('Y-m-d H:i:s');
    }

    public function getEndDateAttribute($value)
    {
        return \Carbon\Carbon::parse($value)->format('Y-m-d H:i:s');
    }

    /**
     * Transform array output: replace banners with banner_url and hide banner_url
     */
    public function toArray()
    {
        $array = parent::toArray();
        
        // Replace banners with banner_url value
        if (isset($array['banner_url'])) {
            $array['banners'] = $array['banner_url'];
            unset($array['banner_url']);
        }
        
        return $array;
    }
}
