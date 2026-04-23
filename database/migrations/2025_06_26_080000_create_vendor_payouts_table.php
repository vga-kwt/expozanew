<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('vendor_payouts', function (Blueprint $table) {
            $table->id();
            $table->string('payout_id')->unique(); // Unique payout reference
            $table->foreignId('vendor_id')->constrained()->onDelete('cascade');
            $table->enum('status', ['pending', 'approved', 'completed', 'rejected', 'cancelled']);
            $table->decimal('amount', 10, 2);
            $table->string('currency', 3)->default('USD');
            $table->string('payment_method')->nullable(); // bank_transfer, paypal, etc.
            $table->string('account_details')->nullable(); // Encrypted account info
            $table->text('summary')->nullable(); // Payout summary
            $table->date('scheduled_date');
            $table->date('processed_date')->nullable();
            $table->string('transaction_reference_id')->nullable(); // Admin entered reference
            $table->foreignId('approved_by')->nullable()->constrained('users')->onDelete('set null');
            $table->timestamp('approved_at')->nullable();
            $table->text('notes')->nullable();
            $table->json('metadata')->nullable(); // Additional payout data
            $table->softDeletes();

            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('vendor_payouts');
    }
}; 