<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('faqs', function (Blueprint $table) {
            // Rename existing columns
            $table->renameColumn('question', 'question_en');
            $table->renameColumn('answer', 'answer_en');
        });

        Schema::table('faqs', function (Blueprint $table) {
            // Add Arabic columns
            $table->string('question_ar')->nullable()->after('question_en');
            $table->text('answer_ar')->nullable()->after('answer_en');
            $table->integer('sort_order')->default(0)->after('status');
        });
    }

    public function down(): void
    {
        Schema::table('faqs', function (Blueprint $table) {
            $table->dropColumn(['question_ar', 'answer_ar', 'sort_order']);
        });

        Schema::table('faqs', function (Blueprint $table) {
            $table->renameColumn('question_en', 'question');
            $table->renameColumn('answer_en', 'answer');
        });
    }
};

