/* eslint-disable @typescript-eslint/no-explicit-any */
import { Button } from '@/components/ui/button';
import dayjs from 'dayjs';
import { CalendarDays, CheckCircle, Clock, CreditCard, Hourglass, PlusCircle, Users, X, XCircle } from 'lucide-react';

interface ExpoDetailsData {
    id: number;
    vendor_slot_count: number;
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
}

interface ExpoDetailsModalProps {
    onClose: () => void;
    setShowJoinModal: () => void;
    expoDetailsData: ExpoDetailsData;
}

const ExpoDetailsModal: React.FC<ExpoDetailsModalProps> = ({ onClose, expoDetailsData, setShowJoinModal }) => {
    return (
        <div
            className="fixed inset-0 z-50 flex items-center justify-center bg-black/50 backdrop-blur-sm transition-opacity duration-300"
            onClick={onClose}
        >
            <div className="relative w-full max-w-2xl rounded-2xl bg-white p-6 shadow-xl dark:bg-neutral-900"
                 style={{ maxHeight: '80vh', overflowY: 'auto' }}
                 onClick={(e) => e.stopPropagation()}>
                <button
                    className="absolute top-4 right-4 rounded-full p-1 text-gray-500 transition-colors hover:bg-gray-100 hover:text-gray-700 dark:text-gray-400 dark:hover:bg-neutral-800 dark:hover:text-gray-200"
                    onClick={onClose}
                    aria-label="Close modal"
                >
                    <X className="h-6 w-6" />
                </button>
                <div className="mb-6">
                    <h2 className="text-2xl font-bold text-gray-900 dark:text-white">{expoDetailsData.title_en}</h2>
                    {/* Status Badge */}
                    <span
                        className={`
                            inline-block mt-2 rounded-full px-3 py-1 text-xs font-semibold
                            ${expoDetailsData.status === 'active'
                                ? 'bg-green-100 text-green-800 dark:bg-green-900/50 dark:text-green-200'
                                : expoDetailsData.status === 'upcoming'
                                    ? 'bg-yellow-100 text-yellow-800 dark:bg-yellow-900/50 dark:text-yellow-200'
                                    : 'bg-gray-200 text-gray-800 dark:bg-gray-700 dark:text-gray-200'}
                        `}
                    >
                        {expoDetailsData.status
                            ? expoDetailsData.status.charAt(0).toUpperCase() + expoDetailsData.status.slice(1)
                            : 'N/A'}
                    </span>
                    <p className="mt-2 text-gray-600 dark:text-gray-300" dangerouslySetInnerHTML={{ __html: expoDetailsData.description_en }} />
                </div>
                <div className="space-y-6">
                    <div className="grid grid-cols-1 gap-4 md:grid-cols-2">
                        <div className="rounded-lg border border-gray-200 p-4 dark:border-neutral-700">
                            <div className="flex items-center gap-3">
                                <Clock className="h-5 w-5 text-gray-500 dark:text-gray-400" />
                                <h3 className="text-lg font-semibold text-gray-800 dark:text-white">Start Date</h3>
                            </div>
                            <p className="mt-2 text-gray-700 dark:text-gray-300">
                                {expoDetailsData.start_date ? dayjs(expoDetailsData.start_date).format('YYYY-MM-DD hh:mm A') : 'N/A'}
                            </p>
                        </div>
                        <div className="rounded-lg border border-gray-200 p-4 dark:border-neutral-700">
                            <div className="flex items-center gap-3">
                                <CalendarDays className="h-5 w-5 text-gray-500 dark:text-gray-400" />
                                <h3 className="text-lg font-semibold text-gray-800 dark:text-white">End Date</h3>
                            </div>
                            <p className="mt-2 text-gray-700 dark:text-gray-300">
                                {expoDetailsData.end_date ? dayjs(expoDetailsData.end_date).format('YYYY-MM-DD hh:mm A') : 'N/A'}
                            </p>
                        </div>
                    </div>
                    <div className="rounded-lg border border-gray-200 p-4 dark:border-neutral-700">
                        <div className="flex items-center gap-3">
                            <Users className="h-5 w-5 text-gray-500 dark:text-gray-400" />
                            <h3 className="text-lg font-semibold text-gray-800 dark:text-white">Slot Availability</h3>
                        </div>
                        <div className="mt-4 flex items-center justify-between">
                            <div className="space-y-1">
                                <p className="text-sm text-gray-500 dark:text-gray-400">Booked / Total Slots</p>
                                <p className="text-lg font-medium text-gray-800 dark:text-white">
                                    {expoDetailsData.filled_slots} / {expoDetailsData.total_slots}
                                </p>
                            </div>
                            <div className="rounded-full bg-green-100 px-4 py-2 text-sm font-medium text-green-800 dark:bg-green-900/50 dark:text-green-200">
                                {expoDetailsData.available_slots} slots available
                            </div>
                        </div>
                    </div>
                    {expoDetailsData.slot_fee &&
                        (() => {
                            let slotFeeData: any;
                            try {
                                slotFeeData = JSON.parse(expoDetailsData.slot_fee);
                            } catch {
                                return <div className="text-gray-500 dark:text-gray-400">Invalid pricing data</div>;
                            }
                            const isArray = Array.isArray(slotFeeData);
                            return (
                                <div className="rounded-lg border border-gray-200 p-4 dark:border-neutral-700">
                                    <div className="flex items-center gap-3">
                                        <CreditCard className="h-5 w-5 text-gray-500 dark:text-gray-400" />
                                        <h3 className="text-lg font-semibold text-gray-800 dark:text-white">Slot Fees</h3>
                                    </div>
                                    <div className="mt-4 grid grid-cols-1 gap-3 md:grid-cols-2">
                                        {isArray
                                            ? slotFeeData.map((item: any, idx: number) => (
                                                <div
                                                    key={idx}
                                                    className="flex items-center justify-between rounded-lg bg-gray-50 p-3 dark:bg-neutral-800"
                                                >
                                                    <span className="font-medium text-gray-700 capitalize dark:text-gray-300">
                                                        Slot {item.slot ?? `${item.from}-${item.to}`}
                                                    </span>
                                                    <span className="font-bold text-blue-600 dark:text-blue-400">
                                                        KWD {Number(item.price).toFixed(2)}
                                                    </span>
                                                </div>
                                            ))
                                            : Object.entries(slotFeeData).map(([type, priceData]: any) => (
                                                <div
                                                    key={type}
                                                    className="flex items-center justify-between rounded-lg bg-gray-50 p-3 dark:bg-neutral-800"
                                                >
                                                    <span className="font-medium text-gray-700 capitalize dark:text-gray-300">{type} slot</span>
                                                    <span className="font-bold text-blue-600 dark:text-blue-400">
                                                        KWD {Number(priceData.price).toFixed(2)}
                                                    </span>
                                                </div>
                                            ))}
                                    </div>
                                </div>
                            );
                        })()}
                    <div className="flex flex-col items-center gap-4 sm:flex-row sm:justify-between">
                        <div className="flex items-center gap-2 rounded-full bg-blue-100 px-4 py-2 text-blue-800 dark:bg-blue-900/50 dark:text-blue-200">
                            <Hourglass className="h-4 w-4" />
                            <span className="font-medium">Time remaining: {expoDetailsData.remaining_time}</span>
                        </div>
                        {(expoDetailsData.vendor_slot_count ?? 0) >= expoDetailsData.total_slots ? (
                            <Button
                                onClick={() => {
                                    window.location.href = `/vendor/expos/${expoDetailsData.id}`;
                                }}
                                className="min-w-[120px] sm:w-auto text-base px-3 py-2 transition-colors bg-green-700 hover:bg-green-800 text-white"
                            >
                                <span className="flex items-center gap-2">
                                    <CheckCircle className="h-5 w-5" />
                                    Go to Expo
                                </span>
                            </Button>
                        ) : expoDetailsData.available_slots === 0 ? (
                            <Button
                                disabled
                                className="min-w-[120px] sm:w-auto text-base px-3 py-2 transition-colors bg-red-600 text-white"
                            >
                                <span className="flex items-center gap-2">
                                    <XCircle className="h-5 w-5" />
                                    Expo Full
                                </span>
                            </Button>
                        ) : (
                            <Button
                                onClick={() => {
                                    window.location.href = `/vendor/expos/${expoDetailsData.id}`;
                                }}
                                className="min-w-[120px] sm:w-auto text-base px-3 py-2 transition-colors bg-blue-700 hover:bg-blue-800 text-white"
                            >
                                <span className="flex items-center gap-2">
                                    <PlusCircle className="h-5 w-5" />
                                    Join Expo Now
                                </span>
                            </Button>
                        )}
                    </div>
                </div>
            </div>
        </div>
    );
};

export default ExpoDetailsModal;
