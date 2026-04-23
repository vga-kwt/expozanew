<?php

namespace App\Http\Controllers;

use App\Models\VendorPayout;
use App\Models\Vendor;
use App\Services\FinanceService;
use Illuminate\Http\Request;
use Inertia\Inertia;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\Log;

class PayoutController extends Controller
{
    protected $financeService;

    public function __construct(FinanceService $financeService)
    {
        $this->financeService = $financeService;
    }

    /**
     * Display vendor payouts
     */
    public function index(Request $request)
    {
        $filters = $this->getPayoutFilters($request);
        $payouts = $this->financeService->getPayouts($filters);
        $statistics = $this->financeService->getPayoutStatistics($this->getDateRange($filters));
        $vendors = Vendor::all();

        return Inertia::render('Finance/Payouts', [
            'payouts' => $payouts,
            'statistics' => $statistics,
            'vendors' => $vendors,
            'filters' => $filters,
            'currencies' => $this->financeService->getAvailableCurrencies(),
            'paymentMethods' => $this->financeService->getPaymentMethods(),
            'payoutStatuses' => $this->financeService->getPayoutStatuses(),
        ]);
    }

    /**
     * Show payout details
     */
    public function show(VendorPayout $payout)
    {
        $payout->load(['vendor', 'approvedBy']);
        
        return Inertia::render('Finance/PayoutDetails', [
            'payout' => $payout,
        ]);
    }

    /**
     * Approve a vendor payout
     */
    public function approve(Request $request, VendorPayout $payout)
    {
        $request->validate([
            'transaction_reference_id' => 'required|string|max:255',
            'notes' => 'nullable|string',
        ]);

        $payout->update([
            'status' => 'approved',
            'transaction_reference_id' => $request->transaction_reference_id,
            'approved_by' => auth()->id(),
            'approved_at' => now(),
            'notes' => $request->notes,
        ]);

        return redirect()->back()->with('success', 'Payout approved successfully.');
    }

    /**
     * Complete a vendor payout
     */
    public function complete(VendorPayout $payout)
    {
        $payout->update([
            'status' => 'completed',
            'processed_date' => now(),
        ]);

        return redirect()->back()->with('success', 'Payout marked as completed.');
    }

    /**
     * Reject a vendor payout
     */
    public function reject(Request $request, VendorPayout $payout)
    {
        $request->validate([
            'notes' => 'required|string',
        ]);

        $payout->update([
            'status' => 'rejected',
            'notes' => $request->notes,
        ]);

        return redirect()->back()->with('success', 'Payout rejected.');
    }

    /**
     * Cancel a vendor payout
     */
    public function cancel(Request $request, VendorPayout $payout)
    {
        $request->validate([
            'notes' => 'required|string',
        ]);

        $payout->update([
            'status' => 'cancelled',
            'notes' => $request->notes,
        ]);

        return redirect()->back()->with('success', 'Payout cancelled.');
    }

    /**
     * Manually generate payouts
     */
    public function generate(Request $request)
    {
        try {
            \Illuminate\Support\Facades\Artisan::call('payouts:generate');
            
            return redirect()->back()->with('success', 'Payouts generated successfully.');
        } catch (\Exception $e) {
            Log::error('Payout generation failed: ' . $e->getMessage());
            return redirect()->back()->with('error', 'Failed to generate payouts: ' . $e->getMessage());
        }
    }

    /**
     * Export payouts to CSV
     */
    public function export(Request $request)
    {
        $query = VendorPayout::with(['vendor', 'approvedBy']);
        // Search filter
        if ($request->filled('search')) {
            $search = $request->input('search');
            $query->where(function ($q) use ($search) {
                $q->where('payout_id', 'like', "%{$search}%")
                  ->orWhere('summary', 'like', "%{$search}%")
                  ->orWhereHas('vendor', function ($vendorQuery) use ($search) {
                      $vendorQuery->where('name', 'like', "%{$search}%")
                                 ->orWhere('brand_name_en', 'like', "%{$search}%");
                  });
            });
        }
        if ($request->filled('status') && $request->input('status') !== 'all') {
            $query->where('status', $request->input('status'));
        }
        if ($request->filled('payment_method') && $request->input('payment_method') !== 'all') {
            $query->where('payment_method', $request->input('payment_method'));
        }
        if ($request->filled('currency') && $request->input('currency') !== 'all') {
            $query->where('currency', $request->input('currency'));
        }
        if ($request->filled('vendor_id') && $request->input('vendor_id') !== 'all') {
            $query->where('vendor_id', $request->input('vendor_id'));
        }
        if ($request->filled('date_from')) {
            $query->whereDate('scheduled_date', '>=', $request->input('date_from'));
        }
        if ($request->filled('date_to')) {
            $query->whereDate('scheduled_date', '<=', $request->input('date_to'));
        }
        if ($request->filled('amount_min')) {
            $query->where('amount', '>=', $request->input('amount_min'));
        }
        if ($request->filled('amount_max')) {
            $query->where('amount', '<=', $request->input('amount_max'));
        }

        $payouts = $query->orderBy('created_at', 'desc')->get();

        $headers = [
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
        ];

        $filename = 'vendor_payouts_' . date('Y-m-d_H-i-s') . '.csv';

        $callback = function() use ($payouts, $headers) {
            $file = fopen('php://output', 'w');
            fputcsv($file, $headers);
            foreach ($payouts as $payout) {
                fputcsv($file, [
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
            fclose($file);
        };

        return response()->stream($callback, 200, [
            'Content-Type' => 'text/csv',
            'Content-Disposition' => 'attachment; filename="' . $filename . '"',
        ]);
    }

    /**
     * Get payout filters from request
     */
    private function getPayoutFilters(Request $request): array
    {
        return [
            'search' => $request->input('search'),
            'status' => $request->input('status'),
            'payment_method' => $request->input('payment_method'),
            'currency' => $request->input('currency'),
            'vendor_id' => $request->input('vendor_id'),
            'date_from' => $request->input('date_from'),
            'date_to' => $request->input('date_to'),
            'amount_min' => $request->input('amount_min'),
            'amount_max' => $request->input('amount_max'),
            'per_page' => $request->input('per_page', 15),
        ];
    }

    /**
     * Get date range from filters
     */
    private function getDateRange(array $filters): array
    {
        $dateRange = [];

        if (!empty($filters['date_from'])) {
            $dateRange[] = \Carbon\Carbon::parse($filters['date_from'])->startOfDay();
        }

        if (!empty($filters['date_to'])) {
            $dateRange[] = \Carbon\Carbon::parse($filters['date_to'])->endOfDay();
        }

        return $dateRange;
    }
} 