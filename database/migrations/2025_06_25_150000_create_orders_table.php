<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('orders', function (Blueprint $table) {
            $table->id();
            $table->string('order_code')->nullable();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->foreignId('vendor_id')->constrained()->cascadeOnDelete();
            $table->string('coupon_id')->nullable();
            $table->string('shipping_address');
            $table->string('billing_address');
            $table->integer('total_items');
            $table->decimal('sub_total_amount', 10, 2);
            $table->decimal('tax_amount', 10, 2);
            $table->decimal('discount_amount', 10, 2);
            $table->decimal('shipping_fee', 10, 2)->default(0);
            $table->decimal('total_amount', 10, 2);
            $table->text('order_summary')->nullable();
            $table->enum('order_status', [
                'pending',        // Order placed but not yet confirmed
                'confirmed',      // Confirmed by system/vendor
                'processing',     // In process (e.g. preparing items)
                'ready_for_pickup', // For local pickups
                'shipped',        // Shipped from warehouse
                'out_for_delivery', // Last-mile delivery in progress
                'delivered',      // Delivered to customer
                'cancelled',      // Cancelled by customer or vendor
                'returned',       // Customer initiated return
                'failed'          // Failed processing (e.g. stock, error)
            ])->default('pending');
            $table->enum('payment_status', ['pending', 'paid', 'cancelled', 'failed', 'refunded','unpaid'])->default('pending');
            $table->string('refund_status')->nullable();
            $table->string('transaction_id')->nullable();
            $table->enum('delivery_status', [
                'pending',         // Not yet picked/packed
                'processing',      // Being packed
                'shipped',         // Shipped to courier
                'out_for_delivery', // En route to customer
                'delivered',       // Delivered to address
                'returned',        // Returned to vendor
                'failed'           // Delivery attempt failed
            ])->default('pending');
            $table->string('payment_method')->nullable();
            $table->string('refund_approved_by')->nullable();
            $table->timestamp('refund_requested_at')->nullable();
            $table->string('refund_rejection_reason_en')->nullable();
            $table->string('refund_rejection_reason_ar')->nullable();
            $table->timestamps();
            $table->softDeletes();

        });
    }

    public function down(): void
    {
        Schema::dropIfExists('orders');
    }
};
