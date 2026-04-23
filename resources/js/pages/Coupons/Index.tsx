import { ActionButtonDelete } from '@/components/action-button';
import { Badge } from '@/components/ui/badge';
import { Button } from '@/components/ui/button';
import { Dialog, DialogContent, DialogFooter, DialogHeader, DialogTitle } from '@/components/ui/dialog';
import { Input } from '@/components/ui/input';
import { Pagination as ShadcnPagination } from '@/components/ui/pagination';
import { StatusFilter } from '@/components/ui/StatusFilter';
import AppLayout from '@/layouts/app-layout';
import { Head, router, usePage } from '@inertiajs/react';
import { useEffect, useState } from 'react';
import toast from 'react-hot-toast';

interface Coupon {
    id: number;
    code: string;
    percentage: string;
    starts_at: string | null;
    ends_at: string | null;
    usage_limit: number | null;
    usage_limit_per_user: number;
    is_active: boolean;
}

interface PaginatedCoupons {
    data: Coupon[];
    links: { url: string | null; label: string; active: boolean }[];
    current_page: number;
    last_page: number;
    total: number;
    per_page: number;
}

interface PageProps extends Record<string, unknown> {
    coupons: PaginatedCoupons;
    filters: { search?: string; status?: string };
}

function toDatetimeLocal(value: string | null): string {
    if (!value) return '';
    const d = new Date(value);
    if (Number.isNaN(d.getTime())) return '';
    const pad = (n: number) => String(n).padStart(2, '0');
    return `${d.getFullYear()}-${pad(d.getMonth() + 1)}-${pad(d.getDate())}T${pad(d.getHours())}:${pad(d.getMinutes())}`;
}

function CouponsIndexPage() {
    const { coupons, filters, flash } = usePage<PageProps & { flash?: { success?: string } }>().props;
    const [search, setSearch] = useState(filters?.search || '');
    const [status, setStatus] = useState(filters?.status || 'all');
    const [modalOpen, setModalOpen] = useState(false);
    const [deleteDialogOpen, setDeleteDialogOpen] = useState(false);
    const [couponToDelete, setCouponToDelete] = useState<Coupon | null>(null);
    const [editCoupon, setEditCoupon] = useState<Coupon | null>(null);
    const [form, setForm] = useState({
        code: '',
        percentage: '',
        starts_at: '',
        ends_at: '',
        usage_limit: '',
        usage_limit_per_user: '1',
        is_active: true,
    });

    useEffect(() => {
        if (flash?.success) {
            toast.success(flash.success);
        }
    }, [flash?.success]);

    useEffect(() => {
        const t = setTimeout(() => {
            const params: Record<string, string> = { search };
            if (status && status !== 'all') {
                params.status = status;
            }
            router.get(route('coupons.index'), params, { preserveState: true, replace: true });
        }, 300);
        return () => clearTimeout(t);
    }, [search, status]);

    useEffect(() => {
        if (!modalOpen) return;
        if (editCoupon) {
            setForm({
                code: editCoupon.code,
                percentage: String(editCoupon.percentage),
                starts_at: toDatetimeLocal(editCoupon.starts_at),
                ends_at: toDatetimeLocal(editCoupon.ends_at),
                usage_limit: editCoupon.usage_limit != null ? String(editCoupon.usage_limit) : '',
                usage_limit_per_user: String(editCoupon.usage_limit_per_user ?? 1),
                is_active: editCoupon.is_active,
            });
        } else {
            setForm({
                code: '',
                percentage: '',
                starts_at: '',
                ends_at: '',
                usage_limit: '',
                usage_limit_per_user: '1',
                is_active: true,
            });
        }
    }, [modalOpen, editCoupon]);

    const openAdd = () => {
        setEditCoupon(null);
        setModalOpen(true);
    };

    const openEdit = (c: Coupon) => {
        setEditCoupon(c);
        setModalOpen(true);
    };

    const save = () => {
        const payload = {
            code: form.code.trim(),
            percentage: parseFloat(form.percentage),
            starts_at: form.starts_at || null,
            ends_at: form.ends_at || null,
            usage_limit: form.usage_limit.trim() === '' ? null : parseInt(form.usage_limit, 10),
            usage_limit_per_user: parseInt(form.usage_limit_per_user, 10) || 1,
            is_active: form.is_active,
        };

        if (editCoupon) {
            router.put(route('coupons.update', editCoupon.id), payload, {
                preserveScroll: true,
                onSuccess: () => {
                    setModalOpen(false);
                },
                onError: (e) => toast.error(Object.values(e).flat().join(' ') || 'Validation failed'),
            });
        } else {
            router.post(route('coupons.store'), payload, {
                preserveScroll: true,
                onSuccess: () => {
                    setModalOpen(false);
                },
                onError: (e) => toast.error(Object.values(e).flat().join(' ') || 'Validation failed'),
            });
        }
    };

    const toggle = (c: Coupon) => {
        router.post(route('coupons.toggle-status', c.id), {}, { preserveScroll: true });
    };

    const doDelete = () => {
        if (!couponToDelete) return;
        router.delete(route('coupons.destroy', couponToDelete.id), { preserveScroll: true });
        setDeleteDialogOpen(false);
        setCouponToDelete(null);
    };

    return (
        <AppLayout>
            <Head title="Checkout coupons" />
            <div className="space-y-6 p-4">
                <div className="flex flex-wrap items-center justify-between gap-4">
                    <h1 className="text-2xl font-semibold">Global checkout coupons</h1>
                    <Button onClick={openAdd}>Add coupon</Button>
                </div>

                <div className="flex flex-wrap gap-4">
                    <Input
                        placeholder="Search by code..."
                        value={search}
                        onChange={(e) => setSearch(e.target.value)}
                        className="max-w-xs"
                    />
                    <StatusFilter
                        value={status}
                        onChange={setStatus}
                        placeholder="Filter by status"
                        className="w-[200px]"
                        statusOptions={[
                            { value: 'all', label: 'All statuses' },
                            { value: 'active', label: 'Active' },
                            { value: 'inactive', label: 'Inactive' },
                        ]}
                    />
                </div>

                <div className="overflow-x-auto rounded-md border">
                    <table className="w-full text-sm">
                        <thead className="bg-muted/50">
                            <tr>
                                <th className="p-3 text-left">Code</th>
                                <th className="p-3 text-left">%</th>
                                <th className="p-3 text-left">Starts</th>
                                <th className="p-3 text-left">Ends</th>
                                <th className="p-3 text-left">Limit</th>
                                <th className="p-3 text-left">/ user</th>
                                <th className="p-3 text-left">Status</th>
                                <th className="p-3 text-right">Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            {coupons.data.map((c) => (
                                <tr key={c.id} className="border-t">
                                    <td className="p-3 font-mono">{c.code}</td>
                                    <td className="p-3">{c.percentage}</td>
                                    <td className="p-3 whitespace-nowrap">{c.starts_at ? new Date(c.starts_at).toLocaleString() : '—'}</td>
                                    <td className="p-3 whitespace-nowrap">{c.ends_at ? new Date(c.ends_at).toLocaleString() : '—'}</td>
                                    <td className="p-3">{c.usage_limit ?? '∞'}</td>
                                    <td className="p-3">{c.usage_limit_per_user}</td>
                                    <td className="p-3">
                                        <Badge variant={c.is_active ? 'default' : 'secondary'}>{c.is_active ? 'Active' : 'Inactive'}</Badge>
                                    </td>
                                    <td className="p-3 text-right space-x-2">
                                        <Button variant="outline" size="sm" onClick={() => openEdit(c)}>
                                            Edit
                                        </Button>
                                        <Button variant="secondary" size="sm" onClick={() => toggle(c)}>
                                            Toggle
                                        </Button>
                                        <ActionButtonDelete
                                            btnTitle="Delete"
                                            onClick={() => {
                                                setCouponToDelete(c);
                                                setDeleteDialogOpen(true);
                                            }}
                                        />
                                    </td>
                                </tr>
                            ))}
                            {coupons.data.length === 0 && (
                                <tr>
                                    <td colSpan={8} className="p-8 text-center text-muted-foreground">
                                        No coupons yet.
                                    </td>
                                </tr>
                            )}
                        </tbody>
                    </table>
                </div>

                {coupons.last_page > 1 && (
                    <ShadcnPagination
                        currentPage={coupons.current_page}
                        lastPage={coupons.last_page}
                        total={coupons.total}
                        perPage={coupons.per_page}
                        links={coupons.links}
                        onPageChange={(pageNum) => {
                            const params: Record<string, string | number> = { page: pageNum, search };
                            if (status && status !== 'all') {
                                params.status = status;
                            }
                            router.get(route('coupons.index'), params, { preserveState: true, replace: true });
                        }}
                    />
                )}
            </div>

            <Dialog open={deleteDialogOpen} onOpenChange={setDeleteDialogOpen}>
                <DialogContent>
                    <DialogHeader>
                        <DialogTitle>Delete coupon</DialogTitle>
                    </DialogHeader>
                    <p>Are you sure you want to delete coupon {couponToDelete?.code}?</p>
                    <DialogFooter>
                        <Button variant="outline" onClick={() => setDeleteDialogOpen(false)}>
                            Cancel
                        </Button>
                        <Button variant="destructive" onClick={doDelete}>
                            Delete
                        </Button>
                    </DialogFooter>
                </DialogContent>
            </Dialog>

            <Dialog open={modalOpen} onOpenChange={setModalOpen}>
                <DialogContent className="max-w-lg">
                    <DialogHeader>
                        <DialogTitle>{editCoupon ? 'Edit coupon' : 'New coupon'}</DialogTitle>
                    </DialogHeader>
                    <div className="space-y-3">
                        <div>
                            <label className="text-sm font-medium">Code</label>
                            <Input value={form.code} onChange={(e) => setForm((f) => ({ ...f, code: e.target.value }))} placeholder="SAVE10" />
                        </div>
                        <div>
                            <label className="text-sm font-medium">Percentage (0–100)</label>
                            <Input
                                type="number"
                                step="0.01"
                                min={0}
                                max={100}
                                value={form.percentage}
                                onChange={(e) => setForm((f) => ({ ...f, percentage: e.target.value }))}
                            />
                        </div>
                        <div className="grid grid-cols-2 gap-2">
                            <div>
                                <label className="text-sm font-medium">Starts at (optional)</label>
                                <Input
                                    type="datetime-local"
                                    value={form.starts_at}
                                    onChange={(e) => setForm((f) => ({ ...f, starts_at: e.target.value }))}
                                />
                            </div>
                            <div>
                                <label className="text-sm font-medium">Ends at (optional)</label>
                                <Input
                                    type="datetime-local"
                                    value={form.ends_at}
                                    onChange={(e) => setForm((f) => ({ ...f, ends_at: e.target.value }))}
                                />
                            </div>
                        </div>
                        <div>
                            <label className="text-sm font-medium">Total usage limit (empty = unlimited)</label>
                            <Input
                                type="number"
                                min={1}
                                value={form.usage_limit}
                                onChange={(e) => setForm((f) => ({ ...f, usage_limit: e.target.value }))}
                                placeholder="Unlimited"
                            />
                        </div>
                        <div>
                            <label className="text-sm font-medium">Per-user limit</label>
                            <Input
                                type="number"
                                min={1}
                                value={form.usage_limit_per_user}
                                onChange={(e) => setForm((f) => ({ ...f, usage_limit_per_user: e.target.value }))}
                            />
                        </div>
                        <div className="flex items-center gap-2">
                            <input
                                type="checkbox"
                                id="is_active"
                                checked={form.is_active}
                                onChange={(e) => setForm((f) => ({ ...f, is_active: e.target.checked }))}
                            />
                            <label htmlFor="is_active" className="text-sm">
                                Active
                            </label>
                        </div>
                    </div>
                    <DialogFooter>
                        <Button variant="outline" onClick={() => setModalOpen(false)}>
                            Cancel
                        </Button>
                        <Button onClick={save}>{editCoupon ? 'Save' : 'Create'}</Button>
                    </DialogFooter>
                </DialogContent>
            </Dialog>
        </AppLayout>
    );
}

export default CouponsIndexPage;
