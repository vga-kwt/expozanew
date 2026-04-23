<?php

namespace App\Http\Controllers\Vendor;

use App\Http\Controllers\Controller;
use App\Models\FinanceTransaction;
use App\Models\VendorPayout;
use App\Models\Setting;
use App\Models\Vendor;
use Illuminate\Http\Request;
use Inertia\Inertia;
use Illuminate\Support\Facades\Auth;
use Carbon\Carbon;
use App\Helpers\ExportService;

class FinanceController extends Controller
{
    public function index(Request $request)
    {
        $vendor = Auth::user()->vendor;
        if (!$vendor) {
            return redirect()->route('vendor.profile.index')->with('error', 'Vendor profile not found.');
        }

        $filters = [
            'type' => $request->input('type', 'all'),
            'status' => $request->input('status', 'all'),
            'date_from' => $request->input('date_from', ''),
            'date_to' => $request->input('date_to', ''),
        ];

        $query = FinanceTransaction::
            where('vendor_id', $vendor->id)
            ->orderByDesc('created_at');

        // Apply filters
        if (!empty($filters['type']) && $filters['type'] !== 'all') {
            $query->where('type', $filters['type']);
        }
        if (!empty($filters['status']) && $filters['status'] !== 'all') {
            $query->where('attempt_status', $filters['status']);
        }
        if (!empty($filters['date_from'])) {
            $query->whereDate('created_at', '>=', $filters['date_from']);
        }
        if (!empty($filters['date_to'])) {
            $query->whereDate('created_at', '<=', $filters['date_to']);
        }

        $transactions = $query->paginate(15)->withQueryString();

        // Summary - Use whereIn for attempt_status to match all success statuses
        $successStatuses = ['Success', 'completed', 'Succss', 'success'];
        
        // Get commission rate (vendor custom or default from settings)
        $defaultCommission = (float) (Setting::where('key', 'vendor_commission')->value('value') ?? 10);
        $commissionRate = $vendor->commission ? (float) $vendor->commission : $defaultCommission;
        
        // Calculate total sales (gross revenue)
        $totalSales = FinanceTransaction::where('vendor_id', $vendor->id)
            ->where('type', 'order')
            ->whereIn('attempt_status', $successStatuses)
            ->sum('amount');
        
        // Calculate vendor earnings (after commission deduction)
        // Vendor gets (100% - commission%)
        $vendorEarningsMultiplier = 1 - ($commissionRate / 100);
        $totalEarnings = $totalSales * $vendorEarningsMultiplier;
        
        // Calculate platform commission
        $platformCommission = $totalSales - $totalEarnings;
        
        // This month sales
        $thisMonthSales = FinanceTransaction::where('vendor_id', $vendor->id)
            ->where('type', 'order')
            ->whereIn('attempt_status', $successStatuses)
            ->whereMonth('created_at', now()->month)
            ->whereYear('created_at', now()->year)
            ->sum('amount');
        
        // This month earnings (after commission)
        $thisMonthEarnings = $thisMonthSales * $vendorEarningsMultiplier;
        
        $summary = [
            'total_sales' => $totalSales, // Gross revenue from orders
            'total_earnings' => $totalEarnings, // Vendor earnings after commission
            'platform_commission' => $platformCommission, // Platform's commission
            'commission_rate' => $commissionRate, // Commission percentage
            'total_subscription_fees' => FinanceTransaction::where('vendor_id', $vendor->id)
                ->whereIn('type', ['subscription', 'subscription renew', 'subscription upgrade'])
                ->whereIn('attempt_status', $successStatuses)
                ->sum('amount'),
            'total_expo_slots' => FinanceTransaction::where('vendor_id', $vendor->id)
                ->where('type', 'expo_booking')
                ->whereIn('attempt_status', $successStatuses)
                ->sum('amount'),
            'total_refunds' => FinanceTransaction::where('vendor_id', $vendor->id)
                ->where('type', 'refund')
                ->whereIn('attempt_status', $successStatuses)
                ->sum('amount'),
            'pending_earnings' => FinanceTransaction::where('vendor_id', $vendor->id)
                ->where('type', 'order')
                ->where('attempt_status', 'pending')
                ->sum('amount'),
            'this_month_sales' => $thisMonthSales,
            'this_month_earnings' => $thisMonthEarnings,
        ];

        return Inertia::render('Vendor/Finance/Index', [
            'transactions' => $transactions,
            'summary' => $summary,
            'filters' => $filters,
        ]);
    }

    public function payouts(Request $request)
    {
        $vendor = Auth::user()->vendor;
        if (!$vendor) {
            return redirect()->route('vendor.profile.index')->with('error', 'Vendor profile not found.');
        }

        $filters = [
            'status' => $request->input('status', 'all'),
            'date_from' => $request->input('date_from', ''),
            'date_to' => $request->input('date_to', ''),
        ];

        $query = VendorPayout::where('vendor_id', $vendor->id)
            ->with(['approvedBy'])
            ->orderByDesc('created_at');

        // Apply filters
        if (!empty($filters['status']) && $filters['status'] !== 'all') {
            $query->where('status', $filters['status']);
        }
        if (!empty($filters['date_from'])) {
            $query->whereDate('scheduled_date', '>=', $filters['date_from']);
        }
        if (!empty($filters['date_to'])) {
            $query->whereDate('scheduled_date', '<=', $filters['date_to']);
        }

        $payouts = $query->paginate(15)->withQueryString();

        // Get commission rate for display
        $defaultCommission = (float) (Setting::where('key', 'vendor_commission')->value('value') ?? 10);
        $commissionRate = $vendor->commission ? (float) $vendor->commission : $defaultCommission;
        
        // Calculate total earnings (for reference)
        $successStatuses = ['Success', 'completed', 'Succss', 'success'];
        $totalSales = FinanceTransaction::where('vendor_id', $vendor->id)
            ->where('type', 'order')
            ->whereIn('attempt_status', $successStatuses)
            ->sum('amount');
        $vendorEarningsMultiplier = 1 - ($commissionRate / 100);
        $totalEarnings = $totalSales * $vendorEarningsMultiplier;
        
        // Summary
        $pendingPayouts = VendorPayout::where('vendor_id', $vendor->id)->where('status', 'pending')->sum('amount');
        $completedPayouts = VendorPayout::where('vendor_id', $vendor->id)->where('status', 'completed')->sum('amount');
        
        $summary = [
            'pending_payouts' => $pendingPayouts,
            'completed_payouts' => $completedPayouts,
            'total_payouts' => VendorPayout::where('vendor_id', $vendor->id)->sum('amount'),
            'pending_count' => VendorPayout::where('vendor_id', $vendor->id)->where('status', 'pending')->count(),
            'next_payout_date' => VendorPayout::where('vendor_id', $vendor->id)
                ->where('status', 'pending')
                ->orderBy('scheduled_date')
                ->value('scheduled_date'),
            'commission_rate' => $commissionRate,
            'total_earnings' => $totalEarnings,
            'total_sales' => $totalSales,
        ];

        return Inertia::render('Vendor/Finance/Payouts', [
            'payouts' => $payouts,
            'summary' => $summary,
            'filters' => $filters,
        ]);
    }

    public function exportTransactions(Request $request)
    {
        $vendor = Auth::user()->vendor;
        if (!$vendor) {
            return redirect()->back()->with('error', 'Vendor profile not found.');
        }

        $filters = [
            'type' => $request->input('type', 'all'),
            'status' => $request->input('status', 'all'),
            'date_from' => $request->input('date_from', ''),
            'date_to' => $request->input('date_to', ''),
        ];

        $query = FinanceTransaction::where('user_id', $vendor->user_id)
            ->with(['user', 'transactionable'])
            ->orderByDesc('created_at');

        // Apply filters
        if (!empty($filters['type']) && $filters['type'] !== 'all') {
            $query->where('type', $filters['type']);
        }
        if (!empty($filters['status']) && $filters['status'] !== 'all') {
            $query->where('attempt_status', $filters['status']);
        }
        if (!empty($filters['date_from'])) {
            $query->whereDate('created_at', '>=', $filters['date_from']);
        }
        if (!empty($filters['date_to'])) {
            $query->whereDate('created_at', '<=', $filters['date_to']);
        }

        $transactions = $query->get();

        $csvData = [];
        $csvData[] = [
            'Transaction ID',
            'Type',
            'Status',
            'Amount (KWD)',
            'Vendor Earnings (KWD)',
            'Payment Method',
            'Description',
            'Date',
            'Customer'
        ];
        foreach ($transactions as $transaction) {
            $csvData[] = [
                $transaction->transaction_id,
                ucfirst($transaction->type),
                ucfirst($transaction->attempt_status),
                number_format($transaction->amount, 2),
                number_format($transaction->vendor_earnings, 2),
                $transaction->payment_method,
                $transaction->summery,
                $transaction->created_at->format('Y-m-d H:i:s'),
                $transaction->user ? $transaction->user->name : 'N/A',
            ];
        }
        $filename = 'vendor_transactions_' . $vendor->id . '_' . now()->format('Y-m-d_H-i-s') . '.csv';
        return ExportService::streamCsv($csvData, $filename);
    }

    public function exportPayouts(Request $request)
    {
        $vendor = Auth::user()->vendor;
        if (!$vendor) {
            return redirect()->back()->with('error', 'Vendor profile not found.');
        }

        $filters = [
            'status' => $request->input('status', 'all'),
            'date_from' => $request->input('date_from', ''),
            'date_to' => $request->input('date_to', ''),
        ];

        $query = VendorPayout::where('vendor_id', $vendor->id)
            ->with(['approvedBy'])
            ->orderByDesc('created_at');

        // Apply filters
        if (!empty($filters['status']) && $filters['status'] !== 'all') {
            $query->where('status', $filters['status']);
        }
        if (!empty($filters['date_from'])) {
            $query->whereDate('scheduled_date', '>=', $filters['date_from']);
        }
        if (!empty($filters['date_to'])) {
            $query->whereDate('scheduled_date', '<=', $filters['date_to']);
        }

        $payouts = $query->get();

        $csvData = [];
        $csvData[] = [
            'Payout ID',
            'Status',
            'Amount (KWD)',
            'Currency',
            'Payment Method',
            'Scheduled Date',
            'Processed Date',
            'Transaction Reference',
            'Notes',
            'Created At'
        ];
        foreach ($payouts as $payout) {
            $csvData[] = [
                $payout->payout_id,
                ucfirst($payout->status),
                number_format((float)($payout->amount ?? 0), 2),
                $payout->currency,
                $payout->payment_method,
                $payout->scheduled_date,
                $payout->processed_date ?? 'N/A',
                $payout->transaction_reference_id ?? 'N/A',
                $payout->notes ?? 'N/A',
                $payout->created_at->format('Y-m-d H:i:s'),
            ];
        }
        $filename = 'vendor_payouts_' . $vendor->id . '_' . now()->format('Y-m-d_H-i-s') . '.csv';
        return ExportService::streamCsv($csvData, $filename);
    }
}