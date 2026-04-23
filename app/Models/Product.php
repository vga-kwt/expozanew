<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\SoftDeletes;
use Illuminate\Support\Facades\Storage;
use App\Models\Order;

class Product extends Model
{
    use HasFactory, SoftDeletes;

    protected $fillable = [
        'name_en', 'name_ar', 'description_en', 'description_ar','attributes',
        'regular_price', 'sale_price', 'stock', 'views', 'image_url','gallery',  'category_id', 'vendor_id', 'status'
    ];

    protected $casts = [
        'gallery' => 'array',
        'attributes' => 'array',
        'regular_price' => 'decimal:2',
        'sale_price' => 'decimal:2',
        'views' => 'integer',
    ];

    protected $appends = ['vendor_name', 'image_url_full', 'gallery_urls'];

    public function getVendorNameAttribute()
    {
        return $this->vendor ? $this->vendor->name : 'Vendor Not Found';
    }

    /**
     * Get the full URL for the product image
     */
    public function getImageUrlFullAttribute()
    {
        if (!$this->image_url) {
            return null;
        }

        $disk = config('filesystems.default', 's3');
        
        if ($disk === 's3') {
            return Storage::disk('s3')->url($this->image_url);
        }
        
        return asset('storage/' . $this->image_url);
    }

    /**
     * Get full URLs for gallery images
     */
    public function getGalleryUrlsAttribute()
    {
        if (!$this->gallery || !is_array($this->gallery)) {
            return [];
        }

        $disk = config('filesystems.default', 's3');
        
        return array_map(function($path) use ($disk) {
            if ($disk === 's3') {
                return Storage::disk('s3')->url($path);
            }
            return asset('storage/' . $path);
        }, $this->gallery);
    }

    public function category() { return $this->belongsTo(Category::class); }
    public function vendor() { return $this->belongsTo(Vendor::class); }
    public function expo() { return $this->belongsTo(Expo::class); }
    public function section() { return $this->belongsTo(Section::class); }


    public function orderItems()
    {
        return $this->hasMany(OrderItem::class);
    }

    public function orders()
    {
        return $this->hasMany(Order::class);
    }

    public function waitingLists()
    {
        return $this->hasMany(WaitingList::class);
    }

    public function reviews()
    {
        return $this->hasMany(Review::class);
    }

    public function wishlists()
    {
        return $this->hasMany(Wishlist::class);
    }

    public function cartItems()
    {
        return $this->hasMany(CartItem::class);
    }

    public function sectionProducts()
    {
        return $this->hasMany(SectionProduct::class);
    }

    public function expoCoupons()
    {
        return $this->hasMany(\App\Models\ExpoProductCoupon::class);
    }

    public function expoProducts()
    {
        return $this->hasMany(ExpoProduct::class);
    }

    /**
     * Transform array output: replace image_url with image_url_full and gallery with gallery_urls
     */
    public function toArray()
    {
        $array = parent::toArray();
        
        // Replace image_url with image_url_full
        if (isset($array['image_url_full'])) {
            $array['image_url'] = $array['image_url_full'];
            unset($array['image_url_full']);
        }
        
        // Replace gallery with gallery_urls
        if (isset($array['gallery_urls'])) {
            $array['gallery'] = $array['gallery_urls'];
            unset($array['gallery_urls']);
        }
        
        return $array;
    }
} 