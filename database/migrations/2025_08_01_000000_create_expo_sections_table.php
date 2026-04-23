<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('expo_sections', function (Blueprint $table) {
            $table->id();
            $table->foreignId('expo_id')->constrained()->onDelete('cascade');
            $table->foreignId('vendor_id')->constrained()->onDelete('cascade');
            $table->foreignId('section_id')->constrained()->onDelete('cascade');
            $table->timestamps();
            $table->softDeletes();

            // Add unique constraint to prevent duplicate assignments
            $table->unique(['expo_id', 'vendor_id', 'section_id'], 'expo_vendor_section_unique');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('expo_sections');
    }
}; 