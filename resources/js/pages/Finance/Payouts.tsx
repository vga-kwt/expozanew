import { Input } from '@/components/ui/input';
import { StatusFilter } from '@/components/ui/StatusFilter';
import { Head, Link, router } from '@inertiajs/react';
import { AlertCircle, ArrowLeft, Calendar, CheckCircle, Clock, CreditCard, Wallet, Download, Filter, Search, XCircle, Play } from 'lucide-react';
import React, { useCallback, useState, useRef, useEffect } from 'react';
import { toast } from 'react-hot-toast';
import { Pagination } from '../../components/Pagination';
import { Badge } from '../../components/ui/badge';
import { Button } from '../../components/ui/button';
import { Card, CardContent, CardHeader, CardTitle } from '../../components/ui/card';
import { Dialog, DialogContent, DialogFooter, DialogHeader, DialogTitle } from '../../components/ui/dialog';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '../../components/ui/select';
import { Textarea } from '../../components/ui/textarea';
import AppLayout from '../../layouts/app-layout';

interface VendorPayout {
    id: number;
    payout_id: string;
    vendor_id: number;
    status: 'pending' | 'approved' | 'completed' | 'rejected' | 'cancelled';
    amount: number;
    currency: string;
    payment_method: string;
    account_details: string;
    summary: string;
    scheduled_date: string;
    processed_date?: string;
    transaction_reference_id?: string;
    approved_by?: number;
    approved_at?: string;
    notes?: string;
    created_at: string;
    vendor?: { name: string; brand_name_en: string };
    approvedBy?: { full_name: string };
    metadata?: {
        period_start?: string;
        period_end?: string;
        total_earnings?: number;
        commission_rate?: number;
        orders_count?: number;
        generated_at?: string;
    };
}

interface PayoutStatistics {
    total_payouts: number;
    total_amount: number;
    status_breakdown: Record<string, number>;
    pending_amount: number;
    completed_amount: number;
    approved_amount: number;
    rejected_amount: number;
    cancelled_amount: number;
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
    statistics: PayoutStatistics;
    vendors: Array<{ id: number; name: string }>;
    filters: {
        search?: string;
        status?: string;
        payment_method?: string;
        currency?: string;
        vendor_id?: string;
        date_from?: string;
        date_to?: string;
        amount_min?: string;
        amount_max?: string;
    };
    paymentMethods: Record<string, string>;
}

const statusColors: Record<string, string> = {
    pending: 'bg-yellow-50 text-yellow-700 border border-yellow-200 dark:bg-yellow-900/20 dark:text-yellow-400 dark:border-yellow-800',
    approved: 'bg-blue-50 text-blue-700 border border-blue-200 dark:bg-blue-900/20 dark:text-blue-400 dark:border-blue-800',
    completed: 'bg-emerald-50 text-emerald-700 border border-emerald-200 dark:bg-emerald-900/20 dark:text-emerald-400 dark:border-emerald-800',
    rejected: 'bg-rose-50 text-rose-700 border border-rose-200 dark:bg-rose-900/20 dark:text-rose-400 dark:border-rose-800',
    cancelled: 'bg-slate-50 text-slate-700 border border-slate-200 dark:bg-slate-900/20 dark:text-slate-400 dark:border-slate-800',
};

const statusIcons: Record<string, React.ReactNode> = {
    pending: <Clock className="h-4 w-4" />,
    approved: <CheckCircle className="h-4 w-4" />,
    completed: <CheckCircle className="h-4 w-4" />,
    rejected: <XCircle className="h-4 w-4" />,
    cancelled: <AlertCircle className="h-4 w-4" />,
};

const paymentProcessorColors: Record<string, string> = {
    knet: 'bg-indigo-50 text-indigo-700 border border-indigo-200 dark:bg-indigo-900/20 dark:text-indigo-400 dark:border-indigo-800',
    card: 'bg-sky-50 text-sky-700 border border-sky-200 dark:bg-sky-900/20 dark:text-sky-400 dark:border-sky-800',
    myfatoorah: 'bg-amber-50 text-amber-700 border border-amber-200 dark:bg-amber-900/20 dark:text-amber-400 dark:border-amber-800',
};

function capitalizeFirst(str: string) {
    return str.charAt(0).toUpperCase() + str.slice(1).toLowerCase();
}


export default function PayoutsPage({ payouts, statistics, vendors, filters, paymentMethods, flash }: Props & { flash?: { success?: string; error?: string } }) {
    useEffect(() => {
        if (flash?.success) {
            toast.success(flash.success);
        }
        if (flash?.error) {
            toast.error(flash.error);
        }
    }, [flash?.success, flash?.error]);

    const [localFilters, setLocalFilters] = useState({
        search: filters.search || '',
        status: filters.status || 'all',
        payment_method: filters.payment_method || 'all',
        currency: filters.currency || 'all',
        vendor_id: filters.vendor_id || 'all',
        date_from: filters.date_from || '',
        date_to: filters.date_to || '',
        amount_min: filters.amount_min || '',
        amount_max: filters.amount_max || '',
    });

    const [actionDialog, setActionDialog] = useState<{
        open: boolean;
        action: 'approve' | 'complete' | 'reject' | 'cancel' | null;
        payout: VendorPayout | null;
    }>({
        open: false,
        action: null,
        payout: null,
    });

    const [generateDialog, setGenerateDialog] = useState(false);
    const [generating, setGenerating] = useState(false);

    const [formData, setFormData] = useState({
        transaction_reference_id: '',
        notes: '',
    });

    const searchTimeoutRef = useRef<NodeJS.Timeout | null>(null);

    const applyFilters = useCallback((newFilters: typeof localFilters) => {
        const params = { ...newFilters } as Record<string, string>;
        Object.keys(params).forEach((key) => {
            if (params[key] === 'all' || params[key] === '') delete params[key];
        });
        router.get(route('finance.payouts'), params);
    }, []);

    // Debounced search function
    const debouncedSearch = useCallback((searchTerm: string) => {
        if (searchTimeoutRef.current) {
            clearTimeout(searchTimeoutRef.current);
        }
        searchTimeoutRef.current = setTimeout(() => {
            const newFilters = { ...localFilters, search: searchTerm };
            applyFilters(newFilters);
        }, 500);
    }, [localFilters, applyFilters]);

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
            status: 'all',
            payment_method: 'all',
            currency: 'all',
            vendor_id: 'all',
            date_from: '',
            date_to: '',
            amount_min: '',
            amount_max: '',
        });
        router.get(route('finance.payouts'), {});
    };

    const exportPayouts = () => {
        const params = new URLSearchParams(localFilters);
        window.open(`${route('finance.payouts.export')}?${params.toString()}`, '_blank');
    };

    const formatCurrency = (amount: number, currency: string = 'USD') => {
        return new Intl.NumberFormat('en-US', {
            style: 'currency',
            currency: currency,
        }).format(amount);
    };

    const handlePageChange = (page: number) => {
        const params = { ...localFilters, page } as Record<string, string | number>;
        Object.keys(params).forEach((key) => {
            if (params[key] === 'all' || params[key] === '') delete params[key];
        });
        router.get(route('finance.payouts'), params);
    };

    // Get today's date for max constraint
    const today = new Date().toISOString().split('T')[0];

    // Count active filters
    const activeFilterCount = Object.values(localFilters).filter((value) => value !== '' && value !== 'all').length;

    const openActionDialog = (payout: VendorPayout, action: 'approve' | 'complete' | 'reject' | 'cancel') => {
        setActionDialog({ open: true, action, payout });
        setFormData({ transaction_reference_id: '', notes: '' });
    };

    const closeActionDialog = () => {
        setActionDialog({ open: false, action: null, payout: null });
        setFormData({ transaction_reference_id: '', notes: '' });
    };

    const handleAction = () => {
        if (!actionDialog.payout || !actionDialog.action) return;

        const { payout, action } = actionDialog;
        const routeMap = {
            approve: route('finance.payouts.approve', payout.id),
            complete: route('finance.payouts.complete', payout.id),
            reject: route('finance.payouts.reject', payout.id),
            cancel: route('finance.payouts.cancel', payout.id),
        };

        const data =
            action === 'approve' ? { transaction_reference_id: formData.transaction_reference_id, notes: formData.notes } : { notes: formData.notes };

        router.post(routeMap[action], data, {
            onSuccess: () => {
                closeActionDialog();
            },
        });
    };

    const getActionButton = (payout: VendorPayout) => {
        switch (payout.status) {
            case 'pending':
                return (
                    <div className="flex gap-1">
                        <Button size="sm" onClick={() => openActionDialog(payout, 'approve')} className="bg-blue-600 hover:bg-blue-700">
                            Approve
                        </Button>
                        <Button size="sm" variant="outline" onClick={() => openActionDialog(payout, 'reject')}>
                            Reject
                        </Button>
                    </div>
                );
            case 'approved':
                return (
                    <Button size="sm" onClick={() => openActionDialog(payout, 'complete')} className="bg-green-600 hover:bg-green-700">
                        Complete
                    </Button>
                );
            case 'completed':
                return <Badge className="bg-green-100 text-green-800">Completed</Badge>;
            case 'rejected':
                return <Badge className="bg-red-100 text-red-800">Rejected</Badge>;
            case 'cancelled':
                return <Badge className="bg-gray-100 text-gray-800">Cancelled</Badge>;
            default:
                return null;
        }
    };

    return (
        <AppLayout>
            <Head title="Payouts - Expoza" />

            <div className="space-y-6 p-6">
                {/* Header */}
                <div className="flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between">
                    <div>
                        <h1 className="text-2xl font-bold">Vendor Payouts</h1>
                        <p className="text-sm text-gray-600 dark:text-gray-400">Manage vendor payouts and payment processing</p>
                    </div>
                    <div className="flex gap-2">
                        <Button
                            onClick={() => setGenerateDialog(true)}
                            className="bg-green-600 hover:bg-green-700 text-white"
                        >
                            <Play className="mr-2 h-4 w-4" />
                            Generate Payouts
                        </Button>
                        <Button onClick={exportPayouts} variant="outline">
                            <Download className="mr-2 h-4 w-4" />
                            Export CSV
                        </Button>
                        <Link href={route('finance.index')}>
                            <Button variant="outline">
                                <ArrowLeft className="mr-2 h-4 w-4" />
                                Back to Finance
                            </Button>
                        </Link>
                    </div>
                </div>

                {/* Statistics Cards */}
                <div className="grid grid-cols-1 gap-4 md:grid-cols-2 lg:grid-cols-4">
                    <Card>
                        <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                            <CardTitle className="text-sm font-medium">Total Payouts</CardTitle>
                            <Wallet className="text-muted-foreground h-4 w-4" />
                        </CardHeader>
                        <CardContent>
                            <div
                                className={`text-2xl font-bold ${statistics?.total_amount < 0 ? 'text-red-600' : statistics?.total_amount > 0 ? 'text-green-600' : ''}`}
                            >
                                {(statistics?.total_amount || 0).toLocaleString()}
                            </div>
                            <p className="text-muted-foreground text-xs">{statistics?.total_payouts || 0} payouts</p>
                        </CardContent>
                    </Card>

                    <Card>
                        <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                            <CardTitle className="text-sm font-medium">Pending Payouts</CardTitle>
                            <Clock className="text-muted-foreground h-4 w-4" />
                        </CardHeader>
                        <CardContent>
                            <div
                                className={`text-2xl font-bold ${statistics?.pending_amount < 0 ? 'text-red-600' : statistics?.pending_amount > 0 ? 'text-green-600' : ''}`}
                            >
                                {(statistics?.pending_amount || 0).toLocaleString()}
                            </div>
                            <p className="text-muted-foreground text-xs">Awaiting approval</p>
                        </CardContent>
                    </Card>

                    <Card>
                        <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                            <CardTitle className="text-sm font-medium">Completed Payouts</CardTitle>
                            <CheckCircle className="text-muted-foreground h-4 w-4" />
                        </CardHeader>
                        <CardContent>
                            <div
                                className={`text-2xl font-bold ${statistics?.completed_amount < 0 ? 'text-red-600' : statistics?.completed_amount > 0 ? 'text-green-600' : ''}`}
                            >
                                {(statistics?.completed_amount || 0).toLocaleString()}
                            </div>
                            <p className="text-muted-foreground text-xs">Successfully processed</p>
                        </CardContent>
                    </Card>

                    <Card>
                        <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                            <CardTitle className="text-sm font-medium">Approved Payouts</CardTitle>
                            <CreditCard className="text-muted-foreground h-4 w-4" />
                        </CardHeader>
                        <CardContent>
                            <div
                                className={`text-2xl font-bold ${statistics?.approved_amount < 0 ? 'text-red-600' : statistics?.approved_amount > 0 ? 'text-green-600' : ''}`}
                            >
                                {(statistics?.approved_amount || 0).toLocaleString()}
                            </div>
                            <p className="text-muted-foreground text-xs">Ready for processing</p>
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
                                        placeholder="Search payouts..."
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
                                        { value: 'approved', label: 'Approved' },
                                        { value: 'completed', label: 'Completed' },
                                        { value: 'rejected', label: 'Rejected' },
                                        { value: 'cancelled', label: 'Cancelled' },
                                    ]}
                                    placeholder="Filter by status"
                                    className="w-80"
                                />
                            </div>

                            <div>
                                <label className="text-sm font-medium">Payment Method</label>
                                <Select value={localFilters.payment_method} onValueChange={(value) => handleFilterChange('payment_method', value)}>
                                    <SelectTrigger>
                                        <SelectValue placeholder="All Methods" />
                                    </SelectTrigger>
                                    <SelectContent>
                                        <SelectItem value="all">All Methods</SelectItem>
                                        {Object.entries(paymentMethods).map(([key, label]) => (
                                            <SelectItem key={key} value={key}>
                                                {label}
                                            </SelectItem>
                                        ))}
                                    </SelectContent>
                                </Select>
                            </div>

                            <div>
                                <label className="text-sm font-medium">Vendor</label>
                                <Select value={localFilters.vendor_id} onValueChange={(value) => handleFilterChange('vendor_id', value)}>
                                    <SelectTrigger>
                                        <SelectValue placeholder="All Vendors" />
                                    </SelectTrigger>
                                    <SelectContent>
                                        <SelectItem value="all">All Vendors</SelectItem>
                                        {vendors.map((vendor) => (
                                            <SelectItem key={vendor.id} value={vendor.id.toString()}>
                                                {vendor.name}
                                            </SelectItem>
                                        ))}
                                    </SelectContent>
                                </Select>
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
                                        min="2015-01-01"
                                        placeholder="Select end date"
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

                {/* Payouts Table */}
                <Card>
                    <CardHeader>
                        <CardTitle>Payouts</CardTitle>
                    </CardHeader>
                    <CardContent>
                        <div className="overflow-x-auto">
                            <table className="min-w-full border bg-white dark:bg-neutral-900">
                                <thead>
                                    <tr>
                                        <th className="border px-4 py-2 text-left">Payout ID</th>
                                        <th className="border px-4 py-2 text-left">Vendor</th>
                                        <th className="border px-4 py-2 text-center">Status</th>
                                        <th className="border px-4 py-2 text-center">Payout Amount</th>
                                        <th className="border px-4 py-2 text-center">Total Sales</th>
                                        <th className="border px-4 py-2 text-center">Commission</th>
                                        <th className="border px-4 py-2 text-center">Payment Method</th>
                                        <th className="border px-4 py-2 text-left">Scheduled Date</th>
                                        <th className="border px-4 py-2 text-left">Actions</th>
                                    </tr>
                                </thead>
                                <tbody className="divide-y divide-gray-200 dark:divide-neutral-700">
                                    {payouts.data.length === 0 ? (
                                        <tr>
                                            <td colSpan={9} className="border px-4 py-8 text-center text-gray-500">
                                                No payouts found.
                                            </td>
                                        </tr>
                                    ) : (
                                        payouts.data.map((payout) => {
                                            // Calculate commission breakdown from metadata
                                            const totalEarnings = payout.metadata?.total_earnings || 0;
                                            const commissionRate = payout.metadata?.commission_rate || 0;
                                            const payoutAmount = Number(payout.amount) || 0;

                                            // If we have total_earnings and commission_rate, calculate breakdown
                                            // Otherwise, calculate from payout amount (vendor gets payout, platform keeps commission)
                                            let totalSales = 0;
                                            let platformCommission = 0;

                                            if (totalEarnings > 0 && commissionRate > 0) {
                                                // total_earnings is vendor earnings (after commission)
                                                // total_sales = total_earnings / (1 - commission_rate/100)
                                                totalSales = totalEarnings / (1 - (commissionRate / 100));
                                                platformCommission = totalSales - totalEarnings;
                                            } else if (payoutAmount > 0 && commissionRate > 0) {
                                                // Calculate from payout amount
                                                totalSales = payoutAmount / (1 - (commissionRate / 100));
                                                platformCommission = totalSales - payoutAmount;
                                            }

                                            return (
                                                <tr key={payout.id} className="hover:bg-gray-50 dark:hover:bg-neutral-800">
                                                    <td className="border px-4 py-3 font-mono text-sm">{payout.payout_id}</td>
                                                    <td className="border px-4 py-3 text-sm">
                                                        {payout.vendor ? (
                                                            <div>
                                                                <div className="font-medium">{payout.vendor.brand_name_en}</div>
                                                                <div className="text-xs text-gray-500">{payout.vendor.name}</div>
                                                            </div>
                                                        ) : (
                                                            <span className="text-gray-500">N/A</span>
                                                        )}
                                                    </td>
                                                    <td className="border px-4 py-3 text-center text-sm">
                                                        <Badge className={statusColors[payout.status] || 'bg-gray-100 text-gray-800'}>
                                                            <div className="flex items-center gap-1">
                                                                {statusIcons[payout.status]}
                                                                {capitalizeFirst(payout.status)}
                                                            </div>
                                                        </Badge>
                                                    </td>
                                                    <td className="border px-4 py-3 text-center text-sm font-medium text-green-600">
                                                        {formatCurrency(payoutAmount, payout.currency || 'KWD')}
                                                        <div className="text-xs text-gray-500 mt-1">Vendor Receives</div>
                                                    </td>
                                                    <td className="border px-4 py-3 text-center text-sm">
                                                        {totalSales > 0 ? (
                                                            <>
                                                                <div className="font-medium">{formatCurrency(totalSales, payout.currency || 'KWD')}</div>
                                                                <div className="text-xs text-gray-500 mt-1">Gross Sales</div>
                                                            </>
                                                        ) : (
                                                            <span className="text-gray-400 text-xs">N/A</span>
                                                        )}
                                                    </td>
                                                    <td className="border px-4 py-3 text-center text-sm">
                                                        {platformCommission > 0 && commissionRate > 0 ? (
                                                            <>
                                                                <div className="font-medium text-red-600">{formatCurrency(platformCommission, payout.currency || 'KWD')}</div>
                                                                <div className="text-xs text-gray-500 mt-1">{commissionRate}% Commission</div>
                                                            </>
                                                        ) : (
                                                            <span className="text-gray-400 text-xs">N/A</span>
                                                        )}
                                                    </td>
                                                    <td className="border px-4 py-3 text-sm text-center">
                                                        <Badge
                                                            className={paymentProcessorColors[payout.payment_method ?? ''] || 'bg-gray-100 text-gray-800'}
                                                        >
                                                            {capitalizeFirst(payout.payment_method ?? '')}
                                                        </Badge>
                                                    </td>
                                                    <td className="border px-4 py-3 text-sm text-gray-500">
                                                        {new Date(payout.scheduled_date).toLocaleDateString()}
                                                    </td>
                                                    <td className="border px-4 py-3 text-sm">{getActionButton(payout)}</td>
                                                </tr>
                                            );
                                        })
                                    )}
                                </tbody>
                            </table>
                        </div>

                        {/* Pagination */}
                        {payouts.last_page > 1 && (
                            <div className="mt-6">
                                <Pagination
                                    currentPage={payouts.current_page}
                                    lastPage={payouts.last_page}
                                    total={payouts.total}
                                    perPage={payouts.per_page}
                                    links={payouts.links}
                                    onPageChange={handlePageChange}
                                />
                            </div>
                        )}
                    </CardContent>
                </Card>

                {/* Generate Payouts Dialog */}
                <Dialog open={generateDialog} onOpenChange={setGenerateDialog}>
                    <DialogContent>
                        <DialogHeader>
                            <DialogTitle>Generate Vendor Payouts</DialogTitle>
                        </DialogHeader>
                        <div className="space-y-4 py-4">
                            <p className="text-sm text-gray-600 dark:text-gray-400">
                                Are you sure you want to generate payouts for all vendors?
                            </p>
                            <div className="bg-blue-50 dark:bg-blue-900/20 border border-blue-200 dark:border-blue-800 rounded-lg p-4">
                                <p className="text-sm text-blue-800 dark:text-blue-300">
                                    <strong>Note:</strong> This will create payouts based on the current payout frequency setting configured in Platform Settings.
                                </p>
                            </div>
                            <div className="bg-yellow-50 dark:bg-yellow-900/20 border border-yellow-200 dark:border-yellow-800 rounded-lg p-4">
                                <p className="text-sm text-yellow-800 dark:text-yellow-300">
                                    <strong>Warning:</strong> Only vendors with pending earnings will have payouts created. Existing payouts for the same period will be skipped.
                                </p>
                            </div>
                        </div>
                        <DialogFooter>
                            <Button
                                variant="outline"
                                onClick={() => setGenerateDialog(false)}
                                disabled={generating}
                            >
                                Cancel
                            </Button>
                            <Button
                                onClick={() => {
                                    setGenerating(true);
                                    router.post(route('finance.payouts.generate'), {}, {
                                        onSuccess: () => {
                                            setGenerateDialog(false);
                                            setGenerating(false);
                                        },
                                        onError: () => {
                                            setGenerating(false);
                                        },
                                        onFinish: () => {
                                            setGenerating(false);
                                        }
                                    });
                                }}
                                className="bg-green-600 hover:bg-green-700 text-white"
                                disabled={generating}
                            >
                                {generating ? (
                                    <>
                                        <Clock className="mr-2 h-4 w-4 animate-spin" />
                                        Generating...
                                    </>
                                ) : (
                                    <>
                                        <Play className="mr-2 h-4 w-4" />
                                        Generate Payouts
                                    </>
                                )}
                            </Button>
                        </DialogFooter>
                    </DialogContent>
                </Dialog>

                {/* Action Dialog */}
                <Dialog open={actionDialog.open} onOpenChange={closeActionDialog}>
                    <DialogContent>
                        <DialogHeader>
                            <DialogTitle>
                                {actionDialog.action === 'approve' && 'Approve Payout'}
                                {actionDialog.action === 'complete' && 'Complete Payout'}
                                {actionDialog.action === 'reject' && 'Reject Payout'}
                                {actionDialog.action === 'cancel' && 'Cancel Payout'}
                            </DialogTitle>
                        </DialogHeader>
                        <div className="space-y-4">
                            {actionDialog.payout && (
                                <div className="space-y-2">
                                    <div className="flex justify-between">
                                        <span className="font-medium">Payout ID:</span>
                                        <span className="font-mono">{actionDialog.payout.payout_id}</span>
                                    </div>
                                    <div className="flex justify-between">
                                        <span className="font-medium">Amount:</span>
                                        <span>
                                            {formatCurrency(actionDialog.payout.amount, actionDialog.payout.currency).replace(/[^0-9.,-]/g, '')}
                                        </span>
                                    </div>
                                    <div className="flex justify-between">
                                        <span className="font-medium">Vendor:</span>
                                        <span>{actionDialog.payout.vendor?.name || 'N/A'}</span>
                                    </div>
                                </div>
                            )}

                            {actionDialog.action === 'approve' && (
                                <div>
                                    <label className="text-sm font-medium">Transaction Reference ID *</label>
                                    <Input
                                        value={formData.transaction_reference_id}
                                        onChange={(e) => setFormData((prev) => ({ ...prev, transaction_reference_id: e.target.value }))}
                                        placeholder="Enter transaction reference ID"
                                    />
                                </div>
                            )}

                            <div>
                                <label className="text-sm font-medium">Notes</label>
                                <Textarea
                                    value={formData.notes}
                                    onChange={(e) => setFormData((prev) => ({ ...prev, notes: e.target.value }))}
                                    placeholder="Add notes (optional)"
                                    rows={3}
                                />
                            </div>
                        </div>
                        <DialogFooter>
                            <Button variant="outline" onClick={closeActionDialog}>
                                Cancel
                            </Button>
                            <Button onClick={handleAction}>
                                {actionDialog.action === 'approve' && 'Approve'}
                                {actionDialog.action === 'complete' && 'Complete'}
                                {actionDialog.action === 'reject' && 'Reject'}
                                {actionDialog.action === 'cancel' && 'Cancel'}
                            </Button>
                        </DialogFooter>
                    </DialogContent>
                </Dialog>
            </div>
        </AppLayout>
    );
}
