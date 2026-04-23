<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        // First, let's check if the new constraint already exists
        $newConstraintExists = DB::select("
            SELECT COUNT(*) as count 
            FROM information_schema.TABLE_CONSTRAINTS 
            WHERE CONSTRAINT_SCHEMA = DATABASE() 
            AND TABLE_NAME = 'expo_sections' 
            AND CONSTRAINT_NAME = 'expo_vendor_section_slot_unique'
        ")[0]->count > 0;

        if (!$newConstraintExists) {
            // Add the new unique constraint that includes slot_id
            Schema::table('expo_sections', function (Blueprint $table) {
                $table->unique(['expo_id', 'vendor_id', 'section_id', 'slot_id'], 'expo_vendor_section_slot_unique');
            });
        }
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        // Drop the new unique constraint
        Schema::table('expo_sections', function (Blueprint $table) {
            $table->dropUnique('expo_vendor_section_slot_unique');
        });
    }
};
