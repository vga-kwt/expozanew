<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('subscriptions', function (Blueprint $table) {
            $table->id();
            $table->string('title_en', 255);
            $table->string('title_ar', 255);
            $table->text('description_en')->nullable();
            $table->text('description_ar')->nullable();
            $table->longText('features')->nullable()->collation('utf8mb4_bin');
            $table->decimal('price', 10, 2);
            $table->enum('duration', ['monthly', 'yearly']);
            $table->enum('status', ['active', 'suspended', 'deleted'])->default('active');
            $table->integer('sort_order')->default(0);
            $table->integer('ad_limit')->default(0);
            $table->softDeletes();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('subscriptions');
    }
};