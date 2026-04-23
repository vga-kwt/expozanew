/* eslint-disable @typescript-eslint/no-explicit-any */
import { useLanguage } from '@/components/language-context';
import { Button } from '@/components/ui/button';
import { Dialog, DialogContent, DialogFooter, DialogHeader, DialogTitle } from '@/components/ui/dialog';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select';
import AppLayout from '@/layouts/app-layout';
import { Head, router, usePage } from '@inertiajs/react';
import { Check } from 'lucide-react';
import { useEffect, useState } from 'react';
import { toast } from 'react-hot-toast';
import dayjs from 'dayjs';

export default function VendorSubscriptionPage() {
    const { t } = useLanguage();
    const { currentSubscription, plans, flash } = usePage().props as any;
    const [upgradeModal, setUpgradeModal] = useState(false);
    const [renewModal, setRenewModal] = useState(false);
    const [cancelModal, setCancelModal] = useState(false);
    const [selectedPlan, setSelectedPlan] = useState(null as any);
    const [loading, setLoading] = useState(false);
    const [paymentMethod, setPaymentMethod] = useState('');
    const [billingType, setBillingType] = useState<'monthly' | 'yearly'>('monthly');
    const filteredPlans = plans.filter((plan: any) => plan.duration === billingType);

    // Check for reload parameter in URL
    useEffect(() => {
        const urlParams = new URLSearchParams(window.location.search);
        if (urlParams.get('reload') === '1') {
            // Remove reload parameter from URL
            urlParams.delete('reload');
            const newUrl = window.location.pathname + (urlParams.toString() ? '?' + urlParams.toString() : '');
            window.history.replaceState({}, '', newUrl);
        }
    }, []);

    // Show toast notifications for flash messages and reload page data
    useEffect(() => {
        if (flash?.success) {
            toast.success(flash.success);
            // Reload page data after successful subscription
            setTimeout(() => {
                router.reload({ only: ['currentSubscription', 'plans'] });
            }, 1000);
        }
        if (flash?.error) {
            // Only show error if it's not related to a free subscription that might have succeeded
            // Check if subscription was actually created by reloading first
            toast.error(flash.error);
            // Also reload on error to refresh subscription status
            setTimeout(() => {
                router.reload({ only: ['currentSubscription', 'plans'] });
            }, 1000);
        }
    }, [flash?.success, flash?.error]);

    const today = dayjs();
    const start = currentSubscription ? dayjs(currentSubscription.start_date) : null;
    const expiry = currentSubscription ? dayjs(currentSubscription.expiry) : null;
    const totalDays = start && expiry ? expiry.diff(start, 'day') : 0;
    const remainingDays = expiry ? expiry.diff(today, 'day') : 0;

    // Proration calculation mock
    const prorationAmount = (() => {
        if (!selectedPlan || !currentSubscription) return 0;
        if (totalDays <= 0 || remainingDays <= 0) return parseFloat(selectedPlan.price);

        const dailyPrice = parseFloat(currentSubscription.price) / totalDays;
        const remainingValue = dailyPrice * remainingDays;

        return Math.max(0, parseFloat(selectedPlan.price) - remainingValue);
    })();

    // Handler for first-time subscription
    const handleSubscribe = () => {
        setLoading(true);
        fetch('/vendor/subscribe/pay-with-myfatoorah', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'X-CSRF-TOKEN': (window as any).Laravel?.csrfToken || document.querySelector('meta[name="csrf-token"]')?.getAttribute('content') || '',
            },
            body: JSON.stringify({
                subscription_id: selectedPlan.id,
                price: selectedPlan.price,
                payment_method: paymentMethod,
                type: 'first',
            }),
        })
        .then(async res => {
            const contentType = res.headers.get('content-type');
            
            // Check if response is JSON
            if (!contentType || !contentType.includes('application/json')) {
                const text = await res.text();
                console.error('Non-JSON response:', text);
                throw new Error('Invalid response format');
            }
            
            // Parse JSON response
            let data;
            try {
                data = await res.json();
            } catch (parseError) {
                console.error('JSON parse error:', parseError);
                throw new Error('Failed to parse server response');
            }
            
            // Check HTTP status
            if (!res.ok) {
                throw new Error(data.message || `HTTP error! status: ${res.status}`);
            }
            
            return data;
        })
        .then(data => {
            setLoading(false);
            setUpgradeModal(false);
            
            // Check if subscription was successfully activated (free or paid)
            if (data.success) {
                if (data.free) {
                    // Free subscription activated directly
                    toast.success(data.message || 'Subscription activated successfully!');
                    // Reload page data to show updated subscription
                    setTimeout(() => {
                        router.reload({ only: ['currentSubscription', 'plans'] });
                    }, 500);
                    return; // Exit early to prevent error message
                } else if (data.payment_url) {
                    // Open MyFatoorah payment page
                    window.open(data.payment_url, '_blank');
                    return; // Exit early
                } else {
                    // Success without payment URL (shouldn't happen, but handle gracefully)
                    toast.success(data.message || 'Subscription activated successfully!');
                    setTimeout(() => {
                        router.reload({ only: ['currentSubscription', 'plans'] });
                    }, 500);
                    return; // Exit early
                }
            }
            
            // Only show error if success is explicitly false
            console.error('Payment initiation failed:', data);
            toast.error(data.message || 'Payment initiation failed.');
        })
        .catch((error) => {
            console.error('Payment request failed:', error);
            setLoading(false);
            setUpgradeModal(false);
            
            // Only show error if it's not a successful free subscription
            // Check if subscription might have been created despite the error
            if (error.message && error.message.includes('JSON')) {
                // If JSON parsing failed, subscription might still be created
                // Reload to check subscription status
                setTimeout(() => {
                    router.reload({ only: ['currentSubscription', 'plans'] });
                }, 500);
            } else {
                toast.error(error.message || 'Payment initiation failed. Please try again.');
            }
        });
    };

    // Handler for upgrade
    const handleUpgrade = () => {
        if (!selectedPlan) return;
        setLoading(true);
        fetch('/vendor/subscribe/pay-with-myfatoorah', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'X-CSRF-TOKEN': (window as any).Laravel?.csrfToken || document.querySelector('meta[name="csrf-token"]')?.getAttribute('content') || '',
            },
            body: JSON.stringify({
                subscription_id: selectedPlan.id,
                price: prorationAmount,
                payment_method: paymentMethod,
                type: 'upgrade',
            }),
        })
        .then(async res => {
            const contentType = res.headers.get('content-type');
            if (!contentType || !contentType.includes('application/json')) {
                const text = await res.text();
                console.error('Non-JSON response:', text);
                throw new Error('Invalid response format');
            }
            
            if (!res.ok) {
                try {
                    const errorData = await res.json();
                    throw new Error(errorData.message || `HTTP error! status: ${res.status}`);
                } catch {
                    throw new Error(`HTTP error! status: ${res.status}`);
                }
            }
            return res.json();
        })
        .then(data => {
            setLoading(false);
            setUpgradeModal(false);
            
            if (data.success) {
                if (data.free) {
                    // Free subscription activated directly
                    toast.success(data.message || 'Subscription upgraded successfully!');
                    setTimeout(() => {
                        router.reload({ only: ['currentSubscription', 'plans'] });
                    }, 500);
                    return;
                } else if (data.payment_url) {
                    // Open MyFatoorah payment page
                    window.open(data.payment_url, '_blank');
                    return;
                } else {
                    toast.success(data.message || 'Subscription upgraded successfully!');
                    setTimeout(() => {
                        router.reload({ only: ['currentSubscription', 'plans'] });
                    }, 500);
                    return;
                }
            }
            
            console.error('Payment initiation failed:', data);
            toast.error(data.message || 'Payment initiation failed.');
        })
        .catch((error) => {
            console.error('Payment request failed:', error);
            setLoading(false);
            setUpgradeModal(false);
            
            if (error.message && error.message.includes('JSON')) {
                setTimeout(() => {
                    router.reload({ only: ['currentSubscription', 'plans'] });
                }, 500);
            } else {
                toast.error(error.message || 'Payment initiation failed. Please try again.');
            }
        });
    };

    // Handler for renewal
    const handleRenew = () => {
        setLoading(true);
        fetch('/vendor/subscribe/pay-with-myfatoorah', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'X-CSRF-TOKEN': (window as any).Laravel?.csrfToken || document.querySelector('meta[name="csrf-token"]')?.getAttribute('content') || '',
            },
            body: JSON.stringify({
                subscription_id: currentSubscription.id,
                price: currentSubscription.price,
                payment_method: paymentMethod,
                type: 'renew',
            }),
        })
        .then(async res => {
            const contentType = res.headers.get('content-type');
            if (!contentType || !contentType.includes('application/json')) {
                const text = await res.text();
                console.error('Non-JSON response:', text);
                throw new Error('Invalid response format');
            }
            
            if (!res.ok) {
                try {
                    const errorData = await res.json();
                    throw new Error(errorData.message || `HTTP error! status: ${res.status}`);
                } catch {
                    throw new Error(`HTTP error! status: ${res.status}`);
                }
            }
            return res.json();
        })
        .then(data => {
            setLoading(false);
            setRenewModal(false);
            
            if (data.success) {
                if (data.free) {
                    // Free subscription activated directly
                    toast.success(data.message || 'Subscription renewed successfully!');
                    setTimeout(() => {
                        router.reload({ only: ['currentSubscription', 'plans'] });
                    }, 500);
                    return;
                } else if (data.payment_url) {
                    window.open(data.payment_url, '_blank');
                    return;
                } else {
                    toast.success(data.message || 'Subscription renewed successfully!');
                    setTimeout(() => {
                        router.reload({ only: ['currentSubscription', 'plans'] });
                    }, 500);
                    return;
                }
            }
            
            console.error('Payment initiation failed:', data);
            toast.error(data.message || 'Payment initiation failed.');
        })
        .catch((error) => {
            console.error('Payment request failed:', error);
            setLoading(false);
            setRenewModal(false);
            
            if (error.message && error.message.includes('JSON')) {
                setTimeout(() => {
                    router.reload({ only: ['currentSubscription', 'plans'] });
                }, 500);
            } else {
                toast.error(error.message || 'Payment initiation failed. Please try again.');
            }
        });
    };

    return (
        <AppLayout>
            <Head title="Vendor Subscription" />
            <div className="max-w-full p-6">
                <h1 className="mb-4 text-2xl font-bold">{t('subscription.mySubscription')}</h1>
                <div className="mb-6 rounded border bg-white p-4 dark:bg-neutral-900">
                    <div className="flex items-center justify-between">
                        <div>
                            {currentSubscription ? (
                                <>
                                    <div className="font-semibold">{t('subscription.currentPlanLabel')} {currentSubscription.title}</div>
                                    <div>Expiry: {currentSubscription.expiry}</div>
                                    <div>
                                        Price: KWD {currentSubscription.price} / {currentSubscription.duration}
                                    </div>
                                </>
                            ) : (
                                <div className="text-gray-500">No active subscription</div>
                            )}
                        </div>
                        <div className="space-x-2">
                            <Button onClick={() => setRenewModal(true)} disabled={!currentSubscription}>
                                {t('subscription.renew')}
                            </Button>
                            <Button variant="destructive" onClick={() => setCancelModal(true)} disabled={!currentSubscription}>
                                {t('subscription.cancel')}
                            </Button>
                        </div>
                    </div>
                </div>
                <div className="mb-8 flex justify-center">
                    <div className="inline-flex rounded-full bg-gray-100 p-1">
                        <Button
                            variant={billingType === 'monthly' ? 'default' : 'ghost'}
                            onClick={() => setBillingType('monthly')}
                            className={`rounded-full px-6 py-2 text-base font-semibold ${billingType === 'monthly'
                                ? 'bg-black text-white hover:bg-black'
                                : 'text-gray-700 hover:bg-transparent hover:text-gray-700'
                                }`}
                        >
                            {t('subscription.monthly')}
                        </Button>
                        <Button
                            variant={billingType === 'yearly' ? 'default' : 'ghost'}
                            onClick={() => setBillingType('yearly')}
                            className={`rounded-full px-6 py-2 text-base font-semibold ${billingType === 'yearly'
                                ? 'bg-black text-white hover:bg-black'
                                : 'text-gray-700 hover:bg-transparent hover:text-gray-700'
                                }`}
                        >
                            {t('subscription.annually')}
                        </Button>
                    </div>
                </div>
                <div className="grid grid-cols-1 justify-center gap-8 md:grid-cols-3">
                    {filteredPlans.length > 0 ? (
                        filteredPlans.map((plan: any) => (
                            <div
                                key={plan.id}
                                className="flex flex-col justify-between rounded-xl border-2 border-gray-200 bg-white p-8 text-gray-800 shadow-lg transition-all duration-300 hover:scale-105 dark:border-[#262626] dark:bg-[#171717] dark:text-gray-100"
                            >
                                <div className="flex flex-1 flex-col items-center">
                                    {plan.image && <img src={plan.image} alt={plan.title} className="mb-6 h-20 w-20 object-contain" />}
                                    <div className="mb-2 text-3xl font-bold text-gray-900 dark:text-white">{plan.title}</div>
                                    <div
                                        className="mb-4 flex justify-center text-center text-base text-gray-600 dark:text-gray-400"
                                        dangerouslySetInnerHTML={{ __html: plan.description }}
                                    />
                                    {plan.features && (
                                        <div className="mb-4 w-full text-center text-base text-gray-700 dark:text-gray-300">
                                            <div className="mb-2 font-bold text-gray-800 dark:text-gray-200">What's included:</div>
                                            <ul className="flex list-none flex-col items-start max-w-[180px] mx-auto space-y-1">
                                                {(() => {
                                                    try {
                                                        const features = JSON.parse(plan.features);
                                                        if (Array.isArray(features)) {
                                                            return features
                                                                .filter((f: string) => f.trim() !== '')
                                                                .map((f: string, i: number) => (
                                                                    <li key={i} className="flex items-center justify-center gap-2 text-base">
                                                                        <Check className="h-4 w-4 text-blue-600 dark:text-blue-400" />
                                                                        <span>{f}</span>
                                                                    </li>
                                                                ));
                                                        }
                                                    } catch {
                                                        return plan.features
                                                            .split('\n')
                                                            .filter((f: string) => f.trim() !== '')
                                                            .map((f: string, i: number) => (
                                                                <li key={i} className="flex items-center justify-center gap-2 text-base">
                                                                    <Check className="h-4 w-4 text-blue-600 dark:text-blue-400" />
                                                                    <span>{f}</span>
                                                                </li>
                                                            ));
                                                    }
                                                    return null;
                                                })()}
                                            </ul>
                                        </div>
                                    )}
                                    <div className="mb-4 flex items-baseline gap-2">
                                        <span className="text-4xl font-extrabold text-blue-600 dark:text-blue-400">KWD {plan.price}</span>
                                        <span className="text-base font-normal text-gray-500 dark:text-gray-500">/{plan.duration}</span>
                                    </div>
                                </div>
                                <Button
                                    className={`mt-auto w-full py-6 text-base font-semibold ${currentSubscription && parseFloat(plan.price) <= parseFloat(currentSubscription.price)
                                        ? 'cursor-not-allowed bg-gray-300 text-gray-600 dark:bg-gray-700 dark:text-gray-500'
                                        : 'bg-blue-600 text-white hover:bg-blue-700 dark:hover:bg-blue-700'
                                        }`}
                                    disabled={currentSubscription && parseFloat(plan.price) <= parseFloat(currentSubscription.price)}
                                    onClick={() => {
                                        setSelectedPlan(plan);
                                        setUpgradeModal(true);
                                    }}
                                >
                                    {currentSubscription ? t('subscription.upgrade') : t('subscription.purchase')}
                                </Button>
                                {(plan.id === 'free' || plan.id === 'chatbots' || plan.id === 'communicator') && (
                                    <p className="mt-2 text-center text-xs text-gray-500 dark:text-gray-500">(no credit card required)</p>
                                )}
                            </div>
                        ))
                    ) : (
                        <div className="col-span-full text-center text-lg text-gray-500 dark:text-gray-400">No plans available</div>
                    )}
                </div>

                {/* Upgrade/Subscribe Modal */}
                <Dialog open={upgradeModal} onOpenChange={setUpgradeModal}>
                    <DialogContent>
                        <DialogHeader>
                            <DialogTitle>{currentSubscription ? t('subscription.upgradePlan') : t('subscription.subscribeToPlan')}</DialogTitle>
                        </DialogHeader>
                        {selectedPlan && (
                            <div>
                                <div>
                                    {currentSubscription ? t('subscription.upgradeTo') : t('subscription.subscribeTo')} <b>{selectedPlan.title}</b>?
                                </div>
                                <div>Price: {selectedPlan.price}</div>
                                {currentSubscription && (
                                    <>
                                        <div>
                                            Prorated Discount: {totalDays > 0 && remainingDays > 0
                                                ? Math.round((parseFloat(currentSubscription.price) / totalDays) * remainingDays)
                                                : 0}
                                        </div>
                                        <div className="font-semibold">
                                            Amount to Pay: {prorationAmount.toFixed(2)}
                                        </div>
                                    </>
                                )}
                            </div>
                        )}
                        {selectedPlan && (
                            <>
                                {currentSubscription ? (
                                    // For upgrades, check prorationAmount
                                    prorationAmount > 0 ? (
                                        <Select value={paymentMethod} onValueChange={setPaymentMethod}>
                                            <SelectTrigger className="mb-2 w-full">
                                                <SelectValue placeholder={t('subscription.selectPaymentMethod')} />
                                            </SelectTrigger>
                                            <SelectContent>
                                                <SelectItem value="knet">KNET</SelectItem>
                                                <SelectItem value="visa/master">VISA/MASTER</SelectItem>
                                            </SelectContent>
                                        </Select>
                                    ) : (
                                        <div className="mb-2 text-sm text-gray-600 dark:text-gray-400">
                                            No additional payment required for this upgrade.
                                        </div>
                                    )
                                ) : (
                                    // For new subscriptions, check plan price
                                    parseFloat(selectedPlan.price) > 0 ? (
                                        <Select value={paymentMethod} onValueChange={setPaymentMethod}>
                                            <SelectTrigger className="mb-2 w-full">
                                                <SelectValue placeholder={t('subscription.selectPaymentMethod')} />
                                            </SelectTrigger>
                                            <SelectContent>
                                                <SelectItem value="knet">KNET</SelectItem>
                                                <SelectItem value="visa/master">VISA/MASTER</SelectItem>
                                            </SelectContent>
                                        </Select>
                                    ) : (
                                        <div className="mb-2 text-sm text-gray-600 dark:text-gray-400">
                                            This is a free plan. No payment method required.
                                        </div>
                                    )
                                )}
                            </>
                        )}
                        <DialogFooter>
                            <Button onClick={() => setUpgradeModal(false)} variant="outline" disabled={loading}>
                                {t('common.cancel')}
                            </Button>
                            {currentSubscription ? (
                                <Button 
                                    onClick={handleUpgrade} 
                                    disabled={loading || (prorationAmount > 0 && !paymentMethod)}
                                >
                                    {loading ? t('subscription.processing') : t('subscription.confirmUpgrade')}
                                </Button>
                            ) : (
                                <Button 
                                    onClick={handleSubscribe} 
                                    disabled={loading || (parseFloat(selectedPlan?.price || '0') > 0 && !paymentMethod)}
                                >
                                    {loading ? t('subscription.processing') : t('subscription.confirmSubscription')}
                                </Button>
                            )}
                        </DialogFooter>
                    </DialogContent>
                </Dialog>

                {/* Renew Modal */}
                <Dialog open={renewModal} onOpenChange={setRenewModal}>
                    <DialogContent>
                        <DialogHeader>
                            <DialogTitle>{t('subscription.renewSubscription')}</DialogTitle>
                        </DialogHeader>
                        <div>{t('subscription.renewPlanMessage')}</div>
                        {currentSubscription && parseFloat(currentSubscription.price) > 0 && (
                            <Select value={paymentMethod} onValueChange={setPaymentMethod}>
                                <SelectTrigger className="mb-2 w-full">
                                    <SelectValue placeholder="Select Payment Method" />
                                </SelectTrigger>
                                <SelectContent>
                                    <SelectItem value="knet">KNET</SelectItem>
                                    <SelectItem value="visa/master">VISA/MASTER</SelectItem>
                                </SelectContent>
                            </Select>
                        )}
                        {currentSubscription && parseFloat(currentSubscription.price) <= 0 && (
                            <div className="mb-2 text-sm text-gray-600 dark:text-gray-400">
                                This is a free plan. No payment method required.
                            </div>
                        )}
                        <DialogFooter>
                            <Button onClick={() => setRenewModal(false)} variant="outline" disabled={loading}>
                                {t('common.cancel')}
                            </Button>
                            <Button 
                                onClick={handleRenew} 
                                disabled={loading || (currentSubscription && parseFloat(currentSubscription.price) > 0 && !paymentMethod)}
                            >
                                {loading ? t('subscription.processing') : t('subscription.confirmRenewal')}
                            </Button>
                        </DialogFooter>
                    </DialogContent>
                </Dialog>

                {/* Cancel Modal */}
                <Dialog open={cancelModal} onOpenChange={setCancelModal}>
                    <DialogContent>
                        <DialogHeader>
                            <DialogTitle>{t('subscription.cancelSubscription')}</DialogTitle>
                        </DialogHeader>
                        <div>Are you sure you want to cancel your subscription?</div>
                        <DialogFooter>
                            <Button onClick={() => setCancelModal(false)} variant="outline" disabled={loading}>
                                {t('common.cancel')}
                            </Button>
                            <Button onClick={() => {
                                setLoading(true);
                                router.post(
                                    '/vendor/subscription/cancel',
                                    {},
                                    {
                                        onFinish: () => {
                                            setLoading(false);
                                            setCancelModal(false);
                                        },
                                        onSuccess: () => router.reload(),
                                    },
                                );
                            }} variant="destructive" disabled={loading}>
                                {loading ? t('subscription.processing') : t('subscription.yesCancel')}
                            </Button>
                        </DialogFooter>
                    </DialogContent>
                </Dialog>
            </div>
        </AppLayout>
    );
}
