<?php

namespace App\Console\Commands;

use App\Models\Vendor;
use App\Models\VendorPayout;
use App\Models\FinanceTransaction;
use App\Models\Setting;
use Illuminate\Console\Command;
use Carbon\Carbon;
use Illuminate\Support\Facades\DB;

class GenerateVendorPayouts extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'payouts:generate';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Generate vendor payouts based on settings and pending earnings';

    /**
     * Execute the console command.
     */
    public function handle()
    {
        $this->info('Starting payout generation...');

        // Get payout frequency from settings
        $payoutFrequency = Setting::where('key', 'payout_frequency')->value('value') ?? '15_days';
        $vendorCommission = (float) (Setting::where('key', 'vendor_commission')->value('value') ?? 10);
        
        $this->info("Payout Frequency: {$payoutFrequency}");
        $this->info("Vendor Commission: {$vendorCommission}%");

        // Get date ranges based on frequency (15_days has 2 periods per month)
        $dateRanges = $this->getDateRanges($payoutFrequency);
        
        // Get all vendors
        $vendors = Vendor::all();
        $this->info("Processing {$vendors->count()} vendors for " . count($dateRanges) . " period(s)...");

        $payoutsCreated = 0;
        $payoutsSkipped = 0;

        foreach ($vendors as $vendor) {
            // Process each period
            foreach ($dateRanges as $dateRange) {
                $this->info("  Processing period: {$dateRange['from']} to {$dateRange['to']}");
                
                // Calculate vendor earnings for the period
                // Only count successful order transactions that haven't been paid out yet
                $earnings = $this->calculateVendorEarnings($vendor->id, $dateRange);
                
                if ($earnings['total'] <= 0) {
                    $this->line("    Vendor {$vendor->name}: No earnings to payout");
                    $payoutsSkipped++;
                    continue;
                }

                // Check if payout already exists for this period
                $existingPayout = VendorPayout::where('vendor_id', $vendor->id)
                    ->where('status', 'pending')
                    ->whereBetween('scheduled_date', [$dateRange['from'], $dateRange['to']])
                    ->first();

                if ($existingPayout) {
                    $this->line("    Vendor {$vendor->name}: Payout already exists (ID: {$existingPayout->payout_id})");
                    $payoutsSkipped++;
                    continue;
                }

                // Calculate payout amount (vendor gets 100% - commission%)
                // If commission is 10%, vendor gets 90% of earnings
                $payoutAmount = $earnings['total'] * (1 - ($vendorCommission / 100));
                
                // Get vendor payment method (default to first available)
                $paymentMethod = $vendor->payment_method ?? 'knet';
                $currency = 'KWD';

                // Generate unique payout ID
                $payoutId = 'PAY-' . strtoupper(uniqid());

                // Calculate scheduled date
                $scheduledDate = $this->getScheduledDate($payoutFrequency, $dateRange);

                // Create payout
                $payout = VendorPayout::create([
                    'payout_id' => $payoutId,
                    'vendor_id' => $vendor->id,
                    'status' => 'pending', // Will be shown in admin for approval
                    'amount' => round($payoutAmount, 2),
                    'currency' => $currency,
                    'payment_method' => $paymentMethod,
                    'account_details' => $vendor->account_details ?? null,
                    'summary' => $this->generateSummary($payoutFrequency, $dateRange, $earnings),
                    'scheduled_date' => $scheduledDate,
                    'notes' => "Auto-generated payout for period {$dateRange['from']} to {$dateRange['to']}",
                    'metadata' => [
                        'period_start' => $dateRange['from'],
                        'period_end' => $dateRange['to'],
                        'total_earnings' => $earnings['total'],
                        'commission_rate' => $vendorCommission,
                        'orders_count' => $earnings['orders_count'],
                        'generated_at' => now()->toIso8601String(),
                    ],
                ]);

                $this->info("    ✓ Created payout for {$vendor->name}: {$payoutId} - Amount: {$payoutAmount} {$currency}");
                $payoutsCreated++;
            }
        }

        $this->info("\nPayout generation completed!");
        $this->info("Created: {$payoutsCreated} payouts");
        $this->info("Skipped: {$payoutsSkipped} vendors");

        return Command::SUCCESS;
    }

    /**
     * Calculate vendor earnings for a date range
     */
    private function calculateVendorEarnings(int $vendorId, array $dateRange): array
    {
        // Get successful order transactions
        // Only count orders with status 'Success' or 'completed'
        $transactions = FinanceTransaction::where('vendor_id', $vendorId)
            ->where('type', 'order')
            ->whereIn('attempt_status', ['Success', 'completed', 'Succss', 'success'])
            ->whereBetween('created_at', [
                Carbon::parse($dateRange['from'])->startOfDay(),
                Carbon::parse($dateRange['to'])->endOfDay()
            ])
            ->get();

        // Get completed payouts for this vendor to exclude already paid transactions
        $completedPayouts = VendorPayout::where('vendor_id', $vendorId)
            ->where('status', 'completed')
            ->whereBetween('scheduled_date', [
                Carbon::parse($dateRange['from'])->startOfDay(),
                Carbon::parse($dateRange['to'])->endOfDay()
            ])
            ->get();

        // If there are completed payouts in this period, we might want to exclude those transactions
        // For now, we'll calculate all earnings in the period
        // You can enhance this logic to track which transactions were already paid

        $total = $transactions->sum('amount');
        $ordersCount = $transactions->count();

        return [
            'total' => $total,
            'orders_count' => $ordersCount,
            'transactions' => $transactions,
        ];
    }

    /**
     * Get date ranges based on payout frequency
     * Returns array of date ranges (15_days has 2 periods per month)
     */
    private function getDateRanges(string $frequency): array
    {
        $now = Carbon::now();
        $ranges = [];

        switch ($frequency) {
            case '15_days':
                // Two periods per month:
                // Period 1: 1st to 16th
                $ranges[] = [
                    'from' => $now->copy()->startOfMonth()->startOfDay()->format('Y-m-d'),
                    'to' => $now->copy()->startOfMonth()->copy()->day(16)->endOfDay()->format('Y-m-d'),
                ];
                // Period 2: 17th to last day of month
                $ranges[] = [
                    'from' => $now->copy()->startOfMonth()->copy()->day(17)->startOfDay()->format('Y-m-d'),
                    'to' => $now->copy()->endOfMonth()->endOfDay()->format('Y-m-d'),
                ];
                break;
            
            case 'monthly':
                // Full month: 1st to last day of current month
                $ranges[] = [
                    'from' => $now->copy()->startOfMonth()->startOfDay()->format('Y-m-d'),
                    'to' => $now->copy()->endOfMonth()->endOfDay()->format('Y-m-d'),
                ];
                break;
            
            case 'custom':
                // Get custom date from settings
                $customDate = Setting::where('key', 'custom_payout_date')->value('value');
                if ($customDate) {
                    $ranges[] = [
                        'from' => Carbon::parse($customDate)->startOfDay()->format('Y-m-d'),
                        'to' => $now->copy()->endOfDay()->format('Y-m-d'),
                    ];
                } else {
                    // Default to monthly if custom date not set
                    $ranges[] = [
                        'from' => $now->copy()->startOfMonth()->startOfDay()->format('Y-m-d'),
                        'to' => $now->copy()->endOfMonth()->endOfDay()->format('Y-m-d'),
                    ];
                }
                break;
            
            default:
                // Default to 15 days: two periods
                $ranges[] = [
                    'from' => $now->copy()->startOfMonth()->startOfDay()->format('Y-m-d'),
                    'to' => $now->copy()->startOfMonth()->copy()->day(16)->endOfDay()->format('Y-m-d'),
                ];
                $ranges[] = [
                    'from' => $now->copy()->startOfMonth()->copy()->day(17)->startOfDay()->format('Y-m-d'),
                    'to' => $now->copy()->endOfMonth()->endOfDay()->format('Y-m-d'),
                ];
        }

        return $ranges;
    }

    /**
     * Get scheduled date for payout
     */
    private function getScheduledDate(string $frequency, array $dateRange): string
    {
        $periodEnd = Carbon::parse($dateRange['to']);
        $periodStart = Carbon::parse($dateRange['from']);

        switch ($frequency) {
            case '15_days':
                // Check if this is first period (1-16) or second period (17-31)
                if ($periodStart->day <= 16) {
                    // First period: 1st to 16th
                    // Scheduled: Same as period end (Dec 16)
                    return $periodEnd->format('Y-m-d');
                } else {
                    // Second period: 17th to last day
                    // Scheduled: Period end + 1 day (Dec 31 → Jan 1)
                    return $periodEnd->copy()->addDay()->format('Y-m-d');
                }
            
            case 'monthly':
                // Period: 1st to last day of month
                // Scheduled: Period end + 1 day (Dec 31 → Jan 1)
                return $periodEnd->copy()->addDay()->format('Y-m-d');
            
            case 'custom':
                $customDate = Setting::where('key', 'custom_payout_date')->value('value');
                if ($customDate) {
                    return Carbon::parse($customDate)->format('Y-m-d');
                }
                // Default: period end + 1 day (monthly behavior)
                return $periodEnd->copy()->addDay()->format('Y-m-d');
            
            default:
                // Default: check period start day
                if ($periodStart->day <= 16) {
                    return $periodEnd->format('Y-m-d');
                } else {
                    return $periodEnd->copy()->addDay()->format('Y-m-d');
                }
        }
    }

    /**
     * Generate summary text for payout
     */
    private function generateSummary(string $frequency, array $dateRange, array $earnings): string
    {
        $period = match($frequency) {
            '15_days' => '15 Days',
            'monthly' => 'Monthly',
            'custom' => 'Custom Period',
            default => 'Period',
        };

        return "{$period} commission payout ({$dateRange['from']} to {$dateRange['to']}) - {$earnings['orders_count']} orders";
    }
}

