<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Ad;
use Illuminate\Support\Str;

class AdSeeder extends Seeder
{
    public function run(): void
    {
        $faker = \Faker\Factory::create();

        for ($i = 1; $i <= 20; $i++) {
            Ad::create([
                'title_en'        => $faker->sentence(3),
                'title_ar'        => 'عنوان ' . $i,
                'description_en'  => $faker->paragraph,
                'description_ar'  => 'وصف ' . $i,
                'vendor_id'       => null,
                'link_type'       => $faker->randomElement(['product', 'vendor', 'expo', 'external']),
                'link_id'         => $faker->numberBetween(1, 10),
                'external_link'   => $faker->url,
                'banners'         => 'ads/banners/placeholder-' . $i . '.jpg',
                'status'          => $faker->randomElement(['active', 'suspended', 'draft']),
                'priority'        => $faker->numberBetween(0, 100),
                'start_date'      => $faker->dateTimeBetween('-1 month', '+1 month')->format('Y-m-d'),
                'end_date'        => $faker->dateTimeBetween('+2 months', '+4 months')->format('Y-m-d'),
            ]);
        }
    }
} 