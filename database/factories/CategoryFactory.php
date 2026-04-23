<?php

namespace Database\Factories;

use Illuminate\Database\Eloquent\Factories\Factory;

class CategoryFactory extends Factory
{
    public function definition(): array
    {
        return [
            'name_en' => $this->faker->word(),
            'name_ar' => $this->faker->word(),
            'image' => 'categories/placeholder.png',
            'status' => $this->faker->randomElement(['active', 'suspended']),
        ];
    }
}