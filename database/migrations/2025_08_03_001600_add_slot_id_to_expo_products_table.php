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
        Schema::table('expo_products', function (Blueprint $table) {
            $table->unsignedBigInteger('slot_id')->nullable()->after('vendor_id');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('expo_products', function (Blueprint $table) {
            $table->dropColumn('slot_id');
        });
    }
};
