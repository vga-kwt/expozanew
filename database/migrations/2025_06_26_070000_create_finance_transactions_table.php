<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('finance_transactions', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->nullable()->constrained()->onDelete('set null');
            $table->string('user_type')->nullable();
            $table->string('transaction_id')->unique();
            $table->string('type');
            $table->text('summery')->nullable();
            $table->string('payment_processor')->nullable();
            $table->string('payment_reference_id')->nullable();
            $table->decimal('amount', 10, 2);
            $table->decimal('charge', 10, 2)->default(0);
            $table->timestamp('attempted_at')->nullable();
            $table->string('attempt_status')->nullable();
            $table->timestamps();
            $table->softDeletes();

        });
    }

    public function down(): void
    {
        Schema::dropIfExists('finance_transactions');
    }
};