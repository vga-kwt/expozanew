<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('expo_product_coupons', function (Blueprint $table) {
            $table->id();
            $table->string('title_en');
            $table->string('title_ar');
            $table->text('description_en')->nullable();
            $table->text('description_ar')->nullable();
            $table->string('code')->unique();
            $table->string('rule')->nullable();
            $table->string('type'); // e.g. 'percentage', 'fixed'
            $table->decimal('value', 10, 2);
            $table->unsignedInteger('per_user_limit')->nullable();
            $table->unsignedInteger('total_limit')->nullable();
            $table->dateTime('start_date')->nullable();
            $table->dateTime('end_date')->nullable();
            $table->boolean('status')->default(true);
            $table->timestamps();
            $table->softDeletes();

        });
    }

    public function down(): void
    {
        Schema::dropIfExists('expo_product_coupons');
    }
};