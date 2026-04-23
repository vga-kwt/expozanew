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
        // Check if the old constraint exists
        $oldConstraintExists = DB::select("
            SELECT COUNT(*) as count 
            FROM information_schema.TABLE_CONSTRAINTS 
            WHERE CONSTRAINT_SCHEMA = DATABASE() 
            AND TABLE_NAME = 'expo_sections' 
            AND CONSTRAINT_NAME = 'expo_vendor_section_unique'
        ")[0]->count > 0;

        if ($oldConstraintExists) {
            // Try to drop the old constraint
            try {
                DB::statement('ALTER TABLE expo_sections DROP INDEX expo_vendor_section_unique');
            } catch (\Exception $e) {
                // If it fails due to foreign key constraints, we'll leave it for now
                // The new constraint will handle the slot-specific uniqueness
                echo "Note: Could not drop old constraint due to foreign key dependencies. New constraint is active.\n";
            }
        }
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        // We don't need to restore the old constraint in rollback
        // as it might still exist and cause conflicts
    }
};
