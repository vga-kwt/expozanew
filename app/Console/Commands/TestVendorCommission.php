<?php

namespace App\Console\Commands;

use App\Models\Vendor;
use App\Models\Setting;
use App\Models\FinanceTransaction;
use App\Models\VendorPayout;
use Illuminate\Console\Command;
use Carbon\Carbon;

class TestVendorCommission extends Command
{
    protected $signature = 'test:vendor-commission {--vendor-id=}';
    protected $description = 'Test vendor commission calculation';

    public function handle()
    {
        $this->info('=== Vendor Commission Test ===');
        $this->newLine();

        // Get commission from settings
        $vendorCommission = (float) (Setting::where('key', 'vendor_commission')->value('value') ?? 10);
        $this->info("Default Vendor Commission from Settings: {$vendorCommission}%");
        $this->newLine();

        // Get vendor
        $vendorId = $this->option('vendor-id');
        if ($vendorId) {
            $vendor = Vendor::find($vendorId);
        } else {
            $vendor = Vendor::first();
        }

        if (!$vendor) {
            $this->error('No vendor found!');
            return Command::FAILURE;
        }

        $this->info("Testing for Vendor: {$vendor->name} (ID: {$vendor->id})");
        $this->info("Vendor's Custom Commission: " . ($vendor->commission ?? 'Not set (using default)'));
        $this->newLine();

        // Get vendor's recent transactions
        $this->info('--- Recent Order Transactions ---');
        $transactions = FinanceTransaction::where('vendor_id', $vendor->id)
            ->where('type', 'order')
            ->whereIn('attempt_status', ['Success', 'completed', 'Succss', 'success'])
            ->orderBy('created_at', 'desc')
            ->limit(5)
            ->get();

        if ($transactions->isEmpty()) {
            $this->warn('No completed order transactions found for this vendor.');
        } else {
            $totalEarnings = 0;
            foreach ($transactions as $transaction) {
                $this->line("  Transaction ID: {$transaction->transaction_id}");
                $this->line("  Amount: {$transaction->amount} KWD");
                $this->line("  Date: {$transaction->created_at}");
                $totalEarnings += $transaction->amount;
                $this->newLine();
            }
            $this->info("Total Earnings: {$totalEarnings} KWD");
            $this->newLine();

            // Calculate payout with commission
            // Vendor gets (100% - commission%), platform keeps commission%
            $commissionToApply = $vendor->commission ?? $vendorCommission;
            $payoutAmount = $totalEarnings * (1 - ($commissionToApply / 100));
            $platformFee = $totalEarnings - $payoutAmount;

            $this->info('--- Commission Calculation ---');
            $this->info("Commission Rate Used: {$commissionToApply}%");
            $this->info("Total Earnings: {$totalEarnings} KWD");
            $this->info("Vendor Payout Amount ({$commissionToApply}%): {$payoutAmount} KWD");
            $this->info("Platform Fee: {$platformFee} KWD");
            $this->newLine();
        }

        // Check existing payouts
        $this->info('--- Existing Payouts ---');
        $payouts = VendorPayout::where('vendor_id', $vendor->id)
            ->orderBy('created_at', 'desc')
            ->limit(5)
            ->get();

        if ($payouts->isEmpty()) {
            $this->warn('No payouts found for this vendor.');
        } else {
            foreach ($payouts as $payout) {
                $this->line("  Payout ID: {$payout->payout_id}");
                $this->line("  Amount: {$payout->amount} KWD");
                $this->line("  Status: {$payout->status}");
                if ($payout->metadata && isset($payout->metadata['commission_rate'])) {
                    $this->line("  Commission Rate Used: {$payout->metadata['commission_rate']}%");
                }
                if ($payout->metadata && isset($payout->metadata['total_earnings'])) {
                    $this->line("  Total Earnings: {$payout->metadata['total_earnings']} KWD");
                }
                $this->newLine();
            }
        }

        // Test calculation for a sample amount
        $this->info('--- Sample Calculation Test ---');
        $testAmount = 100;
        $testCommission = $vendorCommission;
        // Vendor gets (100% - commission%), platform keeps commission%
        $testPayout = $testAmount * (1 - ($testCommission / 100));
        $testPlatformFee = $testAmount - $testPayout;

        $this->info("Test Order Amount: {$testAmount} KWD");
        $this->info("Commission Rate: {$testCommission}%");
        $this->info("Vendor Receives: {$testPayout} KWD");
        $this->info("Platform Keeps: {$testPlatformFee} KWD");
        $this->newLine();

        $this->info('=== Test Complete ===');
        return Command::SUCCESS;
    }
}

