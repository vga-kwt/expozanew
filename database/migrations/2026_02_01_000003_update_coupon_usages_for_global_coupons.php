<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('coupon_usages', function (Blueprint $table) {
            if (! Schema::hasColumn('coupon_usages', 'coupon_id')) {
                $table->foreignId('coupon_id')->nullable()->after('id')->constrained('coupons')->cascadeOnDelete();
            }
            if (! Schema::hasColumn('coupon_usages', 'discount_amount')) {
                $table->decimal('discount_amount', 10, 2)->nullable()->after('user_id');
            }
        });
    }

    public function down(): void
    {
        Schema::table('coupon_usages', function (Blueprint $table) {
            if (Schema::hasColumn('coupon_usages', 'discount_amount')) {
                $table->dropColumn('discount_amount');
            }
            if (Schema::hasColumn('coupon_usages', 'coupon_id')) {
                $table->dropForeign(['coupon_id']);
                $table->dropColumn('coupon_id');
            }
        });
    }
};
