/* eslint-disable @typescript-eslint/no-explicit-any */
import { useLanguage } from '@/components/language-context';
import ExpoDetailsModal from '@/components/modals/ExpoDetailsModal';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { StatusFilter } from '@/components/ui/StatusFilter';
import AppLayout from '@/layouts/app-layout';
import { Head, usePage } from '@inertiajs/react';
import dayjs from 'dayjs';
import isSameOrAfter from 'dayjs/plugin/isSameOrAfter';
import isSameOrBefore from 'dayjs/plugin/isSameOrBefore';
import { CalendarDays, CheckCircle, Clock, Hourglass, PlusCircle, Users, XCircle } from 'lucide-react';
import { useState } from 'react';

dayjs.extend(isSameOrAfter);
dayjs.extend(isSameOrBefore);

interface Expo {
    id: number;
    title_en: string;
    description_en: string;
    start_date: string;
    end_date: string;
    total_slots: number;
    filled_slots: number;
    available_slots: number;
    remaining_time: string;
    slot_fee?: string;
    already_joined?: boolean;
    status: string;
    vendor_slot_count?: number; // Added for new logic
}

export default function VendorExpoListPage() {
    const { t } = useLanguage();
    const expos = (usePage().props as any).expos || [];
    const [selectedExpo, setSelectedExpo] = useState<Expo | null>(null);
    const [showDetailsModal, setShowDetailsModal] = useState(false);
    const [search, setSearch] = useState<string>('');
    const [status, setStatus] = useState<string>('all');
    const [fromDate, setFromDate] = useState<string>('');
    const [toDate, setToDate] = useState<string>('');

    // Filter expos by status
    const filteredExpos = expos.filter((expo: Expo) => {
        const isStatus = status === 'all' || expo.status === status;
        const isSearch = !search || expo.title_en.toLowerCase().includes(search.toLowerCase());

        const expoStartDate = dayjs(expo.start_date);
        const from = fromDate ? dayjs(fromDate).startOf('day') : null;
        const to = toDate ? dayjs(toDate).endOf('day') : null;
        const isWithinDateRange = (!from || expoStartDate.isSameOrAfter(from)) && (!to || expoStartDate.isSameOrBefore(to));

        return isSearch && isStatus && isWithinDateRange;
    });

    const handleViewDetails = (expo: Expo) => {
        setSelectedExpo(expo);
        setShowDetailsModal(true);
    };

    return (
        <AppLayout>
            <Head title={t('expos.vendorExpos')} />
            <div className="max-w-full p-6">
                <h1 className="mb-6 text-2xl font-bold">{t('expos.liveAndUpcoming')}</h1>
                <div className="mb-4 flex flex-col justify-end gap-2 sm:flex-row sm:items-center">
                    <input
                        type="text"
                        className="rounded border px-2 py-1"
                        value={search ?? ''}
                        onChange={(e) => setSearch(e.target.value)}
                        placeholder={t('expos.searchByName')}
                    />
                    <StatusFilter
                        value={status}
                        onChange={(v) => setStatus(v)}
                        statusOptions={[
                            { value: 'all', label: t('expos.allStatuses') },
                            { value: 'upcoming', label: t('expos.upcoming') },
                            { value: 'active', label: t('expos.active') },
                            { value: 'inactive', label: t('expos.inactive') },
                            { value: 'suspended', label: t('expos.suspended') },
                            { value: 'expired', label: t('expos.expired') },
                        ]}
                        placeholder={t('expos.filterByStatus')}
                        className="w-40"
                    />
                    <Input type="date" value={fromDate} onChange={(e) => setFromDate(e.target.value)} className="w-40" />
                    <Input type="date" value={toDate} min={fromDate || undefined} onChange={(e) => setToDate(e.target.value)} className="w-40" />
                    {(search || status !== 'all' || fromDate || toDate) && (
                        <Button
                            variant="outline"
                            onClick={() => {
                                setSearch('');
                                setStatus('all');
                                setFromDate('');
                                setToDate('');
                            }}
                            className="w-24"
                        >
                            {t('expos.clear')}
                        </Button>
                    )}
                </div>
                <div className="mt-5 grid grid-cols-1 gap-6 md:grid-cols-2 xl:grid-cols-3">
                    {filteredExpos.map((expo: Expo) => (
                        <div
                            key={expo.id}
                            className="group relative flex flex-col gap-4 overflow-hidden rounded-2xl border border-gray-200 bg-white p-5 shadow-sm transition-all hover:shadow-lg dark:border-neutral-700 dark:bg-neutral-900"
                        >
                            <div className="space-y-2">
                                <h2 className="text-xl font-bold text-gray-800 dark:text-white">{expo.title_en}</h2>
                                <p
                                    className="line-clamp-3 text-sm text-gray-600 dark:text-neutral-300"
                                    dangerouslySetInnerHTML={{ __html: expo.description_en }}
                                />
                            </div>
                            <div className="flex-1 space-y-3">
                                <div className="flex items-start gap-3 text-sm">
                                    <div className="mt-0.5 flex-shrink-0">
                                        <Clock className="h-4 w-4 text-gray-500 dark:text-neutral-400" />
                                    </div>
                                    <div>
                                        <span className="font-medium text-gray-700 dark:text-gray-300">{t('expos.start')}</span>{' '}
                                        <span className="text-gray-600 dark:text-neutral-300">
                                            {expo.start_date ? dayjs(expo.start_date).format('YYYY-MM-DD hh:mm A') : 'N/A'}
                                        </span>
                                    </div>
                                </div>
                                <div className="flex items-start gap-3 text-sm">
                                    <div className="mt-0.5 flex-shrink-0">
                                        <CalendarDays className="h-4 w-4 text-gray-500 dark:text-neutral-400" />
                                    </div>
                                    <div>
                                        <span className="font-medium text-gray-700 dark:text-gray-300">{t('expos.end')}</span>{' '}
                                        <span className="text-gray-600 dark:text-neutral-300">
                                            {expo.end_date ? dayjs(expo.end_date).format('YYYY-MM-DD hh:mm A') : 'N/A'}
                                        </span>
                                    </div>
                                </div>
                                <div className="flex items-start gap-3 text-sm">
                                    <div className="mt-0.5 flex-shrink-0">
                                        <Users className="h-4 w-4 text-gray-500 dark:text-neutral-400" />
                                    </div>
                                    <div className="flex items-center gap-1">
                                        <span className="font-medium text-gray-700 dark:text-gray-300">{t('expos.slots')}</span>
                                        <span className="text-gray-600 dark:text-neutral-300">
                                            {expo.filled_slots}/{expo.total_slots}
                                        </span>
                                        <span className="ml-1 rounded-full bg-green-100 px-2 py-0.5 text-xs font-medium text-green-800 dark:bg-green-900/50 dark:text-green-200">
                                            {expo.available_slots} {t('expos.available')}
                                        </span>
                                    </div>
                                </div>
                                <div className="flex items-start gap-3 text-sm">
                                    <div className="mt-0.5 flex-shrink-0">
                                        <Hourglass className="h-4 w-4 text-blue-500 dark:text-blue-400" />
                                    </div>
                                    <div>
                                        <span className="font-medium text-blue-600 dark:text-blue-400">{t('expos.remaining')}</span>{' '}
                                        <span className="text-blue-600 dark:text-blue-400">{expo.remaining_time}</span>
                                    </div>
                                </div>

                            </div>
                            <div className="flex flex-wrap items-center gap-2 pt-2">
                                <Button
                                    variant="outline"
                                    onClick={() => handleViewDetails(expo)}
                                    className="flex-1 hover:bg-gray-100 dark:hover:bg-neutral-800"
                                >
                                    {t('expos.viewDetails')}
                                </Button>
                                <Button
                                    disabled={(expo.vendor_slot_count ?? 0) >= expo.total_slots || expo.available_slots === 0}
                                    onClick={() => {
                                        window.location.href = `/vendor/expos/${expo.id}`;
                                    }}
                                    className="flex-1"
                                >
                                    {(expo.vendor_slot_count ?? 0) >= expo.total_slots ? (
                                        <span className="flex items-center gap-1.5">
                                            <CheckCircle className="h-4 w-4" />
                                            {t('expos.alreadyJoined')}
                                        </span>
                                    ) : expo.available_slots === 0 ? (
                                        <span className="flex items-center gap-1.5">
                                            <XCircle className="h-4 w-4" />
                                            {t('expos.full')}
                                        </span>
                                    ) : (
                                        <span className="flex items-center gap-1.5">
                                            <PlusCircle className="h-4 w-4" />
                                            {t('expos.bookSlots')}
                                        </span>
                                    )}
                                </Button>
                            </div>
                        </div>
                    ))}
                </div>
                {filteredExpos.length === 0 && <div className="text-gray-500">{t('expos.noExposAvailable')}</div>}
            </div>
            {selectedExpo && showDetailsModal && (
                <ExpoDetailsModal
                    expoDetailsData={selectedExpo}
                    onClose={() => setShowDetailsModal(false)}
                    setShowJoinModal={() => { }}
                />
            )}
        </AppLayout>
    );
}
