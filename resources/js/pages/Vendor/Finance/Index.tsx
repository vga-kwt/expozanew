/* eslint-disable @typescript-eslint/no-explicit-any */
import { useLanguage } from '@/components/language-context';
import { Link, router, usePage } from '@inertiajs/react';
import { ArrowUpRight, Download, ShoppingCart, TrendingUp, Wallet, X } from 'lucide-react';
import { useEffect, useState } from 'react';
import { toast } from 'react-hot-toast';
import { Badge } from '../../../components/ui/badge';
import { Button } from '../../../components/ui/button';
import { Card, CardContent, CardHeader, CardTitle } from '../../../components/ui/card';
import { Input } from '../../../components/ui/input';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '../../../components/ui/select';
import AppLayout from '../../../layouts/app-layout';

interface FinanceTransaction {
    id: number;
    transaction_id: string;
    type: string;
    status: string;
    total_amount: number;
    vendor_earnings: number;
    currency: string;
    payment_method: string;
    description: string;
    created_at: string;
    user?: { name: string };
    summery: string;
    attempt_status: string;
    payment_processor: string;
    amount: number;
    charge: number;
}

interface Props {
    transactions: {
        data: FinanceTransaction[];
        current_page: number;
        last_page: number;
        per_page: number;
        total: number;
        links: { url: string | null; label: string; active: boolean }[];
    };
    summary: {
        total_earnings: number;
        total_sales: number;
        total_subscription_fees: number;
        total_expo_slots: number;
        total_refunds: number;
        pending_earnings: number;
        this_month_earnings: number;
    };
    filters: {
        type?: string;
        status?: string;
        date_from?: string;
        date_to?: string;
    };
    flash?: {
        success?: string;
        error?: string;
    };
    [key: string]: any;
}


export default function VendorFinanceIndex() {
    const { t } = useLanguage();
    const { props } = usePage<Props>();
    const { transactions, summary, filters, flash } = props;
    const [localFilters, setLocalFilters] = useState({
        type: filters?.type || 'all',
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
        setLocalFilters((prev) => ({ ...prev, [key]: value }));
    };

    const applyFilters = () => {
        setLoading(true);
        const params = { ...localFilters } as Record<string, string>;
        Object.keys(params).forEach((key) => {
            if (params[key] === 'all') delete params[key];
        });
        router.get(route('vendor.finance.index'), params, { preserveState: true, preserveScroll: true, onFinish: () => setLoading(false) });
    };

    const clearFilters = () => {
        const defaultFilters = {
            type: 'all',
            status: 'all',
            date_from: '',
            date_to: '',
        };
        setLocalFilters(defaultFilters);
        router.get(route('vendor.finance.index'), defaultFilters, { preserveState: true, preserveScroll: true });
    };

    const exportTransactions = () => {
        setLoading(true);
        const params = new URLSearchParams();
        Object.entries(localFilters).forEach(([key, value]) => {
            if (value && value !== 'all') params.append(key, value);
        });
        window.open(`${route('vendor.finance.export.transactions')}?${params.toString()}`, '_blank');
        setLoading(false);
    };

    const formatCurrency = (amount: number) => {
        return new Intl.NumberFormat('en-US', {
            style: 'currency',
            currency: 'KWD',
            minimumFractionDigits: 2,
        }).format(amount);
    };

    function capitalizeFirst(str: string) {
        return str.charAt(0).toUpperCase() + str.slice(1).toLowerCase();
    }

    const predefinedTypeColors: Record<string, string> = {
        credit: 'bg-emerald-50 text-emerald-700 border border-emerald-200 dark:bg-emerald-900/20 dark:text-emerald-400 dark:border-emerald-800',
        debit: 'bg-rose-50 text-rose-700 border border-rose-200 dark:bg-rose-900/20 dark:text-rose-400 dark:border-rose-800',
        refund: 'bg-purple-50 text-purple-700 border border-purple-200 dark:bg-purple-900/20 dark:text-purple-400 dark:border-purple-800',
        commission: 'bg-amber-50 text-amber-700 border border-amber-200 dark:bg-amber-900/20 dark:text-amber-400 dark:border-amber-800',
        payout: 'bg-slate-50 text-slate-700 border border-slate-200 dark:bg-slate-900/20 dark:text-slate-400 dark:border-slate-800',
        bonus: 'bg-blue-50 text-blue-700 border border-blue-200 dark:bg-blue-900/20 dark:text-blue-400 dark:border-blue-800',
    };

    // Random color options for unknown types
    const randomColorOptions = [
        'bg-cyan-50 text-cyan-700 border border-cyan-200 dark:bg-cyan-900/20 dark:text-cyan-400 dark:border-cyan-800',
        'bg-teal-50 text-teal-700 border border-teal-200 dark:bg-teal-900/20 dark:text-teal-400 dark:border-teal-800',
        'bg-lime-50 text-lime-700 border border-lime-200 dark:bg-lime-900/20 dark:text-lime-400 dark:border-lime-800',
        'bg-orange-50 text-orange-700 border border-orange-200 dark:bg-orange-900/20 dark:text-orange-400 dark:border-orange-800',
        'bg-pink-50 text-pink-700 border border-pink-200 dark:bg-pink-900/20 dark:text-pink-400 dark:border-pink-800',
        'bg-violet-50 text-violet-700 border border-violet-200 dark:bg-violet-900/20 dark:text-violet-400 dark:border-violet-800',
        'bg-indigo-50 text-indigo-700 border border-indigo-200 dark:bg-indigo-900/20 dark:text-indigo-400 dark:border-indigo-800',
        'bg-sky-50 text-sky-700 border border-sky-200 dark:bg-sky-900/20 dark:text-sky-400 dark:border-sky-800',
    ];

    // Cache for generated random colors to maintain consistency
    const [randomColorCache, setRandomColorCache] = useState<Record<string, string>>({});

    const getTypeColor = (type: string): string => {
        // Return predefined color if exists
        if (predefinedTypeColors[type]) {
            return predefinedTypeColors[type];
        }

        // Return cached random color if already generated
        if (randomColorCache[type]) {
            return randomColorCache[type];
        }

        // Generate new random color
        const randomColor = randomColorOptions[Math.floor(Math.random() * randomColorOptions.length)];
        setRandomColorCache(prev => ({ ...prev, [type]: randomColor }));
        return randomColor;
    };
    
    const statusColors: Record<string, string> = {
        pending: 'bg-yellow-50 text-yellow-700 border border-yellow-200 dark:bg-yellow-900/20 dark:text-yellow-400 dark:border-yellow-800',
        Succss: 'bg-indigo-50 text-indigo-700 border border-indigo-200 dark:bg-indigo-900/20 dark:text-indigo-400 dark:border-indigo-800',
        failed: 'bg-rose-50 text-rose-700 border border-rose-200 dark:bg-rose-900/20 dark:text-rose-400 dark:border-rose-800',
        cancelled: 'bg-slate-50 text-slate-700 border border-slate-200 dark:bg-slate-900/20 dark:text-slate-400 dark:border-slate-800',
        processing: 'bg-blue-50 text-blue-700 border border-blue-200 dark:bg-blue-900/20 dark:text-blue-400 dark:border-blue-800',
    };
    const paymentProcessorColors: Record<string, string> = {
        KNET: 'bg-indigo-50 text-indigo-700 border border-indigo-200 dark:bg-indigo-900/20 dark:text-indigo-400 dark:border-indigo-800',
        'VISA/MASTER': 'bg-sky-50 text-sky-700 border border-sky-200 dark:bg-sky-900/20 dark:text-sky-400 dark:border-sky-800',
        Myfatoorah: 'bg-amber-50 text-amber-700 border border-amber-200 dark:bg-amber-900/20 dark:text-amber-400 dark:border-amber-800',
    };

    if (!transactions || !transactions.data) {
        return <div>{t('finance.noTransactionsFound')}</div>;
    }

    return (
        <AppLayout>
            <div className="space-y-6 p-6">
                <div className="flex items-center justify-between">
                    <h1 className="text-2xl font-bold">{t('vendor.financeManager')}</h1>
                    <div className="flex gap-2">
                        <Button onClick={exportTransactions} variant="outline" disabled={loading}>
                            <Download className="mr-2 h-4 w-4" />
                            {loading ? t('ads.exporting') : t('orders.exportToCsv')}
                        </Button>
                    </div>
                </div>
                <div className="flex space-x-1 border-b">
                    <Button variant="default">{t('finance.revenue')}</Button>
                    <Link href={route('vendor.finance.payouts')}>
                        <Button variant="ghost">{t('finance.payouts')}</Button>
                    </Link>
                </div>
                <div className="space-y-6">
                    <div className="grid grid-cols-1 gap-4 md:grid-cols-2 lg:grid-cols-4">
                        <Card>
                            <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                                <CardTitle className="text-sm font-medium">{t('finance.totalEarnings')}</CardTitle>
                                <Wallet className="text-muted-foreground h-4 w-4" />
                            </CardHeader>
                            <CardContent>
                                <div className="text-2xl font-bold">{summary.total_earnings}</div>
                                <p className="text-muted-foreground text-xs">{t('finance.allTimeEarnings')}</p>
                            </CardContent>
                        </Card>
                        <Card>
                            <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                                <CardTitle className="text-sm font-medium">{t('finance.thisMonth')}</CardTitle>
                                <TrendingUp className="text-muted-foreground h-4 w-4" />
                            </CardHeader>
                            <CardContent>
                                <div className="text-2xl font-bold">{summary.this_month_earnings}</div>
                                <p className="text-muted-foreground text-xs">{t('finance.currentMonthEarnings')}</p>
                            </CardContent>
                        </Card>
                        <Card>
                            <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                                <CardTitle className="text-sm font-medium">{t('finance.pendingEarnings')}</CardTitle>
                                <ArrowUpRight className="text-muted-foreground h-4 w-4" />
                            </CardHeader>
                            <CardContent>
                                <div className="text-2xl font-bold">{summary.pending_earnings}</div>
                                <p className="text-muted-foreground text-xs">{t('finance.awaitingProcessing')}</p>
                            </CardContent>
                        </Card>
                        <Card>
                            <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                                <CardTitle className="text-sm font-medium">{t('finance.totalSales')}</CardTitle>
                                <ShoppingCart className="text-muted-foreground h-4 w-4" />
                            </CardHeader>
                            <CardContent>
                                <div className="text-2xl font-bold">{summary.total_sales}</div>
                                <p className="text-muted-foreground text-xs">{t('finance.productSales')}</p>
                            </CardContent>
                        </Card>
                    </div>
                    <div className="grid grid-cols-1 gap-4 md:grid-cols-3">
                        <Card>
                            <CardHeader>
                                <CardTitle className="text-sm">{t('finance.subscriptionFees')}</CardTitle>
                            </CardHeader>
                            <CardContent>
                                <div className="text-lg font-semibold">{summary.total_subscription_fees}</div>
                            </CardContent>
                        </Card>
                        <Card>
                            <CardHeader>
                                <CardTitle className="text-sm">{t('finance.expoSlots')}</CardTitle>
                            </CardHeader>
                            <CardContent>
                                <div className="text-lg font-semibold">{summary.total_expo_slots}</div>
                            </CardContent>
                        </Card>
                        <Card>
                            <CardHeader>
                                <CardTitle className="text-sm">{t('finance.refunds')}</CardTitle>
                            </CardHeader>
                            <CardContent>
                                <div className="text-lg font-semibold text-red-600">{summary.total_refunds}</div>
                            </CardContent>
                        </Card>
                    </div>
                    <Card>
                        <CardHeader>
                            <CardTitle className="flex items-center justify-between">
                                {t('finance.filterTransactions')}
                                <Button
                                    variant="ghost"
                                    size="sm"
                                    onClick={clearFilters}
                                    className="border border-gray-300 text-gray-500 dark:border-gray-700"
                                >
                                    <X className="mr-1 h-4 w-4" />
                                    {t('products.clearFilters')}
                                </Button>
                            </CardTitle>
                        </CardHeader>
                        <CardContent>
                            <div className="grid grid-cols-1 gap-4 md:grid-cols-4">
                                <div>
                                    <label className="text-sm font-medium">{t('finance.transactionType')}</label>
                                    <Select value={localFilters.type} onValueChange={(value) => handleFilterChange('type', value)}>
                                        <SelectTrigger>
                                            <SelectValue placeholder={t('finance.allTypes')} />
                                        </SelectTrigger>
                                        <SelectContent>
                                            <SelectItem value="all">{t('finance.allTypes')}</SelectItem>
                                            <SelectItem value="order">{t('finance.typeSales')}</SelectItem>
                                            <SelectItem value="subscription">{t('finance.typeSubscription')}</SelectItem>
                                            <SelectItem value="expo_slot">{t('finance.typeExpoSlots')}</SelectItem>
                                            <SelectItem value="refund">{t('finance.typeRefunds')}</SelectItem>
                                            <SelectItem value="chargeback">{t('finance.typeChargebacks')}</SelectItem>
                                        </SelectContent>
                                    </Select>
                                </div>
                                <div>
                                    <label className="text-sm font-medium">{t('common.status')}</label>
                                    <Select value={localFilters.status} onValueChange={(value) => handleFilterChange('status', value)}>
                                        <SelectTrigger>
                                            <SelectValue placeholder={t('finance.allStatuses')} />
                                        </SelectTrigger>
                                        <SelectContent>
                                            <SelectItem value="all">{t('finance.allStatuses')}</SelectItem>
                                            <SelectItem value="pending">{t('finance.statusPending')}</SelectItem>
                                            <SelectItem value="completed">{t('finance.statusCompleted')}</SelectItem>
                                            <SelectItem value="failed">{t('finance.statusFailed')}</SelectItem>
                                            <SelectItem value="cancelled">{t('finance.statusCancelled')}</SelectItem>
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
                            </div>
                            <div className="mt-4 flex justify-end">
                                <Button onClick={applyFilters} disabled={loading}>
                                    {loading ? t('finance.applying') : t('finance.applyFilters')}
                                </Button>
                            </div>
                        </CardContent>
                    </Card>
                    <Card>
                        <CardHeader>
                            <CardTitle>{t('finance.transactionHistory')}</CardTitle>
                        </CardHeader>
                        <CardContent>
                            <div className="overflow-x-auto">
                                <table className="min-w-full border bg-white dark:bg-neutral-900">
                                    <thead>
                                        <tr>
                                            <th className="border px-4 py-2 text-left">{t('finance.transactionId')}</th>
                                            <th className="border px-4 py-2 text-left">{t('finance.description')}</th>
                                            <th className="border px-4 py-2 text-center">{t('finance.type')}</th>
                                            <th className="border px-4 py-2 text-center">{t('common.status')}</th>
                                            <th className="border px-4 py-2 text-center">{t('finance.method')}</th>
                                            <th className="border px-4 py-2 text-center">{t('finance.amount')}</th>
                                            <th className="border px-4 py-2 text-center">{t('finance.charge')}</th>
                                            <th className="border px-4 py-2 text-left">{t('orders.date')}</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        {transactions.data.length === 0 && (
                                            <tr>
                                                <td colSpan={8} className="py-4 text-center text-gray-500">
                                                    {t('finance.noTransactionsFound')}
                                                </td>
                                            </tr>
                                        )}
                                        {transactions.data.map((transaction) => (
                                            <tr key={transaction.id} className="hover:bg-gray-50 dark:hover:bg-neutral-800">
                                                <td className="border px-4 py-3 font-mono text-sm">{transaction.transaction_id}</td>
                                                <td className="border px-4 py-3 text-sm">{transaction.summery}</td>
                                                <td className="border px-4 py-3 text-center text-sm">
                                                    <Badge className={getTypeColor(transaction.type)}>
                                                        {transaction.type
                                                            .split('_')
                                                            .map(word => word.charAt(0).toUpperCase() + word.slice(1))
                                                            .join(' ')}
                                                    </Badge>
                                                </td>
                                                <td className="border px-4 py-3 text-center text-sm">
                                                    <Badge className={statusColors[transaction.attempt_status] || 'bg-gray-100 text-gray-800'}>
                                                        {capitalizeFirst(transaction.attempt_status)}
                                                    </Badge>
                                                </td>
                                                <td className="border px-4 py-3 text-center text-sm">
                                                    <Badge
                                                        className={
                                                            paymentProcessorColors[transaction?.payment_processor ?? ''] ||
                                                            'bg-gray-100 text-gray-800'
                                                        }
                                                    >
                                                        {capitalizeFirst(transaction?.payment_processor ?? '')}
                                                    </Badge>
                                                </td>
                                                <td className={`border px-4 py-3 text-center text-sm font-medium`}>
                                                    {(transaction.amount)}
                                                </td>
                                                <td className={`border px-4 py-3 text-center text-sm font-medium`}>
                                                    {(transaction.charge)}
                                                </td>
                                                <td className="border px-4 py-3 text-sm text-gray-500">
                                                    {new Date(transaction.created_at).toLocaleDateString()}
                                                </td>
                                            </tr>
                                        ))}
                                    </tbody>
                                </table>
                            </div>
                            {/* Pagination */}
                            <div className="mt-4 flex justify-center">
                                {transactions.links.map((link, i) => (
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
            </div>
        </AppLayout>
    );
}
