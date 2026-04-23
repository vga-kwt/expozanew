<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('order_items', function (Blueprint $table) {
            $table->id();
            $table->foreignId('order_id')->constrained()->onDelete('cascade');
            $table->foreignId('product_id')->constrained()->onDelete('cascade');
            $table->integer('quantity');
            $table->decimal('amount', 10, 2);
            $table->decimal('tax_amount', 10, 2)->default(0);
            $table->decimal('discount_applied', 10, 2)->default(0);
            $table->decimal('total_amount', 10, 2);
            $table->enum('delivery_status', [
                'pending',         // Not yet picked/packed
                'processing',      // Being packed
                'shipped',         // Shipped to courier
                'out_for_delivery',// En route to customer
                'delivered',       // Delivered to address
                'returned',        // Returned to vendor
                'failed'           // Delivery attempt failed
            ])->default('pending');
            $table->timestamps();
            $table->softDeletes();

        });
    }

    public function down(): void
    {
        Schema::dropIfExists('order_items');
    }
};