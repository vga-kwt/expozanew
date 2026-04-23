<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Factories\HasFactory;

class Expo extends Model
{
    use HasFactory;

    protected $fillable = [
        'id',
        'name_en',
        'name_ar',
        'description_en',
        'description_ar',
        'background_color',
        'background_image',
        'font_family',
        'font_color',
        'font_style',
        'font_size',
        'font_weight',
        'banner_image',
        'start_date',
        'end_date',
        'status',
        'created_at',
        'updated_at',
        'vendor_slot_capacity',
        'product_capacity_per_slot',
        'slot_pricing',
        'free_participation',
    ];

    protected $appends = ['background_image_url', 'banner_image_url'];

    protected $casts = [
        'slot_pricing' => 'array',
        'free_participation' => 'boolean',
    ];

    /**
     * Get the full URL for the background image
     */
    public function getBackgroundImageUrlAttribute()
    {
        if (!$this->background_image) {
            return null;
        }

        $disk = config('filesystems.default', 's3');
        
        if ($disk === 's3') {
            return \Storage::disk('s3')->url($this->background_image);
        }
        
        return asset('storage/' . $this->background_image);
    }

    /**
     * Get the full URL for the banner image
     */
    public function getBannerImageUrlAttribute()
    {
        if (!$this->banner_image) {
            return null;
        }

        $disk = config('filesystems.default', 's3');
        
        if ($disk === 's3') {
            return \Storage::disk('s3')->url($this->banner_image);
        }
        
        return asset('storage/' . $this->banner_image);
    }

    public function expoParticipations()
    {
        return $this->belongsToMany(Vendor::class, 'expo_vendor')
            ->withPivot(['slot', 'status', 'joined_at'])
            ->withTimestamps();
    }

    public function categories()
    {
        return $this->belongsToMany(Category::class, 'expo_category');
    }

    public function slots()
    {
        return $this->hasMany(ExpoSlot::class);
    }

    public function vendors()
    {
        return $this->belongsToMany(Vendor::class, 'expo_vendor', 'expo_id', 'vendor_id')
            ->withTimestamps();
    }

    public function products()
    {
        return $this->hasMany(Product::class, 'expo_id');
    }

    public function expoVendors()
    {
        return $this->hasMany(ExpoVendor::class, 'expo_id');
    }

    public function expoProducts()
    {
        return $this->hasMany(ExpoProduct::class, 'expo_id');
    }

    /**
     * Get the sections assigned to this expo.
     */
    public function sections()
    {
        return $this->belongsToMany(Section::class, 'expo_sections')
            ->withPivot(['vendor_id'])
            ->withTimestamps();
    }

    /**
     * Get the expo sections assignments.
     */
    public function expoSections()
    {
        return $this->hasMany(ExpoSection::class, 'expo_id');
    }

    /**
     * Get the ads that link to this expo.
     */
    public function ads()
    {
        return $this->hasMany(Ad::class, 'link_id')->where('link_type', 'expo');
    }


     /**
     * Transform array output: replace background_image with background_image_url and hide background_image_url
     */
    public function toArray()
    {
        $array = parent::toArray();
        
        // Replace background_image with background_image_url value
        if (isset($array['background_image_url'])) {
            $array['background_image'] = $array['background_image_url'];
            unset($array['background_image_url']);
        }

          // Replace banner_image with banner_image_url value
          if (isset($array['banner_image_url'])) {
            $array['banner_image'] = $array['banner_image_url'];
            unset($array['banner_image_url']);
        }
        
        
        return $array;
    }
    
}
