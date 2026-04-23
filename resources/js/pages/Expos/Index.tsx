import { ActionButtonDelete, ActionButtonSuspend } from '@/components/action-button';
import ExportButton from '@/components/export-button';
import { useLanguage } from '@/components/language-context';
import { StatusFilter } from '@/components/ui/StatusFilter';
import { Button } from '@/components/ui/button';
import { Dialog, DialogContent, DialogFooter, DialogHeader, DialogTitle } from '@/components/ui/dialog';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Pagination } from '@/components/ui/pagination';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select';
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs';
import { Textarea } from '@/components/ui/textarea';
import AppLayout from '@/layouts/app-layout';
import { Head, Link, router, useForm, usePage } from '@inertiajs/react';
import dayjs from 'dayjs';
import DOMPurify from 'dompurify';
import { useEffect, useRef, useState } from 'react';
import { toast } from 'react-hot-toast';

interface Expo {
    id: number;
    name_en: string;
    name_ar: string;
    brand_name_en: string;
    brand_name_ar: string;
    description_en: string;
    description_ar: string;
    background_color: string;
    background_image: string | null;
    font_style: string;
    font_size: string;
    font_weight: string;
    banner_image: string | null;
    start_date: string;
    end_date: string;
    vendor_slot_capacity: number;
    product_capacity_per_slot: number;
    slot_pricing: number;
    status: 'active' | 'inactive' | 'suspended' | 'expired' | 'upcoming';
    vendors?: Vendor[];
    expo_products?: Array<{
        id: number;
        product?: {
            id: number;
            name: string;
            price: number;
            status: string;
            category: string;
            stock: number;
        };
        vendor?: {
            id: number;
            name: string;
            brand_name_en?: string;
            brand_name_ar?: string;
            email: string;
        };
    }>;
}

interface Vendor {
    id: number;
    name: string;
    brand_name_en?: string;
    email: string;
    phone: string;
    status: string;
    commission: string;
    kyc_status: string;
}

interface Product {
    id: number;
    name: string;
    vendor_name: string;
    vendor_brand_name_en?: string;
    vendor_brand_name_ar?: string;
    price: number;
    status: string;
}

// Status color mapping
const statusColors: Record<string, string> = {
    upcoming: 'bg-amber-500',
    active: 'bg-green-600',
    inactive: 'bg-gray-500',
    suspended: 'bg-red-600',
    expired: 'bg-gray-700',
};

function ExpoPage() {
    const { language } = useLanguage();
    const page = usePage();
    const expos = page.props.expos;
    const filters = page.props.filters || {};

    // Filter state (controlled by backend)
    const [nameFilter, setNameFilter] = useState(filters.search || '');
    const [statusFilter, setStatusFilter] = useState(filters.status || 'all');
    const [fromDate, setFromDate] = useState(filters.from || '');
    const [toDate, setToDate] = useState(filters.to || '');

    // Pagination state
    const currentPage = expos.current_page;
    const lastPage = expos.last_page;
    const perPage = expos.per_page;
    const total = expos.total;
    const links = expos.links;

    // On filter change, fetch from backend
    useEffect(() => {
        setNameFilter(filters.search || '');
        setStatusFilter(filters.status || 'all');
        setFromDate(filters.from || '');
        setToDate(filters.to || '');
    }, [filters]);

    const handleFilterChange = (newFilters: any) => {
        router.get(route('expos.index'), { ...newFilters, page: 1 }, { preserveState: true, replace: true });
    };

    const handlePageChange = (pageNum: number) => {
        router.get(
            route('expos.index'),
            {
                search: nameFilter,
                status: statusFilter,
                from: fromDate,
                to: toDate,
                page: pageNum,
            },
            { preserveState: true, replace: true },
        );
    };

    const [isModalOpen, setIsModalOpen] = useState(false);
    const [editingExpo, setEditingExpo] = useState<Expo | null>(null);

    const { data, setData, post, put, processing, errors, reset } = useForm<{
        name_en: string;
        name_ar: string;
        brand_name_en: string;
        brand_name_ar: string;
        description_en: string;
        description_ar: string;
        background_color: string;
        background_image: File | string | null;
        font_style: string;
        font_size: string;
        font_weight: string;
        banner_image: File | string | null;
        start_date: string;
        end_date: string;
        vendor_slot_capacity: number;
        product_capacity_per_slot: number;
        slot_pricing: number;
        status: 'active' | 'inactive' | 'suspended' | 'expired' | 'upcoming';
    }>({
        name_en: '',
        name_ar: '',
        brand_name_en: '',
        brand_name_ar: '',
        description_en: '',
        description_ar: '',
        background_color: '#ffffff',
        background_image: null,
        font_style: 'Arial',
        font_size: '16px',
        font_weight: '400',
        banner_image: null,
        start_date: '',
        end_date: '',
        vendor_slot_capacity: 0,
        product_capacity_per_slot: 0,
        slot_pricing: 0,
        status: 'active',
    });

    const [deleteDialogOpen, setDeleteDialogOpen] = useState(false);
    const [isDeleting, setIsDeleting] = useState(false);

    // Only keep the Create Expo button
    // ...
    <div className="mb-4 flex flex-col gap-2 sm:flex-row sm:items-center sm:justify-between">
        <h1 className="text-2xl font-bold">Expo Manager</h1>
        <div className="flex flex-col items-center gap-2 sm:flex-row">
            <input
                type="text"
                className="rounded border px-2 py-1"
                value={nameFilter ?? ''}
                onChange={(e) => {
                    setNameFilter(e.target.value);
                    setCurrentPage(1);
                }}
                placeholder="Search by name..."
            />
            <StatusFilter
                value={statusFilter}
                onChange={(v) => {
                    setStatusFilter(v);
                    setCurrentPage(1);
                }}
                statusOptions={[
                    { value: 'all', label: 'All Statuses' },
                    { value: 'upcoming', label: 'Upcoming' },
                    { value: 'active', label: 'Active' },
                    { value: 'inactive', label: 'Inactive' },
                    { value: 'suspended', label: 'Suspended' },
                    { value: 'expired', label: 'Expired' },
                ]}
                placeholder="Filter by status"
                className="w-40"
            />
            <Input
                type="date"
                value={fromDate}
                onChange={(e) => {
                    setFromDate(e.target.value);
                    setCurrentPage(1);
                }}
                className="w-40"
            />
            <Input
                type="date"
                value={toDate}
                min={fromDate || undefined}
                onChange={(e) => {
                    setToDate(e.target.value);
                    setCurrentPage(1);
                }}
                className="w-40"
            />
            <Link href={route('expos.create')}>
                <Button variant="default">Create Expo</Button>
            </Link>
        </div>
    </div>;

    const closeModal = () => {
        setIsModalOpen(false);
        setEditingExpo(null);
        reset();
    };

    const handleSave = () => {
        const onFinish = () => {
            closeModal();
        };

        if (editingExpo) {
            put(route('expos.update', editingExpo.id), {
                forceFormData: true,
                onFinish,
                preserveState: false,
            });
        } else {
            post(route('expos.store'), {
                onFinish,
                preserveState: false,
            });
        }
    };

    const openDeleteDialog = (expo: Expo) => {
        setSelectedExpo(expo);
        setDeleteDialogOpen(true);
    };

    const handleDelete = () => {
        if (selectedExpo) {
            setIsDeleting(true);
            router.delete(route('expos.destroy', selectedExpo.id), {
                onSuccess: () => {
                    setDeleteDialogOpen(false);
                    setSelectedExpo(null);
                    toast.success('Expo deleted successfully!');
                },
                onFinish: () => setIsDeleting(false),
            });
        }
    };

    // Status color utility
    const getStatusColor = (status: string) => statusColors[status.toLowerCase()] || 'bg-gray-700';

    const getStatusLabelEn = (status: string) => {
        switch (status.toLowerCase()) {
            case 'active':
                return 'Active';
            case 'upcoming':
                return 'Upcoming';
            case 'expired':
                return 'Expired';
            case 'suspended':
                return 'Suspended';
            case 'inactive':
                return 'Inactive';
            default:
                return status;
        }
    };

    const getStatusLabelAr = (status: string) => {
        switch (status.toLowerCase()) {
            case 'active':
                return 'نشط';
            case 'upcoming':
                return 'قادم';
            case 'expired':
                return 'منتهي';
            case 'suspended':
                return 'معلق';
            case 'inactive':
                return 'غير نشط';
            default:
                return status;
        }
    };

    const [selectedExpo, setSelectedExpo] = useState<Expo | null>(null);
    const [isViewModalOpen, setIsViewModalOpen] = useState(false);
    const [tabValue, setTabValue] = useState('info');

    type ExpoWithVendors = Expo & { vendors?: Vendor[]; products?: Product[] };
    const handleView = (expo: ExpoWithVendors) => {
        setSelectedExpo(expo);
        setIsViewModalOpen(true);
    };

    const handleCloseViewModal = () => {
        setIsViewModalOpen(false);
        setSelectedExpo(null);
        setTabValue('info');
    };

    const [toggleLoadingId, setToggleLoadingId] = useState<number | null>(null);

    const [confirmDialog, setConfirmDialog] = useState<{ open: boolean; expo: Expo | null; action: 'suspend' | 'activate' | null }>({
        open: false,
        expo: null,
        action: null,
    });

    const handleToggleStatus = (expo: Expo) => {
        setConfirmDialog({ open: true, expo, action: expo.status === 'suspended' ? 'activate' : 'suspend' });
    };

    const confirmToggleStatus = async () => {
        if (!confirmDialog.expo) return;
        const expo = confirmDialog.expo;
        const isActivating = expo.status === 'suspended';
        const isExpired = expo.end_date && dayjs(expo.end_date).isBefore(dayjs(), 'day');

        // If trying to activate and expired
        if (isActivating && isExpired) {
            toast.error('This expo is expired and cannot be activated.');
            setConfirmDialog({ open: false, expo: null, action: null });
            return;
        }
        // If already suspended and expired, and trying to suspend again
        if (!isActivating && isExpired) {
            toast.error('This expo is expired. You can only suspend it, not activate.');
            setConfirmDialog({ open: false, expo: null, action: null });
            return;
        }
        const newStatus = isActivating ? 'active' : 'suspended';
        setToggleLoadingId(expo.id);
        try {
            await router.post(
                route('expos.toggle-status', expo.id),
                { status: newStatus },
                {
                    onSuccess: () => {
                        setToggleLoadingId(null);
                        lastFlash.current.success = '';
                        lastFlash.current.error = '';
                        router.reload({ only: ['expos'] });
                    },
                    onError: () => {
                        setToggleLoadingId(null);
                        toast.error('Failed to update status.');
                    },
                    preserveState: true,
                },
            );
        } catch {
            setToggleLoadingId(null);
            toast.error('Failed to update status.');
        }
        setConfirmDialog({ open: false, expo: null, action: null });
    };

    const lastFlash = useRef({ success: '', error: '' });

    useEffect(() => {
        // eslint-disable-next-line @typescript-eslint/no-explicit-any
        const flash = (page.props as any).flash;
        if (flash?.success && flash.success !== lastFlash.current.success) {
            toast.success(flash.success);
            lastFlash.current.success = flash.success;
        }
        if (flash?.error && flash.error !== lastFlash.current.error) {
            toast.error(flash.error);
            lastFlash.current.error = flash.error;
        }
    }, [page.props]);

    return (
        <div className="p-6">
            <div className="mb-4 flex flex-col gap-2 sm:flex-row sm:items-center sm:justify-between">
                <h1 className="text-2xl font-bold">Expo Manager</h1>
                <div className="flex flex-col items-center gap-2 sm:flex-row">
                    <input
                        type="text"
                        className="rounded border px-2 py-1"
                        value={nameFilter}
                        onChange={(e) => {
                            setNameFilter(e.target.value);
                            handleFilterChange({
                                search: e.target.value,
                                status: statusFilter,
                                from: fromDate,
                                to: toDate,
                            });
                        }}
                        placeholder="Search by name..."
                    />
                    <StatusFilter
                        value={statusFilter}
                        onChange={(v) => {
                            setStatusFilter(v);
                            handleFilterChange({
                                search: nameFilter,
                                status: v,
                                from: fromDate,
                                to: toDate,
                            });
                        }}
                        statusOptions={[
                            { value: 'all', label: 'All Statuses' },
                            { value: 'upcoming', label: 'Upcoming' },
                            { value: 'active', label: 'Active' },
                            { value: 'inactive', label: 'Inactive' },
                            { value: 'suspended', label: 'Suspended' },
                            { value: 'expired', label: 'Expired' },
                        ]}
                        placeholder="Filter by status"
                        className="w-40"
                    />
                    <Input
                        type="date"
                        min="2015-01-01"
                        onChange={(e) => {
                            setFromDate(e.target.value);
                            handleFilterChange({
                                search: nameFilter,
                                status: statusFilter,
                                from: e.target.value,
                                to: toDate,
                            });
                        }}
                        className="w-40"
                    />
                    <Input
                        type="date"
                        value={toDate}
                        min="2015-01-01"
                        onChange={(e) => {
                            setToDate(e.target.value);
                            handleFilterChange({
                                search: nameFilter,
                                status: statusFilter,
                                from: fromDate,
                                to: e.target.value,
                            });
                        }}
                        className="w-40"
                    />

                    <ExportButton
                        title={language === 'ar' ? 'تصدير CSV' : 'Export CSV'}
                        onClick={() => {
                            // Build query string from filters
                            const params = new URLSearchParams();
                            if (nameFilter) params.append('search', nameFilter);
                            if (statusFilter && statusFilter !== 'all') params.append('status', statusFilter);
                            if (fromDate) params.append('from', fromDate);
                            if (toDate) params.append('to', toDate);
                            const url = params.toString() ? `${route('expos.export')}?${params.toString()}` : route('expos.export');
                            window.location.href = url;
                        }}
                    />

                    <Link href={route('expos.create')}>
                        <Button variant="default">Create Expo</Button>
                    </Link>
                </div>
            </div>
            <table className="min-w-full border bg-white dark:bg-neutral-900">
                <thead>
                    <tr>
                        <th className="border px-4 py-2">#</th>
                        <th className="border px-4 py-2">{language === 'ar' ? 'اسم المعرض' : 'Expo Name'}</th>
                        <th className="border px-4 py-2">{language === 'ar' ? 'البداية' : 'Start Date'}</th>
                        <th className="border px-4 py-2">{language === 'ar' ? 'النهاية' : 'End Date'}</th>
                        <th className="border px-4 py-2">{language === 'ar' ? 'المواد' : 'Total Slots'}</th>
                        <th className="border px-4 py-2">{language === 'ar' ? 'المواد' : 'Booked Slots'}</th>
                        <th className="border px-4 py-2">Total Amount</th>
                        <th className="border px-4 py-2">Reserved</th>
                        <th className="border px-4 py-2">{language === 'ar' ? 'الحالة' : 'Status'}</th>
                        <th className="border px-4 py-2">{language === 'ar' ? 'الإجراءات' : 'Actions'}</th>
                    </tr>
                </thead>
                <tbody>
                    {expos.data.map((expo: any, index: number) => (
                        <tr key={expo.id}>
                            <td className="border px-4 py-2 text-center">{(currentPage - 1) * perPage + index + 1}</td>
                            <td className="border px-4 py-2 text-center">{language === 'ar' ? expo.name_ar : expo.name_en}</td>
                            <td className="border px-4 py-2 text-center">
                                {expo.start_date ? dayjs(expo.start_date).format('YYYY-MM-DD hh:mm:A') : ''}
                            </td>
                            <td className="border px-4 py-2 text-center">{expo.end_date ? dayjs(expo.end_date).format('YYYY-MM-DD hh:mm:A') : ''}</td>
                            <td className="border px-4 py-2 text-center">{expo.vendor_slot_capacity}</td>
                            <td className="border px-4 py-2 text-center">{expo.booked_slots}</td>
                            <td className="border px-4 py-2 text-center">KWD {expo.total_amount}</td>
                            {/* % Reserved */}
                            <td className="border px-4 py-2 text-center">
                                {expo.vendor_slot_capacity && expo.booked_slots != null
                                    ? `${Math.round((expo.booked_slots / expo.vendor_slot_capacity) * 100)}%`
                                    : '-'}
                            </td>

                            <td className="border px-4 py-2 text-center">
                                <span
                                    className={`inline-block min-w-[90px] rounded px-2 py-1 text-xs font-semibold ${getStatusColor(expo.status)} text-center text-white`}
                                >
                                    {language === 'ar' ? getStatusLabelAr(expo.status) : getStatusLabelEn(expo.status)}
                                </span>
                            </td>
                            <td className="space-x-2 border px-4 py-2 text-center">
                                <Button size="sm" variant="outline" onClick={() => handleView(expo)}>
                                    {language === 'ar' ? 'عرض' : 'View'}
                                </Button>
                                <Link href={route('expos.edit', expo.id)}>
                                    <Button size="sm" variant="outline">
                                        Edit
                                    </Button>
                                </Link>
                                <ActionButtonSuspend
                                    variant={expo.status === 'suspended' ? 'default' : 'outline'}
                                    btnTitle={
                                        toggleLoadingId === expo.id
                                            ? expo.status === 'suspended'
                                                ? language === 'ar'
                                                    ? 'يتم التفعيل...'
                                                    : 'Activating...'
                                                : language === 'ar'
                                                    ? 'يتم التعليق...'
                                                    : 'Suspending...'
                                            : expo.status === 'suspended'
                                                ? language === 'ar'
                                                    ? 'تفعيل'
                                                    : 'Activate'
                                                : language === 'ar'
                                                    ? 'تعليق'
                                                    : 'Suspend'
                                    }
                                    onClick={() => handleToggleStatus(expo)}
                                />
                                <ActionButtonDelete btnTitle={language === 'ar' ? 'حذف' : 'Delete'} onClick={() => openDeleteDialog(expo)} />
                            </td>
                        </tr>
                    ))}
                </tbody>
            </table>
            {/* Pagination */}
            {lastPage > 1 && (
                <div className="mt-6">
                    <Pagination
                        currentPage={currentPage}
                        lastPage={lastPage}
                        total={total}
                        perPage={perPage}
                        links={links}
                        onPageChange={handlePageChange}
                    />
                </div>
            )}
            <Dialog open={isModalOpen} onOpenChange={setIsModalOpen}>
                <DialogContent className="w-full" style={{ maxWidth: '80rem', width: '100%' }}>
                    <DialogHeader>
                        <DialogTitle>
                            {editingExpo ? (language === 'ar' ? 'تعديل المعرض' : 'Edit Expo') : language === 'ar' ? 'إنشاء معرض' : 'Create Expo'}
                        </DialogTitle>
                    </DialogHeader>
                    <div className="overflow-x-auto">
                        <div className="grid grid-cols-1 gap-6 py-4 md:grid-cols-3">
                            {tabValue === 'info' && (
                                <>
                                    <div className="space-y-4">
                                        <div>
                                            <Label htmlFor="name_en">Expo Name (EN)</Label>
                                            <Input
                                                id="name_en"
                                                name="name_en"
                                                value={data.name_en}
                                                onChange={(e) => setData('name_en', e.target.value)}
                                            />
                                            {errors.name_en && <div className="mt-1 text-xs text-red-500">{errors.name_en}</div>}
                                        </div>
                                        <div>
                                            <Label htmlFor="name_ar">Expo Name (AR)</Label>
                                            <Input
                                                id="name_ar"
                                                name="name_ar"
                                                value={data.name_ar}
                                                onChange={(e) => setData('name_ar', e.target.value)}
                                                dir="rtl"
                                            />
                                            {errors.name_ar && <div className="mt-1 text-xs text-red-500">{errors.name_ar}</div>}
                                        </div>
                                        <div>
                                            <Label htmlFor="description_en">Description (EN)</Label>
                                            <Textarea
                                                id="description_en"
                                                name="description_en"
                                                value={data.description_en}
                                                onChange={(e) => setData('description_en', e.target.value)}
                                            />
                                            {errors.description_en && <div className="mt-1 text-xs text-red-500">{errors.description_en}</div>}
                                        </div>
                                        <div>
                                            <Label htmlFor="description_ar">Description (AR)</Label>
                                            <Textarea
                                                id="description_ar"
                                                name="description_ar"
                                                value={data.description_ar}
                                                onChange={(e) => setData('description_ar', e.target.value)}
                                                dir="rtl"
                                            />
                                            {errors.description_ar && <div className="mt-1 text-xs text-red-500">{errors.description_ar}</div>}
                                        </div>
                                    </div>

                                    <div className="space-y-4">
                                        <div className="flex items-center gap-4">
                                            <div className="flex-1">
                                                <Label htmlFor="background_color">Background Color</Label>
                                                <Input
                                                    id="background_color"
                                                    type="color"
                                                    name="background_color"
                                                    value={data.background_color}
                                                    onChange={(e) => setData('background_color', e.target.value)}
                                                    className="p-1"
                                                />
                                                {errors.background_color && (
                                                    <div className="mt-1 text-xs text-red-500">{errors.background_color}</div>
                                                )}
                                            </div>
                                            <div className="flex-1">
                                                <Label>Status</Label>
                                                <Select
                                                    value={data.status}
                                                    onValueChange={(value: 'active' | 'inactive' | 'suspended' | 'expired' | 'upcoming') =>
                                                        setData('status', value)
                                                    }
                                                >
                                                    <SelectTrigger>
                                                        <SelectValue placeholder="Select status" />
                                                    </SelectTrigger>
                                                    <SelectContent>
                                                        <SelectItem value="upcoming">Upcoming</SelectItem>
                                                        <SelectItem value="active">Active</SelectItem>
                                                        <SelectItem value="inactive">Inactive</SelectItem>
                                                        <SelectItem value="suspended">Suspended</SelectItem>
                                                        <SelectItem value="expired">Expired</SelectItem>
                                                    </SelectContent>
                                                </Select>
                                                {errors.status && <div className="mt-1 text-xs text-red-500">{errors.status}</div>}
                                            </div>
                                        </div>
                                        <div>
                                            <Label htmlFor="font_style">Font Style</Label>
                                            <Input
                                                id="font_style"
                                                name="font_style"
                                                value={data.font_style}
                                                onChange={(e) => setData('font_style', e.target.value)}
                                            />
                                            {errors.font_style && <div className="mt-1 text-xs text-red-500">{errors.font_style}</div>}
                                        </div>
                                        <div className="flex gap-4">
                                            <div className="flex-1">
                                                <Label htmlFor="font_size">Font Size (e.g., 16px)</Label>
                                                <Input
                                                    id="font_size"
                                                    name="font_size"
                                                    value={data.font_size}
                                                    onChange={(e) => setData('font_size', e.target.value)}
                                                />
                                                {errors.font_size && <div className="mt-1 text-xs text-red-500">{errors.font_size}</div>}
                                            </div>
                                            <div className="flex-1">
                                                <Label htmlFor="font_weight">Font Weight (e.g., 400)</Label>
                                                <Input
                                                    id="font_weight"
                                                    name="font_weight"
                                                    value={data.font_weight}
                                                    onChange={(e) => setData('font_weight', e.target.value)}
                                                />
                                                {errors.font_weight && <div className="mt-1 text-xs text-red-500">{errors.font_weight}</div>}
                                            </div>
                                        </div>
                                        <div>
                                            <Label htmlFor="background_image">Background Image</Label>
                                            <Input
                                                id="background_image"
                                                type="file"
                                                name="background_image"
                                                onChange={(e) =>
                                                    setData(
                                                        'background_image',
                                                        e.target.files && e.target.files[0] ? (e.target.files[0] as File) : null,
                                                    )
                                                }
                                                accept="image/*"
                                            />
                                            {errors.background_image && <div className="mt-1 text-xs text-red-500">{errors.background_image}</div>}
                                            {editingExpo?.background_image && typeof editingExpo.background_image === 'string' && (
                                                <img
                                                    src={editingExpo.background_image}
                                                    alt="Current Background"
                                                    className="mt-2 h-12 w-20 rounded object-cover"
                                                />
                                            )}
                                        </div>
                                        <div>
                                            <Label htmlFor="banner_image">Banner Image</Label>
                                            <Input
                                                id="banner_image"
                                                type="file"
                                                name="banner_image"
                                                onChange={(e) =>
                                                    setData('banner_image', e.target.files && e.target.files[0] ? (e.target.files[0] as File) : null)
                                                }
                                                accept="image/*"
                                            />
                                            {errors.banner_image && <div className="mt-1 text-xs text-red-500">{errors.banner_image}</div>}
                                            {editingExpo?.banner_image && typeof editingExpo.banner_image === 'string' && (
                                                <img
                                                    src={editingExpo.banner_image}
                                                    alt="Current Banner"
                                                    className="mt-2 h-16 w-32 rounded object-cover"
                                                />
                                            )}
                                        </div>
                                    </div>

                                    <div className="space-y-4">
                                        <div className="flex gap-4">
                                            <div className="flex-1">
                                                <Label htmlFor="start_date">Start Date</Label>
                                                <Input
                                                    id="start_date"
                                                    type="date"
                                                    name="start_date"
                                                    value={data.start_date}
                                                    onChange={(e) => setData('start_date', e.target.value)}
                                                />
                                                {errors.start_date && <div className="mt-1 text-xs text-red-500">{errors.start_date}</div>}
                                            </div>
                                            <div className="flex-1">
                                                <Label htmlFor="end_date">End Date</Label>
                                                <Input
                                                    id="end_date"
                                                    type="date"
                                                    name="end_date"
                                                    value={data.end_date}
                                                    onChange={(e) => setData('end_date', e.target.value)}
                                                />
                                                {errors.end_date && <div className="mt-1 text-xs text-red-500">{errors.end_date}</div>}
                                            </div>
                                        </div>
                                        <div>
                                            <Label htmlFor="slot_pricing">Slot Pricing</Label>
                                            <Input
                                                id="slot_pricing"
                                                type="number"
                                                name="slot_pricing"
                                                value={data.slot_pricing}
                                                onChange={(e) => setData('slot_pricing', parseFloat(e.target.value) || 0)}
                                            />
                                            {errors.slot_pricing && <div className="mt-1 text-xs text-red-500">{errors.slot_pricing}</div>}
                                        </div>
                                        <div>
                                            <Label htmlFor="vendor_slot_capacity">Vendor Slot Capacity</Label>
                                            <Input
                                                id="vendor_slot_capacity"
                                                type="number"
                                                name="vendor_slot_capacity"
                                                value={data.vendor_slot_capacity}
                                                onChange={(e) => setData('vendor_slot_capacity', parseInt(e.target.value) || 0)}
                                            />
                                            {errors.vendor_slot_capacity && (
                                                <div className="mt-1 text-xs text-red-500">{errors.vendor_slot_capacity}</div>
                                            )}
                                        </div>
                                        <div>
                                            <Label htmlFor="product_capacity_per_slot">Product Capacity Per Slot</Label>
                                            <Input
                                                id="product_capacity_per_slot"
                                                type="number"
                                                name="product_capacity_per_slot"
                                                value={data.product_capacity_per_slot}
                                                onChange={(e) => setData('product_capacity_per_slot', parseInt(e.target.value) || 0)}
                                            />
                                            {errors.product_capacity_per_slot && (
                                                <div className="mt-1 text-xs text-red-500">{errors.product_capacity_per_slot}</div>
                                            )}
                                        </div>
                                    </div>
                                </>
                            )}
                            {tabValue === 'design' && (
                                <>
                                    <div>
                                        <h3 className="mb-2 font-bold">Design & Branding</h3>
                                        <div className="mb-2 flex items-center gap-4">
                                            <div>
                                                <span className="font-semibold">Background Color:</span>
                                                <span
                                                    className="ml-2 inline-block h-6 w-6 rounded border"
                                                    style={{ background: data.background_color || '#fff' }}
                                                ></span>
                                            </div>
                                            {data.background_image && typeof data.background_image === 'string' && (
                                                <div>
                                                    <span className="font-semibold">Background Image:</span>
                                                    <img
                                                        src={data.background_image}
                                                        alt="bg"
                                                        className="ml-2 inline-block h-10 w-10 rounded object-cover"
                                                    />
                                                </div>
                                            )}
                                        </div>
                                        <div>
                                            <span className="font-semibold">Font:</span> {data.font_style || '-'} / {data.font_size || '-'} /{' '}
                                            {data.font_weight || '-'}
                                        </div>
                                    </div>
                                </>
                            )}
                            {tabValue === 'slot' && (
                                <>
                                    <div>
                                        <h3 className="mb-2 font-bold">Slot Configuration</h3>
                                        <div>
                                            <span className="font-semibold">Total Slot Capacity:</span> {data.vendor_slot_capacity}
                                        </div>
                                        <div>
                                            <span className="font-semibold">Products per Slot:</span> {data.product_capacity_per_slot}
                                        </div>
                                        <div>
                                            <span className="font-semibold">Pricing:</span>
                                        </div>
                                        <ul className="ml-4 text-sm">
                                            <li>Slot 1–5: KWD 10</li>
                                            <li>Slot 6–10: KWD 8</li>
                                        </ul>
                                    </div>
                                </>
                            )}
                            {tabValue === 'banner' && (
                                <>
                                    <div>
                                        <h3 className="mb-2 font-bold">Banner</h3>
                                        {data.banner_image && typeof data.banner_image === 'string' ? (
                                            <a href={data.banner_image} target="_blank" rel="noopener noreferrer">
                                                <img src={data.banner_image} alt="Banner" className="h-16 w-32 rounded object-cover shadow" />
                                            </a>
                                        ) : (
                                            <span className="text-muted-foreground text-xs">No banner uploaded</span>
                                        )}
                                    </div>
                                </>
                            )}
                            {tabValue === 'vendors' && (
                                <>
                                    <div>
                                        <h3 className="mb-2 font-bold">Vendors & Products</h3>
                                        <div className="flex gap-4">
                                            <div>
                                                <span className="font-semibold">Vendors Registered:</span> 12
                                            </div>
                                            <div>
                                                <span className="font-semibold">Products Submitted:</span> 34
                                            </div>
                                        </div>
                                    </div>
                                </>
                            )}
                        </div>
                    </div>
                    <DialogFooter>
                        <Button variant="outline" onClick={closeModal}>
                            Cancel
                        </Button>
                        <Button onClick={handleSave} disabled={processing}>
                            {processing ? 'Saving...' : 'Save'}
                        </Button>
                    </DialogFooter>
                </DialogContent>
            </Dialog>
            <Dialog open={deleteDialogOpen} onOpenChange={setDeleteDialogOpen}>
                <DialogContent>
                    <DialogHeader>
                        <DialogTitle>{language === 'ar' ? 'تأكيد الحذف' : 'Confirm Deletion'}</DialogTitle>
                    </DialogHeader>
                    <div className="py-4">
                        <p>{language === 'ar' ? 'هل أنت متأكد أنك تريد حذف هذا المعرض؟' : 'Are you sure you want to delete this expo?'}</p>
                    </div>
                    <DialogFooter>
                        <Button variant="outline" onClick={() => setDeleteDialogOpen(false)} disabled={isDeleting}>
                            {language === 'ar' ? 'إلغاء' : 'Cancel'}
                        </Button>
                        <Button variant="destructive" onClick={handleDelete} disabled={isDeleting}>
                            {isDeleting ? (language === 'ar' ? 'جاري الحذف...' : 'Deleting...') : language === 'ar' ? 'حذف' : 'Delete'}
                        </Button>
                    </DialogFooter>
                </DialogContent>
            </Dialog>
            {/* Confirm Suspend/Activate Dialog */}
            <Dialog open={confirmDialog.open} onOpenChange={(open) => setConfirmDialog({ ...confirmDialog, open })}>
                <DialogContent>
                    <DialogHeader>
                        <DialogTitle>{confirmDialog.action === 'activate' ? 'Activate Expo' : 'Suspend Expo'}</DialogTitle>
                    </DialogHeader>
                    <div className="py-4">
                        <p>
                            {confirmDialog.action === 'activate'
                                ? 'Are you sure you want to activate this expo?'
                                : 'Are you sure you want to suspend this expo?'}
                        </p>
                    </div>
                    <DialogFooter>
                        <Button variant="outline" onClick={() => setConfirmDialog({ open: false, expo: null, action: null })}>
                            Cancel
                        </Button>
                        <Button
                            variant={confirmDialog.action === 'activate' ? 'default' : 'destructive'}
                            onClick={confirmToggleStatus}
                            disabled={toggleLoadingId === confirmDialog.expo?.id}
                        >
                            {toggleLoadingId === confirmDialog.expo?.id
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
            <Dialog open={isViewModalOpen} onOpenChange={handleCloseViewModal}>
                <DialogContent className="w-[98vw] max-w-[98vw] p-4 sm:w-[1000px] sm:max-w-[1200px] sm:p-6">
                    <DialogHeader>
                        <DialogTitle>Expo Details</DialogTitle>
                    </DialogHeader>
                    {selectedExpo && (
                        <Tabs value={tabValue} onValueChange={setTabValue} className="w-full">
                            <TabsList className="no-scrollbar mb-4 flex w-full cursor-pointer flex-nowrap gap-1 whitespace-nowrap sm:gap-2">
                                <TabsTrigger
                                    value="info"
                                    className="min-w-[120px] cursor-pointer px-2 py-2 text-sm sm:min-w-[140px] sm:px-4 sm:py-3 sm:text-base"
                                >
                                    Expo Info
                                </TabsTrigger>
                                <TabsTrigger
                                    value="slot"
                                    className="min-w-[120px] cursor-pointer px-2 py-2 text-sm sm:min-w-[140px] sm:px-4 sm:py-3 sm:text-base"
                                >
                                    Slot Configuration
                                </TabsTrigger>
                                <TabsTrigger
                                    value="vendors"
                                    className="min-w-[120px] cursor-pointer px-2 py-2 text-sm sm:min-w-[140px] sm:px-4 sm:py-3 sm:text-base"
                                >
                                    Vendors
                                </TabsTrigger>
                                <TabsTrigger
                                    value="products"
                                    className="min-w-[120px] cursor-pointer px-2 py-2 text-sm sm:min-w-[140px] sm:px-4 sm:py-3 sm:text-base"
                                >
                                    Products
                                </TabsTrigger>
                            </TabsList>
                            <TabsContent value="info">
                                <div className="space-y-2" style={{ maxHeight: '70vh', overflowY: 'auto' }}>
                                    <div>
                                        <span className="font-semibold">Expo Name (EN):</span> {selectedExpo.name_en}
                                    </div>
                                    <div>
                                        <span className="font-semibold">Expo Name (AR):</span> {selectedExpo.name_ar}
                                    </div>
                                    <div>
                                        <span className="font-semibold">Description (EN):</span>{' '}
                                        {selectedExpo.description_en ? (
                                            <span
                                                dangerouslySetInnerHTML={{
                                                    __html: DOMPurify.sanitize(selectedExpo.description_en, {
                                                        ALLOWED_TAGS: ['b', 'strong', 'i', 'em', 'u', 'br'],
                                                    }),
                                                }}
                                            />
                                        ) : null}
                                    </div>
                                    <div>
                                        <span className="font-semibold">Description (AR):</span>{' '}
                                        {selectedExpo.description_ar ? (
                                            <span
                                                dir="rtl"
                                                dangerouslySetInnerHTML={{
                                                    __html: DOMPurify.sanitize(selectedExpo.description_ar, {
                                                        ALLOWED_TAGS: ['b', 'strong', 'i', 'em', 'u', 'br'],
                                                    }),
                                                }}
                                            />
                                        ) : null}
                                    </div>
                                    <div>
                                        <span className="font-semibold">Start Date:</span> {selectedExpo.start_date}
                                    </div>
                                    <div>
                                        <span className="font-semibold">End Date:</span> {selectedExpo.end_date}
                                    </div>
                                    {/* Font + Status in one column */}
                                    <span className="mb-1 font-semibold">Font Size: </span>
                                    <span> {selectedExpo.font_size || '-'}</span>

                                    <div>
                                        <span className="mt-2 mb-1 font-semibold">Status : </span>
                                        <span
                                            className={`inline-block min-w-[90px] rounded px-2 py-1 text-xs font-semibold ${getStatusColor(selectedExpo.status)} text-center text-white`}
                                        >
                                            {getStatusLabelEn(selectedExpo.status)}
                                        </span>
                                    </div>
                                    <div className="mt-2 flex flex-row items-center gap-6">
                                        {/* BG Color */}
                                        <div className="flex flex-col items-center">
                                            <span className="mb-1 font-semibold">BG Color</span>
                                            <span
                                                className="inline-block h-16 w-24 rounded border align-middle"
                                                style={{ background: selectedExpo.background_color || '#fff' }}
                                            ></span>
                                        </div>
                                        {/* BG Image */}
                                        <div className="flex flex-col items-center">
                                            <span className="mb-1 font-semibold">BG Image</span>
                                            {selectedExpo.background_image && typeof selectedExpo.background_image === 'string' ? (
                                                <a
                                                    href={selectedExpo.background_image || '#'}
                                                    target="_blank"
                                                    rel="noopener noreferrer"
                                                >
                                                    <img
                                                        src={selectedExpo.background_image}
                                                        alt="bg"
                                                        className="inline-block h-16 w-24 cursor-pointer rounded object-cover align-middle transition hover:scale-105"
                                                    />
                                                </a>
                                            ) : (
                                                <span className="text-muted-foreground text-xs">No image</span>
                                            )}
                                        </div>
                                        {/* Banner Image */}
                                        <div className="flex flex-col items-center">
                                            <span className="mb-1 font-semibold">Banner</span>
                                            {selectedExpo.banner_image && typeof selectedExpo.banner_image === 'string' ? (
                                                <a
                                                    href={selectedExpo.banner_image || '#'}
                                                    target="_blank"
                                                    rel="noopener noreferrer"
                                                >
                                                    <img
                                                        src={selectedExpo.banner_image}
                                                        alt="Banner"
                                                        className="inline-block h-16 w-24 cursor-pointer rounded object-cover align-middle shadow transition hover:scale-105"
                                                    />
                                                </a>
                                            ) : (
                                                <span className="text-muted-foreground text-xs">No banner</span>
                                            )}
                                        </div>
                                    </div>
                                </div>
                            </TabsContent>

                            <TabsContent value="slot">
                                <div className="space-y-2" style={{ maxHeight: '70vh', overflowY: 'auto' }}>
                                    <div>
                                        <span className="font-semibold">Total Slot Capacity:</span> {selectedExpo.vendor_slot_capacity}
                                    </div>
                                    <div>
                                        <span className="font-semibold">Products per Slot:</span> {selectedExpo.product_capacity_per_slot}
                                    </div>
                                    <div>
                                        <span className="font-semibold">Pricing:</span>
                                    </div>
                                    <ul className="ml-4 text-sm">
                                        {(() => {
                                            let pricing: Array<{ slot?: number; from?: number; to?: number; price: number }> = [];
                                            try {
                                                if (typeof selectedExpo.slot_pricing === 'string') {
                                                    pricing = JSON.parse(selectedExpo.slot_pricing);
                                                } else if (Array.isArray(selectedExpo.slot_pricing)) {
                                                    pricing = selectedExpo.slot_pricing;
                                                } else {
                                                    pricing = [];
                                                }
                                            } catch {
                                                pricing = [];
                                            }
                                            if (!Array.isArray(pricing) || pricing.length === 0) {
                                                return <li className="text-muted-foreground">No pricing set</li>;
                                            }
                                            return pricing.map((item, idx) => {
                                                if (item.slot !== undefined) {
                                                    return (
                                                        <li key={idx}>
                                                            Slot {item.slot}: KWD {item.price}
                                                        </li>
                                                    );
                                                } else if (item.from !== undefined && item.to !== undefined) {
                                                    return (
                                                        <li key={idx}>
                                                            Slots {item.from}–{item.to}: KWD {item.price}
                                                        </li>
                                                    );
                                                } else {
                                                    return null;
                                                }
                                            });
                                        })()}
                                    </ul>
                                </div>
                            </TabsContent>

                            <TabsContent value="vendors">
                                <table className="min-w-full border">
                                    <thead>
                                        <tr>
                                            <th className="border px-4 py-2 text-center">Brand Name</th>
                                            <th className="border px-4 py-2 text-center">Email</th>
                                            <th className="border px-4 py-2 text-center">Phone</th>
                                            <th className="border px-4 py-2 text-center">Status</th>
                                            <th className="border px-4 py-2 text-center">Commission</th>
                                            <th className="border px-4 py-2 text-center">KYC</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        {(selectedExpo.vendors || []).map((vendor: Vendor) => (
                                            <tr key={vendor.id}>
                                                <td className="border px-4 py-2 text-center">{vendor.brand_name_en || vendor.name}</td>
                                                <td className="border px-4 py-2 text-center">{vendor.email}</td>
                                                <td className="border px-4 py-2 text-center">{vendor.phone ? vendor.phone : '-'}</td>
                                                <td className="border px-4 py-2 text-center capitalize">{vendor.status}</td>
                                                <td className="border px-4 py-2 text-center capitalize">{vendor.commission}</td>
                                                <td className="border px-4 py-2 text-center capitalize">{vendor.kyc_status}</td>
                                            </tr>
                                        ))}
                                    </tbody>
                                </table>
                            </TabsContent>

                            <TabsContent value="products">
                                <table className="min-w-full border">
                                    <thead>
                                        <tr>
                                            <th className="border px-4 py-2 text-center">Name</th>
                                            <th className="border px-4 py-2 text-center">Price</th>
                                            <th className="border px-4 py-2 text-center">Stock</th>
                                            <th className="border px-4 py-2 text-center">Status</th>
                                            <th className="border px-4 py-2 text-center">Category</th>
                                            <th className="border px-4 py-2 text-center">Brand Name</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        {(selectedExpo.expo_products || []).map((ep) => (
                                            <tr key={ep.id}>
                                                <td className="border px-4 py-2 text-center">{ep.product?.name || '-'}</td>
                                                <td className="border px-4 py-2 text-center">{ep.product?.price ?? '-'}</td>
                                                <td className="border px-4 py-2 text-center">{ep.product?.stock || '-'}</td>
                                                <td className="border px-4 py-2 text-center capitalize">{ep.product?.status || '-'}</td>
                                                <td className="border px-4 py-2 text-center">{ep.product?.category || '-'}</td>
                                                <td className="border px-4 py-2 text-center">{ep.vendor?.brand_name_en || ep.vendor?.name || '-'}</td>
                                            </tr>
                                        ))}
                                    </tbody>
                                </table>
                            </TabsContent>
                        </Tabs>
                    )}
                    <DialogFooter>
                        <Button variant="outline" onClick={handleCloseViewModal}>
                            Close
                        </Button>
                    </DialogFooter>
                </DialogContent>
            </Dialog>
        </div>
    );
}

export default function ExpoIndex() {
    return (
        <AppLayout>
            <Head title="Expos" />
            <ExpoPage />
        </AppLayout>
    );
}
