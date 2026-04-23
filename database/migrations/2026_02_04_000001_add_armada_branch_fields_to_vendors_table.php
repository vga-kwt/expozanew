<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('vendors', function (Blueprint $table) {
            $table->string('armada_branch_id')->nullable()->after('use_armada_delivery');
            $table->string('armada_branch_key')->nullable()->after('armada_branch_id');
            $table->decimal('latitude', 10, 7)->nullable()->after('armada_branch_key');
            $table->decimal('longitude', 10, 7)->nullable()->after('latitude');
            $table->string('address_text', 500)->nullable()->after('longitude');
        });
    }

    public function down(): void
    {
        Schema::table('vendors', function (Blueprint $table) {
            $table->dropColumn([
                'armada_branch_id',
                'armada_branch_key',
                'latitude',
                'longitude',
                'address_text',
            ]);
        });
    }
};
