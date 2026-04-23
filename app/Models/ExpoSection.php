<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class ExpoSection extends Model
{
    use SoftDeletes;
    use HasFactory;

    protected $fillable = [
        'expo_id',
        'vendor_id',
        'section_id',
        'slot_id',
    ];

    /**
     * Get the expo that owns the section assignment.
     */
    public function expo()
    {
        return $this->belongsTo(Expo::class);
    }

    /**
     * Get the vendor that owns the section assignment.
     */
    public function vendor()
    {
        return $this->belongsTo(Vendor::class);
    }

    /**
     * Get the section that is assigned.
     */
    public function section()
    {
        return $this->belongsTo(Section::class);
    }
    
    public function slot()
    {
        return $this->belongsTo(Slot::class);
    }
} 