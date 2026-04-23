<?php

namespace App\Console\Commands;

use App\Models\Order;
use Illuminate\Console\Command;

class FixOrderVendorIds extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'orders:fix-vendor-ids {--order-id= : Fix specific order by ID}';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Fix orders with missing or incorrect vendor_id by getting it from order items products';

    /**
     * Execute the console command.
     */
    public function handle()
    {
        $orderId = $this->option('order-id');
        
        if ($orderId) {
            $orders = Order::where('id', $orderId)->get();
        } else {
            // Get orders with null vendor_id or orders where vendor_id doesn't match product vendor_id
            $orders = Order::with('orderItems.product')
                ->whereNull('vendor_id')
                ->orWhere(function($query) {
                    $query->whereNotNull('vendor_id')
                        ->whereDoesntHave('orderItems.product', function($q) {
                            $q->whereColumn('products.vendor_id', 'orders.vendor_id');
                        });
                })
                ->get();
        }

        if ($orders->isEmpty()) {
            $this->info('No orders need fixing.');
            return 0;
        }

        $this->info("Found {$orders->count()} order(s) to fix.");

        $fixed = 0;
        foreach ($orders as $order) {
            $order->load('orderItems.product');
            
            // Get vendor_id from first order item's product
            $firstItem = $order->orderItems->first();
            if ($firstItem && $firstItem->product && $firstItem->product->vendor_id) {
                $newVendorId = $firstItem->product->vendor_id;
                
                if ($order->vendor_id != $newVendorId) {
                    $oldVendorId = $order->vendor_id ?? 'NULL';
                    $order->vendor_id = $newVendorId;
                    $order->save();
                    
                    $this->info("Order #{$order->id} (Code: {$order->order_code}): Updated vendor_id from {$oldVendorId} to {$newVendorId}");
                    $fixed++;
                }
            } else {
                $this->warn("Order #{$order->id} (Code: {$order->order_code}): Could not determine vendor_id - no products found");
            }
        }

        $this->info("\nFixed {$fixed} order(s).");
        return 0;
    }
}

