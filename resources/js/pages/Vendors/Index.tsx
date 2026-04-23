import { Button } from '@/components/ui/button';
import { Dialog, DialogContent, DialogFooter, DialogHeader, DialogTitle } from '@/components/ui/dialog';
import { Input } from '@/components/ui/input';
import { Pagination as ShadcnPagination } from '@/components/ui/pagination';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select';
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs';
import AppLayout from '@/layouts/app-layout';
import { Head, Link, router, usePage } from '@inertiajs/react';
import dayjs from 'dayjs';
import { throttle } from 'lodash';
import { CreditCard, Eye, EyeOff, FileText, Image } from 'lucide-react';
import { useEffect, useState } from 'react';
import { toast } from 'react-hot-toast';
import ReactQuill from 'react-quill';
import 'react-quill/dist/quill.snow.css';

import { StatusFilter } from '@/components/ui/StatusFilter';
import {
    Dialog as ConfirmDialog,
    DialogContent as ConfirmDialogContent,
    DialogFooter as ConfirmDialogFooter,
    DialogHeader as ConfirmDialogHeader,
    DialogTitle as ConfirmDialogTitle,
} from '@/components/ui/dialog';

interface Vendor {
    id: number;
    name: string;
    brand_name_en: string | null;
    brand_name_ar: string | null;
    description_en: string | null;
    description_ar: string | null;
    email: string | null;
    phone: string | null;
    mobile: string | null;
    status: string;
    commission: string | null;
    kyc_status: string;
    kyc_rejection_reason: string | null;
    kyc_rejection_reason_en?: string | null;
    kyc_rejection_reason_ar?: string | null;
    kyc_documents: unknown[];
    subscription_id: number | null;
    logo?: string | null;
    use_armada_delivery?: boolean;
    armada_branch_id?: string | null;
    armada_branch_key?: string | null;
    user?: {
        phone?: string;
    };
}
interface PaginatedVendors {
    per_page: number;
    current_page: number;
    last_page: number;
    total: number;
    data: Vendor[];
    links: { url: string | null; label: string; active: boolean }[];
}

function Pagination({ links }: { links: PaginatedVendors['links'] }) {
    return (
        <div className="mt-4 flex flex-wrap justify-center">
            {links.map((link, index) => (
                <Link
                    key={index}
                    href={link.url || ''}
                    preserveState
                    preserveScroll
                    className={`mx-1 my-1 rounded border px-3 py-1 text-sm ${link.active ? 'bg-blue-500 text-white' : ''} ${!link.url ? 'cursor-not-allowed text-gray-400' : ''}`}
                    dangerouslySetInnerHTML={{ __html: link.label }}
                />
            ))}
        </div>
    );
}

function EditVendorModal({ vendor, isOpen, onClose, vendors }: { vendor: Vendor | null; isOpen: boolean; onClose: () => void; vendors: Vendor[] }) {
    const [form, setForm] = useState({
        name: '',
        brand_name_en: '',
        brand_name_ar: '',
        description_en: '',
        description_ar: '',
        email: '',
        mobile: '',
        phone: '',
        status: 'active' as 'active' | 'suspended',
        commission: '',
        kyc_status: 'pending' as 'pending' | 'approved' | 'rejected',
        kyc_rejection_reason: '',
        kyc_rejection_reason_en: '',
        kyc_rejection_reason_ar: '',
        logo: undefined as File | undefined,
        logo_preview: undefined as string | undefined,
    });
    const [errors, setErrors] = useState<{ [key: string]: string[] | string } | null>(null);
    const [processing, setProcessing] = useState(false);
    const [error, setError] = useState('');
    const [loading, setLoading] = useState(false);

    useEffect(() => {
        if (vendor) {
            if (typeof vendor.description_en === 'undefined' || typeof vendor.description_ar === 'undefined') {
                setLoading(true);
            } else {
                setForm({
                    name: vendor.name || '',
                    brand_name_en: vendor.brand_name_en || '',
                    brand_name_ar: vendor.brand_name_ar || '',
                    description_en: vendor.description_en || '',
                    description_ar: vendor.description_ar || '',
                    email: vendor.email || '',
                    mobile: vendor.mobile || '',
                    phone: vendor.user?.phone || '',
                    status: vendor.status as 'active' | 'suspended',
                    commission: vendor.commission || '',
                    kyc_status: vendor.kyc_status as 'pending' | 'approved' | 'rejected',
                    kyc_rejection_reason: vendor.kyc_rejection_reason || '',
                    kyc_rejection_reason_en: vendor.kyc_rejection_reason_en || '',
                    kyc_rejection_reason_ar: vendor.kyc_rejection_reason_ar || '',
                    logo: undefined,
                    logo_preview: undefined,
                });
                setLoading(false);
            }
        } else {
            setLoading(false);
        }
        setErrors(null);
    }, [vendor, isOpen]);

    const handleSubmit = () => {
        setProcessing(true);
        setErrors(null);
        setError('');

        // 1. Frontend validation
        const newErrors: { [key: string]: string } = {};
        if (!form.brand_name_en || form.brand_name_en.trim() === '') {
            newErrors.brand_name_en = 'Brand Name (English) is required';
        }
        if (!form.email || form.email.trim() === '') {
            newErrors.email = 'Email is required';
        } else if (vendors && vendors.some((v) => v.email === form.email && v.id !== vendor?.id)) {
            newErrors.email = 'This email is already taken by another vendor.';
        }
        if (Object.keys(newErrors).length > 0) {
            setErrors(newErrors);
            setProcessing(false);
            return;
        }

        let payload: FormData | typeof form = { ...form, name: form.brand_name_en };
        const options = {
            onSuccess: () => {
                setProcessing(false);
                setErrors(null);
                setError('');
                onClose();
            },
            onError: (err: any) => {
                setProcessing(false);
                if (typeof err === 'string') {
                    setError(err);
                } else {
                    setErrors(err);
                    setError('');
                }
            },
            preserveState: false,
        };

        if (form.logo) {
            const fd = new FormData();
            Object.entries(form).forEach(([key, value]) => {
                if (key === 'logo_preview') return;
                if (value !== undefined && value !== null) {
                    fd.append(key, value as Blob | string);
                }
            });
            fd.append('_method', 'PUT');
            payload = fd;
            (options as unknown as { forceFormData: boolean }).forceFormData = true;
            router.post(route('vendors.update', vendor?.id), payload, options);
        } else {
            router.put(route('vendors.update', vendor?.id), payload, options);
        }
    };

    if (!vendor || loading)
        return (
            <Dialog open={isOpen} onOpenChange={onClose}>
                <DialogContent className="max-h-[90vh] !w-[54vw] !max-w-[54vw] max-w-2xl overflow-y-auto">
                    <DialogHeader>
                        <DialogTitle>Edit Vendor</DialogTitle>
                    </DialogHeader>
                    <div className="flex min-h-[200px] items-center justify-center">Loading vendor details...</div>
                </DialogContent>
            </Dialog>
        );

    return (
        <Dialog open={isOpen} onOpenChange={onClose}>
            <DialogContent
                className="max-h-[90vh] !w-[54vw] !max-w-[54vw] max-w-2xl overflow-y-auto"
                style={{ width: '54vw', maxWidth: '54vw', minWidth: '540px', maxHeight: '90vh' }}
            >
                <DialogHeader>
                    <DialogTitle>Edit Vendor</DialogTitle>
                </DialogHeader>
                {/* Show global error if present */}
                {error && <div className="mb-4 rounded border border-red-300 bg-red-100 px-4 py-2 text-sm text-red-700">{error}</div>}
                <div className="space-y-6">
                    {/* Basic Information */}
                    <div className="grid grid-cols-1 gap-4 md:grid-cols-3">
                        {/* Name field removed, replaced by Brand Name (English) */}
                        <div>
                            <label className="mb-1 block font-medium">Email</label>
                            <Input placeholder="Email" value={form.email} onChange={(e) => setForm({ ...form, email: e.target.value })} />
                            {errors?.email && <div className="mt-1 text-xs text-red-500">{errors.email}</div>}
                        </div>
                        <div>
                            <label className="mb-1 block font-medium">Phone Number</label>
                            <Input
                                type="number"
                                inputMode="numeric"
                                pattern="[0-9]*"
                                placeholder="Phone Number"
                                value={form.phone}
                                onChange={(e) => setForm({ ...form, phone: e.target.value.replace(/\D/g, '') })}
                            />
                            {errors?.phone && (
                                <div className="mt-1 text-xs text-red-500">{Array.isArray(errors.phone) ? errors.phone[0] : errors.phone}</div>
                            )}
                        </div>
                    </div>

                    {/* Brand Names and Mobile */}
                    <div className="grid grid-cols-1 gap-4 md:grid-cols-3">
                        <div>
                            <label className="mb-1 block font-medium">Brand Name (English)</label>
                            <Input
                                placeholder="Brand Name in English"
                                value={form.brand_name_en}
                                onChange={(e) => setForm({ ...form, brand_name_en: e.target.value })}
                            />
                            {(errors?.brand_name_en || errors?.name) && (
                                <div className="mt-1 text-xs text-red-500">
                                    {errors.brand_name_en ? (Array.isArray(errors.brand_name_en) ? errors.brand_name_en[0] : errors.brand_name_en) : (Array.isArray(errors.name) ? errors.name[0] : errors.name)}
                                </div>
                            )}
                        </div>
                        <div>
                            <label className="mb-1 block font-medium">Brand Name (Arabic)</label>
                            <Input
                                placeholder="Brand Name in Arabic"
                                value={form.brand_name_ar}
                                onChange={(e) => setForm({ ...form, brand_name_ar: e.target.value })}
                            />
                            {errors?.brand_name_ar && (
                                <div className="mt-1 text-xs text-red-500">
                                    {Array.isArray(errors.brand_name_ar) ? errors.brand_name_ar[0] : errors.brand_name_ar}
                                </div>
                            )}
                        </div>
                        <div>
                            <label className="mb-1 block font-medium">Business Mobile</label>
                            <Input
                                type="number"
                                inputMode="numeric"
                                pattern="[0-9]*"
                                placeholder="Mobile Number"
                                value={form.mobile}
                                onChange={(e) => setForm({ ...form, mobile: e.target.value.replace(/\D/g, '') })}
                            />
                            {errors?.mobile && (
                                <div className="mt-1 text-xs text-red-500">{Array.isArray(errors.mobile) ? errors.mobile[0] : errors.mobile}</div>
                            )}
                        </div>
                    </div>

                    {/* Status, Commission, KYC Status */}
                    <div className="grid grid-cols-1 gap-4 md:grid-cols-3">
                        <div>
                            <label className="mb-1 block font-medium">Status *</label>
                            <Select value={form.status} onValueChange={(value: 'active' | 'suspended') => setForm({ ...form, status: value })}>
                                <SelectTrigger>
                                    <SelectValue placeholder="Select status" />
                                </SelectTrigger>
                                <SelectContent>
                                    <SelectItem value="active">Active</SelectItem>
                                    <SelectItem value="suspended">Suspended</SelectItem>
                                </SelectContent>
                            </Select>
                            {errors?.status && (
                                <div className="mt-1 text-xs text-red-500">{Array.isArray(errors.status) ? errors.status[0] : errors.status}</div>
                            )}
                        </div>
                        <div>
                            <label className="mb-1 block font-medium">Commission (%)</label>
                            <Input
                                type="number"
                                min={0}
                                max={100}
                                placeholder="Commission percentage"
                                value={form.commission}
                                onChange={(e) => setForm({ ...form, commission: e.target.value })}
                            />
                            {errors?.commission && (
                                <div className="mt-1 text-xs text-red-500">
                                    {Array.isArray(errors.commission) ? errors.commission[0] : errors.commission}
                                </div>
                            )}
                        </div>
                        <div>
                            <label className="mb-1 block font-medium">KYC Status</label>
                            <Select
                                value={form.kyc_status}
                                onValueChange={(value: 'pending' | 'approved' | 'rejected') => setForm({ ...form, kyc_status: value })}
                            >
                                <SelectTrigger>
                                    <SelectValue placeholder="Select KYC status" />
                                </SelectTrigger>
                                <SelectContent>
                                    <SelectItem value="pending">Pending</SelectItem>
                                    <SelectItem value="approved">Approved</SelectItem>
                                    <SelectItem value="rejected">Rejected</SelectItem>
                                </SelectContent>
                            </Select>
                            {errors?.kyc_status && (
                                <div className="mt-1 text-xs text-red-500">
                                    {Array.isArray(errors.kyc_status) ? errors.kyc_status[0] : errors.kyc_status}
                                </div>
                            )}
                        </div>
                    </div>

                    {/* KYC Rejection Reasons */}
                    <div className="grid grid-cols-1 gap-4 md:grid-cols-3">
                        <div>
                            <label className="mb-1 block font-medium">KYC Rejection Reason (English)</label>
                            <Input
                                placeholder="Reason for rejection (English)"
                                value={form.kyc_rejection_reason_en ?? ''}
                                onChange={(e) => setForm({ ...form, kyc_rejection_reason_en: e.target.value })}
                            />
                            {errors?.kyc_rejection_reason_en && (
                                <div className="mt-1 text-xs text-red-500">
                                    {Array.isArray(errors.kyc_rejection_reason_en)
                                        ? errors.kyc_rejection_reason_en[0]
                                        : errors.kyc_rejection_reason_en}
                                </div>
                            )}
                        </div>
                        <div>
                            <label className="mb-1 block font-medium">KYC Rejection Reason (Arabic)</label>
                            <Input
                                placeholder="Reason for rejection (Arabic)"
                                value={form.kyc_rejection_reason_ar ?? ''}
                                onChange={(e) => setForm({ ...form, kyc_rejection_reason_ar: e.target.value })}
                            />
                            {errors?.kyc_rejection_reason_ar && (
                                <div className="mt-1 text-xs text-red-500">
                                    {Array.isArray(errors.kyc_rejection_reason_ar)
                                        ? errors.kyc_rejection_reason_ar[0]
                                        : errors.kyc_rejection_reason_ar}
                                </div>
                            )}
                        </div>
                        <div />
                    </div>

                    {/* Descriptions */}
                    <div className="grid grid-cols-1 gap-4 md:grid-cols-2">
                        <div>
                            <div className="h-[250px]">
                                <label className="mb-1 block font-medium">Description (English)</label>
                                <ReactQuill
                                    theme="snow"
                                    value={form.description_en || ''}
                                    onChange={(value) => setForm({ ...form, description_en: value })}
                                    className="h-[9.7rem]"
                                />
                            </div>
                            {errors?.description_en && (
                                <div className="mt-1 text-xs text-red-500">
                                    {Array.isArray(errors.description_en) ? errors.description_en[0] : errors.description_en}
                                </div>
                            )}
                        </div>
                        <div>
                            <div className="h-[250px]">
                                <label className="mb-1 block font-medium">Description (Arabic)</label>
                                <ReactQuill
                                    theme="snow"
                                    value={form.description_ar || ''}
                                    onChange={(value) => setForm({ ...form, description_ar: value })}
                                    className="h-[9.7rem]"
                                />
                            </div>
                            {errors?.description_ar && (
                                <div className="mt-1 text-xs text-red-500">
                                    {Array.isArray(errors.description_ar) ? errors.description_ar[0] : errors.description_ar}
                                </div>
                            )}
                        </div>
                    </div>

                    {/* Logo Upload and Preview */}
                    <div>
                        <label className="mb-1 block font-medium">Logo</label>
                        <div className="flex flex-wrap items-center gap-6">
                            <div>
                                {form.logo_preview ? (
                                    <img src={form.logo_preview} alt="Logo Preview" className="h-20 w-20 rounded border object-cover" />
                                ) : vendor.logo ? (
                                    <img
                                        src={vendor.logo}
                                        alt="Vendor Logo"
                                        className="h-20 w-20 rounded border object-cover"
                                    />
                                ) : (
                                    <div className="bg-muted text-muted-foreground flex h-20 w-20 items-center justify-center rounded border text-xl font-bold select-none">
                                        No Logo
                                    </div>
                                )}
                            </div>
                            <div>
                                <Input
                                    type="file"
                                    accept="image/*"
                                    onChange={(e) => {
                                        const file = e.target.files?.[0];
                                        if (file) {
                                            setForm((f) => ({
                                                ...f,
                                                logo: file,
                                                logo_preview: URL.createObjectURL(file),
                                            }));
                                        }
                                    }}
                                />
                                {errors?.logo && (
                                    <div className="mt-1 text-xs text-red-500">{Array.isArray(errors.logo) ? errors.logo[0] : errors.logo}</div>
                                )}
                                <p className="mt-1 text-xs text-gray-500">
                                    Upload a new logo to replace the current one (recommended size: 300x300 px, max 2MB).
                                </p>
                            </div>
                        </div>
                    </div>
                </div>
                <DialogFooter>
                    <Button variant="outline" onClick={onClose} disabled={processing}>
                        Cancel
                    </Button>
                    <Button onClick={handleSubmit} disabled={processing}>
                        {processing ? 'Saving...' : 'Save Changes'}
                    </Button>
                </DialogFooter>
            </DialogContent>
        </Dialog>
    );
}

function CreateVendorModal({ isOpen, onClose, defaultCommission }: { isOpen: boolean; onClose: () => void; defaultCommission: string }) {
    const [form, setForm] = useState({
        name: '',
        brand_name_en: '',
        brand_name_ar: '',
        description_en: '',
        description_ar: '',
        email: '',
        mobile: '',
        phone: '',

        status: 'active' as 'active' | 'suspended',
        commission: '',
        kyc_status: 'pending' as 'pending' | 'approved' | 'rejected',
        logo: undefined as File | undefined,
        logo_preview: undefined as string | undefined,
        password: '',
        password_confirmation: '',
    });
    const [errors, setErrors] = useState<{ [key: string]: string } | null>(null);
    const [showPassword, setShowPassword] = useState(false);
    const [showConfirmPassword, setShowConfirmPassword] = useState(false);
    const [processing, setProcessing] = useState(false);
    const handleSubmit = () => {
        setProcessing(true);
        let payload: FormData | typeof form = form;
        if (form.logo) {
            const fd = new FormData();
            Object.entries(form).forEach(([key, value]) => {
                if (key === 'logo_preview') return;
                if (value !== undefined && value !== null) {
                    fd.append(key, value as Blob | string);
                }
            });
            payload = fd;
            fd.append('name', form.brand_name_en); // Ensure name is set to brand_name_en
            router.post(route('vendors.store'), payload, {
                preserveState: true,
                onSuccess: () => {
                    setProcessing(false);
                    setErrors(null);
                    setForm({
                        name: '',
                        brand_name_en: '',
                        brand_name_ar: '',
                        description_en: '',
                        description_ar: '',
                        email: '',
                        mobile: '',
                        phone: '',
                        status: 'active',
                        commission: '',
                        kyc_status: 'pending',
                        logo: undefined,
                        logo_preview: undefined,
                        password: '',
                        password_confirmation: '',
                    });
                    onClose();
                },
                onError: (err) => {
                    setProcessing(false);
                    setErrors(err);
                },
            });
        } else {
            router.post(route('vendors.store'), { ...form, name: form.brand_name_en }, {
                preserveState: true,
                onSuccess: () => {
                    setProcessing(false);
                    setErrors(null);
                    setForm({
                        name: '',
                        brand_name_en: '',
                        brand_name_ar: '',
                        description_en: '',
                        description_ar: '',
                        email: '',
                        mobile: '',
                        phone: '',
                        status: 'active',
                        commission: '',
                        kyc_status: 'pending',
                        logo: undefined,
                        logo_preview: undefined,
                        password: '',
                        password_confirmation: '',
                    });
                    onClose();
                },
                onError: (err) => {
                    setProcessing(false);
                    setErrors(err);
                },
            });
        }
    };
    useEffect(() => {
        if (isOpen && defaultCommission && form.commission === '') {
            setForm((f) => ({ ...f, commission: defaultCommission }));
        }
        // eslint-disable-next-line react-hooks/exhaustive-deps
    }, [isOpen, defaultCommission]);
    return (
        <Dialog open={isOpen} onOpenChange={onClose}>
            <DialogContent
                className="max-h-[90vh] !w-[54vw] !max-w-[54vw] max-w-2xl overflow-y-auto"
                style={{ width: '54vw', maxWidth: '54vw', minWidth: '540px', maxHeight: '90vh' }}
            >
                <DialogHeader>
                    <DialogTitle>Create Vendor</DialogTitle>
                </DialogHeader>
                <div className="space-y-6">
                    {/* Basic Information */}
                    <div className="grid grid-cols-1 gap-4 md:grid-cols-3">
                        {/* Name field removed */}
                        <div>
                            <label className="mb-1 block font-medium">
                                Email <span className="text-red-500">*</span>
                            </label>
                            <Input placeholder="Email" value={form.email} onChange={(e) => setForm({ ...form, email: e.target.value })} />
                            {errors?.email && <div className="mt-1 text-xs text-red-500">{errors.email}</div>}
                        </div>
                        <div>
                            <label className="mb-1 block font-medium capitalize">Phone number</label>
                            <Input
                                type="number"
                                inputMode="numeric"
                                pattern="[0-9]*"
                                placeholder="Phone Number"
                                value={form.phone}
                                onChange={(e) => setForm({ ...form, phone: e.target.value.replace(/\D/g, '') })}
                            />
                            {errors?.phone && <div className="mt-1 text-xs text-red-500">{errors.phone}</div>}
                        </div>
                    </div>
                    {/* Brand Names and Mobile */}
                    <div className="grid grid-cols-1 gap-4 md:grid-cols-3">
                        <div>
                            <label className="mb-1 block font-medium">Brand Name (English)</label>
                            <Input
                                placeholder="Brand Name in English"
                                value={form.brand_name_en}
                                onChange={(e) => setForm({ ...form, brand_name_en: e.target.value })}
                            />
                            {(errors?.brand_name_en || errors?.name) && <div className="mt-1 text-xs text-red-500">{errors.brand_name_en || errors.name}</div>}
                        </div>
                        <div>
                            <label className="mb-1 block font-medium">Brand Name (Arabic)</label>
                            <Input
                                placeholder="Brand Name in Arabic"
                                value={form.brand_name_ar}
                                onChange={(e) => setForm({ ...form, brand_name_ar: e.target.value })}
                            />
                            {errors?.brand_name_ar && <div className="mt-1 text-xs text-red-500">{errors.brand_name_ar}</div>}
                        </div>
                        <div>
                            <label className="mb-1 block font-medium">Business Mobile number</label>
                            <Input
                                type="number"
                                inputMode="numeric"
                                pattern="[0-9]*"
                                placeholder="Mobile Number"
                                value={form.mobile}
                                onChange={(e) => setForm({ ...form, mobile: e.target.value.replace(/\D/g, '') })}
                            />
                            {errors?.mobile && <div className="mt-1 text-xs text-red-500">{errors.mobile}</div>}
                        </div>
                    </div>
                    {/* Status, Commission, KYC Status */}
                    <div className="grid grid-cols-1 gap-4 md:grid-cols-3">
                        <div>
                            <label className="mb-1 block font-medium">
                                Status <span className="text-red-500">*</span>
                            </label>
                            <Select value={form.status} onValueChange={(value: 'active' | 'suspended') => setForm({ ...form, status: value })}>
                                <SelectTrigger>
                                    <SelectValue placeholder="Select status" />
                                </SelectTrigger>
                                <SelectContent>
                                    <SelectItem value="active">Active</SelectItem>
                                    <SelectItem value="suspended">Suspended</SelectItem>
                                </SelectContent>
                            </Select>
                            {errors?.status && <div className="mt-1 text-xs text-red-500">{errors.status}</div>}
                        </div>
                        <div>
                            <label className="mb-1 block font-medium">Commission (%)</label>
                            <Input
                                type="number"
                                min={0}
                                max={100}
                                placeholder="Commission percentage"
                                value={form.commission}
                                onChange={(e) => setForm({ ...form, commission: e.target.value })}
                            />
                            {errors?.commission && <div className="mt-1 text-xs text-red-500">{errors.commission}</div>}
                        </div>
                        <div>
                            <label className="mb-1 block font-medium">KYC Status</label>
                            <Select
                                value={form.kyc_status}
                                onValueChange={(value: 'pending' | 'approved' | 'rejected') => setForm({ ...form, kyc_status: value })}
                            >
                                <SelectTrigger>
                                    <SelectValue placeholder="Select KYC status" />
                                </SelectTrigger>
                                <SelectContent>
                                    <SelectItem value="pending">Pending</SelectItem>
                                    <SelectItem value="approved">Approved</SelectItem>
                                    <SelectItem value="rejected">Rejected</SelectItem>
                                </SelectContent>
                            </Select>
                            {errors?.kyc_status && <div className="mt-1 text-xs text-red-500">{errors.kyc_status}</div>}
                        </div>
                    </div>

                    {/* Descriptions */}
                    <div className="grid grid-cols-1 gap-4 md:grid-cols-2">
                        <div>
                            <div className="h-[250px]">
                                <label className="mb-1 block font-medium">Description (English)</label>
                                <ReactQuill
                                    theme="snow"
                                    value={form.description_en || ''}
                                    onChange={(value) => setForm({ ...form, description_en: value })}
                                    className="h-[9.7rem] bg-white"
                                />
                            </div>
                            {errors?.description_en && <div className="mt-1 text-xs text-red-500">{errors.description_en}</div>}
                        </div>
                        <div>
                            <div className="h-[250px]">
                                <label className="mb-1 block font-medium">Description (Arabic)</label>
                                <ReactQuill
                                    theme="snow"
                                    value={form.description_ar || ''}
                                    onChange={(value) => setForm({ ...form, description_ar: value })}
                                    className="h-[9.7rem] bg-white"
                                />
                            </div>
                            {errors?.description_ar && <div className="mt-1 text-xs text-red-500">{errors.description_ar}</div>}
                        </div>
                    </div>
                    {/* Logo Upload and Preview */}
                    <div>
                        <label className="mb-1 block font-medium">Logo</label>
                        <div className="flex flex-wrap items-center gap-6">
                            <div>
                                {form.logo_preview ? (
                                    <img src={form.logo_preview} alt="Logo Preview" className="h-20 w-20 rounded border object-cover" />
                                ) : (
                                    <div className="bg-muted text-muted-foreground flex h-20 w-20 items-center justify-center rounded border text-xl font-bold select-none">
                                        No Logo
                                    </div>
                                )}
                            </div>
                            <div>
                                <Input
                                    type="file"
                                    accept="image/*"
                                    onChange={(e) => {
                                        const file = e.target.files?.[0];
                                        if (file) {
                                            setForm((f) => ({ ...f, logo: file, logo_preview: URL.createObjectURL(file) }));
                                        }
                                    }}
                                />
                                {errors?.logo && <div className="mt-1 text-xs text-red-500">{errors.logo}</div>}
                                <p className="mt-1 text-xs text-gray-500">
                                    Upload/Update store logo <span className="font-medium">(Image: recommended size 300x300 px)</span>
                                </p>
                            </div>
                        </div>
                    </div>
                    {/* Password Fields */}
                    <div className="grid grid-cols-1 gap-4 md:grid-cols-2">
                        <div className="relative">
                            <label className="mb-1 block font-medium">
                                Password <span className="text-red-500">*</span>
                            </label>
                            <div className="relative">
                                <Input
                                    placeholder="Password"
                                    type={showPassword ? 'text' : 'password'}
                                    value={form.password}
                                    onChange={(e) => setForm({ ...form, password: e.target.value })}
                                    className="h-10 pr-10"
                                />
                                <button
                                    type="button"
                                    className="pointer-events-auto absolute top-1/2 right-2 flex -translate-y-1/2 items-center text-gray-500"
                                    onClick={() => setShowPassword((v) => !v)}
                                    tabIndex={-1}
                                    aria-label={showPassword ? 'Hide password' : 'Show password'}
                                >
                                    {showPassword ? <EyeOff className="h-5 w-5" /> : <Eye className="h-5 w-5" />}
                                </button>
                            </div>
                            {errors?.password && (
                                <div className="mt-1 text-xs text-red-500">
                                    {errors.password.toLowerCase().includes('format')
                                        ? 'Password must be at least 8 characters, include 1 uppercase letter and 1 number.'
                                        : errors.password}
                                </div>
                            )}
                        </div>
                        <div className="relative">
                            <label className="mb-1 block font-medium">
                                Confirm Password <span className="text-red-500">*</span>
                            </label>
                            <div className="relative">
                                <Input
                                    placeholder="Confirm Password"
                                    type={showConfirmPassword ? 'text' : 'password'}
                                    value={form.password_confirmation}
                                    onChange={(e) => setForm({ ...form, password_confirmation: e.target.value })}
                                    className="h-10 pr-10"
                                />
                                <button
                                    type="button"
                                    className="pointer-events-auto absolute top-1/2 right-2 flex -translate-y-1/2 items-center text-gray-500"
                                    onClick={() => setShowConfirmPassword((v) => !v)}
                                    tabIndex={-1}
                                    aria-label={showConfirmPassword ? 'Hide password' : 'Show password'}
                                >
                                    {showConfirmPassword ? <EyeOff className="h-5 w-5" /> : <Eye className="h-5 w-5" />}
                                </button>
                            </div>
                            {errors?.password_confirmation && <div className="mt-1 text-xs text-red-500">{errors.password_confirmation}</div>}
                        </div>
                    </div>
                </div>
                <DialogFooter>
                    <Button variant="outline" onClick={onClose} disabled={processing}>
                        Cancel
                    </Button>
                    <Button onClick={handleSubmit} disabled={processing}>
                        {processing ? 'Creating...' : 'Create'}
                    </Button>
                </DialogFooter>
            </DialogContent>
        </Dialog>
    );
}

function formatStatus(status: string) {
    if (!status) return '-';
    if (status.toLowerCase() === 'out_of_stock') return 'Out of Stock';
    return status
        .split('_')
        .map((word) => word.charAt(0).toUpperCase() + word.slice(1).toLowerCase())
        .join(' ');
}

function VendorHistoryModal({ vendor, isOpen, onClose }: { vendor: Vendor | null; isOpen: boolean; onClose: () => void }) {
    type OrderRow = {
        id: number;
        order_code: number;
        order_status: string;
        total_amount: string;
        created_at: string;
        payment_status?: string;
        user?: { full_name?: string };
        vendor?: { name?: string };
        shipping_address?: string;
    };
    type OrdersPaginated = {
        data: OrderRow[];
        current_page: number;
        last_page: number;
        total: number;
        per_page: number;
        links: { url: string | null; label: string; active: boolean }[];
    };
    const [orders, setOrders] = useState<OrdersPaginated>({ data: [], current_page: 1, last_page: 1, total: 0, per_page: 10, links: [] });
    const [loading, setLoading] = useState(false);
    const [page, setPage] = useState(1);
    useEffect(() => {
        if (vendor && isOpen) {
            setLoading(true);
            fetch(`/vendors/${vendor.id}/show?page=${page}`)
                .then((res) => res.json())
                .then((data) => {
                    setOrders(data.orders || { data: [], current_page: 1, last_page: 1, total: 0, per_page: 10, links: [] });
                    setLoading(false);
                })
                .catch(() => setLoading(false));
        } else if (!isOpen) {
            setOrders({ data: [], current_page: 1, last_page: 1, total: 0, per_page: 10, links: [] });
            setLoading(false);
            setPage(1);
        }
    }, [vendor, isOpen, page]);
    if (!vendor) return null;
    return (
        <Dialog open={isOpen} onOpenChange={onClose}>
            <DialogContent className="!w-[90vw] !max-w-4xl">
                <DialogHeader>
                    <DialogTitle>Vendor Orders: {vendor.brand_name_en}</DialogTitle>
                </DialogHeader>
                <div className="overflow-x-auto">
                    {loading ? (
                        <div className="py-8 text-center text-gray-500">Loading...</div>
                    ) : orders.data.length === 0 ? (
                        <div className="py-8 text-center text-gray-500">No orders found.</div>
                    ) : (
                        <>
                            <table className="min-w-full border bg-white dark:bg-neutral-900">
                                <thead>
                                    <tr className="text-center">
                                        <th className="border px-4 py-2">#</th>
                                        <th className="border px-4 py-2">Status</th>
                                        <th className="border px-4 py-2">Total</th>
                                        <th className="border px-4 py-2">Date</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    {orders.data.map((order: OrderRow, idx: number) => (
                                        <tr key={order.id} className="text-center">
                                            <td className="border px-4 py-2">{(orders.current_page - 1) * orders.per_page + idx + 1}</td>
                                            <td className="border px-4 py-2">{formatStatus(order.order_status)}</td>
                                            <td className="border px-4 py-2">KD {order.total_amount}</td>
                                            <td className="border px-4 py-2">{new Date(order.created_at).toLocaleDateString()}</td>
                                        </tr>
                                    ))}
                                </tbody>
                            </table>
                            <div className="mt-4">
                                <ShadcnPagination
                                    currentPage={orders.current_page}
                                    lastPage={orders.last_page}
                                    total={orders.total}
                                    perPage={orders.per_page}
                                    links={orders.links || []}
                                    onPageChange={setPage}
                                />
                            </div>
                        </>
                    )}
                </div>
            </DialogContent>
        </Dialog>
    );
}

function SubscriptionModal({
    vendor,
    isOpen,
    onClose,
    onSubscriptionUpdated,
}: {
    vendor: Vendor | null;
    isOpen: boolean;
    onClose: () => void;
    onSubscriptionUpdated: () => void;
}) {
    type Subscription = {
        id: number;
        title_en: string;
        title_ar?: string;
        price: string;
        duration: string;
        description_en?: string;
        benefits?: string;
    };
    type VendorSubscription = {
        id: number;
        subscription_id: number;
        start_date: string;
        end_date: string;
        status: string;
        payment_status: string;
        subscription: Subscription;
    };
    const [subscriptions, setSubscriptions] = useState<Subscription[]>([]);
    const [loading, setLoading] = useState(false);
    const [selectedId, setSelectedId] = useState<number | null>(null);
    const [form, setForm] = useState({
        start_date: new Date().toISOString().split('T')[0],
        end_date: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000).toISOString().split('T')[0],
    });
    const [currentSubscription, setCurrentSubscription] = useState<VendorSubscription | null>(null);

    useEffect(() => {
        if (isOpen && vendor) {
            setLoading(true);
            fetch('/vendors/available-subscriptions')
                .then((res) => res.json())
                .then((data: Subscription[]) => setSubscriptions(data))
                .catch(() => setSubscriptions([]));
            fetch(`/vendors/${vendor.id}/details`)
                .then((res) => res.json())
                .then((data) => {
                    if (data.subscriptions.currentVendorSubscription) {
                        setCurrentSubscription(data.subscriptions.currentVendorSubscription);
                        setSelectedId(data.subscriptions.currentVendorSubscription.subscription_id);
                        setForm({
                            start_date: new Date().toISOString().split('T')[0],
                            end_date: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000).toISOString().split('T')[0],
                        });
                    } else {
                        setCurrentSubscription(null);
                        setSelectedId(null);
                        setForm({
                            start_date: new Date().toISOString().split('T')[0],
                            end_date: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000).toISOString().split('T')[0],
                        });
                    }
                })
                .catch(() => setCurrentSubscription(null))
                .finally(() => setLoading(false));
        }
    }, [isOpen, vendor]);

    const handleUpdate = () => {
        if (!vendor || !selectedId) return;
        setLoading(true);

        router.post(
            route('vendors.assignSubscription', vendor.id),
            {
                subscription_id: selectedId,
                start_date: form.start_date,
                end_date: form.end_date,
            },
            {
                preserveState: true,
                preserveScroll: true,
                onSuccess: () => {
                    toast.success('Subscription updated successfully');
                    onSubscriptionUpdated();
                    onClose();
                    setLoading(false);
                },
                onError: (errors) => {
                    const errorMessage = errors?.subscription_id ||
                        errors?.start_date ||
                        errors?.end_date ||
                        'Failed to update subscription';
                    toast.error(errorMessage);
                    setLoading(false);
                },
                onFinish: () => setLoading(false),
            }
        );
    };

    if (!vendor) return null;

    const monthlyPlans = subscriptions.filter((sub) => sub.duration === 'monthly');
    const yearlyPlans = subscriptions.filter((sub) => sub.duration === 'yearly');

    return (
        <Dialog open={isOpen} onOpenChange={onClose}>
            <DialogContent className="!max-w-4xl">
                <DialogHeader>
                    <DialogTitle className="flex items-center gap-2">
                        <CreditCard className="h-5 w-5" />
                        {currentSubscription ? 'Renew/Update Subscription' : 'Assign Subscription'}
                    </DialogTitle>
                </DialogHeader>
                <div className="space-y-8">
                    {/* Monthly Plans */}
                    {monthlyPlans.length > 0 && (
                        <div>
                            <h1 className="mb-2 text-xl font-bold">Monthly</h1>
                            <div className="grid grid-cols-1 gap-4 md:grid-cols-3">
                                {monthlyPlans.map((sub) => (
                                    <div
                                        key={sub.id}
                                        className={`cursor-pointer rounded-lg border p-4 transition-all ${selectedId === sub.id
                                            ? 'border-2 border-black bg-blue-50 dark:bg-neutral-800'
                                            : 'border border-gray-200 bg-white hover:border-white dark:bg-neutral-900'
                                            }`}
                                        onClick={() => setSelectedId(sub.id)}
                                    >
                                        <div className="mb-2 flex items-center justify-between">
                                            <div className="text-lg font-semibold">{sub.title_en}</div>
                                            <div className="text-lg font-bold text-green-600">KD {sub.price}</div>
                                        </div>
                                        <div className="text-muted-foreground mb-1 text-sm">Duration: {sub.duration}</div>
                                        {sub.description_en && (
                                            <div className="mb-1 text-xs text-gray-500" dangerouslySetInnerHTML={{ __html: sub.description_en }} />
                                        )}
                                        {sub.benefits && <div className="text-xs text-gray-500">{sub.benefits}</div>}
                                        {selectedId === sub.id && (
                                            <div className="mt-2 text-xs font-semibold text-blue-700 dark:text-blue-400">Selected</div>
                                        )}
                                    </div>
                                ))}
                            </div>
                        </div>
                    )}
                    {/* Yearly Plans */}
                    {yearlyPlans.length > 0 && (
                        <div>
                            <h1 className="mb-2 text-xl font-bold">Yearly</h1>
                            <div className="grid grid-cols-1 gap-4 md:grid-cols-3">
                                {yearlyPlans.map((sub) => (
                                    <div
                                        key={sub.id}
                                        className={`cursor-pointer rounded-lg border p-4 transition-all ${selectedId === sub.id
                                            ? 'border-2 border-black bg-blue-50 dark:bg-neutral-800'
                                            : 'border border-gray-200 bg-white hover:border-white dark:bg-neutral-900'
                                            }`}
                                        onClick={() => setSelectedId(sub.id)}
                                    >
                                        <div className="mb-2 flex items-center justify-between">
                                            <div className="text-lg font-semibold">{sub.title_en}</div>
                                            <div className="text-lg font-bold text-green-600">KD {sub.price}</div>
                                        </div>
                                        <div className="text-muted-foreground mb-1 text-sm">Duration: {sub.duration}</div>
                                        {sub.description_en && (
                                            <div className="mb-1 text-xs text-gray-500" dangerouslySetInnerHTML={{ __html: sub.description_en }} />
                                        )}
                                        {sub.benefits && <div className="text-xs text-gray-500">{sub.benefits}</div>}
                                        {selectedId === sub.id && (
                                            <div className="mt-2 text-xs font-semibold text-blue-700 dark:text-blue-400">Selected</div>
                                        )}
                                    </div>
                                ))}
                            </div>
                        </div>
                    )}
                </div>
                <DialogFooter>
                    <Button variant="outline" onClick={onClose}>
                        Cancel
                    </Button>
                    <Button onClick={handleUpdate} disabled={loading || !selectedId || !form.start_date || !form.end_date}>
                        {loading ? 'Updating...' : currentSubscription ? 'Renew Subscription' : 'Assign Subscription'}
                    </Button>
                </DialogFooter>
            </DialogContent>
        </Dialog>
    );
}

function KYCModal({
    vendor,
    isOpen,
    onClose,
    onApprove,
    onReject,
}: {
    vendor: Vendor | null;
    isOpen: boolean;
    onClose: () => void;
    onApprove: () => void;
    onReject: (data: { kyc_rejection_reason_en: string; kyc_rejection_reason_ar: string }) => void;
}) {
    const [rejectReasonEn, setRejectReasonEn] = useState('');
    const [rejectReasonAr, setRejectReasonAr] = useState('');
    const [showRejectInputs, setShowRejectInputs] = useState(false);
    const [confirmApproveOpen, setConfirmApproveOpen] = useState(false);

    useEffect(() => {
        if (!isOpen) {
            setShowRejectInputs(false);
            setRejectReasonEn('');
            setRejectReasonAr('');
            setConfirmApproveOpen(false);
        }
    }, [isOpen]);

    if (!vendor) return null;

    // Properly structure KYC documents
    let kycDocs: { [key: string]: string } | null = null;
    if (vendor.kyc_documents && !Array.isArray(vendor.kyc_documents)) {
        kycDocs = vendor.kyc_documents as unknown as { [key: string]: string };
    }
    const kycDocsUrls = (vendor as { kyc_documents_urls?: { [key: string]: string } }).kyc_documents_urls;

    // Define document structure with proper names
    const documentTypes = [
        { key: 'civil_id', name: 'Civil ID Document' },
        { key: 'commercial_license', name: 'Commercial License' },
        { key: 'iban_certificate', name: 'IBAN Certificate' },
    ];

    // Get documents with URLs
    const docs = documentTypes.map((docType) => {
        const path = kycDocs?.[docType.key];
        const url = kycDocsUrls?.[docType.key] || (path ? (path.startsWith('http') ? path : `/storage/${path}`) : null);
        return {
            key: docType.key,
            name: docType.name,
            url: url,
            path: path,
        };
    }).filter(doc => doc.url); // Only show documents that have URLs

    return (
        <>
            <Dialog open={isOpen} onOpenChange={onClose}>
                <DialogContent className="max-w-2xl">
                    <DialogHeader>
                        <DialogTitle>KYC Documents: {vendor.brand_name_en}</DialogTitle>
                    </DialogHeader>
                    <div className="space-y-4">
                        <div>
                            <span className="font-medium">Status:</span> {vendor.kyc_status}
                            {vendor.kyc_status === 'rejected' && (vendor.kyc_rejection_reason_en || vendor.kyc_rejection_reason_ar) && (
                                <div className="mt-1 text-sm text-red-600">
                                    Reason:{' '}
                                    {(vendor.kyc_rejection_reason_en || '-') +
                                        (vendor.kyc_rejection_reason_ar ? ' / ' + vendor.kyc_rejection_reason_ar : '')}
                                </div>
                            )}
                        </div>
                        <div>
                            <span className="font-medium">Documents:</span>
                            <div className="mt-2 flex flex-wrap gap-4">
                                {docs.length === 0 && <span className="text-muted-foreground">No documents uploaded.</span>}
                                {docs.map((doc) => {
                                    const url = doc.url || '';
                                    const name = doc.name;

                                    const isPDF = url.toLowerCase().endsWith('.pdf');
                                    const isImage = /\.(jpg|jpeg|png|gif|webp)$/i.test(url);

                                    return (
                                        <div key={doc.key} className="flex-1 flex-col items-center rounded-lg border p-3 bg-gray-50 dark:bg-gray-800">
                                            <span className="mb-2 text-xs font-medium text-center">{name}</span>

                                            {/* File Type Icon */}
                                            <div className="mb-3 flex items-center justify-center">
                                                {isPDF ? (
                                                    <div className="flex items-center gap-2">
                                                        <FileText className="h-8 w-8 text-red-500" />
                                                        <span className="text-xs text-red-600 font-medium">PDF</span>
                                                    </div>
                                                ) : isImage ? (
                                                    <div className="flex items-center gap-2">
                                                        <Image className="h-8 w-8 text-blue-500" />
                                                        <span className="text-xs text-blue-600 font-medium">Image</span>
                                                    </div>
                                                ) : (
                                                    <div className="flex items-center gap-2">
                                                        <FileText className="h-8 w-8 text-gray-500" />
                                                        <span className="text-xs text-gray-600 font-medium">Document</span>
                                                    </div>
                                                )}
                                            </div>

                                            {/* View Button */}
                                            <Button
                                                size="sm"
                                                variant="default"
                                                className="w-full"
                                                onClick={() => window.open(url, '_blank')}
                                            >
                                                <Eye className="h-3 w-3 mr-1" />
                                                View
                                            </Button>
                                        </div>
                                    );
                                })}
                            </div>
                        </div>
                        {(vendor.kyc_status === 'pending' || vendor.kyc_status === 'review') && (
                            <div className="space-y-2">
                                <div className="flex gap-2">
                                    <Button onClick={() => setConfirmApproveOpen(true)}>Approve</Button>
                                    <Button variant="destructive" onClick={() => setShowRejectInputs(true)}>
                                        Reject
                                    </Button>
                                </div>
                                {showRejectInputs && (
                                    <div className="space-y-2">
                                        <div className="space-y-3">
                                            <div className="border-muted bg-background space-y-4 rounded-lg border p-4 shadow-sm">
                                                <div>
                                                    <label className="mb-1 block text-sm font-medium" htmlFor="reject-reason-en">
                                                        Rejection Reason (EN) <span className="text-destructive">*</span>
                                                    </label>
                                                    <textarea
                                                        id="reject-reason-en"
                                                        placeholder="Type the rejection reason in English..."
                                                        value={rejectReasonEn}
                                                        onChange={(e) => setRejectReasonEn(e.target.value)}
                                                        className="border-input bg-background focus-visible:ring-ring mb-2 h-32 w-full resize-none rounded-md border px-3 py-4 text-left text-base focus-visible:ring-2 focus-visible:ring-offset-2 focus-visible:outline-none"
                                                        style={{ verticalAlign: 'top' }}
                                                    />
                                                </div>
                                                <div>
                                                    <label className="mb-1 block text-sm font-medium" htmlFor="reject-reason-ar">
                                                        Rejection Reason (AR)
                                                    </label>
                                                    <textarea
                                                        id="reject-reason-ar"
                                                        placeholder="Type the rejection reason in Arabic..."
                                                        value={rejectReasonAr}
                                                        onChange={(e) => setRejectReasonAr(e.target.value)}
                                                        className="border-input bg-background focus-visible:ring-ring h-32 w-full resize-none rounded-md border px-3 py-4 text-left text-base focus-visible:ring-2 focus-visible:ring-offset-2 focus-visible:outline-none"
                                                        style={{ verticalAlign: 'top' }}
                                                    />
                                                </div>
                                            </div>
                                            <Button
                                                variant="destructive"
                                                onClick={() =>
                                                    onReject({
                                                        kyc_rejection_reason_en: rejectReasonEn,
                                                        kyc_rejection_reason_ar: rejectReasonAr,
                                                    })
                                                }
                                                disabled={!rejectReasonEn}
                                                className="w-full"
                                            >
                                                Confirm Reject
                                            </Button>
                                        </div>
                                    </div>
                                )}
                            </div>
                        )}
                    </div>
                </DialogContent>
            </Dialog>
            {/* KYC Approve Confirmation Dialog */}
            <ConfirmDialog open={confirmApproveOpen} onOpenChange={setConfirmApproveOpen}>
                <ConfirmDialogContent>
                    <ConfirmDialogHeader>
                        <ConfirmDialogTitle>Approve KYC</ConfirmDialogTitle>
                    </ConfirmDialogHeader>
                    <div>Are you sure you want to approve KYC for this vendor?</div>
                    <ConfirmDialogFooter>
                        <Button variant="outline" onClick={() => setConfirmApproveOpen(false)}>
                            Cancel
                        </Button>
                        <Button
                            variant="default"
                            onClick={() => {
                                onApprove();
                                setConfirmApproveOpen(false);
                            }}
                        >
                            Approve
                        </Button>
                    </ConfirmDialogFooter>
                </ConfirmDialogContent>
            </ConfirmDialog>
        </>
    );
}

function VendorViewModal({
    vendor,
    isOpen,
    onClose,
    onOpenSubscriptionModal,
}: {
    vendor: Vendor | null;
    isOpen: boolean;
    onClose: () => void;
    onOpenSubscriptionModal: () => void;
}) {
    type OrderRow = {
        id: number;
        order_code: number;
        order_status: string;
        shipping_address?: string;
        total_amount: string;
        created_at: string;
        payment_status?: string;
        user?: { full_name?: string };
        vendor?: { name?: string };
    };
    type ProductRow = {
        id: number;
        name_en?: string;
        name_ar?: string;
        status: string;
        sale_price?: string;
        created_at?: string;
        stock?: number;
        category?: { name_en?: string };
        vendor?: { brand_name_en?: string; name?: string };
    };
    type ExpoRow = {
        id: number;
        name_en?: string;
        name_ar?: string;
        pivot?: { status?: string; slot?: string; total_slots?: string; joined_at?: string };
        start_date?: string;
        end_date?: string;
    };
    type SubscriptionRow = {
        id: number;
        subscription?: { title_en?: string; price?: string; duration?: string; description_en?: string; features?: string | string[] };
        start_date: string;
        end_date: string;
        status: string;
        payment_status: string;
    };
    type VendorSubscription = {
        id: number;
        subscription_id: number;
        start_date: string;
        end_date: string;
        status: string;
        payment_status: string;
        subscription?: { title_en?: string; price?: string; duration?: string; description_en?: string; features?: string | string[] };
    };
    type Paginated<T> = {
        data: T[];
        current_page: number;
        last_page: number;
        total: number;
        per_page: number;
        links: { url: string | null; label: string; active: boolean }[];
    };
    type VendorDetailsData = {
        orders: Paginated<OrderRow>;
        products: Paginated<ProductRow>;
        expos: Paginated<ExpoRow>;
        subscriptions: {
            current?: VendorSubscription;
            currentVendorSubscription?: VendorSubscription;
            history?: SubscriptionRow[];
        };
    };
    const [tab, setTab] = useState<'info' | 'history' | 'subscriptions' | 'products' | 'expos'>('info');
    const [loading, setLoading] = useState<boolean>(false);
    const [ordersPage, setOrdersPage] = useState(1);
    const [productsPage, setProductsPage] = useState(1);
    const [exposPage, setExposPage] = useState(1);
    const [data, setData] = useState<VendorDetailsData>({
        orders: { data: [], current_page: 1, last_page: 1, total: 0, per_page: 10, links: [] },
        products: { data: [], current_page: 1, last_page: 1, total: 0, per_page: 10, links: [] },
        expos: { data: [], current_page: 1, last_page: 1, total: 0, per_page: 10, links: [] },
        subscriptions: {},
    });

    useEffect(() => {
        if (vendor && isOpen) {
            setLoading(true);
            fetch(`/vendors/${vendor.id}/details?orders_page=${ordersPage}&products_page=${productsPage}&expos_page=${exposPage}`)
                .then((res) => res.json())
                .then((json: VendorDetailsData) => {
                    setData(json);
                    setLoading(false);
                })
                .catch(() => setLoading(false));
        } else if (!isOpen) {
            setData({
                orders: { data: [], current_page: 1, last_page: 1, total: 0, per_page: 10, links: [] },
                products: { data: [], current_page: 1, last_page: 1, total: 0, per_page: 10, links: [] },
                expos: { data: [], current_page: 1, last_page: 1, total: 0, per_page: 10, links: [] },
                subscriptions: {},
            });
            setLoading(false);
            setOrdersPage(1);
            setProductsPage(1);
            setExposPage(1);
        }
    }, [vendor, isOpen, ordersPage, productsPage, exposPage]);

    // Reset page when switching tabs
    useEffect(() => {
        if (tab === 'history') setOrdersPage(1);
        if (tab === 'products') setProductsPage(1);
        if (tab === 'expos') setExposPage(1);
    }, [tab]);

    if (!vendor) return null;

    return (
        <Dialog open={isOpen} onOpenChange={onClose}>
            <DialogContent className="!w-[90vw] !max-w-7xl">
                <DialogHeader>
                    <DialogTitle>Vendor Details</DialogTitle>
                </DialogHeader>
                <Tabs value={tab} onValueChange={(v) => setTab(v as typeof tab)} className="w-full">
                    <TabsList className="mb-4">
                        <TabsTrigger value="info">Info</TabsTrigger>
                        <TabsTrigger value="history">Orders</TabsTrigger>
                        <TabsTrigger value="subscriptions">Subscriptions</TabsTrigger>
                        <TabsTrigger value="products">Products</TabsTrigger>
                        <TabsTrigger value="expos">Expos</TabsTrigger>
                    </TabsList>
                    <TabsContent value="info">
                        <div className="flex max-h-[600px] flex-col items-center overflow-y-auto p-6">
                            <div className="w-full max-w-4xl rounded-lg border bg-white p-6 shadow dark:bg-neutral-900">
                                <div className="mb-6 flex flex-col items-center gap-4 sm:flex-row">
                                    <a
                                        href={vendor.logo || undefined}
                                        target="_blank"
                                        rel="noopener noreferrer"
                                        className="block"
                                        style={{ textDecoration: 'none' }}
                                    >
                                        {vendor.logo ? (
                                            <img
                                                src={vendor.logo}
                                                alt={vendor.brand_name_en || 'Vendor'}
                                                className="h-20 w-20 cursor-pointer rounded-full border object-cover"
                                            />
                                        ) : (
                                            <div className="bg-muted text-muted-foreground flex h-20 w-20 cursor-pointer items-center justify-center rounded-full border text-xl font-bold select-none">
                                                {vendor.brand_name_en
                                                    ? vendor.brand_name_en
                                                        .split(' ')
                                                        .map((word) => word[0]?.toUpperCase())
                                                        .join('')
                                                    : '-'}
                                            </div>
                                        )}
                                    </a>
                                    <div>
                                        <h2 className="text-xl font-bold">{vendor.brand_name_en || '-'}</h2>
                                    </div>
                                </div>
                                <div className="grid grid-cols-1 gap-x-8 gap-y-4 sm:grid-cols-3">
                                    <div>
                                        <div className="text-muted-foreground mb-1 text-xs">Brand Name (EN)</div>
                                        <div className="font-medium">{vendor.brand_name_en || '-'}</div>
                                    </div>
                                    <div>
                                        <div className="text-muted-foreground mb-1 text-xs">Brand Name (AR)</div>
                                        <div className="font-medium">{vendor.brand_name_ar || '-'}</div>
                                    </div>
                                    <div>
                                        <div className="text-muted-foreground mb-1 text-xs">Email</div>
                                        <div className="font-medium">{vendor.email || '-'}</div>
                                    </div>
                                    <div>
                                        <div className="text-muted-foreground mb-1 text-xs capitalize">Phone number</div>
                                        <div className="font-medium">{vendor.user?.phone || '-'}</div>
                                    </div>
                                    <div>
                                        <div className="text-muted-foreground mb-1 text-xs capitalize">Business mobile number</div>
                                        <div className="font-medium">{vendor.mobile || '-'}</div>
                                    </div>
                                    <div>
                                        <div className="text-muted-foreground mb-1 text-xs">Status</div>
                                        <div className="font-medium">
                                            {vendor.status ? vendor.status.charAt(0).toUpperCase() + vendor.status.slice(1) : '-'}
                                        </div>
                                    </div>
                                    <div>
                                        <div className="text-muted-foreground mb-1 text-xs">Commission</div>
                                        <div className="font-medium">{vendor.commission ? `${vendor.commission}%` : '-'}</div>
                                    </div>
                                    <div>
                                        <div className="text-muted-foreground mb-1 text-xs">KYC Status</div>
                                        <div className="font-medium">
                                            {vendor.kyc_status ? vendor.kyc_status.charAt(0).toUpperCase() + vendor.kyc_status.slice(1) : '-'}
                                        </div>
                                    </div>

                                    <div>
                                        <div className="text-muted-foreground mb-1 text-xs">KYC Documents</div>
                                        <div className="font-medium">
                                            {vendor.kyc_documents
                                                ? (Array.isArray(vendor.kyc_documents)
                                                    ? vendor.kyc_documents.length
                                                    : Object.keys(vendor.kyc_documents).length) + ' document(s)'
                                                : '-'}
                                        </div>
                                    </div>
                                    <div>
                                        <div className="text-muted-foreground mb-1 text-xs">Description (EN)</div>
                                        <div
                                            className="font-medium"
                                            dangerouslySetInnerHTML={{
                                                __html: vendor.description_en || '-'
                                            }}
                                        />
                                    </div>
                                    <div>
                                        <div className="text-muted-foreground mb-1 text-xs">Description (AR)</div>
                                        <div
                                            className="font-medium"
                                            dangerouslySetInnerHTML={{
                                                __html: vendor.description_ar || '-'
                                            }}
                                        />
                                    </div>
                                    <div>
                                        <div className="text-muted-foreground mb-1 text-xs">KYC Rejection Reason (EN)</div>
                                        <div className="font-medium">{vendor.kyc_rejection_reason_en || '-'}</div>
                                    </div>
                                    <div>
                                        <div className="text-muted-foreground mt-2 mb-1 text-xs">KYC Rejection Reason (AR)</div>
                                        <div className="font-medium">{vendor.kyc_rejection_reason_ar || '-'}</div>
                                    </div>
                                    <div>
                                        <div className="text-muted-foreground mb-1 text-xs">Armada branch ID</div>
                                        <div className="font-medium font-mono text-sm">{vendor.armada_branch_id || '-'}</div>
                                    </div>
                                    <div>
                                        <div className="text-muted-foreground mb-1 text-xs">Armada branch key</div>
                                        <div className="font-medium font-mono text-sm break-all">{vendor.armada_branch_key ? `${vendor.armada_branch_key.slice(0, 12)}…` : '-'}</div>
                                    </div>
                                    {vendor.kyc_status === 'approved' && vendor.use_armada_delivery && !vendor.armada_branch_id && (
                                        <div className="sm:col-span-3 flex items-end">
                                            <Button
                                                size="sm"
                                                onClick={() => {
                                                    router.post(route('vendors.create-armada-branch', vendor.id), {}, {
                                                        onSuccess: () => {
                                                            onClose();
                                                            router.reload();
                                                        },
                                                        preserveState: false,
                                                    });
                                                }}
                                            >
                                                Create Armada branch
                                            </Button>
                                        </div>
                                    )}
                                </div>
                            </div>
                        </div>
                    </TabsContent>
                    <TabsContent value="history">
                        {loading ? (
                            <div className="py-8 text-center text-gray-500">Loading...</div>
                        ) : (
                            <div className="max-h-[600px] overflow-x-auto overflow-y-auto p-4">
                                {data.orders.data.length > 0 && (
                                    <div className="mb-2 flex justify-end">
                                        <Button asChild variant="outline" size="sm">
                                            <Link href={route('orders.index')} className="flex items-center gap-1">
                                                View All Orders
                                            </Link>
                                        </Button>
                                    </div>
                                )}
                                {data.orders.data.length === 0 ? (
                                    <div className="py-8 text-center text-gray-500">No orders found.</div>
                                ) : (
                                    <>
                                        <div className="overflow-x-auto">
                                            <table className="min-w-full border bg-white dark:bg-neutral-900">
                                                <thead>
                                                    <tr>
                                                        <th className="border px-4 py-2 text-left font-medium">#</th>
                                                        <th className="border px-4 py-2 text-left font-medium">Order ID</th>
                                                        <th className="border px-4 py-2 text-left font-medium">User</th>
                                                        <th className="border px-4 py-2 text-left font-medium">Vendor</th>
                                                        <th className="border px-4 py-2 text-left font-medium">Total</th>
                                                        <th className="border px-4 py-2 text-left font-medium">Status</th>
                                                        <th className="border px-4 py-2 text-left font-medium">Payment Status</th>
                                                        <th className="border px-4 py-2 text-left font-medium">Date</th>
                                                    </tr>
                                                </thead>
                                                <tbody>
                                                    {data.orders.data.map((order: OrderRow, idx: number) => (
                                                        <tr key={order.id} className="hover:bg-muted/50 border-b last:border-0">
                                                            <td className="border px-4 py-2">
                                                                {(data.orders.current_page - 1) * data.orders.per_page + idx + 1}
                                                            </td>
                                                            <td className="border px-4 py-2">{order.order_code}</td>
                                                            <td className="border px-4 py-2">{order.user?.full_name || '-'}</td>
                                                            <td className="border px-4 py-2">{vendor?.name || '-'}</td>
                                                            <td className="border px-4 py-2">KD {order.total_amount}</td>
                                                            <td className="border px-4 py-2">{formatStatus(order.order_status)}</td>
                                                            <td className="border px-4 py-2">
                                                                {order.payment_status ? formatStatus(order.payment_status) : '-'}
                                                            </td>
                                                            <td className="border px-4 py-2">{new Date(order.created_at).toLocaleDateString()}</td>
                                                        </tr>
                                                    ))}
                                                </tbody>
                                            </table>
                                        </div>
                                        <div className="mt-4">
                                            <ShadcnPagination
                                                currentPage={data.orders.current_page}
                                                lastPage={data.orders.last_page}
                                                total={data.orders.total}
                                                perPage={data.orders.per_page}
                                                links={data.orders.links || []}
                                                onPageChange={setOrdersPage}
                                            />
                                        </div>
                                    </>
                                )}
                            </div>
                        )}
                    </TabsContent>
                    <TabsContent value="subscriptions">
                        <div className="max-h-[600px] overflow-y-auto p-6">
                            {loading ? (
                                <div className="py-8 text-center text-gray-500">Loading subscription details...</div>
                            ) : (
                                <div className="space-y-6">
                                    {/* Current Subscription Details */}
                                    {data.subscriptions.currentVendorSubscription ? (
                                        <div className="rounded-lg border bg-gradient-to-r from-blue-50 to-indigo-50 p-6 dark:from-blue-900/20 dark:to-indigo-900/20">
                                            <div className="mb-4 flex items-center justify-between">
                                                <h3 className="text-lg font-semibold text-blue-900 dark:text-blue-100">Current Subscription</h3>
                                                <div className="flex items-center gap-2">
                                                    <span
                                                        className={`inline-block rounded-full px-3 py-1 text-xs font-semibold text-white ${data.subscriptions.currentVendorSubscription.status === 'active'
                                                            ? 'bg-green-600'
                                                            : 'bg-gray-400'
                                                            }`}
                                                    >
                                                        {data.subscriptions.currentVendorSubscription.status === 'active' ? 'Active' : 'Inactive'}
                                                    </span>
                                                    <Button size="sm" onClick={onOpenSubscriptionModal} className="flex items-center gap-2">
                                                        <CreditCard className="h-4 w-4" />
                                                        Renew/Update
                                                    </Button>
                                                </div>
                                            </div>

                                            <div className="grid grid-cols-1 gap-6 md:grid-cols-2 lg:grid-cols-3">
                                                <div>
                                                    <div className="text-muted-foreground mb-1 text-sm">Plan Name</div>
                                                    <div className="text-lg font-semibold">
                                                        {data.subscriptions.currentVendorSubscription.subscription?.title_en}
                                                    </div>
                                                </div>
                                                <div>
                                                    <div className="text-muted-foreground mb-1 text-sm">Price</div>
                                                    <div className="text-lg font-semibold text-green-600">
                                                        KD {data.subscriptions.currentVendorSubscription.subscription?.price}
                                                    </div>
                                                </div>
                                                <div>
                                                    <div className="text-muted-foreground mb-1 text-sm">Duration</div>
                                                    <div className="font-semibold">
                                                        {data.subscriptions.currentVendorSubscription.subscription?.duration}
                                                    </div>
                                                </div>
                                                <div>
                                                    <div className="text-muted-foreground mb-1 text-sm">Start Date</div>
                                                    <div className="font-medium">
                                                        {new Date(data.subscriptions.currentVendorSubscription.start_date).toLocaleDateString()}
                                                    </div>
                                                </div>
                                                <div>
                                                    <div className="text-muted-foreground mb-1 text-sm">End Date</div>
                                                    <div className="font-medium">
                                                        {new Date(data.subscriptions.currentVendorSubscription.end_date).toLocaleDateString()}
                                                    </div>
                                                </div>
                                                <div>
                                                    <div className="text-muted-foreground mb-1 text-sm">Payment Status</div>
                                                    <div className="font-medium">
                                                        <span
                                                            className={`inline-block rounded px-2 py-1 text-xs font-semibold text-white ${data.subscriptions.currentVendorSubscription.payment_status === 'paid'
                                                                ? 'bg-green-600'
                                                                : data.subscriptions.currentVendorSubscription.payment_status === 'pending'
                                                                    ? 'bg-yellow-500'
                                                                    : 'bg-red-600'
                                                                }`}
                                                        >
                                                            {data.subscriptions.currentVendorSubscription.payment_status === 'paid'
                                                                ? 'Paid'
                                                                : data.subscriptions.currentVendorSubscription.payment_status === 'pending'
                                                                    ? 'Pending'
                                                                    : data.subscriptions.currentVendorSubscription.payment_status}
                                                        </span>
                                                    </div>
                                                </div>
                                            </div>

                                            {data.subscriptions.currentVendorSubscription.subscription?.description_en && (
                                                <div className="mt-4">
                                                    <div className="text-muted-foreground mb-1 text-sm">Description</div>
                                                    <div
                                                        className="text-sm"
                                                        dangerouslySetInnerHTML={{
                                                            __html: data.subscriptions.currentVendorSubscription.subscription.description_en,
                                                        }}
                                                    />
                                                </div>
                                            )}

                                            {/* Features: Parse and display as bullet list, support JSON string or array */}
                                            {data.subscriptions.currentVendorSubscription.subscription?.features &&
                                                (() => {
                                                    let features = data.subscriptions.currentVendorSubscription.subscription.features;
                                                    if (typeof features === 'string') {
                                                        try {
                                                            features = JSON.parse(features);
                                                        } catch {
                                                            // If parsing fails, leave features as string
                                                        }
                                                    }
                                                    if (Array.isArray(features)) {
                                                        return (
                                                            <div className="mt-4">
                                                                <div className="text-muted-foreground mb-2 text-sm">Features</div>
                                                                <ul className="list-disc pl-5">
                                                                    {features.map((feature: string, idx: number) => (
                                                                        <li key={idx} className="text-sm">
                                                                            {feature}
                                                                        </li>
                                                                    ))}
                                                                </ul>
                                                            </div>
                                                        );
                                                    }
                                                    return null;
                                                })()}
                                        </div>
                                    ) : (
                                        <div className="py-12 text-center">
                                            <CreditCard className="mx-auto mb-4 h-16 w-16 text-gray-400" />
                                            <h3 className="mb-2 text-lg font-semibold text-gray-600">No Active Subscription</h3>
                                            <p className="mb-4 text-gray-500">This vendor doesn't have an active subscription plan.</p>
                                            <Button size="sm" onClick={onOpenSubscriptionModal} className="mx-auto flex items-center gap-2">
                                                <CreditCard className="h-4 w-4" />
                                                Assign Subscription
                                            </Button>
                                        </div>
                                    )}

                                    {/* Days Remaining Alert */}
                                    {data.subscriptions.currentVendorSubscription && (
                                        <div className="rounded-lg border border-yellow-200 bg-yellow-50 p-4 dark:border-yellow-800 dark:bg-yellow-900/20">
                                            <div className="flex items-center justify-between">
                                                <div>
                                                    <div className="text-sm font-medium text-yellow-800 dark:text-yellow-200">
                                                        Subscription Status
                                                    </div>
                                                    <div className="text-sm text-yellow-600 dark:text-yellow-300">
                                                        {(() => {
                                                            const endDate = new Date(data.subscriptions.currentVendorSubscription.end_date);
                                                            const today = new Date();
                                                            const daysRemaining = Math.ceil(
                                                                (endDate.getTime() - today.getTime()) / (1000 * 60 * 60 * 24),
                                                            );

                                                            if (daysRemaining > 30) {
                                                                return `${daysRemaining} days remaining`;
                                                            } else if (daysRemaining > 0) {
                                                                return `${daysRemaining} days remaining - Renew soon!`;
                                                            } else if (daysRemaining === 0) {
                                                                return 'Expires today!';
                                                            } else {
                                                                return `Expired ${Math.abs(daysRemaining)} days ago`;
                                                            }
                                                        })()}
                                                    </div>
                                                </div>
                                                {(() => {
                                                    const endDate = new Date(data.subscriptions.currentVendorSubscription.end_date);
                                                    const today = new Date();
                                                    const daysRemaining = Math.ceil((endDate.getTime() - today.getTime()) / (1000 * 60 * 60 * 24));

                                                    if (daysRemaining <= 30 && daysRemaining > 0) {
                                                        return (
                                                            <Button
                                                                size="sm"
                                                                onClick={onOpenSubscriptionModal}
                                                                className="bg-yellow-600 hover:bg-yellow-700"
                                                            >
                                                                Renew Now
                                                            </Button>
                                                        );
                                                    }
                                                    return null;
                                                })()}
                                            </div>
                                        </div>
                                    )}

                                    {/* Subscription History */}
                                    {data.subscriptions.history && data.subscriptions.history.length > 0 && (
                                        <div className="rounded-lg border bg-white dark:bg-neutral-900">
                                            <div className="border-b p-4">
                                                <h3 className="text-lg font-semibold">Subscription History</h3>
                                            </div>
                                            <div className="overflow-x-auto">
                                                <table className="min-w-full">
                                                    <thead>
                                                        <tr className="border-b">
                                                            <th className="px-4 py-3 text-left">Plan</th>
                                                            <th className="px-4 py-3 text-left">Start Date</th>
                                                            <th className="px-4 py-3 text-left">End Date</th>
                                                            <th className="px-4 py-3 text-left">Status</th>
                                                            <th className="px-4 py-3 text-left">Payment</th>
                                                        </tr>
                                                    </thead>
                                                    <tbody>
                                                        {data.subscriptions.history.map((sub: SubscriptionRow) => (
                                                            <tr key={sub.id} className="border-b">
                                                                <td className="px-4 py-3">
                                                                    <div>
                                                                        <div className="font-medium">{sub.subscription?.title_en}</div>
                                                                        <div className="text-muted-foreground text-sm">
                                                                            KD {sub.subscription?.price}
                                                                        </div>
                                                                    </div>
                                                                </td>
                                                                <td className="px-4 py-3">{new Date(sub.start_date).toLocaleDateString()}</td>
                                                                <td className="px-4 py-3">{new Date(sub.end_date).toLocaleDateString()}</td>
                                                                <td className="px-4 py-3">
                                                                    <span
                                                                        className={`inline-block rounded px-2 py-1 text-xs font-semibold text-white ${sub.status === 'active' ? 'bg-green-600' : 'bg-gray-400'
                                                                            }`}
                                                                    >
                                                                        {sub.status === 'active' ? 'Active' : 'Expired'}
                                                                    </span>
                                                                </td>
                                                                <td className="px-4 py-3">
                                                                    <span
                                                                        className={`inline-block rounded px-2 py-1 text-xs font-semibold text-white ${sub.payment_status === 'paid' ? 'bg-green-600' : 'bg-yellow-500'
                                                                            }`}
                                                                    >
                                                                        {sub.payment_status === 'paid' ? 'Paid' : 'Pending'}
                                                                    </span>
                                                                </td>
                                                            </tr>
                                                        ))}
                                                    </tbody>
                                                </table>
                                            </div>
                                        </div>
                                    )}
                                </div>
                            )}
                        </div>
                    </TabsContent>
                    <TabsContent value="products">
                        {loading ? (
                            <div className="py-8 text-center text-gray-500">Loading...</div>
                        ) : (
                            <div className="max-h-[600px] overflow-x-auto overflow-y-auto p-4">
                                {data.products.data.length > 0 && (
                                    <div className="mb-2 flex justify-end">
                                        <Button asChild variant="outline" size="sm">
                                            <Link href={route('products.index')} className="flex items-center gap-1">
                                                View All Products
                                            </Link>
                                        </Button>
                                    </div>
                                )}
                                {data.products.data.length === 0 ? (
                                    <div className="py-8 text-center text-gray-500">No products found.</div>
                                ) : (
                                    <>
                                        <table className="min-w-full border bg-white dark:bg-neutral-900">
                                            <thead>
                                                <tr>
                                                    <th className="border px-4 py-2">#</th>
                                                    <th className="border px-4 py-2">Name (EN)</th>
                                                    <th className="border px-4 py-2">Name (AR)</th>
                                                    <th className="border px-4 py-2">Price</th>
                                                    <th className="border px-4 py-2">Stock</th>
                                                    <th className="border px-4 py-2">Status</th>
                                                    <th className="border px-4 py-2">Category</th>
                                                    <th className="border px-4 py-2">Brand Name (EN)</th>
                                                </tr>
                                            </thead>
                                            <tbody>
                                                {data.products.data.map((product: ProductRow, idx: number) => (
                                                    <tr key={product.id} className="text-center">
                                                        <td className="border px-4 py-2">
                                                            {(data.products.current_page - 1) * data.products.per_page + idx + 1}
                                                        </td>
                                                        <td className="border px-4 py-2">{product.name_en || '-'}</td>
                                                        <td className="border px-4 py-2">{product.name_ar || '-'}</td>
                                                        <td className="border px-4 py-2">KD {product.sale_price || '-'}</td>
                                                        <td className="border px-4 py-2">{product.stock ?? '-'}</td>
                                                        <td className="border px-4 py-2">{product.status ? formatStatus(product.status) : '-'}</td>
                                                        <td className="border px-4 py-2">{product.category?.name_en || '-'}</td>
                                                        <td className="border px-4 py-2">{product.vendor?.brand_name_en || product.vendor?.name || '-'}</td>
                                                    </tr>
                                                ))}
                                            </tbody>
                                        </table>
                                        <div className="mt-4">
                                            <ShadcnPagination
                                                currentPage={data.products.current_page}
                                                lastPage={data.products.last_page}
                                                total={data.products.total}
                                                perPage={data.products.per_page}
                                                links={data.products.links || []}
                                                onPageChange={setProductsPage}
                                            />
                                        </div>
                                    </>
                                )}
                            </div>
                        )}
                    </TabsContent>
                    <TabsContent value="expos">
                        {loading ? (
                            <div className="py-8 text-center text-gray-500">Loading...</div>
                        ) : (
                            <div className="max-h-[600px] overflow-x-auto overflow-y-auto p-4">
                                {data.expos.data.length > 0 && (
                                    <div className="mb-2 flex justify-end">
                                        <Button asChild variant="outline" size="sm">
                                            <Link href={route('expos.index')} className="flex items-center gap-1">
                                                View All Expos
                                            </Link>
                                        </Button>
                                    </div>
                                )}
                                {data.expos.data.length === 0 ? (
                                    <div className="py-8 text-center text-gray-500">No expos found.</div>
                                ) : (
                                    <>
                                        <table className="min-w-full border bg-white dark:bg-neutral-900">
                                            <thead>
                                                <tr>
                                                    <th className="border px-4 py-2">#</th>
                                                    <th className="border px-4 py-2">Expo Name</th>
                                                    <th className="border px-4 py-2">Start Date</th>
                                                    <th className="border px-4 py-2">End Date</th>
                                                    <th className="border px-4 py-2">Total Slots</th>
                                                    <th className="border px-4 py-2">Status</th>
                                                    <th className="border px-4 py-2">Joined At</th>
                                                </tr>
                                            </thead>
                                            <tbody>
                                                {data.expos.data.map((expo: ExpoRow, idx: number) => (
                                                    <tr key={expo.id} className="text-center">
                                                        <td className="border px-4 py-2">
                                                            {(data.expos.current_page - 1) * data.expos.per_page + idx + 1}
                                                        </td>
                                                        <td className="border px-4 py-2">{expo.name_en || expo.name_ar || '-'}</td>
                                                        <td className="border px-4 py-2">
                                                            {expo.start_date ? dayjs(expo.start_date).format('YYYY-MM-DD hh:mm:A') : '-'}
                                                        </td>
                                                        <td className="border px-4 py-2">
                                                            {expo.end_date ? dayjs(expo.end_date).format('YYYY-MM-DD hh:mm:A') : '-'}
                                                        </td>
                                                        <td className="border px-4 py-2">{expo.pivot?.slot || '-'}</td>
                                                        <td className="border px-4 py-2">
                                                            {expo.pivot?.status
                                                                ? expo.pivot.status.charAt(0).toUpperCase() + expo.pivot.status.slice(1)
                                                                : '-'}
                                                        </td>
                                                        <td className="border px-4 py-2">
                                                            {expo.pivot?.joined_at ? new Date(expo.pivot.joined_at).toLocaleDateString() : '-'}
                                                        </td>
                                                    </tr>
                                                ))}
                                            </tbody>
                                        </table>
                                        <div className="mt-4">
                                            <ShadcnPagination
                                                currentPage={data.expos.current_page}
                                                lastPage={data.expos.last_page}
                                                total={data.expos.total}
                                                perPage={data.expos.per_page}
                                                links={data.expos.links || []}
                                                onPageChange={setExposPage}
                                            />
                                        </div>
                                    </>
                                )}
                            </div>
                        )}
                    </TabsContent>
                </Tabs>
            </DialogContent>
        </Dialog>
    );
}

function VendorsPage() {
    const { props } = usePage<{ vendors: PaginatedVendors; filters: { search: string }; defaultCommission?: string; flash?: { success?: string; error?: string; info?: string } }>();
    const vendors = props.vendors as PaginatedVendors;
    const filters = props.filters as { search: string };
    const defaultCommission = props.defaultCommission || '';
    const [search, setSearch] = useState(filters.search || '');
    const [status, setStatus] = useState('');
    const [kycStatus, setKycStatus] = useState('');
    const [from, setFrom] = useState('');
    const [to, setTo] = useState('');
    const [selectedVendor, setSelectedVendor] = useState<Vendor | null>(null);
    const [editModalOpen, setEditModalOpen] = useState(false);
    const [historyModalOpen, setHistoryModalOpen] = useState(false);
    const [kycModalOpen, setKycModalOpen] = useState(false);
    const [kycVendor, setKycVendor] = useState<Vendor | null>(null);
    const [createModalOpen, setCreateModalOpen] = useState(false);
    const [deleteDialogOpen, setDeleteDialogOpen] = useState(false);
    const [vendorToDelete, setVendorToDelete] = useState<Vendor | null>(null);
    const [viewModalOpen, setViewModalOpen] = useState(false);
    const [confirmStatusDialogOpen, setConfirmStatusDialogOpen] = useState(false);
    const [vendorToToggle, setVendorToToggle] = useState<Vendor | null>(null);
    const [subscriptionModalOpen, setSubscriptionModalOpen] = useState(false);

    useEffect(() => {
        const debouncedSearch = throttle(() => {
            router.get(route('vendors.index'), { search, status, from, to, kycStatus }, { preserveState: true, replace: true });
        }, 300);
        debouncedSearch();
        return () => debouncedSearch.cancel();
    }, [search, status, from, to, kycStatus]);

    useEffect(() => {
        if (props.flash) {
            if (props.flash.success) toast.success(props.flash.success);
            if (props.flash.error) toast.error(props.flash.error);
            if (props.flash.info) toast.success(props.flash.info);
        }
    }, [props.flash]);

    const openEditModal = (vendor: Vendor) => {
        setSelectedVendor(vendor);
        setEditModalOpen(true);
    };
    const openHistoryModal = (vendor: Vendor) => {
        setSelectedVendor(vendor);
        setHistoryModalOpen(true);
    };
    const openKycModal = (vendor: Vendor) => {
        setKycVendor(vendor);
        setKycModalOpen(true);
    };
    const openViewModal = (vendor: Vendor) => {
        setSelectedVendor(vendor);
        setViewModalOpen(true);
    };

    const handleDelete = (vendor: Vendor) => {
        router.delete(route('vendors.destroy', vendor.id), {
            preserveState: false,
            onSuccess: () => {
                setDeleteDialogOpen(false);
                setVendorToDelete(null);
            },
        });
    };
    const handleKycApprove = () => {
        if (!kycVendor) return;
        router.post(
            route('vendors.kyc.approve', kycVendor.id),
            {},
            {
                onSuccess: () => setKycModalOpen(false),
                preserveState: false,
            },
        );
    };
    const handleKycReject = (data: { kyc_rejection_reason_en: string; kyc_rejection_reason_ar: string }) => {
        if (!kycVendor) return;
        router.post(route('vendors.kyc.reject', kycVendor.id), data, {
            onSuccess: () => setKycModalOpen(false),
            preserveState: false,
        });
    };

    const handleToggleStatus = (vendor: Vendor) => {
        if (!vendor) return;
        router.post(
            route('vendors.toggle-status', vendor.id),
            {},
            {
                onSuccess: () => router.reload(),
                onError: (err) => console.error('Error toggling status:', err),
            },
        );
    };

    // Helper to get the next day in yyyy-mm-dd format
    function getNextDay(dateStr: string) {
        if (!dateStr) return undefined;
        const date = new Date(dateStr);
        date.setDate(date.getDate() + 1);
        return date.toISOString().slice(0, 10);
    }

    // Add a function to refresh vendor details
    const refreshVendorDetails = async (vendorId: number) => {
        const res = await fetch(`/vendors/${vendorId}/details`);
        const data = await res.json();
        // Merge the new details into selectedVendor (update only relevant fields)
        setSelectedVendor((prev) => (prev ? { ...prev, ...data.vendor } : prev));
    };

    return (
        <div className="p-6">
            <div className="mb-4 flex items-center justify-between">
                <h1 className="text-2xl font-bold">Vendor Manager</h1>
                <div className="flex items-center gap-2">
                    <Input
                        type="text"
                        placeholder="Search by name, email, phone..."
                        value={search}
                        onChange={(e) => setSearch(e.target.value)}
                        className="w-72"
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
                        className="h-10 w-40"
                    />
                    <StatusFilter
                        value={kycStatus || 'all'}
                        onChange={(v) => setKycStatus(v === 'all' ? '' : v)}
                        statusOptions={[
                            { value: 'all', label: 'All Statuses' },
                            { value: 'pending', label: 'Pending' },
                            { value: 'approved', label: 'Approved' },
                        ]}
                        placeholder="Filter by kyc"
                        className="h-10 w-40"
                    />
                    <Input
                        type="date"
                        value={from}
                        onChange={(e) => {
                            setFrom(e.target.value);
                            if (to && e.target.value && to < e.target.value) {
                                setTo('');
                            }
                        }}
                        className="h-10 w-40"
                        min="2015-01-01"
                    />
                    <Input type="date" value={to} min="2015-01-01" onChange={(e) => setTo(e.target.value)} className="h-10 w-40" />
                    <Button onClick={() => setCreateModalOpen(true)}>Create Vendor</Button>
                </div>
            </div>
            <div className="overflow-x-auto">
                <table className="min-w-full border bg-white dark:bg-neutral-900">
                    <thead>
                        <tr>
                            <th className="border px-4 py-2">Id</th>
                            <th className="border px-4 py-2">Brand Name (EN)</th>
                            <th className="border px-4 py-2">Email</th>
                            <th className="border px-4 py-2">Phone</th>
                            <th className="border px-4 py-2">Status</th>
                            <th className="border px-4 py-2">Commission (%)</th>
                            <th className="border px-4 py-2">KYC</th>
                            <th className="border px-4 py-2">Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        {vendors.data.map((vendor, idx) => (
                            <tr key={vendor.id || idx} className="text-center">
                                <td className="border px-4 py-2">{(vendors.current_page - 1) * vendors.per_page + idx + 1}</td>
                                <td className="border px-4 py-2">{vendor.brand_name_en}</td>
                                <td className="border px-4 py-2">{vendor.email || '-'}</td>
                                <td className="border px-4 py-2">{vendor.user?.phone || '-'}</td>
                                <td className="border px-4 py-2 text-center">
                                    <span
                                        className={
                                            'inline-block min-w-[90px] rounded px-2 py-1 text-center text-xs font-semibold text-white ' +
                                            ({
                                                active: 'bg-green-600',
                                                suspended: 'bg-red-600',
                                            }[vendor.status] || 'bg-gray-400')
                                        }
                                    >
                                        {vendor.status === 'active'
                                            ? 'Active'
                                            : vendor.status === 'suspended'
                                                ? 'Suspended'
                                                : vendor.status.charAt(0).toUpperCase() + vendor.status.slice(1)}
                                    </span>
                                </td>
                                <td className="border px-4 py-2">{vendor.commission || '-'}</td>
                                <td className="border px-4 py-2">
                                    {/* <KycStatusBadge status={vendor.kyc_status} /> */}
                                    <span
                                        className={
                                            'inline-block min-w-[90px] rounded px-2 py-1 text-center text-xs font-semibold text-white ' +
                                            ({
                                                approved: 'bg-green-600',
                                                rejected: 'bg-red-600',
                                            }[vendor.kyc_status] || 'bg-gray-400')
                                        }
                                    >
                                        {vendor.kyc_status === 'active'
                                            ? 'Approved'
                                            : vendor.kyc_status === 'rejected'
                                                ? 'Rejected'
                                                : vendor.kyc_status.charAt(0).toUpperCase() + vendor.kyc_status.slice(1)}
                                    </span>
                                </td>
                                <td className="space-x-2 border px-4 py-2 text-center">
                                    <Button size="sm" variant="secondary" onClick={() => openViewModal(vendor)}>
                                        View
                                    </Button>
                                    <Button size="sm" variant="outline" onClick={() => openEditModal(vendor)}>
                                        Edit
                                    </Button>

                                    <Button size="sm" variant="secondary" onClick={() => openKycModal(vendor)}>
                                        KYC
                                    </Button>

                                    <Button
                                        size="sm"
                                        variant={vendor.status === 'active' ? 'outline' : undefined}
                                        className={
                                            vendor.status !== 'active'
                                                ? 'border border-black bg-black text-white dark:border-white dark:bg-white dark:text-black'
                                                : ''
                                        }
                                        onClick={() => {
                                            setVendorToToggle(vendor);
                                            setConfirmStatusDialogOpen(true);
                                        }}
                                    >
                                        {vendor.status === 'active' ? 'Suspend' : 'Activate'}
                                    </Button>
                                    <Button
                                        size="sm"
                                        variant="destructive"
                                        onClick={() => {
                                            setVendorToDelete(vendor);
                                            setDeleteDialogOpen(true);
                                        }}
                                    >
                                        Delete
                                    </Button>
                                </td>
                            </tr>
                        ))}
                    </tbody>
                </table>
            </div>
            {/* Pagination */}
            {vendors.last_page > 1 && (
                <div className="mt-6">
                    <ShadcnPagination
                        currentPage={vendors.current_page}
                        lastPage={vendors.last_page}
                        total={vendors.total}
                        perPage={vendors.per_page}
                        links={vendors.links}
                        onPageChange={(pageNum: number) => {
                            router.get(
                                route('vendors.index'),
                                {
                                    search,
                                    status,
                                    from,
                                    to,
                                    page: pageNum,
                                },
                                { preserveState: true, replace: true },
                            );
                        }}
                    />
                </div>
            )}
            <EditVendorModal vendor={selectedVendor} isOpen={editModalOpen} onClose={() => setEditModalOpen(false)} vendors={vendors.data} />
            <VendorHistoryModal vendor={selectedVendor} isOpen={historyModalOpen} onClose={() => setHistoryModalOpen(false)} />
            <KYCModal
                vendor={kycVendor}
                isOpen={kycModalOpen}
                onClose={() => setKycModalOpen(false)}
                onApprove={handleKycApprove}
                onReject={handleKycReject}
            />
            <CreateVendorModal isOpen={createModalOpen} onClose={() => setCreateModalOpen(false)} defaultCommission={defaultCommission} />
            <VendorViewModal
                vendor={selectedVendor}
                isOpen={viewModalOpen}
                onClose={() => setViewModalOpen(false)}
                onOpenSubscriptionModal={() => setSubscriptionModalOpen(true)}
            />
            <SubscriptionModal
                vendor={selectedVendor}
                isOpen={subscriptionModalOpen}
                onClose={() => setSubscriptionModalOpen(false)}
                onSubscriptionUpdated={() => {
                    if (selectedVendor) refreshVendorDetails(selectedVendor.id);
                }}
            />

            <Dialog open={deleteDialogOpen} onOpenChange={setDeleteDialogOpen}>
                <DialogContent>
                    <DialogHeader>
                        <DialogTitle>Delete Vendor</DialogTitle>
                    </DialogHeader>
                    <div>Are you sure you want to delete this vendor?</div>
                    <DialogFooter>
                        <Button variant="outline" onClick={() => setDeleteDialogOpen(false)}>
                            Cancel
                        </Button>
                        <Button
                            variant="destructive"
                            onClick={() => {
                                if (vendorToDelete) {
                                    handleDelete(vendorToDelete);
                                }
                            }}
                        >
                            Delete
                        </Button>
                    </DialogFooter>
                </DialogContent>
            </Dialog>

            <Dialog open={confirmStatusDialogOpen} onOpenChange={setConfirmStatusDialogOpen}>
                <DialogContent>
                    <DialogHeader>
                        <DialogTitle>{vendorToToggle?.status === 'suspended' ? 'Activate Vendor' : 'Suspend Vendor'}</DialogTitle>
                    </DialogHeader>
                    <div>Are you sure you want to {vendorToToggle?.status === 'suspended' ? 'activate' : 'suspend'} this vendor?</div>
                    <DialogFooter>
                        <Button variant="outline" onClick={() => setConfirmStatusDialogOpen(false)}>
                            Cancel
                        </Button>
                        <Button
                            variant={vendorToToggle?.status === 'suspended' ? 'default' : 'destructive'}
                            onClick={() => {
                                if (vendorToToggle) {
                                    handleToggleStatus(vendorToToggle);
                                }
                                setConfirmStatusDialogOpen(false);
                            }}
                        >
                            {vendorToToggle?.status === 'suspended' ? 'Activate' : 'Suspend'}
                        </Button>
                    </DialogFooter>
                </DialogContent>
            </Dialog>
        </div>
    );
}

const VendorsIndex = () => (
    <AppLayout>
        <Head title="Vendors Manager" />
        <VendorsPage />
    </AppLayout>
);

export default VendorsIndex;
