<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class Section extends Model
{
    use SoftDeletes;
    protected $fillable = [
        'name', 'category_id', 'vendor_id', 'status'
    ];

    public function category()
    {
        return $this->belongsTo(Category::class);
    }

    public function sectionProducts()
    {
        return $this->hasMany(SectionProduct::class);
    }

    /**
     * Get the expos that this section is assigned to.
     */
    public function expos()
    {
        return $this->belongsToMany(Expo::class, 'expo_sections')
            ->withPivot(['vendor_id'])
            ->withTimestamps();
    }

    protected static function booted()
    {
        static::deleting(function ($section) {
            // If it's a force delete, also force delete children
            if ($section->isForceDeleting()) {
                $section->sectionProducts()->forceDelete();
            } else {
                $section->sectionProducts()->delete();
            }
        });
    }
} 