<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Banner;

class BannerSeeder extends Seeder
{
    public function run(): void
    {
        Banner::create([
            'title' => 'Summer Sale',
            'image' => 'banners/summer.jpg',
            'link' => 'https://example.com/sale',
            'status' => 'active',
        ]);
        Banner::create([
            'title' => 'Winter Collection',
            'image' => 'banners/winter.jpg',
            'link' => 'https://example.com/winter',
            'status' => 'active',
        ]);
    }
} 