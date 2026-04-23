<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Carbon\Carbon;

class ExpoSeeder extends Seeder
{
    public function run(): void
    {
        $faker = \Faker\Factory::create();

        // 1. Participation wala Expo (paid)
        $startDate1 = Carbon::now()->addDays(rand(5, 30));
        $endDate1 = (clone $startDate1)->addDays(rand(3, 10));
        DB::table('expos')->insert([
            'name_en' => 'Participation Expo',
            'name_ar' => 'معرض المشاركة',
            'description_en' => $faker->sentence(10),
            'description_ar' => 'وصف للمعرض المشاركة',
            'background_color' => $faker->hexColor,
            'background_image' => $faker->imageUrl(800, 400, 'business'),
            'font_family' => $faker->randomElement(['Arial', 'Verdana', 'Roboto', 'Tahoma']),
            'font_style' => $faker->randomElement(['normal', 'italic']),
            'font_size' => $faker->randomElement(['14', '16', '18']),
            'font_color' => $faker->hexColor,
            'font_weight' => $faker->randomElement(['normal', 'bold']),
            'banner_image' => $faker->imageUrl(1200, 300, 'abstract'),
            'start_date' => $startDate1,
            'end_date' => $endDate1,
            'status' => $faker->randomElement(['upcoming', 'active', 'inactive', 'suspended', 'expired']),
            'vendor_slot_capacity' => $faker->numberBetween(10, 30),
            'product_capacity_per_slot' => $faker->numberBetween(5, 15),
            'slot_pricing' => json_encode([
                'basic' => $faker->randomFloat(2, 100, 500),
                'premium' => $faker->randomFloat(2, 600, 1500)
            ]), // yahan participation kimat hai
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        // 2. Free Expo (no participation fee)
        $startDate2 = Carbon::now()->addDays(rand(10, 35));
        $endDate2 = (clone $startDate2)->addDays(rand(4, 8));
        DB::table('expos')->insert([
            'name_en' => 'Free Expo',
            'name_ar' => 'معرض مجاني',
            'description_en' => $faker->sentence(8),
            'description_ar' => 'وصف للمعرض المجاني',
            'background_color' => $faker->hexColor,
            'background_image' => $faker->imageUrl(800, 400, 'business'),
            'font_family' => $faker->randomElement(['Arial', 'Verdana', 'Roboto', 'Tahoma']),
            'font_style' => $faker->randomElement(['normal', 'italic']),
            'font_size' => $faker->randomElement(['14', '16', '18']),
            'font_color' => $faker->hexColor,
            'font_weight' => $faker->randomElement(['normal', 'bold']),
            'banner_image' => $faker->imageUrl(1200, 300, 'abstract'),
            'start_date' => $startDate2,
            'end_date' => $endDate2,
            'status' => $faker->randomElement(['upcoming', 'active', 'inactive', 'suspended', 'expired']),
            'vendor_slot_capacity' => $faker->numberBetween(10, 30),
            'product_capacity_per_slot' => $faker->numberBetween(5, 15),
            'slot_pricing' => json_encode([
                'basic' => 0.00,
                'premium' => 0.00
            ]), // yahan free hai
            'created_at' => now(),
            'updated_at' => now(),
        ]);
    }
}
