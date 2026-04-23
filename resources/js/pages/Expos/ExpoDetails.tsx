import React, { useState } from 'react';
import { useLanguage } from '@/components/language-context';
import { router, usePage } from '@inertiajs/react';
import { Head } from '@inertiajs/react';
import AppLayout from '@/layouts/app-layout';
import { Button } from '@/components/ui/button';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Badge } from '@/components/ui/badge';
import { Alert, AlertDescription } from '@/components/ui/alert';
import { Calendar, Clock, Users, CreditCard, AlertCircle, CheckCircle } from 'lucide-react';
import PaymentModal from '@/components/modals/PaymentModal';
import SlotSelector from '@/components/SlotSelector';
import { toast } from 'react-hot-toast';

interface Category {
  id: number;
  name_en: string;
  name_ar: string;
}

interface Expo {
  id: number;
  title_en: string;
  title_ar: string;
  description_en: string;
  description_ar: string;
  start_date: string;
  end_date: string;
  total_slots: number;
  filled_slots: number;
  available_slots: number;
  remaining_time: string;
  categories: Category[];
  slot_pricing?: string;
  availableSlotlist: number[];
}

interface BookingData {
  expo_id: number;
  booking_id: number;
  total_amount: number;
  booked_slots: number[];
  total_slots_booked: number;
  message: string;
}

export default function ExpoDetails() {
  const { t } = useLanguage();
  const expo = (usePage().props as any).expo as Expo;
  const [availableSlots] = useState<number[]>(expo.availableSlotlist || []);
  const [selectedSlots, setSelectedSlots] = useState<number[]>([]);
  const [showPaymentModal, setShowPaymentModal] = useState(false);
  const [bookingData, setBookingData] = useState<BookingData | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [success, setSuccess] = useState<string | null>(null);

  // Handle slot_pricing whether it comes as string or array
  const slotPrices = (() => {
    if (!expo.slot_pricing) return [];
    if (Array.isArray(expo.slot_pricing)) return expo.slot_pricing;
    try {
      return JSON.parse(expo.slot_pricing);
    } catch {
      return [];
    }
  })();
  const pricePerSlot = 0; // No default price - only show slots with explicit pricing

  const getSlotPrice = (slot: number): number => {
    const found = slotPrices.find((s: any) => {
      if ('slot' in s) return Number(s.slot) === Number(slot);
      if ('from' in s && 'to' in s) return Number(slot) >= Number(s.from) && Number(slot) <= Number(s.to);
      return false;
    });
    return found ? Number(found.price) : 0; // Return 0 if no pricing found
  };

  const handleSlotToggle = (slot: number) => {
    setSelectedSlots((prev) =>
      prev.includes(slot)
        ? prev.filter((s) => s !== slot)
        : [...prev, slot]
    );
    setError(null);
  };

  const handleBookSlots = () => {
    if (selectedSlots.length === 0) {
      setError(t('expos.pleaseSelectAtLeastOneSlot'));
      return;
    }

    const totalAmount = selectedSlots.reduce((sum, slot) => sum + getSlotPrice(slot), 0);
    setBookingData({
      expo_id: expo.id,
      booking_id: Date.now(),
      total_amount: totalAmount,
      booked_slots: selectedSlots,
      total_slots_booked: selectedSlots.length,
      message: t('expos.previewPayment'),
    });

    setShowPaymentModal(true);
  };

  const formatDate = (dateString: string) => {
    return new Date(dateString).toLocaleString('en-US', {
      year: 'numeric',
      month: 'short',
      day: 'numeric',
      hour: '2-digit',
      minute: '2-digit',
    });
  };

  return (
    <AppLayout>
      <Head title={`${expo.title_en} - ${t('expos.expoDetails')}`} />

      <div className="p-6 max-w-6xl mx-auto">
        <div className="flex items-center justify-between mb-6">
          <div>
            <h1 className="text-3xl font-bold">{expo.title_en}</h1>
            <p
              className="text-gray-600 dark:text-gray-300 mt-2"
              dangerouslySetInnerHTML={{ __html: expo.description_en }}
            />
          </div>
          <Badge variant={expo.available_slots > 0 ? 'default' : 'destructive'}>
            {expo.available_slots > 0 ? `${expo.available_slots} ${t('expos.slotsAvailable')}` : t('expos.fullyBooked')}
          </Badge>
        </div>

        {error && (
          <Alert className="mb-6 border-red-200 bg-red-50 dark:bg-red-900/20 dark:border-red-800">
            <AlertCircle className="h-4 w-4 text-red-600" />
            <AlertDescription>{error}</AlertDescription>
          </Alert>
        )}

        {success && (
          <Alert className="mb-6 border-green-200 bg-green-50 dark:bg-green-900/20 dark:border-green-800">
            <CheckCircle className="h-4 w-4 text-green-600" />
            <AlertDescription>{success}</AlertDescription>
          </Alert>
        )}

        <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
          <Card>
            <CardHeader>
              <CardTitle className="flex items-center gap-2 text-blue-600">
                <Calendar className="h-4 w-4" />
                {t('expos.eventSchedule')}
              </CardTitle>
            </CardHeader>
            <CardContent className="text-sm">
              <div className="flex justify-between">
                <span>{t('expos.start')}</span>
                <span className="font-medium">{formatDate(expo.start_date)}</span>
              </div>
              <div className="flex justify-between">
                <span>{t('expos.end')}</span>
                <span className="font-medium">{formatDate(expo.end_date)}</span>
              </div>
            </CardContent>
          </Card>

          <Card>
            <CardHeader>
              <CardTitle className="flex items-center gap-2 text-green-600">
                <Users className="h-4 w-4" />
                {t('expos.slotAvailability')}
              </CardTitle>
            </CardHeader>
            <CardContent className="text-sm">
              <div className="flex justify-between">
                <span>{t('expos.totalSlotsLabel')}</span>
                <span className="font-medium">{expo.total_slots}</span>
              </div>
              <div className="flex justify-between">
                <span>{t('expos.filled')}</span>
                <span className="font-medium text-red-600">{expo.filled_slots}</span>
              </div>
              <div className="flex justify-between">
                <span>{t('expos.availableLabel')}</span>
                <span className="font-medium text-green-600">{expo.available_slots}</span>
              </div>
            </CardContent>
          </Card>

          <Card>
            <CardHeader>
              <CardTitle className="flex items-center gap-2 text-orange-600">
                <Clock className="h-4 w-4" />
                {t('expos.timeRemaining')}
              </CardTitle>
            </CardHeader>
            <CardContent className="text-sm text-orange-600 font-medium">
              {expo.remaining_time}
            </CardContent>
          </Card>
        </div>

        <div className="rounded-lg border border-gray-200 p-4 dark:border-neutral-700 mt-6">
          <div className="flex items-center gap-3">
            <CreditCard className="h-5 w-5 text-gray-500 dark:text-gray-400" />
            <h3 className="text-lg font-semibold text-gray-800 dark:text-white">{t('expos.slotFees')}</h3>
          </div>
          <div className="mt-4 grid grid-cols-1 gap-3 md:grid-cols-2">
            {Array.isArray(slotPrices)
              ? slotPrices.map((item: any, idx: number) => (
                <div
                  key={idx}
                  className="flex items-center justify-between rounded-lg bg-gray-50 p-3 dark:bg-neutral-800"
                >
                  <span className="font-medium text-gray-700 capitalize dark:text-gray-300">
                    {t('expos.slot')} {item.slot ?? `${item.from}-${item.to}`}
                  </span>
                  <span className="font-bold text-blue-600 dark:text-blue-400">
                    KWD {Number(item.price).toFixed(2)}
                  </span>
                </div>
              ))
              : Object.entries(slotPrices).map(([type, priceData]: any) => (
                <div
                  key={type}
                  className="flex items-center justify-between rounded-lg bg-gray-50 p-3 dark:bg-neutral-800"
                >
                  <span className="font-medium text-gray-700 capitalize dark:text-gray-300">{type} {t('expos.slot')}</span>
                  <span className="font-bold text-blue-600 dark:text-blue-400">
                    KWD {Number(priceData.price).toFixed(2)}
                  </span>
                </div>
              ))}
          </div>
        </div>

        {/* SLOT SELECTOR */}
        <SlotSelector
          availableSlots={availableSlots.filter(slot => {
            // Only show slots that have explicit pricing
            return slotPrices.some((s: any) => {
              if ('slot' in s) return Number(s.slot) === Number(slot);
              if ('from' in s && 'to' in s) return Number(slot) >= Number(s.from) && Number(slot) <= Number(s.to);
              return false;
            });
          })}
          selectedSlots={selectedSlots}
          onSlotToggle={handleSlotToggle}
          pricePerSlot={pricePerSlot}
          slotPrices={slotPrices}
          maxSlots={expo.available_slots}
        />

        {/* BOOKING BUTTON */}
        <Card className="mt-6">
          <CardHeader>
            <CardTitle className="flex items-center gap-2">
              <CreditCard className="h-5 w-5" />
              {t('expos.completeBooking')}
            </CardTitle>
          </CardHeader>
          <CardContent>
            <Button onClick={handleBookSlots} className="w-full" size="lg">
              {t('expos.bookSelectedSlots')}
            </Button>
            <PaymentModal
              isOpen={showPaymentModal}
              onClose={() => setShowPaymentModal(false)}
              bookingData={bookingData}
              expoName={expo.title_en}
              onVendorNameRequired={(msg) => {
                toast.error(msg);
                router.visit('/vendor/profile');
              }}
            />
          </CardContent>
        </Card>

        {/* CATEGORIES */}
        {expo.categories?.length > 0 && (
          <Card className="mt-6">
            <CardHeader>
              <CardTitle>{t('expos.expoCategories')}</CardTitle>
            </CardHeader>
            <CardContent className="flex flex-wrap gap-2">
              {expo.categories.map((category: Category) => (
                <Badge key={category.id} variant="outline">
                  {category.name_en}
                </Badge>
              ))}
            </CardContent>
          </Card>
        )}
      </div>
    </AppLayout>
  );
}
