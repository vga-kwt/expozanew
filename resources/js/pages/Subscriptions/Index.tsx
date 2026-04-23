import { ActionButtonDelete, ActionButtonSuspend } from '@/components/action-button';
import { Badge } from '@/components/ui/badge';
import { Button } from '@/components/ui/button';
import { Dialog, DialogContent, DialogFooter, DialogHeader, DialogTitle } from '@/components/ui/dialog';
import { Input } from '@/components/ui/input';
import { Pagination } from '@/components/ui/pagination';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select';
import { StatusFilter } from '@/components/ui/StatusFilter';
import AppLayout from '@/layouts/app-layout';
import { Head, router, usePage } from '@inertiajs/react';
import { X } from 'lucide-react';
import { useEffect, useState } from 'react';
import toast from 'react-hot-toast';
import ReactQuill from 'react-quill';
import 'react-quill/dist/quill.snow.css';

interface Subscription {
    id: number;
    title_en: string;
    title_ar: string;
    description_en: string;
    description_ar: string;
    price: string;
    duration: string;
    status: string;
    features: string;
    sort_order: number;
    ad_limit: number;
}

interface PageProps extends Record<string, unknown> {
    subscriptions: {
        data: Subscription[];
        current_page: number;
        last_page: number;
        total: number;
        per_page: number;
        links: { url: string | null; label: string; active: boolean }[];
    };
    filters: {
        search?: string;
        duration?: string;
        status?: string;
        from_date?: string;
        to_date?: string;
    };
    errors: Record<string, string>;
}

const SubscriptionsIndexPage = () => (
    <AppLayout>
        <Head title="Subscription Manager" />
        <SubscriptionsIndex />
    </AppLayout>
);

export default SubscriptionsIndexPage;

function SubscriptionsIndex() {
    const { subscriptions, filters, errors } = usePage<PageProps>().props;
    const [search, setSearch] = useState(filters?.search || '');
    const [duration, setDuration] = useState(filters?.duration || '');
    const [status, setStatus] = useState(filters?.status || '');
    const [fromDate] = useState(filters?.from_date || '');
    const [toDate] = useState(filters?.to_date || '');

    // Modal state
    const [modalOpen, setModalOpen] = useState(false);
    const [editSub, setEditSub] = useState<Subscription | null>(null);
    const [isSubmitting, setIsSubmitting] = useState(false);
    const [form, setForm] = useState({
        title_en: '',
        title_ar: '',
        description_en: '',
        description_ar: '',
        features: [] as string[],
        price: '',
        duration: 'monthly',
        status: 'active',
        sort_order: 0,
        ad_limit: 0,
    });
    const [formErrors, setFormErrors] = useState<Record<string, string>>({});
    const [confirmDialog, setConfirmDialog] = useState<{ open: boolean; subscription: Subscription | null; action: 'suspend' | 'activate' | null }>({
        open: false,
        subscription: null,
        action: null,
    });
    const [toggleLoadingId, setToggleLoadingId] = useState<number | null>(null);
    const [selectedSubscription, setSelectedSubscription] = useState<Subscription | null>(null);
    const [deleteDialogOpen, setDeleteDialogOpen] = useState(false);
    const [isDeleting, setIsDeleting] = useState(false);
    const [newFeature, setNewFeature] = useState('');

    // Handle search with debounce
    useEffect(() => {
        const timeoutId = setTimeout(() => {
            router.get(
                route('subscriptions.index'),
                { search, duration, status, from_date: fromDate, to_date: toDate },
                { preserveState: true, replace: true }
            );
        }, 300);

        return () => clearTimeout(timeoutId);
    }, [search, duration, status, fromDate, toDate]);

    // Reset form when modal opens/closes
    useEffect(() => {
        if (modalOpen) {
            if (editSub) {
                 let featuresArray: string[] = [];
                 if (editSub.features) {
                     try {
                         const parsedFeatures = JSON.parse(editSub.features);
                         if (Array.isArray(parsedFeatures)) {
                             featuresArray = parsedFeatures;
                         }
                     } catch (e) {
                        // It's not a JSON string, so it might be the old HTML string.
                        // We will just clear it for consistency as we move to the new tag system.
                        featuresArray = [];
                        console.error("Could not parse features JSON:", e);
                     }
                 }
                setForm({
                    title_en: editSub.title_en || '',
                    title_ar: editSub.title_ar || '',
                    description_en: editSub.description_en || '',
                    description_ar: editSub.description_ar || '',
                    features: featuresArray,
                    price: editSub.price || '',
                    duration: editSub.duration || 'monthly',
                    status: editSub.status || 'active',
                    sort_order: editSub.sort_order || 0,
                    ad_limit: editSub.ad_limit || 0,
                });
            } else {
                setForm({
                    title_en: '',
                    title_ar: '',
                    description_en: '',
                    description_ar: '',
                    features: [],
                    price: '',
                    duration: 'monthly',
                    status: 'active',
                    sort_order: 0,
                    ad_limit: 0,
                });
            }
            setFormErrors({});
        }
    }, [modalOpen, editSub]);

    // Handle server-side errors
    useEffect(() => {
        if (errors) {
            setFormErrors(errors);
            if (errors.error) {
                toast.error(errors.error);
            }
        }
    }, [errors]);

    const openAddModal = () => {
        setEditSub(null);
        setModalOpen(true);
    };

    const openEditModal = (sub: Subscription) => {
        setEditSub(sub);
        setModalOpen(true);
    };

    const closeModal = () => {
        setModalOpen(false);
        setEditSub(null);
        setFormErrors({});
        setIsSubmitting(false);
    };

    const validateForm = () => {
        const errors: Record<string, string> = {};

        if (!form.title_en?.trim()) {
            errors.title_en = 'English title is required';
        }
        if (!form.title_ar?.trim()) {
            errors.title_ar = 'Arabic title is required';
        }
        if (!form.price || parseFloat(form.price) < 0) {
            errors.price = 'Valid price is required';
        }

        setFormErrors(errors);
        return Object.keys(errors).length === 0;
    };

    const handleSave = () => {
        if (!validateForm()) {
            return;
        }

        setIsSubmitting(true);
        const data = {
            ...form,
            features: JSON.stringify(form.features),
            price: parseFloat(form.price),
            sort_order: parseInt(form.sort_order.toString()),
            ad_limit: parseInt(form.ad_limit.toString()),
        };

        if (editSub) {
            router.put(route('subscriptions.update', editSub.id), data, {
                onSuccess: () => {
                    toast.success('Subscription updated successfully!');
                    closeModal();
                },
                onError: (err) => {
                    setFormErrors(err);
                    setIsSubmitting(false);
                },
                onFinish: () => setIsSubmitting(false),
            });
        } else {
            router.post(route('subscriptions.store'), data, {
                onSuccess: () => {
                    toast.success('Subscription created successfully!');
                    closeModal();
                },
                onError: (err) => {
                    setFormErrors(err);
                    setIsSubmitting(false);
                },
                onFinish: () => setIsSubmitting(false),
            });
        }
    };

    const confirmToggleStatus = async () => {
        if (!confirmDialog.subscription) return;
        const subscription = confirmDialog.subscription;
        setToggleLoadingId(subscription.id);

        router.post(route('subscriptions.suspend', subscription.id), {}, {
            onSuccess: () => {
                toast.success(`Subscription status updated successfully!`);
                setToggleLoadingId(null);
                setConfirmDialog({ open: false, subscription: null, action: null });
            },
            onError: () => {
                toast.error('Failed to update status.');
                setToggleLoadingId(null);
            },
            onFinish: () => setToggleLoadingId(null),
        });
    };

    const handleDelete = () => {
        if (!selectedSubscription) {
            toast.error('No subscription selected for deletion.');
            return;
        }

        setIsDeleting(true);
        router.delete(route('subscriptions.destroy', selectedSubscription.id), {
            onSuccess: () => {
                toast.success('Subscription deleted successfully!');
                setDeleteDialogOpen(false);
                setSelectedSubscription(null);
            },
            onError: () => {
                toast.error('Failed to delete subscription.');
            },
            onFinish: () => setIsDeleting(false),
        });
    };

    const openDeleteDialog = (subscription: Subscription) => {
        setSelectedSubscription(subscription);
        setDeleteDialogOpen(true);
    };

    const handleToggleStatus = (subscription: Subscription) => {
        setConfirmDialog({ open: true, subscription, action: subscription.status === 'suspended' ? 'activate' : 'suspend' });
    };

    const handlePageChange = (page: number) => {
        router.get(
            route('subscriptions.index'),
            { search, duration, status, from_date: fromDate, to_date: toDate, page },
            { preserveState: true }
        );
    };

    const handleAddFeature = () => {
        if (newFeature && !form.features.includes(newFeature)) {
            setForm(f => ({ ...f, features: [...f.features, newFeature] }));
            setNewFeature('');
        }
    };

    const handleRemoveFeature = (featureToRemove: string) => {
        setForm(f => ({ ...f, features: f.features.filter(feature => feature !== featureToRemove) }));
    };

    return (
        <div className="p-6">
            <div className="mb-6 flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between">
                <h1 className="text-2xl font-bold">Subscription Manager</h1>
                <div className="flex flex-col gap-2 sm:flex-row sm:items-center">
                    <Input
                        type="text"
                        placeholder="Search subscriptions..."
                        value={search}
                        onChange={(e) => setSearch(e.target.value)}
                        className="w-full sm:w-64"
                    />
                    <Select value={duration || "all"} onValueChange={v => setDuration(v === "all" ? "" : v)}>
                        <SelectTrigger className="w-32">
                            <SelectValue placeholder="Duration" />
                        </SelectTrigger>
                        <SelectContent>
                            <SelectItem value="all">All</SelectItem>
                            <SelectItem value="monthly">Monthly</SelectItem>
                            <SelectItem value="yearly">Yearly</SelectItem>
                        </SelectContent>
                    </Select>
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

                    <Button onClick={openAddModal} variant="default">
                        Add Subscription
                    </Button>
                </div>
            </div>

            {/* Filters */}
            <div className="mb-4 flex flex-wrap gap-2">

            </div>

            <div className="overflow-x-auto">
                <table className="min-w-full border bg-white dark:bg-neutral-900">
                    <thead>
                        <tr>
                            <th className="border px-4 py-2">#</th>
                            <th className="border px-4 py-2">Title (EN)</th>
                            <th className="border px-4 py-2">Title (AR)</th>
                            <th className="border px-4 py-2">Price</th>
                            <th className="border px-4 py-2">Duration</th>
                            <th className="border px-4 py-2">Status</th>
                            <th className="border px-4 py-2">Features</th>
                            <th className="border px-4 py-2">Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        {subscriptions.data.length > 0 ? (
                            subscriptions.data.map((s: Subscription, idx: number) => (
                                <tr key={s.id} className="text-center">
                                    <td className="border px-4 py-2 text-center">
                                        {(subscriptions.current_page - 1) * subscriptions.per_page + idx + 1}
                                    </td>
                                    <td className="border px-4 py-2 text-center">{s.title_en}</td>
                                    <td className="border px-4 py-2 text-center" dir="rtl">{s.title_ar}</td>
                                    <td className="border px-4 py-2 text-center">{s.price}</td>
                                    <td className="border px-4 py-2 text-center capitalize">{s.duration}</td>
                                    <td className="border px-4 py-2 text-center">
                                        <span
                                            className={
                                                'inline-block min-w-[90px] rounded px-2 py-1 text-center text-xs font-semibold text-white ' +
                                                ({
                                                    active: 'bg-green-600',
                                                    suspended: 'bg-red-600',
                                                }[s.status] || 'bg-gray-400')
                                            }
                                        >
                                            {s.status === 'active'
                                                ? 'Active'
                                                : s.status === 'suspended'
                                                    ? 'Suspended'
                                                    : s.status.charAt(0).toUpperCase() + s.status.slice(1)}
                                        </span>
                                    </td>
                                    <td className="border px-4 py-2 text-center">
                                        {(() => {
                                            if (!s.features) {
                                                return <span className="text-gray-500">No features</span>;
                                            }
                                            try {
                                                const features = JSON.parse(s.features);
                                                if (Array.isArray(features) && features.length > 0) {
                                                    return (
                                                        <div className="flex flex-wrap gap-1 justify-center max-w-xs mx-auto">
                                                            {features.map((feature: string) => (
                                                                <Badge key={feature} variant="secondary">{feature}</Badge>
                                                            ))}
                                                        </div>
                                                    );
                                                }
                                            } catch {
                                                // It might be old HTML data
                                                return (
                                                    <div
                                                        className="max-w-xs truncate"
                                                        dangerouslySetInnerHTML={{ __html: s.features }}
                                                    />
                                                );
                                            }
                                            return <span className="text-gray-500">No features</span>;
                                        })()}
                                    </td>
                                    <td className="space-x-2 border px-4 py-2 text-center">
                                        <Button size="sm" variant="outline" onClick={() => openEditModal(s)}>
                                            Edit
                                        </Button>
                                        <ActionButtonSuspend
                                            variant={s.status === 'active' ? 'outline' : 'default'}
                                            btnTitle={s.status === 'active' ? 'Suspend' : 'Activate'}
                                            onClick={() => handleToggleStatus(s)}
                                            disabled={toggleLoadingId === s.id}
                                        />
                                        <ActionButtonDelete btnTitle="Delete" onClick={() => openDeleteDialog(s)} />
                                    </td>
                                </tr>
                            ))
                        ) : (
                            <tr>
                                <td colSpan={8} className="py-8 text-center text-gray-500">
                                    No subscriptions found.
                                </td>
                            </tr>
                        )}
                    </tbody>
                </table>
            </div>

            {/* Pagination */}
            {subscriptions.last_page > 1 && (
                <div className="mt-6">
                    <Pagination
                        currentPage={subscriptions.current_page}
                        lastPage={subscriptions.last_page}
                        total={subscriptions.total}
                        perPage={subscriptions.per_page}
                        links={subscriptions.links}
                        onPageChange={handlePageChange}
                    />
                </div>
            )}

            {/* Add/Edit Modal */}
            <Dialog open={modalOpen} onOpenChange={setModalOpen}>
                <DialogContent className="!max-w-4xl w-full overflow-y-auto p-6">
                    <DialogHeader>
                        <DialogTitle>{editSub ? 'Edit Subscription' : 'Add Subscription'}</DialogTitle>
                    </DialogHeader>
                    <div className="space-y-4">
                        <div className="grid grid-cols-1 gap-4 md:grid-cols-2">
                            <div>
                                <label className="mb-1 block font-medium">Title (EN) <span className='text-red-500'>*</span></label>
                                <Input
                                    placeholder="Enter English title"
                                    value={form.title_en}
                                    onChange={(e) => setForm((f) => ({ ...f, title_en: e.target.value }))}
                                    className={formErrors.title_en ? 'border-red-500' : ''}
                                />
                                {formErrors.title_en && <p className="mt-1 text-sm text-red-500">{formErrors.title_en}</p>}
                            </div>
                            <div>
                                <label className="mb-1 block font-medium">Title (AR) <span className='text-red-500'>*</span></label>
                                <Input
                                    placeholder="Enter Arabic title"
                                    value={form.title_ar}
                                    onChange={(e) => setForm((f) => ({ ...f, title_ar: e.target.value }))}
                                    dir="rtl"
                                    className={formErrors.title_ar ? 'border-red-500' : ''}
                                />
                                {formErrors.title_ar && <p className="mt-1 text-sm text-red-500">{formErrors.title_ar}</p>}
                            </div>
                        </div>
                        <div className="grid grid-cols-1 gap-4 md:grid-cols-2">
                            <div>
                                <label className="mb-1 block font-medium">Description (EN)</label>
                                <ReactQuill
                                    value={form.description_en}
                                    onChange={(value) => setForm((f) => ({ ...f, description_en: value }))}
                                    theme="snow"
                                    className="h-40"
                                />
                            </div>
                            <div>
                                <label className="mb-1 block font-medium">Description (AR)</label>
                                <ReactQuill
                                    value={form.description_ar}
                                    onChange={(value) => setForm((f) => ({ ...f, description_ar: value }))}
                                    theme="snow"
                                    className="h-40"
                                />
                            </div>
                        </div>
                        <div className="pt-8">
                            <label className="mb-1 block font-medium">Features</label>
                            <div className="flex gap-2">
                                <Input
                                    placeholder="Add a feature"
                                    value={newFeature}
                                    onChange={(e) => setNewFeature(e.target.value)}
                                    onKeyDown={(e) => {
                                        if (e.key === 'Enter') {
                                            e.preventDefault();
                                            handleAddFeature();
                                        }
                                    }}
                                />
                                <Button type="button" onClick={handleAddFeature}>Add</Button>
                            </div>
                            <div className="mt-2 flex flex-wrap gap-1">
                                {form.features.map((feature) => (
                                    <Badge key={feature} variant="secondary" className="flex items-center gap-1">
                                        {feature}
                                        <button
                                            type='button'
                                            className="ring-offset-background rounded-full outline-none focus:ring-2 focus:ring-ring focus:ring-offset-2"
                                            onClick={() => handleRemoveFeature(feature)}
                                        >
                                            <X className="h-3 w-3 text-muted-foreground hover:text-foreground" />
                                        </button>
                                    </Badge>
                                ))}
                            </div>
                        </div>
                        <div className="grid grid-cols-1 gap-4 md:grid-cols-2">
                            <div>
                                <label className="mb-1 block font-medium">Price <span className='text-red-500'>*</span></label>
                                <Input
                                    type="number"
                                    min="0"
                                    step="0.01"
                                    placeholder="Enter price"
                                    value={form.price}
                                    onChange={(e) => setForm((f) => ({ ...f, price: e.target.value }))}
                                    className={formErrors.price ? 'border-red-500' : ''}
                                />
                                {formErrors.price && <p className="mt-1 text-sm text-red-500">{formErrors.price}</p>}
                            </div>
                            <div>
                                <label className="mb-1 block font-medium">Duration</label>
                                <Select value={form.duration} onValueChange={(v) => setForm((f) => ({ ...f, duration: v }))}>
                                    <SelectTrigger className={formErrors.duration ? 'border-red-500' : ''}>
                                        <SelectValue placeholder="Select duration" />
                                    </SelectTrigger>
                                    <SelectContent>
                                        <SelectItem value="monthly">Monthly</SelectItem>
                                        <SelectItem value="yearly">Yearly</SelectItem>
                                    </SelectContent>
                                </Select>
                                {formErrors.duration && <p className="mt-1 text-sm text-red-500">{formErrors.duration}</p>}
                            </div>
                        </div>

                        <div className="grid grid-cols-1 gap-4 md:grid-cols-3">
                            <div>
                                <label className="mb-1 block font-medium">Status</label>
                                <Select value={form.status} onValueChange={(v) => setForm((f) => ({ ...f, status: v }))}>
                                    <SelectTrigger className={formErrors.status ? 'border-red-500' : ''}>
                                        <SelectValue placeholder="Select status" />
                                    </SelectTrigger>
                                    <SelectContent>
                                        <SelectItem value="active">Active</SelectItem>
                                        <SelectItem value="suspended">Suspended</SelectItem>
                                    </SelectContent>
                                </Select>
                                {formErrors.status && <p className="mt-1 text-sm text-red-500">{formErrors.status}</p>}
                            </div>
                            <div>
                                <label className="mb-1 block font-medium">Sort Order</label>
                                <Input
                                    type="number"
                                    min="0"
                                    placeholder="Sort order"
                                    value={form.sort_order}
                                    onChange={(e) => setForm((f) => ({ ...f, sort_order: Number(e.target.value) }))}
                                    className={formErrors.sort_order ? 'border-red-500' : ''}
                                />
                                {formErrors.sort_order && <p className="mt-1 text-sm text-red-500">{formErrors.sort_order}</p>}
                            </div>
                            <div>
                                <label className="mb-1 block font-medium">Ad Limit</label>
                                <Input
                                    type="number"
                                    min="0"
                                    placeholder="Ad limit"
                                    value={form.ad_limit}
                                    onChange={(e) => setForm((f) => ({ ...f, ad_limit: Number(e.target.value) }))}
                                    className={formErrors.ad_limit ? 'border-red-500' : ''}
                                />
                                {formErrors.ad_limit && <p className="mt-1 text-sm text-red-500">{formErrors.ad_limit}</p>}
                            </div>
                        </div>
                    </div>
                    <DialogFooter>
                        <Button variant="outline" onClick={closeModal} disabled={isSubmitting}>
                            Cancel
                        </Button>
                        <Button onClick={handleSave} disabled={isSubmitting}>
                            {isSubmitting ? (editSub ? 'Updating...' : 'Creating...') : (editSub ? 'Update' : 'Create')}
                        </Button>
                    </DialogFooter>
                </DialogContent>
            </Dialog>

            {/* Confirm Suspend/Activate Dialog */}
            <Dialog open={confirmDialog.open} onOpenChange={(open) => setConfirmDialog({ ...confirmDialog, open })}>
                <DialogContent>
                    <DialogHeader>
                        <DialogTitle>{confirmDialog.action === 'activate' ? 'Activate Subscription' : 'Suspend Subscription'}</DialogTitle>
                    </DialogHeader>
                    <div className="py-4">
                        <p>
                            {confirmDialog.action === 'activate'
                                ? 'Are you sure you want to activate this subscription?'
                                : 'Are you sure you want to suspend this subscription?'}
                        </p>
                    </div>
                    <DialogFooter>
                        <Button variant="outline" onClick={() => setConfirmDialog({ open: false, subscription: null, action: null })}>
                            Cancel
                        </Button>
                        <Button
                            variant={confirmDialog.action === 'activate' ? 'default' : 'destructive'}
                            onClick={confirmToggleStatus}
                            disabled={toggleLoadingId === confirmDialog.subscription?.id}
                        >
                            {toggleLoadingId === confirmDialog.subscription?.id
                                ? confirmDialog.action === 'activate'
                                    ? 'Activating...'
                                    : 'Suspending...'
                                : confirmDialog.action === 'activate'
                                    ? 'Activate'
                                    : 'Suspend'}
                        </Button>
                    </DialogFooter>
                </DialogContent>
            </Dialog>

            {/* Delete Confirmation Dialog */}
            <Dialog open={deleteDialogOpen} onOpenChange={setDeleteDialogOpen}>
                <DialogContent>
                    <DialogHeader>
                        <DialogTitle>Confirm Deletion</DialogTitle>
                    </DialogHeader>
                    <div className="py-4">
                        <p>Are you sure you want to delete this subscription? This action cannot be undone.</p>
                    </div>
                    <DialogFooter>
                        <Button variant="outline" onClick={() => setDeleteDialogOpen(false)} disabled={isDeleting}>
                            Cancel
                        </Button>
                        <Button variant="destructive" onClick={handleDelete} disabled={isDeleting}>
                            {isDeleting ? 'Deleting...' : 'Delete'}
                        </Button>
                    </DialogFooter>
                </DialogContent>
            </Dialog>
        </div>
    );
}
