<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Attribute extends Model
{
    use HasFactory;

    protected $fillable = [
        'parent_id',
        'name',
        'options',
        'status',
    ];

    protected $casts = [
        'options' => 'array',
    ];

    public function parent()
    {
        return $this->belongsTo(Attribute::class, 'parent_id');
    }

    public function children()
    {
        return $this->hasMany(Attribute::class, 'parent_id');
    }
} 