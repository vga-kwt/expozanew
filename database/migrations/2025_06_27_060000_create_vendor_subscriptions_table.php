<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('vendor_subscriptions', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('vendor_id');
            $table->unsignedBigInteger('subscription_id');
            $table->date('start_date');
            $table->date('end_date');
            $table->string('status');
            $table->enum('payment_status', [
                'pending',        // Awaiting payment
                'processing',     // Payment processing in gateway
                'paid',           // Payment successful
                'failed',         // Payment failed
                'refunded',       // Fully refunded
                'partially_refunded', // Partial refund
                'chargeback'      // Dispute/chargeback raised
            ])->default('pending');
            $table->string('transaction_id')->nullable();
            $table->timestamps();
            $table->softDeletes();


            $table->foreign('vendor_id')->references('id')->on('vendors')->onDelete('cascade');
            $table->foreign('subscription_id')->references('id')->on('subscriptions')->onDelete('cascade');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('vendor_subscriptions');
    }
};