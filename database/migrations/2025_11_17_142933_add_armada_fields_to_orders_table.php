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
        Schema::table('orders', function (Blueprint $table) {
            $table->string('armada_order_id')->nullable()->after('order_code');
            $table->string('armada_tracking_number')->nullable()->after('armada_order_id');
            $table->json('armada_response')->nullable()->after('armada_tracking_number');
            $table->boolean('is_armada_synced')->default(false)->after('armada_response');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('orders', function (Blueprint $table) {
            $table->dropColumn([
                'armada_order_id',
                'armada_tracking_number',
                'armada_response',
                'is_armada_synced',
            ]);
        });
    }
};
