<?php

namespace Database\Seeders;

use App\Models\Category;
use App\Models\Product;
use App\Models\Vendor;
use App\Models\Expo;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

class ProductSeeder extends Seeder
{
    public function run(): void
    {
        $faker = \Faker\Factory::create();
        $categories = Category::all();
        $vendors = Vendor::all();

        if ($categories->count() === 0 || $vendors->count() === 0) {
            $this->command->warn('Please seed categories and vendors before products.');
            return;
        }

        // pehle ek vendor ke liye 5 product
        $singleVendor = $vendors->first();
        if ($singleVendor) {
            for ($i = 0; $i < 5; $i++) {
                $category = $categories->random();
                DB::table('products')->insert([
                    'category_id' => $category->id,
                    'vendor_id' => $singleVendor->id,
                    'parent_id' => null,
                    'name_en' => $faker->words(3, true),
                    'name_ar' => 'منتج ' . $faker->numberBetween(1, 100),
                    'description_en' => $faker->sentence(10),
                    'description_ar' => 'وصف المنتج ' . $faker->numberBetween(1, 100),
                    'views' => $faker->numberBetween(0, 1000),
                    'attributes' => json_encode([
                        'color' => $faker->randomElement(['Red', 'Blue', 'Green']),
                        'size' => $faker->randomElement(['S', 'M', 'L', 'XL']),
                    ]),
                    'regular_price' => $faker->randomFloat(2, 50, 500),
                    'sale_price' => $faker->randomFloat(2, 30, 400),
                    'image_url' => $faker->imageUrl(400, 400, 'product'),
                    'gallery' => json_encode([
                        $faker->imageUrl(400, 400, 'product'),
                        $faker->imageUrl(400, 400, 'product'),
                    ]),
                    'status' => 'active',
                    'stock' => $faker->numberBetween(10, 100),
                    'created_at' => now(),
                    'updated_at' => now(),
                ]);
            }
        }

        // phir 2 vendor ke liye 8-8 product
        $nextVendors = $vendors->slice(1, 2); // skip pehla, next do
        foreach ($nextVendors as $vendor) {
            for ($i = 0; $i < 8; $i++) {
                $category = $categories->random();
                DB::table('products')->insert([
                    'category_id' => $category->id,
                    'vendor_id' => $vendor->id,
                    'parent_id' => null,
                    'name_en' => $faker->words(3, true),
                    'name_ar' => 'منتج ' . $faker->numberBetween(1, 100),
                    'description_en' => $faker->sentence(10),
                    'description_ar' => 'وصف المنتج ' . $faker->numberBetween(1, 100),
                    'views' => $faker->numberBetween(0, 1000),
                    'attributes' => json_encode([
                        'color' => $faker->randomElement(['Red', 'Blue', 'Green']),
                        'size' => $faker->randomElement(['S', 'M', 'L', 'XL']),
                    ]),
                    'regular_price' => $faker->randomFloat(2, 50, 500),
                    'sale_price' => $faker->randomFloat(2, 30, 400),
                    'image_url' => $faker->imageUrl(400, 400, 'product'),
                    'gallery' => json_encode([
                        $faker->imageUrl(400, 400, 'product'),
                        $faker->imageUrl(400, 400, 'product'),
                    ]),
                    'status' => 'active',
                    'stock' => $faker->numberBetween(10, 100),
                    'created_at' => now(),
                    'updated_at' => now(),
                ]);
            }
        }

        // agar aur vendors bach gaye toh un sab ke liye ek ek product dal do
        if ($vendors->count() > 3) {
            $otherVendors = $vendors->slice(3);
            foreach ($otherVendors as $vendor) {
                $category = $categories->random();
                DB::table('products')->insert([
                    'category_id' => $category->id,
                    'vendor_id' => $vendor->id,
                    'parent_id' => null,
                    'name_en' => $faker->words(3, true),
                    'name_ar' => 'منتج ' . $faker->numberBetween(1, 100),
                    'description_en' => $faker->sentence(10),
                    'description_ar' => 'وصف المنتج ' . $faker->numberBetween(1, 100),
                    'views' => $faker->numberBetween(0, 1000),
                    'attributes' => json_encode([
                        'color' => $faker->randomElement(['Red', 'Blue', 'Green']),
                        'size' => $faker->randomElement(['S', 'M', 'L', 'XL']),
                    ]),
                    'regular_price' => $faker->randomFloat(2, 50, 500),
                    'sale_price' => $faker->randomFloat(2, 30, 400),
                    'image_url' => $faker->imageUrl(400, 400, 'product'),
                    'gallery' => json_encode([
                        $faker->imageUrl(400, 400, 'product'),
                        $faker->imageUrl(400, 400, 'product'),
                    ]),
                    'status' => 'active',
                    'stock' => $faker->numberBetween(10, 100),
                    'created_at' => now(),
                    'updated_at' => now(),
                ]);
            }
        }
    }
}
