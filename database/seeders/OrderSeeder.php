<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Order;
use App\Models\User;
use App\Models\Vendor;
use App\Models\Product;

class OrderSeeder extends Seeder
{
    public function run(): void
    {
        $users = User::where('role', 'user')->get();
        $vendors = Vendor::all();
        $products = Product::all();

        if ($users->count() && $vendors->count() && $products->count()) {
            foreach (range(1, 50) as $i) {
                $user = $users->random();
                $vendor = $vendors->random();

                $totalItems = rand(1, 5);
                $orderItemsData = [];
                $subTotal = 0;
                $taxTotal = 0;
                $discountTotal = 0;

                for ($j = 0; $j < $totalItems; $j++) {
                    $product = $products->random();
                    $qty = rand(1, 3);
                    $price = $product->sale_price ?? rand(10, 100);
                    $amount = $qty * $price;
                    $tax = rand(1, 10);
                    $discount = rand(0, 5);
                    $totalAmount = $amount + $tax - $discount;

                    $orderItemsData[] = [
                        'product_id' => $product->id,
                        'quantity' => $qty,
                        'amount' => $amount,
                        'tax_amount' => $tax,
                        'discount_applied' => $discount,
                        'total_amount' => $totalAmount,
                        'delivery_status' => fake()->randomElement(['pending', 'processing', 'shipped', 'delivered']),
                        'created_at' => now(),
                        'updated_at' => now(),
                    ];

                    $subTotal += $amount;
                    $taxTotal += $tax;
                    $discountTotal += $discount;
                }

                $shippingFee = rand(0, 50);
                $totalAmount = $subTotal + $taxTotal + $shippingFee - $discountTotal;

                $randomDate = fake()->dateTimeBetween('-2 months', 'now');
                $order = Order::create([
                    'user_id' => $user->id,
                    'vendor_id' => $vendor->id,
                    'coupon_id' => null,
                    'shipping_address' => fake()->address,
                    'billing_address' => fake()->address,
                    'total_items' => $totalItems,
                    'sub_total_amount' => $subTotal,
                    'tax_amount' => $taxTotal,
                    'discount_amount' => $discountTotal,
                    'total_amount' => $totalAmount,
                    'order_status' => fake()->randomElement([
                        'pending',
                        'confirmed',
                        'processing',
                        'ready_for_pickup',
                        'shipped',
                        'out_for_delivery',
                        'delivered',
                        'cancelled',
                        'returned',
                        'failed'
                    ]),
                    'payment_status' => fake()->randomElement(['pending', 'paid','unpaid','cancelled', 'failed', 'refunded']),
                    'delivery_status' => fake()->randomElement(['pending', 'processing', 'shipped', 'delivered']),
                    'refund_status' => fake()->randomElement(['pending', 'approved', 'rejected', 'none']),
                    'refund_approved_by' => fake()->name,
                    'refund_requested_at' => fake()->dateTimeBetween('-1 month', 'now'),
                    'refund_rejection_reason_en' => fake()->optional()->sentence,
                    'refund_rejection_reason_ar' => fake()->optional()->sentence,
                    'payment_method' => fake()->randomElement(['card', 'knet', 'myfatoorah']),
                    'transaction_id' => 'TXN' . fake()->unique()->numerify('########'),
                    'shipping_fee' => $shippingFee,
                    'order_summary' => json_encode([
                        'items' => collect($orderItemsData)->map(function ($item) use ($products) {
                            $product = $products->find($item['product_id']);
                            return [
                                'name' => $product ? $product->name_en : 'Sample Product',
                                'qty' => $item['quantity'],
                                'price' => $item['amount'] / $item['quantity'],
                            ];
                        }),
                    ]),
                    // Add a formatted order code like 0001, 0002, etc.
                    'order_code' => str_pad(Order::max('id') + 1, 4, '0', STR_PAD_LEFT),
                    'created_at' => $randomDate,
                    'updated_at' => $randomDate,
                ]);

                foreach ($orderItemsData as $itemData) {
                    $order->orderItems()->create($itemData);
                }
                $fulfillment = $order->fulfillments()->create([
                    'courier_partner'    => fake()->randomElement(['FedEx', 'DHL', 'BlueDart', 'Aramex']),
                    'tracking_number'    => 'TRK' . fake()->unique()->numerify('########'),
                    'is_ready'           => true,
                    'is_dispatched'      => fake()->boolean,
                    'in_transit'         => fake()->boolean,
                    'is_delivered'       => fake()->boolean,
                    'is_rto'             => false,
                    'is_rto_recieved'    => false,
                    'status'             => fake()->randomElement(['ready', 'dispatched', 'in_transit', 'delivered']),
                    'created_at' => $randomDate,
                    'updated_at' => $randomDate,
                ]);
                // Create fulfillment_items for each order item
                foreach ($order->orderItems as $orderItem) {
                    $fulfillment->fulfillmentItems()->create([
                        'item_id' => $orderItem->id,
                        'fullfilment_id' => $fulfillment->id,
                        'created_at' => $randomDate,
                        'updated_at' => $randomDate,
                    ]);
                }
            }
        }
    }
}
