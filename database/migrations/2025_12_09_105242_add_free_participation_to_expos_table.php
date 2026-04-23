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
        Schema::table('expos', function (Blueprint $table) {
            $table->boolean('free_participation')->default(false)->after('slot_pricing');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('expos', function (Blueprint $table) {
            $table->dropColumn('free_participation');
        });
    }
};
