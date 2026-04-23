import { useEffect, useState } from 'react';
import * as React from 'react';
import { useLanguage } from '@/components/language-context';
import AppLayout from '@/layouts/app-layout';
import { Button } from '@/components/ui/button';
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogFooter } from '@/components/ui/dialog';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Badge } from '@/components/ui/badge';
import { Checkbox } from '@/components/ui/checkbox';
import { toast } from 'react-hot-toast';
import { Head, router, usePage } from '@inertiajs/react';
import { Loader2, Calendar, Clock, Users, CreditCard, CheckCircle, AlertCircle } from 'lucide-react';
import PaymentModal from '@/components/modals/PaymentModal';
import { Alert, AlertDescription } from '@/components/ui/alert';

interface ExpoDetails {
  id: number;
  title_en: string;
  description_en: string;
  start_date: string;
  end_date: string;
  total_slots: number;
  filled_slots: number;
  available_slots: number;
  remaining_time: string;
  categories: any[];
  slot_pricing: string | string[];
  vendor_slot_count: number;
  free_participation?: boolean | number | string;
}

interface BookingData {
  expo_id?: number;
  booking_id?: number;
  booking_ids?: number[];
  total_amount: number | string;
  total_slots_booked: number;
  booked_slots: number[];
  individual_bookings?: Array<{
    id: number;
    slot_number: number;
    amount: number;
    transaction_id: string;
  }>;
  message?: string;
  free_participation?: boolean;
}

interface Props {
  expoId: number;
}

export default function VendorExpoDetailsPage({ expoId }: Props) {
  const { t } = useLanguage();
  const expo = (usePage().props as any).expo;
  const [expoDetails, setExpoDetails] = useState<ExpoDetails | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [availableSlots, setAvailableSlots] = useState<number[]>([]);
  const [selectedSlots, setSelectedSlots] = useState<number[]>([]);
  const [isBooking, setIsBooking] = useState(false);
  const [showPaymentModal, setShowPaymentModal] = useState(false);
  const [showFreeBookingModal, setShowFreeBookingModal] = useState(false);
  const [bookingData, setBookingData] = useState<BookingData | null>(null);
  const [assignModal, setAssignModal] = useState(false);
  const [products, setProducts] = useState<any[]>([]);
  const [selectedProducts, setSelectedProducts] = useState<number[]>([]);
  const [assigning, setAssigning] = useState(false);
  const [joined, setJoined] = useState(false);
  const [sectionModal, setSectionModal] = useState(false);
  const [sectionName, setSectionName] = useState('');
  const [selectedCategory, setSelectedCategory] = useState<number | null>(null);
  const [sectionProducts, setSectionProducts] = useState<number[]>([]);
  const [creatingSection, setCreatingSection] = useState(false);
  const [couponModal, setCouponModal] = useState(false);
  const [selectedCouponProduct, setSelectedCouponProduct] = useState<number | null>(null);
  const [discount, setDiscount] = useState('');
  const [addingCoupon, setAddingCoupon] = useState(false);

  useEffect(() => {
    setLoading(true);
    fetch(`/vendor/expos/${expoId}`)
      .then(res => res.json())
      .then(data => {
        setExpoDetails(data.expo || null);
        setLoading(false);
      })
      .catch(() => {
        setError(t('expos.failedToLoadExpoDetails'));
        setLoading(false);
      });
  }, [expoId]);

  useEffect(() => {
    if (expoDetails) {
      fetchAvailableSlots();
    }
  }, [expoDetails]);

  const fetchAvailableSlots = async () => {
    try {
      const response = await fetch(`/vendor/expos/${expoId}/available-slots`);
      const data = await response.json();
      setAvailableSlots(data.available_slots || []);
    } catch (error) {
      console.error('Error fetching available slots:', error);
    }
  };

  const handleSlotToggle = (slot: number) => {
    setSelectedSlots(prev =>
      prev.includes(slot)
        ? prev.filter(s => s !== slot)
        : [...prev, slot]
    );
  };

  const handleBookSlots = async () => {
    if (selectedSlots.length === 0) {
      toast.error(t('expos.pleaseSelectAtLeastOneSlot'));
      return;
    }

    // Check if this is a free participation expo BEFORE making API call
    const isFreeParticipation = expoDetails?.free_participation === true ||
      expoDetails?.free_participation === 1 ||
      (typeof expoDetails?.free_participation === 'string' && 
       (expoDetails.free_participation === 'true' || expoDetails.free_participation === '1'));

    // If free participation, show simple modal with slot details
    if (isFreeParticipation) {
      const totalAmount = calculateTotalPrice();
      setBookingData({
        expo_id: expoId,
        total_amount: totalAmount,
        total_slots_booked: selectedSlots.length,
        booked_slots: selectedSlots,
        free_participation: true,
      });
      setShowFreeBookingModal(true);
      setShowPaymentModal(false);
      return; // Don't proceed with API call - just show modal
    }

    // For paid bookings, proceed with API call and payment modal
    setIsBooking(true);
    setError('');

    // CRITICAL: Clear booking data and close modals IMMEDIATELY before API call
    // This prevents any modal from opening if response is delayed
    setBookingData(null);
    setShowPaymentModal(false);
    setShowFreeBookingModal(false);

    try {
      console.log('Booking slots - Request:', {
        expoId,
        selectedSlots,
        url: `/vendor/expos/${expoId}/book-slots`,
      });

      const response = await fetch(`/vendor/expos/${expoId}/book-slots`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-TOKEN': document.querySelector('meta[name="csrf-token"]')?.getAttribute('content') || '',
        },
        body: JSON.stringify({
          slots: selectedSlots,
        }),
      });

      console.log('Booking slots - Response status:', response.status);
      const data = await response.json();
      console.log('Booking slots - Response data:', data);
      
      // CRITICAL: Check if response has error
      if (!response.ok) {
        console.log('Response not OK. Checking for vendor_name_required. data.code:', data?.code);
        if (data?.code === 'vendor_name_required') {
          console.log('VENDOR NAME REQUIRED - Redirecting to profile');
          toast.error(data.error || t('expos.toBookNeedName'));
          router.visit('/vendor/profile');
          setIsBooking(false);
          return;
        }
        console.error('Booking failed - Response not OK:', {
          status: response.status,
          statusText: response.statusText,
          data: data,
        });
        toast.error(data.error || data.message || t('expos.failedToBookSlots'));
        setIsBooking(false);
        return;
      }
      
      // CRITICAL: Check if backend actually created bookings
      if (!data.success) {
        console.error('Booking failed - Backend returned success=false:', data);
        toast.error(data.error || data.message || t('expos.failedToBookSlots'));
        setIsBooking(false);
        return;
      }

      if (response.ok && data.success) {
        // Paid booking - show payment modal
        setIsBooking(false);
        
        setBookingData({
          ...data,
          free_participation: false,
          message: data.message || t('expos.proceedWithPayment')
        });
        setShowPaymentModal(true);
      } else {
        // Error case
        setIsBooking(false);
        toast.error(data.error || data.message || t('expos.failedToBookSlots'));
      }
    } catch (error) {
      console.error('Error booking slots:', error);
      toast.error(t('expos.errorBookingSlots'));
    } finally {
      setIsBooking(false);
    }
  };

  // Get price per slot from expo details (slot_pricing)
  const getPricePerSlot = (slot: number) => {
    if (expoDetails && expoDetails.slot_pricing) {
      if (Array.isArray(expoDetails.slot_pricing)) {
        // Try to find slot-specific pricing
        const slotSpecific = expoDetails.slot_pricing.find((p: any) => {
          return p && typeof p === 'object' && p.slot !== undefined && Number(p.slot) === Number(slot);
        }) as any;
        if (slotSpecific && slotSpecific.price !== undefined) {
          return Number(slotSpecific.price);
        }

        // Try range-based pricing
        const rangeMatch = expoDetails.slot_pricing.find((p: any) => {
          return p && typeof p === 'object' && p.from !== undefined && p.to !== undefined && Number(p.from) <= slot && slot <= Number(p.to);
        }) as any;
        if (rangeMatch && rangeMatch.price !== undefined) {
          return Number(rangeMatch.price);
        }

        // Fallback to array index (legacy)
        const legacyPrice = expoDetails.slot_pricing[slot - 1];
        return typeof legacyPrice === 'number' ? legacyPrice : (typeof legacyPrice === 'string' ? Number(legacyPrice) : 0) || 0;
      }
      if (typeof expoDetails.slot_pricing === 'string' && !isNaN(Number(expoDetails.slot_pricing))) {
        return Number(expoDetails.slot_pricing);
      }
    }
    return 0; // No default price
  };

  const calculateTotalPrice = () => {
    return selectedSlots.reduce((sum, slot) => sum + getPricePerSlot(slot), 0);
  };

  const formatAmount = (amount: number) => {
    return new Intl.NumberFormat('en-US', {
      style: 'currency',
      currency: 'USD',
    }).format(amount);
  };

  const fetchProducts = async () => {
    try {
      const response = await fetch(`/vendor/expos/${expoId}/products`);
      const data = await response.json();
      if (data.all_products) {
        setProducts(data.all_products);
      }
      setSelectedProducts([]);
    } catch (error) {
      console.error('Failed to fetch products:', error);
      toast.error(t('expos.failedToLoadProducts'));
    }
  };

  const handleAssignProducts = () => {
    if (!selectedProducts.length) return toast.error(t('expos.selectAtLeastOneProduct'));
    setAssigning(true);
    fetch(`/vendor/expos/${expoId}/assign-products`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ products: selectedProducts }),
    })
      .then(res => res.json())
      .then(data => {
        if (data.success) {
          toast.success(data.message || t('expos.productsAssigned'));
          setAssignModal(false);
        } else {
          toast.error(data.message || t('expos.failedToAssignProducts'));
        }
      })
      .catch(() => toast.error(t('expos.failedToAssignProducts')))
      .finally(() => setAssigning(false));
  };

  const productLimit = (expoDetails ? (expoDetails.filled_slots + 1) * 1 : 1);

  const handleCreateSection = () => {
    if (!sectionName || !selectedCategory || sectionProducts.length === 0) {
      return toast.error(t('expos.sectionNameCategoryProductRequired'));
    }
    setCreatingSection(true);
    fetch(`/vendor/expos/${expoId}/sections`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        section_name: sectionName,
        category_id: selectedCategory,
        products: sectionProducts,
      }),
    })
      .then(res => res.json())
      .then(data => {
        if (data.success) {
          toast.success(data.message || t('expos.sectionCreated'));
          setSectionModal(false);
        } else {
          toast.error(data.message || t('expos.failedToCreateSection'));
        }
      })
      .catch(() => toast.error(t('expos.failedToCreateSection')))
      .finally(() => setCreatingSection(false));
  };

  const handleAddCoupon = () => {
    if (!selectedCouponProduct || !discount) {
      return toast.error(t('expos.selectProductAndDiscount'));
    }
    setAddingCoupon(true);
    fetch(`/vendor/expos/${expoId}/coupons`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        product_id: selectedCouponProduct,
        discount,
      }),
    })
      .then(res => res.json())
      .then(data => {
        if (data.success) {
          toast.success(data.message || t('expos.couponAdded'));
          setCouponModal(false);
        } else {
          toast.error(data.message || t('expos.failedToAddCoupon'));
        }
      })
      .catch(() => toast.error(t('expos.failedToAddCoupon')))
      .finally(() => setAddingCoupon(false));
  };

  if (!expoDetails) {
    return <div className="text-red-600 mt-8 text-center">{t('expos.failedToLoadExpoDetails')}</div>;
  }

  return (
    <AppLayout>
      <Head title={t('expos.expoDetails')} />
      <div className="p-6 max-w-4xl mx-auto">
        <div className="mb-8">
          <h1 className="text-3xl font-bold mb-2">{expoDetails.title_en}</h1>
          <p className="text-gray-600 mb-4">{expoDetails.description_en}</p>

          <div className="grid grid-cols-1 md:grid-cols-3 gap-4 mb-6">
            <Card>
              <CardHeader className="pb-2">
                <CardTitle className="text-sm font-medium text-gray-600 flex items-center gap-2">
                  <Calendar className="h-4 w-4" />
                  {t('expos.eventDates')}
                </CardTitle>
              </CardHeader>
              <CardContent>
                <div className="text-sm">
                  <div>{t('expos.start')} {new Date(expoDetails.start_date).toLocaleDateString()}</div>
                  <div>{t('expos.end')} {new Date(expoDetails.end_date).toLocaleDateString()}</div>
                </div>
              </CardContent>
            </Card>

            <Card>
              <CardHeader className="pb-2">
                <CardTitle className="text-sm font-medium text-gray-600 flex items-center gap-2">
                  <Users className="h-4 w-4" />
                  {t('expos.slotAvailability')}
                </CardTitle>
              </CardHeader>
              <CardContent>
                <div className="text-sm">
                  <div>{t('expos.availableLabel')} {expoDetails.available_slots} / {expoDetails.total_slots}</div>
                  <div className="text-blue-600">{expoDetails.remaining_time} {t('expos.remainingLabel')}</div>
                </div>
              </CardContent>
            </Card>

            <Card>
              <CardHeader className="pb-2">
                <CardTitle className="text-sm font-medium text-gray-600 flex items-center gap-2">
                  <Clock className="h-4 w-4" />
                  {t('expos.timeRemaining')}
                </CardTitle>
              </CardHeader>
              <CardContent>
                <div className="text-sm text-blue-600">{expoDetails.remaining_time}</div>
              </CardContent>
            </Card>
          </div>
        </div>

        <Card className="mb-6">
          <CardHeader>
            <CardTitle className="flex items-center gap-2">
              <CreditCard className="h-5 w-5" />
              {t('expos.bookSlots')}
            </CardTitle>
          </CardHeader>
          <CardContent>
            {error && (
              <div className="mb-4 p-3 bg-red-50 border border-red-200 rounded-md">
                <p className="text-red-600 text-sm">{error}</p>
              </div>
            )}

            <div className="mb-4">
              <h3 className="text-lg font-semibold mb-3">{t('expos.availableSlots')}</h3>
              {availableSlots.length === 0 ? (
                <p className="text-gray-500">{t('expos.noSlotsAvailableForBooking')}</p>
              ) : (
                <div className="grid grid-cols-2 md:grid-cols-4 lg:grid-cols-6 gap-3">
                  {availableSlots.map((slot) => (
                    <div key={slot} className="flex items-center space-x-2">
                      <Checkbox
                        id={`slot-${slot}`}
                        checked={selectedSlots.includes(slot)}
                        onCheckedChange={() => handleSlotToggle(slot)}
                      />
                      <label
                        htmlFor={`slot-${slot}`}
                        className="text-sm font-medium leading-none peer-disabled:cursor-not-allowed peer-disabled:opacity-70"
                      >
                        {t('expos.slot')} {slot}
                      </label>
                    </div>
                  ))}
                </div>
              )}
            </div>

            {selectedSlots.length > 0 && (
              <div className="mb-4 p-4 bg-blue-50 border border-blue-200 rounded-md">
                <h4 className="font-semibold mb-2">{t('expos.bookingSummary')}</h4>
                <div className="flex items-center gap-2 mb-3">
                  <span className="font-medium">{t('expos.totalSlotsSelected')}</span>
                  <Badge variant="default" className="text-lg">
                    {selectedSlots.length} {t('expos.slotsCount')}
                  </Badge>
                </div>
                <div className="flex flex-wrap gap-2 mb-3">
                  {selectedSlots.map((slot) => (
                    <Badge key={slot} variant="secondary">
                      {t('expos.slot')} {slot}
                    </Badge>
                  ))}
                </div>
                <div className="flex justify-between items-center">
                  <span className="font-medium">{t('expos.totalAmount')}</span>
                  <span className="text-lg font-bold text-green-600">
                    {formatAmount(calculateTotalPrice())}
                  </span>
                </div>
              </div>
            )}

            <Button
              onClick={handleBookSlots}
              disabled={isBooking || selectedSlots.length === 0}
              className="w-full"
              size="lg"
            >
              {isBooking ? (
                <>
                  <Loader2 className="mr-2 h-4 w-4 animate-spin" />
                  {t('expos.bookingSlots')}
                </>
              ) : (
                <>
                  <CreditCard className="mr-2 h-4 w-4" />
                  {t('expos.bookSelectedSlots')}
                </>
              )}
            </Button>
          </CardContent>
        </Card>

        {joined && (
          <div className="space-x-2">
            <Button onClick={() => { setAssignModal(true); fetchProducts(); }}>
              {t('expos.assignProducts')}
            </Button>
            <Button onClick={() => setSectionModal(true)}>
              {t('expos.createSection')}
            </Button>
            <Button onClick={() => setCouponModal(true)}>
              {t('expos.addCouponDiscount')}
            </Button>
          </div>
        )}

        {/* Assign Products Modal */}
        <Dialog open={assignModal} onOpenChange={setAssignModal}>
          <DialogContent>
            <DialogHeader>
              <DialogTitle>{t('expos.assignProductsToExpo')}</DialogTitle>
            </DialogHeader>
            <div className="mb-2">{t('expos.productLimit')} {productLimit}</div>
            <div className="mb-4">
              {products.map(product => (
                <label key={product.id} className="block mb-1">
                  <input
                    type="checkbox"
                    value={product.id}
                    checked={selectedProducts.includes(product.id)}
                    onChange={e => {
                      const id = product.id;
                      setSelectedProducts(sel =>
                        e.target.checked
                          ? sel.length < productLimit ? [...sel, id] : sel
                          : sel.filter(pid => pid !== id)
                      );
                    }}
                    disabled={!selectedProducts.includes(product.id) && selectedProducts.length >= productLimit}
                  />
                  <span className="ml-2">{product.name_en}</span>
                </label>
              ))}
            </div>
            <DialogFooter>
              <Button onClick={() => setAssignModal(false)} variant="outline" disabled={assigning}>{t('common.cancel')}</Button>
              <Button onClick={handleAssignProducts} disabled={assigning || selectedProducts.length === 0}>
                {assigning ? t('expos.assigning') : t('expos.assignProducts')}
              </Button>
            </DialogFooter>
          </DialogContent>
        </Dialog>

        {/* Create Section Modal */}
        <Dialog open={sectionModal} onOpenChange={setSectionModal}>
          <DialogContent>
            <DialogHeader>
              <DialogTitle>{t('expos.createSection')}</DialogTitle>
            </DialogHeader>
            <div className="mb-2">
              <label className="block mb-1 font-medium">{t('expos.sectionName')}</label>
              <input
                className="border rounded px-2 py-1 w-full"
                value={sectionName}
                onChange={e => setSectionName(e.target.value)}
              />
            </div>
            <div className="mb-2">
              <label className="block mb-1 font-medium">{t('expos.category')}</label>
              <select
                className="border rounded px-2 py-1 w-full"
                value={selectedCategory ?? ''}
                onChange={e => setSelectedCategory(Number(e.target.value))}
              >
                <option value="">{t('expos.selectCategory')}</option>
                {expoDetails?.categories?.map((cat: any) => (
                  <option key={cat.id} value={cat.id}>{cat.name_en}</option>
                ))}
              </select>
            </div>
            <div className="mb-4">
              <label className="block mb-1 font-medium">{t('expos.products')}</label>
              {products.map(product => (
                <label key={product.id} className="block mb-1">
                  <input
                    type="checkbox"
                    value={product.id}
                    checked={sectionProducts.includes(product.id)}
                    onChange={e => {
                      const id = product.id;
                      setSectionProducts(sel =>
                        e.target.checked
                          ? [...sel, id]
                          : sel.filter(pid => pid !== id)
                      );
                    }}
                  />
                  <span className="ml-2">{product.name_en}</span>
                </label>
              ))}
            </div>
            <DialogFooter>
              <Button onClick={() => setSectionModal(false)} variant="outline" disabled={creatingSection}>{t('common.cancel')}</Button>
              <Button onClick={handleCreateSection} disabled={creatingSection || !sectionName || !selectedCategory || sectionProducts.length === 0}>
                {creatingSection ? t('expos.creating') : t('expos.createSection')}
              </Button>
            </DialogFooter>
          </DialogContent>
        </Dialog>

        {/* Add Coupon/Discount Modal */}
        <Dialog open={couponModal} onOpenChange={setCouponModal}>
          <DialogContent>
            <DialogHeader>
              <DialogTitle>{t('expos.addCouponDiscount')}</DialogTitle>
            </DialogHeader>
            <div className="mb-2">
              <label className="block mb-1 font-medium">{t('expos.product')}</label>
              <select
                className="border rounded px-2 py-1 w-full"
                value={selectedCouponProduct ?? ''}
                onChange={e => setSelectedCouponProduct(Number(e.target.value))}
              >
                <option value="">{t('expos.selectProduct')}</option>
                {(products.length > 0 ? products : [
                  { id: 1, name: 'Product 1' },
                  { id: 2, name: 'Product 2' },
                ]).map(product => (
                  <option key={product.id} value={product.id}>{product.name_en}</option>
                ))}
              </select>
            </div>
            <div className="mb-4">
              <label className="block mb-1 font-medium">{t('expos.discount')}</label>
              <input
                className="border rounded px-2 py-1 w-full"
                type="text"
                value={discount}
                onChange={e => setDiscount(e.target.value)}
                placeholder={t('expos.discountPlaceholder')}
              />
            </div>
            <DialogFooter>
              <Button onClick={() => setCouponModal(false)} variant="outline" disabled={addingCoupon}>{t('common.cancel')}</Button>
              <Button onClick={handleAddCoupon} disabled={addingCoupon || !selectedCouponProduct || !discount}>
                {addingCoupon ? t('expos.adding') : t('expos.addCouponDiscount')}
              </Button>
            </DialogFooter>
          </DialogContent>
        </Dialog>

        {/* Only render PaymentModal if bookingData exists, showPaymentModal is true, and it's NOT a free booking */}
        {(() => {
          // Early return if no booking data or modal should not be shown
          if (!bookingData || !showPaymentModal) return null;

          const totalAmount = Number(bookingData.total_amount) || 0;
          const isFree = bookingData.free_participation === true ||
            (typeof bookingData.free_participation === 'number' && bookingData.free_participation === 1) ||
            (typeof bookingData.free_participation === 'string' && bookingData.free_participation === 'true') ||
            totalAmount === 0 ||
            totalAmount <= 0.01;

          console.log('VendorDetails - Rendering PaymentModal check:', {
            bookingData,
            showPaymentModal,
            totalAmount,
            isFree,
            free_participation_value: bookingData.free_participation,
            free_participation_type: typeof bookingData.free_participation,
          });

          // CRITICAL: Don't render PaymentModal if it's a free booking
          if (isFree) {
            console.log('VendorDetails - This is a FREE booking, NOT rendering PaymentModal');

            // Close modal immediately if somehow opened for free booking
            if (showPaymentModal) {
              setShowPaymentModal(false);
              setBookingData(null);
            }
            return null;
          }

          // Only render if NOT free
          console.log('VendorDetails - Rendering PaymentModal with onVendorNameRequired callback');
          return (
            <PaymentModal
              isOpen={showPaymentModal}
              onClose={() => {
                setShowPaymentModal(false);
                setBookingData(null);
              }}
              bookingData={{ ...bookingData, expo_id: bookingData.expo_id || expoId }}
              expoName={expoDetails?.title_en || 'Expo'}
              onVendorNameRequired={(msg) => {
                console.log('VendorDetails - onVendorNameRequired callback called with:', msg);
                console.log('About to show toast and redirect to /vendor/profile');
                toast.error(msg);
                console.log('Toast shown, now calling router.visit');
                router.visit('/vendor/profile');
                console.log('router.visit called');
              }}
            />
          );
        })()}

        {/* Free Booking Confirmation Modal */}
        <Dialog open={showFreeBookingModal} onOpenChange={(open) => {
          if (!open) {
            setShowFreeBookingModal(false);
            setBookingData(null);
          }
        }}>
          <DialogContent className="sm:max-w-md">
            <DialogHeader>
              <DialogTitle>{t('expos.confirmBooking')}</DialogTitle>
            </DialogHeader>
            <div className="space-y-4 py-4">
              {bookingData && selectedSlots.length > 0 && (
                <>
                  {/* Confirmation Message */}
                  <div className="bg-blue-50 dark:bg-blue-900/20 border border-blue-200 dark:border-blue-800 rounded-lg p-4">
                    <p className="text-sm text-gray-700 dark:text-gray-300">
                      {t('expos.confirmFreeBookingMessage')}
                    </p>
                  </div>

                  {/* Slot Details */}
                  <div className="space-y-3">
                    <div>
                      <h3 className="text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">{t('expos.selectedSlots')}</h3>
                      <div className="flex flex-wrap gap-2">
                        {selectedSlots.map((slot: number) => {
                          const slotPrice = getPricePerSlot(slot);
                          return (
                            <div
                              key={slot}
                              className="px-3 py-2 bg-blue-50 dark:bg-blue-900/20 rounded-lg border border-blue-200 dark:border-blue-800"
                            >
                              <span className="text-sm font-medium text-blue-700 dark:text-blue-300">
                                {t('expos.slot')} {slot}
                              </span>
                              <span className="text-xs text-gray-500 dark:text-gray-400 ml-2">
                                (KWD {slotPrice.toFixed(2)})
                              </span>
                            </div>
                          );
                        })}
                      </div>
                    </div>
                    
                    <div className="pt-3 border-t">
                      <div className="flex justify-between items-center">
                        <span className="text-sm font-medium text-gray-700 dark:text-gray-300">{t('expos.totalSlots')}</span>
                        <span className="text-sm font-semibold">{selectedSlots.length}</span>
                      </div>
                      <div className="flex justify-between items-center mt-2">
                        <span className="text-sm font-medium text-gray-700 dark:text-gray-300">{t('expos.totalAmount')}</span>
                        <span className="text-lg font-bold text-green-600 dark:text-green-400">
                          KWD {calculateTotalPrice().toFixed(2)}
                        </span>
                      </div>
                    </div>
                  </div>
                </>
              )}
            </div>
            <DialogFooter className="gap-2">
              <Button
                variant="outline"
                onClick={() => {
                  setShowFreeBookingModal(false);
                  setBookingData(null);
                }}
                disabled={isBooking}
              >
                {t('common.cancel')}
              </Button>
              <Button
                className="bg-green-600 hover:bg-green-700"
                onClick={async () => {
                  if (!bookingData || selectedSlots.length === 0) {
                    toast.error(t('expos.noSlotsSelected'));
                    return;
                  }

                  setIsBooking(true);
                  setError('');

                  try {
                    console.log('Booking free slots - Request:', {
                      expoId,
                      selectedSlots,
                      url: `/vendor/expos/${expoId}/book-slots`,
                    });

                    const response = await fetch(`/vendor/expos/${expoId}/book-slots`, {
                      method: 'POST',
                      headers: {
                        'Content-Type': 'application/json',
                        'X-CSRF-TOKEN': document.querySelector('meta[name="csrf-token"]')?.getAttribute('content') || '',
                      },
                      body: JSON.stringify({
                        slots: selectedSlots,
                      }),
                    });

                    console.log('Booking free slots - Response status:', response.status);
                    const data = await response.json();
                    console.log('Booking free slots - Response data:', data);

                    if (!response.ok || !data.success) {
                      console.log('Free booking failed. Checking vendor_name_required. data.code:', data?.code);
                      if (data?.code === 'vendor_name_required') {
                        console.log('VENDOR NAME REQUIRED - Redirecting to profile');
                        toast.error(data.error || t('expos.toBookNeedName'));
                        router.visit('/vendor/profile');
                        setIsBooking(false);
                        return;
                      }
                      console.error('Booking failed:', data);
toast.error(data.error || data.message || t('expos.failedToBookSlots'));
                    setIsBooking(false);
                    return;
                  }

                  // Success - show message and reload
                  toast.success(data.message || t('expos.slotsBookedSuccess'));
                    setShowFreeBookingModal(false);
                    setBookingData(null);
                    setIsBooking(false);
                    setSelectedSlots([]);

                    // Reload page to show updated slot status
                    setTimeout(() => {
                      window.location.reload();
                    }, 1000);
                  } catch (error) {
                    console.error('Error booking slots:', error);
                    toast.error(t('expos.errorBookingSlotsRetry'));
                    setIsBooking(false);
                  }
                }}
                disabled={isBooking}
              >
                {isBooking ? (
                  <>
                    <Loader2 className="mr-2 h-4 w-4 animate-spin" />
                    {t('expos.booking')}
                  </>
                ) : (
                  t('expos.bookNow')
                )}
              </Button>
            </DialogFooter>
          </DialogContent>
        </Dialog>
      </div>
    </AppLayout>
  );
} 