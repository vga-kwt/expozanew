import React, { useState } from 'react';
import { Dialog, DialogContent, DialogHeader, DialogTitle } from '@/components/ui/dialog';
import { Button } from '@/components/ui/button';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Badge } from '@/components/ui/badge';
import { Alert, AlertDescription } from '@/components/ui/alert';
import { RadioGroup, RadioGroupItem } from '@/components/ui/radio-group';
import { Label } from '@/components/ui/label';
import { Loader2, CreditCard, CheckCircle, AlertCircle, XCircle, Shield, Clock } from 'lucide-react';
import { toast } from 'react-hot-toast';
import { useLanguage } from '@/components/language-context';

interface PaymentModalProps {
  isOpen: boolean;
  onClose: () => void;
  bookingData: {
    expo_id: number;
    booking_id?: number; // Legacy support
    booking_ids?: number[]; // New individual booking IDs
    total_amount: number | string;
    total_slots_booked: number;
    booked_slots: number[];
    free_participation?: boolean;
    individual_bookings?: Array<{
      id: number;
      slot_number: number;
      amount: number;
      transaction_id: string;
    }>;
    message?: string;
  } | null;
  expoName: string;
  onVendorNameRequired?: (message: string) => void;
}


export default function PaymentModal({ isOpen, onClose, bookingData, expoName, onVendorNameRequired }: PaymentModalProps) {
  const { t } = useLanguage();
  const [isProcessing, setIsProcessing] = useState(false);
  const [paymentStatus, setPaymentStatus] = useState<'pending' | 'success' | 'failed'>('pending');
  const [paymentMethod, setPaymentMethod] = useState('');
  const [error, setError] = useState<string | null>(null);
  
  console.log('PaymentModal rendered with onVendorNameRequired:', typeof onVendorNameRequired, onVendorNameRequired ? 'defined' : 'undefined');

  // Check if this is a free booking (moved to top for use in multiple places)
  const isFreeBooking = bookingData ? (
    bookingData.free_participation === true ||
    (typeof bookingData.free_participation === 'number' && bookingData.free_participation === 1) ||
    (typeof bookingData.free_participation === 'string' && (bookingData.free_participation === 'true' || bookingData.free_participation === '1')) ||
    Number(bookingData.total_amount) === 0 ||
    parseFloat(String(bookingData.total_amount || 0)) <= 0.01
  ) : false;



  const handleMyFatoorahPayment = async () => {
    if (!bookingData) return;
    
    // Check if this is a free booking - if so, don't process payment
    const isFree = bookingData.free_participation === true ||
                   (typeof bookingData.free_participation === 'string' && bookingData.free_participation === 'true') ||
                   Number(bookingData.total_amount) === 0 ||
                   parseFloat(String(bookingData.total_amount)) === 0;
    
    if (isFree) {
      // For free bookings, just confirm directly
      handleFreeBookingConfirm();
      return;
    }
    
    // Validate payment method for paid bookings
    if (!paymentMethod) {
      setError(t('payment.pleaseSelectPaymentMethod'));
      return;
    }
    
    setIsProcessing(true);
    setError(null);

    try {
      const response = await fetch('/vendor/expo-booking/pay-with-myfatoorah', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-TOKEN': document.querySelector('meta[name="csrf-token"]')?.getAttribute('content') || '',
        },
        body: JSON.stringify({
          expo_id: bookingData.expo_id,
          slots: bookingData.booked_slots,
          price: bookingData.total_amount,
          payment_method: paymentMethod,
        }),
      });
      const data = await response.json();
      if (data.success && data.payment_url) {
        window.location.href = data.payment_url;
      } else {
setError(data.message || t('payment.paymentInitiationFailed'));
    }
    } catch {
      setError(t('payment.networkError'));
    } finally {
      setIsProcessing(false);
    }
  };

  const handleClose = () => {
    if (!isProcessing) {
      setPaymentStatus('pending');
      setError(null);
      setPaymentMethod('');
      onClose();
    }
  };

  // Handle free booking confirmation - Always create bookings (like paid bookings)
  const handleFreeBookingConfirm = React.useCallback(async () => {
    if (!bookingData) return;
    
    setIsProcessing(true);
    setError(null);
    
    try {
      // Always create bookings for free participation (same as paid bookings)
      const createResponse = await fetch(`/vendor/expos/${bookingData.expo_id}/book-slots`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-TOKEN': document.querySelector('meta[name="csrf-token"]')?.getAttribute('content') || '',
        },
        body: JSON.stringify({
          slots: bookingData.booked_slots || [],
        }),
      });
      
      const createData = await createResponse.json();
      console.log('PaymentModal - Free booking response:', createResponse.status, createData);
      
      if (!createResponse.ok || !createData.success) {
        console.log('PaymentModal - Booking failed. Checking vendor_name_required. code:', createData?.code);
        if (createData?.code === 'vendor_name_required') {
          console.log('PaymentModal - VENDOR NAME REQUIRED - Calling onVendorNameRequired');
          console.log('onVendorNameRequired type:', typeof onVendorNameRequired);
          console.log('onVendorNameRequired exists?:', !!onVendorNameRequired);
          
          if (onVendorNameRequired) {
            console.log('Calling onVendorNameRequired with message:', createData.error);
            try {
              onVendorNameRequired(createData.error || t('payment.toBookNeedName'));
              console.log('onVendorNameRequired called successfully');
            } catch (err) {
              console.error('Error calling onVendorNameRequired:', err);
            }
          } else {
            console.warn('onVendorNameRequired is not defined!');
          }
          
          onClose();
          setIsProcessing(false);
          return;
        }
        setError(createData.error || createData.message || t('payment.failedToBookSlots'));
        setIsProcessing(false);
        return;
      }
      
      // Success - show message from API response
      const successMessage = createData.message || t('payment.slotsBookedSuccess');
      toast.success(successMessage);
      
      // Close modal first
      onClose();
      
      // Reload page after showing success message (give time to see the message)
      setTimeout(() => {
        window.location.reload();
      }, 1500);
      
    } catch (error) {
      console.error('Error booking slots:', error);
      setError(t('payment.errorBookingSlots'));
      setIsProcessing(false);
    }
  }, [bookingData, onClose, onVendorNameRequired, t]);


  if (!bookingData) return null;

  return (
    <Dialog open={isOpen} onOpenChange={handleClose}>
      <DialogContent className="sm:max-w-lg max-h-[95vh] overflow-y-auto">
        <DialogHeader className="pb-4">
          <DialogTitle className="flex items-center gap-2 text-xl">
            <CreditCard className="h-6 w-6" />
            {t('payment.paymentFor')} {expoName}
          </DialogTitle>
        </DialogHeader>

        <div className="space-y-6">
          {paymentStatus === 'pending' && (
            <>
              {/* Booking Summary */}
              <Card className="border-blue-200 dark:border-blue-800">
                <CardHeader className="pb-3">
                  <CardTitle className="text-lg flex items-center gap-2">
                    <Shield className="h-5 w-5 text-blue-600" />
                    {t('payment.bookingSummary')}
                  </CardTitle>
                </CardHeader>
                <CardContent className="space-y-4">
                  <div className="grid grid-cols-2 gap-4 text-sm">
                    <div>
                      <span className="text-gray-600 dark:text-gray-400">{t('payment.expo')}</span>
                      <div className="font-medium text-gray-900 dark:text-gray-100">{expoName}</div>
                    </div>
                    <div>
                      <span className="text-gray-600 dark:text-gray-400">{bookingData.booking_ids && bookingData.booking_ids.length > 1 ? t('payment.bookingIds') : t('payment.bookingId')}</span>
                      <div className="font-medium text-gray-900 dark:text-gray-100">
                        {bookingData.booking_ids && bookingData.booking_ids.length > 0
                          ? bookingData.booking_ids.map(id => `#${id}`).join(', ')
                          : `#${bookingData.booking_id ?? 'N/A'}`
                        }
                      </div>
                    </div>
                  </div>

                  <div>
                    <span className="text-gray-600 dark:text-gray-400 text-sm">{t('payment.bookedSlots')}</span>
                    <div className="flex flex-wrap gap-2 mt-2">
                      {bookingData.booked_slots && bookingData.booked_slots.map((slot: number) => (
                        <Badge key={slot} variant="secondary" className="bg-blue-100 text-blue-800 dark:bg-blue-900 dark:text-blue-200">
                          {t('expos.slot')} {slot}
                        </Badge>
                      ))}
                    </div>
                    {bookingData.individual_bookings && bookingData.individual_bookings.length > 0 && (
                      <div className="mt-3 text-xs text-gray-500 dark:text-gray-400">
                        <div className="grid grid-cols-1 gap-1">
                          {bookingData.individual_bookings.map((booking) => (
                            <div key={booking.id} className="flex justify-between items-center py-1 px-2 bg-gray-50 dark:bg-gray-800 rounded">
                              <span>{t('expos.slot')} {booking.slot_number}</span>
                              <span className="font-medium">KWD {Number(booking.amount).toFixed(2)}</span>
                            </div>
                          ))}
                        </div>
                      </div>
                    )}
                  </div>

                  <div className="flex justify-between items-center pt-4 border-t border-gray-200 dark:border-gray-700">
                    <span className="text-lg font-semibold text-gray-900 dark:text-gray-100">{t('payment.totalAmount')}</span>
                    {bookingData.total_amount != null ? (
                      <span className="text-2xl font-bold text-green-600 dark:text-green-400">
                        KWD {(Number(bookingData.total_amount))}
                      </span>
                    ) : (
                      <span className="text-sm text-red-500">{t('payment.notAvailable')}</span>
                    )}
                  </div>
                </CardContent>
              </Card>

              {/* Payment Method Selection - Hide for free bookings */}
              {!isFreeBooking && (
                <Card>
                  <CardHeader className="pb-3">
                    <CardTitle className="text-lg">{t('payment.paymentMethod')}</CardTitle>
                  </CardHeader>
                  <CardContent>
                    <RadioGroup value={paymentMethod} onValueChange={setPaymentMethod}>
                      <div className="flex items-center space-x-2 mb-3">
                        <RadioGroupItem value="knet" id="knet" />
                        <Label htmlFor="knet" className="flex items-center gap-2 cursor-pointer">
                          <Shield className="h-4 w-4" />
                          KNET
                        </Label>
                      </div>
                      <div className="flex items-center space-x-2">
                        <RadioGroupItem value="visa/master" id="visa/master" />
                        <Label htmlFor="visa/master" className="flex items-center gap-2 cursor-pointer">
                          <CreditCard className="h-4 w-4" />
                          VISA/MASTER
                        </Label>
                      </div>
                    </RadioGroup>
                  </CardContent>
                </Card>
              )}

              {/* Security Notice - Show different message for free bookings */}
              {isFreeBooking ? (
                <Alert className="border-green-200 bg-green-50 dark:bg-green-900/20 dark:border-green-800">
                  <CheckCircle className="h-4 w-4 text-green-600" />
                  <AlertDescription className="text-green-600 text-sm">
                    {t('payment.noPaymentRequired')}
                  </AlertDescription>
                </Alert>
              ) : (
                <Alert className="border-green-200 bg-green-50 dark:bg-green-900/20 dark:border-green-800">
                  <Shield className="h-4 w-4 text-green-600" />
                  <AlertDescription className="text-green-600 text-sm">
                    {t('payment.paymentSecureNotice')}
                  </AlertDescription>
                </Alert>
              )}

              {error && !isFreeBooking && (
                <Alert className="border-red-200 bg-red-50 dark:bg-red-900/20 dark:border-red-800">
                  <AlertCircle className="h-4 w-4 text-red-600" />
                  <AlertDescription className="text-red-600">{error}</AlertDescription>
                </Alert>
              )}

              {/* Action Buttons */}
              <div className="space-y-3">
                {isFreeBooking ? (
                  <>
                    <Button
                      onClick={handleFreeBookingConfirm}
                      disabled={isProcessing}
                      className="w-full bg-green-600 hover:bg-green-700"
                      size="lg"
                    >
                      <CheckCircle className="mr-2 h-4 w-4" />
                      {t('payment.confirmBooking')}
                    </Button>
                    <Button
                      variant="outline"
                      onClick={handleClose}
                      disabled={isProcessing}
                      className="w-full"
                    >
                      {t('payment.cancel')}
                    </Button>
                  </>
                ) : (
                  <>
                    <Button
                      onClick={handleMyFatoorahPayment}
                      disabled={isProcessing || (!isFreeBooking && !paymentMethod)}
                      className="w-full"
                      size="lg"
                    >
                      {isProcessing ? (
                        <>
                          <Loader2 className="mr-2 h-4 w-4 animate-spin" />
                          {t('payment.processingPayment')}
                        </>
                      ) : (
                        <>
                          <CreditCard className="mr-2 h-4 w-4" />
                          {t('payment.confirmAndPay')}
                        </>
                      )}
                    </Button>
                    <Button
                      variant="outline"
                      onClick={handleClose}
                      disabled={isProcessing}
                      className="w-full"
                    >
                      {t('payment.cancel')}
                    </Button>
                  </>
                )}
              </div>
            </>
          )}

          {paymentStatus === 'success' && (
            <div className="text-center space-y-6">
              <div className="flex justify-center">
                <div className="h-20 w-20 bg-green-100 dark:bg-green-900/20 rounded-full flex items-center justify-center">
                  <CheckCircle className="h-12 w-12 text-green-600" />
                </div>
              </div>
              <div>
                <h3 className="text-xl font-semibold text-green-600 mb-2">{t('payment.paymentSuccessful')}</h3>
                <p className="text-gray-600 dark:text-gray-300 mb-4">
                  {bookingData.total_slots_booked > 1 ? t('payment.slotsConfirmedPlural') : t('payment.slotsConfirmedSingle')}
                </p>
                {bookingData.individual_bookings && bookingData.individual_bookings.length > 0 && (
                  <div className="bg-blue-50 dark:bg-blue-900/20 border border-blue-200 dark:border-blue-800 rounded-lg p-3 mb-4">
                    <div className="text-sm">
                      <div className="font-medium text-blue-800 dark:text-blue-200 mb-2">{t('payment.bookingDetails')}</div>
                      <div className="space-y-1">
                        {bookingData.individual_bookings.map((booking) => (
                          <div key={booking.id} className="flex justify-between text-blue-700 dark:text-blue-300">
                            <span>{t('expos.slot')} {booking.slot_number} (#{booking.id})</span>
                            <span>KWD {Number(booking.amount).toFixed(2)}</span>
                          </div>
                        ))}
                      </div>
                    </div>
                  </div>
                )}
                <div className="bg-green-50 dark:bg-green-900/20 border border-green-200 dark:border-green-800 rounded-lg p-4">
                  <div className="flex items-center gap-2 mb-2">
                    <Clock className="h-4 w-4 text-green-600" />
                    <span className="font-medium text-green-600">{t('payment.whatsNext')}</span>
                  </div>
                  <ul className="text-sm text-green-700 dark:text-green-300 space-y-1">
                    <li>• {t('payment.confirmationEmail')}</li>
                    <li>• {t('payment.assignProductsToSlots')}</li>
                    <li>• {t('payment.prepareBoothSetup')}</li>
                  </ul>
                </div>
              </div>
            </div>
          )}

          {paymentStatus === 'failed' && (
            <div className="text-center space-y-6">
              <div className="flex justify-center">
                <div className="h-20 w-20 bg-red-100 dark:bg-red-900/20 rounded-full flex items-center justify-center">
                  <XCircle className="h-12 w-12 text-red-600" />
                </div>
              </div>
              <div>
                <h3 className="text-xl font-semibold text-red-600 mb-2">{t('payment.paymentFailed')}</h3>
                <p className="text-gray-600 dark:text-gray-300 mb-4">
                  {error || t('payment.paymentErrorDefault')}
                </p>
                <div className="space-y-3">
                  <Button onClick={() => setPaymentStatus('pending')} className="w-full">
                    {t('payment.tryAgain')}
                  </Button>
                  <Button variant="outline" onClick={handleClose} className="w-full">
                    {t('payment.close')}
                  </Button>
                </div>
              </div>
            </div>
          )}
        </div>
      </DialogContent>
    </Dialog>
  );
}
