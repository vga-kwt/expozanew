import { Checkbox } from '@/components/ui/checkbox';
import { Badge } from '@/components/ui/badge';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Loader2, Grid3X3, AlertCircle } from 'lucide-react';
import { Alert, AlertDescription } from '@/components/ui/alert';
import { useLanguage } from '@/components/language-context';
// import { Slot } from '@radix-ui/react-slot';

interface SlotSelectorProps {
  availableSlots: number[];
  selectedSlots: number[];
  onSlotToggle: (slot: number) => void;
  isLoading?: boolean;
  maxSlots?: number;
  pricePerSlot?: number;
  slotPrices?: { slot?: number; from?: number; to?: number; price: number; original?: number }[];
  className?: string;
}


export default function SlotSelector({
  availableSlots,
  selectedSlots,
  onSlotToggle,
  isLoading = false,
  maxSlots,
  pricePerSlot = 0,
  slotPrices = [],
  className = '',
}: SlotSelectorProps) {
  const { t } = useLanguage();
  // const formatAmount = (amount: number) => {
  //   return new Intl.NumberFormat('en-KW', {
  //     style: 'currency',
  //     currency: 'KWD',
  //     minimumFractionDigits: 3,
  //   }).format(amount);
  // };

  const calculateTotalPrice = () => {
    return selectedSlots.reduce((sum, slot) => sum + getSlotPrice(slot), 0);

  };

  // Helper: Calculate total original price (without discount)
  const calculateOriginalTotal = () => {
    return selectedSlots.reduce((sum, slot) => {
      const found = slotPrices.find((s) => {
        if (s.slot !== undefined) return Number(s.slot) === Number(slot);
        if (s.from !== undefined && s.to !== undefined) {
          return Number(slot) >= Number(s.from) && Number(slot) <= Number(s.to);
        }
        return false;
      });
      return sum + (found?.original ?? found?.price ?? pricePerSlot);
    }, 0);
  };

  // Helper: Calculate total discount
  const calculateTotalDiscount = () => {
    const original = calculateOriginalTotal();
    const discounted = calculateTotalPrice();
    return original > discounted ? original - discounted : 0;
  };

  const isSlotLimitReached = maxSlots ? selectedSlots.length >= maxSlots : false;

  const getSlotPrice = (slot: number): number => {
    if (!slotPrices || slotPrices.length === 0) return 0;

    // Try slot-wise pricing first
    const slotSpecific = slotPrices.find((p: any) => p.slot !== undefined && Number(p.slot) === Number(slot));
    if (slotSpecific) {
      return Number(slotSpecific.price);
    }

    // Fallback to range-based pricing
    const rangeMatch = slotPrices.find(
      (p: any) => p.from !== undefined && p.to !== undefined && Number(p.from) <= slot && slot <= Number(p.to)
    );

    if (rangeMatch) {
      return Number(rangeMatch.price);
    }

    // No pricing found - return 0
    return 0;
  };


  if (isLoading) {
    return (
      <Card className={className}>
        <CardHeader>
          <CardTitle className="flex items-center gap-2">
            <Grid3X3 className="h-5 w-5" />
            {t('expos.availableSlots')}
          </CardTitle>
        </CardHeader>
        <CardContent>
          <div className="flex items-center justify-center py-12">
            <Loader2 className="h-6 w-6 animate-spin mr-3" />
            <span className="text-gray-600 dark:text-gray-300">{t('expos.loadingAvailableSlots')}</span>
          </div>
        </CardContent>
      </Card>
    );
  }

  if (availableSlots.length === 0) {
    return (
      <Card className={className}>
        <CardHeader>
          <CardTitle className="flex items-center gap-2">
            <Grid3X3 className="h-5 w-5" />
            {t('expos.availableSlots')}
          </CardTitle>
        </CardHeader>
        <CardContent>
          <Alert>
            <AlertCircle className="h-4 w-4" />
            <AlertDescription>
              {t('expos.noSlotsAvailableAtThisTime')}
            </AlertDescription>
          </Alert>
        </CardContent>
      </Card>
    );
  }

  return (
    <Card className={className}>
      <CardHeader>
        <CardTitle className="flex items-center gap-2">
          <Grid3X3 className="h-5 w-5" />
          {t('expos.availableSlots')}
          {maxSlots && (
            <Badge variant="outline" className="ml-2">
              {selectedSlots.length}/{maxSlots} {t('expos.selected')}
            </Badge>
          )}
        </CardTitle>
      </CardHeader>
      <CardContent>
        <div className="space-y-4">
          {/* Slot Grid */}
          <div className="grid grid-cols-2 md:grid-cols-4 lg:grid-cols-6 xl:grid-cols-8 gap-3">
            {availableSlots.map((slot) => {
              const isSelected = selectedSlots.includes(slot);
              const isDisabled = maxSlots ? !isSelected && isSlotLimitReached : false;

              return (
                <div
                  key={slot}
                  className={`flex items-center space-x-2 p-3 border rounded-lg transition-all cursor-pointer ${isSelected
                    ? 'bg-blue-50 border-blue-200 dark:bg-blue-900/20 dark:border-blue-800'
                    : isDisabled
                      ? 'bg-gray-50 border-gray-200 dark:bg-gray-800 dark:border-gray-700 opacity-50 cursor-not-allowed'
                      : 'hover:bg-gray-50 dark:hover:bg-gray-800 border-gray-200 dark:border-gray-700'
                    }`}
                  onClick={() => !isDisabled && onSlotToggle(slot)}
                >
                  <Checkbox
                    id={`slot-${slot}`}
                    checked={isSelected}
                    onCheckedChange={() => !isDisabled && onSlotToggle(slot)}
                    disabled={isDisabled}
                  />
                  <label
                    htmlFor={`slot-${slot}`}
                    className={`text-sm font-medium leading-none peer-disabled:cursor-not-allowed peer-disabled:opacity-70 ${isDisabled ? 'cursor-not-allowed' : 'cursor-pointer'
                      }`}
                  >
                    {t('expos.slot')} {slot}
                  </label>
                </div>
              );
            })}
          </div>

          {/* Selection Summary */}
          {selectedSlots.length > 0 && (
            <div className="p-4 bg-blue-50 dark:bg-blue-900/20 border border-blue-200 dark:border-blue-800 rounded-lg">
              <h4 className="font-semibold mb-3 text-blue-900 dark:text-blue-100">
                {t('expos.selectionSummary')}
              </h4>

              <div className="space-y-3">
                <div className="flex flex-wrap gap-2">
                  {selectedSlots.map((slot) => (
                    <Badge
                      key={slot}
                      variant="secondary"
                      className="bg-blue-100 text-blue-800 dark:bg-blue-900 dark:text-blue-200"
                    >
                      {t('expos.slot')} {slot} — KWD {(getSlotPrice(slot))}
                    </Badge>
                  ))}
                </div>

                <div className="flex justify-between items-center py-2 border-t border-blue-200 dark:border-blue-800">
                  <div className="space-y-1">
                    <div className="text-sm text-gray-600 dark:text-gray-400">
                      {t('expos.slotsSelectedLabel')} <span className="font-medium">{selectedSlots.length}</span>
                    </div>
                    <div className="text-sm text-gray-600 dark:text-gray-400">
                      {slotPrices.length > 0
                        ? t('expos.slotWisePricing')
                        : <>{t('expos.pricePerSlotLabel')} <span className="font-medium">KWD {(pricePerSlot)}</span></>
                      }
                    </div>
                  </div>
                  <div className="text-right">
                    <div className="text-lg font-bold text-green-600 dark:text-green-400">
                      KWD {(calculateTotalPrice())}
                    </div>
                    <div className="text-xs text-gray-500 dark:text-gray-400">
                      {t('expos.selectionTotalAmount')}
                    </div>
                    {/* {selectedSlots.length > 1 && calculateTotalDiscount() > 0 && (
                      <div className="text-xs text-green-700 dark:text-green-300 mt-1">
                        You saved: KWD {(calculateTotalDiscount())}
                      </div>
                    )} */}
                  </div>
                </div>
              </div>
            </div>
          )}

          {/* Slot Limit Warning */}
          {maxSlots && isSlotLimitReached && (
            <Alert className="border-orange-200 bg-orange-50 dark:bg-orange-900/20 dark:border-orange-800">
              <AlertCircle className="h-4 w-4 text-orange-600" />
              <AlertDescription className="text-orange-600">
                {t('expos.slotLimitReached')}
              </AlertDescription>
            </Alert>
          )}
        </div>
      </CardContent>
    </Card>
  );
}