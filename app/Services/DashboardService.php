<?php

namespace App\Services;

use App\Models\FinanceTransaction;
use App\Models\Order;
use App\Models\Subscription;
use App\Models\User;
use App\Models\Vendor;
use App\Models\VendorSubscription;
use App\Models\Expo;
use App\Models\Category;
use App\Models\Product;
use Carbon\Carbon;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;

class DashboardService
{
    protected $financeService;

    public function __construct(FinanceService $financeService)
    {
        $this->financeService = $financeService;
    }

    /**
     * Get admin dashboard data
     */
    public function getAdminDashboardData(array $filters = []): array
    {
        return [
            'stats' => $this->getAdminStats(),
            'sales_data' => $this->getSalesData($filters['period'] ?? 'month'),
            'recent_orders' => $this->getRecentOrders(),
            'recent_users' => $this->getRecentUsers(),
            'top_vendors' => $this->getTopVendors(),
            'expos' => $this->getExpos(),
            'categories' => $this->getCategories(),
            'vendors' => $this->getVendors(),
        ];
    }

    /**
     * Get vendor dashboard data
     */
    public function getVendorDashboardData(Vendor $vendor, $period = 'month'): array
    {
        // Filter delivered orders by period
        $deliveredOrders = $vendor->orders->where('order_status', 'delivered')->filter(function ($order) use ($period) {
            if ($period === 'today') {
                return $order->created_at->isToday();
            } elseif ($period === 'week') {
                return $order->created_at->isCurrentWeek();
            } else { // month
                return $order->created_at->isCurrentMonth();
            }
        });

        $totalSales = $deliveredOrders->sum('total_amount');
        $totalOrders = $deliveredOrders->count();
        $aov = $totalOrders > 0 ? round($totalSales / $totalOrders, 2) : 0;

        // Get and process expo data
        $allExpos = $this->getVendorExpoStatus($vendor);
        $activeExpos = collect($allExpos)->filter(function ($expo) {
            return in_array($expo['status'], ['upcoming']);
        })->values();
        $nextExpo = collect($allExpos)->filter(function ($expo) {
            return $expo['status'] === 'upcoming';
        })->sortBy('start_date')->first();

        // Calculate vendor rank by revenue (delivered orders)
        $topVendors = Vendor::withSum([
            'orders as revenue' => function ($q) {
                $q->where('order_status', 'delivered');
            }
        ], 'total_amount')
            ->orderByDesc('revenue')
            ->pluck('id')
            ->toArray();
        // dd($topVendors);
        $vendorRank = array_search($vendor->id, $topVendors);
        $vendorRank = $vendorRank !== false ? $vendorRank + 1 : null;

        return [
            'subscription' => $this->getVendorSubscription($vendor),
            'expo_status' => $allExpos,
            'expos' => $allExpos,
            'active_expos' => $activeExpos->toArray(),
            'next_expo' => $nextExpo,
            'pending_orders' => $this->getVendorPendingOrders($vendor),
            'total_sales' => $totalSales,
            'kyc_status' => $vendor->kyc_status,
            'active_products' => $this->getVendorActiveProducts($vendor),
            'recent_orders' => $this->getVendorRecentOrders($vendor),
            'top_products' => $this->getVendorTopProducts($vendor),
            'sales_chart' => $this->getVendorSalesChart($vendor, $period),
            'metrics' => $this->getVendorMetrics($vendor),
            'account_status' => $vendor->status,
            'low_stock_products' => $this->getVendorLowStockProducts($vendor),
            'sales_summary' => [
                'total_sales' => $totalSales,
                'total_orders' => $totalOrders,
                'aov' => $aov,
            ],
            'vendor_rank' => $vendorRank,
        ];
    }

    /**
     * Get admin statistics
     */
    private function getAdminStats(): array
    {
        $totalRevenue = Order::where('order_status', 'delivered')->sum('total_amount');
        $completedOrders = Order::where('order_status', 'delivered')->count();
        $cancelledOrders = Order::where('order_status', 'cancelled')->count();
        $refundedOrders = Order::where('payment_status', 'refunded')->count();
        $totalUsers = User::count();
        $totalVendors = Vendor::count();
        $pendingRefunds = Order::where('refund_status', 'pending')->count();
        $pendingKYC = Vendor::where('kyc_status', 'pending')->count();
        $pendingKYCList = Vendor::where('kyc_status', 'pending')->take(5)->get(['id', 'name', 'brand_name_en', 'email']);
        $newUsersThisMonth = User::where('role', 'user')->whereMonth('created_at', now()->month)
            ->whereYear('created_at', now()->year)
            ->count();

        // Count active subscriptions
        $total_active_subscription = VendorSubscription::where('status', 'active')->count();
        // Plans expiring within 30 days
        $plansExpiringSoon = VendorSubscription::where('status', 'active')
            ->whereBetween('end_date', [now(), now()->addDays(30)])
            ->count();

        // Total revenue from subscriptions
        // Adjust the model/field if your payments are stored elsewhere
        $totalSubscriptionRevenue = FinanceTransaction::where('type', 'subscription')->sum('amount');

        // Get finance statistics
        $financeStats = $this->financeService->getStatistics();

        return [
            'total_revenue' => number_format($totalRevenue, 2),
            'completed_orders' => $completedOrders,
            'cancelled_orders' => $cancelledOrders,
            'refunded_orders' => $refundedOrders,
            'new_users_this_month' => $newUsersThisMonth,
            'total_vendors' => $totalVendors,
            'pending_kyc' => $pendingKYC,
            'pending_kyc_list' => $pendingKYCList,
            'pending_refunds' => $pendingRefunds,
            'finance_stats' => $financeStats,
            'active_subscription' => $total_active_subscription, // fixed typo
            'plans_expiring_soon' => $plansExpiringSoon,
            'subscription_revenue' => number_format($totalSubscriptionRevenue, 2),
        ];
    }

    /**
     * Get sales data for charts
     */
    private function getSalesData(string $period = 'month'): array
    {
        $salesQuery = Order::select(
            DB::raw('DATE(created_at) as date'),
            DB::raw('sum(total_amount) as total')
        )->where('order_status', 'delivered'); // Only count delivered orders for revenue

        switch ($period) {
            case 'today':
                $salesQuery->whereDate('created_at', Carbon::today());
                break;
            case 'week':
                $salesQuery->whereBetween('created_at', [Carbon::now()->startOfWeek(), Carbon::now()->endOfWeek()]);
                break;
            default: // month
                $salesQuery->whereMonth('created_at', Carbon::now()->month)
                    ->whereYear('created_at', Carbon::now()->year);
                break;
        }

        $result = $salesQuery->groupBy('date')->orderBy('date', 'asc')->get()->toArray();
        Log::info('Sales data for period', ['period' => $period, 'result' => $result]);
        return $result;
    }

    /**
     * Get recent orders
     */
    private function getRecentOrders(): array
    {
        return Order::with('user:id,full_name')
            ->latest()
            ->take(5)
            ->get()
            ->toArray();
    }

    /**
     * Get recent users
     */
    private function getRecentUsers(): array
    {
        return User::latest()
            ->take(5)
            ->get()
            ->toArray();
    }

    /**
     * Get top vendors by sales
     */
    public function getTopVendors(): array
    {
        return Vendor::with('user')
            ->withCount([
                'orders as orders_count' => function ($q) {
                    $q->where('order_status', 'delivered');
                }
            ])
            ->withSum([
                'orders as revenue' => function ($q) {
                    $q->where('order_status', 'delivered');
                }
            ], 'total_amount')
            ->orderByDesc('revenue')
            ->take(5)
            ->get(['id', 'name', 'brand_name_en', 'user_id'])
            ->toArray();
    }

    /**
     * Get expos list
     */
    public function getExpos(): array
    {
        return Expo::select('id', 'name_en as name')->get()->toArray();
    }

    /**
     * Get categories list
     */
    public function getCategories(): array
    {
        return Category::select('id', 'name_en as name')->get()->toArray();
    }

    /**
     * Get vendors list
     */
    public function getVendors(): array
    {
        return Vendor::select('id', 'name', 'brand_name_en')->get()->toArray();
    }

    /**
     * Get vendor subscription
     */
    private function getVendorSubscription(Vendor $vendor): ?array
    {
        $activeSub = VendorSubscription::where('vendor_id', $vendor->id)
            ->where('status', 'active')
            ->orderByDesc('end_date')
            ->first();

        if ($activeSub && $activeSub->subscription) {
            return [
                'plan_name' => $activeSub->subscription->title_en ?? $activeSub->subscription->name_en ?? 'No Plan',
                'status' => $activeSub->status,
                'expiry_date' => $activeSub->end_date, // <-- Add this line
            ];
        }

        return null;
    }

    /**
     * Get vendor expo status
     */
    private function getVendorExpoStatus(Vendor $vendor): array
    {
        return $vendor->expoParticipations->map(function ($expo) {
            return [
                'id' => $expo->id,
                'name' => $expo->name_en, // Use name_en as name for frontend
                'start_date' => $expo->start_date,
                'end_date' => $expo->end_date,
                'status' => $expo->pivot->status ?? $expo->status,
                'products_count' => $expo->pivot->products_count ?? 0,
            ];
        })->toArray();
    }

    /**
     * Get vendor pending orders count
     */
    private function getVendorPendingOrders(Vendor $vendor): int
    {
        return $vendor->orders->where('order_status', 'pending')->count();
    }

    /**
     * Get vendor total sales
     */
    private function getVendorTotalSales(Vendor $vendor): float
    {
        return $vendor->orders
            ->where('order_status', 'delivered')
            ->where(fn($order) => $order->created_at->month === now()->month)
            ->sum('total_amount');
    }

    /**
     * Get vendor active products count
     */
    private function getVendorActiveProducts(Vendor $vendor): int
    {
        return $vendor->products->where('status', 'active')->count();
    }

    /**
     * Get vendor recent orders
     */
    private function getVendorRecentOrders(Vendor $vendor): array
    {
        // Eager load user and expo relationships for recent orders
        $orders = $vendor->orders()->with(['user', 'expo'])->orderByDesc('created_at')->take(5)->get();

        return $orders->map(function ($order) {
            return [
                'id' => $order->id,
                'order_code' => $order->order_code,
                'order_identifier' => $order->id,
                'total_amount' => $order->total_amount,
                'order_status' => $order->order_status,
                'created_at' => $order->created_at,
                'customer_name' => optional($order->user)->full_name,
            ];
        })->toArray();
    }

    /**
     * Get vendor top products
     */
    private function getVendorTopProducts(Vendor $vendor): array
    {
        return Product::with('vendor')
            ->withCount([
                'orderItems as sales_count' => function ($q) {
                    $q->whereMonth('created_at', now()->month)->whereYear('created_at', now()->year);
                }
            ])
            ->withSum([
                'orderItems as total_revenue' => function ($q) {
                    $q->whereMonth('created_at', now()->month)->whereYear('created_at', now()->year);
                }
            ], 'total_amount')
            ->where('vendor_id', $vendor->id)
            ->orderByDesc('sales_count')
            ->take(5)
            ->get()
            ->map(function ($product) {
                return [
                    'id' => $product->id,
                    'name' => $product->name_en, // or $product->name if that's the correct field
                    'sales_count' => $product->sales_count ?? 0,
                    'total_revenue' => $product->total_revenue ?? 0,
                    'image_url' => $product->image_url_full, // Use S3 accessor
                ];
            })
            ->toArray();
    }

    /**
     * Get vendor sales chart data
     */
    private function getVendorSalesChart(Vendor $vendor, $period = 'month'): array
    {
        $orders = $vendor->orders->where('order_status', 'delivered')->filter(function ($order) use ($period) {
            if ($period === 'today') {
                return $order->created_at->isToday();
            } elseif ($period === 'week') {
                return $order->created_at->isCurrentWeek();
            } else { // month
                return $order->created_at->isCurrentMonth();
            }
        });

        // Group by day for today/week/month
        return $orders
            ->groupBy(function ($order) {
                return $order->created_at->format('M d');
            })
            ->map(function ($orders, $date) {
                return [
                    'date' => $date,
                    'sales' => $orders->sum('total_amount'),
                ];
            })
            ->values()
            ->toArray();
    }

    /**
     * Get vendor metrics
     */
    private function getVendorMetrics(Vendor $vendor): array
    {
        $totalOrders = $vendor->orders->where('order_status', 'delivered')->count();
        $totalViews = $vendor->products->sum('views') ?? 0;
        $totalSales = $this->getVendorTotalSales($vendor);

        $conversionRate = $totalViews > 0 ? round(($totalOrders / $totalViews) * 100, 2) : 0;
        $avgOrderValue = $totalOrders > 0 ? round($totalSales / $totalOrders, 2) : 0;
        $customerSatisfaction = 85; // Mock value
        $returnRate = 2.5; // Mock value

        return [
            'conversion_rate' => $conversionRate,
            'avg_order_value' => $avgOrderValue,
            'customer_satisfaction' => $customerSatisfaction,
            'return_rate' => $returnRate,
        ];
    }

    /**
     * Get vendor low stock products
     */
    private function getVendorLowStockProducts(Vendor $vendor): array
    {
        return Product::with('vendor')
            ->where('vendor_id', $vendor->id)
            ->where('stock', '<', 5)
            ->orderBy('stock', 'asc')
            ->take(5)
            ->get(['id', 'name_en', 'name_ar', 'stock', 'vendor_id'])
            ->toArray();
    }
}
