/* eslint-disable @typescript-eslint/no-explicit-any */
import { Button } from '@/components/ui/button';
import { Dialog, DialogContent, DialogFooter, DialogHeader, DialogTitle } from '@/components/ui/dialog';
import { Input } from '@/components/ui/input';
import { Pagination } from '@/components/ui/pagination';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select';
import { StatusFilter } from '@/components/ui/StatusFilter';
import AppLayout from '@/layouts/app-layout';
import { Head, Link, router, usePage } from '@inertiajs/react';
import { useEffect, useState } from 'react';
import { toast } from 'react-hot-toast';

function ProductsIndex() {
    const { products, categories, vendors, filters, hasActiveFilters, activeFilterCount } = usePage().props as any;
    const [search, setSearch] = useState(filters?.search || '');
    const [category, setCategory] = useState(filters?.category_id || '');
    const [vendor, setVendor] = useState(filters?.vendor_id || '');
    const [fromDate, setFromDate] = useState(filters?.from || '');
    const [toDate, setToDate] = useState(filters?.to || '');
    const [status, setStatus] = useState(filters?.status || '');
    const [deleteId, setDeleteId] = useState<number | null>(null);
    const [isDeleting, setIsDeleting] = useState(false);
    const [isFiltering, setIsFiltering] = useState(false);
    const [suspendDialogOpen, setSuspendDialogOpen] = useState(false);
    const [productToSuspend, setProductToSuspend] = useState<any>(null);
    const [isSuspending, setIsSuspending] = useState(false);

    useEffect(() => {
        const timeout = setTimeout(() => {
            const filters: any = {};

            if (search && search.trim() !== '') {
                filters.search = search.trim();
            }

            if (category && category !== 'all' && category !== '') {
                filters.category_id = category;
            }

            if (vendor && vendor !== 'all' && vendor !== '') {
                filters.vendor_id = vendor;
            }

            if (status && status !== 'all' && status !== '') {
                filters.status = status;
            }

            if (fromDate && toDate) {
                filters.date_from = fromDate;
                filters.date_to = toDate;
            }

            router.get(route('products.index'), filters, { preserveState: true, replace: true });
        }, 300);
        return () => clearTimeout(timeout);
    }, [search, category, vendor, status, fromDate, toDate]);

    const handleDelete = (id: number) => {
        setIsDeleting(true);
        router.delete(route('products.destroy', id), {
            onSuccess: () => {
                toast.success('Product deleted successfully!');
                setDeleteId(null);
            },
            onError: () => {
                toast.error('Failed to delete product.');
            },
            onFinish: () => setIsDeleting(false),
        });
    };

    const handleSuspend = (product: any) => {
        setIsSuspending(true);
        router.post(
            route('products.suspend', product.id),
            {},
            {
                preserveState: false,
                onSuccess: () => {
                    const action = product.status === 'active' ? 'suspended' : 'activated';
                    toast.success(`Product ${action} successfully!`);
                    setSuspendDialogOpen(false);
                    setProductToSuspend(null);
                },
                onError: () => {
                    toast.error('Failed to update product status.');
                },
                onFinish: () => setIsSuspending(false),
            },
        );
    };

    return (
        <AppLayout>
            <Head title="Product Manager" />
            <div className="p-6">
                <div className="mb-4 flex flex-col gap-2 sm:flex-row sm:items-center sm:justify-between">
                    <div className="flex items-center gap-2">
                        <h1 className="text-2xl font-bold">Product Manager</h1>
                        {hasActiveFilters && (
                            <span className="text-sm text-gray-500">
                                ({activeFilterCount} filter{activeFilterCount !== 1 ? 's' : ''} active)
                            </span>
                        )}
                        {isFiltering && (
                            <div className="flex items-center gap-1 text-sm text-gray-500">
                                <div className="h-4 w-4 animate-spin rounded-full border-b-2 border-blue-500"></div>
                                <span>Filtering...</span>
                            </div>
                        )}
                    </div>
                    <div className="flex flex-col gap-2 sm:flex-row sm:items-center">
                        <Button asChild>
                            <Link href={route('products.create')}>Add Product</Link>
                        </Button>
                    </div>
                </div>
                <div className="mb-4 flex justify-end gap-2">
                    <div className="flex items-center gap-2">
                        <Input
                            type="text"
                            placeholder="Search products..."
                            value={search}
                            onChange={(e) => setSearch(e.target.value)}
                            className="w-64"
                        />
                        <StatusFilter
                            value={status || 'all'}
                            onChange={(v) => setStatus(v === 'all' ? '' : v)}
                            statusOptions={[
                                { value: 'all', label: 'All Statuses' },
                                { value: 'active', label: 'Active' },
                                { value: 'suspended', label: 'Suspended' },
                            ]}
                            placeholder="Filter by status"
                            className="w-40"
                        />
                    </div>
                    <Select value={category} onValueChange={setCategory}>
                        <SelectTrigger className="w-40">
                            <SelectValue placeholder="Category" />
                        </SelectTrigger>
                        <SelectContent>
                            <SelectItem value="all">All</SelectItem>
                            {categories.map((c: any) => (
                                <SelectItem key={c.id} value={c.id.toString()}>
                                    {c.name_en}
                                </SelectItem>
                            ))}
                        </SelectContent>
                    </Select>
                    <Select value={vendor} onValueChange={setVendor}>
                        <SelectTrigger className="w-40">
                            <SelectValue placeholder="Vendor" />
                        </SelectTrigger>
                        <SelectContent>
                            <SelectItem value="all">All</SelectItem>
                            {vendors.map((v: any) => (
                                <SelectItem key={v.id} value={v.id.toString()}>
                                    {v.name}
                                </SelectItem>
                            ))}
                        </SelectContent>
                    </Select>
                    <Input type="date" value={fromDate} min="2015-01-01" onChange={(e) => setFromDate(e.target.value)} className="w-40" />
                    <Input type="date" value={toDate} min="2015-01-01" onChange={(e) => setToDate(e.target.value)} className="w-40" />
                    {(search || category !== '' || vendor !== '' || status !== '' || fromDate || toDate) && (
                        <Button
                            variant="outline"
                            onClick={() => {
                                setSearch('');
                                setCategory('');
                                setFromDate('');
                                setToDate('');
                                setVendor('');
                                setStatus('');
                                router.get(route('products.index'), {}, { preserveState: true, replace: true });
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
                                <th className="border px-4 py-2">Name (EN)</th>
                                <th className="border px-4 py-2">Name (AR)</th>
                                <th className="border px-4 py-2">Stock</th>
                                <th className="border px-4 py-2">Status</th>
                                <th className="border px-4 py-2">Category</th>
                                <th className="border px-4 py-2">Brand name (EN)</th>
                                <th className="border px-4 py-2">Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            {products?.data && products.data.length > 0 ? (
                                products.data.map((p: any, idx: number) => (
                                    <tr key={p.id} className="text-center">
                                        <td className="border px-4 py-2 text-center">{(products.current_page - 1) * products.per_page + idx + 1}</td>
                                        <td className="border px-4 py-2 text-center">{p.name_en}</td>
                                        <td className="border px-4 py-2 text-center" dir="rtl">
                                            {p.name_ar}
                                        </td>
                                        <td className="border px-4 py-2 text-center">{p.stock}</td>
                                        <td className="border px-4 py-2 text-center">
                                            <span
                                                className={
                                                    'inline-block min-w-[90px] rounded px-2 py-1 text-center text-xs font-semibold text-white ' +
                                                    (p.status === 'active' ? 'bg-green-600' : p.status === 'suspended' ? 'bg-red-600' : 'bg-gray-400')
                                                }
                                            >
                                                {p.status === 'active'
                                                    ? 'Active'
                                                    : p.status === 'suspended'
                                                        ? 'Suspended'
                                                        : p.status.charAt(0).toUpperCase() + p.status.slice(1)}
                                            </span>
                                        </td>
                                        <td className="border px-4 py-2 text-center">{p.category?.name_en}</td>
                                        <td className="border px-4 py-2 text-center">{p.vendor?.brand_name_en || p.vendor?.name}</td>
                                        <td className="space-x-2 border px-4 py-2 text-center">
                                            <Button size="sm" variant="outline" asChild>
                                                <Link href={route('products.edit', p.id)}>Edit</Link>
                                            </Button>
                                            <Button
                                                size="sm"
                                                variant={p.status === 'active' ? 'outline' : 'default'}
                                                onClick={() => {
                                                    setProductToSuspend(p);
                                                    setSuspendDialogOpen(true);
                                                }}
                                            >
                                                {p.status === 'active' ? 'Suspend' : 'Activate'}
                                            </Button>
                                            <Button size="sm" variant="destructive" onClick={() => setDeleteId(p.id)}>
                                                Delete
                                            </Button>
                                        </td>
                                    </tr>
                                ))
                            ) : (
                                <tr>
                                    <td colSpan={9} className="py-8 text-center text-gray-500">
                                        No products found.
                                    </td>
                                </tr>
                            )}
                        </tbody>
                    </table>
                </div>
                {/* Pagination */}
                {products.last_page > 1 && (
                    <div className="mt-6">
                        <Pagination
                            currentPage={products.current_page}
                            lastPage={products.last_page}
                            total={products.total}
                            perPage={products.per_page}
                            links={products.links}
                            onPageChange={(page) =>
                                router.get(
                                    route('products.index'),
                                    { search, category_id: category, vendor_id: vendor, status, page },
                                    { preserveState: true },
                                )
                            }
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
                            <p>Are you sure you want to delete this product? This action cannot be undone.</p>
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
                            <DialogTitle>{productToSuspend?.status === 'active' ? 'Suspend Product' : 'Activate Product'}</DialogTitle>
                        </DialogHeader>
                        <div className="py-4">
                            <p>
                                Are you sure you want to {productToSuspend?.status === 'active' ? 'suspend' : 'activate'} the product
                                <strong> "{productToSuspend?.name_en}"</strong>?
                            </p>
                            {productToSuspend?.status === 'active' && (
                                <p className="mt-2 text-sm text-gray-600">Suspended products will not be visible to customers.</p>
                            )}
                            {productToSuspend?.status === 'suspended' && (
                                <p className="mt-2 text-sm text-gray-600">Activated products will be visible to customers again.</p>
                            )}
                        </div>
                        <DialogFooter>
                            <Button variant="outline" onClick={() => setSuspendDialogOpen(false)} disabled={isSuspending}>
                                Cancel
                            </Button>
                            <Button
                                variant={productToSuspend?.status === 'active' ? 'destructive' : 'default'}
                                onClick={() => productToSuspend && handleSuspend(productToSuspend)}
                                disabled={isSuspending}
                            >
                                {isSuspending ? 'Updating...' : productToSuspend?.status === 'active' ? 'Suspend' : 'Activate'}
                            </Button>
                        </DialogFooter>
                    </DialogContent>
                </Dialog>
            </div>
        </AppLayout>
    );
}

export default ProductsIndex;
