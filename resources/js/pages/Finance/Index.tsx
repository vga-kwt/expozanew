import { Input } from '@/components/ui/input';
import { StatusFilter } from '@/components/ui/StatusFilter';
import { Head, Link, router } from '@inertiajs/react';
import { Calendar, CreditCard, Download, Filter, Search, TrendingUp, Users, Wallet } from 'lucide-react';
import { useCallback, useState } from 'react';
import { Pagination } from '../../components/Pagination';
import { Badge } from '../../components/ui/badge';
import { Button } from '../../components/ui/button';
import { Card, CardContent, CardHeader, CardTitle } from '../../components/ui/card';
import AppLayout from '../../layouts/app-layout';

interface FinanceTransaction {
    id: number;
    transaction_id: string;
    type: string;
    user_type: string;
    attempt_status: string;
    amount: number;
    charge: number;
    summery: string;
    payment_reference_id?: string;
    payment_processor?: string | null;
    created_at: string;
    user?: { full_name: string; email: string };
    vendor?: { name: string; brand_name_en: string };
}

interface Statistics {
    transactions: {
        total_transactions: number;
        total_amount: number;
        type_breakdown: Record<string, number>;
        income_amount: number;
        expense_amount: number;
        refund_amount: number;
    };
    payouts: {
        total_payouts: number;
        total_amount: number;
        status_breakdown: Record<string, number>;
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
    statistics: Statistics;
    vendors: Array<{ id: number; name: string }>;
    filters: {
        search?: string;
        type?: string;
        status?: string;
        date_from?: string;
        date_to?: string;
        amount_min?: string;
        amount_max?: string;
    };
}

const typeColors: Record<string, string> = {
    credit: 'bg-emerald-50 text-emerald-700 border border-emerald-200 dark:bg-emerald-900/20 dark:text-emerald-400 dark:border-emerald-800',
    debit: 'bg-rose-50 text-rose-700 border border-rose-200 dark:bg-rose-900/20 dark:text-rose-400 dark:border-rose-800',
    refund: 'bg-purple-50 text-purple-700 border border-purple-200 dark:bg-purple-900/20 dark:text-purple-400 dark:border-purple-800',
    commission: 'bg-amber-50 text-amber-700 border border-amber-200 dark:bg-amber-900/20 dark:text-amber-400 dark:border-amber-800',
    payout: 'bg-slate-50 text-slate-700 border border-slate-200 dark:bg-slate-900/20 dark:text-slate-400 dark:border-slate-800',
    bonus: 'bg-blue-50 text-blue-700 border border-blue-200 dark:bg-blue-900/20 dark:text-blue-400 dark:border-blue-800',
    order: 'bg-cyan-50 text-cyan-700 border border-cyan-200 dark:bg-cyan-900/20 dark:text-cyan-400 dark:border-cyan-800',
};

const statusColors: Record<string, string> = {
    pending: 'bg-yellow-50 text-yellow-700 border border-yellow-200 dark:bg-yellow-900/20 dark:text-yellow-400 dark:border-yellow-800',
    completed: 'bg-emerald-50 text-emerald-700 border border-emerald-200 dark:bg-emerald-900/20 dark:text-emerald-400 dark:border-emerald-800',
    failed: 'bg-rose-50 text-rose-700 border border-rose-200 dark:bg-rose-900/20 dark:text-rose-400 dark:border-rose-800',
    cancelled: 'bg-slate-50 text-slate-700 border border-slate-200 dark:bg-slate-900/20 dark:text-slate-400 dark:border-slate-800',
    processing: 'bg-blue-50 text-blue-700 border border-blue-200 dark:bg-blue-900/20 dark:text-blue-400 dark:border-blue-800',
    success: 'bg-green-50 text-green-700 border border-green-200 dark:bg-green-900/20 dark:text-green-400 dark:border-green-800',
};

const paymentProcessorColors: Record<string, string> = {
    knet: 'bg-indigo-50 text-indigo-700 border border-indigo-200 dark:bg-indigo-900/20 dark:text-indigo-400 dark:border-indigo-800',
    card: 'bg-sky-50 text-sky-700 border border-sky-200 dark:bg-sky-900/20 dark:text-sky-400 dark:border-sky-800',
    myfatoorah: 'bg-amber-50 text-amber-700 border border-amber-200 dark:bg-amber-900/20 dark:text-amber-400 dark:border-amber-800',
    'apple pay': 'bg-pink-50 text-pink-700 border border-pink-200 dark:bg-pink-900/20 dark:text-pink-400 dark:border-pink-800',
    'visa/master': 'bg-violet-50 text-violet-700 border border-violet-200 dark:bg-violet-900/20 dark:text-violet-400 dark:border-violet-800',
};

function capitalizeFirst(str: string) {
    return str.charAt(0).toUpperCase() + str.slice(1).toLowerCase();
}

export default function FinanceIndex({ transactions, statistics, filters }: Props) {
    const [localFilters, setLocalFilters] = useState({
        search: filters.search || '',
        type: filters.type || 'all',
        status: filters.status || 'all',
        date_from: filters.date_from || '',
        date_to: filters.date_to || '',
        amount_min: filters.amount_min || '',
        amount_max: filters.amount_max || '',
    });

    // Debounced search function
    const debouncedSearch = useCallback(
        (() => {
            let timeoutId: NodeJS.Timeout;
            return (searchTerm: string) => {
                clearTimeout(timeoutId);
                timeoutId = setTimeout(() => {
                    const newFilters = { ...localFilters, search: searchTerm };
                    applyFilters(newFilters);
                }, 500);
            };
        })(),
        [localFilters],
    );

    const applyFilters = (newFilters: typeof localFilters) => {
        const params = { ...newFilters } as Record<string, string>;
        Object.keys(params).forEach((key) => {
            if (params[key] === 'all' || params[key] === '') delete params[key];
        });
        router.get(route('finance.index'), params);
    };

    const handleFilterChange = (key: string, value: string) => {
        const newFilters = { ...localFilters, [key]: value };

        // Validate date range
        if (key === 'date_from' && newFilters.date_to && value > newFilters.date_to) {
            // If start date is after end date, clear end date
            newFilters.date_to = '';
        }
        if (key === 'date_to' && newFilters.date_from && value < newFilters.date_from) {
            // If end date is before start date, clear start date
            newFilters.date_from = '';
        }

        setLocalFilters(newFilters);
        applyFilters(newFilters);
    };

    const clearFilters = () => {
        setLocalFilters({
            search: '',
            type: 'all',
            status: 'all',
            date_from: '',
            date_to: '',
            amount_min: '',
            amount_max: '',
        });
        router.get(route('finance.index'), {});
    };

    const exportTransactions = () => {
        const params = new URLSearchParams(localFilters);
        window.open(`${route('finance.export.transactions')}?${params.toString()}`, '_blank');
    };

    const formatCurrency = (amount: number) => {
        return new Intl.NumberFormat('en-US', {
            style: 'currency',
            currency: 'KWD',
            minimumFractionDigits: 3,
            maximumFractionDigits: 3,
        }).format(amount);
    };

    const handlePageChange = (page: number) => {
        const params = { ...localFilters, page } as Record<string, string | number>;
        Object.keys(params).forEach((key) => {
            if (params[key] === 'all' || params[key] === '') delete params[key];
        });
        router.get(route('finance.index'), params);
    };

    // Get today's date for max constraint
    const today = new Date().toISOString().split('T')[0];

    // Count active filters
    const activeFilterCount = Object.values(localFilters).filter((value) => value !== '' && value !== 'all').length;

    return (
        <AppLayout>
            <Head title="Finance - Expoza" />

            <div className="space-y-6 p-6">
                {/* Header */}
                <div className="flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between">
                    <div>
                        <h1 className="text-2xl font-bold">Finance Management</h1>
                        <p className="text-sm text-gray-600 dark:text-gray-400">Monitor transactions, revenue, and financial performance</p>
                    </div>
                    <div className="flex gap-2">
                        <Button onClick={exportTransactions} variant="outline">
                            <Download className="mr-2 h-4 w-4" />
                            Export CSV
                        </Button>
                        <Link href={route('finance.payouts')}>
                            <Button>
                                Manage Payouts
                            </Button>
                        </Link>
                    </div>
                </div>

                {/* Statistics Cards */}
                <div className="grid grid-cols-1 gap-4 md:grid-cols-2 lg:grid-cols-4">
                    <Card>
                        <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                            <CardTitle className="text-sm font-medium">Net Income</CardTitle>
                            <TrendingUp className="text-muted-foreground h-4 w-4" />
                        </CardHeader>
                        <CardContent>
                            <div
                                className={`text-2xl font-bold ${statistics?.summary?.net_income < 0 ? 'text-red-600' : statistics?.summary?.net_income > 0 ? 'text-green-600' : ''}`}
                            >
                                {(statistics?.summary?.net_income || 0).toLocaleString()}
                            </div>
                            <p className="text-muted-foreground text-xs">{(statistics?.summary?.profit_margin || 0).toFixed(1)}% profit margin</p>
                        </CardContent>
                    </Card>

                    <Card>
                        <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                            <CardTitle className="text-sm font-medium">Total Revenue</CardTitle>
                            <Wallet className="text-muted-foreground h-4 w-4" />
                        </CardHeader>
                        <CardContent>
                            <div
                                className={`text-2xl font-bold ${statistics?.transactions?.income_amount < 0 ? 'text-red-600' : statistics?.transactions?.income_amount > 0 ? 'text-green-600' : ''}`}
                            >
                                {(statistics?.transactions?.income_amount || 0).toLocaleString()}
                            </div>
                            <p className="text-muted-foreground text-xs">{statistics?.transactions?.total_transactions || 0} transactions</p>
                        </CardContent>
                    </Card>

                    <Card>
                        <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                            <CardTitle className="text-sm font-medium">Total Payouts</CardTitle>
                            <Users className="text-muted-foreground h-4 w-4" />
                        </CardHeader>
                        <CardContent>
                            <div
                                className={`text-2xl font-bold ${statistics?.summary?.total_payouts < 0 ? 'text-red-600' : statistics?.summary?.total_payouts > 0 ? 'text-green-600' : ''}`}
                            >
                                {(statistics?.summary?.total_payouts || 0).toLocaleString()}
                            </div>
                            <p className="text-muted-foreground text-xs">{formatCurrency(statistics?.summary?.pending_payouts || 0)} pending</p>
                        </CardContent>
                    </Card>

                    <Card>
                        <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                            <CardTitle className="text-sm font-medium">Available Balance</CardTitle>
                            <CreditCard className="text-muted-foreground h-4 w-4" />
                        </CardHeader>
                        <CardContent>
                            <div
                                className={`text-2xl font-bold ${statistics?.summary?.available_balance < 0 ? 'text-red-600' : statistics?.summary?.available_balance > 0 ? 'text-green-600' : ''}`}
                            >
                                {(statistics?.summary?.available_balance || 0).toLocaleString()}
                            </div>
                            <p className="text-muted-foreground text-xs">After all payouts</p>
                        </CardContent>
                    </Card>
                </div>

                {/* Filters */}
                <Card>
                    <CardHeader>
                        <CardTitle className="flex items-center gap-2">
                            <Filter className="h-4 w-4" />
                            Filters
                        </CardTitle>
                    </CardHeader>
                    <CardContent>
                        <div className="grid grid-cols-1 gap-4 md:grid-cols-2 lg:grid-cols-4">
                            <div>
                                <label className="text-sm font-medium">Search</label>
                                <div className="relative">
                                    <Search className="text-muted-foreground absolute top-1/2 left-3 h-4 w-4 -translate-y-1/2" />
                                    <Input
                                        placeholder="Search transactions..."
                                        value={localFilters.search}
                                        onChange={(e) => {
                                            setLocalFilters((prev) => ({ ...prev, search: e.target.value }));
                                            debouncedSearch(e.target.value);
                                        }}
                                        className="pl-9"
                                    />
                                </div>
                            </div>
                            <div>
                                <label className="text-sm font-medium">Status</label>
                                <StatusFilter
                                    value={localFilters.status}
                                    onChange={(v) => handleFilterChange('status', v)}
                                    statusOptions={[
                                        { value: 'all', label: 'All Statuses' },
                                        { value: 'pending', label: 'Pending' },
                                        { value: 'completed', label: 'Completed' },
                                        { value: 'failed', label: 'Failed' },
                                        { value: 'cancelled', label: 'Cancelled' },
                                    ]}
                                    placeholder="Filter by status"
                                    className="w-80"
                                />
                            </div>

                            <div>
                                <label className="text-sm font-medium">Start Date</label>
                                <div className="relative">
                                    <Calendar className="text-muted-foreground absolute top-1/2 left-3 h-4 w-4 -translate-y-1/2" />
                                    <Input
                                        type="date"
                                        value={localFilters.date_from}
                                        onChange={(e) => handleFilterChange('date_from', e.target.value)}
                                        className="pl-9"
                                        max={localFilters.date_to || today}
                                        placeholder="Select start date"
                                        min="2015-01-01"
                                    />
                                </div>
                            </div>

                            <div>
                                <label className="text-sm font-medium">End Date</label>
                                <div className="relative">
                                    <Calendar className="text-muted-foreground absolute top-1/2 left-3 h-4 w-4 -translate-y-1/2" />
                                    <Input
                                        type="date"
                                        value={localFilters.date_to}
                                        onChange={(e) => handleFilterChange('date_to', e.target.value)}
                                        className="pl-9"
                                        max={today}
                                        placeholder="Select end date"
                                        min="2015-01-01"
                                    />
                                </div>
                            </div>

                            <div>
                                <label className="text-sm font-medium">Min Amount</label>
                                <Input
                                    type="number"
                                    placeholder="0.00"
                                    value={localFilters.amount_min}
                                    onChange={(e) => handleFilterChange('amount_min', e.target.value)}
                                />
                            </div>

                            <div>
                                <label className="text-sm font-medium">Max Amount</label>
                                <Input
                                    type="number"
                                    placeholder="0.00"
                                    value={localFilters.amount_max}
                                    onChange={(e) => handleFilterChange('amount_max', e.target.value)}
                                />
                            </div>
                        </div>

                        <div className="mt-4 flex justify-end">
                            <Button onClick={clearFilters} variant="outline">
                                Clear Filters ({activeFilterCount})
                            </Button>
                        </div>
                    </CardContent>
                </Card>

                {/* Transactions Table */}
                <Card>
                    <CardHeader>
                        <CardTitle>Transactions</CardTitle>
                    </CardHeader>
                    <CardContent>
                        <div className="overflow-x-auto">
                            <table className="min-w-full border bg-white dark:bg-neutral-900">
                                <thead>
                                    <tr>
                                        <th className="border px-4 py-2 text-left">Transaction ID</th>
                                        <th className="border px-4 py-2 text-left">Description</th>
                                        <th className="border px-4 py-2 text-center">Type</th>
                                        <th className="border px-4 py-2 text-center">Status</th>
                                        <th className="border px-4 py-2 text-center">Method</th>
                                        <th className="border px-4 py-2 text-center">Amount</th>
                                        <th className="border px-4 py-2 text-center">Charge</th>
                                        <th className="border px-4 py-2 text-left">User/Vendor</th>
                                        <th className="border px-4 py-2 text-left">Role</th>
                                        <th className="border px-4 py-2 text-left">Date</th>
                                    </tr>
                                </thead>
                                <tbody className="divide-y divide-gray-200 dark:divide-neutral-700">
                                    {transactions.data.length === 0 ? (
                                        <tr>
                                            <td colSpan={9} className="border px-4 py-8 text-center text-gray-500">
                                                No transactions found.
                                            </td>
                                        </tr>
                                    ) : (
                                        transactions.data.map((transaction) => (
                                            <tr key={transaction.id} className="hover:bg-gray-50 dark:hover:bg-neutral-800">
                                                <td className="border px-4 py-3 font-mono text-sm">{transaction.transaction_id}</td>
                                                <td className="border px-4 py-3 text-sm">{transaction.summery}</td>
                                                <td className="border px-4 py-3 text-center text-sm">
                                                    <Badge className={typeColors[transaction.type] || 'bg-gray-100 text-gray-800'}>
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
                                                    {Number(transaction.amount).toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 })}
                                                </td>
                                                <td className={`border px-4 py-3 text-center text-sm font-medium`}>
                                                    {Number(transaction.charge).toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 })}
                                                </td>
                                                <td className="border px-4 py-3 text-sm">
                                                    {transaction.user ? (
                                                        <div>
                                                            <div className="font-medium">{transaction.user.full_name}</div>
                                                            <div className="text-xs text-gray-500">{transaction.user.email}</div>
                                                        </div>
                                                    ) : transaction.vendor ? (
                                                        <div>
                                                            <div className="font-medium">{transaction.vendor.brand_name_en}</div>
                                                            <div className="text-xs text-gray-500">{transaction.vendor.name}</div>
                                                        </div>
                                                    ) : (
                                                        <span className="text-gray-500">N/A</span>
                                                    )}
                                                </td>
                                                <td className="border px-4 py-3 text-sm capitalize">{transaction.user_type || 'N/A'}</td>
                                                <td className="border px-4 py-3 text-sm text-gray-500">
                                                    {new Date(transaction.created_at).toLocaleDateString()}
                                                </td>
                                            </tr>
                                        ))
                                    )}
                                </tbody>
                            </table>
                        </div>

                        {/* Pagination */}
                        {transactions.last_page > 1 && (
                            <div className="mt-6">
                                <Pagination
                                    currentPage={transactions.current_page}
                                    lastPage={transactions.last_page}
                                    total={transactions.total}
                                    perPage={transactions.per_page}
                                    links={transactions.links}
                                    onPageChange={handlePageChange}
                                />
                            </div>
                        )}
                    </CardContent>
                </Card>
            </div>
        </AppLayout>
    );
}
