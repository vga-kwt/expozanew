<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Notification extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'order_id',
        'status',
        'type',
        'title',
        'body',
        'content',
        'icon_image',
        'is_read',
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function notificationViews()
    {
        return $this->hasMany(NotificationView::class);
    }

    public function order()
    {
        return $this->belongsTo(Order::class);
    }
}
