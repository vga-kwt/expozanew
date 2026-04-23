import { useLanguage } from '@/components/language-context';
import { type BreadcrumbItem, type SharedData } from '@/types';
import { Head, useForm, usePage, router } from '@inertiajs/react';
import { FormEventHandler, useState } from 'react';
import { Shield, Upload, FileText, AlertCircle, CheckCircle, XCircle, Clock, Edit } from 'lucide-react';

import HeadingSmall from '@/components/heading-small';
import InputError from '@/components/input-error';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Badge } from '@/components/ui/badge';
import { Alert, AlertDescription } from '@/components/ui/alert';
import { Dialog, DialogContent, DialogDescription, DialogHeader, DialogTitle } from '@/components/ui/dialog';
import AppLayout from '@/layouts/app-layout';
import toast from 'react-hot-toast';

const getBreadcrumbs = (t: (k: string) => string): BreadcrumbItem[] => [
    { title: t('vendor.kycStatus'), href: '/vendor/profile/kyc-status' },
];

interface KYCStatusProps {
    kyc_status: string;
    kyc_rejection_reason_en?: string;
    kyc_documents?: {
        civil_id?: string;
        commercial_license?: string;
        iban_certificate?: string;
        civil_id_url?: string;
        commercial_license_url?: string;
        iban_certificate_url?: string;
    };
}

export default function KYCStatus({ kyc_status, kyc_rejection_reason_en, kyc_documents }: KYCStatusProps) {
    // REVIEW: KYCStatus component for displaying and managing vendor KYC status and document submission.
    // Uses shadcn UI components for consistent styling.
    // Handles file uploads for Civil ID and Address Proof, and displays current KYC status with contextual feedback.
    // Statuses: approved, pending (review), rejected, unknown.
    // If rejected, shows rejection reason and allows resubmission.
    // If pending (review), disables resubmission and informs user.
    // If approved, disables resubmission and shows success.
    // If unknown, prompts user to contact support.

    // Note: The backend expects 'pending' or 'review' as status for under-review. Adjust as needed.

    const [civilIdFile, setCivilIdFile] = useState<File | null>(null);
    const [commercialLicenseFile, setCommercialLicenseFile] = useState<File | null>(null);
    const [ibanCertificateFile, setIbanCertificateFile] = useState<File | null>(null);
    
    // Update document modal state
    const [updateDocumentType, setUpdateDocumentType] = useState<'civil_id' | 'commercial_license' | 'iban_certificate' | null>(null);
    const [updateDocumentFile, setUpdateDocumentFile] = useState<File | null>(null);
    const [isUpdateModalOpen, setIsUpdateModalOpen] = useState(false);
    const [isUpdating, setIsUpdating] = useState(false);

    const { data, setData, post, errors, processing } = useForm({
        civil_id: null as File | null,
        commercial_license: null as File | null,
        iban_certificate: null as File | null,
    });

    const getKYCStatusIcon = (status: string) => {
        switch (status) {
            case 'approved': return <CheckCircle className="h-8 w-8 text-green-500" />;
            case 'pending':
            case 'review':
                return <Clock className="h-8 w-8 text-yellow-500" />;
            case 'rejected': return <XCircle className="h-8 w-8 text-red-500" />;
            default: return <AlertCircle className="h-8 w-8 text-gray-500" />;
        }
    };

    const getKYCStatusColor = (status: string) => {
        switch (status) {
            case 'approved': return 'bg-green-100 text-green-800';
            case 'pending':
            case 'review':
                return 'bg-yellow-100 text-yellow-800';
            case 'rejected': return 'bg-red-100 text-red-800';
            default: return 'bg-gray-100 text-gray-800';
        }
    };

    const { t } = useLanguage();
    const getKYCStatusMessage = (status: string) => {
        switch (status) {
            case 'approved':
                return t('vendor.kycApprovedMessage');
            case 'pending':
            case 'review':
                return t('vendor.kycPendingMessage');
            case 'rejected':
                return t('vendor.kycRejectedMessage');
            default:
                return t('vendor.kycUnknownMessage');
        }
    };

    const handleFileChange = (field: 'civil_id' | 'commercial_license' | 'iban_certificate', file: File | null) => {
        setData(field, file);
        if (field === 'civil_id') setCivilIdFile(file);
        if (field === 'commercial_license') setCommercialLicenseFile(file);
        if (field === 'iban_certificate') setIbanCertificateFile(file);
    };

    const submit: FormEventHandler = (e) => {
        e.preventDefault();

        if (!data.civil_id || !data.commercial_license || !data.iban_certificate) {
            alert(t('vendor.selectAllDocuments'));
            return;
        }

        const formData = new FormData();
        formData.append('civil_id', data.civil_id);
        formData.append('commercial_license', data.commercial_license);
        formData.append('iban_certificate', data.iban_certificate);

        post(route('vendor.profile.resend-kyc'), {
            forceFormData: true,
            onSuccess: () => {
                setCivilIdFile(null);
                setCommercialLicenseFile(null);
                setIbanCertificateFile(null);
                setData('civil_id', null);
                setData('commercial_license', null);
                setData('iban_certificate', null);
            },
        });
    };

    const handleUpdateDocument = (documentType: 'civil_id' | 'commercial_license' | 'iban_certificate') => {
        setUpdateDocumentType(documentType);
        setUpdateDocumentFile(null);
        setIsUpdateModalOpen(true);
    };

    const submitUpdateDocument = async () => {
        if (!updateDocumentType || !updateDocumentFile) {
            toast.error(t('vendor.selectFileToUpdate'));
            return;
        }

        setIsUpdating(true);
        const formData = new FormData();
        formData.append('document_type', updateDocumentType);
        formData.append('document', updateDocumentFile);

        try {
            const response = await fetch(route('vendor.profile.update-kyc-document'), {
                method: 'POST',
                headers: {
                    'X-CSRF-TOKEN': document.querySelector('meta[name="csrf-token"]')?.getAttribute('content') || '',
                },
                body: formData,
            });

            const result = await response.json();

            if (response.ok && result.success) {
                toast.success(result.message || 'Document updated successfully');
                setIsUpdateModalOpen(false);
                setUpdateDocumentFile(null);
                setUpdateDocumentType(null);
                router.reload();
            } else {
                toast.error(result.error || result.message || 'Failed to update document');
            }
        } catch (error) {
            toast.error('An error occurred while updating the document');
        } finally {
            setIsUpdating(false);
        }
    };

    return (
        <AppLayout breadcrumbs={getBreadcrumbs(t)}>
            <Head title={t('vendor.kycStatus')} />

            <div className="space-y-6 p-6">
                <HeadingSmall
                    title={t('vendor.kycStatus')}
                    description={t('vendor.kycStatusDescription')}
                />

                {/* Current Status */}
                <Card>
                    <CardHeader>
                        <CardTitle className="flex items-center gap-2">
                            <Shield className="h-5 w-5" />
                            {t('vendor.currentKycStatus')}
                        </CardTitle>
                    </CardHeader>
                    <CardContent className="space-y-4">
                        <div className="flex items-center gap-4">
                            {getKYCStatusIcon(kyc_status)}
                            <div>
                                <Badge className={getKYCStatusColor(kyc_status)}>
                                    {kyc_status.charAt(0).toUpperCase() + kyc_status.slice(1)}
                                </Badge>
                                <p className="mt-1 text-sm text-gray-600">
                                    {getKYCStatusMessage(kyc_status)}
                                </p>
                            </div>
                        </div>

                        {kyc_status === 'rejected' && kyc_rejection_reason_en && (
                            <Alert className="border-red-200 bg-red-50">
                                <AlertCircle className="h-4 w-4" />
                                <AlertDescription>
                                    <strong>{t('kyc.rejectionReason')}</strong> {kyc_rejection_reason_en}
                                </AlertDescription>
                            </Alert>
                        )}
                    </CardContent>
                </Card>

                {/* Current Documents */}
                {kyc_documents && (kyc_documents.civil_id || kyc_documents.commercial_license || kyc_documents.iban_certificate) && (
                    <Card>
                        <CardHeader>
                            <CardTitle className="flex items-center gap-2">
                                <FileText className="h-5 w-5" />
                                {t('vendor.currentDocuments')}
                            </CardTitle>
                            <CardDescription>
                                {t('vendor.documentsSubmittedDesc')}
                            </CardDescription>
                        </CardHeader>
                        <CardContent className="space-y-4">
                            {kyc_documents.civil_id && (
                                <div className="flex items-center justify-between p-3 border rounded-lg">
                                    <div>
                                        <p className="font-medium">{t('vendor.civilId')}</p>
                                        <p className="text-sm text-gray-500">{t('vendor.submittedForVerification')}</p>
                                    </div>
                                    <div className="flex items-center gap-2">
                                        <Button
                                            asChild
                                            variant="outline"
                                            size="sm"
                                        >
                                            <a href={kyc_documents.civil_id_url} target="_blank" rel="noopener noreferrer">
                                                {t('vendor.view')}
                                            </a>
                                        </Button>
                                        <Button
                                            variant="outline"
                                            size="sm"
                                            onClick={() => handleUpdateDocument('civil_id')}
                                        >
                                            <Edit className="h-4 w-4 mr-1" />
                                            {t('vendor.update')}
                                        </Button>
                                    </div>
                                </div>
                            )}

                            {kyc_documents.commercial_license && (
                                <div className="flex items-center justify-between p-3 border rounded-lg">
                                    <div>
                                        <p className="font-medium">{t('vendor.commercialLicense')}</p>
                                        <p className="text-sm text-gray-500">{t('vendor.submittedForVerification')}</p>
                                    </div>
                                    <div className="flex items-center gap-2">
                                        <Button
                                            asChild
                                            variant="outline"
                                            size="sm"
                                        >
                                            <a href={kyc_documents.commercial_license_url} target="_blank" rel="noopener noreferrer">
                                                {t('vendor.view')}
                                            </a>
                                        </Button>
                                        <Button
                                            variant="outline"
                                            size="sm"
                                            onClick={() => handleUpdateDocument('commercial_license')}
                                        >
                                            <Edit className="h-4 w-4 mr-1" />
                                            {t('vendor.update')}
                                        </Button>
                                    </div>
                                </div>
                            )}

                            {kyc_documents.iban_certificate && (
                                <div className="flex items-center justify-between p-3 border rounded-lg">
                                    <div>
                                        <p className="font-medium">{t('vendor.ibanCertificate')}</p>
                                        <p className="text-sm text-gray-500">{t('vendor.submittedForVerification')}</p>
                                    </div>
                                    <div className="flex items-center gap-2">
                                        <Button
                                            asChild
                                            variant="outline"
                                            size="sm"
                                        >
                                            <a href={kyc_documents.iban_certificate_url} target="_blank" rel="noopener noreferrer">
                                                {t('vendor.view')}
                                            </a>
                                        </Button>
                                        <Button
                                            variant="outline"
                                            size="sm"
                                            onClick={() => handleUpdateDocument('iban_certificate')}
                                        >
                                            <Edit className="h-4 w-4 mr-1" />
                                            {t('vendor.update')}
                                        </Button>
                                    </div>
                                </div>
                            )}
                        </CardContent>
                    </Card>
                )}

                {/* KYC Requirements */}
                <Card>
                    <CardHeader>
                        <CardTitle>{t('vendor.kycRequirements')}</CardTitle>
                        <CardDescription>
                            {t('vendor.kycRequirementsDesc')}
                        </CardDescription>
                    </CardHeader>
                    <CardContent className="space-y-4">
                        <div className="space-y-3">
                            <div className="flex items-start gap-3">
                                <div className="w-2 h-2 bg-blue-500 rounded-full mt-2"></div>
                                <div>
                                    <p className="font-medium">{t('vendor.civilId')}</p>
                                    <p className="text-sm text-gray-600">{t('vendor.civilIdRequirement')}</p>
                                </div>
                            </div>

                            <div className="flex items-start gap-3">
                                <div className="w-2 h-2 bg-blue-500 rounded-full mt-2"></div>
                                <div>
                                    <p className="font-medium">{t('vendor.commercialLicense')}</p>
                                    <p className="text-sm text-gray-600">{t('vendor.commercialLicenseRequirement')}</p>
                                </div>
                            </div>

                            <div className="flex items-start gap-3">
                                <div className="w-2 h-2 bg-blue-500 rounded-full mt-2"></div>
                                <div>
                                    <p className="font-medium">{t('vendor.ibanCertificate')}</p>
                                    <p className="text-sm text-gray-600">{t('vendor.ibanCertRequirement')}</p>
                                </div>
                            </div>
                        </div>

                        <Alert>
                            <AlertCircle className="h-4 w-4" />
                            <AlertDescription>
                                {t('vendor.importantNote')}
                            </AlertDescription>
                        </Alert>
                    </CardContent>
                </Card>

                {/* Upload/Resubmit Documents or Status Message */}
                {(kyc_status === 'rejected' || kyc_status === 'pending') && (
                    <Card>
                        <CardHeader>
                            <CardTitle className="flex items-center gap-2">
                                <Upload className="h-5 w-5" />
                                {t('vendor.submitDocuments')}
                            </CardTitle>
                            <CardDescription>
                                {t('vendor.pleaseUploadDesc')}
                            </CardDescription>
                        </CardHeader>
                        <CardContent>
                            {kyc_status === 'rejected' && (
                                <Alert className="border-yellow-200 bg-yellow-50 mb-4">
                                    <AlertCircle className="h-4 w-4" />
                                    <AlertDescription>
                                        <strong>Your KYC was rejected.</strong>
                                        {kyc_rejection_reason_en && (
                                            <>
                                                <br />
                                                <span>
                                                    <strong>Reason:</strong> {kyc_rejection_reason_en}
                                                </span>
                                            </>
                                        )}
                                        <br />
                                        Please fix the issues mentioned above and resubmit your documents.
                                    </AlertDescription>
                                </Alert>
                            )}

                            <div className="mb-6">
                                <h3 className="text-lg font-semibold mb-2 flex items-center gap-2">
                                    <Upload className="h-5 w-5" />
                                    {t('vendor.uploadRequiredDocuments')}
                                </h3>
                                <p className="text-sm text-gray-500 mb-6">
                                    {t('vendor.pleaseUploadClearDocs')}
                                </p>
                            </div>

                            <form onSubmit={submit} className="space-y-6">
                                <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
                                    {/* Civil ID */}
                                    <div className="space-y-2">
                                        <Label htmlFor="civil_id" className="flex items-center gap-2 text-sm font-medium">
                                            <FileText className="h-4 w-4" />
                                            {t('vendor.civilId')} <span className="text-red-500">*</span>
                                        </Label>
                                        <Input
                                            id="civil_id"
                                            type="file"
                                            accept=".pdf,.jpg,.jpeg,.png"
                                            onChange={(e) => handleFileChange('civil_id', e.target.files?.[0] || null)}
                                            required
                                            className="cursor-pointer"
                                        />
                                        <div className="mt-2 min-h-[24px]">
                                            {civilIdFile && (
                                                <Badge variant="outline" className="text-green-700 border-green-300 bg-green-50 text-xs">
                                                    {civilIdFile.name}
                                                </Badge>
                                            )}
                                        </div>
                                        <p className="text-xs text-gray-500 mt-1">
                                            {t('vendor.acceptedFormats')}
                                        </p>
                                        <InputError message={errors.civil_id} className="mt-1" />
                                    </div>

                                    {/* Commercial License */}
                                    <div className="space-y-2">
                                        <Label htmlFor="commercial_license" className="flex items-center gap-2 text-sm font-medium">
                                            <FileText className="h-4 w-4" />
                                            {t('vendor.commercialLicense')} <span className="text-red-500">*</span>
                                        </Label>
                                        <Input
                                            id="commercial_license"
                                            type="file"
                                            accept=".pdf,.jpg,.jpeg,.png"
                                            onChange={(e) => handleFileChange('commercial_license', e.target.files?.[0] || null)}
                                            required
                                            className="cursor-pointer"
                                        />
                                        <div className="mt-2 min-h-[24px]">
                                            {commercialLicenseFile && (
                                                <Badge variant="outline" className="text-green-700 border-green-300 bg-green-50 text-xs">
                                                    {commercialLicenseFile.name}
                                                </Badge>
                                            )}
                                        </div>
                                        <p className="text-xs text-gray-500 mt-1">
                                            {t('vendor.acceptedFormats')}
                                        </p>
                                        <InputError message={errors.commercial_license} className="mt-1" />
                                    </div>

                                    {/* IBAN Certificate */}
                                    <div className="space-y-2">
                                        <Label htmlFor="iban_certificate" className="flex items-center gap-2 text-sm font-medium">
                                            <FileText className="h-4 w-4" />
                                            {t('vendor.ibanCertificate')} <span className="text-red-500">*</span>
                                        </Label>
                                        <Input
                                            id="iban_certificate"
                                            type="file"
                                            accept=".pdf,.jpg,.jpeg,.png"
                                            onChange={(e) => handleFileChange('iban_certificate', e.target.files?.[0] || null)}
                                            required
                                            className="cursor-pointer"
                                        />
                                        <div className="mt-2 min-h-[24px]">
                                            {ibanCertificateFile && (
                                                <Badge variant="outline" className="text-green-700 border-green-300 bg-green-50 text-xs">
                                                    {ibanCertificateFile.name}
                                                </Badge>
                                            )}
                                        </div>
                                        <p className="text-xs text-gray-500 mt-1">
                                            {t('vendor.acceptedFormats')}
                                        </p>
                                        <InputError message={errors.iban_certificate} className="mt-1" />
                                    </div>
                                </div>

                                <Button type="submit" disabled={processing} className="w-full mt-4 flex items-center gap-2">
                                    <Upload className="h-4 w-4" />
                                    {processing ? t('common.loading') : t('vendor.submitDocuments')}
                                </Button>
                            </form>
                        </CardContent>
                    </Card>
                )}

                {(kyc_status === 'pending' || kyc_status === 'review') && (
                    <Card>
                        <CardHeader>
                            <CardTitle className="flex items-center gap-2">
                                <Upload className="h-5 w-5" />
                                {t('vendor.kycUnderReview')}
                            </CardTitle>
                            <CardDescription>
                                {t('vendor.kycUnderReviewDesc')}
                            </CardDescription>
                        </CardHeader>
                    </Card>
                )}

                {/* Update Document Modal */}
                <Dialog open={isUpdateModalOpen} onOpenChange={setIsUpdateModalOpen}>
                    <DialogContent>
                        <DialogHeader>
                            <DialogTitle>
                                {t('vendor.updateDocument')} {updateDocumentType ? (updateDocumentType === 'civil_id' ? t('vendor.civilId') : updateDocumentType === 'commercial_license' ? t('vendor.commercialLicense') : t('vendor.ibanCertificate')) : ''}
                            </DialogTitle>
                            <DialogDescription>
                                {t('vendor.updateDocumentDesc')}
                            </DialogDescription>
                        </DialogHeader>
                        <div className="space-y-4">
                            <div className="space-y-2">
                                <Label htmlFor="update-document" className="flex items-center gap-2 text-sm font-medium">
                                    <FileText className="h-4 w-4" />
                                    {t('vendor.selectNewDocument')} <span className="text-red-500">*</span>
                                </Label>
                                <Input
                                    id="update-document"
                                    type="file"
                                    accept=".pdf,.jpg,.jpeg,.png"
                                    onChange={(e) => setUpdateDocumentFile(e.target.files?.[0] || null)}
                                    className="cursor-pointer"
                                />
                                {updateDocumentFile && (
                                    <Badge variant="outline" className="text-green-700 border-green-300 bg-green-50 text-xs">
                                        {updateDocumentFile.name}
                                    </Badge>
                                )}
                                <p className="text-xs text-gray-500 mt-1">
                                    {t('vendor.acceptedFormats')}
                                </p>
                            </div>
                            <div className="flex justify-end gap-2">
                                <Button
                                    variant="outline"
                                    onClick={() => {
                                        setIsUpdateModalOpen(false);
                                        setUpdateDocumentFile(null);
                                        setUpdateDocumentType(null);
                                    }}
                                >
                                    {t('common.cancel')}
                                </Button>
                                <Button
                                    onClick={submitUpdateDocument}
                                    disabled={isUpdating || !updateDocumentFile}
                                >
                                    {isUpdating ? t('common.loading') : t('vendor.updateDocument')}
                                </Button>
                            </div>
                        </div>
                    </DialogContent>
                </Dialog>
               
            </div>
        </AppLayout>
    );
} 