<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\SoftDeletes;

class Category extends Model
{
    use HasFactory, SoftDeletes;

    protected $fillable = [
        'parent_id',
        'name_en',
        'name_ar',
        'content',
        'image',
        'status'
    ];

    protected $appends = ['image_url'];

    /**
     * Get the full URL for the category image
     */
    public function getImageUrlAttribute()
    {
        if (!$this->image) {
            return null;
        }

        $disk = config('filesystems.default', 's3');
        
        if ($disk === 's3') {
            return \Storage::disk('s3')->url($this->image);
        }
        
        return asset('storage/' . $this->image);
    }
}
