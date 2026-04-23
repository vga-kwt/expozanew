<?php

namespace App\Http\Controllers\Vendor;

use App\Http\Controllers\Controller;
use App\Models\FinanceTransaction;
use App\Models\Product;
use App\Models\Order;
use App\Models\OrderItem;
use App\Models\Setting;
use App\Models\Vendor;
use Illuminate\Http\Request;
use Inertia\Inertia;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Log;
use Carbon\Carbon;
use Illuminate\Support\Facades\DB;
use App\Models\VendorSubscription;
use App\Models\Subscription;
use App\Helpers\ExportService;

class AnalyticsController extends Controller
{
    public function index(Request $request)
    {
        $vendor = Auth::user()->vendor;
        if (!$vendor) {
            return redirect()->route('vendor.profile.index')->with('error', 'Vendor profile not found.');
        }

        // Check if vendor has premium subscription
        $hasPremiumAccess = $this->checkPremiumAccess($vendor);

        if (!$hasPremiumAccess) {
            return Inertia::render('Vendor/Analytics/Index', [
                'hasPremiumAccess' => false,
                'salesData' => [],
                'bestSellingProducts' => [],
                'refundData' => [],
                'revenueSummary' => [],
                'filters' => [],
            ]);
        }

        // Get filters with defaults - handle null values properly
        $filters = [
            'period' => $request->input('period', 'monthly'),
            'date_from' => $request->input('date_from') ?: now()->startOfMonth()->format('Y-m-d'),
            'date_to' => $request->input('date_to') ?: now()->format('Y-m-d'),
        ];
        
        // Ensure dates are not null
        if (is_null($filters['date_from']) || empty($filters['date_from'])) {
            $filters['date_from'] = now()->startOfMonth()->format('Y-m-d');
        }
        if (is_null($filters['date_to']) || empty($filters['date_to'])) {
            $filters['date_to'] = now()->format('Y-m-d');
        }

        // Debug: Log the vendor and filters
        Log::info('Analytics index called', [
            'vendor_id' => $vendor->id,
            'filters' => $filters,
            'request_params' => $request->all()
        ]);

        // Sales Analytics
        $salesData = $this->getSalesData($vendor->id, $filters);
        Log::info('Sales data retrieved', ['count' => count($salesData)]);

        // Best Selling Products
        $bestSellingProducts = $this->getBestSellingProducts($vendor->id, $filters);
        Log::info('Best selling products retrieved', ['count' => count($bestSellingProducts)]);

        // Refund Analytics
        $refundData = $this->getRefundAnalytics($vendor->id, $filters);
        Log::info('Refund data retrieved', ['data' => $refundData]);

        // Revenue Summary
        $revenueSummary = $this->getRevenueSummary($vendor->id, $filters);
        Log::info('Revenue summary retrieved', ['data' => $revenueSummary]);

        return Inertia::render('Vendor/Analytics/Index', [
            'salesData' => $salesData,
            'bestSellingProducts' => $bestSellingProducts,
            'refundData' => $refundData,
            'revenueSummary' => $revenueSummary,
            'filters' => $filters,
            'hasPremiumAccess' => $hasPremiumAccess,
        ]);
    }

    public function exportAnalytics(Request $request)
    {
        $vendor = Auth::user()->vendor;

        if (!$vendor) {
            return redirect()->back()->with('error', 'Vendor profile not found.');
        }

        // Check premium access
        $hasPremiumAccess = $this->checkPremiumAccess($vendor);

        if (!$hasPremiumAccess) {
            return redirect()->back()->with('error', 'Analytics export require a premium subscription.');
        }

        // Get filters
        $filters = [
            'period' => $request->input('period', 'monthly'),
            'date_from' => $request->input('date_from', now()->startOfMonth()->format('Y-m-d')),
            'date_to' => $request->input('date_to', now()->format('Y-m-d')),
        ];

        try {
            // Get data for export
            $salesData = $this->getSalesDataForExport($vendor->id, $filters);
            $bestSellingProducts = $this->getBestSellingProductsForExport($vendor->id, $filters);
            $refundData = $this->getRefundAnalyticsForExport($vendor->id, $filters);
            $revenueSummary = $this->getRevenueSummaryForExport($vendor->id, $filters);

            // Prepare CSV data
            $csvData = [];

            // Revenue Summary
            $csvData[] = ['REVENUE SUMMARY'];
            $csvData[] = ['Current Period Revenue', number_format($revenueSummary['current_period'], 2)];
            $csvData[] = ['Previous Period Revenue', number_format($revenueSummary['previous_period'], 2)];
            $csvData[] = ['Growth Percentage', $revenueSummary['growth_percentage'] . '%'];
            $csvData[] = [];

            // Sales Data
            $csvData[] = ['SALES ANALYTICS'];
            $csvData[] = ['Date', 'Sales Count', 'Revenue (KD)', 'Vendor Earnings (KD)'];
            foreach ($salesData as $data) {
                $csvData[] = [
                    $data['date'],
                    $data['sales_count'],
                    number_format($data['revenue'], 2),
                    number_format($data['vendor_earnings'], 2),
                ];
            }
            $csvData[] = [];

            // Best Selling Products
            $csvData[] = ['BEST SELLING PRODUCTS'];
            $csvData[] = ['Product Name', 'Sales Count', 'Revenue (KD)', 'Vendor Earnings (KD)'];
            foreach ($bestSellingProducts as $product) {
                $csvData[] = [
                    $product['product_name'],
                    $product['sales_count'],
                    number_format($product['revenue'], 2),
                    number_format($product['vendor_earnings'], 2),
                ];
            }
            $csvData[] = [];

            // Refund Analytics
            $csvData[] = ['REFUND ANALYTICS'];
            $csvData[] = ['Total Sales', 'Total Refunds', 'Refund Rate (%)', 'Refund Amount (KD)'];
            $csvData[] = [
                $refundData['total_sales'],
                $refundData['total_refunds'],
                number_format($refundData['refund_rate'], 2),
                number_format($refundData['refund_amount'], 2),
            ];

            $filename = 'vendor_analytics_' . $vendor->id . '_' . now()->format('Y-m-d_H-i-s') . '.csv';
            
            return ExportService::streamCsv($csvData, $filename);

        } catch (\Exception $e) {
            Log::error('Analytics export failed', [
                'vendor_id' => $vendor->id,
                'error' => $e->getMessage(),
                'filters' => $filters,
            ]);
            return redirect()->back()->with('error', 'Failed to export analytics. Please try again.');
        }
    }

    // Temporary debug method - remove after fixing
    public function debugSalesData(Request $request)
    {
        $vendor = Auth::user()->vendor;
        if (!$vendor) {
            return response()->json(['error' => 'Vendor not found']);
        }

        // Check basic data
        $totalOrders = Order::where('vendor_id', $vendor->id)->count();
        $deliveredOrders = Order::where('vendor_id', $vendor->id)
            ->where('order_status', 'delivered')
            ->count();
        
        // Check recent orders
        $recentOrders = Order::where('vendor_id', $vendor->id)
            ->where('order_status', 'delivered')
            ->orderBy('created_at', 'desc')
            ->limit(5)
            ->get(['id', 'total_amount', 'created_at', 'order_status']);

        // Test with a wider date range
        $wideRangeOrders = Order::where('vendor_id', $vendor->id)
            ->where('order_status', 'delivered')
            ->whereBetween('created_at', [now()->subYear()->format('Y-m-d') . ' 00:00:00', now()->format('Y-m-d') . ' 23:59:59'])
            ->count();

        return response()->json([
            'vendor_id' => $vendor->id,
            'total_orders' => $totalOrders,
            'delivered_orders' => $deliveredOrders,
            'recent_orders' => $recentOrders,
            'wide_range_orders' => $wideRangeOrders,
            'current_filters' => [
                'date_from' => $request->input('date_from', now()->startOfMonth()->format('Y-m-d')),
                'date_to' => $request->input('date_to', now()->format('Y-m-d')),
                'period' => $request->input('period', 'monthly')
            ]
        ]);
    }

    private function checkPremiumAccess($vendor)
    {
        $activeSubscription = VendorSubscription::where('vendor_id', $vendor->id)
            ->where('status', 'active')
            ->where('end_date', '>', now())
            ->first();
        if (!$activeSubscription) {
            return false;
        }

        // Check if subscription plan allows analytics
        $subscription = $activeSubscription->subscription;

        if ($subscription && in_array($subscription->title_en, ['Premium Plan','Premium Plan (Yearly)'])) {
            return true;
        }

        return false;
    }

    private function getSalesData($vendorId, $filters)
    {
        $dateFrom = $filters['date_from'];
        $dateTo = $filters['date_to'];
        $period = $filters['period'];

        // Get commission rate (vendor custom or default from settings)
        $vendor = Vendor::find($vendorId);
        $defaultCommission = (float) (Setting::where('key', 'vendor_commission')->value('value') ?? 10);
        $commissionRate = $vendor && $vendor->commission ? (float) $vendor->commission : $defaultCommission;
        // Vendor gets (100% - commission%), so multiply by (1 - commission/100)
        $vendorEarningsMultiplier = 1 - ($commissionRate / 100);

        // Debug: Log the filters being used
        Log::info('getSalesData called', [
            'vendor_id' => $vendorId,
            'date_from' => $dateFrom,
            'date_to' => $dateTo,
            'period' => $period,
            'commission_rate' => $commissionRate,
            'vendor_earnings_multiplier' => $vendorEarningsMultiplier
        ]);

        // Ensure proper date format
        $dateFromFormatted = Carbon::parse($dateFrom)->format('Y-m-d');
        $dateToFormatted = Carbon::parse($dateTo)->format('Y-m-d');
        
        Log::info('Date formatting', [
            'original_from' => $dateFrom,
            'original_to' => $dateTo,
            'formatted_from' => $dateFromFormatted,
            'formatted_to' => $dateToFormatted
        ]);

        // Get vendor's orders
        $query = Order::where('vendor_id', $vendorId)
            ->where('order_status', 'delivered')
            ->whereBetween('created_at', [$dateFromFormatted . ' 00:00:00', $dateToFormatted . ' 23:59:59']);

        // Debug: Check if there are any orders for this vendor in the date range
        $totalOrders = (clone $query)->count();
        Log::info('Total orders found', ['count' => $totalOrders]);
        
        // Also check without date filter to see if there are any delivered orders at all
        $totalDeliveredOrders = Order::where('vendor_id', $vendorId)
            ->where('order_status', 'delivered')
            ->count();
        Log::info('Total delivered orders (no date filter)', ['count' => $totalDeliveredOrders]);

        switch ($period) {
            case 'daily':
                $data = $query->selectRaw("
                    DATE(created_at) as date,
                    COUNT(*) as sales_count,
                    SUM(total_amount) as revenue,
                    SUM(total_amount * {$vendorEarningsMultiplier}) as vendor_earnings
                ")
                    ->groupBy('date')
                    ->orderBy('date')
                    ->get();
                break;

            case 'weekly':
                $data = $query->selectRaw("
                    YEARWEEK(created_at) as week,
                    COUNT(*) as sales_count,
                    SUM(total_amount) as revenue,
                    SUM(total_amount * {$vendorEarningsMultiplier}) as vendor_earnings
                ")
                    ->groupBy('week')
                    ->orderBy('week')
                    ->get();

                // Convert week to readable format
                $data->transform(function ($item) {
                    $item->date = 'Week ' . $item->week;
                    return $item;
                });
                break;

            case 'monthly':
            default:
                $data = $query->selectRaw("
                    DATE_FORMAT(created_at, '%Y-%m') as month,
                    COUNT(*) as sales_count,
                    SUM(total_amount) as revenue,
                    SUM(total_amount * {$vendorEarningsMultiplier}) as vendor_earnings
                ")
                    ->groupBy('month')
                    ->orderBy('month')
                    ->get();

                // Convert month to readable format
                $data->transform(function ($item) {
                    $item->date = Carbon::createFromFormat('Y-m', $item->month)->format('M Y');
                    return $item;
                });
                break;
        }

        // Debug: Log the raw data before mapping
        Log::info('Raw sales data', ['data' => $data->toArray()]);

        $result = $data->map(function($item) {
            return [
                'date' => $item->date,
                'sales_count' => (int)$item->sales_count,
                'revenue' => (float)$item->revenue,
                'vendor_earnings' => (float)$item->vendor_earnings,
            ];
        });

        // Debug: Log the final result
        Log::info('Final sales data result', ['result' => $result->toArray()]);

        return $result;
    }

    private function getBestSellingProducts($vendorId, $filters)
    {
        $dateFrom = $filters['date_from'];
        $dateTo = $filters['date_to'];

        // Get vendor's delivered orders
        $orderIds = Order::where('vendor_id', $vendorId)
            ->where('order_status', 'delivered')
            ->whereBetween('created_at', [$dateFrom . ' 00:00:00', $dateTo . ' 23:59:59'])
            ->pluck('id');

        if ($orderIds->isEmpty()) {
            return [];
        }

        // Get best selling products
        return OrderItem::whereIn('order_id', $orderIds)
            ->selectRaw('
                product_id, 
                COUNT(*) as sales_count, 
                SUM(total_amount) as revenue,
                SUM(total_amount * 0.85) as vendor_earnings
            ')
            ->groupBy('product_id')
            ->orderByDesc('sales_count')
            ->limit(10)
            ->with('product:id,name_en')
            ->get()
            ->map(function($item) {
                return [
                    'product_name' => $item->product ? $item->product->name_en : 'Unknown Product',
                    'sales_count' => (int)$item->sales_count,
                    'revenue' => (float)$item->revenue,
                    'vendor_earnings' => (float)$item->vendor_earnings,
                ];
            });
    }

    private function getRefundAnalytics($vendorId, $filters)
    {
        $dateFrom = $filters['date_from'];
        $dateTo = $filters['date_to'];

        // Total sales (delivered orders)
        $totalSales = Order::where('vendor_id', $vendorId)
            ->where('order_status', 'delivered')
            ->whereBetween('created_at', [$dateFrom . ' 00:00:00', $dateTo . ' 23:59:59'])
            ->count();

        // Total refunds
        $totalRefunds = Order::where('vendor_id', $vendorId)
            ->where('order_status', 'refunded')
            ->whereBetween('created_at', [$dateFrom . ' 00:00:00', $dateTo . ' 23:59:59'])
            ->count();

        // Refund amount
        $refundAmount = Order::where('vendor_id', $vendorId)
            ->where('order_status', 'refunded')
            ->whereBetween('created_at', [$dateFrom . ' 00:00:00', $dateTo . ' 23:59:59'])
            ->sum('total_amount');

        // Calculate refund rate
        $refundRate = $totalSales > 0 ? ($totalRefunds / $totalSales) * 100 : 0;

        return [
            'total_sales' => $totalSales,
            'total_refunds' => $totalRefunds,
            'refund_rate' => round($refundRate, 2),
            'refund_amount' => (float)$refundAmount,
        ];
    }

    private function getRevenueSummary($vendorId, $filters)
    {
        $dateFrom = $filters['date_from'];
        $dateTo = $filters['date_to'];

        // Current period revenue
        $currentPeriodRevenue = Order::where('vendor_id', $vendorId)
            ->where('order_status', 'delivered')
            ->whereBetween('created_at', [$dateFrom . ' 00:00:00', $dateTo . ' 23:59:59'])
            ->sum('total_amount');

        // Previous period revenue (same duration)
        $dateFromCarbon = Carbon::parse($dateFrom);
        $dateToCarbon = Carbon::parse($dateTo);
        $duration = $dateFromCarbon->diffInDays($dateToCarbon);

        $previousDateFrom = $dateFromCarbon->copy()->subDays($duration + 1);
        $previousDateTo = $dateFromCarbon->copy()->subDay();

        $previousPeriodRevenue = Order::where('vendor_id', $vendorId)
            ->where('order_status', 'delivered')
            ->whereBetween('created_at', [$previousDateFrom, $previousDateTo])
            ->sum('total_amount');

        // Calculate growth percentage
        $growthPercentage = $previousPeriodRevenue > 0 
            ? (($currentPeriodRevenue - $previousPeriodRevenue) / $previousPeriodRevenue) * 100 
            : 0;

        return [
            'current_period' => (float)$currentPeriodRevenue,
            'previous_period' => (float)$previousPeriodRevenue,
            'growth_percentage' => round($growthPercentage, 2),
        ];
    }

    // Export methods
    private function getSalesDataForExport($vendorId, $filters)
    {
        return $this->getSalesData($vendorId, $filters);
    }

    private function getBestSellingProductsForExport($vendorId, $filters)
    {
        return $this->getBestSellingProducts($vendorId, $filters);
    }

    private function getRefundAnalyticsForExport($vendorId, $filters)
    {
        return $this->getRefundAnalytics($vendorId, $filters);
    }

    private function getRevenueSummaryForExport($vendorId, $filters)
    {
        return $this->getRevenueSummary($vendorId, $filters);
    }
}
