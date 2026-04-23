<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class City extends Model
{
    use SoftDeletes;

    protected $fillable = [
        'country_id',
        'state_id',
        'name_en',
        'name_ar',
        'status',
    ];

    protected $casts = [
        'status' => 'string',
    ];

    // Scopes
    public function scopeActive($query)
    {
        return $query->where('status', 'active');
    }

    public function scopeSuspended($query)
    {
        return $query->where('status', 'suspended');
    }

    public function scopeSearch($query, $search)
    {
        return $query->where(function ($q) use ($search) {
            $q->where('name_en', 'like', "%{$search}%")
              ->orWhere('name_ar', 'like', "%{$search}%");
        });
    }

    public function scopeFilterByStatus($query, $status)
    {
        if ($status && $status !== 'all') {
            return $query->where('status', $status);
        }
        return $query;
    }

    public function scopeFilterByCountry($query, $countryId)
    {
        if ($countryId && $countryId !== 'all') {
            return $query->where('country_id', $countryId);
        }
        return $query;
    }

    public function scopeFilterByState($query, $stateId)
    {
        if ($stateId && $stateId !== 'all') {
            return $query->where('state_id', $stateId);
        }
        return $query;
    }

    // Relationships
    public function country()
    {
        return $this->belongsTo(Country::class);
    }

    public function state()
    {
        return $this->belongsTo(State::class);
    }

    // Accessors
    public function getDisplayNameAttribute()
    {
        return app()->getLocale() === 'ar' ? $this->name_ar : $this->name_en;
    }

    public function getStatusLabelAttribute()
    {
        return $this->status === 'active' ? 'Active' : 'Suspended';
    }

    public function getStatusLabelArAttribute()
    {
        return $this->status === 'active' ? 'نشط' : 'معلق';
    }
}
