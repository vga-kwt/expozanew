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
        Schema::table('addresses', function (Blueprint $table) {
            // Step 1: Drop old city column if exists
            if (Schema::hasColumn('addresses', 'city')) {
                $table->dropColumn('city');
            }

            // Step 2: Add city_id foreign key
            $table->unsignedBigInteger('city_id')->nullable()->after('state_id');
            $table->foreign('city_id')->references('id')->on('cities')->onDelete('set null');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('addresses', function (Blueprint $table) {
            // Step 1: Drop foreign key and city_id
            $table->dropForeign(['city_id']);
            $table->dropColumn('city_id');

            // Step 2: Re-add old city column if needed
            $table->string('city')->nullable();
        });
    }
};
