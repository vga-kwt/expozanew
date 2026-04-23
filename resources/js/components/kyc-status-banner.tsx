import { useLanguage } from '@/components/language-context';
import { Badge } from '@/components/ui/badge';
import { Button } from '@/components/ui/button';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Link } from '@inertiajs/react';
import { AlertTriangle, CheckCircle, Clock, FileText, XCircle } from 'lucide-react';

interface KYCStatusBannerProps {
    kycStatus: string;
    kycRejectionReason?: string;
    isVendor: boolean;
}

export function KYCStatusBanner({ kycStatus, kycRejectionReason, isVendor }: KYCStatusBannerProps) {
    const { t } = useLanguage();
    if (!isVendor) return null;

    if (kycStatus === 'approved') {
        return null;
    }

    const getStatusConfig = (status: string) => {
        switch (status) {

            case 'approved':
                return {
                    icon: CheckCircle,
                    color: 'text-green-600',
                    bgColor: 'bg-green-50',
                    borderColor: 'border-green-200',
                    title: t('kyc.approved'),
                    description: t('kyc.approvedDesc'),
                    badgeVariant: 'default',
                };

            case 'pending':
                return {
                    icon: Clock,
                    color: 'text-yellow-600',
                    bgColor: 'bg-yellow-50',
                    borderColor: 'border-yellow-200',
                    title: t('kyc.pending'),
                    description: t('kyc.pendingDesc'),
                    badgeVariant: 'secondary',
                };

            case 'review':
                return {
                    icon: Clock,
                    color: 'text-yellow-600',
                    bgColor: 'bg-yellow-50',
                    borderColor: 'border-yellow-200',
                    title: t('kyc.review'),
                    description: t('kyc.reviewDesc'),
                    badgeVariant: 'secondary',
                };

            case 'rejected':
                return {
                    icon: XCircle,
                    color: 'text-red-600',
                    bgColor: 'bg-red-50',
                    borderColor: 'border-red-200',
                    title: t('kyc.rejected'),
                    description: kycRejectionReason || t('kyc.rejectedDesc'),
                    badgeVariant: 'destructive',
                };

            default:
                return {
                    icon: AlertTriangle,
                    color: 'text-gray-600',
                    bgColor: 'bg-card',
                    borderColor: 'border-gray-200',
                    title: t('kyc.notSubmitted'),
                    description: t('kyc.notSubmittedDesc'),
                    badgeVariant: 'outline',
                };
        }
    };

    const config = getStatusConfig(kycStatus);
    const Icon = config.icon;

    return (
        <Card className={`${config.bgColor} ${config.borderColor} border`}>
            <CardHeader className="pb-3">
                <div className="flex items-center justify-between">
                    <div className="flex items-center space-x-2">
                        <Icon className={`h-5 w-5 ${config.color}`} />
                        <CardTitle className={`text-lg ${config.color}`}>{config.title}</CardTitle>
                    </div>
                    <Badge variant={config.badgeVariant}>{kycStatus.toUpperCase()}</Badge>
                </div>
            </CardHeader>
            <CardContent>
                <p className="text-card-foreground mb-4 text-sm">{config.description}</p>

                {kycStatus === 'rejected' && (
                    <div className="mb-4 rounded-lg border border-red-300 bg-red-100 p-3">
                        <h4 className="mb-2 font-medium text-red-800">{t('kyc.rejectionReason')}</h4>
                        <p className="text-sm text-red-700">{kycRejectionReason}</p>
                    </div>
                )}

                <div className="flex flex-wrap gap-2">
                    {kycStatus === 'not_submitted' && (
                        <Button asChild size="sm">
                            <Link href="/vendor/kyc">
                                <FileText className="mr-2 h-4 w-4" />
                                {t('kyc.submitKycDocuments')}
                            </Link>
                        </Button>
                    )}

                    {kycStatus === 'rejected' && (
                        <Button asChild size="sm">
                            <Link href="/vendor/kyc">
                                <FileText className="mr-2 h-4 w-4" />
                                {t('kyc.resubmitKyc')}
                            </Link>
                        </Button>
                    )}

                    {kycStatus === 'pending' && (
                        <div className="text-sm text-gray-600">
                            <p>• {t('kyc.noProductsUntilApproved')}</p>
                            <p>• {t('kyc.noExposUntilApproved')}</p>
                            <p>• {t('kyc.noAdsUntilApproved')}</p>
                        </div>
                    )}

                    {kycStatus === 'approved' && (
                        <div className="text-sm text-green-700">
                            <p>✓ {t('kyc.canCreateProducts')}</p>
                            <p>✓ {t('kyc.canJoinExpos')}</p>
                            <p>✓ {t('kyc.canCreateAds')}</p>
                        </div>
                    )}
                </div>
            </CardContent>
        </Card>
    );
}
