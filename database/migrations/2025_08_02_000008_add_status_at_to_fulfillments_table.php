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
        Schema::table('fulfillments', function (Blueprint $table) {
            if (!Schema::hasColumn('fulfillments', 'is_ready_at')) {
                $table->timestamp('is_ready_at')->nullable()->after('is_ready');
            }
            if (!Schema::hasColumn('fulfillments', 'is_dispatched_at')) {
                $table->timestamp('is_dispatched_at')->nullable()->after('is_dispatched');
            }
            if (!Schema::hasColumn('fulfillments', 'in_transit_at')) {
                $table->timestamp('in_transit_at')->nullable()->after('in_transit');
            }
            if (!Schema::hasColumn('fulfillments', 'is_delivered_at')) {
                $table->timestamp('is_delivered_at')->nullable()->after('is_delivered');
            }
            if (!Schema::hasColumn('fulfillments', 'is_rto_at')) {
                $table->timestamp('is_rto_at')->nullable()->after('is_rto');
            }
            if (!Schema::hasColumn('fulfillments', 'is_rto_recieved_at')) {
                $table->timestamp('is_rto_recieved_at')->nullable()->after('is_rto_recieved');
            }
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('fulfillments', function (Blueprint $table) {
            $columns = [
                'is_ready_at',
                'is_dispatched_at',
                'in_transit_at',
                'is_delivered_at',
                'is_rto_at',
                'is_rto_recieved_at',
            ];
            foreach ($columns as $column) {
                if (Schema::hasColumn('fulfillments', $column)) {
                    $table->dropColumn($column);
                }
            }
        });
    }
};
