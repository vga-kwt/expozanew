<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        // Add variant fields to cart_items table
        Schema::table('cart_items', function (Blueprint $table) {
            $table->string('size')->nullable()->after('price');
            $table->string('color')->nullable()->after('size');
        });

        // Add variant fields to order_items table
        Schema::table('order_items', function (Blueprint $table) {
            $table->string('size')->nullable()->after('total_amount');
            $table->string('color')->nullable()->after('size');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        // Remove variant fields from cart_items table
        Schema::table('cart_items', function (Blueprint $table) {
            $table->dropColumn(['size', 'color']);
        });

        // Remove variant fields from order_items table
        Schema::table('order_items', function (Blueprint $table) {
            $table->dropColumn(['size', 'color']);
        });
    }
};
