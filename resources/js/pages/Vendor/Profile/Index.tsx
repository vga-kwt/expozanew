import HeadingSmall from '@/components/heading-small';
import InputError from '@/components/input-error';
import { useLanguage } from '@/components/language-context';
import GoogleMapPicker from '@/components/GoogleMapPicker';
import { Alert, AlertDescription } from '@/components/ui/alert';
import { Badge } from '@/components/ui/badge';
import { Button } from '@/components/ui/button';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Dialog, DialogContent, DialogDescription, DialogFooter, DialogHeader, DialogTitle, DialogTrigger } from '@/components/ui/dialog';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select';
import AppLayout from '@/layouts/app-layout';
import { type BreadcrumbItem, type SharedData } from '@/types';
import { Transition } from '@headlessui/react';
import { Head, Link, router, useForm, usePage } from '@inertiajs/react';
import { Eye, EyeOff, Key, Shield, Trash2, Upload, User, MapPin } from 'lucide-react';
import { FormEventHandler, useRef, useState } from 'react';
import toast from 'react-hot-toast';
import ReactQuillWrapper from '@/components/ReactQuillWrapper';
import { useOtp } from '@/hooks/use-otp';

const getBreadcrumbs = (t: (k: string) => string): BreadcrumbItem[] => [
    { title: t('vendor.profileManagement'), href: '/vendor/profile' },
];

interface Vendor {
    id: number;
    name: string;
    brand_name_en?: string;
    brand_name_ar?: string;
    email: string;
    phone?: string;
    mobile?: string;
    description_en?: string;
    description_ar?: string;
    logo?: string;
    kyc_status: string;
    kyc_rejection_reason?: string;
    use_armada_delivery?: boolean;
    latitude?: number | null;
    longitude?: number | null;
    address_text?: string;
}

interface Address {
    id?: number;
    full_name?: string;
    phone?: string;
    line_1?: string;
    line_2?: string;
    country_id?: number;
    state_id?: number;
    city_id?: number;
    pincode?: string;
    country?: { id: number; name_en: string; name_ar: string };
    state?: { id: number; name_en: string; name_ar: string };
    city?: { id: number; name_en: string; name_ar: string };
}

interface Country {
    id: number;
    name_en: string;
    name_ar: string;
}

interface State {
    id: number;
    name_en: string;
    name_ar: string;
    country_id: number;
}

interface City {
    id: number;
    name_en: string;
    name_ar: string;
    country_id: number;
    state_id: number;
}

export default function VendorProfileIndex({
    vendor,
    kyc_status,
    kyc_rejection_reason,
    user,
    address,
    countries,
    states,
    cities,
}: {
    vendor: Vendor;
    kyc_status: string;
    kyc_rejection_reason?: string;
    user: any;
    address?: Address;
    countries?: Country[];
    states?: State[];
    cities?: City[];
}) {
    const { t } = useLanguage();
    const { flash } = usePage<SharedData>().props;
    const [showPassword, setShowPassword] = useState(false);
    const [showConfirmPassword, setShowConfirmPassword] = useState(false);
    const [isPasswordDialogOpen, setIsPasswordDialogOpen] = useState(false);
    const [isDeleteDialogOpen, setIsDeleteDialogOpen] = useState(false);
    // Removed unused internal otp state
    // const [otp, setOtp] = useState('');
    const [otpSent, setOtpSent] = useState(false);
    const [otpLoading, setOtpLoading] = useState(false);
    const [step, setStep] = useState<'otp' | 'password'>('otp');
    const [logoPreview, setLogoPreview] = useState<string | null>(null);
    const [logoError, setLogoError] = useState<string | null>(null);
    const [isUploadingLogo, setIsUploadingLogo] = useState(false);
    const fileInputRef = useRef<HTMLInputElement>(null);
    const [otpServer, setOtpServer] = useState<string | null>(null);
    const [otpVerifying, setOtpVerifying] = useState(false);

    const { data, setData, patch, errors, processing, recentlySuccessful } = useForm({
        name: vendor.name,
        brand_name_en: vendor.brand_name_en || '',
        brand_name_ar: vendor.brand_name_ar || '',
        email: vendor.email,
        mobile: vendor.mobile || '',
        phone: user.phone || '',
        description_en: vendor.description_en || '',
        description_ar: vendor.description_ar || '',
        use_armada_delivery: vendor.use_armada_delivery || false,
        latitude: vendor.latitude || null,
        longitude: vendor.longitude || null,
        address_text: vendor.address_text || '',
        // Address fields
        address_full_name: address?.full_name || vendor.name || '',
        address_phone: address?.phone || user.phone || '',
        address_line_1: address?.line_1 || '',
        address_line_2: address?.line_2 || '',
        address_country_id: address?.country_id?.toString() || '',
        address_state_id: address?.state_id?.toString() || '',
        address_city_id: address?.city_id?.toString() || '',
        address_pincode: address?.pincode || '',
    });

    const passwordForm = useForm({
        old_password: '',
        new_password: '',
        new_password_confirmation: '',
        otp: '',
    });

    const deleteForm = useForm({
        confirmation: '',
    });


    const submit: FormEventHandler = (e) => {
        e.preventDefault();
        patch(route('vendor.profile.update'), {
            preserveScroll: true,
        });
    };

    const handleLogoUpload = (event: React.ChangeEvent<HTMLInputElement>) => {
        const file = event.target.files?.[0];
        if (!file) return;

        // Clear previous errors
        setLogoError(null);

        // Validate file type
        if (!file.type.startsWith('image/')) {
            setLogoError('Please select a valid image file');
            return;
        }

        // Validate file size (2MB max)
        if (file.size > 2 * 1024 * 1024) {
            setLogoError('File size must be less than 2MB');
            return;
        }

        // Create preview
        const reader = new FileReader();
        reader.onload = (e) => {
            setLogoPreview(e.target?.result as string);
        };
        reader.readAsDataURL(file);

        // Validate image dimensions
        const img = new Image();
        img.onload = () => {
            if (img.width < 300 || img.height < 300) {
                setLogoError('Image must be at least 300x300 pixels');
                setLogoPreview(null);
                return;
            }
            if (img.width > 800 || img.height > 800) {
                setLogoError('Image must be no larger than 800x800 pixels');
                setLogoPreview(null);
                return;
            }

            // If validation passes, upload the file
            uploadLogo(file);
        };
        img.onerror = () => {
            setLogoError('Invalid image file');
            setLogoPreview(null);
        };
        img.src = URL.createObjectURL(file);
    };

    const uploadLogo = (file: File) => {
        setIsUploadingLogo(true);
        const formData = new FormData();
        formData.append('logo', file);

        router.post(route('vendor.profile.upload-logo'), formData, {
            onSuccess: () => {
                setIsUploadingLogo(false);
                setLogoPreview(null);
                setLogoError(null);
                // Refresh the page to show new logo
                router.reload();
            },
            onError: (errors) => {
                setIsUploadingLogo(false);
                setLogoPreview(null);
                setLogoError(errors.logo || 'Upload failed. Please try again.');
                console.error('Logo upload failed:', errors);
            },
        });
    };

    // Use custom hook
    // Use custom hook
    const { generateAndSendOtp, verifyLocalOtp, otpSent: hookOtpSent, loading: hookOtpLoading, resetOtp } = useOtp();

    const sendOTP = async () => {
        // Validation for phone
        if (!data.phone) {
            toast.error('Phone number is missing');
            return;
        }
        await generateAndSendOtp(data.phone, 'Your OTP for Expoza profile update is:');
    };

    const verifyOTP = async () => {
        // console.log('Verifying OTP:', passwordForm.data.otp);

        if (!passwordForm.data.otp) {
            toast.error('Please enter OTP');
            return;
        }

        // Frontend Verification
        if (verifyLocalOtp(passwordForm.data.otp)) {
            try {
                // Call backend to set session verified flag
                const response = await fetch(route('vendor.profile.otp-verify'), {
                    method: 'POST',
                    headers: {
                        'X-Requested-With': 'XMLHttpRequest',
                        'X-CSRF-TOKEN': (document.querySelector('meta[name="csrf-token"]') as HTMLMetaElement)?.content || '',
                        'Content-Type': 'application/json',
                    },
                    credentials: 'same-origin',
                    body: JSON.stringify({
                        // No body needed if backend just sets flag, or pass phone if needed
                        phone: data.phone
                    }),
                });
                const responseData = await response.json();

                if (responseData.success) {
                    setStep('password');
                    toast.success('OTP verified successfully!');
                } else {
                    toast.error(responseData.message || 'Verification failed.');
                }
            } catch (error) {
                console.error('OTP verification error:', error);
                toast.error('Failed to verify OTP. Please try again.');
            }
        } else {
            toast.error('Invalid OTP.');
        }
    };

    const changePassword = () => {
        passwordForm.post(route('vendor.profile.change-password'), {
            onSuccess: () => {
                setIsPasswordDialogOpen(false);
                passwordForm.reset();
                setOtpSent(false);
                setStep('otp');
                toast.success('Password changed successfully!');
            },
            onError: (errors) => {
                toast.error(
                    errors.new_password || errors.new_password_confirmation || errors.otp || errors.error || 'Failed to change password',
                );
            },
        });
    };

    // Reset dialog state on close
    const handlePasswordDialogOpenChange = (open: boolean) => {
        setIsPasswordDialogOpen(open);
        if (!open) {
            setStep('otp');
            setOtpSent(false);
            passwordForm.reset();
        }
    };

    const deleteAccount = () => {
        if (deleteForm.data.confirmation !== 'DELETE') {
            alert('Please type DELETE to confirm account deletion');
            return;
        }

        router.delete(route('vendor.profile.delete-account'), {
            data: {
                confirmation: deleteForm.data.confirmation,
            },
            onSuccess: () => {
                // Redirect will be handled by the controller
            },
            onError: (errors) => {
                alert('Failed to delete account: ' + (errors.confirmation || 'Unknown error'));
            },
        });
    };

    const getKYCStatusColor = (status: string) => {
        switch (status) {
            case 'approved':
                return 'bg-green-100 text-green-800';
            case 'pending':
                return 'bg-yellow-100 text-yellow-800';
            case 'rejected':
                return 'bg-red-100 text-red-800';
            default:
                return 'bg-gray-100 text-gray-800';
        }
    };

    return (
        <AppLayout breadcrumbs={getBreadcrumbs(t)}>
            <Head title={t('vendor.profileManagement')} />

            <div className="space-y-4 p-6">
                <HeadingSmall title={t('vendor.profileManagement')} description={t('vendor.profileDescription')} />

                {/* KYC Status Banner */}
                <Alert className={kyc_status === 'rejected' ? 'border-red-200 bg-red-50' : ''}>
                    <Shield className="h-4 w-4" />
                    <AlertDescription>
                        <div className="flex items-center gap-x-4">
                            <span>{t('profile.kycStatusLabel')} </span>
                            <Badge className={getKYCStatusColor(kyc_status)}>{kyc_status.charAt(0).toUpperCase() + kyc_status.slice(1)}</Badge>
                        </div>
                        {kyc_status === 'rejected' && kyc_rejection_reason && (
                            <div className="mt-2 text-sm text-red-700">{t('profile.reason')} {kyc_rejection_reason}</div>
                        )}
                        {kyc_status === 'rejected' && (
                            <Link href={route('vendor.profile.kyc-status')} className="mt-2 inline-block text-sm text-blue-600 hover:underline">
                                {t('profile.resubmitKycDocuments')}
                            </Link>
                        )}
                    </AlertDescription>
                </Alert>

                {flash && flash.success && <div className="mb-3 rounded bg-green-100 px-4 py-2 text-green-800">{flash.success}</div>}

                <div className="grid gap-4 md:grid-cols-2">
                    {/* Profile Information */}
                    <Card>
                        <CardHeader>
                            <CardTitle className="flex items-center gap-2">
                                <User className="h-5 w-5" />
                                {t('profile.profileInformation')}
                            </CardTitle>
                            <CardDescription>{t('profile.profileInfoDesc')}</CardDescription>
                        </CardHeader>
                        <CardContent>
                            <form onSubmit={submit} className="space-y-3">
                                <div className="grid gap-2">
                                    <Label htmlFor="name">{t('profile.nameRequired')}</Label>
                                    <Input
                                        id="name"
                                        value={data.name}
                                        onChange={(e) => setData('name', e.target.value)}
                                        required
                                        placeholder={t('profile.placeholderFullName')}
                                    />
                                    <InputError message={errors.name} />
                                </div>

                                <div className="grid gap-2">
                                    <Label htmlFor="brand_name">{t('profile.brandNameEn')}</Label>
                                    <Input
                                        id="brand_name"
                                        value={data.brand_name_en}
                                        onChange={(e) => setData('brand_name_en', e.target.value)}
                                        placeholder={t('profile.placeholderBrandEn')}
                                    />
                                    <InputError message={errors.brand_name_en} />
                                </div>

                                <div className="grid gap-2">
                                    <Label htmlFor="brand_name_ar">{t('profile.brandNameAr')}</Label>
                                    <Input
                                        id="brand_name_ar"
                                        value={data.brand_name_ar}
                                        onChange={(e) => setData('brand_name_ar', e.target.value)}
                                        placeholder={t('profile.brandNameAr')}
                                        dir="rtl"
                                    />
                                    <InputError message={errors.brand_name_ar} />
                                </div>

                                <div className="grid gap-2">
                                    <Label htmlFor="email">{t('profile.emailRequired')}</Label>
                                    <Input
                                        id="email"
                                        type="email"
                                        value={data.email}
                                        onChange={(e) => setData('email', e.target.value)}
                                        required
                                        placeholder={t('profile.placeholderEmail')}
                                    />
                                    <InputError message={errors.email} />
                                </div>
                                <div className="grid gap-2">
                                    <Label htmlFor="phone">{t('profile.phone')}</Label>
                                    <Input
                                        id="phone"
                                        value={data.phone}
                                        onChange={(e) => {
                                            const numericValue = e.target.value.replace(/\D/g, '');
                                            setData('phone', numericValue);
                                        }}
                                        placeholder={t('profile.placeholderPhone')}
                                    />
                                    <InputError message={errors.phone} />
                                </div>

                                <div className="grid gap-2">
                                    <Label htmlFor="business_phone">{t('profile.businessMobile')}</Label>
                                    <Input
                                        id="business_phone"
                                        value={data.mobile}
                                        onChange={(e) => {
                                            const numericValue = e.target.value.replace(/\D/g, '');
                                            setData('mobile', numericValue);
                                        }}
                                        placeholder={t('profile.placeholderBusinessPhone')}
                                    />
                                    <InputError message={errors.mobile} />
                                </div>

                                <div className="grid gap-2">
                                    <Label htmlFor="description">{t('profile.descriptionEn')}</Label>
                                    <div className="h-56">
                                        <ReactQuillWrapper
                                            value={data.description_en}
                                            onChange={(value: string) => setData('description_en', value)}
                                            theme="snow"
                                            className="h-44"
                                        />
                                    </div>
                                    <InputError message={errors.description_en} />
                                </div>

                                <div className="grid gap-2">
                                    <Label htmlFor="description_ar">{t('profile.descriptionAr')}</Label>
                                    <div className="h-56">
                                        <ReactQuillWrapper
                                            value={data.description_ar}
                                            onChange={(value: string) => setData('description_ar', value)}
                                            theme="snow"
                                            className="h-44"
                                        />
                                    </div>
                                    <InputError message={errors.description_ar} />
                                </div>

                                <div className="flex items-center gap-3 rounded-lg border p-4 bg-muted/50">
                                    <input
                                        id="use_armada_delivery"
                                        type="checkbox"
                                        tabIndex={6}
                                        checked={data.use_armada_delivery}
                                        onChange={(e) => setData('use_armada_delivery', e.target.checked)}
                                        disabled={processing}
                                        className="h-4 w-4 rounded border-gray-300 text-primary focus:ring-primary"
                                    />
                                    <div>
                                        <Label htmlFor="use_armada_delivery" className="cursor-pointer font-medium">
                                            {t('profile.agreeArmada')}
                                        </Label>
                                        <p className="text-xs text-muted-foreground mt-1">
                                            {t('profile.armadaHint')}
                                        </p>
                                    </div>
                                </div>
                                <InputError message={errors.use_armada_delivery} />

                                {/* Store Location */}
                                <div className="grid gap-2">
                                    <Label className="font-medium">{t('profile.storeLocation')}</Label>
                                    <p className="text-xs text-muted-foreground">
                                        {t('profile.storeLocationHint')}
                                    </p>
                                    <GoogleMapPicker
                                        latitude={data.latitude}
                                        longitude={data.longitude}
                                        onLocationChange={(lat: number, lng: number, address?: string) => {
                                            setData((prev: any) => ({
                                                ...prev,
                                                latitude: lat,
                                                longitude: lng,
                                                address_text: address || prev.address_text,
                                            }));
                                        }}
                                        disabled={processing}
                                    />
                                    <InputError message={errors.latitude} />
                                </div>
                                <div className="grid gap-2">
                                    <Label htmlFor="address_text">{t('profile.storeAddress')}</Label>
                                    <Input
                                        id="address_text"
                                        type="text"
                                        value={data.address_text}
                                        readOnly
                                        disabled
                                        placeholder={t('profile.placeholderMapLocation')}
                                        className="bg-muted cursor-not-allowed"
                                    />
                                    <p className="text-xs text-muted-foreground">
                                        {t('profile.addressAutoHint')}
                                    </p>
                                    <InputError message={errors.address_text} />
                                </div>

                                <Button type="submit" disabled={processing}>
                                    {processing ? t('profile.saving') : t('profile.saveChanges')}
                                </Button>

                                <Transition
                                    show={recentlySuccessful}
                                    enter="transition ease-in-out"
                                    enterFrom="opacity-0"
                                    leave="transition ease-in-out"
                                    leaveTo="opacity-0"
                                >
                                    <p className="text-sm text-green-600">{t('profile.profileUpdatedSuccess')}</p>
                                </Transition>
                            </form>
                        </CardContent>
                    </Card>

                    {/* Address Section */}
                    <Card>
                        <CardHeader>
                            <CardTitle className="flex items-center gap-2">
                                <MapPin className="h-5 w-5" />
                                {t('profile.addressInformation')}
                            </CardTitle>
                            <CardDescription>{t('profile.businessAddressDesc')}</CardDescription>
                        </CardHeader>
                        <CardContent>
                            <form onSubmit={submit} className="space-y-3">
                                <div className="grid gap-2">
                                    <Label htmlFor="address_full_name">{t('profile.fullName')}</Label>
                                    <Input
                                        id="address_full_name"
                                        value={data.address_full_name}
                                        onChange={(e) => setData('address_full_name', e.target.value)}
                                        placeholder={t('profile.placeholderAddressFullName')}
                                    />
                                    <InputError message={errors.address_full_name} />
                                </div>

                                <div className="grid gap-2">
                                    <Label htmlFor="address_phone">{t('profile.phone')}</Label>
                                    <Input
                                        id="address_phone"
                                        value={data.address_phone}
                                        onChange={(e) => {
                                            const numericValue = e.target.value.replace(/\D/g, '');
                                            setData('address_phone', numericValue);
                                        }}
                                        placeholder={t('profile.placeholderAddressPhone')}
                                    />
                                    <InputError message={errors.address_phone} />
                                </div>

                                <div className="grid gap-2">
                                    <Label htmlFor="address_line_1">{t('profile.addressLine1')}</Label>
                                    <Input
                                        id="address_line_1"
                                        value={data.address_line_1}
                                        onChange={(e) => setData('address_line_1', e.target.value)}
                                        placeholder={t('profile.placeholderAddressLine1')}
                                    />
                                    <InputError message={errors.address_line_1} />
                                </div>

                                <div className="grid gap-2">
                                    <Label htmlFor="address_line_2">{t('profile.addressLine2')}</Label>
                                    <Input
                                        id="address_line_2"
                                        value={data.address_line_2}
                                        onChange={(e) => setData('address_line_2', e.target.value)}
                                        placeholder={t('profile.placeholderAddressLine2')}
                                    />
                                    <InputError message={errors.address_line_2} />
                                </div>

                                <div className="grid gap-2">
                                    <Label htmlFor="address_country_id">{t('sidebar.country')}</Label>
                                    <Select
                                        value={data.address_country_id}
                                        onValueChange={(value) => {
                                            setData('address_country_id', value);
                                            setData('address_state_id', ''); // Reset state when country changes
                                            setData('address_city_id', ''); // Reset city when country changes
                                        }}
                                    >
                                        <SelectTrigger>
                                            <SelectValue placeholder={t('profile.selectCountry')} />
                                        </SelectTrigger>
                                        <SelectContent>
                                            {countries?.map((country) => (
                                                <SelectItem key={country.id} value={country.id.toString()}>
                                                    {country.name_en}
                                                </SelectItem>
                                            ))}
                                        </SelectContent>
                                    </Select>
                                    <InputError message={errors.address_country_id} />
                                </div>

                                <div className="grid gap-2">
                                    <Label htmlFor="address_state_id">{t('sidebar.state')}</Label>
                                    <Select
                                        value={data.address_state_id}
                                        onValueChange={(value) => {
                                            setData('address_state_id', value);
                                            setData('address_city_id', ''); // Reset city when state changes
                                        }}
                                        disabled={!data.address_country_id}
                                    >
                                        <SelectTrigger>
                                            <SelectValue placeholder={t('profile.selectState')} />
                                        </SelectTrigger>
                                        <SelectContent>
                                            {states
                                                ?.filter((state) => !data.address_country_id || state.country_id.toString() === data.address_country_id)
                                                .map((state) => (
                                                    <SelectItem key={state.id} value={state.id.toString()}>
                                                        {state.name_en}
                                                    </SelectItem>
                                                ))}
                                        </SelectContent>
                                    </Select>
                                    <InputError message={errors.address_state_id} />
                                </div>

                                <div className="grid gap-2">
                                    <Label htmlFor="address_city_id">{t('sidebar.city')}</Label>
                                    <Select
                                        value={data.address_city_id}
                                        onValueChange={(value) => setData('address_city_id', value)}
                                        disabled={!data.address_state_id}
                                    >
                                        <SelectTrigger>
                                            <SelectValue placeholder={t('profile.selectCity')} />
                                        </SelectTrigger>
                                        <SelectContent>
                                            {cities
                                                ?.filter((city) => {
                                                    if (data.address_state_id) {
                                                        return city.state_id.toString() === data.address_state_id;
                                                    }
                                                    if (data.address_country_id) {
                                                        return city.country_id.toString() === data.address_country_id;
                                                    }
                                                    return true;
                                                })
                                                .map((city) => (
                                                    <SelectItem key={city.id} value={city.id.toString()}>
                                                        {city.name_en}
                                                    </SelectItem>
                                                ))}
                                        </SelectContent>
                                    </Select>
                                    <InputError message={errors.address_city_id} />
                                </div>

                                <div className="grid gap-2">
                                    <Label htmlFor="address_pincode">{t('profile.postalCode')}</Label>
                                    <Input
                                        id="address_pincode"
                                        value={data.address_pincode}
                                        onChange={(e) => setData('address_pincode', e.target.value)}
                                        placeholder={t('profile.placeholderPostalCode')}
                                    />
                                    <InputError message={errors.address_pincode} />
                                </div>

                                <Button type="submit" disabled={processing}>
                                    {processing ? t('profile.saving') : t('profile.saveAddress')}
                                </Button>
                            </form>
                        </CardContent>
                    </Card>

                    {/* Password Change */}
                    <Card>
                        <CardHeader>
                            <CardTitle className="flex items-center gap-2">
                                <Key className="h-5 w-5" />
                                {t('profile.changePassword')}
                            </CardTitle>
                            <CardDescription>{t('profile.changePasswordDesc')}</CardDescription>
                        </CardHeader>
                        <CardContent>
                            <Dialog open={isPasswordDialogOpen} onOpenChange={handlePasswordDialogOpenChange}>
                                <DialogTrigger asChild>
                                    <Button variant="outline" className="w-full">
                                        {t('profile.changePassword')}
                                    </Button>
                                </DialogTrigger>
                                <DialogContent className="sm:max-w-md">
                                    <DialogHeader>
                                        <DialogTitle>{t('profile.changePassword')}</DialogTitle>
                                        <DialogDescription>{t('profile.verifyOtpDesc')}</DialogDescription>
                                    </DialogHeader>
                                    <div className="space-y-4">
                                        {step === 'otp' && (
                                            <>
                                                {/* Phone Number Field */}
                                                <div className="grid gap-2">
                                                    <Label htmlFor="phone">{t('profile.phoneNumber')}</Label>
                                                    <div className="flex gap-2">
                                                        <Input
                                                            id="phone"
                                                            value={data.phone}
                                                            onChange={(e) => {
                                                                const numericValue = e.target.value.replace(/\D/g, '');
                                                                setData('phone', numericValue);
                                                            }}
                                                            placeholder={t('profile.placeholderPhone')}
                                                        />
                                                        <Button type="button" onClick={sendOTP} disabled={hookOtpLoading || hookOtpSent}>
                                                            {hookOtpLoading ? t('profile.sending') : hookOtpSent ? t('profile.otpSent') : t('profile.sendOtp')}
                                                        </Button>
                                                    </div>
                                                    <span className="text-xs text-muted-foreground">
                                                        {t('profile.enterPhoneForOtp')}
                                                    </span>
                                                </div>

                                                {/* OTP Entry Field - Only show after OTP is sent */}
                                                {hookOtpSent && (
                                                    <div className="grid gap-2">
                                                        <Label htmlFor="otp_code">{t('profile.enterOtp')}</Label>
                                                        <div className="flex gap-2">
                                                            <Input
                                                                id="otp_code"
                                                                type="text"
                                                                value={passwordForm.data.otp || ''} // Using passwordForm for OTP code
                                                                onChange={(e) => passwordForm.setData('otp', e.target.value)}
                                                                placeholder={t('profile.placeholderOtp')}
                                                                maxLength={6}
                                                                className="flex-1"
                                                            />
                                                            <Button onClick={verifyOTP} disabled={!passwordForm.data.otp || otpVerifying}>
                                                                {otpVerifying ? t('profile.verifying') : t('profile.verifyOtp')}
                                                            </Button>
                                                        </div>
                                                        <span className="text-xs text-muted-foreground">
                                                            {t('profile.enterOtpSentHint')}
                                                            {otpServer && (
                                                                <span className="ml-2 text-green-600 font-semibold">[Test OTP: {otpServer}]</span>
                                                            )}
                                                        </span>
                                                    </div>
                                                )}
                                            </>
                                        )}
                                        {step === 'password' && (
                                            <>
                                                {/* New Password */}
                                                <div className="grid gap-2">
                                                    <Label htmlFor="new_password">New Password</Label>
                                                    <div className="relative">
                                                        <Input
                                                            id="new_password"
                                                            type={showPassword ? 'text' : 'password'}
                                                            value={passwordForm.data.new_password}
                                                            onChange={(e) => passwordForm.setData('new_password', e.target.value)}
                                                            placeholder={t('profile.placeholderNewPassword')}
                                                        />
                                                        <Button
                                                            type="button"
                                                            variant="ghost"
                                                            size="sm"
                                                            className="absolute top-0 right-0 h-full px-3 py-2 hover:bg-transparent"
                                                            onClick={() => setShowPassword((v) => !v)}
                                                            tabIndex={-1}
                                                        >
                                                            {showPassword ? <EyeOff className="h-4 w-4" /> : <Eye className="h-4 w-4" />}
                                                        </Button>
                                                    </div>
                                                </div>
                                                {/* Confirm New Password */}
                                                <div className="grid gap-2">
                                                    <Label htmlFor="new_password_confirmation">{t('profile.confirmNewPassword')}</Label>
                                                    <div className="relative">
                                                        <Input
                                                            id="new_password_confirmation"
                                                            type={showConfirmPassword ? 'text' : 'password'}
                                                            value={passwordForm.data.new_password_confirmation}
                                                            onChange={(e) => passwordForm.setData('new_password_confirmation', e.target.value)}
                                                            placeholder={t('profile.placeholderConfirmPassword')}
                                                        />
                                                        <Button
                                                            type="button"
                                                            variant="ghost"
                                                            size="sm"
                                                            className="absolute top-0 right-0 h-full px-3 py-2 hover:bg-transparent"
                                                            onClick={() => setShowConfirmPassword((v) => !v)}
                                                            tabIndex={-1}
                                                        >
                                                            {showConfirmPassword ? <EyeOff className="h-4 w-4" /> : <Eye className="h-4 w-4" />}
                                                        </Button>
                                                    </div>
                                                </div>
                                                <DialogFooter>
                                                    <Button onClick={changePassword} disabled={passwordForm.processing}>
                                                        {passwordForm.processing ? t('profile.changing') : t('profile.updatePassword')}
                                                    </Button>
                                                </DialogFooter>
                                            </>
                                        )}
                                    </div>
                                </DialogContent>
                            </Dialog>
                        </CardContent>
                    </Card>

                    {/* Store Logo */}
                    <Card>
                        <CardHeader>
                            <CardTitle className="flex items-center gap-2">
                                <Upload className="h-5 w-5" />
                                {t('profile.storeLogo')}
                            </CardTitle>
                        </CardHeader>
                        <CardContent className="space-y-4">
                            {/* Current Logo or Preview */}
                            {(vendor.logo || logoPreview) && (
                                <div className="flex justify-center">
                                    <img
                                        src={logoPreview || vendor.logo}
                                        alt="Store Logo"
                                        className="h-32 w-32 rounded-lg border object-cover"
                                    />
                                </div>
                            )}

                            {/* Error Message */}
                            {logoError && (
                                <div className="rounded-md bg-red-50 p-3">
                                    <p className="text-sm text-red-700">{logoError}</p>
                                </div>
                            )}

                            {/* Upload Progress */}
                            {isUploadingLogo && (
                                <div className="rounded-md bg-blue-50 p-3">
                                    <p className="text-sm text-blue-700">{t('profile.uploadingLogo')}</p>
                                </div>
                            )}

                            <input
                                ref={fileInputRef}
                                type="file"
                                accept="image/*"
                                onChange={handleLogoUpload}
                                className="hidden"
                                disabled={isUploadingLogo}
                            />

                            <div className="flex gap-2">
                                <Button
                                    onClick={() => fileInputRef.current?.click()}
                                    variant="outline"
                                    className="flex-1"
                                    disabled={isUploadingLogo}
                                >
                                    {isUploadingLogo ? t('profile.saving') : vendor.logo ? t('profile.changeLogo') : t('profile.uploadLogo')}
                                </Button>

                                {logoPreview && !isUploadingLogo && (
                                    <Button
                                        onClick={() => {
                                            setLogoPreview(null);
                                            setLogoError(null);
                                            if (fileInputRef.current) {
                                                fileInputRef.current.value = '';
                                            }
                                        }}
                                        variant="outline"
                                        size="sm"
                                    >
                                        {t('common.cancel')}
                                    </Button>
                                )}
                            </div>

                            {/* Requirements */}
                            <div className="space-y-1 text-xs text-gray-500">
                                <p>{t('profile.logoRequirements')}</p>
                                <p>• {t('profile.logoFormats')}</p>
                            </div>
                        </CardContent>
                    </Card>

                    {/* Logo Upload & Security */}
                    <div className="space-y-4">
                        {/* Account Deletion */}
                        <Card className="border-red-200">
                            <CardHeader>
                                <CardTitle className="flex items-center gap-2 text-red-600">
                                    <Trash2 className="h-5 w-5" />
                                    {t('profile.deleteAccount')}
                                </CardTitle>
                                <CardDescription>{t('profile.deleteAccountDesc')}</CardDescription>
                            </CardHeader>
                            <CardContent>
                                <Dialog open={isDeleteDialogOpen} onOpenChange={setIsDeleteDialogOpen}>
                                    <DialogTrigger asChild>
                                        <Button variant="destructive" className="w-full">
                                            {t('profile.deleteAccount')}
                                        </Button>
                                    </DialogTrigger>
                                    <DialogContent>
                                        <DialogHeader>
                                            <DialogTitle>{t('profile.deleteAccount')}</DialogTitle>
                                            <DialogDescription>
                                                {t('profile.deleteConfirmDesc')}
                                            </DialogDescription>
                                        </DialogHeader>
                                        <div className="space-y-4">
                                            <div className="grid gap-2">
                                                <Label htmlFor="confirmation">{t('profile.typeDeleteToConfirm')}</Label>
                                                <Input
                                                    id="confirmation"
                                                    value={deleteForm.data.confirmation}
                                                    onChange={(e) => deleteForm.setData('confirmation', e.target.value)}
                                                    placeholder="DELETE"
                                                />
                                            </div>
                                            <DialogFooter>
                                                <Button
                                                    variant="destructive"
                                                    onClick={deleteAccount}
                                                    disabled={deleteForm.processing || deleteForm.data.confirmation !== 'DELETE'}
                                                >
                                                    {deleteForm.processing ? t('profile.deleting') : t('profile.deleteAccount')}
                                                </Button>
                                            </DialogFooter>
                                        </div>
                                    </DialogContent>
                                </Dialog>
                            </CardContent>
                        </Card>
                    </div>
                </div>
            </div>
        </AppLayout>
    );
}
