<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\FinanceTransaction;
use App\Models\User;
use App\Models\Vendor;

class FinanceSeeder extends Seeder
{
    public function run(): void
    {
        $users = User::all();
        $vendors = Vendor::all();
        
        $paymentProcessors = ['card', 'knet', 'myfatoorah'];
        $transactionTypes = ['credit', 'debit', 'refund', 'commission', 'payout'];
        $attemptStatuses = ['completed', 'pending', 'failed', 'processing'];
        
        for ($i = 1; $i <= 10; $i++) {
            $user = $users->random();
            $vendor = $vendors->random();
            $type = $transactionTypes[array_rand($transactionTypes)];
            $processor = $paymentProcessors[array_rand($paymentProcessors)];
            $status = $attemptStatuses[array_rand($attemptStatuses)];
            
            $amount = rand(1000, 50000) / 100; // Random amount between 10.00 and 500.00
            $charge = rand(0, 500) / 100; // Random charge between 0.00 and 5.00
            
            $summaries = [
                'credit' => ['Product sale commission', 'Subscription payment', 'Bonus credit', 'Refund processed'],
                'debit' => ['Product purchase', 'Subscription renewal', 'Service fee', 'Commission deduction'],
                'refund' => ['Order cancellation refund', 'Product return refund', 'Overpayment refund'],
                'commission' => ['Platform commission', 'Transaction fee', 'Service charge'],
                'payout' => ['Vendor payout', 'Earnings withdrawal', 'Commission payout']
            ];
            
            $summary = $summaries[$type][array_rand($summaries[$type])];
            
            FinanceTransaction::create([
                'user_id' => $user->id,
                'user_type' => $user->role, 
                'transaction_id' => 'TXN' . strtoupper(uniqid()) . rand(1000, 9999),
                'type' => $type,
                'summery' => $summary,
                'payment_processor' => $processor,
                'payment_reference_id' => 'REF' . strtoupper(uniqid()) . rand(100, 999),
                'amount' => $amount,
                'charge' => $charge,
                'attempted_at' => now()->subDays(rand(1, 30)),
                'attempt_status' => $status,
            ]);
        }
    }
} 