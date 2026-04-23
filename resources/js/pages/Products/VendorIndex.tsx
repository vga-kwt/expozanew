/* eslint-disable @typescript-eslint/no-explicit-any */
import { useLanguage } from '@/components/language-context';
import { Badge } from '@/components/ui/badge';
import { Button } from '@/components/ui/button';
import { Dialog, DialogContent, DialogFooter, DialogHeader, DialogTitle } from '@/components/ui/dialog';
import { Input } from '@/components/ui/input';
import { Pagination } from '@/components/ui/pagination';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select';
import AppLayout from '@/layouts/app-layout';
import { Head, Link, router, usePage } from '@inertiajs/react';
import { useEffect, useState } from 'react';
import { toast } from 'react-hot-toast';

interface Product {
    id: number;
    name_en: string;
    name_ar: string;
    description_en?: string;
    description_ar?: string;
    price: string;
    regular_price: number;
    stock: number;
    status: 'active' | 'suspended' | 'deleted';
    images?: { url: string; name: string }[];
    category: { id: number; name_en: string };
    expo?: { id: number; name_en: string };
}

interface IndexProps {
    products: {
        data: Product[];
        current_page: number;
        last_page: number;
        total: number;
        per_page: number;
        links: {
            url: string;
            label: string;
            active: boolean;
        }[];
    };
    categories: { id: number; name_en: string }[];
    expos: { id: number; name_en: string }[];
    filters: Record<string, string>;
    hasActiveFilters: boolean;
    activeFilterCount: number;
    [key: string]: unknown;
}

const VendorProductsIndex = () => {
    const { t } = useLanguage();
    const { products, categories, filters, hasActiveFilters, activeFilterCount } = usePage<IndexProps>().props;
    const [search, setSearch] = useState(filters?.name || '');
    const [category, setCategory] = useState(filters?.category_id || 'all');
    const [status, setStatus] = useState(filters?.status || 'all');
    const [fromDate, setFromDate] = useState(filters?.from || '');
    const [toDate, setToDate] = useState(filters?.to || '');
    const [suspendDialogOpen, setSuspendDialogOpen] = useState(false);
    const [productToSuspend, setProductToSuspend] = useState<Product | null>(null);
    const [isSuspending, setIsSuspending] = useState(false);
    const [deleteModal, setDeleteModal] = useState<{
        isOpen: boolean;
        deleteDataId: string | null;
        isDeleting: boolean;
    }>({
        isOpen: false,
        deleteDataId: null,
        isDeleting: false,
    });

    useEffect(() => {
        const timeout = setTimeout(() => {
            const filters: any = {};

            if (search && search.trim() !== '') {
                filters.search = search.trim();
            }

            if (category && category !== 'all' && category !== '') {
                filters.category_id = category;
            }

            if (status && status !== 'all' && status !== '') {
                filters.status = status;
            }

            if (fromDate && toDate) {
                filters.date_from = fromDate;
                filters.date_to = toDate;
            }

            router.get(route('vendor.products.index'), filters, {
                preserveState: true,
                replace: true,
            });
        }, 500);
        return () => clearTimeout(timeout);
    }, [search, category, status, fromDate, toDate]);

    const handleDelete = () => {
        if (!deleteModal.deleteDataId) return;
        console.log(deleteModal.deleteDataId);

        setDeleteModal({ ...deleteModal, isDeleting: true });
        router.delete(route('products.destroy', deleteModal.deleteDataId), {
            preserveState: false,
            onSuccess: () => {
                toast.success('Product deleted successfully!');
            },
            onError: () => {
                toast.error('Failed to delete product.');
            },
        });
        setDeleteModal({ isOpen: false, deleteDataId: null, isDeleting: false });
    };

    const handleSuspend = (product: Product) => {
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
            <Head title={t('products.myProducts')} />
            <div className="p-6">
                <div className="mb-4 flex items-center justify-between">
                    <div className="flex items-center gap-2">
                        <h1 className="text-2xl font-bold">{t('products.myProducts')}</h1>
                        {hasActiveFilters && (
                            <span className="text-sm text-gray-500">
                                ({activeFilterCount} {activeFilterCount !== 1 ? t('products.filtersActive') : t('products.filterActive')})
                            </span>
                        )}
                    </div>
                    <Button asChild>
                        <Link href={route('products.create')}>{t('products.addProduct')}</Link>
                    </Button>
                </div>
                <div className="mb-4 flex justify-end gap-2">
                    <Input placeholder={t('products.searchByName')} value={search} onChange={(e) => setSearch(e.target.value)} className="w-48" />
                    <Select value={category} onValueChange={setCategory}>
                        <SelectTrigger className="w-40">
                            <SelectValue placeholder={t('products.category')} />
                        </SelectTrigger>
                        <SelectContent>
                            <SelectItem value="all">{t('products.allCategories')}</SelectItem>
                            {categories.map((c: any) => (
                                <SelectItem key={c.id} value={String(c.id)}>
                                    {c.name_en}
                                </SelectItem>
                            ))}
                        </SelectContent>
                    </Select>
                    <Select value={status} onValueChange={setStatus}>
                        <SelectTrigger className="w-40">
                            <SelectValue placeholder={t('products.status')} />
                        </SelectTrigger>
                        <SelectContent>
                            <SelectItem value="all">{t('products.allStatuses')}</SelectItem>
                            <SelectItem value="active">{t('expos.active')}</SelectItem>
                            <SelectItem value="suspended">{t('expos.suspended')}</SelectItem>
                            <SelectItem value="deleted">{t('products.deleted')}</SelectItem>
                        </SelectContent>
                    </Select>
                    <Input type="date" value={fromDate} onChange={(e) => setFromDate(e.target.value)} className="w-40" />
                    <Input type="date" value={toDate} min={fromDate || undefined} onChange={(e) => setToDate(e.target.value)} className="w-40" />
                    {(search || category !== 'all' || status !== 'all' || fromDate || toDate) && (
                        <Button
                            variant="outline"
                            onClick={() => {
                                setSearch('');
                                setFromDate('');
                                setToDate('');
                                setCategory('all');
                                setStatus('all');
                                router.get(route('vendor.products.index'), {}, { preserveState: true });
                            }}
                        >
                            {t('products.clearFilters')}
                        </Button>
                    )}
                </div>
                <div className="overflow-x-auto">
                    <table className="min-w-full border bg-white dark:bg-neutral-900">
                        <thead>
                            <tr>
                                <th className="border px-4 py-2">{t('products.id')}</th>
                                <th className="border px-4 py-2">{t('products.nameEn')}</th>
                                <th className="border px-4 py-2">{t('products.nameAr')}</th>
                                <th className="border px-4 py-2">{t('products.category')}</th>
                                <th className="border px-4 py-2 text-center">{t('products.stock')}</th>
                                <th className="border px-4 py-2 text-center">{t('products.status')}</th>
                                <th className="border px-4 py-2">{t('common.actions')}</th>
                            </tr>
                        </thead>
                        <tbody>
                            {Array.isArray(products?.data) && products.data.length > 0 ? (
                                products.data.map((p: Product, idx: number) => (
                                    <tr key={p.id} className="text-center">
                                        <td className="border px-4 py-2 text-center">{(products.current_page - 1) * products.per_page + idx + 1}</td>
                                        <td className="border px-4 py-2 text-center">{p.name_en}</td>
                                        <td className="border px-4 py-2 text-center" dir="rtl">
                                            {p.name_ar}
                                        </td>
                                        <td className="border px-4 py-2 text-center">{p.category?.name_en}</td>
                                        <td className="border px-4 py-2 text-center">
                                            {p.stock === 0 ? <Badge variant="destructive">{t('products.outOfStock')}</Badge> : p.stock}
                                        </td>
                                        <td className="border px-4 py-2 text-center">
                                            <span
                                                className={
                                                    'inline-block min-w-[90px] rounded px-2 py-1 text-center text-xs font-semibold text-white ' +
                                                    (p.status === 'active' ? 'bg-green-600' : p.status === 'suspended' ? 'bg-red-600' : 'bg-gray-400')
                                                }
                                            >
                                                {p.status === 'active'
                                                    ? t('expos.active')
                                                    : p.status === 'suspended'
                                                      ? t('expos.suspended')
                                                      : p.status === 'deleted'
                                                        ? t('products.deleted')
                                                        : p.status.charAt(0).toUpperCase() + p.status.slice(1)}
                                            </span>
                                        </td>
                                        <td className="space-x-2 border px-4 py-2 text-center">
                                            <Button size="sm" variant="outline" asChild>
                                                <Link href={route('products.edit', p.id)}>{t('common.edit')}</Link>
                                            </Button>
                                            <Button
                                                size="sm"
                                                variant={p.status === 'active' ? 'outline' : 'default'}
                                                onClick={() => {
                                                    setProductToSuspend(p);
                                                    setSuspendDialogOpen(true);
                                                }}
                                            >
                                                {p.status === 'active' ? t('products.suspend') : t('products.activate')}
                                            </Button>
                                            <Button
                                                size="sm"
                                                variant="destructive"
                                                onClick={() => setDeleteModal({ isOpen: true, deleteDataId: p.id.toString(), isDeleting: false })}
                                            >
                                                {t('common.delete')}
                                            </Button>
                                        </td>
                                    </tr>
                                ))
                            ) : (
                                <tr>
                                    <td colSpan={8} className="text-muted-foreground py-4 text-center">
                                        {t('products.noProductsFound')}
                                    </td>
                                </tr>
                            )}
                        </tbody>
                    </table>
                </div>
                {products?.last_page > 1 && (
                    <div className="mt-6">
                        <Pagination
                            currentPage={products.current_page}
                            lastPage={products.last_page}
                            total={products.total}
                            perPage={products.per_page}
                            links={products.links}
                            onPageChange={(page) =>
                                router.get(route('vendor.products.index'), { search, category_id: category, status, page }, { preserveState: true })
                            }
                        />
                    </div>
                )}

                {/* Suspend Confirmation Dialog */}
                <Dialog open={suspendDialogOpen} onOpenChange={() => setSuspendDialogOpen(false)}>
                    <DialogContent>
                        <DialogHeader>
                            <DialogTitle>{productToSuspend?.status === 'active' ? t('products.suspendProduct') : t('products.activateProduct')}</DialogTitle>
                        </DialogHeader>
                        <div className="py-4">
                            <p>
                                {productToSuspend?.status === 'active' ? t('products.confirmSuspend') : t('products.confirmActivate')}
                                <strong> "{productToSuspend?.name_en}"</strong>?
                            </p>
                            {productToSuspend?.status === 'active' && (
                                <p className="mt-2 text-sm text-gray-600">{t('products.suspendedHint')}</p>
                            )}
                            {productToSuspend?.status === 'suspended' && (
                                <p className="mt-2 text-sm text-gray-600">{t('products.activatedHint')}</p>
                            )}
                        </div>
                        <DialogFooter>
                            <Button variant="outline" onClick={() => setSuspendDialogOpen(false)} disabled={isSuspending}>
                                {t('common.cancel')}
                            </Button>
                            <Button
                                variant={productToSuspend?.status === 'active' ? 'outline' : 'default'}
                                onClick={() => productToSuspend && handleSuspend(productToSuspend)}
                                disabled={isSuspending}
                            >
                                {isSuspending ? t('products.updating') : productToSuspend?.status === 'active' ? t('products.suspend') : t('products.activate')}
                            </Button>
                        </DialogFooter>
                    </DialogContent>
                </Dialog>

                {/* Delete Dialog */}
                <Dialog
                    open={deleteModal.isOpen}
                    onOpenChange={(open) =>
                        setDeleteModal((prev) => ({
                            ...prev,
                            isOpen: open,
                        }))
                    }
                >
                    <DialogContent>
                        <DialogHeader>
                            <DialogTitle>{t('products.confirmDeletion')}</DialogTitle>
                        </DialogHeader>
                        <div className="py-4">
                            <p>{t('products.confirmDeleteProduct')}</p>
                        </div>
                        <DialogFooter>
                            <Button variant="outline" onClick={() => setDeleteModal({ isOpen: false, deleteDataId: null, isDeleting: false })}>
                                {t('common.cancel')}
                            </Button>
                            <Button variant="destructive" onClick={handleDelete} disabled={deleteModal.isDeleting}>
                                {deleteModal.isDeleting ? t('profile.deleting') : t('common.delete')}
                            </Button>
                        </DialogFooter>
                    </DialogContent>
                </Dialog>
            </div>
        </AppLayout>
    );
};

export default VendorProductsIndex;
