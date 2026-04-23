<?php

namespace Database\Factories;

use App\Models\Product;
use App\Models\Category;
use App\Models\Vendor;
use App\Models\Expo;
use Illuminate\Database\Eloquent\Factories\Factory;

class ProductFactory extends Factory
{
    protected $model = Product::class;

    public function definition()
    {
        return [
            'name_en' => $this->faker->word,
            'name_ar' => $this->faker->word,
            'description_en' => $this->faker->sentence,
            'description_ar' => $this->faker->sentence,
            'regular_price' => $this->faker->randomFloat(2, 10, 1000),
            'sale_price' => $this->faker->optional(0.3)->randomFloat(2, 5, 800),
            'stock' => $this->faker->numberBetween(1, 100),
            'gallery' => json_encode([]),
            'expo_id' => Expo::factory(),
            'category_id' => Category::factory(),
            'vendor_id' => Vendor::factory(),
            'status' => 'active',
        ];
    }
} 