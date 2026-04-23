import { useState, useEffect } from 'react';
import { Head, usePage, router } from '@inertiajs/react';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select';
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogFooter } from '@/components/ui/dialog';
import { Badge } from '@/components/ui/badge';
import { Pagination } from '@/components/ui/pagination';
import AppLayout from '@/layouts/app-layout';
import { Link } from '@inertiajs/react';
import { toast } from 'react-hot-toast';
import { StatusFilter } from '@/components/ui/StatusFilter';

interface CmsPage {
    id: number;
    title_en: string;
    title_ar: string;
    slug: string;
    status: 'active' | 'suspended' | 'draft';
    meta_title?: string;
    meta_description?: string;
    meta_keywords?: string;
    created_at: string;
    updated_at: string;
}

interface Props {
    pages: {
        data: CmsPage[];
        current_page: number;
        last_page: number;
        per_page: number;
        total: number;
        links: { url: string | null; label: string; active: boolean }[];
    };
    filters: {
        search?: string;
        status?: string;
    };
    hasActiveFilters: boolean;
    activeFilterCount: number;
    [key: string]: unknown;
}

function CmsPagesIndex() {
    const { pages, filters, hasActiveFilters, activeFilterCount } = usePage<Props>().props;
    const [search, setSearch] = useState(filters?.search || '');
    const [status, setStatus] = useState(filters?.status || '');
    const [deleteId, setDeleteId] = useState<number | null>(null);
    const [isDeleting, setIsDeleting] = useState(false);
    const [isFiltering, setIsFiltering] = useState(false);
    const [suspendDialogOpen, setSuspendDialogOpen] = useState(false);
    const [pageToSuspend, setPageToSuspend] = useState<CmsPage | null>(null);
    const [isSuspending, setIsSuspending] = useState(false);

    useEffect(() => {
        const timeout = setTimeout(() => {
            // Only include non-empty filters in the URL
            const filters: any = {};

            if (search && search.trim() !== '') {
                filters.search = search.trim();
            }

            if (status && status !== 'all' && status !== '') {
                filters.status = status;
            }

            router.get(route('cms-pages.index'), filters, { preserveState: true, replace: true });
        }, 300);
        return () => clearTimeout(timeout);
    }, [search, status]);

    const handleDelete = (id: number) => {
        setIsDeleting(true);
        router.delete(route('cms-pages.destroy', id), {
            preserveState: false,
            onSuccess: () => {
                toast.success('CMS page deleted successfully!');
                setDeleteId(null);
            },
            onError: () => {
                toast.error('Failed to delete CMS page.');
            },
            onFinish: () => setIsDeleting(false),
        });
    };

    const handleSuspend = (page: CmsPage) => {
        setIsSuspending(true);
        router.post(route('cms-pages.suspend', page.id), {}, {
            preserveState: false,
            onSuccess: () => {
                const action = page.status === 'active' ? 'suspended' : 'activated';
                toast.success(`CMS page ${action} successfully!`);
                setSuspendDialogOpen(false);
                setPageToSuspend(null);
            },
            onError: () => {
                toast.error('Failed to update CMS page status.');
            },
            onFinish: () => setIsSuspending(false),
        });
    };

    const getStatusBadge = (status: 'active' | 'suspended' | 'draft') => {
        const variants = {
            active: 'default',
            suspended: 'destructive',
            draft: 'secondary',
        } as const;

        return <Badge variant={variants[status]}>{status}</Badge>;
    };

    return (
        <AppLayout>
            <Head title="CMS Manager" />
            <div className="p-6">
                <div className="mb-4 flex flex-col gap-2 sm:flex-row sm:items-center sm:justify-between">
                    <div className="flex items-center gap-2">
                        <h1 className="text-2xl font-bold">CMS Manager</h1>
                        {hasActiveFilters && (
                            <span className="text-sm text-gray-500">
                                ({activeFilterCount} filter{activeFilterCount !== 1 ? 's' : ''} active)
                            </span>
                        )}
                        {isFiltering && (
                            <div className="flex items-center gap-1 text-sm text-gray-500">
                                <div className="animate-spin rounded-full h-4 w-4 border-b-2 border-blue-500"></div>
                                <span>Filtering...</span>
                            </div>
                        )}
                    </div>
                    <div className="flex flex-col gap-2 sm:flex-row sm:items-center">
                        <div className="relative w-full sm:w-64">
                            <Input
                                type="text"
                                placeholder="Search pages..."
                                value={search}
                                onChange={e => setSearch(e.target.value)}
                                className="w-full"
                            />
                            {isFiltering && (
                                <div className="absolute right-3 top-1/2 transform -translate-y-1/2">
                                    <div className="animate-spin rounded-full h-4 w-4 border-b-2 border-blue-500"></div>
                                </div>
                            )}
                        </div>
                        <StatusFilter
                            value={status || 'all'}
                            onChange={(v) => setStatus(v === 'all' ? '' : v)}
                            statusOptions={[
                                { value: 'all', label: 'All Statuses' },
                                { value: 'active', label: 'Active' },
                                { value: 'suspended', label: 'Suspended' },
                                { value: 'draft', label: 'Draft' },
                            ]}
                            placeholder="Filter by status"
                            className="w-40"
                        />
                        <Button asChild>
                            <Link href={route('cms-pages.create')}>Add Page</Link>
                        </Button>
                    </div>
                </div>
                <div className="mb-4 flex flex-wrap gap-2">
                    {(search || status !== '') && (
                        <Button
                            variant="outline"
                            onClick={() => {
                                setSearch('');
                                setStatus('');
                                router.get(route('cms-pages.index'), {}, { preserveState: true, replace: true });
                            }}
                        >
                            Clear Filters
                        </Button>
                    )}
                </div>
                <div className="overflow-x-auto">
                    <table className="min-w-full border bg-white dark:bg-neutral-900">
                        <thead>
                            <tr>
                                <th className="border px-4 py-2">#</th>
                                <th className="border px-4 py-2">Title (EN)</th>
                                <th className="border px-4 py-2">Title (AR)</th>
                                <th className="border px-4 py-2">Slug</th>
                                <th className="border px-4 py-2">Status</th>
                                <th className="border px-4 py-2">Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            {pages?.data && pages.data.length > 0 ? (
                                pages.data.map((page: CmsPage, idx: number) => (
                                    <tr key={page.id} className="text-center">
                                        <td className="border px-4 py-2 text-center">
                                            {(pages.current_page - 1) * pages.per_page + idx + 1}
                                        </td>
                                        <td className="border px-4 py-2 text-center">{page.title_en}</td>
                                        <td className="border px-4 py-2 text-center">{page.title_ar}</td>
                                        <td className="border px-4 py-2 text-center">{page.slug}</td>
                                        <td className="border px-4 py-2 text-center">
                                            <span
                                                className={
                                                    'inline-block min-w-[90px] rounded px-2 py-1 text-center text-xs font-semibold text-white ' +
                                                    ({
                                                        active: 'bg-green-600',
                                                        suspended: 'bg-red-600',
                                                        draft: 'bg-gray-400',
                                                    }[page.status] || 'bg-gray-400')
                                                }
                                            >
                                                {page.status === 'active'
                                                    ? 'Active'
                                                    : page.status === 'suspended'
                                                        ? 'Suspended'
                                                        : page.status.charAt(0).toUpperCase() + page.status.slice(1)}
                                            </span>
                                        </td>
                                        <td className="space-x-2 border px-4 py-2 text-center">
                                            <Button size="sm" variant="outline" asChild>
                                                <Link href={route('cms-pages.edit', page.id)}>Edit</Link>
                                            </Button>
                                            <Button
                                                size="sm"
                                                variant={page.status === 'active' ? 'outline' : 'default'}
                                                onClick={() => {
                                                    setPageToSuspend(page);
                                                    setSuspendDialogOpen(true);
                                                }}
                                            >
                                                {page.status === 'active' ? 'Suspend' : 'Activate'}
                                            </Button>
                                            <Button
                                                size="sm"
                                                variant="destructive"
                                                onClick={() => setDeleteId(page.id)}
                                            >
                                                Delete
                                            </Button>
                                        </td>
                                    </tr>
                                ))
                            ) : (
                                <tr>
                                    <td colSpan={6} className="py-8 text-center text-gray-500">
                                        No CMS pages found.
                                    </td>
                                </tr>
                            )}
                        </tbody>
                    </table>
                </div>
                {/* Pagination */}
                {pages.last_page > 1 && (
                    <div className="mt-6">
                        <Pagination
                            currentPage={pages.current_page}
                            lastPage={pages.last_page}
                            total={pages.total}
                            perPage={pages.per_page}
                            links={pages.links}
                            onPageChange={page => router.get(route('cms-pages.index'), { search, status, page }, { preserveState: true })}
                        />
                    </div>
                )}
                {/* Delete Confirmation Dialog */}
                <Dialog open={!!deleteId} onOpenChange={() => setDeleteId(null)}>
                    <DialogContent>
                        <DialogHeader>
                            <DialogTitle>Confirm Deletion</DialogTitle>
                        </DialogHeader>
                        <div className="py-4">
                            <p>Are you sure you want to delete this CMS page? This action cannot be undone.</p>
                        </div>
                        <DialogFooter>
                            <Button variant="outline" onClick={() => setDeleteId(null)} disabled={isDeleting}>
                                Cancel
                            </Button>
                            <Button variant="destructive" onClick={() => deleteId && handleDelete(deleteId)} disabled={isDeleting}>
                                {isDeleting ? 'Deleting...' : 'Delete'}
                            </Button>
                        </DialogFooter>
                    </DialogContent>
                </Dialog>

                {/* Suspend Confirmation Dialog */}
                <Dialog open={suspendDialogOpen} onOpenChange={() => setSuspendDialogOpen(false)}>
                    <DialogContent>
                        <DialogHeader>
                            <DialogTitle>
                                {pageToSuspend?.status === 'active' ? 'Suspend CMS Page' : 'Activate CMS Page'}
                            </DialogTitle>
                        </DialogHeader>
                        <div className="py-4">
                            <p>
                                Are you sure you want to {pageToSuspend?.status === 'active' ? 'suspend' : 'activate'} the CMS page
                                <strong> "{pageToSuspend?.title_en}"</strong>?
                            </p>
                            {pageToSuspend?.status === 'active' && (
                                <p className="mt-2 text-sm text-gray-600">
                                    Suspended pages will not be visible to visitors.
                                </p>
                            )}
                            {pageToSuspend?.status === 'suspended' && (
                                <p className="mt-2 text-sm text-gray-600">
                                    Activated pages will be visible to visitors again.
                                </p>
                            )}
                        </div>
                        <DialogFooter>
                            <Button variant="outline" onClick={() => setSuspendDialogOpen(false)} disabled={isSuspending}>
                                Cancel
                            </Button>
                            <Button
                                variant={pageToSuspend?.status === 'active' ? 'destructive' : 'default'}
                                onClick={() => pageToSuspend && handleSuspend(pageToSuspend)}
                                disabled={isSuspending}
                            >
                                {isSuspending ? 'Updating...' : (pageToSuspend?.status === 'active' ? 'Suspend' : 'Activate')}
                            </Button>
                        </DialogFooter>
                    </DialogContent>
                </Dialog>
            </div>
        </AppLayout>
    );
}

export default CmsPagesIndex;
