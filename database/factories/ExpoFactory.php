<?php

namespace Database\Factories;

use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends \Illuminate\Database\Eloquent\Factories\Factory<\App\Models\Expo>
 */
class ExpoFactory extends Factory
{
    /**
     * Define the model's default state.
     *
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        $start = $this->faker->dateTimeBetween('-1 month', '+1 month');
        $end = (clone $start)->modify('+2 days');
        return [
            'name_en' => $this->faker->words(2, true) . ' Expo',
            'name_ar' => 'معرض ' . $this->faker->word(),
            'description_en' => $this->faker->sentence(),
            'description_ar' => 'وصف ' . $this->faker->word(),
            'background_color' => $this->faker->hexColor(),
            'background_image' => 'https://via.placeholder.com/300x100.png?text=BG',
            'font_style' => $this->faker->randomElement(['Arial', 'Roboto', 'Times New Roman', 'Courier New', 'Tahoma']),
            'font_size' => $this->faker->randomElement(['14px', '16px', '18px', '20px']),
            'font_weight' => $this->faker->randomElement(['400', '500', '700']),
            'banner_image' => 'https://via.placeholder.com/600x200.png?text=Banner',
            'start_date' => $start,
            'end_date' => $end,
            'vendor_slot_capacity' => $this->faker->numberBetween(5, 20),
            'product_capacity_per_slot' => $this->faker->numberBetween(1, 10),
            'slot_pricing' => json_encode([
                '1' => 10,
                '2' => 8,
                '3' => 8,
            ]),
            'status' => $this->faker->randomElement(['active', 'suspended', 'expired']),
        ];
    }
}
