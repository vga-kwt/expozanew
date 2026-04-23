/* eslint-disable @typescript-eslint/no-explicit-any */
import { useLanguage } from '@/components/language-context';
import { Badge } from '@/components/ui/badge';
import { Button } from '@/components/ui/button';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { StatCard } from '@/components/ui/stat-card';
import { Link } from '@inertiajs/react';
import { Calendar, Clock, Folder, Shield, Wallet } from 'lucide-react';
import { MiniLineChart } from './mini-line-chart';

export function DashboardOverview({ vendor_dashboard, top_vendors }: { vendor_dashboard: any; top_vendors: any[] }) {
    const { t } = useLanguage();
    return (
        <div className="space-y-6">
            <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-3">
                <StatCard
                    title={t('vendor.accountVerificationStatus')}
                    value={
                        <span className="flex items-center gap-2">
                            {vendor_dashboard.kyc_status === 'approved' && (
                                <span className="inline-flex items-center gap-1">
                                    <Shield className="text-green-600 h-5 w-5" />
                                    <span>{t('vendor.verified')}</span>
                                </span>
                            )}
                            {vendor_dashboard.kyc_status === 'pending' && (
                                <span className="inline-flex items-center gap-1">
                                    <span className="text-yellow-500">⏳</span>
                                    <span>{t('vendor.pending')}</span>
                                </span>
                            )}
                            {vendor_dashboard.kyc_status === 'review' && (
                                <span className="inline-flex items-center gap-1">
                                    <span className="text-blue-500">📝</span>
                                    <span>{t('vendor.underReview')}</span>
                                </span>
                            )}
                            {vendor_dashboard.kyc_status === 'rejected' && (
                                <span className="inline-flex items-center gap-1">
                                    <span className="text-red-600">❌</span>
                                    <span>{t('vendor.rejected')}</span>
                                </span>
                            )}
                            {!['approved', 'pending', 'review', 'rejected'].includes(vendor_dashboard.kyc_status) && (
                                <span className="inline-flex items-center gap-1">
                                    <span className="text-gray-400">❔</span>
                                    <span>{t('vendor.unverified')}</span>
                                </span>
                            )}
                        </span>
                    }
                    icon={Shield}
                    description={
                        vendor_dashboard.kyc_status === 'approved' ? (
                            t('vendor.accountVerified')
                        ) : (
                            <div className="flex flex-col items-start gap-2">
                                <span>
                                    {vendor_dashboard.kyc_status === 'pending'
                                        ? t('vendor.verificationUnderReview')
                                        : vendor_dashboard.kyc_status === 'review'
                                            ? t('vendor.documentsBeingReviewed')
                                            : vendor_dashboard.kyc_status === 'rejected'
                                                ? t('vendor.verificationFailed')
                                                : t('vendor.verificationRequired')}
                                </span>
                                <a href="/vendor/kyc-status">
                                    <button
                                        type="button"
                                        className="inline-flex items-center px-3 py-1.5 text-sm font-medium text-primary-foreground bg-primary hover:bg-primary/90 dark:bg-primary dark:text-primary-foreground dark:hover:bg-primary/90 rounded-md transition cursor-pointer shadow-sm"
                                    >
                                        {vendor_dashboard.kyc_status === 'rejected'
                                            ? t('vendor.updateKycDocs')
                                            : t('vendor.submitKycDocs')}
                                    </button>
                                </a>
                            </div>
                        )
                    }
                />


                <StatCard
                    title={t('vendor.activeSubscriptionPlan')}
                    value={
                        <div className="flex flex-col items-start">
                            <span className="font-semibold">{vendor_dashboard.subscription?.plan_name || t('vendor.noActivePlan')}</span>
                            {vendor_dashboard.subscription?.expiry_date && (
                                <span className="text-muted-foreground text-xs">
                                    {t('vendor.validTill')}{' '}
                                    {new Date(vendor_dashboard.subscription.expiry_date).toLocaleDateString(undefined, {
                                        year: 'numeric',
                                        month: 'long',
                                        day: 'numeric',
                                    })}
                                </span>
                            )}
                        </div>
                    }
                    icon={Folder}
                    description={
                        <Button asChild size="sm" variant="outline" className="mt-2">
                            <Link href="/vendor/subscription">{vendor_dashboard.subscription_plan?.can_renew ? t('vendor.renew') : t('vendor.upgrade')}</Link>
                        </Button>
                    }
                />
                <StatCard
                    title={t('vendor.totalSalesThisMonth')}
                    value={
                        <div className="flex flex-col items-start">
                            <span className="text-2xl font-bold">
                                {vendor_dashboard.total_sales?.toLocaleString('en-IN', { minimumFractionDigits: 0 })}
                            </span>
                            <span className="mt-1 flex items-center text-sm font-medium text-green-600">
                                +{vendor_dashboard.sales_growth_percent ?? 10}%&nbsp;
                                <span className="text-muted-foreground font-normal">{t('vendor.fromLastMonth')}</span>
                            </span>
                            <div className="mt-2 h-8 w-full">
                                <MiniLineChart data={vendor_dashboard.sales_trend ?? []} />
                            </div>
                        </div>
                    }
                    icon={Wallet}
                    description={t('vendor.revenueFromCompletedOrders')}
                />
                <StatCard
                    title={t('vendor.expoParticipationStatus')}
                    icon={Calendar}
                    value={
                        <div className="flex flex-col gap-2">
                            {(vendor_dashboard.expos?.length > 0 ? vendor_dashboard.expos.slice(0, 2) : []).map((expo: any) => (
                                <div
                                    key={expo.id}
                                    className="bg-muted/50 flex flex-col gap-1 rounded-md border p-2 md:flex-row md:items-center md:gap-3"
                                >
                                    <div className="flex items-center gap-2">
                                        <Calendar className="text-muted-foreground h-4 w-4" />
                                        <span className="text-base font-semibold">{expo.name}</span>
                                        <Badge
                                            variant={
                                                expo.status === 'active'
                                                    ? 'default'
                                                    : expo.status === 'upcoming'
                                                        ? 'secondary'
                                                        : expo.status === 'expired'
                                                            ? 'destructive'
                                                            : expo.status === 'inactive'
                                                                ? 'outline'
                                                                : expo.status === 'suspended'
                                                                    ? 'destructive'
                                                                    : 'outline'
                                            }
                                        >
                                            {expo.status.charAt(0).toUpperCase() + expo.status.slice(1)}
                                        </Badge>
                                    </div>
                                    <div className="text-muted-foreground ml-6 flex items-center gap-2 text-xs md:ml-0">
                                        <Clock className="h-3 w-3" />

                                        <span className="text-muted-foreground ml-2 text-xs">
                                            (
                                            {new Date(expo.start_date).toLocaleDateString('en-IN', {
                                                day: '2-digit',
                                                month: 'short',
                                                year: 'numeric',
                                            })}{' '}
                                            -{' '}
                                            {new Date(expo.end_date).toLocaleDateString('en-IN', { day: '2-digit', month: 'short', year: 'numeric' })}
                                            )
                                        </span>
                                    </div>
                                </div>
                            ))}
                        </div>
                    }
                    description={
                        vendor_dashboard.expos?.length > 0 ? (
                            <Button asChild size="sm" variant="outline" className="mt-2">
                                <Link href="/vendor/expos">{t('vendor.viewMyExpos')}</Link>
                            </Button>
                        ) : (
                            <span className="text-muted-foreground">{t('vendor.noCurrentExpos')}</span>
                        )
                    }
                />
                <Card>
                    <CardHeader>
                        <CardTitle>{t('dashboard.topVendorsBySales')}</CardTitle>
                    </CardHeader>
                    <CardContent>
                        {top_vendors && top_vendors.length > 0 ? (
                            <table className="min-w-full rounded border text-sm">
                                <thead>
                                    <tr className="bg-muted">
                                        <th className="px-3 py-2 text-left">{t('dashboard.rank')}</th>
                                        <th className="px-3 py-2 text-left">{t('dashboard.brandNameEn')}</th>
                                        <th className="px-3 py-2 text-left">{t('dashboard.sales')}</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    {top_vendors.slice(0, 5).map((vendor, idx) => (
                                        <tr key={vendor.id} className="border-b last:border-b-0">
                                            <td className="px-3 py-2">
                                                {idx === 0 && (
                                                    <span role="img" aria-label="gold">
                                                        🥇
                                                    </span>
                                                )}
                                                {idx === 1 && (
                                                    <span role="img" aria-label="silver">
                                                        🥈
                                                    </span>
                                                )}
                                                {idx === 2 && (
                                                    <span role="img" aria-label="bronze">
                                                        🥉
                                                    </span>
                                                )}
                                                {idx === 3 && (
                                                    <span role="img" aria-label="medal">
                                                        🎖️
                                                    </span>
                                                )}
                                                {idx === 4 && (
                                                    <span role="img" aria-label="medal">
                                                        🏅
                                                    </span>
                                                )}
                                            </td>
                                            <td className="px-3 py-2">{vendor.brand_name_en || vendor.name_en}</td>
                                            <td className="px-3 py-2">
                                                {Number(vendor.revenue).toLocaleString('en-IN', { minimumFractionDigits: 0 })}
                                            </td>
                                        </tr>
                                    ))}
                                </tbody>
                            </table>
                        ) : (
                            <div className="text-muted-foreground text-xs">{t('dashboard.noTopVendors')}</div>
                        )}
                        {vendor_dashboard?.vendor_rank && (
                            <div className="mt-4 text-center text-sm">
                                {t('dashboard.youAreRanked')} <span className="font-bold">#{vendor_dashboard.vendor_rank}</span> {t('dashboard.thisMonthSuffix')}
                            </div>
                        )}
                    </CardContent>
                </Card>
            </div>
        </div>
    );
}
