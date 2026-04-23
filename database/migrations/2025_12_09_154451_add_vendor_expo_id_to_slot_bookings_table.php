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
        Schema::table('slot_bookings', function (Blueprint $table) {
            $table->unsignedBigInteger('vendor_expo_id')->nullable()->after('vendor_id');
            $table->foreign('vendor_expo_id')->references('id')->on('expo_vendor')->onDelete('set null');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('slot_bookings', function (Blueprint $table) {
            $table->dropForeign(['vendor_expo_id']);
            $table->dropColumn('vendor_expo_id');
        });
    }
};
