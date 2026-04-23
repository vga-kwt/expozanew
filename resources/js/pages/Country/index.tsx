/* eslint-disable @typescript-eslint/no-explicit-any */
import { ActionButtonDelete, ActionButtonSuspend } from '@/components/action-button';
import ExportButton from '@/components/export-button';
import { useLanguage } from '@/components/language-context';
import { Button } from '@/components/ui/button';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Dialog, DialogContent, DialogFooter, DialogHeader, DialogTitle } from '@/components/ui/dialog';
import { Input } from '@/components/ui/input';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select';
import { StatusFilter } from '@/components/ui/StatusFilter';
import AppLayout from '@/layouts/app-layout';
import ExportService from '@/utils/exportService';
import { Head, Link, router, useForm, usePage } from '@inertiajs/react';
import { useCallback, useEffect, useState } from 'react';
import { toast } from 'react-hot-toast';

interface Country {
    id: number;
    name_en: string;
    name_ar: string;
    status: 'active' | 'suspended';
    created_at: string;
    updated_at: string;
}

interface PaginatedData {
    data: Country[];
    current_page: number;
    last_page: number;
    per_page: number;
    total: number;
    links: { url: string | null; label: string; active: boolean }[];
}

interface Props {
    countries: PaginatedData;
    statistics: {
        total: number;
        active: number;
        suspended: number;
        deleted: number;
    };
    filters: {
        search?: string;
        status?: string;
        date_from?: string;
        date_to?: string;
    };
    flash?: {
        success?: string;
        error?: string;
    };
    [key: string]: any;
}

const CountryIndex = () => {
    const { language } = useLanguage();
    const { props } = usePage<Props>();
    const { countries, statistics, filters, flash } = props;

    const [isOpenCreateModal, setIsOpenCreateModal] = useState<boolean>(false);
    const [isOpenDeleteModal, setIsOpenDeleteModal] = useState<boolean>(false);
    const [localFilters, setLocalFilters] = useState({
        search: filters.search || '',
        status: filters.status || 'all',
        date_from: filters.date_from || '',
        date_to: filters.date_to || '',
    });
    const [countryToDelete, setCountryToDelete] = useState<Country | null>(null);
    const [countryToEdit, setCountryToEdit] = useState<Country | null>(null);
    const [confirmDialog, setConfirmDialog] = useState<{
        open: boolean;
        country: Country | null;
        action: 'suspend' | 'activate' | 'delete' | null;
    }>({
        open: false,
        country: null,
        action: null,
    });

    // Debounced search function
    const debouncedSearch = useCallback(
        (() => {
            let timeoutId: NodeJS.Timeout;
            return (searchTerm: string) => {
                clearTimeout(timeoutId);
                timeoutId = setTimeout(() => {
                    const newFilters = { ...localFilters, search: searchTerm };
                    const params = { ...newFilters } as Record<string, string>;
                    Object.keys(params).forEach((key) => {
                        if (params[key] === 'all' || params[key] === '') delete params[key];
                    });
                    router.get(route('country.index'), params);
                }, 500); // 500ms delay
            };
        })(),
        [localFilters],
    );

    const { data, setData, processing, errors, setError, reset } = useForm<{
        name_en: string;
        name_ar: string;
        status: 'active' | 'suspended';
    }>({
        name_en: '',
        name_ar: '',
        status: 'active',
    });

    // Handle filter changes
    const handleFilterChange = (key: string, value: string) => {
        setLocalFilters((prev) => ({ ...prev, [key]: value }));

        // Apply filter immediately
        const newFilters = { ...localFilters, [key]: value };

        // Date validation
        if (key === 'date_from' && newFilters.date_to && value > newFilters.date_to) {
            // If start date is after end date, clear end date
            newFilters.date_to = '';
            setLocalFilters((prev) => ({ ...prev, date_to: '' }));
        }
        if (key === 'date_to' && newFilters.date_from && value < newFilters.date_from) {
            // If end date is before start date, don't apply
            toast.error('End date cannot be before start date');
            return;
        }

        const params = { ...newFilters } as Record<string, string>;
        Object.keys(params).forEach((key) => {
            if (params[key] === 'all' || params[key] === '') delete params[key];
        });
        router.get(route('country.index'), params);
    };

    const applyFilters = () => {
        const params = { ...localFilters } as Record<string, string>;
        Object.keys(params).forEach((key) => {
            if (params[key] === 'all' || params[key] === '') delete params[key];
        });
        router.get(route('country.index'), params);
    };

    const clearFilters = () => {
        setLocalFilters({
            search: '',
            status: 'all',
            date_from: '',
            date_to: '',
        });
        router.get(route('country.index'), {});
    };

    // Export function
    const handleExport = async () => {
        try {
            const exportFilters: Record<string, string> = { ...localFilters };
            // Remove 'all' values for export
            Object.keys(exportFilters).forEach((key) => {
                if (exportFilters[key] === 'all') {
                    delete exportFilters[key];
                }
            });

            await ExportService.exportCountries(exportFilters);
            toast.success('Countries exported successfully');
        } catch (error) {
            console.error('Export failed:', error);
            toast.error('Failed to export countries. Please try again.');
        }
    };

    // Modal handlers
    const closeModal = () => {
        setIsOpenCreateModal(false);
        setCountryToEdit(null);
        reset();
    };

    const openCreateModal = () => {
        setIsOpenCreateModal(true);
        setCountryToEdit(null);
        reset();
    };

    const openEditModal = (country: Country) => {
        setCountryToEdit(country);
        setData({
            name_en: country.name_en,
            name_ar: country.name_ar,
            status: country.status,
        });
        setIsOpenCreateModal(true);
    };

    // Form submission
    const handleSubmit = () => {
        if (countryToEdit) {
            router.put(route('country.update', countryToEdit.id), data, {
                onSuccess: () => {
                    toast.success('Country updated successfully');
                    closeModal();
                },
                onError: () => {
                    toast.error('Please fix the errors below');
                },
            });
        } else {
            router.post(route('country.store'), data, {
                onSuccess: () => {
                    toast.success('Country created successfully');
                    closeModal();
                },
                onError: (error) => {
                    const newErrorsPayload = {
                        ...error,
                        name_ar: 'The Arabic name is required.',
                    };
                    setError(newErrorsPayload as any);
                    toast.error('Please fix the errors below');
                },
            });
        }
    };

    // Status toggle
    const handleToggleStatus = (country: Country) => {
        setConfirmDialog({
            open: true,
            country,
            action: country.status === 'suspended' ? 'activate' : 'suspend',
        });
    };

    const confirmToggleStatus = () => {
        if (confirmDialog.country) {
            router.post(
                route('country.toggle-status', confirmDialog.country.id),
                {},
                {
                    onSuccess: () => {
                        toast.success('Status updated successfully');
                        setConfirmDialog({ open: false, country: null, action: null });
                    },
                    onError: () => {
                        toast.error('Failed to update status');
                        setConfirmDialog({ open: false, country: null, action: null });
                    },
                },
            );
        }
    };

    // Delete handlers
    const openDeleteDialog = (country: Country) => {
        setConfirmDialog({ open: true, country, action: 'delete' });
    };

    const confirmDelete = () => {
        if (confirmDialog.country) {
            router.delete(route('country.destroy', confirmDialog.country.id), {
                onSuccess: () => {
                    toast.success('Country deleted successfully');
                    setConfirmDialog({ open: false, country: null, action: null });
                },
                onError: () => {
                    toast.error('Failed to delete country');
                    setConfirmDialog({ open: false, country: null, action: null });
                },
            });
        }
    };

    // Status utilities
    const statusColors: Record<string, string> = {
        active: 'bg-green-600',
        suspended: 'bg-red-600',
    };

    const getStatusColor = (status: string) => statusColors[status.toLowerCase()] || 'bg-gray-700';

    const getStatusLabelEn = (status: string) => {
        switch (status.toLowerCase()) {
            case 'active':
                return 'Active';
            case 'suspended':
                return 'Suspended';
            default:
                return status;
        }
    };

    const getStatusLabelAr = (status: string) => {
        switch (status.toLowerCase()) {
            case 'active':
                return 'نشط';
            case 'suspended':
                return 'معلق';
            default:
                return status;
        }
    };

    // Flash messages
    useEffect(() => {
        // Removed flash message handling to prevent duplicate messages
        // Toast notifications are handled in the router callbacks
    }, [flash]);

    return (
        <AppLayout>
            <Head title="Countries - Expoza" />

            <div className="p-6">
                {/* Header */}
                <div className="mb-6 flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between">
                    <div>
                        <h1 className="text-2xl font-bold">Countries</h1>
                        <p className="text-sm text-gray-600 dark:text-gray-400">Manage countries and their status</p>
                    </div>
                    <div className="flex gap-2">
                        <ExportButton title="Export CSV" onClick={handleExport} />
                        <Button variant="default" onClick={openCreateModal}>
                            Add Country
                        </Button>
                    </div>
                </div>

                {/* Filters */}
                <Card className="mb-6">
                    <CardHeader>
                        <CardTitle>Filters</CardTitle>
                    </CardHeader>
                    <CardContent>
                        <div className="flex flex-wrap items-end gap-4">
                            <Input
                                type="text"
                                placeholder="Search countries..."
                                value={localFilters.search}
                                onChange={(e) => handleFilterChange('search', e.target.value)}
                                className="w-48"
                            />
                            <StatusFilter
                                value={localFilters.status}
                                onChange={(v) => handleFilterChange('status', v)}
                                statusOptions={[
                                    { value: 'all', label: 'All Statuses' },
                                    { value: 'active', label: 'Active' },
                                    { value: 'suspended', label: 'Suspended' },
                                ]}
                                placeholder="Filter by status"
                                className="w-70"
                            />
                            <div>
                                <label className="text-sm font-medium">Date From</label>
                                <Input
                                    type="date"
                                    value={localFilters.date_from}
                                    min="2015-01-01"
                                    onChange={(e) => handleFilterChange('date_from', e.target.value)}
                                />
                            </div>
                            <div>
                                <label className="text-sm font-medium">Date To</label>
                                <Input
                                    type="date"
                                    value={localFilters.date_to}
                                    onChange={(e) => handleFilterChange('date_to', e.target.value)}
                                    min="2015-01-01"
                                />
                            </div>
                            <Button variant="outline" onClick={clearFilters}>
                                Clear Filters
                            </Button>
                        </div>
                    </CardContent>
                </Card>
                {/* Countries Table */}
                <div className="overflow-x-auto">
                    <table className="min-w-full border bg-white dark:bg-neutral-900">
                        <thead>
                            <tr>
                                <th className="border px-4 py-2">#</th>
                                <th className="border px-4 py-2">Name (EN)</th>
                                <th className="border px-4 py-2">Name (AR)</th>
                                <th className="border px-4 py-2">Status</th>
                                <th className="border px-4 py-2">Created</th>
                                <th className="border px-4 py-2">Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            {countries.data.length === 0 ? (
                                <tr>
                                    <td colSpan={6} className="border px-4 py-2 text-center text-gray-500">
                                        No countries found.
                                    </td>
                                </tr>
                            ) : (
                                countries.data.map((country, index) => (
                                    <tr key={country.id}>
                                        <td className="border px-4 py-2 text-center">
                                            {(countries.current_page - 1) * countries.per_page + index + 1}
                                        </td>
                                        <td className="border px-4 py-2 text-center">{country.name_en}</td>
                                        <td className="border px-4 py-2 text-center" dir="rtl">
                                            {country.name_ar}
                                        </td>
                                        <td className="border px-4 py-2 text-center">
                                            <span
                                                className={`inline-block min-w-[90px] rounded px-2 py-1 text-xs font-semibold capitalize ${getStatusColor(country.status)} text-center text-white`}
                                            >
                                                {language === 'ar' ? getStatusLabelAr(country.status) : getStatusLabelEn(country.status)}
                                            </span>
                                        </td>
                                        <td className="border px-4 py-2 text-center text-sm">{new Date(country.created_at).toLocaleDateString()}</td>
                                        <td className="border px-4 py-2 text-center">
                                            <div className="flex justify-center gap-2">
                                                <Button size="sm" variant="outline" onClick={() => openEditModal(country)}>
                                                    Edit
                                                </Button>
                                                <ActionButtonSuspend
                                                    variant={country.status === 'suspended' ? 'default' : 'outline'}
                                                    onClick={() => handleToggleStatus(country)}
                                                    btnTitle={country.status === 'suspended' ? 'Activate' : 'Suspend'}
                                                />
                                                <ActionButtonDelete btnTitle="Delete" onClick={() => openDeleteDialog(country)} />
                                            </div>
                                        </td>
                                    </tr>
                                ))
                            )}
                        </tbody>
                    </table>
                </div>

                {/* Pagination */}
                {countries.last_page > 1 && (
                    <div className="mt-4 flex justify-center">
                        <div className="flex gap-1">
                            {countries.links.map((link, index) => (
                                <Button key={index} asChild variant={link.active ? 'default' : 'outline'} disabled={!link.url} size="sm">
                                    {link.url ? (
                                        <Link href={link.url}>{link.label.replace(/&laquo;|&raquo;/g, '')}</Link>
                                    ) : (
                                        <span>{link.label.replace(/&laquo;|&raquo;/g, '')}</span>
                                    )}
                                </Button>
                            ))}
                        </div>
                    </div>
                )}

                {/* Create/Edit Modal */}
                <Dialog open={isOpenCreateModal} onOpenChange={setIsOpenCreateModal}>
                    <DialogContent className="w-full max-w-md">
                        <DialogHeader>
                            <DialogTitle>{countryToEdit ? 'Edit Country' : 'Create Country'}</DialogTitle>
                        </DialogHeader>
                        <div className="space-y-4">
                            <div>
                                <label htmlFor="name_en" className="text-sm font-medium">
                                    Country Name (EN) <span className="text-red-500">*</span>
                                </label>
                                <Input
                                    id="name_en"
                                    value={data.name_en}
                                    onChange={(e) => setData('name_en', e.target.value)}
                                    className={errors.name_en ? 'border-red-500' : ''}
                                />
                                {errors.name_en && <div className="mt-1 text-xs text-red-500">{errors.name_en}</div>}
                            </div>
                            <div>
                                <label htmlFor="name_ar" className="text-sm font-medium">
                                    Country Name (AR) <span className="text-red-500">*</span>
                                </label>
                                <Input
                                    id="name_ar"
                                    value={data.name_ar}
                                    onChange={(e) => setData('name_ar', e.target.value)}
                                    dir="rtl"
                                    className={errors.name_ar ? 'border-red-500' : ''}
                                />
                                {errors.name_ar && <div className="mt-1 text-xs text-red-500">{errors.name_ar}</div>}
                            </div>
                            <div>
                                <label htmlFor="status" className="text-sm font-medium">
                                    Status <span className="text-red-500">*</span>
                                </label>
                                <Select value={data.status} onValueChange={(value: 'active' | 'suspended') => setData('status', value)}>
                                    <SelectTrigger className={errors.status ? 'border-red-500' : ''}>
                                        <SelectValue placeholder="Select status" />
                                    </SelectTrigger>
                                    <SelectContent>
                                        <SelectItem value="active">Active</SelectItem>
                                        <SelectItem value="suspended">Suspended</SelectItem>
                                    </SelectContent>
                                </Select>
                                {errors.status && <div className="mt-1 text-xs text-red-500">{errors.status}</div>}
                            </div>
                        </div>
                        <DialogFooter>
                            <Button variant="outline" onClick={closeModal}>
                                Cancel
                            </Button>
                            <Button onClick={handleSubmit} disabled={processing}>
                                {processing ? 'Saving...' : countryToEdit ? 'Update' : 'Create'}
                            </Button>
                        </DialogFooter>
                    </DialogContent>
                </Dialog>

                {/* Confirmation Dialog */}
                <Dialog open={confirmDialog.open} onOpenChange={(open) => setConfirmDialog({ ...confirmDialog, open })}>
                    <DialogContent>
                        <DialogHeader>
                            <DialogTitle>
                                {confirmDialog.action === 'activate' && 'Activate Country'}
                                {confirmDialog.action === 'suspend' && 'Suspend Country'}
                                {confirmDialog.action === 'delete' && 'Delete Country'}
                            </DialogTitle>
                        </DialogHeader>
                        <div className="py-4">
                            <p>
                                {confirmDialog.action === 'activate' && `Are you sure you want to activate "${confirmDialog.country?.name_en}"?`}
                                {confirmDialog.action === 'suspend' && `Are you sure you want to suspend "${confirmDialog.country?.name_en}"?`}
                                {confirmDialog.action === 'delete' &&
                                    `Are you sure you want to delete "${confirmDialog.country?.name_en}"? This action cannot be undone.`}
                            </p>
                        </div>
                        <DialogFooter>
                            <Button variant="outline" onClick={() => setConfirmDialog({ open: false, country: null, action: null })}>
                                Cancel
                            </Button>
                            <Button
                                variant={confirmDialog.action === 'delete' ? 'destructive' : 'default'}
                                onClick={confirmDialog.action === 'delete' ? confirmDelete : confirmToggleStatus}
                            >
                                {confirmDialog.action === 'activate' && 'Activate'}
                                {confirmDialog.action === 'suspend' && 'Suspend'}
                                {confirmDialog.action === 'delete' && 'Delete'}
                            </Button>
                        </DialogFooter>
                    </DialogContent>
                </Dialog>
            </div>
        </AppLayout>
    );
};

export default CountryIndex;
