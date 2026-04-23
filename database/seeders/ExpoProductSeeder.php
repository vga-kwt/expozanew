<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Expo;
use App\Models\Product;
use App\Models\Vendor;
use App\Models\ExpoProduct;

class ExpoProductSeeder extends Seeder
{
    public function run()
    {
        $expos = Expo::all();
        $products = Product::all();

        if ($expos->isEmpty() || $products->isEmpty()) {
            $this->command->warn('Please seed expos and products before running ExpoProductSeeder.');
            return;
        }

        foreach ($expos as $expo) {
            // Assign 5 random products to each expo
            $randomProducts = $products->random(min(10, $products->count()));

            foreach ($randomProducts as $product) {
                ExpoProduct::firstOrCreate([
                    'expo_id' => $expo->id,
                    'product_id' => $product->id,
                ], [
                    'vendor_id' => $product->vendor_id,
                ]);
            }
        }
    }
}
