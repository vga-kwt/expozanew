import React, { useState, useEffect } from 'react';
import { useLanguage } from '@/components/language-context';
import { router, Link, usePage } from '@inertiajs/react';
import { Button } from '../../../components/ui/button';
import { Card, CardContent, CardHeader, CardTitle } from '../../../components/ui/card';
import { Input } from '../../../components/ui/input';
import { Badge } from '../../../components/ui/badge';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '../../../components/ui/select';
import { Download, Wallet, Clock, CheckCircle, Calendar, AlertCircle, X, Filter, Search, ArrowLeft } from 'lucide-react';
import AppLayout from '../../../layouts/app-layout';
import { toast } from 'react-hot-toast';
import { Pagination } from '../../../components/Pagination';

interface VendorPayout {
  id: number;
  payout_id: string;
  status: string;
  amount: number;
  currency: string;
  payment_method: string;
  summary: string;
  scheduled_date: string;
  processed_date?: string;
  transaction_reference_id?: string;
  approved_by?: { name: string };
  approved_at?: string;
  notes?: string;
  created_at: string;
}

interface Props {
  payouts: {
    data: VendorPayout[];
    current_page: number;
    last_page: number;
    per_page: number;
    total: number;
    links: { url: string | null; label: string; active: boolean }[];
  };
  summary: {
    pending_payouts: number;
    completed_payouts: number;
    total_payouts: number;
    pending_count: number;
    next_payout_date?: string;
  };
  filters: {
    status?: string;
    date_from?: string;
    date_to?: string;
  };
  flash?: {
    success?: string;
    error?: string;
  };
}

const statusColors = {
  pending: 'bg-yellow-50 text-yellow-700 border border-yellow-200 dark:bg-yellow-900/20 dark:text-yellow-400 dark:border-yellow-800',
  approved: 'bg-blue-50 text-blue-700 border border-blue-200 dark:bg-blue-900/20 dark:text-blue-400 dark:border-blue-800',
  completed: 'bg-emerald-50 text-emerald-700 border border-emerald-200 dark:bg-emerald-900/20 dark:text-emerald-400 dark:border-emerald-800',
  rejected: 'bg-rose-50 text-rose-700 border border-rose-200 dark:bg-rose-900/20 dark:text-rose-400 dark:border-rose-800',
  cancelled: 'bg-slate-50 text-slate-700 border border-slate-200 dark:bg-slate-900/20 dark:text-slate-400 dark:border-slate-800',
};

const paymentProcessorColors: Record<string, string> = {
  knet: 'bg-indigo-50 text-indigo-700 border border-indigo-200 dark:bg-indigo-900/20 dark:text-indigo-400 dark:border-indigo-800',
  card: 'bg-sky-50 text-sky-700 border border-sky-200 dark:bg-sky-900/20 dark:text-sky-400 dark:border-sky-800',
  myfatoorah: 'bg-amber-50 text-amber-700 border border-amber-200 dark:bg-amber-900/20 dark:text-amber-400 dark:border-amber-800',
};

const statusIcons = {
  pending: <Clock className="h-4 w-4" />,
  approved: <CheckCircle className="h-4 w-4" />,
  completed: <CheckCircle className="h-4 w-4" />,
  rejected: <X className="h-4 w-4" />,
  cancelled: <AlertCircle className="h-4 w-4" />,
};

export default function VendorFinancePayouts() {
  const { t } = useLanguage();
  const { props } = usePage<Props>();
  const { payouts, summary, filters, flash } = props;
  const [localFilters, setLocalFilters] = useState({
    status: filters?.status || 'all',
    date_from: filters?.date_from || '',
    date_to: filters?.date_to || '',
  });
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    if (flash?.success) toast.success(flash.success);
    if (flash?.error) toast.error(flash.error);
  }, [flash?.success, flash?.error]);

  const handleFilterChange = (key: string, value: string) => {
    setLocalFilters(prev => ({ ...prev, [key]: value }));
  };

  const applyFilters = () => {
    setLoading(true);
    const params = { ...localFilters } as Record<string, string>;
    Object.keys(params).forEach(key => {
      if (params[key] === 'all') delete params[key];
    });
    router.get(route('vendor.finance.payouts'), params, { preserveState: true, preserveScroll: true, onFinish: () => setLoading(false) });
  };

  const clearFilters = () => {
    const defaultFilters = {
      status: 'all',
      date_from: '',
      date_to: '',
    };
    setLocalFilters(defaultFilters);
    router.get(route('vendor.finance.payouts'), defaultFilters, { preserveState: true, preserveScroll: true });
  };

  const exportPayouts = () => {
    const params = { ...localFilters } as Record<string, string>;
    Object.keys(params).forEach(key => {
      if (params[key] === 'all') delete params[key];
    });
    window.open(route('vendor.finance.export.payouts', params), '_blank');
  };

  const formatCurrency = (amount: number) => {
    return new Intl.NumberFormat('en-US', {
      style: 'currency',
      currency: 'USD',
    }).format(amount);
  };

  const formatDate = (dateString: string) => {
    return new Date(dateString).toLocaleDateString('en-US', {
      year: 'numeric',
      month: 'short',
      day: 'numeric',
    });
  };

  const getStatusIcon = (status: string) => {
    return statusIcons[status as keyof typeof statusIcons] || <AlertCircle className="h-4 w-4" />;
  };

  const getStatusColor = (status: string) => {
    return statusColors[status as keyof typeof statusColors] || statusColors.pending;
  };

  const handlePageChange = (page: number) => {
    const params = { ...localFilters, page } as Record<string, string | number>;
    Object.keys(params).forEach((key) => {
      if (params[key] === 'all' || params[key] === '') delete params[key];
    });
    router.get(route('vendor.finance.payouts'), params);
  };

  // Count active filters
  const activeFilterCount = Object.values(localFilters).filter((value) => value !== '' && value !== 'all').length;

  return (
    <AppLayout>
      <div className="space-y-6 p-6">
        {/* Header */}
        <div className="flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between">
          <div>
            <h1 className="text-2xl font-bold">{t('vendor.myPayouts')}</h1>
            <p className="text-sm text-gray-600 dark:text-gray-400">{t('payouts.trackPayoutsDesc')}</p>
          </div>
          <div className="flex gap-2">
            <Button onClick={exportPayouts} variant="outline">
              <Download className="mr-2 h-4 w-4" />
              {t('orders.exportToCsv')}
            </Button>
            <Link href={route('vendor.finance.index')}>
              <Button variant="outline">
                <ArrowLeft className="mr-2 h-4 w-4" />
                {t('common.back')} to {t('finance.revenue')}
              </Button>
            </Link>
          </div>
        </div>

        {/* Statistics Cards */}
        <div className="grid grid-cols-1 gap-4 md:grid-cols-2 lg:grid-cols-4">
          <Card>
            <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
              <CardTitle className="text-sm font-medium">{t('payouts.totalPayouts')}</CardTitle>
              <Wallet className="text-muted-foreground h-4 w-4" />
            </CardHeader>
            <CardContent>
              <div className="text-2xl font-bold text-green-600">
                {summary.total_payouts}
              </div>
              <p className="text-muted-foreground text-xs">{payouts.total} {t('payouts.payoutsCount')}</p>
            </CardContent>
          </Card>

          <Card>
            <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
              <CardTitle className="text-sm font-medium">{t('payouts.pendingPayouts')}</CardTitle>
              <Clock className="text-muted-foreground h-4 w-4" />
            </CardHeader>
            <CardContent>
              <div className="text-2xl font-bold text-yellow-600">
                {summary.pending_payouts}
              </div>
              <p className="text-muted-foreground text-xs">{summary.pending_count} {t('payouts.pendingCount')}</p>
            </CardContent>
          </Card>

          <Card>
            <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
              <CardTitle className="text-sm font-medium">{t('payouts.completedPayouts')}</CardTitle>
              <CheckCircle className="text-muted-foreground h-4 w-4" />
            </CardHeader>
            <CardContent>
              <div className="text-2xl font-bold text-emerald-600">
                {summary.completed_payouts}
              </div>
              <p className="text-muted-foreground text-xs">{t('payouts.successfullyProcessed')}</p>
            </CardContent>
          </Card>


        </div>

        {/* Filters */}
        <Card>
          <CardHeader>
            <CardTitle className="flex items-center gap-2">
              <Filter className="h-4 w-4" />
              {t('payouts.filters')}
              {activeFilterCount > 0 && (
                <Badge variant="secondary" className="ml-2">
                  {activeFilterCount}
                </Badge>
              )}
            </CardTitle>
          </CardHeader>
          <CardContent>
            <div className="grid grid-cols-1 gap-4 md:grid-cols-3">
              <div>
                <label className="text-sm font-medium">{t('common.status')}</label>
                <Select value={localFilters.status} onValueChange={(value) => handleFilterChange('status', value)}>
                  <SelectTrigger>
                    <SelectValue placeholder={t('payouts.allStatuses')} />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="all">{t('payouts.allStatuses')}</SelectItem>
                    <SelectItem value="pending">{t('payouts.statusPending')}</SelectItem>
                    <SelectItem value="approved">{t('payouts.statusApproved')}</SelectItem>
                    <SelectItem value="completed">{t('payouts.statusCompleted')}</SelectItem>
                    <SelectItem value="rejected">{t('payouts.statusRejected')}</SelectItem>
                    <SelectItem value="cancelled">{t('payouts.statusCancelled')}</SelectItem>
                  </SelectContent>
                </Select>
              </div>
              <div>
                <label className="text-sm font-medium">{t('payouts.dateFrom')}</label>
                <Input
                  type="date"
                  value={localFilters.date_from}
                  onChange={(e) => handleFilterChange('date_from', e.target.value)}
                />
              </div>
              <div>
                <label className="text-sm font-medium">{t('payouts.dateTo')}</label>
                <Input
                  type="date"
                  value={localFilters.date_to}
                  onChange={(e) => handleFilterChange('date_to', e.target.value)}
                />
              </div>
            </div>
            <div className="mt-4 flex gap-2">
              <Button onClick={applyFilters} disabled={loading}>
                {loading ? t('payouts.applying') : t('payouts.applyFilters')}
              </Button>
              <Button onClick={clearFilters} variant="outline">
                {t('products.clearFilters')}
              </Button>
            </div>
          </CardContent>
        </Card>

        {/* Payouts Table */}
        <Card>
          <CardHeader>
            <CardTitle>{t('payouts.payoutHistory')}</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="overflow-x-auto">
              <table className="w-full">
                <thead>
                  <tr className="border-b">
                    <th className="text-left p-2">{t('payouts.payoutId')}</th>
                    <th className="text-left p-2">{t('payouts.amount')}</th>
                    <th className="text-left p-2">{t('common.status')}</th>
                    <th className="text-left p-2">{t('payouts.paymentMethod')}</th>
                    <th className="text-left p-2">{t('payouts.scheduledDate')}</th>
                    <th className="text-left p-2">{t('payouts.processedDate')}</th>
                    <th className="text-left p-2">{t('payouts.summary')}</th>
                  </tr>
                </thead>
                <tbody>
                  {payouts.data.map((payout) => (
                    <tr key={payout.id} className="border-b hover:bg-gray-50 dark:hover:bg-gray-800">
                      <td className="p-2 font-mono text-sm">{payout.payout_id}</td>
                      <td className="p-2 font-medium">{payout.amount}</td>
                      <td className="p-2">
                        <Badge className={getStatusColor(payout.status)}>
                          <div className="flex items-center gap-1">
                            {getStatusIcon(payout.status)}
                            {payout.status.charAt(0).toUpperCase() + payout.status.slice(1)}
                          </div>
                        </Badge>
                      </td>
                      <td className="p-2 capitalize">
                        <Badge className={paymentProcessorColors[payout.payment_method]}>
                          {payout.payment_method.charAt(0).toUpperCase() + payout.payment_method.slice(1)}
                        </Badge>
                      </td>
                      <td className="p-2 text-sm">{formatDate(payout.scheduled_date)}</td>
                      <td className="p-2 text-sm">
                        {payout.processed_date ? formatDate(payout.processed_date) : '-'}
                      </td>
                      <td className="p-2 text-sm max-w-xs truncate" title={payout.summary}>
                        {payout.summary}
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>

            {payouts.data.length === 0 && (
              <div className="text-center py-8 text-gray-500">
                {t('payouts.noPayoutsFound')}
              </div>
            )}

            {/* Pagination */}
            <div className="mt-4 flex justify-center">
              {payouts.links.map((link, i) => (
                <Button key={i} asChild variant={link.active ? 'default' : 'outline'} disabled={!link.url} className="mx-1">
                  {link.url ? (
                    <Link href={link.url} preserveScroll preserveState>
                      {link.label.replace(/&laquo;|&raquo;/g, '')}
                    </Link>
                  ) : (
                    <span>{link.label.replace(/&laquo;|&raquo;/g, '')}</span>
                  )}
                </Button>
              ))}
            </div>
          </CardContent>
        </Card>
      </div>
    </AppLayout>
  );
} 