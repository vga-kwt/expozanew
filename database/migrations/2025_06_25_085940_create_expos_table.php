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
        Schema::create('expos', function (Blueprint $table) {
            $table->id();
            $table->string('name_en');
            $table->string('name_ar');
            $table->text('description_en')->nullable();
            $table->text('description_ar')->nullable();
            $table->string('background_color')->nullable();
            $table->string('background_image')->nullable();
            $table->string('font_family')->nullable();
            $table->string('font_style')->nullable();
            $table->string('font_size')->nullable();
            $table->string('font_color')->nullable();
            $table->string('font_weight')->nullable();
            $table->string('banner_image')->nullable();
            $table->dateTime('start_date')->nullable();
            $table->dateTime('end_date')->nullable();
            $table->string('status')->default('upcoming');
            $table->integer('vendor_slot_capacity')->nullable();
            $table->integer('product_capacity_per_slot')->nullable();
            $table->json('slot_pricing')->nullable();
            $table->softDeletes();

            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('expos');
    }
};
