import Heading from '@/components/heading';
import { useLanguage } from '@/components/language-context';
import { Alert, AlertDescription } from '@/components/ui/alert';
import { Badge } from '@/components/ui/badge';
import { Button } from '@/components/ui/button';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Dialog, DialogContent, DialogDescription, DialogFooter, DialogHeader, DialogTitle } from '@/components/ui/dialog';
import { Input } from '@/components/ui/input';
import { Pagination } from '@/components/ui/pagination';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select';
import AppLayout from '@/layouts/app-layout';
import { Head, Link, router } from '@inertiajs/react';
import { useState } from 'react';

import { Download } from 'lucide-react';
import { ActionButtonDelete, ActionButtonSuspend } from '@/components/action-button';



interface Ad {
    id: number;
    title_en: string;
    title_ar: string;
    banners: string;
    banners: string;
    link_type: string;
    link_id: number | null;
    external_link: string | null;
    status: 'draft' | 'active' | 'suspended';
    priority: number;
    start_date: string | null;
    end_date: string | null;
    created_at: string;
    description_en: string | null;
    description_ar: string | null;
    product?: { id: number; name_en: string; name_ar: string };
    linkedVendor?: { id: number; name: string; brand_name_en?: string; brand_name_ar?: string; name_en?: string; name_ar?: string };
    expo?: { id: number; title_en: string; title_ar: string };
}

interface SubscriptionInfo {
    hasSubscription: boolean;
    planName: string;
    adLimit: number;
    currentAds: number;
    remainingAds: number;
}

interface VendorAdsIndexProps {
    ads: {
        data: Ad[];
        current_page: number;
        last_page: number;
        total: number;
        per_page: number;
        links: { url: string | null; label: string; active: boolean }[];
    };
    filters: Record<string, string>;
    linkTypeOptions: Array<{ value: string; label: string }>;
    statusOptions: Array<{ value: string; label: string }>;
    products: Array<{ id: number; name_en: string; name_ar: string }>;
    expos: Array<{ id: number; title_en: string; title_ar: string }>;
    subscriptionInfo?: SubscriptionInfo; // Make optional for admin users
    isAdmin?: boolean; // Add flag to identify admin users
}

export default function VendorAdsIndex({ ads, filters, linkTypeOptions, statusOptions, products, expos, subscriptionInfo, isAdmin = false }: VendorAdsIndexProps) {
    const { t } = useLanguage();
    const [fromDate, setFromDate] = useState<string | null>(null);
    const [toDate, setToDate] = useState<string | null>(null);
    const [search] = useState<string | null>(null);
    const [statusFilter] = useState<string | null>(null);
    const [linkTypeFilter] = useState<string | null>(null);
    const [sortBy] = useState<string>('created_at');
    const [sortOrder] = useState<'asc' | 'desc'>('desc');
    const [linkedItem] = useState<string | null>(null);
    const [isExporting, setIsExporting] = useState(false);

    // Check if any filter is active
    const isAnyFilterActive =
        (filters.search && filters.search !== '') ||
        (filters.status && filters.status !== 'all') ||
        (filters.link_type && filters.link_type !== 'all') ||
        fromDate ||
        toDate;

    // Check if user can create ads (admin can always create, vendor needs subscription)
    const canCreateAds = isAdmin || (subscriptionInfo?.hasSubscription && subscriptionInfo?.remainingAds > 0);

    // Function to parse IST date string correctly
    const parseISTDate = (dateStr: string) => {
        if (!dateStr) return '';

        // Parse the date string as IST (not UTC)
        // dateStr format: "2025-08-05 16:00:00"
        const [date, time] = dateStr.split(' ');
        const [year, month, day] = date.split('-').map(Number);
        const [hour, minute, second] = time.split(':').map(Number);

        // Create date in IST timezone
        const istDate = new Date(year, month - 1, day, hour, minute, second);

        return istDate.toLocaleString('en-IN', {
            year: 'numeric',
            month: 'short',
            day: '2-digit',
            hour: '2-digit',
            minute: '2-digit',
            hour12: false,
            timeZone: 'Asia/Kolkata'
        });
    };
    const [confirmDialog, setConfirmDialog] = useState<{ open: boolean; ad: Ad; action: 'activate' | 'suspend' } | null>(null);
    const [selectedAdForDelete, setSelectedAdForDelete] = useState<Ad | null>(null);
    const [deleteDialogOpen, setDeleteDialogOpen] = useState(false);
    const [isDeleting, setIsDeleting] = useState(false);
    const [toggleLoadingId, setToggleLoadingId] = useState<number | null>(null);

    const exportAds = async () => {
        setIsExporting(true);
        try {
            const params = new URLSearchParams();
            if (filters.search) params.append('search', filters.search);
            if (filters.status && filters.status !== 'all') params.append('status', filters.status);
            if (filters.link_type && filters.link_type !== 'all') params.append('link_type', filters.link_type);
            if (filters.from_date) params.append('from_date', filters.from_date);
            if (filters.to_date) params.append('to_date', filters.to_date);
            if (filters.sort_by) params.append('sort_by', filters.sort_by);
            if (filters.sort_order) params.append('sort_order', filters.sort_order);

            const response = await fetch(`/vendor/ads/export?${params.toString()}`);

            if (!response.ok) {
                const errorData = await response.json().catch(() => ({}));
                throw new Error(errorData.message || `Export failed: ${response.status}`);
            }

            // Get the filename from the response headers
            const contentDisposition = response.headers.get('content-disposition');
            let filename = 'ads_export.csv';
            if (contentDisposition) {
                const filenameMatch = contentDisposition.match(/filename="(.+)"/);
                if (filenameMatch) {
                    filename = filenameMatch[1];
                }
            }

            // Create blob and download
            const blob = await response.blob();
            const url = window.URL.createObjectURL(blob);
            const a = document.createElement('a');
            a.href = url;
            a.download = filename;
            document.body.appendChild(a);
            a.click();
            window.URL.revokeObjectURL(url);
            document.body.removeChild(a);
        } catch (error) {
            console.error('Export failed:', error);
            alert(`Export failed: ${error instanceof Error ? error.message : 'Unknown error'}`);
        } finally {
            setIsExporting(false);
        }
    };


    const openDeleteDialog = (ad: Ad) => {
        setSelectedAdForDelete(ad);
        setDeleteDialogOpen(true);
    };

    const handleDelete = async (ad: Ad) => {
        setIsDeleting(true);
        try {
            await router.delete(`/vendor/ads/${ad.id}`, {
                onSuccess: () => {
                    setDeleteDialogOpen(false);
                    setSelectedAdForDelete(null);
                },
                onFinish: () => setIsDeleting(false),
            });
        } catch {
            setIsDeleting(false);
        }
    };

    const confirmToggleStatus = async () => {
        if (!confirmDialog) return;
        setToggleLoadingId(confirmDialog.ad.id);
        try {
            await router.post(`/vendor/ads/${confirmDialog.ad.id}/toggle-status`, {}, {
                onSuccess: () => setConfirmDialog(null),
                onFinish: () => setToggleLoadingId(null),
            });
        } catch {
            setToggleLoadingId(null);
        }
    };

    const getStatusBadge = (status: string, ad: Ad) => {
        const now = new Date();
        // Parse dates as IST to avoid timezone issues
        const startDate = ad.start_date ? (() => {
            const [date, time] = ad.start_date.split(' ');
            const [year, month, day] = date.split('-').map(Number);
            const [hour, minute, second] = time.split(':').map(Number);
            return new Date(year, month - 1, day, hour, minute, second);
        })() : null;
        const endDate = ad.end_date ? (() => {
            const [date, time] = ad.end_date.split(' ');
            const [year, month, day] = date.split('-').map(Number);
            const [hour, minute, second] = time.split(':').map(Number);
            return new Date(year, month - 1, day, hour, minute, second);
        })() : null;

        // Check if ad is currently active based on dates
        const isCurrentlyActive = startDate && endDate && now >= startDate && now <= endDate;
        const isExpired = endDate && now > endDate;
        const isScheduled = startDate && now < startDate;

        let statusDisplay = status;
        let variant: 'secondary' | 'default' | 'destructive' = 'secondary';

        if (status === 'active') {
            if (isCurrentlyActive) {
                statusDisplay = t('ads.live');
                variant = 'default';
            } else if (isExpired) {
                statusDisplay = t('ads.expired');
                variant = 'destructive';
            } else if (isScheduled) {
                statusDisplay = t('ads.scheduled');
                variant = 'default';
            } else {
                variant = 'default';
            }
        } else if (status === 'suspended') {
            variant = 'destructive';
        } else if (status === 'draft') {
            statusDisplay = t('ads.draft');
            variant = 'secondary';
        }

        return <Badge variant={variant}>{statusDisplay}</Badge>;
    };

    const getLinkTypeLabel = (linkType: string) => {
        const option = linkTypeOptions.find((opt) => opt.value === linkType);
        return option?.label || linkType;
    };

    const getLinkedItemName = (ad: Ad) => {
        if (ad.link_type === 'external') {
            return ad.external_link;
        }

        if (ad.link_type === 'vendor' && ad.linkedVendor) {
            return `${ad.linkedVendor.brand_name_en || ad.linkedVendor.name} (${ad.linkedVendor.brand_name_ar || ad.linkedVendor.name_ar || ''})`;
        }

        const item = ad.product || ad.expo;
        if (item) {
            if ('name_en' in item) {
                return `${item.name_en} (${item.name_ar})`;
            } else {
                return `${item.title_en} (${item.title_ar})`;
            }
        }
        return 'N/A';
    };

    return (
        <AppLayout>
            <Head title={t('sidebar.myAds')} />
            <div className="space-y-8 px-2 py-6 md:px-6">
                <div className="mb-2 flex flex-col gap-4 md:flex-row md:items-center md:justify-between">
                    <Heading title={t('sidebar.myAds')} />
                    <Link href={route('vendor.ads.create')}>
                        <Button
                            className="w-full md:w-auto"
                            variant="default"
                            disabled={!canCreateAds}
                        >
                            <span className="inline-flex items-center gap-2">
                                <svg xmlns="http://www.w3.org/2000/svg" className="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 4v16m8-8H4" />
                                </svg>
                                {t('ads.addNewAd')}
                            </span>
                        </Button>
                    </Link>
                </div>

                {/* Subscription Info Alert - Only show for vendor users */}
                {!isAdmin && subscriptionInfo && (
                    <Alert className={subscriptionInfo.hasSubscription ? 'border-green-200 bg-green-50' : 'border-red-200 bg-red-50'}>
                        <AlertDescription>
                            <div className="flex flex-col gap-2 md:flex-row md:items-center md:justify-between">
                                <div>
                                    <strong>{t('ads.currentPlan')}</strong> {subscriptionInfo.planName}
                                    {subscriptionInfo.hasSubscription && (
                                        <span className="ml-4">
                                            <strong>{t('ads.adLimit')}</strong> {subscriptionInfo.currentAds} / {subscriptionInfo.adLimit}(
                                            {subscriptionInfo.remainingAds} {t('ads.remaining')})
                                        </span>
                                    )}
                                </div>
                                {!subscriptionInfo.hasSubscription && (
                                    <Button asChild size="sm" variant="outline">
                                        <Link href="/vendor/subscription">{t('ads.upgradePlan')}</Link>
                                    </Button>
                                )}
                            </div>
                        </AlertDescription>
                    </Alert>
                )}

                <div className="flex flex-col justify-end gap-2 sm:flex-row sm:items-center">
                    <div>
                        <Input
                            placeholder={t('ads.searchAds')}
                            value={filters.search || ''}
                            onChange={(e) => router.get('/vendor/ads', { ...filters, search: e.target.value }, { preserveState: true })}
                        />
                    </div>
                    <div className="w-40">
                        <Select
                            value={filters.status || 'all'}
                            onValueChange={(value) => router.get('/vendor/ads', { ...filters, status: value }, { preserveState: true })}
                        >
                            <SelectTrigger>
                                <SelectValue />
                            </SelectTrigger>
                            <SelectContent>
                                <SelectItem value="all">{t('ads.allStatus')}</SelectItem>
                                {statusOptions.map((option) => (
                                    <SelectItem key={option.value} value={option.value}>
                                        {option.label}
                                    </SelectItem>
                                ))}
                            </SelectContent>
                        </Select>
                    </div>
                    <div className="w-40">
                        <Select
                            value={filters.link_type || 'all'}
                            onValueChange={(value) => router.get('/vendor/ads', { ...filters, link_type: value }, { preserveState: true })}
                        >
                            <SelectTrigger>
                                <SelectValue />
                            </SelectTrigger>
                            <SelectContent>
                                <SelectItem value="all">{t('ads.allTypes')}</SelectItem>
                                {linkTypeOptions.map((option) => (
                                    <SelectItem key={option.value} value={option.value}>
                                        {option.label}
                                    </SelectItem>
                                ))}
                            </SelectContent>
                        </Select>
                    </div>
                    <div className="flex items-center gap-2">
                        <Input
                            type="date"
                            value={fromDate || ""}
                            onChange={(e) => {
                                setFromDate(e.target.value);
                                router.get('/vendor/ads', {
                                    search,
                                    status: statusFilter,
                                    link_type: linkTypeFilter,
                                    sort_by: sortBy,
                                    sort_order: sortOrder,
                                    from_date: e.target.value,
                                    to_date: toDate,
                                    linked_item: linkedItem,
                                }, { preserveState: true });
                            }}
                            className="w-40"
                        />
                        <Input
                            type="date"
                            value={toDate || ""}
                            min={fromDate || undefined}
                            onChange={(e) => {
                                setToDate(e.target.value);
                                router.get('/vendor/ads', {
                                    search,
                                    status: statusFilter,
                                    link_type: linkTypeFilter,
                                    sort_by: sortBy,
                                    sort_order: sortOrder,
                                    from_date: fromDate,
                                    to_date: e.target.value,
                                    linked_item: linkedItem,
                                }, { preserveState: true });
                            }}
                            className="w-40"
                        />
                        <Button onClick={exportAds} variant="outline" disabled={isExporting}>
                            <Download className="mr-2 h-4 w-4" />
                            {isExporting ? t('ads.exporting') : t('ads.exportCsv')}
                        </Button>
                        {isAnyFilterActive && (
                            <Button
                                variant="ghost"
                                onClick={() => {
                                    setFromDate(null);
                                    setToDate(null);
                                    router.get('/vendor/ads', {
                                        search: '',
                                        status: 'all',
                                        link_type: 'all',
                                        sort_by: sortBy,
                                        sort_order: sortOrder,
                                        from_date: '',
                                        to_date: '',
                                        linked_item: '',
                                    }, { preserveState: false });
                                }}
                            >
                                {t('products.clearFilters')}
                            </Button>
                        )}
                    </div>
                </div>

                {/* Ads Table */}
                <Card className="border-border rounded-xl border shadow-md">
                    <CardHeader className="pb-2">
                        <CardTitle className="text-lg font-semibold">
                            {t('sidebar.myAds')} <span className="text-muted-foreground font-normal">({ads.total})</span>
                        </CardTitle>
                    </CardHeader>
                    <CardContent>
                        <div className="overflow-x-auto rounded-lg">
                            <table className="w-full border-separate border-spacing-y-1 text-sm">
                                <thead>
                                    <tr className="bg-muted/60 dark:bg-muted/40 text-muted-foreground">
                                        <th className="rounded-tl-lg p-3 text-left">{t('ads.banner')}</th>
                                        <th className="p-3 text-left">{t('ads.titleEn')}</th>
                                        <th className="p-3 text-left">{t('ads.titleAr')}</th>
                                        <th className="p-3 text-left">{t('ads.linkType')}</th>
                                        <th className="p-3 text-left">{t('ads.linkedItem')}</th>
                                        <th className="p-3 text-left">{t('common.status')}</th>
                                        <th className="p-3 text-left">{t('ads.priority')}</th>
                                        <th className="p-3 text-left">{t('ads.dates')}</th>
                                        <th className="rounded-tr-lg p-3 text-left">{t('common.actions')}</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    {ads.data.map((ad) => (
                                        <tr key={ad.id} className="bg-card dark:bg-muted/60 hover:bg-muted/30 border-border rounded-lg border shadow-sm transition">
                                            <td className="p-3 align-middle">
                                                <div className="border-border bg-muted flex h-12 w-20 items-center justify-center overflow-hidden rounded-lg border">
                                                    {ad.banners ? (
                                                        <img
                                                            src={ad.banners}
                                                            alt={ad.title_en}
                                                            className="h-full w-full object-cover"
                                                        />
                                                    ) : (
                                                        <span className="text-muted-foreground text-xs">{t('ads.noImage')}</span>
                                                    )}
                                                </div>
                                            </td>
                                            <td className="p-3 align-middle font-medium">{ad.title_en}</td>
                                            <td className="p-3 align-middle font-medium">{ad.title_ar}</td>
                                            <td className="p-3 align-middle">
                                                <Badge variant="outline">{getLinkTypeLabel(ad.link_type)}</Badge>
                                            </td>
                                            <td className="text-muted-foreground max-w-xs truncate p-3 align-middle text-xs">
                                                {getLinkedItemName(ad)}
                                            </td>
                                            <td className="p-3 align-middle">{getStatusBadge(ad.status, ad)}</td>
                                            <td className="p-3 align-middle">{ad.priority}</td>
                                            <td className="p-3 align-middle text-center">
                                                {ad.start_date && ad.end_date ? (
                                                    <div className="text-sm">
                                                        <div className="font-medium">
                                                            {parseISTDate(ad.start_date)}
                                                        </div>
                                                        <div className="text-muted-foreground text-xs">{t('ads.dateRangeTo')}</div>
                                                        <div className="font-medium">
                                                            {parseISTDate(ad.end_date)}
                                                        </div>
                                                    </div>
                                                ) : (
                                                    <span className="text-muted-foreground text-sm">{t('ads.noDateRange')}</span>
                                                )}
                                            </td>



                                            <td className="p-3 align-middle">
                                                <div className="flex items-center gap-2">
                                                    <ActionButtonSuspend
                                                        variant={ad.status === 'active' ? 'outline' : 'default'}
                                                        onClick={() => setConfirmDialog({ open: true, ad, action: ad.status === 'suspended' ? 'activate' : 'suspend' })}
                                                        btnTitle={ad.status === 'active' ? t('products.suspend') : t('products.activate')}
                                                    />
                                                    <Link href={route('vendor.ads.edit', ad.id)}>
                                                        <Button
                                                            variant="outline"
                                                            size="sm"
                                                            className="rounded-md"
                                                        >
                                                            {t('common.edit')}
                                                        </Button>
                                                    </Link>
                                                    <ActionButtonDelete btnTitle={t('common.delete')} onClick={() => openDeleteDialog(ad)} />

                                                </div>
                                            </td>
                                        </tr>
                                    ))}
                                </tbody>
                            </table>
                        </div>

                        {/* Pagination */}
                        <div className="mt-6">
                            <Pagination
                                currentPage={ads.current_page}
                                lastPage={ads.last_page}
                                total={ads.total}
                                perPage={ads.per_page}
                                links={ads.links}
                            />
                        </div>
                    </CardContent>
                </Card>
            </div>



            {/* Confirm Suspend/Activate Dialog */}
            {confirmDialog && (
                <Dialog open={confirmDialog.open} onOpenChange={(open) => setConfirmDialog(confirmDialog ? { ...confirmDialog, open } : null)}>
                    <DialogContent>
                        <DialogHeader>
                            <DialogTitle>{confirmDialog.action === 'activate' ? t('ads.activateAd') : t('ads.suspendAd')}</DialogTitle>
                        </DialogHeader>
                        <div className="py-4">
                            <p>
                                {confirmDialog.action === 'activate'
                                    ? t('ads.confirmActivateAd')
                                    : t('ads.confirmSuspendAd')}
                            </p>
                        </div>
                        <DialogFooter>
                            <Button variant="outline" onClick={() => setConfirmDialog(null)}>
                                {t('common.cancel')}
                            </Button>
                            <Button
                                variant={confirmDialog.action === 'activate' ? 'default' : 'destructive'}
                                onClick={confirmToggleStatus}
                                disabled={toggleLoadingId === confirmDialog.ad.id}
                            >
                                {toggleLoadingId === confirmDialog.ad.id
                                    ? (confirmDialog.action === 'activate' ? t('ads.activating') : t('ads.suspending'))
                                    : (confirmDialog.action === 'activate' ? t('products.activate') : t('products.suspend'))}
                            </Button>
                        </DialogFooter>
                    </DialogContent>
                </Dialog>
            )}

            {/* Delete Confirmation Dialog */}
            <Dialog open={deleteDialogOpen && !!selectedAdForDelete} onOpenChange={(open) => {
                if (!open) {
                    setDeleteDialogOpen(false);
                    setSelectedAdForDelete(null);
                }
            }}>
                <DialogContent>
                    <DialogHeader>
                        <DialogTitle>{t('ads.confirmDeletion')}</DialogTitle>
                    </DialogHeader>
                    <div className="py-4">
                        <p>{t('ads.confirmDeleteAd')}</p>
                        {selectedAdForDelete && (
                            <p className="mt-2 text-sm text-gray-600">
                                <strong>{t('ads.adLabel')}:</strong> {selectedAdForDelete.title_en}
                            </p>
                        )}
                    </div>
                    <DialogFooter>
                        <Button variant="outline" onClick={() => {
                            setDeleteDialogOpen(false);
                            setSelectedAdForDelete(null);
                        }} disabled={isDeleting}>
                            {t('common.cancel')}
                        </Button>
                        <Button variant="destructive" onClick={() => selectedAdForDelete && handleDelete(selectedAdForDelete)} disabled={isDeleting}>
                            {isDeleting ? t('ads.deleting') : t('common.delete')}
                        </Button>
                    </DialogFooter>
                </DialogContent>
            </Dialog>
        </AppLayout>
    );
}
