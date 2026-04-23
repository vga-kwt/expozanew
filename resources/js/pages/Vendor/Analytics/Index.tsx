import React, { useState, useEffect } from 'react';
import { useLanguage } from '@/components/language-context';
import { router, Link, usePage } from '@inertiajs/react';
import { Button } from '../../../components/ui/button';
import { Card, CardContent, CardHeader, CardTitle } from '../../../components/ui/card';
import { Input } from '../../../components/ui/input';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '../../../components/ui/select';
import { Download, TrendingUp, TrendingDown, BarChart3, ShoppingCart, AlertTriangle, Wallet, X } from 'lucide-react';
import AppLayout from '../../../layouts/app-layout';
import { toast } from 'react-hot-toast';

interface SalesData {
  date: string;
  sales_count: number;
  revenue: number;
  vendor_earnings: number;
}

interface BestSellingProduct {
  product_name: string;
  sales_count: number;
  revenue: number;
  vendor_earnings: number;
}

interface RefundData {
  total_sales: number;
  total_refunds: number;
  refund_rate: number;
  refund_amount: number;
}

interface RevenueSummary {
  current_period: number;
  previous_period: number;
  growth_percentage: number;
}

interface Props {
  salesData: SalesData[];
  bestSellingProducts: BestSellingProduct[];
  refundData: RefundData;
  revenueSummary: RevenueSummary;
  filters: {
    period: string;
    date_from: string;
    date_to: string;
  };
  hasPremiumAccess: boolean;
  flash?: {
    success?: string;
    error?: string;
  };
  [key: string]: any;
}

export default function VendorAnalytics() {
  const { t } = useLanguage();
  const { props } = usePage<Props>();
  const {
    salesData,
    bestSellingProducts,
    refundData,
    revenueSummary,
    filters,
    hasPremiumAccess,
    flash
  } = props;

  const [localFilters, setLocalFilters] = useState({
    period: filters?.period || 'monthly',
    date_from: filters?.date_from || '',
    date_to: filters?.date_to || '',
  });

  const [loading, setLoading] = useState(false);

  // Show toast notifications for flash messages
  useEffect(() => {
    if (flash?.success) toast.success(flash.success);
    if (flash?.error) toast.error(flash.error);
  }, [flash?.success, flash?.error]);

  const handleFilterChange = (key: string, value: string) => {
    setLocalFilters(prev => ({ ...prev, [key]: value }));
  };

  const applyFilters = () => {
    setLoading(true);
    router.get(route('vendor.analytics.index'), localFilters, {
      preserveState: true,
      preserveScroll: true,
      onFinish: () => setLoading(false)
    });
  };

  const clearFilters = () => {
    const defaultFilters = {
      period: 'monthly',
      date_from: '',
      date_to: '',
    };
    setLocalFilters(defaultFilters);
    router.get(route('vendor.analytics.index'), defaultFilters, {
      preserveState: true,
      preserveScroll: true
    });
  };

  const exportAnalytics = () => {
    setLoading(true);
    const params = new URLSearchParams();
    Object.entries(localFilters).forEach(([key, value]) => {
      if (value) params.append(key, value);
    });

    const url = `${route('vendor.analytics.export')}?${params.toString()}`;
    window.open(url, '_blank');
    setLoading(false);
  };

  const formatCurrency = (amount: number) => {
    return new Intl.NumberFormat('en-US', {
      style: 'currency',
      currency: 'KWD',
      minimumFractionDigits: 2,
    }).format(amount);
  };

  const formatNumber = (num: number) => {
    return new Intl.NumberFormat('en-US').format(num);
  };

  if (!hasPremiumAccess) {
    return (
      <AppLayout>
        <div className="space-y-6 p-6">
          <div className="text-center py-12">
            <BarChart3 className="mx-auto h-12 w-12 text-gray-400" />
            <h3 className="mt-2 text-sm font-semibold text-gray-900">{t('analytics.analyticsAccessRequired')}</h3>
            <p className="mt-1 text-sm text-gray-500">
              {t('analytics.analyticsPremiumMessage')}
            </p>
            <div className="mt-6">
              <Link href={route('vendor.subscription')}>
                <Button>
                  {t('analytics.upgradeToPremium')}
                </Button>
              </Link>
            </div>
          </div>
        </div>
      </AppLayout>
    );
  }

  return (
    <AppLayout>
      <div className="space-y-6 p-6">
        <div className="flex items-center justify-between">
          <h1 className="text-2xl font-bold">{t('vendor.analyticsReports')}</h1>
          <div className="flex gap-2">
            <Button onClick={exportAnalytics} variant="outline" disabled={loading}>
              <Download className="w-4 h-4 mr-2" />
              {loading ? t('ads.exporting') : t('orders.exportToCsv')}
            </Button>
          </div>
        </div>

        {/* Filters */}
        <Card>
          <CardHeader>
            <CardTitle className="flex items-center justify-between">
              {t('analytics.filterAnalytics')}
              <Button
                variant="ghost"
                size="sm"
                onClick={clearFilters}
                className="text-gray-500 hover:text-gray-700"
              >
                <X className="w-4 h-4 mr-1" />
                {t('products.clearFilters')}
              </Button>
            </CardTitle>
          </CardHeader>
          <CardContent>
            <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
              <div>
                <label className="text-sm font-medium">{t('analytics.period')}</label>
                <Select value={localFilters.period} onValueChange={(value) => handleFilterChange('period', value)}>
                  <SelectTrigger>
                    <SelectValue placeholder={t('analytics.selectPeriod')} />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="daily">{t('analytics.daily')}</SelectItem>
                    <SelectItem value="weekly">{t('analytics.weekly')}</SelectItem>
                    <SelectItem value="monthly">{t('analytics.monthly')}</SelectItem>
                  </SelectContent>
                </Select>
              </div>

              <div>
                <label className="text-sm font-medium">{t('finance.dateFrom')}</label>
                <Input
                  type="date"
                  value={localFilters.date_from}
                  onChange={(e) => handleFilterChange('date_from', e.target.value)}
                />
              </div>

              <div>
                <label className="text-sm font-medium">{t('finance.dateTo')}</label>
                <Input
                  type="date"
                  value={localFilters.date_to}
                  onChange={(e) => handleFilterChange('date_to', e.target.value)}
                  min={localFilters.date_from}
                />
              </div>

              <div className="flex items-end">
                <Button onClick={applyFilters} disabled={loading} className="w-full">
                  {loading ? t('analytics.applying') : t('analytics.applyFilters')}
                </Button>
              </div>
            </div>
          </CardContent>
        </Card>

        {/* Revenue Summary Cards */}
        <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
          <Card>
            <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
              <CardTitle className="text-sm font-medium">{t('analytics.currentPeriodRevenue')}</CardTitle>
              <Wallet className="h-4 w-4 text-muted-foreground" />
            </CardHeader>
            <CardContent>
              <div className="text-2xl font-bold">{formatCurrency(revenueSummary.current_period)}</div>
              <div className="flex items-center text-xs text-muted-foreground">
                {revenueSummary.growth_percentage >= 0 ? (
                  <TrendingUp className="mr-1 h-3 w-3 text-green-500" />
                ) : (
                  <TrendingDown className="mr-1 h-3 w-3 text-red-500" />
                )}
                {Math.abs(revenueSummary.growth_percentage)}% from previous period
              </div>
            </CardContent>
          </Card>

          <Card>
            <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
              <CardTitle className="text-sm font-medium">Total Sales</CardTitle>
              <ShoppingCart className="h-4 w-4 text-muted-foreground" />
            </CardHeader>
            <CardContent>
              <div className="text-2xl font-bold">{formatNumber(refundData.total_sales)}</div>
              <p className="text-xs text-muted-foreground">Completed orders</p>
            </CardContent>
          </Card>

          <Card>
            <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
              <CardTitle className="text-sm font-medium">{t('analytics.refundRate')}</CardTitle>
              <AlertTriangle className="h-4 w-4 text-muted-foreground" />
            </CardHeader>
            <CardContent>
              <div className="text-2xl font-bold">{refundData.refund_rate}%</div>
              <p className="text-xs text-muted-foreground">
                {refundData.total_refunds} refunds out of {refundData.total_sales} sales
              </p>
            </CardContent>
          </Card>
        </div>

        {/* Sales Graph */}
        <Card>
          <CardHeader>
            <CardTitle>Sales Trend</CardTitle>
          </CardHeader>
          <CardContent>
            {salesData.length === 0 ? (
              <div className="text-center py-8 text-gray-500">
                No sales data available for the selected period.
              </div>
            ) : (
              <div className="space-y-4">
                {salesData.map((data, index) => (
                  <div key={index} className="flex items-center justify-between p-4 border rounded-lg">
                    <div className="flex-1">
                      <div className="font-medium">{data.date}</div>
                      <div className="text-sm text-gray-500">
                        {data.sales_count} sales • {formatCurrency(data.revenue)} revenue
                      </div>
                    </div>
                    <div className="text-right">
                      <div className="text-sm font-medium text-green-600">
                        {formatCurrency(data.vendor_earnings)}
                      </div>
                      <div className="text-xs text-gray-500">Your Earnings</div>
                    </div>
                  </div>
                ))}
              </div>
            )}
          </CardContent>
        </Card>

        {/* Best Selling Products */}
        <Card>
          <CardHeader>
            <CardTitle>{t('analytics.bestSellingProducts')}</CardTitle>
          </CardHeader>
          <CardContent>
            {bestSellingProducts.length === 0 ? (
              <div className="text-center py-8 text-gray-500">
                No product sales data available for the selected period.
              </div>
            ) : (
              <div className="overflow-x-auto">
                <table className="min-w-full divide-y divide-gray-200 dark:divide-gray-700">
                  <thead>
                    <tr>
                      <th className="px-4 py-2 text-left">Product</th>
                      <th className="px-4 py-2 text-center">Sales Count</th>
                      <th className="px-4 py-2 text-right">Revenue</th>
                      <th className="px-4 py-2 text-right">Your Earnings</th>
                    </tr>
                  </thead>
                  <tbody>
                    {bestSellingProducts.map((product, index) => (
                      <tr key={index} className="hover:bg-gray-50 dark:hover:bg-gray-800">
                        <td className="px-4 py-2 font-medium">{product.product_name}</td>
                        <td className="px-4 py-2 text-center">{formatNumber(product.sales_count)}</td>
                        <td className="px-4 py-2 text-right">{formatCurrency(product.revenue)}</td>
                        <td className="px-4 py-2 text-right font-medium text-green-600">
                          {formatCurrency(product.vendor_earnings)}
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            )}
          </CardContent>
        </Card>

        {/* Refund Analytics */}
        <Card>
          <CardHeader>
            <CardTitle>Refund Analytics</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
              <div className="text-center">
                <div className="text-2xl font-bold">{formatNumber(refundData.total_sales)}</div>
                <div className="text-sm text-gray-500">Total Sales</div>
              </div>
              <div className="text-center">
                <div className="text-2xl font-bold text-red-600">{formatNumber(refundData.total_refunds)}</div>
                <div className="text-sm text-gray-500">Total Refunds</div>
              </div>
              <div className="text-center">
                <div className="text-2xl font-bold">{refundData.refund_rate}%</div>
                <div className="text-sm text-gray-500">{t('analytics.refundRate')}</div>
              </div>
              <div className="text-center">
                <div className="text-2xl font-bold text-red-600">{formatCurrency(refundData.refund_amount)}</div>
                <div className="text-sm text-gray-500">Refund Amount</div>
              </div>
            </div>
          </CardContent>
        </Card>
      </div>
    </AppLayout>
  );
} 