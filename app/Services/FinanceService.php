<?php

namespace App\Services;

use App\Models\FinanceTransaction;
use App\Models\VendorPayout;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Pagination\LengthAwarePaginator;
use Illuminate\Support\Facades\DB;
use Carbon\Carbon;

class FinanceService
{
    /**
     * Get finance transactions with filtering and pagination
     */
    public function getTransactions(array $filters = []): LengthAwarePaginator
    {
        $query = FinanceTransaction::with(['user']);

        $this->applyTransactionFilters($query, $filters);

        return $query->orderBy('created_at', 'desc')
                    ->paginate($filters['per_page'] ?? 15);
    }

    /**
     * Get vendor payouts with filtering and pagination
     */
    public function getPayouts(array $filters = []): LengthAwarePaginator
    {
        $query = VendorPayout::with(['vendor', 'approvedBy']);

        $this->applyPayoutFilters($query, $filters);

        return $query->orderBy('created_at', 'desc')
                    ->paginate($filters['per_page'] ?? 15);
    }

    /**
     * Get finance statistics
     */
    public function getStatistics(array $filters = []): array
    {
        $dateRange = $this->getDateRange($filters);

        $transactionStats = $this->getTransactionStatistics($dateRange);
        $payoutStats = $this->getPayoutStatistics($dateRange);

        return [
            'transactions' => $transactionStats,
            'payouts' => $payoutStats,
            'summary' => $this->getSummaryStatistics($transactionStats, $payoutStats)
        ];
    }

    /**
     * Get payout statistics
     */
    public function getPayoutStatistics(array $dateRange = []): array
    {
        $query = VendorPayout::query();

        if (!empty($dateRange) && count($dateRange) === 2) {
            $query->whereBetween('created_at', $dateRange);
        } elseif (!empty($dateRange) && count($dateRange) === 1) {
            $query->where('created_at', '>=', $dateRange[0]);
        }

        $totalPayouts = $query->count();
        $totalAmount = $query->sum('amount');

        $statusStats = $query->select('status', DB::raw('count(*) as count'), DB::raw('sum(amount) as total_amount'))
                            ->groupBy('status')
                            ->get()
                            ->keyBy('status');

        // Calculate amounts for each status, defaulting to 0 if no payouts exist
        $pendingAmount = 0;
        $approvedAmount = 0;
        $completedAmount = 0;
        $rejectedAmount = 0;
        $cancelledAmount = 0;

        if ($statusStats->has('pending')) {
            $pendingAmount = $statusStats['pending']->total_amount ?? 0;
        }
        if ($statusStats->has('approved')) {
            $approvedAmount = $statusStats['approved']->total_amount ?? 0;
        }
        if ($statusStats->has('completed')) {
            $completedAmount = $statusStats['completed']->total_amount ?? 0;
        }
        if ($statusStats->has('rejected')) {
            $rejectedAmount = $statusStats['rejected']->total_amount ?? 0;
        }
        if ($statusStats->has('cancelled')) {
            $cancelledAmount = $statusStats['cancelled']->total_amount ?? 0;
        }

        return [
            'total_payouts' => $totalPayouts,
            'total_amount' => $totalAmount,
            'status_breakdown' => $statusStats,
            'pending_amount' => $pendingAmount,
            'approved_amount' => $approvedAmount,
            'completed_amount' => $completedAmount,
            'rejected_amount' => $rejectedAmount,
            'cancelled_amount' => $cancelledAmount,
        ];
    }

    /**
     * Get transaction statistics
     */
    public function getTransactionStatistics(array $dateRange = []): array
    {
        $query = FinanceTransaction::query();

        if (!empty($dateRange) && count($dateRange) === 2) {
            $query->whereBetween('created_at', $dateRange);
        } elseif (!empty($dateRange) && count($dateRange) === 1) {
            $query->where('created_at', '>=', $dateRange[0]);
        }

        $totalTransactions = $query->count();
        $totalAmount = $query->sum('amount');

        // Get all type stats (for display)
        $typeStats = $query->select('type', DB::raw('count(*) as count'), DB::raw('sum(amount) as total_amount'))
                          ->groupBy('type')
                          ->get()
                          ->keyBy('type');

        // For income calculation, only count successful transactions
        $successfulStatuses = ['completed', 'success', 'Succss', 'Success'];
        
        $successfulQuery = FinanceTransaction::query();
        if (!empty($dateRange) && count($dateRange) === 2) {
            $successfulQuery->whereBetween('created_at', $dateRange);
        } elseif (!empty($dateRange) && count($dateRange) === 1) {
            $successfulQuery->where('created_at', '>=', $dateRange[0]);
        }
        $successfulQuery->whereIn('attempt_status', $successfulStatuses);
        
        $successfulTypeStats = $successfulQuery->select('type', DB::raw('count(*) as count'), DB::raw('sum(amount) as total_amount'))
                          ->groupBy('type')
                          ->get()
                          ->keyBy('type');

        // Map actual transaction types to income/expense categories (only successful ones)
        $incomeAmount = 0;
        $expenseAmount = 0;
        $refundAmount = 0;

        // Income types: order, subscription, expo_booking (revenue generating) - only successful
        if ($successfulTypeStats->has('order')) {
            $incomeAmount += $successfulTypeStats['order']->total_amount ?? 0;
        }
        if ($successfulTypeStats->has('subscription') || $successfulTypeStats->has('subscription renew') || $successfulTypeStats->has('subscription upgrade')) {
            $incomeAmount += ($successfulTypeStats['subscription']->total_amount ?? 0) + 
                           ($successfulTypeStats['subscription renew']->total_amount ?? 0) + 
                           ($successfulTypeStats['subscription upgrade']->total_amount ?? 0);
        }
        if ($successfulTypeStats->has('expo_booking')) {
            $incomeAmount += $successfulTypeStats['expo_booking']->total_amount ?? 0;
        }
        if ($successfulTypeStats->has('expo_slot')) {
            $incomeAmount += $successfulTypeStats['expo_slot']->total_amount ?? 0;
        }

        // Expense types: refund, chargeback (money going out) - only successful
        if ($successfulTypeStats->has('chargeback')) {
            $expenseAmount += $successfulTypeStats['chargeback']->total_amount ?? 0;
        }

        // Refund type (separate category) - only successful
        if ($successfulTypeStats->has('refund')) {
            $refundAmount = $successfulTypeStats['refund']->total_amount ?? 0;
            $expenseAmount += $refundAmount; // Also count as expense
        }

        return [
            'total_transactions' => $totalTransactions,
            'total_amount' => $totalAmount,
            'type_breakdown' => $typeStats,
            'income_amount' => $incomeAmount,
            'expense_amount' => $expenseAmount,
            'refund_amount' => $refundAmount,
        ];
    }

    /**
     * Get summary statistics
     */
    public function getSummaryStatistics(array $transactionStats, array $payoutStats): array
    {
        $netIncome = ($transactionStats['income_amount'] ?? 0) - ($transactionStats['expense_amount'] ?? 0);
        $totalPayouts = $payoutStats['completed_amount'] ?? 0;
        $pendingPayouts = $payoutStats['pending_amount'] ?? 0;
        $availableBalance = $netIncome - $totalPayouts;

        return [
            'net_income' => $netIncome,
            'total_payouts' => $totalPayouts,
            'pending_payouts' => $pendingPayouts,
            'available_balance' => $availableBalance,
            'profit_margin' => $netIncome > 0 ? (($netIncome - $totalPayouts) / $netIncome) * 100 : 0
        ];
    }

    /**
     * Apply filters to transaction query
     */
    private function applyTransactionFilters(Builder $query, array $filters): void
    {
        // Search filter
        if (!empty($filters['search'])) {
            $search = $filters['search'];
            $query->where(function ($q) use ($search) {
                $q->where('transaction_id', 'like', "%{$search}%")
                  ->orWhere('summery', 'like', "%{$search}%")
                  ->orWhere('payment_reference_id', 'like', "%{$search}%")
                  ->orWhereHas('user', function ($userQuery) use ($search) {
                      $userQuery->where('full_name', 'like', "%{$search}%")
                               ->orWhere('email', 'like', "%{$search}%");
                  });
            });
        }

        // Type filter
        if (!empty($filters['type']) && $filters['type'] !== 'all') {
            $query->where('type', $filters['type']);
        }

        // Status filter
        if (!empty($filters['status']) && $filters['status'] !== 'all') {
            $query->where('attempt_status', $filters['status']);
        }

        // Date range filter
        if (!empty($filters['date_from'])) {
            $query->whereDate('created_at', '>=', $filters['date_from']);
        }

        if (!empty($filters['date_to'])) {
            $query->whereDate('created_at', '<=', $filters['date_to']);
        }

        // Amount range filter
        if (!empty($filters['amount_min'])) {
            $query->where('amount', '>=', $filters['amount_min']);
        }

        if (!empty($filters['amount_max'])) {
            $query->where('amount', '<=', $filters['amount_max']);
        }

        // Currency filter - Note: finance_transactions doesn't have currency field
        // This filter will be ignored for transactions
    }

    /**
     * Apply filters to payout query
     */
    private function applyPayoutFilters(Builder $query, array $filters): void
    {
        // Search filter
        if (!empty($filters['search'])) {
            $search = $filters['search'];
            $query->where(function ($q) use ($search) {
                $q->where('payout_id', 'like', "%{$search}%")
                  ->orWhere('summary', 'like', "%{$search}%")
                  ->orWhereHas('vendor', function ($vendorQuery) use ($search) {
                      $vendorQuery->where('name', 'like', "%{$search}%")
                                 ->orWhere('brand_name_en', 'like', "%{$search}%");
                  });
            });
        }

        // Status filter
        if (!empty($filters['status']) && $filters['status'] !== 'all') {
            $query->where('status', $filters['status']);
        }

        // Payment method filter
        if (!empty($filters['payment_method']) && $filters['payment_method'] !== 'all') {
            $query->where('payment_method', $filters['payment_method']);
        }

        // Currency filter
        if (!empty($filters['currency']) && $filters['currency'] !== 'all') {
            $query->where('currency', $filters['currency']);
        }

        // Date range filter (only scheduled_date, like Expo export)
        if (!empty($filters['date_from'])) {
            $query->whereDate('scheduled_date', '>=', $filters['date_from']);
        }
        if (!empty($filters['date_to'])) {
            $query->whereDate('scheduled_date', '<=', $filters['date_to']);
        }

        // Amount range filter
        if (!empty($filters['amount_min'])) {
            $query->where('amount', '>=', $filters['amount_min']);
        }

        if (!empty($filters['amount_max'])) {
            $query->where('amount', '<=', $filters['amount_max']);
        }

        // Vendor filter
        if (!empty($filters['vendor_id'])) {
            $query->where('vendor_id', $filters['vendor_id']);
        }
    }

    /**
     * Get date range from filters
     */
    private function getDateRange(array $filters): array
    {
        $dateRange = [];

        if (!empty($filters['date_from'])) {
            $dateRange[] = Carbon::parse($filters['date_from'])->startOfDay();
        }

        if (!empty($filters['date_to'])) {
            $dateRange[] = Carbon::parse($filters['date_to'])->endOfDay();
        }

        return $dateRange;
    }

    /**
     * Get available currencies
     */
    public function getAvailableCurrencies(): array
    {
        return [
            'USD' => 'US Dollar',
            'EUR' => 'Euro',
            'AED' => 'UAE Dirham',
            'SAR' => 'Saudi Riyal',
            'GBP' => 'British Pound',
            'CAD' => 'Canadian Dollar',
            'AUD' => 'Australian Dollar',
            'JPY' => 'Japanese Yen',
            'CHF' => 'Swiss Franc',
            'CNY' => 'Chinese Yuan'
        ];
    }

    /**
     * Get payment methods
     */
    public function getPaymentMethods(): array
    {
        return [
            'card' => 'Card',
            'knet' => 'KNET',
            'myfatoorah' => 'MyFatoorah'
        ];
    }

    /**
     * Get transaction types
     */
    public function getTransactionTypes(): array
    {
        return [
            'order' => 'Order',
            'subscription' => 'Subscription',
            'expo_booking' => 'Expo Booking',
            'expo_slot' => 'Expo Slot',
            'refund' => 'Refund',
            'chargeback' => 'Chargeback'
        ];
    }

    /**
     * Get payout statuses
     */
    public function getPayoutStatuses(): array
    {
        return [
            'pending' => 'Pending',
            'approved' => 'Approved',
            'completed' => 'Completed',
            'rejected' => 'Rejected',
            'cancelled' => 'Cancelled'
        ];
    }

    /**
     * Export transactions to CSV
     */
    public function exportTransactions(array $filters = []): string
    {
        $query = FinanceTransaction::with(['user']);
        $this->applyTransactionFilters($query, $filters);
        $transactions = $query->orderBy('created_at', 'desc')->get();

        $filename = 'finance_transactions_' . date('Y-m-d_H-i-s') . '.csv';
        $filepath = storage_path('app/public/exports/' . $filename);

        // Ensure directory exists
        if (!file_exists(dirname($filepath))) {
            mkdir(dirname($filepath), 0755, true);
        }

        $handle = fopen($filepath, 'w');

        // Add headers
        fputcsv($handle, [
            'Transaction ID',
            'Type',
            'Status',
            'Amount',
            'Charge',
            'Summary',
            'Payment Reference ID',
            'Payment Processor',
            'User',
            'Created At'
        ]);

        // Add data
        foreach ($transactions as $transaction) {
            fputcsv($handle, [
                $transaction->transaction_id,
                $transaction->type,
                $transaction->attempt_status,
                $transaction->amount,
                $transaction->charge,
                $transaction->summery,
                $transaction->payment_reference_id,
                $transaction->payment_processor,
                $transaction->user?->full_name ?? 'N/A',
                $transaction->created_at->format('Y-m-d H:i:s')
            ]);
        }

        fclose($handle);

        return $filepath;
    }

    /**
     * Export payouts to CSV
     */
    public function exportPayouts(array $filters = []): string
    {
        $query = VendorPayout::with(['vendor', 'approvedBy']);
        $this->applyPayoutFilters($query, $filters);
        $payouts = $query->orderBy('created_at', 'desc')->get();

        $filename = 'vendor_payouts_' . date('Y-m-d_H-i-s') . '.csv';
        $filepath = storage_path('app/public/exports/' . $filename);

        // Ensure directory exists
        if (!file_exists(dirname($filepath))) {
            mkdir(dirname($filepath), 0755, true);
        }

        $handle = fopen($filepath, 'w');

        // Add headers
        fputcsv($handle, [
            'Payout ID',
            'Vendor',
            'Status',
            'Amount',
            'Currency',
            'Payment Method',
            'Summary',
            'Scheduled Date',
            'Processed Date',
            'Transaction Reference',
            'Approved By',
            'Notes',
            'Created At'
        ]);

        // Add data
        foreach ($payouts as $payout) {
            fputcsv($handle, [
                $payout->payout_id,
                $payout->vendor?->name ?? 'N/A',
                $payout->status,
                $payout->amount,
                $payout->currency,
                $payout->payment_method,
                $payout->summary,
                $payout->scheduled_date,
                $payout->processed_date,
                $payout->transaction_reference_id,
                $payout->approvedBy?->full_name ?? 'N/A',
                $payout->notes,
                $payout->created_at->format('Y-m-d H:i:s')
            ]);
        }

        fclose($handle);

        return $filepath;
    }
} 