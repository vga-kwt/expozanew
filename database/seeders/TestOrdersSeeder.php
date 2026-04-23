<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Order;
use App\Models\OrderItem;
use App\Models\Product;
use App\Models\Vendor;
use Carbon\Carbon;

class TestOrdersSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        // Get vendor with ID 1 (or create if doesn't exist)
        $vendor = Vendor::find(1);
        if (!$vendor) {
            echo "Vendor with ID 1 not found. Please ensure vendor exists.\n";
            return;
        }

        // Get some products for this vendor (or create test products)
        $products = Product::where('vendor_id', 1)->limit(5)->get();
        if ($products->isEmpty()) {
            echo "No products found for vendor ID 1. Creating test products...\n";
            // Create test products
            for ($i = 1; $i <= 5; $i++) {
                Product::create([
                    'vendor_id' => 1,
                    'name_en' => "Test Product $i",
                    'name_ar' => "منتج تجريبي $i",
                    'description_en' => "Test product description $i",
                    'description_ar' => "وصف المنتج التجريبي $i",
                    'price' => rand(10, 100),
                    'status' => 'active',
                    'category_id' => 1, // Adjust based on your categories
                ]);
            }
            $products = Product::where('vendor_id', 1)->limit(5)->get();
        }

        echo "Creating test orders for vendor ID 1...\n";

        // Create test orders for the past 3 months
        $dates = [
            Carbon::now()->subDays(5),
            Carbon::now()->subDays(10),
            Carbon::now()->subDays(15),
            Carbon::now()->subDays(30),
            Carbon::now()->subDays(45),
            Carbon::now()->subDays(60),
            Carbon::now()->subWeeks(10),
            Carbon::now()->subWeeks(12),
        ];

        foreach ($dates as $date) {
            // Create 2-4 orders for each date
            $orderCount = rand(2, 4);
            
            for ($i = 0; $i < $orderCount; $i++) {
                $totalAmount = rand(50, 300);
                
                $order = Order::create([
                    'vendor_id' => 1,
                    'user_id' => 1, // Adjust based on your users
                    'order_status' => 'delivered',
                    'total_amount' => $totalAmount,
                    'sub_total_amount' => $totalAmount * 0.9,
                    'tax_amount' => $totalAmount * 0.1,
                    'discount_amount' => 0,
                    'shipping_address' => json_encode([
                        'street' => 'Test Street',
                        'city' => 'Test City',
                        'country' => 'Kuwait'
                    ]),
                    'billing_address' => json_encode([
                        'street' => 'Test Street',
                        'city' => 'Test City',
                        'country' => 'Kuwait'
                    ]),
                    'total_items' => rand(1, 5),
                    'payment_status' => 'paid',
                    'delivery_status' => 'delivered',
                    'payment_method' => 'credit_card',
                    'shipping_fee' => 5.0,
                    'created_at' => $date,
                    'updated_at' => $date,
                ]);

                // Create order items
                $itemCount = rand(1, 3);
                for ($j = 0; $j < $itemCount; $j++) {
                    $product = $products->random();
                    $quantity = rand(1, 3);
                    $price = $product->price;
                    
                    OrderItem::create([
                        'order_id' => $order->id,
                        'product_id' => $product->id,
                        'quantity' => $quantity,
                        'price' => $price,
                        'total_amount' => $price * $quantity,
                    ]);
                }

                echo "Created order ID: {$order->id} for date: {$date->format('Y-m-d')}\n";
            }
        }

        echo "Test orders created successfully!\n";
    }
}
