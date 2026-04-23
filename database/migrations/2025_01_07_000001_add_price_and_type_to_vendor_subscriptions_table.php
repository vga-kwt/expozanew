<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        // Check if table exists before trying to alter it
        if (!Schema::hasTable('vendor_subscriptions')) {
            return;
        }
        
        Schema::table('vendor_subscriptions', function (Blueprint $table) {
            if (!Schema::hasColumn('vendor_subscriptions', 'price')) {
                $table->decimal('price', 10, 2)->nullable()->after('subscription_id');
            }
            if (!Schema::hasColumn('vendor_subscriptions', 'type')) {
                $table->string('type')->nullable()->after('price');
            }
        });
    }

    public function down(): void
    {
        // Check if table exists before trying to alter it
        if (!Schema::hasTable('vendor_subscriptions')) {
            return;
        }
        
        Schema::table('vendor_subscriptions', function (Blueprint $table) {
            if (Schema::hasColumn('vendor_subscriptions', 'price')) {
                $table->dropColumn('price');
            }
            if (Schema::hasColumn('vendor_subscriptions', 'type')) {
                $table->dropColumn('type');
            }
        });
    }
};

