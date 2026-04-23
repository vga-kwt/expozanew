<?php

namespace Database\Seeders;

use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use App\Models\VendorPayout;
use App\Models\Vendor;
use App\Models\User;
use Carbon\Carbon;

class VendorPayoutSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        // Get existing vendors and users
        $vendors = Vendor::all();
        $users = User::where('role', 'admin')->get();

        if ($vendors->isEmpty()) {
            $this->command->info('No vendors found. Please run VendorSeeder first.');
            return;
        }

        if ($users->isEmpty()) {
            $this->command->info('No admin users found. Please run UserSeeder first.');
            return;
        }

        $payoutStatuses = ['pending', 'approved', 'completed', 'rejected', 'cancelled'];
        $paymentMethods = ['card', 'knet', 'myfatoorah'];
        $currencies = ['KWD'];

        $samplePayouts = [
            [
                'payout_id' => 'PAY-001',
                'status' => 'completed',
                'amount' => 1250.00,
                'currency' => 'KWD',
                'payment_method' => 'card',
                'account_details' => json_encode([
                    'card_type' => 'Visa',
                    'masked_card' => '**** 1234',
                    'country' => 'Kuwait'
                ]),
                'summary' => 'Monthly commission payout for January 2024',
                'scheduled_date' => '2024-01-31',
                'processed_date' => '2024-02-01',
                'transaction_reference_id' => 'TXN-2024-001',
                'notes' => 'Successfully processed via card',
                'metadata' => [
                    'commission_rate' => 15,
                    'orders_count' => 25,
                    'total_sales' => 8500.00,
                    'country' => 'Kuwait'
                ]
            ],
            [
                'payout_id' => 'PAY-002',
                'status' => 'pending',
                'amount' => 875.50,
                'currency' => 'KWD',
                'payment_method' => 'knet',
                'account_details' => json_encode([
                    'knet_id' => 'KNET123456',
                    'country' => 'Kuwait'
                ]),
                'summary' => 'Commission payout for February 2024',
                'scheduled_date' => '2024-02-29',
                'processed_date' => null,
                'transaction_reference_id' => null,
                'notes' => 'Awaiting approval from finance team',
                'metadata' => [
                    'commission_rate' => 12,
                    'orders_count' => 18,
                    'total_sales' => 7295.83,
                    'country' => 'Kuwait'
                ]
            ],
            [
                'payout_id' => 'PAY-003',
                'status' => 'approved',
                'amount' => 2100.00,
                'currency' => 'KWD',
                'payment_method' => 'myfatoorah',
                'account_details' => json_encode([
                    'myfatoorah_invoice_id' => 'MF123456',
                    'country' => 'Kuwait'
                ]),
                'summary' => 'Quarterly bonus payout Q1 2024',
                'scheduled_date' => '2024-03-31',
                'processed_date' => null,
                'transaction_reference_id' => null,
                'notes' => 'Approved by finance manager',
                'metadata' => [
                    'bonus_type' => 'performance',
                    'performance_score' => 95,
                    'sales_target_achieved' => 120,
                    'country' => 'Kuwait'
                ]
            ],
            [
                'payout_id' => 'PAY-004',
                'status' => 'rejected',
                'amount' => 650.25,
                'currency' => 'KWD',
                'payment_method' => 'card',
                'account_details' => json_encode([
                    'card_type' => 'Mastercard',
                    'masked_card' => '**** 5678',
                    'country' => 'Kuwait'
                ]),
                'summary' => 'Commission payout for March 2024',
                'scheduled_date' => '2024-03-31',
                'processed_date' => '2024-04-01',
                'transaction_reference_id' => 'TXN-2024-004',
                'notes' => 'Rejected due to insufficient funds on card',
                'metadata' => [
                    'rejection_reason' => 'insufficient_funds',
                    'retry_count' => 2,
                    'commission_rate' => 10,
                    'country' => 'Kuwait'
                ]
            ],
            [
                'payout_id' => 'PAY-005',
                'status' => 'completed',
                'amount' => 1800.00,
                'currency' => 'KWD',
                'payment_method' => 'knet',
                'account_details' => json_encode([
                    'knet_id' => 'KNET789012',
                    'country' => 'Kuwait'
                ]),
                'summary' => 'Monthly commission payout for April 2024',
                'scheduled_date' => '2024-04-30',
                'processed_date' => '2024-05-01',
                'transaction_reference_id' => 'TXN-2024-005',
                'notes' => 'Successfully processed via KNET',
                'metadata' => [
                    'commission_rate' => 18,
                    'orders_count' => 32,
                    'total_sales' => 10000.00,
                    'sepa_reference' => 'SEPA123456789',
                    'country' => 'Kuwait'
                ]
            ]
        ];

        foreach ($samplePayouts as $index => $payoutData) {
            // Assign to existing vendors in rotation
            $vendor = $vendors[$index % $vendors->count()];
            
            // Assign to existing admin users in rotation
            $approvedBy = $users[$index % $users->count()];

            VendorPayout::create([
                'payout_id' => $payoutData['payout_id'],
                'vendor_id' => $vendor->id,
                'status' => $payoutData['status'],
                'amount' => $payoutData['amount'],
                'currency' => $payoutData['currency'],
                'payment_method' => $payoutData['payment_method'],
                'account_details' => $payoutData['account_details'],
                'summary' => $payoutData['summary'],
                'scheduled_date' => $payoutData['scheduled_date'],
                'processed_date' => $payoutData['processed_date'],
                'transaction_reference_id' => $payoutData['transaction_reference_id'],
                'approved_by' => $payoutData['status'] === 'approved' || $payoutData['status'] === 'completed' ? $approvedBy->id : null,
                'approved_at' => $payoutData['status'] === 'approved' || $payoutData['status'] === 'completed' ? Carbon::now()->subDays(rand(1, 30)) : null,
                'notes' => $payoutData['notes'],
                'metadata' => $payoutData['metadata'],
            ]);
        }

        // Create additional random payouts
        for ($i = 6; $i <= 20; $i++) {
            $vendor = $vendors->random();
            $status = $payoutStatuses[array_rand($payoutStatuses)];
            $paymentMethod = $paymentMethods[array_rand($paymentMethods)];
            $currency = $currencies[array_rand($currencies)];
            $amount = rand(100, 5000) + (rand(0, 99) / 100);
            
            $scheduledDate = Carbon::now()->addDays(rand(-60, 30));
            $processedDate = $status === 'completed' ? $scheduledDate->copy()->addDays(rand(1, 3)) : null;
            $approvedBy = $status === 'approved' || $status === 'completed' ? $users->random() : null;

            VendorPayout::create([
                'payout_id' => 'PAY-' . str_pad($i, 3, '0', STR_PAD_LEFT),
                'vendor_id' => $vendor->id,
                'status' => $status,
                'amount' => $amount,
                'currency' => $currency,
                'payment_method' => $paymentMethod,
                'account_details' => json_encode([
                    'method' => $paymentMethod,
                    'account_id' => 'ACC' . rand(1000, 9999),
                    'country' => 'Kuwait'
                ]),
                'summary' => 'Commission payout for ' . $scheduledDate->format('F Y'),
                'scheduled_date' => $scheduledDate->format('Y-m-d'),
                'processed_date' => $processedDate ? $processedDate->format('Y-m-d') : null,
                'transaction_reference_id' => $status === 'completed' ? 'TXN-' . date('Y') . '-' . str_pad($i, 3, '0', STR_PAD_LEFT) : null,
                'approved_by' => $approvedBy ? $approvedBy->id : null,
                'approved_at' => $approvedBy ? Carbon::now()->subDays(rand(1, 30)) : null,
                'notes' => $this->getRandomNotes($status),
                'metadata' => [
                    'commission_rate' => rand(8, 20),
                    'orders_count' => rand(5, 50),
                    'total_sales' => $amount * (rand(5, 10) / 10),
                    'country' => 'Kuwait'
                ],
            ]);
        }

        $this->command->info('VendorPayoutSeeder completed successfully!');
    }

    private function getRandomNotes($status)
    {
        $notes = [
            'pending' => [
                'Awaiting approval from finance team',
                'Pending vendor account verification',
                'Scheduled for next processing cycle',
                'Under review by compliance team'
            ],
            'approved' => [
                'Approved by finance manager',
                'Cleared for processing',
                'Approved after KYC verification',
                'Ready for payment processing'
            ],
            'completed' => [
                'Successfully processed',
                'Payment completed via bank transfer',
                'Funds transferred successfully',
                'Transaction completed without issues'
            ],
            'rejected' => [
                'Rejected due to insufficient funds',
                'Account details invalid',
                'Bank rejected the transaction',
                'Payment method not supported'
            ],
            'cancelled' => [
                'Cancelled by vendor request',
                'Cancelled due to policy violation',
                'Cancelled by finance team',
                'Cancelled due to incomplete documentation'
            ]
        ];

        return $notes[$status][array_rand($notes[$status])];
    }
} 