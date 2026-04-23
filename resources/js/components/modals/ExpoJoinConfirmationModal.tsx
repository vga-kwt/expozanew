/* eslint-disable @typescript-eslint/no-unused-vars */
/* eslint-disable @typescript-eslint/no-explicit-any */
import { Button } from '@/components/ui/button';
import { router } from '@inertiajs/react';
import { AlertCircle, CheckCircle, CreditCard, X } from 'lucide-react';
import { useState } from 'react';

interface ExpoDetailsData {
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
}

interface ExpoJoinConfirmationModalProps {
    onClose: () => void;
    setShowJoinModal: () => void;
    expoDetailsData: ExpoDetailsData;
}

const ExpoJoinConfirmationModal: React.FC<ExpoJoinConfirmationModalProps> = ({ onClose, expoDetailsData, setShowJoinModal }) => {
    const [joinMessage, setJoinMessage] = useState<string | null>(null);
    const [errorMessage, setErrorMessage] = useState<string | null>(null);
    const [selectedSlot, setSelectedSlot] = useState<number | null>(null);
    const [selectedSlots, setSelectedSlots] = useState<number[]>([]);

    let isMultiSelect = false;

    try {
        const parsedFee = JSON.parse(expoDetailsData?.slot_fee ?? '[]');
        isMultiSelect = Array.isArray(parsedFee) && parsedFee.length > 1;
    } catch (error) {
        isMultiSelect = false;
    }

    const handleSlotClick = (slotNumber: number) => {
        if (isMultiSelect) {
            setSelectedSlots((prev) => (prev.includes(slotNumber) ? prev.filter((slot) => slot !== slotNumber) : [...prev, slotNumber]));
        } else {
            setSelectedSlot(slotNumber);
        }
    };

    const handleJoinExpo = () => {
        if (!expoDetailsData && selectedSlot === null && selectedSlots.length === 0) return;

        setJoinMessage('');
        setErrorMessage('');
        router.post(
            `/vendor/expos/${expoDetailsData.id}/join`,
            { slot: isMultiSelect ? selectedSlots : selectedSlot },
            {
                onSuccess: () => {
                    setJoinMessage('Successfully joined the expo!');
                    setErrorMessage('');
                    setTimeout(() => {
                        setShowJoinModal();
                        setSelectedSlot(null);
                        setSelectedSlots([]);
                        setJoinMessage('');
                    }, 1500);
                },
                onError: (errors: any) => {
                    setErrorMessage(
                        errors && typeof errors === 'object' && Object.values(errors).length > 0
                            ? (Object.values(errors)[0] as string)
                            : 'Failed to join expo. Please try again.',
                    );
                },
            },
        );
    };
    return (
        <div
            className="fixed inset-0 z-50 flex items-center justify-center bg-black/50 backdrop-blur-sm transition-opacity duration-300"
            onClick={onClose}
        >
            <div className="relative w-full max-w-lg rounded-2xl bg-white p-6 shadow-xl dark:bg-neutral-900" onClick={(e) => e.stopPropagation()}>
                <button
                    className="absolute top-4 right-4 rounded-full p-1 text-gray-500 transition-colors hover:bg-gray-100 hover:text-gray-700 dark:text-gray-400 dark:hover:bg-neutral-800 dark:hover:text-gray-200"
                    onClick={onClose}
                    aria-label="Close modal"
                >
                    <X className="h-6 w-6" />
                </button>
                <div className="mb-6">
                    <h2 className="text-2xl font-bold text-gray-900 dark:text-white">
                        Join <span className="text-blue-600 dark:text-blue-400">{expoDetailsData.title_en}</span>
                    </h2>
                </div>
                <div className="mb-6 rounded-lg border border-gray-200 p-4 dark:border-neutral-700">
                    <h3 className="mb-3 text-lg font-semibold text-gray-800 dark:text-white">Slot Pricing</h3>
                    {expoDetailsData.slot_fee ? (
                        <div className="grid grid-cols-1 gap-3 md:grid-cols-2">
                            {(() => {
                                const parsed = JSON.parse(expoDetailsData.slot_fee);
                                if (!Array.isArray(parsed)) return null;

                                return parsed.map((fee: any, index: number) => {
                                    const isRange = 'from' in fee && 'to' in fee;
                                    const isSlot = 'slot' in fee;

                                    return (
                                        <div
                                            key={index}
                                            className={`flex items-center justify-between rounded-lg p-3 ${
                                                isSlot ? 'bg-gray-50 dark:bg-neutral-800' : 'bg-blue-50 dark:bg-blue-900/20'
                                            }`}
                                        >
                                            <span className="font-medium text-gray-700 capitalize dark:text-gray-300">
                                                {isRange ? `Slot ${fee.from} to ${fee.to}` : isSlot ? `Slot ${fee.slot}` : 'Unknown Slot'}
                                            </span>
                                            <span
                                                className={`font-bold ${
                                                    isSlot ? 'text-gray-800 dark:text-white' : 'text-blue-600 dark:text-blue-400'
                                                }`}
                                            >
                                                KWD {fee.price}
                                            </span>
                                        </div>
                                    );
                                });
                            })()}
                        </div>
                    ) : (
                        <div className="text-gray-500 dark:text-gray-400">No pricing information available</div>
                    )}
                </div>
                <div className="mb-6">
                    <h3 className="mb-3 text-lg font-semibold text-gray-800 dark:text-white">Select Your Slot</h3>
                    <div className="grid grid-cols-5 gap-2">
                        {Array.from({ length: expoDetailsData.total_slots }, (_, i) => {
                            const slotNumber = i + 1;
                            const isBooked = slotNumber <= expoDetailsData.filled_slots;
                            const isSelected = isMultiSelect ? selectedSlots.includes(slotNumber) : selectedSlot === slotNumber;

                            return (
                                <button
                                    key={slotNumber}
                                    disabled={isBooked}
                                    onClick={() => {
                                        if (!isBooked) handleSlotClick(slotNumber);
                                    }}
                                    className={`flex h-10 items-center justify-center rounded-lg border text-sm font-medium transition-all ${
                                        isBooked
                                            ? 'cursor-not-allowed border-gray-200 bg-gray-100 text-gray-400 dark:border-neutral-700 dark:bg-neutral-800 dark:text-neutral-500'
                                            : isSelected
                                              ? 'border-blue-500 bg-blue-50 text-blue-600 ring-2 ring-blue-500/50 dark:border-blue-400 dark:bg-blue-900/30 dark:text-blue-200'
                                              : 'border-gray-200 bg-white text-gray-700 hover:border-blue-300 hover:bg-blue-50 hover:text-blue-600 dark:border-neutral-700 dark:bg-neutral-800 dark:text-gray-300 dark:hover:border-blue-500 dark:hover:bg-blue-900/20'
                                    }`}
                                >
                                    {slotNumber}
                                </button>
                            );
                        })}
                    </div>

                    <div className="mt-3 text-sm font-medium text-blue-600 dark:text-blue-400">
                        {isMultiSelect && selectedSlots.length > 0
                            ? `Selected: ${selectedSlots.join(', ')}`
                            : selectedSlot
                              ? `Selected: Slot ${selectedSlot}`
                              : 'No slot selected'}
                    </div>
                </div>
                <Button
                    size="lg"
                    className="w-full py-6 text-lg font-medium"
                    disabled={isMultiSelect ? selectedSlots.length === 0 : selectedSlot === null}
                    onClick={handleJoinExpo}
                >
                    <CreditCard className="mr-2 h-5 w-5" />
                    Confirm & Pay
                </Button>

                {joinMessage && (
                    <div className="mt-4 flex items-center rounded-lg bg-green-100 p-3 text-green-800 dark:bg-green-900/30 dark:text-green-200">
                        <CheckCircle className="mr-2 h-5 w-5" />
                        {joinMessage}
                    </div>
                )}
                {errorMessage && (
                    <div className="mt-4 flex items-center rounded-lg bg-red-100 p-3 text-red-800 dark:bg-red-900/30 dark:text-red-200">
                        <AlertCircle className="mr-2 h-5 w-5" />
                        {errorMessage}
                    </div>
                )}
            </div>
        </div>
    );
};

export default ExpoJoinConfirmationModal;
