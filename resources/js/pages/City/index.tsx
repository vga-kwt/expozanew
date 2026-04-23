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
import { useState } from 'react';
import { toast } from 'react-hot-toast';

interface City {
    id: number;
    name_en: string | null;
    name_ar: string | null;
    status: 'active' | 'suspended';
    created_at: string;
    updated_at: string;
    country: {
        id: number;
        name_en: string | null;
        name_ar: string | null;
    };
    state: {
        id: number;
        name_en: string | null;
        name_ar: string | null;
    };
}

interface Country {
    id: number;
    name_en: string | null;
    name_ar: string | null;
}

interface State {
    id: number;
    name_en: string | null;
    name_ar: string | null;
    country_id: number;
}

interface PaginatedData {
    data: City[];
    current_page: number;
    last_page: number;
    per_page: number;
    total: number;
    links: { url: string | null; label: string; active: boolean }[];
}

interface Props {
    cities: PaginatedData;
    statistics: {
        total: number;
        active: number;
        suspended: number;
        deleted: number;
    };
    filters: {
        search?: string;
        status?: string;
        country_id?: string;
        state_id?: string;
        date_from?: string;
        date_to?: string;
    };
    countries: Country[];
    states: State[];
    flash?: {
        success?: string;
        error?: string;
    };
    [key: string]: unknown;
}

const CityIndex = () => {
    const { language } = useLanguage();
    const { props } = usePage<Props>();
    const { cities, filters, countries, states } = props;

    const [isOpenCreateModal, setIsOpenCreateModal] = useState<boolean>(false);
    const [localFilters, setLocalFilters] = useState({
        search: filters.search || '',
        status: filters.status || 'all',
        country_id: filters.country_id || 'all',
        state_id: filters.state_id || 'all',
        date_from: filters.date_from || '',
        date_to: filters.date_to || '',
    });
    const [cityToEdit, setCityToEdit] = useState<City | null>(null);
    const [confirmDialog, setConfirmDialog] = useState<{
        open: boolean;
        city: City | null;
        action: 'suspend' | 'activate' | 'delete' | null;
    }>({
        open: false,
        city: null,
        action: null,
    });


    const { data, setData, processing, errors,setError, reset } = useForm<{
        country_id: string;
        state_id: string;
        name_en: string;
        name_ar: string;
        status: 'active' | 'suspended';
    }>({
        country_id: '',
        state_id: '',
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
        router.get(route('city.index'), params);
    };

    const clearFilters = () => {
        setLocalFilters({
            search: '',
            status: 'all',
            country_id: 'all',
            state_id: 'all',
            date_from: '',
            date_to: '',
        });
        router.get(route('city.index'), {});
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

            await ExportService.exportCities(exportFilters);
            toast.success('Cities exported successfully');
        } catch (error) {
            console.error('Export failed:', error);
            toast.error('Failed to export cities. Please try again.');
        }
    };

    // Modal handlers
    const closeModal = () => {
        setIsOpenCreateModal(false);
        setCityToEdit(null);
        reset();
    };

    const openCreateModal = () => {
        setIsOpenCreateModal(true);
        setCityToEdit(null);
        reset();
    };

    const openEditModal = (city: City) => {
        setCityToEdit(city);
        setData({
            country_id: city.country?.id?.toString() || '',
            state_id: city.state?.id?.toString() || '',
            name_en: city.name_en || '',
            name_ar: city.name_ar || '',
            status: city.status,
        });
        setIsOpenCreateModal(true);
    };

    // Form submission
    const handleSubmit = () => {
        if (cityToEdit) {
            router.put(route('city.update', cityToEdit.id), data, {
                onSuccess: () => {
                    toast.success('City updated successfully');
                    closeModal();
                },
                onError: () => {
                    toast.error('Please fix the errors below');
                },
            });
        } else {
            router.post(route('city.store'), data, {
                onSuccess: (errors) => {
                    setError(errors as any);
                    toast.success('City created successfully');
                    closeModal();
                },
                onError: (errors) => {
                     const newErrorsPayload = {
                        ...errors,
                        name_ar: 'City name in Arabic is required.',
                    };
                    setError(newErrorsPayload as any);
                    toast.error('Please fix the errors below');
                },
            });
        }
    };

    // Status toggle
    const handleToggleStatus = (city: City) => {
        setConfirmDialog({
            open: true,
            city,
            action: city.status === 'suspended' ? 'activate' : 'suspend',
        });
    };

    const confirmToggleStatus = () => {
        if (confirmDialog.city) {
            router.post(
                route('city.toggle-status', confirmDialog.city.id),
                {},
                {
                    onSuccess: () => {
                        toast.success('City status updated successfully');
                        setConfirmDialog({ open: false, city: null, action: null });
                    },
                    onError: () => {
                        toast.error('Failed to update city status');
                        setConfirmDialog({ open: false, city: null, action: null });
                    },
                },
            );
        }
    };

    // Delete handlers
    const openDeleteDialog = (city: City) => {
        setConfirmDialog({ open: true, city, action: 'delete' });
    };

    const confirmDelete = () => {
        if (confirmDialog.city) {
            router.delete(route('city.destroy', confirmDialog.city.id), {
                onSuccess: () => {
                    toast.success('City deleted successfully');
                    setConfirmDialog({ open: false, city: null, action: null });
                },
                onError: () => {
                    toast.error('Failed to delete city');
                    setConfirmDialog({ open: false, city: null, action: null });
                },
            });
        }
    };

    // Status colors and labels
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

    // Filter states by selected country
    const filteredStates = states.filter((state) => localFilters.country_id === 'all' || state.country_id.toString() === localFilters.country_id);

    return (
        <AppLayout>
            <Head title="Cities" />

            <div className="container mx-auto p-6">
                <div className="mb-6 flex items-center justify-between">
                    <h1 className="text-3xl font-bold">Cities</h1>
                    <div className="flex gap-2">
                        <ExportButton title="Export CSV" onClick={handleExport} />
                        <Button onClick={openCreateModal}>Add City</Button>
                    </div>
                </div>

                {/* Filters */}
                <Card className="mb-6">
                    <CardHeader>
                        <CardTitle>Filters</CardTitle>
                    </CardHeader>
                    <CardContent>
                        <div className="mb-4 flex flex-wrap gap-2">
                            <Input
                                type="text"
                                placeholder="Search cities..."
                                value={localFilters.search}
                                onChange={(e) => handleFilterChange('search', e.target.value)}
                                className="w-70"
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
                            />
                        </div>
                        <div className="grid grid-cols-1 gap-4 md:grid-cols-6">
                            <div>
                                <label className="text-sm font-medium">Country</label>
                                <Select value={localFilters.country_id} onValueChange={(value) => handleFilterChange('country_id', value)}>
                                    <SelectTrigger>
                                        <SelectValue placeholder="All Countries" />
                                    </SelectTrigger>
                                    <SelectContent>
                                        <SelectItem value="all">All Countries</SelectItem>
                                        {countries.map((country) => (
                                            <SelectItem key={country.id} value={country.id.toString()}>
                                                {language === 'ar' ? (country.name_ar || '-') : (country.name_en || '-')}
                                            </SelectItem>
                                        ))}
                                    </SelectContent>
                                </Select>
                            </div>
                            <div>
                                <label className="text-sm font-medium">State</label>
                                <Select value={localFilters.state_id} onValueChange={(value) => handleFilterChange('state_id', value)}>
                                    <SelectTrigger>
                                        <SelectValue placeholder="All States" />
                                    </SelectTrigger>
                                    <SelectContent>
                                        <SelectItem value="all">All States</SelectItem>
                                        {filteredStates.map((state) => (
                                            <SelectItem key={state.id} value={state.id.toString()}>
                                                {language === 'ar' ? (state.name_ar || '-') : (state.name_en || '-')}
                                            </SelectItem>
                                        ))}
                                    </SelectContent>
                                </Select>
                            </div>
                            <div>
                                <label className="text-sm font-medium">Date From</label>
                                <Input
                                    type="date"
                                    value={localFilters.date_from}
                                    onChange={(e) => handleFilterChange('date_from', e.target.value)}
                                    min="2015-01-01"
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
                        </div>
                        <div className="mt-4 flex justify-end">
                            <Button variant="outline" onClick={clearFilters}>
                                Clear Filters
                            </Button>
                        </div>
                    </CardContent>
                </Card>

                {/* Cities Table */}
                <div className="overflow-x-auto">
                    <table className="min-w-full border bg-white dark:bg-neutral-900">
                        <thead>
                            <tr>
                                <th className="border px-4 py-2">#</th>
                                <th className="border px-4 py-2">Name (EN)</th>
                                <th className="border px-4 py-2">Name (AR)</th>
                                <th className="border px-4 py-2">Country</th>
                                <th className="border px-4 py-2">State</th>
                                <th className="border px-4 py-2">Status</th>
                                <th className="border px-4 py-2">Created</th>
                                <th className="border px-4 py-2">Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            {cities.data.length === 0 ? (
                                <tr>
                                    <td colSpan={8} className="border px-4 py-2 text-center text-gray-500">
                                        No cities found.
                                    </td>
                                </tr>
                            ) : (
                                cities.data.map((city, index) => (
                                    <tr key={city.id}>
                                        <td className="border px-4 py-2 text-center">{(cities.current_page - 1) * cities.per_page + index + 1}</td>
                                        <td className="border px-4 py-2 text-center">{city.name_en || '-'}</td>
                                        <td className="border px-4 py-2 text-center" dir="rtl">
                                            {city.name_ar || '-'}
                                        </td>
                                        <td className="border px-4 py-2 text-center">
                                            {city.country ? (language === 'ar' ? city.country.name_ar : city.country.name_en) : '-'}
                                        </td>
                                        <td className="border px-4 py-2 text-center">
                                            {city.state ? (language === 'ar' ? city.state.name_ar : city.state.name_en) : '-'}
                                        </td>
                                        <td className="border px-4 py-2 text-center">
                                            <span
                                                className={`inline-block min-w-[90px] rounded px-2 py-1 text-xs font-semibold capitalize ${getStatusColor(city.status)} text-center text-white`}
                                            >
                                                {language === 'ar' ? getStatusLabelAr(city.status) : getStatusLabelEn(city.status)}
                                            </span>
                                        </td>
                                        <td className="border px-4 py-2 text-center text-sm">{new Date(city.created_at).toLocaleDateString()}</td>
                                        <td className="border px-4 py-2 text-center">
                                            <div className="flex justify-center gap-2">
                                                <Button size="sm" variant="outline" onClick={() => openEditModal(city)}>
                                                    Edit
                                                </Button>
                                                <ActionButtonSuspend
                                                    variant={city.status === 'suspended' ? 'default' : 'outline'}
                                                    onClick={() => handleToggleStatus(city)}
                                                    btnTitle={city.status === 'suspended' ? 'Activate' : 'Suspend'}
                                                />
                                                <ActionButtonDelete btnTitle="Delete" onClick={() => openDeleteDialog(city)} />
                                            </div>
                                        </td>
                                    </tr>
                                ))
                            )}
                        </tbody>
                    </table>
                </div>

                {/* Pagination */}
                {cities.last_page > 1 && (
                    <div className="mt-4 flex justify-center">
                        <div className="flex gap-1">
                            {cities.links.map((link, index) => (
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
                            <DialogTitle>{cityToEdit ? 'Edit City' : 'Create City'}</DialogTitle>
                        </DialogHeader>
                        <div className="space-y-4">
                            <div>
                                <label htmlFor="country_id" className="text-sm font-medium">
                                    Country <span className='text-red-500'>*</span>
                                </label>
                                <Select value={data.country_id} onValueChange={(value) => setData('country_id', value)}>
                                    <SelectTrigger>
                                        <SelectValue placeholder="Select Country" />
                                    </SelectTrigger>
                                    <SelectContent>
                                        {countries.map((country) => (
                                            <SelectItem key={country.id} value={country.id.toString()}>
                                                {language === 'ar' ? (country.name_ar || '-') : (country.name_en || '-')}
                                            </SelectItem>
                                        ))}
                                    </SelectContent>
                                </Select>
                                {errors.country_id && <p className="mt-1 text-sm text-red-600">{errors.country_id}</p>}
                            </div>

                            <div>
                                <label htmlFor="state_id" className="text-sm font-medium">
                                    State <span className='text-red-500'>*</span>
                                </label>
                                <Select value={data.state_id} onValueChange={(value) => setData('state_id', value)}>
                                    <SelectTrigger>
                                        <SelectValue placeholder="Select State" />
                                    </SelectTrigger>
                                    <SelectContent>
                                        {states
                                            .filter((state) => !data.country_id || state.country_id.toString() === data.country_id)
                                            .map((state) => (
                                                <SelectItem key={state.id} value={state.id.toString()}>
                                                    {language === 'ar' ? state.name_ar : state.name_en}
                                                </SelectItem>
                                            ))}
                                    </SelectContent>
                                </Select>
                                {errors.state_id && <p className="mt-1 text-sm text-red-600">{errors.state_id}</p>}
                            </div>

                            <div>
                                <label htmlFor="name_en" className="text-sm font-medium">
                                    City Name (EN) <span className='text-red-500'>*</span>
                                </label>
                                <Input
                                    id="name_en"
                                    value={data.name_en}
                                    onChange={(e) => setData('name_en', e.target.value)}
                                    placeholder="Enter city name in English"
                                />
                                {errors.name_en && <p className="mt-1 text-sm text-red-600">{errors.name_en}</p>}
                            </div>

                            <div>
                                <label htmlFor="name_ar" className="text-sm font-medium">
                                    City Name (AR) <span className='text-red-500'>*</span>
                                </label>
                                <Input
                                    id="name_ar"
                                    value={data.name_ar}
                                    onChange={(e) => setData('name_ar', e.target.value)}
                                    placeholder="أدخل اسم المدينة بالعربية"
                                    dir="rtl"
                                />
                                {errors.name_ar && <p className="mt-1 text-sm text-red-600">{errors.name_ar}</p>}
                            </div>

                            <div>
                                <label htmlFor="status" className="text-sm font-medium">
                                    Status <span className='text-red-500'>*</span>
                                </label>
                                <Select value={data.status} onValueChange={(value: 'active' | 'suspended') => setData('status', value)}>
                                    <SelectTrigger>
                                        <SelectValue placeholder="Select Status" />
                                    </SelectTrigger>
                                    <SelectContent>
                                        <SelectItem value="active">Active</SelectItem>
                                        <SelectItem value="suspended">Suspended</SelectItem>
                                    </SelectContent>
                                </Select>
                                {errors.status && <p className="mt-1 text-sm text-red-600">{errors.status}</p>}
                            </div>
                        </div>
                        <DialogFooter>
                            <Button variant="outline" onClick={closeModal}>
                                Cancel
                            </Button>
                            <Button onClick={handleSubmit} disabled={processing}>
                                {processing ? 'Saving...' : cityToEdit ? 'Update' : 'Create'}
                            </Button>
                        </DialogFooter>
                    </DialogContent>
                </Dialog>

                {/* Confirmation Dialog */}
                <Dialog open={confirmDialog.open} onOpenChange={(open) => setConfirmDialog((prev) => ({ ...prev, open }))}>
                    <DialogContent>
                        <DialogHeader>
                            <DialogTitle>
                                {confirmDialog.action === 'delete' && 'Delete City'}
                                {confirmDialog.action === 'suspend' && 'Suspend City'}
                                {confirmDialog.action === 'activate' && 'Activate City'}
                            </DialogTitle>
                        </DialogHeader>
                        <div className="py-4">
                            <p>
                                {confirmDialog.action === 'delete' && `Are you sure you want to delete "${confirmDialog.city?.name_en || 'this city'}"?`}
                                {confirmDialog.action === 'suspend' && `Are you sure you want to suspend "${confirmDialog.city?.name_en || 'this city'}"?`}
                                {confirmDialog.action === 'activate' && `Are you sure you want to activate "${confirmDialog.city?.name_en || 'this city'}"?`}
                            </p>
                        </div>
                        <DialogFooter>
                            <Button variant="outline" onClick={() => setConfirmDialog({ open: false, city: null, action: null })}>
                                Cancel
                            </Button>
                            <Button
                                variant={confirmDialog.action === 'delete' ? 'destructive' : 'default'}
                                onClick={confirmDialog.action === 'delete' ? confirmDelete : confirmToggleStatus}
                            >
                                {confirmDialog.action === 'delete' && 'Delete'}
                                {confirmDialog.action === 'suspend' && 'Suspend'}
                                {confirmDialog.action === 'activate' && 'Activate'}
                            </Button>
                        </DialogFooter>
                    </DialogContent>
                </Dialog>
            </div>
        </AppLayout>
    );
};

export default CityIndex;
