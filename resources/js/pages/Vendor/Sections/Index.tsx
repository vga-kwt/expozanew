/* eslint-disable @typescript-eslint/no-explicit-any */
import { ActionButtonDelete, ActionButtonSuspend } from '@/components/action-button';
import { useLanguage } from '@/components/language-context';
import ExportButton from '@/components/export-button';
import SectionFormModal from '@/components/modals/SectionFormModal';
import SectionProductViewModal from '@/components/modals/SectionProductViewModal';
import { Button } from '@/components/ui/button';
import { Dialog, DialogContent, DialogFooter, DialogHeader, DialogTitle } from '@/components/ui/dialog';
import { Input } from '@/components/ui/input';
import { StatusFilter } from '@/components/ui/StatusFilter';
import AppLayout from '@/layouts/app-layout';
import ExportService from '@/utils/exportService';
import { Head, router, useForm, usePage } from '@inertiajs/react';
import React, { useCallback, useState } from 'react';
import toast from 'react-hot-toast';

interface Section {
    id: number;
    name: string;
    category_id: number | null;
    status: 'active' | 'suspended';
    product_ids: string[];
    created_at: string;
    updated_at: string;
    category?: { name_en?: string; name?: string };
    section_products?: SectionProducts[];
}

interface SectionProducts {
    created_at: string;
    deleted_at: string;
    id: number;
    product_id: number;
    section_id: number;
    updated_at: string;
    vendor_id: number;
}

interface PaginatedData {
    data: Section[];
    current_page: number;
    last_page: number;
    per_page: number;
    total: number;
    links: { url: string | null; label: string; active: boolean }[];
}

interface Props {
    sections: PaginatedData;
    product: {
        id: number;
        name_en: string;
    }[];
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

const SectionIndex = () => {
    const { t } = useLanguage();
    const { props } = usePage<Props>();
    const { sections, filters } = props;
    const [isOpenFormModal, setIsOpenFormModal] = useState<boolean>(false);
    const sectionRows = sections?.data || [];

    const [localFilters, setLocalFilters] = useState({
        search: filters?.search || '',
        status: filters?.status || 'all',
        date_from: filters?.date_from || '',
        date_to: filters?.date_to || '',
    });
    const [sectionToEdit, setSectionToEdit] = useState<Section | null>(null);
    const [statusDialog, setStatusDialog] = useState<{ open: boolean; section: Section | null; action: string | null }>({
        open: false,
        section: null,
        action: null,
    });
    const [deleteDialog, setDeleteDialog] = useState<{
        open: boolean;
        section: Section | null;
    }>({
        open: false,
        section: null,
    });
    const [viewModal, setViewModal] = useState<{
        isOpen: boolean;
        products: any[] | null;
    }>({
        isOpen: false,
        products: null,
    });

    // Debounced search function
    const debouncedSearch = useCallback(
        (() => {
            let timeoutId: NodeJS.Timeout;
            return (value: string) => {
                clearTimeout(timeoutId);
                timeoutId = setTimeout(() => {
                    handleFilterChange('search', value);
                }, 500);
            };
        })(),
        [],
    );

    const { data, setData, errors, reset, clearErrors, put } = useForm<{
        id?: number;
        name: string;
        category_id: number | null;
        product_ids: string[];
        status: 'active' | 'suspended';
    }>({
        id: undefined,
        name: '',
        category_id: null,
        product_ids: [],
        status: 'active',
    });

    const handleFilterChange = (key: string, value: string) => {
        const newFilters = { ...localFilters, [key]: value };

        if (key === 'date_from' && newFilters.date_to && value > newFilters.date_to) {
            newFilters.date_to = '';
        }
        if (key === 'date_to' && newFilters.date_from && value < newFilters.date_from) {
            toast.error('End date cannot be before start date');
            return;
        }

        setLocalFilters(newFilters);

        const params = { ...newFilters } as Record<string, string>;
        Object.keys(params).forEach((key) => {
            if (params[key] === 'all' || params[key] === '') delete params[key];
        });
        router.get(route('section.index'), params);
    };

    const clearFilters = () => {
        setLocalFilters({
            search: '',
            status: 'all',
            date_from: '',
            date_to: '',
        });
        router.get(route('section.index'), {});
    };

    const handleExport = async () => {
        try {
            const exportFilters = { ...localFilters } as Record<string, string>;
            // Remove 'all' values for export
            Object.keys(exportFilters).forEach((key) => {
                if (exportFilters[key] === 'all') {
                    delete exportFilters[key];
                }
            });

            await ExportService.exportSections(exportFilters);
            toast.success('Sections exported successfully');
        } catch (error) {
            console.error('Export error:', error);
            toast.error('Failed to export sections');
        }
    };

    const handleToggleStatus = (section: Section) => {
        setStatusDialog({
            open: true,
            section,
            action: section?.status === 'suspended' ? 'activate' : 'suspend',
        });
    };

    const handleConfirmStatus = () => {
        if (!statusDialog.section) return;
        router.put(
            route('section.updateStatus', statusDialog.section.id),
            { status: statusDialog.action === 'suspend' ? 'suspended' : 'active' },
            {
                onSuccess: () => setStatusDialog({ open: false, section: null, action: null }),
            },
        );
    };

    const openEditModal = (section: Section) => {
        setSectionToEdit(section);
        setData({
            id: section.id,
            name: section.name,
            category_id: section.category_id,
            product_ids: section.section_products ? section.section_products.map((sp) => String(sp.product_id)) : [],
            status: section.status,
        });
        setIsOpenFormModal(true);
    };

    const statusColors: Record<string, string> = {
        active: 'bg-green-600',
        suspended: 'bg-red-600',
    };

    const getStatusColor = (status: string) => statusColors[status.toLowerCase()] || 'bg-gray-700';

    const openDeleteDialog = (section: Section) => {
        setDeleteDialog({ open: true, section });
    };

    const handleSubmitSectionData = (e: React.FormEvent) => {
        e.preventDefault();
        clearErrors();

        router.post(route('section.store'), data, {
            onSuccess: () => {
                setIsOpenFormModal(false);
                reset();
            },
        });
    };

    const handleUpdateSection = () => {
        put(route('section.update', sectionToEdit?.id), {
            preserveScroll: true,
            onSuccess: () => {
                setIsOpenFormModal(false);
                reset();
                setSectionToEdit(null);
            },
        });
    };

    const handleViewProductDetails = (data: Section['section_products']) => {
        const productIds = data?.map((i) => i.product_id);
        const matchingProducts = props.product.filter((j) => productIds?.includes(j.id));
        setViewModal({
            isOpen: true,
            products: matchingProducts,
        });
    };

    return (
        <AppLayout>
            <Head title={t('vendor.sectionPage')} />
            <div className="p-6">
                <div className="mb-6 flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between">
                    <h1 className="text-2xl font-bold">{t('sidebar.mySections')}</h1>
                    <div className="flex gap-2">
                        <ExportButton title={t('sections.exportCsv')} onClick={handleExport} />
                        <Button variant="default" onClick={() => setIsOpenFormModal(true)}>
                            {t('sections.addSection')}
                        </Button>
                    </div>
                </div>
                <div className="mb-6 flex flex-wrap justify-end gap-4">
                    <Input
                        type="text"
                        placeholder={t('sections.searchSections')}
                        value={localFilters.search}
                        onChange={(e) => {
                            setLocalFilters((prev) => ({ ...prev, search: e.target.value }));
                            debouncedSearch(e.target.value);
                        }}
                        className="w-48"
                    />
                    <StatusFilter
                        value={localFilters.status}
                        onChange={(v) => handleFilterChange('status', v)}
                        statusOptions={[
                            { value: 'all', label: t('sections.allStatuses') },
                            { value: 'active', label: t('expos.active') },
                            { value: 'suspended', label: t('expos.suspended') },
                        ]}
                        placeholder={t('sections.filterByStatus')}
                        className="w-70"
                    />
                    <Input
                        type="date"
                        value={localFilters.date_from}
                        onChange={(e) => handleFilterChange('date_from', e.target.value)}
                        className="w-auto"
                    />
                    <Input
                        type="date"
                        value={localFilters.date_to}
                        onChange={(e) => handleFilterChange('date_to', e.target.value)}
                        min={localFilters.date_from || undefined}
                        className="w-auto"
                    />
                    <Button variant="outline" onClick={clearFilters}>
                        {t('products.clearFilters')}
                    </Button>
                </div>
                <div className="overflow-x-auto">
                    <table className="min-w-full border bg-white dark:bg-neutral-900">
                        <thead>
                            <tr>
                                <th className="border px-4 py-2">#</th>
                                <th className="border px-4 py-2">{t('sections.sectionName')}</th>
                                <th className="border px-4 py-2">{t('sections.category')}</th>
                                <th className="border px-4 py-2">{t('common.status')}</th>
                                <th className="border px-4 py-2">{t('sections.created')}</th>
                                <th className="border px-4 py-2">{t('common.actions')}</th>
                            </tr>
                        </thead>
                        <tbody>
                            {sectionRows.length === 0 ? (
                                <tr>
                                    <td colSpan={7} className="border px-4 py-2 text-center text-gray-500">
                                        {t('sections.noSectionsFound')}
                                    </td>
                                </tr>
                            ) : (
                                sectionRows.map((section: Section, index: number) => (
                                    <tr key={index}>
                                        <td className="border px-4 py-2 text-center">{index + 1}</td>
                                        <td className="border px-4 py-2 text-center">{section.name}</td>
                                        <td className="border px-4 py-2 text-center">
                                            {section.category?.name_en || section.category?.name || 'N/A'}
                                        </td>
                                        <td className="border px-4 py-2 text-center">
                                            <span
                                                className={`inline-block min-w-[90px] rounded px-2 py-1 text-xs font-semibold capitalize ${getStatusColor(section.status)} text-center text-white`}
                                            >
                                                {section.status}
                                            </span>
                                        </td>
                                        <td className="border px-4 py-2 text-center text-sm">{new Date(section.created_at).toLocaleDateString()}</td>
                                        <td className="border px-4 py-2 text-center">
                                            <div className="flex justify-center gap-2">
                                                <Button
                                                    size="sm"
                                                    variant="outline"
                                                    onClick={() => handleViewProductDetails(section.section_products)}
                                                >
                                                    {t('orders.view')}
                                                </Button>
                                                <Button size="sm" variant="outline" onClick={() => openEditModal(section)}>
                                                    {t('common.edit')}
                                                </Button>
                                                <ActionButtonSuspend
                                                    variant={section.status === 'suspended' ? 'default' : 'outline'}
                                                    onClick={() => handleToggleStatus(section)}
                                                    btnTitle={section.status === 'suspended' ? t('products.activate') : t('products.suspend')}
                                                />
                                                <ActionButtonDelete btnTitle={t('common.delete')} onClick={() => openDeleteDialog(section)} />
                                            </div>
                                        </td>
                                    </tr>
                                ))
                            )}
                        </tbody>
                    </table>
                </div>
                {sections?.last_page > 1 && (
                    <div className="mt-4 flex justify-center">
                        <div className="flex gap-1">
                            {sections?.links.map((link, index) => (
                                <Button key={index} asChild variant={link.active ? 'default' : 'outline'} disabled={!link.url} size="sm">
                                    {link.url ? (
                                        <a href={link.url}>{link.label.replace(/&laquo;|&raquo;/g, '')}</a>
                                    ) : (
                                        <span>{link.label.replace(/&laquo;|&raquo;/g, '')}</span>
                                    )}
                                </Button>
                            ))}
                        </div>
                    </div>
                )}
            </div>
            <SectionFormModal
                open={isOpenFormModal}
                onOpenChange={setIsOpenFormModal}
                formData={data}
                setFormData={setData}
                resetForm={reset}
                errors={errors}
                onConfirm={sectionToEdit ? handleUpdateSection : handleSubmitSectionData}
                categories={props.category}
                products={props.product}
            />

            <Dialog open={statusDialog.open} onOpenChange={(open) => setStatusDialog((s) => ({ ...s, open }))}>
                <DialogContent>
                    <DialogHeader>
                        <DialogTitle>{statusDialog.action === 'suspend' ? t('sections.suspendSection') : t('sections.activateSection')}</DialogTitle>
                    </DialogHeader>
                    <div>
                        {statusDialog.action === 'suspend' ? t('sections.confirmSuspendSection') : t('sections.confirmActivateSection')}{' '}
                        <b>{statusDialog.section?.name}</b>?
                    </div>
                    <DialogFooter>
                        <Button variant="outline" onClick={() => setStatusDialog({ open: false, section: null, action: null })}>
                            {t('common.cancel')}
                        </Button>
                        <Button variant={statusDialog.action === 'suspend' ? 'destructive' : 'default'} onClick={handleConfirmStatus}>
                            {statusDialog.action === 'suspend' ? t('products.suspend') : t('products.activate')}
                        </Button>
                    </DialogFooter>
                </DialogContent>
            </Dialog>

            <Dialog open={deleteDialog.open} onOpenChange={(open) => setDeleteDialog((s) => ({ ...s, open }))}>
                <DialogContent>
                    <DialogHeader>
                        <DialogTitle>{t('sections.deleteSection')}</DialogTitle>
                    </DialogHeader>
                    <div>
                        {t('sections.confirmDeleteSection')} <b>{deleteDialog.section?.name}</b>?
                    </div>
                    <DialogFooter>
                        <Button variant="outline" onClick={() => setDeleteDialog({ open: false, section: null })}>
                            {t('common.cancel')}
                        </Button>
                        <Button
                            variant="destructive"
                            onClick={() => {
                                if (deleteDialog.section) {
                                    router.delete(route('section.destroy', deleteDialog.section.id), {
                                        onSuccess: () => setDeleteDialog({ open: false, section: null }),
                                    });
                                }
                            }}
                        >
                            {t('common.delete')}
                        </Button>
                    </DialogFooter>
                </DialogContent>
            </Dialog>

            <SectionProductViewModal
                open={viewModal.isOpen}
                onOpenChange={(isOpen) => setViewModal((prev) => ({ ...prev, isOpen }))}
                data={viewModal.products}
            />
        </AppLayout>
    );
};
export default SectionIndex;
