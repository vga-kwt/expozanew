<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('fulfillments', function (Blueprint $table) {
            $table->id();
            $table->foreignId('order_id')->constrained()->onDelete('cascade')->nullable();
            $table->string('courier_partner')->nullable();
            $table->string('tracking_number')->nullable();
            $table->boolean('is_ready')->default(false)->nullable();
            $table->boolean('is_dispatched')->default(false)->nullable();
            $table->boolean('in_transit')->default(false)->nullable();
            $table->boolean('is_delivered')->default(false)->nullable();
            $table->boolean('is_rto')->default(false)->nullable();
            $table->boolean('is_rto_recieved')->default(false)->nullable();
            $table->string('status')->nullable();
            $table->timestamps();
            $table->softDeletes();

        });
    }

    public function down(): void
    {
        Schema::dropIfExists('fulfillments');
    }
};