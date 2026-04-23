/* eslint-disable @typescript-eslint/no-explicit-any */
import { DashboardOverview } from '@/components/dashboard-overview';
import { useLanguage } from '@/components/language-context';
import { KYCStatusBanner } from '@/components/kyc-status-banner';
import { Button } from '@/components/ui/button';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import AppLayout from '@/layouts/app-layout';
import { PageProps } from '@/types';
import { Head, Link, router } from '@inertiajs/react';
import { BarChart, Clock, ShoppingCart, TrendingDown, TrendingUp, UserCheck, Users, Wallet } from 'lucide-react';
import { useEffect, useRef, useState } from 'react';
import { CartesianGrid, Line, LineChart, ResponsiveContainer, Tooltip, XAxis, YAxis } from 'recharts';

interface Stat {
    total_revenue: string;
    total_orders: number;
    total_users: number;
    total_vendors: number;
    pending_refunds: number;
    pending_vendors: number;
    completed_orders: number;
    cancelled_orders: number;
    refunded_orders: number;
    new_users_this_month: number;
    pending_kyc: number;
    pending_kyc_list: { id: number; name: string; brand_name_en?: string; email: string }[];
    finance_stats?: {
        transactions: {
            total_transactions: number;
            total_amount: number;
            income_amount: number;
            expense_amount: number;
            refund_amount: number;
        };
        payouts: {
            total_payouts: number;
            total_amount: number;
            pending_amount: number;
            completed_amount: number;
            approved_amount: number;
            rejected_amount: number;
            cancelled_amount: number;
        };
        summary: {
            net_income: number;
            total_payouts: number;
            pending_payouts: number;
            available_balance: number;
            profit_margin: number;
        };
    };
    active_subscription: number;
    plans_expiring_soon: number;
    subscription_revenue: string;
}

interface SaleData {
    date?: string;
    period?: string;
    week?: string;
    month?: string;
    total: number;
}

interface RecentOrder {
    id: number;
    order_identifier: string;
    user: { name: string };
    vendor: { name: string; brand_name_en?: string };
    status: string;
    total_amount: string;
    created_at: string;
}

interface VendorDashboard {
    subscription: {
        plan_name: string;
        status: string;
    } | null;
    expo_status: ExpoStatus[];
    pending_orders: number;
    total_sales: number;
    kyc_status: string;
    active_products: number;
    recent_orders: VendorOrder[];
    top_products: TopProduct[];
    sales_chart: SalesChart[];
    metrics: {
        conversion_rate: number;
        avg_order_value: number;
        customer_satisfaction: number;
        return_rate: number;
    };
    account_status: string;
    kyc_rejection_reason?: string;
    low_stock_products?: Array<{
        id: number;
        name_en: string;
        name_ar: string;
        stock: number;
        vendor?: { id: number; name: string; brand_name_en?: string };
    }>;
    active_expos?: ExpoStatus[];
    next_expo?: ExpoStatus | null;
    vendor_rank?: number;
    sales_summary?: {
        total_sales: number;
        total_orders: number;
        aov: number;
    };
}

interface VendorOrder {
    order_code: string;
    id: number;
    order_identifier: string;
    total_amount: number;
    status: string;
    created_at: string;
    user_name?: string;
    order_status?: string;
    customer_name?: string;
    expo_name?: string;
}

interface ExpoStatus {
    id: number;
    name: string;
    start_date: string;
    end_date: string;
    status: string;
    products_count: number;
}

interface TopProduct {
    id: number;
    name: string;
    sales_count: number;
    total_revenue: number;
    status: string;
    image_url?: string | null;
}

interface SalesChart {
    date: string;
    sales: number;
}

interface User {
    role: string;
    full_name?: string;
    email?: string;
}

interface AuthProps {
    user: User;
    permissions?: string[];
}

interface DashboardPageProps extends PageProps {
    stats: Stat;
    sales_data: SaleData[];
    recent_orders: RecentOrder[];
    vendor_dashboard: VendorDashboard;
    expos: { id: string; name: string }[];
    categories: { id: string; name: string }[];
    vendors: { id: string; name: string; brand_name_en?: string }[];
    top_vendors?: Array<{
        id: number;
        name: string;
        brand_name_en?: string;
        user_id: number;
        orders_count: number;
        revenue: number;
        user?: { name: string };
    }>;
    total_sales: number;
}

const StatCard = ({
    title,
    value,
    icon: Icon,
    description,
    link,
}: {
    title: string;
    value: string | number;
    icon: React.ElementType;
    description: string;
    link?: string;
}) => {
    const cardContent = (
        <Card>
            <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                <CardTitle className="text-sm font-medium">{title}</CardTitle>
                <Icon className="text-muted-foreground h-4 w-4" />
            </CardHeader>
            <CardContent>
                <div className="text-2xl font-bold">{value}</div>
                <p className="text-muted-foreground text-xs">{description}</p>
            </CardContent>
        </Card>
    );

    return link ? <Link href={link}>{cardContent}</Link> : cardContent;
};

const formatCurrency = (value: any): string => {
    const numValue = Number(value) || 0;
    return numValue.toFixed(2);
};

const formatPercentage = (value: any): string => {
    const numValue = Number(value) || 0;
    return numValue.toFixed(1);
};

export default function Dashboard({ stats, auth, vendor_dashboard, top_vendors, sales_data }: DashboardPageProps & { auth: AuthProps }) {
    const user = auth?.user;
    const { t } = useLanguage();

    const [grouping, setGrouping] = useState('monthly');
    const [salesPeriod, setSalesPeriod] = useState<'today' | 'week' | 'month'>('month');
    const initialChartData = sales_data || vendor_dashboard?.sales_chart || [];
    const [filteredSalesData, setFilteredSalesData] = useState<SaleData[]>(initialChartData);
    const [expoId, setExpoId] = useState<string>('');
    const [categoryId, setCategoryId] = useState<string>('');
    const [vendorId, setVendorId] = useState<string>('');

    const isAdmin = user?.role === 'admin' || auth?.permissions?.includes('manage_users');
    const isVendor = user?.role === 'vendor';

    const didMount = useRef(false);
    useEffect(() => {
        const params: Record<string, string> = { grouping };
        if (expoId) params.expo_id = expoId;
        if (categoryId) params.category_id = categoryId;
        if (vendorId) params.vendor_id = vendorId;

        if (didMount.current) {
            router.get('/dashboard', params, { preserveState: true, replace: true });
        } else {
            didMount.current = true;
        }
    }, [grouping, expoId, categoryId, vendorId]);

    useEffect(() => {
        if (didMount.current) {
            router.get('/dashboard', { period: salesPeriod }, { preserveState: true, replace: true });
        } else {
            didMount.current = true;
        }
    }, [salesPeriod]);

    useEffect(() => {
        if (sales_data) {
            setFilteredSalesData(sales_data);
        } else if (vendor_dashboard?.sales_chart) {
            const mapped = vendor_dashboard.sales_chart.map((item: any) => ({
                date: item.date,
                total: item.sales,
            }));
            setFilteredSalesData(mapped);
        } else {
            setFilteredSalesData([]);
        }
    }, [sales_data, vendor_dashboard]);

    return (
        <AppLayout>
            <Head title={t('dashboard.title')} />
            <div className="flex-1 space-y-4 p-4 pt-6 md:p-8">
                <div className="flex items-center justify-between space-y-2">
                    <h2 className="text-3xl font-bold tracking-tight">{t('dashboard.title')}</h2>
                </div>
                {isAdmin && (
                    <>
                        <div className="space-y-6">
                            <div>
                                <h3 className="mb-4 text-lg font-semibold">{t('dashboard.platformOverview')}</h3>
                                <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
                                    <StatCard
                                        title={t('dashboard.totalRevenue')}
                                        value={` ${stats.total_revenue}`}
                                        icon={Wallet}
                                        description={t('dashboard.totalRevenueDesc')}
                                    />
                                    <StatCard
                                        title={t('dashboard.completedOrders')}
                                        value={stats.completed_orders}
                                        icon={ShoppingCart}
                                        description={t('dashboard.completedOrdersDesc')}
                                        link="/orders?status=delivered"
                                    />
                                    <StatCard
                                        title={t('dashboard.cancelledOrders')}
                                        value={stats.cancelled_orders}
                                        icon={ShoppingCart}
                                        description={t('dashboard.cancelledOrdersDesc')}
                                        link="/orders?status=cancelled"
                                    />
                                    <StatCard
                                        title={t('dashboard.refundedOrders')}
                                        value={stats.refunded_orders}
                                        icon={ShoppingCart}
                                        description={t('dashboard.refundedOrdersDesc')}
                                        link="/orders?payment_status=refunded"
                                    />
                                    <StatCard
                                        title={t('dashboard.newUsersThisMonth')}
                                        value={stats.new_users_this_month}
                                        icon={Users}
                                        description={t('dashboard.newUsersThisMonthDesc')}
                                        link="/users"
                                    />
                                    <StatCard
                                        title={t('dashboard.totalVendors')}
                                        value={stats.total_vendors}
                                        icon={UserCheck}
                                        description={t('dashboard.totalVendorsDesc')}
                                        link="/vendors"
                                    />
                                    <StatCard
                                        title={t('dashboard.pendingRefunds')}
                                        value={stats.pending_refunds}
                                        icon={Clock}
                                        description={t('dashboard.pendingRefundsDesc')}
                                        link="/orders?date_from=&date_to=&payment_status=refunded&search=&status=pending"
                                    />
                                    <StatCard
                                        title={t('dashboard.vendorsAwaitingKYC')}
                                        value={stats.pending_kyc}
                                        icon={UserCheck}
                                        description={t('dashboard.vendorsAwaitingKYCDesc')}
                                        link="/vendors?kyc_status=pending"
                                    />
                                </div>
                            </div>
                            {stats.finance_stats && (
                                <div>
                                    <h3 className="mb-4 text-lg font-semibold">{t('dashboard.financialOverview')}</h3>
                                    <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
                                        <Card>
                                            <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                                                <CardTitle className="text-sm font-medium">{t('dashboard.netIncome')}</CardTitle>
                                                <TrendingUp className="h-4 w-4 text-green-600" />
                                            </CardHeader>
                                            <CardContent>
                                                <div className="text-2xl font-bold text-green-600">
                                                    <span
                                                        className={`${Number(stats.finance_stats?.summary?.net_income) < 0 ? 'text-red-600' : Number(stats.finance_stats?.summary?.net_income) > 0 ? 'text-green-600' : ''}`}
                                                    >
                                                        {formatCurrency(stats.finance_stats?.summary?.net_income).replace(/[^0-9.,-]/g, '')}
                                                    </span>
                                                </div>
                                                <p className="text-muted-foreground text-xs">{t('dashboard.netIncomeDesc')}</p>
                                            </CardContent>
                                        </Card>

                                        <Card>
                                            <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                                                <CardTitle className="text-sm font-medium">{t('dashboard.availableBalance')}</CardTitle>
                                                <Wallet className="h-4 w-4 text-blue-600" />
                                            </CardHeader>
                                            <CardContent>
                                                <div className="text-2xl font-bold text-blue-600">
                                                    <span
                                                        className={`${Number(stats.finance_stats?.summary?.available_balance) < 0 ? 'text-red-600' : Number(stats.finance_stats?.summary?.available_balance) > 0 ? 'text-green-600' : ''}`}
                                                    >
                                                        {formatCurrency(stats.finance_stats?.summary?.available_balance).replace(/[^0-9.,-]/g, '')}
                                                    </span>
                                                </div>
                                                <p className="text-muted-foreground text-xs">{t('dashboard.availableBalanceDesc')}</p>
                                            </CardContent>
                                        </Card>

                                        <Card>
                                            <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                                                <CardTitle className="text-sm font-medium">{t('dashboard.pendingPayouts')}</CardTitle>
                                                <Clock className="h-4 w-4 text-orange-600" />
                                            </CardHeader>
                                            <CardContent>
                                                <div className="text-2xl font-bold text-orange-600">
                                                    <span
                                                        className={`${Number(stats.finance_stats?.summary?.pending_payouts) < 0 ? 'text-red-600' : Number(stats.finance_stats?.summary?.pending_payouts) > 0 ? 'text-green-600' : ''}`}
                                                    >
                                                        {formatCurrency(stats.finance_stats?.summary?.pending_payouts).replace(/[^0-9.,-]/g, '')}
                                                    </span>
                                                </div>
                                                <p className="text-muted-foreground text-xs">{t('dashboard.pendingPayoutsDesc')}</p>
                                            </CardContent>
                                        </Card>

                                        <Card>
                                            <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                                                <CardTitle className="text-sm font-medium">{t('dashboard.profitMargin')}</CardTitle>
                                                <BarChart className="h-4 w-4 text-purple-600" />
                                            </CardHeader>
                                            <CardContent>
                                                <div className="text-2xl font-bold text-purple-600">
                                                    {formatPercentage(stats.finance_stats?.summary?.profit_margin)}%
                                                </div>
                                                <p className="text-muted-foreground text-xs">{t('dashboard.profitMarginDesc')}</p>
                                            </CardContent>
                                        </Card>
                                    </div>

                                    <div className="mt-4 grid gap-4 md:grid-cols-2 lg:grid-cols-4">
                                        <Card>
                                            <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                                                <CardTitle className="text-sm font-medium">{t('dashboard.totalTransactions')}</CardTitle>
                                                <Wallet className="text-muted-foreground h-4 w-4" />
                                            </CardHeader>
                                            <CardContent>
                                                <div className="text-2xl font-bold">{stats.finance_stats.transactions?.total_transactions || 0}</div>
                                                <p className="text-muted-foreground text-xs">{t('dashboard.totalTransactionsDesc')}</p>
                                            </CardContent>
                                        </Card>

                                        <Card>
                                            <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                                                <CardTitle className="text-sm font-medium">{t('dashboard.incomeAmount')}</CardTitle>
                                                <TrendingUp className="h-4 w-4 text-green-600" />
                                            </CardHeader>
                                            <CardContent>
                                                <div className="text-2xl font-bold text-green-600">
                                                    <span
                                                        className={`${Number(stats.finance_stats?.transactions?.income_amount) < 0 ? 'text-red-600' : Number(stats.finance_stats?.transactions?.income_amount) > 0 ? 'text-green-600' : ''}`}
                                                    >
                                                        {formatCurrency(stats.finance_stats?.transactions?.income_amount).replace(/[^0-9.,-]/g, '')}
                                                    </span>
                                                </div>
                                                <p className="text-muted-foreground text-xs">{t('dashboard.incomeAmountDesc')}</p>
                                            </CardContent>
                                        </Card>

                                        <Card>
                                            <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                                                <CardTitle className="text-sm font-medium">{t('dashboard.expenseAmount')}</CardTitle>
                                                <TrendingDown className="h-4 w-4 text-red-600" />
                                            </CardHeader>
                                            <CardContent>
                                                <div className="text-2xl font-bold text-red-600">
                                                    <span
                                                        className={`${Number(stats.finance_stats?.transactions?.expense_amount) < 0 ? 'text-red-600' : Number(stats.finance_stats?.transactions?.expense_amount) > 0 ? 'text-green-600' : ''}`}
                                                    >
                                                        {formatCurrency(stats.finance_stats?.transactions?.expense_amount).replace(/[^0-9.,-]/g, '')}
                                                    </span>
                                                </div>
                                                <p className="text-muted-foreground text-xs">{t('dashboard.expenseAmountDesc')}</p>
                                            </CardContent>
                                        </Card>

                                        <Card>
                                            <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                                                <CardTitle className="text-sm font-medium">{t('dashboard.totalPayouts')}</CardTitle>
                                                <Wallet className="text-muted-foreground h-4 w-4" />
                                            </CardHeader>
                                            <CardContent>
                                                <div className="text-2xl font-bold">{stats.finance_stats.payouts?.total_payouts || 0}</div>
                                                <p className="text-muted-foreground text-xs">{t('dashboard.totalPayoutsDesc')}</p>
                                            </CardContent>
                                        </Card>
                                    </div>
                                </div>
                            )}
                            <div>
                                <h3 className="mb-4 text-lg font-semibold">{t('dashboard.quickActions')}</h3>
                                <div className="flex gap-4">
                                    <Link href="/finance">
                                        <Button variant="outline" className="flex items-center gap-2">
                                            <Wallet className="h-4 w-4" />
                                            {t('dashboard.viewFinanceDetails')}
                                        </Button>
                                    </Link>
                                    <Link href="/payouts">
                                        <Button variant="outline" className="flex items-center gap-2">
                                            <Wallet className="h-4 w-4" />
                                            {t('dashboard.managePayouts')}
                                        </Button>
                                    </Link>
                                    <Link href="/orders">
                                        <Button variant="outline" className="flex items-center gap-2">
                                            <ShoppingCart className="h-4 w-4" />
                                            {t('dashboard.viewOrders')}
                                        </Button>
                                    </Link>
                                    <Link href="/vendors">
                                        <Button variant="outline" className="flex items-center gap-2">
                                            <UserCheck className="h-4 w-4" />
                                            {t('dashboard.manageVendors')}
                                        </Button>
                                    </Link>
                                </div>
                            </div>
                        </div>
                        <div className="mt-8 space-y-6">
                            <Card className="mb-4">
                                <CardHeader className="flex flex-row items-center justify-between">
                                    <div className="flex items-center gap-2">
                                        <BarChart className="text-muted-foreground h-4 w-4" />
                                        <CardTitle>{t('dashboard.salesOverview')}</CardTitle>
                                    </div>
                                    <select
                                        value={salesPeriod}
                                        onChange={(e) => setSalesPeriod(e.target.value as 'today' | 'week' | 'month')}
                                        className="min-w-[120px] rounded border px-2 py-1"
                                    >
                                        <option value="today">{t('dashboard.today')}</option>
                                        <option value="week">{t('dashboard.thisWeek')}</option>
                                        <option value="month">{t('dashboard.thisMonth')}</option>
                                    </select>
                                </CardHeader>
                                <CardContent>
                                    <ResponsiveContainer width="100%" height={350}>
                                        <LineChart data={filteredSalesData}>
                                            <CartesianGrid strokeDasharray="3 3" />
                                            <XAxis dataKey="date" />
                                            <YAxis />
                                            <Tooltip />
                                            <Line type="monotone" dataKey="total" stroke="#10b981" fill="#10b981" />
                                        </LineChart>
                                    </ResponsiveContainer>
                                </CardContent>
                            </Card>

                            {/* Subscription Summary Section */}
                            <Card className="mb-4">
                                <CardHeader>
                                    <CardTitle>{t('dashboard.subscriptionSummary')}</CardTitle>
                                </CardHeader>
                                <CardContent>
                                    <div className="grid gap-4 md:grid-cols-3">
                                        <div className="flex flex-col items-center justify-center rounded border p-4">
                                            <div className="mb-1 text-lg font-semibold">{t('dashboard.totalActivePlans')}</div>
                                            <div className="mb-1 text-3xl font-bold">{stats.active_subscription}</div>
                                            <div className="text-muted-foreground text-center text-xs">{t('dashboard.totalActivePlansDesc')}</div>
                                        </div>
                                        <div className="flex flex-col items-center justify-center rounded border p-4">
                                            <div className="mb-1 text-lg font-semibold">{t('dashboard.plansExpiringSoon')}</div>
                                            <div className="mb-1 text-3xl font-bold">{stats.plans_expiring_soon}</div>
                                            <div className="text-muted-foreground text-center text-xs">{t('dashboard.plansExpiringSoonDesc')}</div>
                                        </div>
                                        <div className="flex flex-col items-center justify-center rounded border p-4">
                                            <div className="mb-1 text-lg font-semibold">{t('dashboard.totalRevenueFromSubscriptions')}</div>
                                            <div className="mb-1 text-3xl font-bold">{stats.subscription_revenue}</div>
                                            <div className="text-muted-foreground text-center text-xs">{t('dashboard.totalRevenueFromSubscriptionsDesc')}</div>
                                        </div>
                                    </div>
                                </CardContent>
                            </Card>
                        </div>
                        <div className="mt-4 grid gap-4 md:grid-cols-2 lg:grid-cols-4">
                            {/* Low Stock Products */}
                            <Card>
                                <CardHeader>
                                    <CardTitle>{t('dashboard.lowStockProducts')}</CardTitle>
                                </CardHeader>
                                <CardContent>
                                    {vendor_dashboard?.low_stock_products && vendor_dashboard.low_stock_products.length > 0 ? (
                                        <ul className="text-sm">
                                            {vendor_dashboard.low_stock_products.map((product) => (
                                                <li key={product.id} className="mb-2 flex justify-between">
                                                    <span>
                                                        {product.name_en} ({product.stock} {t('dashboard.left')})
                                                    </span>
                                                    <span className="text-muted-foreground text-xs">{product.vendor?.brand_name_en || product.vendor?.name}</span>
                                                </li>
                                            ))}
                                        </ul>
                                    ) : (
                                        <div className="text-muted-foreground text-xs">{t('dashboard.noLowStockProducts')}</div>
                                    )}
                                </CardContent>
                            </Card>
                            {/* Expos Summary */}
                            <Card>
                                <CardHeader>
                                    <CardTitle>{t('dashboard.activeExpos')}</CardTitle>
                                </CardHeader>
                                <CardContent>
                                    {/* TODO: Map active expos and upcoming expos with countdown if data is available */}
                                    <div className="text-muted-foreground text-xs">{t('dashboard.comingSoon')}</div>
                                </CardContent>
                            </Card>
                            {/* Top 5 Products This Month */}
                            <Card>
                                <CardHeader>
                                    <CardTitle>{t('dashboard.top5ProductsThisMonth')}</CardTitle>
                                </CardHeader>
                                <CardContent>
                                    {vendor_dashboard?.top_products && vendor_dashboard.top_products.length > 0 ? (
                                        <ul className="text-sm">
                                            {vendor_dashboard.top_products.map((product) => (
                                                <li key={product.id} className="mb-2 flex justify-between">
                                                    <span>
                                                        {product.name} ({product.sales_count} {t('dashboard.sold')})
                                                    </span>
                                                    <span className="text-muted-foreground text-xs">
                                                        <span
                                                            className={`${Number(product.total_revenue) < 0 ? 'text-red-600' : Number(product.total_revenue) > 0 ? 'text-green-600' : ''}`}
                                                        >
                                                            {formatCurrency(product.total_revenue).replace(/[^0-9.,-]/g, '')}
                                                        </span>
                                                    </span>
                                                </li>
                                            ))}
                                        </ul>
                                    ) : (
                                        <div className="text-muted-foreground text-xs">{t('dashboard.noTopProducts')}</div>
                                    )}
                                </CardContent>
                            </Card>
                            {/* Top Vendors by Sales */}
                            <Card>
                                <CardHeader>
                                    <CardTitle>{t('dashboard.topVendorsBySales')}</CardTitle>
                                </CardHeader>
                                <CardContent>
                                    {top_vendors && top_vendors.length > 0 ? (
                                        <table className="min-w-full rounded border text-sm">
                                            <thead>
                                                <tr className="bg-muted">
                                                    <th className="px-3 py-2 text-left">{t('dashboard.rank')}</th>
                                                    <th className="px-3 py-2 text-left">{t('dashboard.brandNameEn')}</th>
                                                    <th className="px-3 py-2 text-left">{t('dashboard.sales')}</th>
                                                </tr>
                                            </thead>
                                            <tbody>
                                                {top_vendors.slice(0, 5).map((vendor, idx) => (
                                                    <tr key={vendor.id} className="border-b last:border-b-0">
                                                        <td className="px-3 py-2">
                                                            {idx === 0 && (
                                                                <span role="img" aria-label="gold">
                                                                    🥇
                                                                </span>
                                                            )}
                                                            {idx === 1 && (
                                                                <span role="img" aria-label="silver">
                                                                    🥈
                                                                </span>
                                                            )}
                                                            {idx === 2 && (
                                                                <span role="img" aria-label="bronze">
                                                                    🥉
                                                                </span>
                                                            )}
                                                            {idx === 3 && (
                                                                <span role="img" aria-label="medal">
                                                                    🎖️
                                                                </span>
                                                            )}
                                                            {idx === 4 && (
                                                                <span role="img" aria-label="medal">
                                                                    🏅
                                                                </span>
                                                            )}
                                                        </td>
                                                        <td className="px-3 py-2">{vendor.brand_name_en || vendor.name}</td>
                                                        <td className="px-3 py-2">
                                                            {Number(vendor.revenue).toLocaleString('en-SA', { minimumFractionDigits: 0 })}

                                                        </td>
                                                    </tr>
                                                ))}
                                            </tbody>
                                        </table>
                                    ) : (
                                        <div className="text-muted-foreground text-xs">{t('dashboard.noTopVendors')}</div>
                                    )}
                                    {vendor_dashboard?.vendor_rank && (
                                        <div className="mt-4 text-center text-sm">
                                            {t('dashboard.youAreRanked')} <span className="font-bold">#{vendor_dashboard.vendor_rank}</span> {t('dashboard.thisMonthSuffix')}
                                        </div>
                                    )}
                                </CardContent>
                            </Card>
                        </div>
                    </>
                )}
                {isVendor && vendor_dashboard && (
                    <>
                        <KYCStatusBanner
                            kycStatus={vendor_dashboard.kyc_status || 'not_submitted'}
                            kycRejectionReason={vendor_dashboard.kyc_rejection_reason}
                            isVendor={isVendor}
                        />
                        <DashboardOverview vendor_dashboard={vendor_dashboard} top_vendors={top_vendors || []} />
                        <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-7">
                            <Card className="col-span-4">
                                <CardHeader className="flex flex-row items-center justify-between pb-2">
                                    <CardTitle className="text-lg font-semibold">{t('dashboard.salesOverview')}</CardTitle>
                                    <div>
                                        <select
                                            value={salesPeriod}
                                            onChange={(e) => setSalesPeriod(e.target.value as 'today' | 'week' | 'month')}
                                            className="shadcn-select"
                                            aria-label="Sales Period"
                                        >
                                            <option value="today">{t('dashboard.today')}</option>
                                            <option value="week">{t('dashboard.thisWeek')}</option>
                                            <option value="month">{t('dashboard.thisMonth')}</option>
                                        </select>
                                    </div>
                                </CardHeader>
                                <CardContent>
                                    <div className="mb-6 grid grid-cols-3 gap-4">
                                        <div className="bg-muted flex flex-col items-center justify-center rounded-md border p-4">
                                            <div className="mb-1 flex items-center gap-2 text-lg font-semibold">
                                                <Wallet className="h-5 w-5 text-green-600" />
                                                {t('dashboard.totalSales')}
                                            </div>
                                            <div className="mb-1 text-3xl font-bold">
                                                {vendor_dashboard?.sales_summary?.total_sales !== undefined
                                                    ? Number(vendor_dashboard.sales_summary.total_sales).toFixed(2)
                                                    : '--'}
                                            </div>
                                            <div className="text-muted-foreground text-center text-xs">{t('dashboard.totalSalesDesc')}</div>
                                        </div>
                                        <div className="bg-muted flex flex-col items-center justify-center rounded-md border p-4">
                                            <div className="mb-1 flex items-center gap-2 text-lg font-semibold">
                                                <ShoppingCart className="h-5 w-5 text-blue-600" />
                                                {t('dashboard.orders')}
                                            </div>
                                            <div className="mb-1 text-3xl font-bold">{vendor_dashboard?.sales_summary?.total_orders ?? '--'}</div>
                                            <div className="text-muted-foreground text-center text-xs">{t('dashboard.ordersDesc')}</div>
                                        </div>
                                        <div className="bg-muted flex flex-col items-center justify-center rounded-md border p-4">
                                            <div className="mb-1 flex items-center gap-2 text-lg font-semibold">
                                                <BarChart className="h-5 w-5 text-purple-600" />
                                                {t('dashboard.aov')}
                                            </div>
                                            <div className="mb-1 text-3xl font-bold">{vendor_dashboard?.sales_summary?.aov ?? '--'}</div>
                                            <div className="text-muted-foreground text-center text-xs">{t('dashboard.aovDesc')}</div>
                                        </div>
                                    </div>
                                    <div>
                                        <div className="mb-2 flex items-center gap-2 font-medium">
                                            <TrendingUp className="h-4 w-4 text-green-500" />
                                            {t('dashboard.salesTrend')}
                                            <span className="text-muted-foreground ml-auto text-xs">
                                                {salesPeriod === 'today' ? t('dashboard.last7Days') : salesPeriod === 'week' ? t('dashboard.last7Days') : t('dashboard.last30Days')}
                                            </span>
                                        </div>
                                        <ResponsiveContainer width="100%" height={300}>
                                            <LineChart data={vendor_dashboard.sales_chart || []}>
                                                <CartesianGrid strokeDasharray="3 3" />
                                                <XAxis dataKey="date" />
                                                <YAxis />
                                                <Tooltip />
                                                <Line type="monotone" dataKey="sales" stroke="#10b981" fill="#10b981" />
                                            </LineChart>
                                        </ResponsiveContainer>
                                    </div>
                                </CardContent>
                            </Card>
                            <Card className="col-span-3">
                                <CardHeader className="flex flex-row items-center justify-between">
                                    <CardTitle>{t('dashboard.recentOrders')}</CardTitle>
                                    <Button asChild size="sm" variant="outline" className="ml-auto">
                                        <Link href="/vendor/orders">{t('dashboard.viewAllOrders')}</Link>
                                    </Button>
                                </CardHeader>
                                <CardContent>
                                    <div className="space-y-4">
                                        {Array.isArray(vendor_dashboard.recent_orders) && vendor_dashboard.recent_orders.length > 0 ? (
                                            vendor_dashboard.recent_orders.slice(0, 5).map((order: VendorOrder) => {
                                                let statusColor = '';
                                                let statusIcon = '';
                                                switch (order.order_status) {
                                                    case 'completed':
                                                        statusColor = 'text-green-600';
                                                        statusIcon = '🟢';
                                                        break;
                                                    case 'pending':
                                                        statusColor = 'text-yellow-500';
                                                        statusIcon = '🟡';
                                                        break;
                                                    case 'cancelled':
                                                        statusColor = 'text-red-600';
                                                        statusIcon = '🔴';
                                                        break;
                                                    case 'returned':
                                                        statusColor = 'text-purple-600';
                                                        statusIcon = '🟣';
                                                        break;
                                                    case 'failed':
                                                        statusColor = 'text-red-700';
                                                        statusIcon = '❌';
                                                        break;
                                                    case 'ready_for_pickup':
                                                        statusColor = 'text-blue-500';
                                                        statusIcon = '📦';
                                                        break;
                                                    case 'shipped':
                                                        statusColor = 'text-blue-600';
                                                        statusIcon = '🚚';
                                                        break;
                                                    default:
                                                        statusColor = 'text-gray-500';
                                                        statusIcon = '⚪';
                                                }

                                                return (
                                                    <div key={order.id} className="bg-muted flex flex-col gap-2 rounded-lg border p-4">
                                                        <div className="flex flex-wrap justify-between gap-4 text-sm">
                                                            {/* Left Side */}
                                                            <div className="flex flex-col gap-1">
                                                                <span className="font-medium">
                                                                    {t('dashboard.orderId')}: <span className="font-semibold">#{order.order_code}</span>
                                                                </span>
                                                                <span>
                                                                    {t('dashboard.customer')}: <span className="font-semibold">{order.customer_name || t('dashboard.noData')}</span>
                                                                </span>
                                                            </div>
                                                            {/* Right Side */}
                                                            <div className="flex flex-col gap-1 items-end">
                                                                <span>
                                                                    {t('dashboard.amount')}:{' '}
                                                                    <span className="font-semibold">
                                                                        {formatCurrency(order.total_amount).replace(/[^0-9.,-]/g, '')}
                                                                    </span>
                                                                </span>
                                                                <span className="flex items-center gap-1 font-medium">
                                                                    {t('common.status')}:
                                                                    <span className="capitalize">{order.order_status?.split('_').join(' ')}</span>
                                                                </span>
                                                            </div>
                                                        </div>
                                                    </div>
                                                );
                                            })
                                        ) : (
                                            <div className="text-muted-foreground py-8 text-center">{t('dashboard.noRecentOrders')}</div>
                                        )}
                                    </div>
                                </CardContent>
                            </Card>
                        </div>

                        <div className="grid gap-4 md:grid-cols-2">
                            <Card>
                                <CardHeader className="flex flex-row items-center gap-2">
                                    <span className="text-yellow-500">
                                        <svg
                                            xmlns="http://www.w3.org/2000/svg"
                                            className="inline h-5 w-5"
                                            fill="none"
                                            viewBox="0 0 24 24"
                                            stroke="currentColor"
                                        >
                                            <path
                                                strokeLinecap="round"
                                                strokeLinejoin="round"
                                                strokeWidth={2}
                                                d="M12 9v2m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"
                                            />
                                        </svg>
                                    </span>
                                    <CardTitle className="flex-1">{t('dashboard.lowStockProducts')}</CardTitle>
                                </CardHeader>
                                <CardContent>
                                    {vendor_dashboard?.low_stock_products && vendor_dashboard.low_stock_products.length > 0 ? (
                                        <ul className="space-y-3">
                                            {vendor_dashboard.low_stock_products.map((product) => (
                                                <li key={product.id} className="flex items-center justify-between rounded border p-3">
                                                    <div>
                                                        <span className="font-medium">{product.name_en}</span>
                                                        <span className="text-muted-foreground ml-2 text-xs">({product.stock} {t('dashboard.left')})</span>
                                                    </div>
                                                    <Button asChild size="sm" variant="link" className="h-7 px-2 py-0">
                                                        <Link href="/vendor/products">{t('dashboard.manage')}</Link>
                                                    </Button>
                                                </li>
                                            ))}
                                        </ul>
                                    ) : (
                                        <div className="text-muted-foreground flex flex-col items-center justify-center py-8 text-center">
                                            <span className="mb-2 text-2xl">🚫</span>
                                            {t('dashboard.noLowStockProducts')}
                                        </div>
                                    )}
                                </CardContent>
                            </Card>
                            {/* Low Stock Products */}
                            <Card>
                                <CardHeader className="flex flex-row items-center justify-between">
                                    <CardTitle>{t('dashboard.top5ProductsThisMonth')}</CardTitle>
                                    <Button asChild size="sm" variant="outline" className="ml-auto">
                                        <Link href="/vendor/products">{t('dashboard.viewAllProducts')}</Link>
                                    </Button>
                                </CardHeader>
                                <CardContent>
                                    {!vendor_dashboard?.top_products || vendor_dashboard.top_products.length === 0 ? (
                                        <div className="overflow-x-auto">
                                            <table className="min-w-full rounded border text-sm">
                                                <thead>
                                                    <tr className="bg-muted">
                                                        <th className="px-3 py-2 text-left">{t('dashboard.productName')}</th>
                                                        <th className="px-3 py-2 text-left">{t('dashboard.unitsSold')}</th>
                                                        <th className="px-3 py-2 text-left">{t('dashboard.revenue')}</th>
                                                    </tr>
                                                </thead>
                                                <tbody>
                                                    <tr>
                                                        <td className="px-3 py-2">{t('dashboard.noData')}</td>
                                                        <td className="px-3 py-2">0</td>
                                                        <td className="px-3 py-2">0.00</td>
                                                    </tr>
                                                </tbody>
                                            </table>
                                        </div>
                                    ) : (
                                        <div className="overflow-x-auto">
                                            <table className="min-w-full rounded border text-sm">
                                                <thead>
                                                    <tr className="bg-muted">
                                                        <th className="px-3 py-2 text-left">{t('dashboard.productName')}</th>
                                                        <th className="px-3 py-2 text-left">{t('dashboard.sold')}</th>
                                                        <th className="px-3 py-2 text-left">{t('common.total')}</th>
                                                    </tr>
                                                </thead>
                                                <tbody>
                                                    {vendor_dashboard.top_products.map((product) => (
                                                        <tr key={product.id} className="border-b last:border-b-0">
                                                            <td className="flex items-center gap-2 px-3 py-2">
                                                                {product.image_url && (
                                                                    <img
                                                                        src={product.image_url}
                                                                        alt={product.name}
                                                                        className="h-8 w-8 rounded border object-cover"
                                                                    />
                                                                )}
                                                                <span>{product.name}</span>
                                                            </td>
                                                            <td className="px-3 py-2">{product.sales_count}</td>
                                                            <td className="px-3 py-2">
                                                                {Number(product.total_revenue).toLocaleString('en-IN', { minimumFractionDigits: 2 })}
                                                            </td>
                                                        </tr>
                                                    ))}
                                                </tbody>
                                            </table>
                                        </div>
                                    )}
                                </CardContent>
                            </Card>
                        </div>
                    </>
                )}
            </div>
        </AppLayout>
    );
}
