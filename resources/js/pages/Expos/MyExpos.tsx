import { Button } from '@/components/ui/button';
import { useLanguage } from '@/components/language-context';
import AppLayout from '@/layouts/app-layout';
import { Head, usePage } from '@inertiajs/react';
import dayjs from 'dayjs';
import isSameOrAfter from 'dayjs/plugin/isSameOrAfter';
import { Clock, Hourglass, Package, Grid3X3, AlertTriangle, Settings } from 'lucide-react';
import { useState } from 'react';
import ManageProductsModal from '@/components/modals/ManageProductsModal';
import ManageSectionsModal from '@/components/modals/ManageSectionsModal';

dayjs.extend(isSameOrAfter);

interface Product {
    id: number;
    name_en: string;
    name_ar?: string;
    section_id?: number;
    discount?: number;
    image?: string;
    slot_id?: number;
    assigned_slot?: number;
}

interface Section {
    id: number;
    name_en: string;
    name: string;
    name_ar?: string;
    category_id: number;
    products_in_section?: number;
    total_available_products?: number;
    remaining_products?: number;
    utilization_percentage?: number;
    is_full?: boolean;
    products?: Product[];
    assigned_slot_id?: number;
}

interface Category {
    id: number;
    name_en: string;
    name_ar?: string;
}

interface Slot {
    id: number;
    slot_number: number;
    max_products: number;
    assigned_products: number;
    assigned_expo_section_product: number;
    total_assigned: number;
    current_products: number;
    remaining_products: number;
    products: Product[];
    utilization_percentage: number;
    is_full: boolean;
}

interface MyExpo {
    id: number;
    title_en: string;
    products: Product[];
    sections: Section[];
    expired: boolean;
    categories?: Category[];
    maxProducts?: number;
    start_date?: string;
    end_date?: string;
    slotNumber?: number;
    slotCount?: number;
    capacityPerSlot?: number;
    status?: string;
    vendor_slot_capacity?: number;
    // Enhanced slot management properties
    currentProducts?: number;
    remainingCapacity?: number;
    totalSlots?: number;
    utilization_percentage?: number;
    is_full?: boolean;
    slots?: Slot[];
    slots_booked?: number;
    total_slots_available?: number;
}

export default function MyExpos() {
    const { t } = useLanguage();
    const myExpos = (usePage().props as { myExpos?: MyExpo[] }).myExpos || [];
    const today = dayjs();

    // Enhanced expo calculations with proper slot management
    const exposWithMax = myExpos.map((expo) => {
        const totalSlots = expo.slotCount || 1;
        const capacityPerSlot = expo.capacityPerSlot || 20;
        const totalCapacity = totalSlots * capacityPerSlot;

        // Use slots data from backend if available, otherwise generate mock data
        const slots: Slot[] = expo.slots && expo.slots.length > 0
            ? expo.slots.map((slot: unknown) => {
                const slotData = slot as Record<string, unknown>;
                return {
                    id: slotData.id as number,
                    slot_number: slotData.slot_number as number,
                    max_products: slotData.max_products as number,
                    assigned_products: slotData.assigned_products as number,
                    assigned_expo_section_product: slotData.assigned_expo_section_product as number,
                    total_assigned: slotData.total_assigned as number,
                    current_products: slotData.current_products as number,
                    remaining_products: slotData.remaining_products as number,
                    products: (slotData.products as Product[]) || [],
                    utilization_percentage: slotData.utilization_percentage as number,
                    is_full: slotData.is_full as boolean
                };
            })
            : Array.from({ length: totalSlots }, (_, index) => {
                // Fallback to mock data if backend data not available
                const slotProducts = (expo.products || []).filter(p => Number(p.assigned_slot) === index + 1);
                const slotCurrentProducts = slotProducts.length;
                const slotRemainingProducts = Math.max(0, capacityPerSlot - slotCurrentProducts);
                return {
                    id: index + 1,
                    slot_number: index + 1,
                    max_products: capacityPerSlot,
                    assigned_products: slotCurrentProducts,
                    assigned_expo_section_product: slotCurrentProducts,
                    total_assigned: slotCurrentProducts,
                    current_products: slotCurrentProducts,
                    remaining_products: slotRemainingProducts,
                    products: slotProducts,
                    utilization_percentage: capacityPerSlot > 0 ? Math.round((slotCurrentProducts / capacityPerSlot) * 100) : 0,
                    is_full: slotRemainingProducts === 0
                };
            });

        // Calculate total current products from all slots (including section products)
        const currentProducts = slots.reduce((total, slot) => total + slot.current_products, 0);
        const remainingCapacity = Math.max(0, totalCapacity - currentProducts);

        // Calculate section-wise availability
        const sectionsWithAvailability = (expo.sections || []).map(section => {
            const sectionProducts = section.products_in_section || 0;
            const sectionCapacity = section.total_available_products || capacityPerSlot;
            const sectionRemaining = Math.max(0, sectionCapacity - sectionProducts);

            return {
                ...section,
                products_in_section: sectionProducts,
                total_available_products: sectionCapacity,
                remaining_products: sectionRemaining,
                utilization_percentage: sectionCapacity > 0 ? Math.round((sectionProducts / sectionCapacity) * 100) : 0,
                is_full: sectionRemaining === 0,
                products: (expo.products || []).filter(p => p.section_id === section.id)
            };
        });

        return {
            ...expo,
            maxProducts: totalCapacity,
            currentProducts,
            remainingCapacity,
            totalSlots,
            capacityPerSlot,
            utilization_percentage: totalCapacity > 0 ? Math.round((currentProducts / totalCapacity) * 100) : 0,
            is_full: remainingCapacity === 0,
            sections: sectionsWithAvailability,
            slots,
            slots_booked: totalSlots,
            total_slots_available: totalSlots // Mock data - would come from backend
        };
    });

    // Filter out expired expos
    const activeExpos = exposWithMax.filter((expo) => !expo.expired && dayjs(expo.end_date).isSameOrAfter(today, 'day'));

    const [selectedExpo, setSelectedExpo] = useState<MyExpo | null>(null);
    const [expandedExpo, setExpandedExpo] = useState<number | null>(null);
    const [manageProductsModalOpen, setManageProductsModalOpen] = useState(false);
    const [manageSectionsModalOpen, setManageSectionsModalOpen] = useState(false);
    const [selectedSlot, setSelectedSlot] = useState<Slot | null>(null);

    // Open Manage Products for a specific slot
    const openManageProducts = (expo: MyExpo, slot: Slot) => {
        setSelectedExpo(expo);
        setSelectedSlot(slot);
        setManageProductsModalOpen(true);
    };

    const closeManageProducts = () => {
        setManageProductsModalOpen(false);
        setSelectedExpo(null);
        setSelectedSlot(null);
    };

    // --- Manage Sections Logic ---
    const openManageSections = (expo: MyExpo, slot: Slot) => {
        setSelectedExpo(expo);
        setSelectedSlot(slot);
        setManageSectionsModalOpen(true);
    };

    const closeManageSections = () => {
        setManageSectionsModalOpen(false);
        setSelectedExpo(null);
        setSelectedSlot(null);
    };

    const toggleExpoExpansion = (expoId: number) => {
        setExpandedExpo(expandedExpo === expoId ? null : expoId);
    };

    return (
        <AppLayout>
            <Head title={t('expos.myExpos')} />
            <div className="max-w-full p-6">
                <h1 className="mb-6 text-2xl font-bold">{t('expos.myExpos')}</h1>
                <div className="space-y-8">
                    {activeExpos.map((expo: MyExpo) => (
                        <div key={expo.id} className="bg-white dark:bg-neutral-900 rounded-2xl border border-gray-200 dark:border-neutral-700 shadow-sm">
                            {/* Expo Header */}
                            <div className="p-6 border-b border-gray-200 dark:border-neutral-700">
                                <div className="flex items-center justify-between">
                                    <div>
                                        <h2 className="text-2xl font-bold text-gray-800 dark:text-white mb-2">{expo.title_en}</h2>
                                        <div className="flex items-center gap-4 text-sm text-gray-600 dark:text-gray-400">
                                            <div className="flex items-center gap-2">
                                                <Clock className="h-4 w-4" />
                                                <span>
                                                    {dayjs(expo.start_date).isValid() && dayjs(expo.end_date).isValid()
                                                        ? `${dayjs(expo.start_date).format('MMM D')} – ${dayjs(expo.end_date).format('MMM D')}`
                                                        : t('expos.noDate')}
                                                </span>
                                            </div>
                                            <div className="flex items-center gap-2">
                                                <Hourglass className="h-4 w-4" />
                                                <span className="font-medium">{expo.expired ? t('expos.expired') : expo.status === 'upcoming' ? t('expos.upcoming') : t('expos.live')}</span>
                                            </div>
                                        </div>
                                    </div>

                                </div>
                            </div>

                            {/* Slot & Product Overview */}
                            <div className="p-6 bg-gradient-to-r from-blue-50 to-indigo-50 dark:from-blue-900/20 dark:to-indigo-900/20">
                                <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-3 mb-4">
                                    <h3 className="text-lg font-semibold text-gray-800 dark:text-white flex items-center gap-2">
                                        <Package className="h-5 w-5" />
                                        {t('expos.slotProductOverview')}
                                    </h3>
                                    <Button
                                        variant="outline"
                                        onClick={() => toggleExpoExpansion(expo.id)}
                                        className="flex items-center gap-2 w-full sm:w-auto"
                                    >
                                        {expandedExpo === expo.id ? t('expos.collapse') : t('expos.viewDetails')}
                                        <Grid3X3 className="h-4 w-4" />
                                    </Button>
                                </div>
                                <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                                    {/* A. Total Slots Booked */}
                                    <div className="bg-white dark:bg-neutral-800 rounded-lg p-4 border border-blue-200 dark:border-blue-700">
                                        <div className="text-sm text-gray-600 dark:text-gray-400 mb-1">🔹 {t('expos.totalSlotsBooked')}</div>
                                        <div className="text-xl font-bold text-blue-600 dark:text-blue-400">
                                            {expo.slots_booked} of {expo.vendor_slot_capacity} {t('expos.booked')}
                                        </div>
                                        <div className="w-full bg-gray-200 rounded-full h-2 mt-2 dark:bg-gray-700">
                                            <div
                                                className="h-2 rounded-full bg-blue-500"
                                                style={{ width: `${Math.min(((expo.slots_booked || 0) / (expo.vendor_slot_capacity || 1)) * 100, 100)}%` }}
                                            ></div>
                                        </div>
                                    </div>

                                    {/* B. Total Products */}
                                    <div className="bg-white dark:bg-neutral-800 rounded-lg p-4 border border-green-200 dark:border-green-700">
                                        <div className="text-sm text-gray-600 dark:text-gray-400 mb-1">🔹 {t('expos.totalProductsAdded')}</div>
                                        <div className="text-xl font-bold text-green-600 dark:text-green-400">
                                            {expo.currentProducts} of {expo.maxProducts} {t('expos.allowed')}
                                        </div>
                                        <div className="w-full bg-gray-200 rounded-full h-2 mt-2 dark:bg-gray-700">
                                            <div
                                                className={`h-2 rounded-full ${expo.is_full ? 'bg-red-500' :
                                                    (expo.utilization_percentage || 0) > 80 ? 'bg-yellow-500' : 'bg-green-500'
                                                    }`}
                                                style={{ width: `${Math.min(expo.utilization_percentage || 0, 100)}%` }}
                                            ></div>
                                        </div>
                                    </div>

                                    {/* C. Remaining Products Allowed */}
                                    <div className="bg-white dark:bg-neutral-800 rounded-lg p-4 border border-orange-200 dark:border-orange-700">
                                        <div className="text-sm text-gray-600 dark:text-gray-400 mb-1">🔹 {t('expos.remainingProducts')}</div>
                                        <div className={`text-xl font-bold ${(expo.remainingCapacity || 0) === 0 ? 'text-red-600 dark:text-red-400' :
                                            (expo.remainingCapacity || 0) < 5 ? 'text-yellow-600 dark:text-yellow-400' :
                                                'text-orange-600 dark:text-orange-400'
                                            }`}>
                                            {expo.remainingCapacity} {t('expos.remainingLabel')}
                                        </div>
                                        {(expo.remainingCapacity || 0) === 0 && (
                                            <div className="flex items-center gap-1 mt-2 text-red-600 dark:text-red-400">
                                                <AlertTriangle className="h-4 w-4" />
                                                <span className="text-xs">{t('expos.capacityFull')}</span>
                                            </div>
                                        )}
                                    </div>
                                </div>
                            </div>

                            {/* Expanded Details */}
                            {expandedExpo === expo.id && (
                                <div className="p-6 space-y-6">
                                    {/*  Slot-wise Product Distribution */}
                                    <div>
                                        <h3 className="text-lg font-semibold text-gray-800 dark:text-white mb-4 flex items-center gap-2">
                                            <Grid3X3 className="h-5 w-5" />
                                            {t('expos.slotWiseDistribution')}
                                        </h3>
                                        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
                                            {expo.slots?.map((slot) => (
                                                <div key={slot.id} className="bg-gray-50 dark:bg-gray-800 rounded-lg p-4 border border-gray-200 dark:border-gray-700 overflow-hidden">
                                                    <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-2 mb-3">
                                                        <h4 className="font-semibold text-gray-800 dark:text-white">{t('expos.slot')} {slot.slot_number}</h4>
                                                        <span className={`text-xs px-2 py-1 rounded-full w-fit ${slot.is_full ? 'bg-red-100 text-red-700 dark:bg-red-900/20 dark:text-red-400' :
                                                            slot.utilization_percentage > 80 ? 'bg-yellow-100 text-yellow-700 dark:bg-yellow-900/20 dark:text-yellow-400' :
                                                                'bg-green-100 text-green-700 dark:bg-green-900/20 dark:text-green-400'
                                                            }`}>
                                                            {slot.utilization_percentage}% full
                                                        </span>
                                                    </div>

                                                    <div className="space-y-2 text-sm mb-4">
                                                        <div className="flex justify-between">
                                                            <span className="text-gray-600 dark:text-gray-400">{t('expos.maxProducts')}</span>
                                                            <span className="font-medium">{slot.max_products}</span>
                                                        </div>
                                                        <div className="flex justify-between">
                                                            <span className="text-gray-600 dark:text-gray-400">{t('expos.productsUsed')}</span>
                                                            <span className="font-medium text-blue-600 dark:text-blue-400">{slot.assigned_products} </span>
                                                        </div>
                                                        <div className="flex justify-between">
                                                            <span className="text-gray-600 dark:text-gray-400">Remaining:</span>
                                                            <span className={`font-medium ${slot.remaining_products === 0 ? 'text-red-600 dark:text-red-400' : 'text-green-600 dark:text-green-400'
                                                                }`}>
                                                                {slot.remaining_products}
                                                            </span>
                                                        </div>
                                                    </div>

                                                    <div className="w-full bg-gray-200 rounded-full h-2 mb-4 dark:bg-gray-700">
                                                        <div
                                                            className={`h-2 rounded-full transition-all ${slot.is_full ? 'bg-red-500' :
                                                                slot.utilization_percentage > 80 ? 'bg-yellow-500' :
                                                                    'bg-green-500'
                                                                }`}
                                                            style={{ width: `${Math.min(slot.utilization_percentage, 100)}%` }}
                                                        ></div>
                                                    </div>

                                                    <div className="flex flex-col gap-2 mb-3">
                                                        <Button variant="outline" onClick={() => openManageProducts(expo, slot)} className="flex items-center justify-center gap-2 w-full">
                                                            <Package className="h-4 w-4 flex-shrink-0" />
                                                            <span className="truncate">{t('expos.manageProducts')}</span>
                                                        </Button>
                                                        <Button variant="outline" onClick={() => openManageSections(expo, slot)} className="flex items-center justify-center gap-2 w-full">
                                                            <Settings className="h-4 w-4 flex-shrink-0" />
                                                            <span className="truncate">{t('expos.manageSections')}</span>
                                                        </Button>
                                                    </div>

                                                    {/* Product Grid/List */}
                                                    {slot.products.length > 0 && (
                                                        <div className="space-y-2">
                                                            <div className="text-xs text-gray-500 dark:text-gray-400">{t('expos.assignedProducts')}</div>
                                                            <div className="grid grid-cols-2 gap-2">
                                                                {slot.products.slice(0, 4).map((product) => (
                                                                    <div key={product.id} className="bg-white dark:bg-gray-700 rounded p-2 text-xs">
                                                                        <div className="font-medium text-gray-800 dark:text-white truncate">
                                                                            {product.name_en}
                                                                        </div>
                                                                    </div>
                                                                ))}
                                                                {slot.products.length > 4 && (
                                                                    <div className="bg-gray-100 dark:bg-gray-600 rounded p-2 text-xs text-center text-gray-600 dark:text-gray-300">
                                                                        +{slot.products.length - 4} more
                                                                    </div>
                                                                )}
                                                            </div>
                                                        </div>
                                                    )}
                                                </div>
                                            ))}
                                        </div>
                                    </div>
                                </div>
                            )}
                        </div>
                    ))}
                </div>
                {activeExpos.length === 0 && <div className="text-gray-500">{t('expos.noJoinedExpos')}</div>}

                {/* --- Manage Products Modal --- */}
                {selectedExpo && selectedSlot && (
                    <ManageProductsModal
                        isOpen={manageProductsModalOpen}
                        onClose={closeManageProducts}
                        expoId={selectedExpo.id}
                        expoName={selectedExpo.title_en}
                        maxProducts={selectedSlot.max_products}
                        slotId={selectedSlot.id || selectedSlot.slot_number}
                    />
                )}

                {/* --- Manage Sections Modal --- */}
                {selectedExpo && selectedSlot && (
                    <ManageSectionsModal
                        isOpen={manageSectionsModalOpen}
                        onClose={closeManageSections}
                        expoId={selectedExpo.id}
                        expoName={selectedExpo.title_en}
                        categories={selectedExpo.categories || []}
                        slotId={selectedSlot.id || selectedSlot.slot_number}
                    />
                )}
            </div>
        </AppLayout>
    );
}
