<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('expo_vendor', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('expo_id');
            $table->unsignedBigInteger('vendor_id');
            $table->string('name');
            $table->text('description')->nullable();
            $table->unsignedBigInteger('address_id')->nullable();
            $table->string('email')->nullable();
            $table->string('mobile')->nullable();
            $table->integer('slot')->nullable();
            $table->string('status')->default('pending');
            $table->integer('products_count')->default(0);
            $table->text('notes')->nullable();
            $table->timestamp('approved_at')->nullable();
            $table->timestamp('joined_at')->nullable();
            $table->timestamps();

            $table->foreign('expo_id')->references('id')->on('expos')->onDelete('cascade');
            $table->foreign('vendor_id')->references('id')->on('vendors')->onDelete('cascade');
            $table->foreign('address_id')->references('id')->on('addresses')->onDelete('set null');
            $table->unique(['expo_id', 'vendor_id']);
            $table->softDeletes();

        });
    }

    public function down(): void
    {
        Schema::dropIfExists('expo_vendor');
    }
};
