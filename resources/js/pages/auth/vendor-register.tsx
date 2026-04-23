import { Head, useForm } from '@inertiajs/react';
import { LoaderCircle, Eye, EyeOff, Info } from 'lucide-react';
import { FormEventHandler, useState } from 'react';
import toast from 'react-hot-toast';

import { useLanguage } from '@/components/language-context';
import InputError from '@/components/input-error';
import TextLink from '@/components/text-link';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import AuthLayout from '@/layouts/auth-layout';
import { useOtp } from '@/hooks/use-otp';
import GoogleMapPicker from '@/components/GoogleMapPicker';

type RegisterForm = {
    brand_name_en: string;
    brand_name_ar: string;
    email: string;
    phone: string;
    password: string;
    password_confirmation: string;
    use_armada_delivery: boolean;
    accept_terms: boolean;
    latitude: number | null;
    longitude: number | null;
    address_text: string;
};

export default function VendorRegister() {
    const { t } = useLanguage();
    const [step, setStep] = useState(1);
    const [successMsg, setSuccessMsg] = useState('');
    const [generatedOTP, setGeneratedOTP] = useState<string>(''); // Store OTP in frontend
    const { data, setData, post, processing, errors, reset, clearErrors } = useForm<Required<RegisterForm> & { otp: string }>({
        brand_name_en: '',
        brand_name_ar: '',
        email: '',
        phone: '',
        password: '',
        password_confirmation: '',
        otp: '',
        use_armada_delivery: false,
        accept_terms: false,
        latitude: null,
        longitude: null,
        address_text: '',
    });
    const [showPassword, setShowPassword] = useState(false);
    const [showConfirmPassword, setShowConfirmPassword] = useState(false);
    const [touched, setTouched] = useState<{ [key: string]: boolean }>({});
    const [submitAttempted, setSubmitAttempted] = useState(false);

    const { generateAndSendOtp, verifyLocalOtp, otpSent, loading: otpLoading } = useOtp();

    // Step 1: Registration details
    const handleRegister: FormEventHandler = async (e) => {
        e.preventDefault();
        setSubmitAttempted(true);

        setTouched({
            brand_name_en: true,
            brand_name_ar: true,
            email: true,
            phone: true,
            password: true,
            password_confirmation: true
        });

        // Basic validation check before sending OTP
        if (!data.brand_name_en || !data.brand_name_ar || !data.email || !data.phone || !data.password || !data.accept_terms || !data.use_armada_delivery) {
            toast.error(t('vendorAuth.fillRequiredFields'));
            return;
        }

        await generateAndSendOtp(data.phone, 'Your OTP for Expoza vendor registration is:');
        setStep(2);
    };

    // Step 2: OTP verification (Frontend-based)
    const handleVerifyOtp: FormEventHandler = (e) => {
        e.preventDefault();

        if (verifyLocalOtp(data.otp)) {
            // OTP matched! Now call backend to set session flag
            post(route('vendor.register.verify-otp'), {
                onSuccess: () => {
                    setSuccessMsg(t('vendorAuth.otpVerifiedSuccess'));
                    setStep(3);
                    toast.success(t('vendorAuth.otpVerified'));
                },
                onError: () => {
                    toast.error(t('vendorAuth.verifyOtpFailed'));
                }
            });
        } else {
            toast.error(t('vendorAuth.invalidOtp'));
        }
    };

    // Step 3: Complete registration
    const handleComplete: FormEventHandler = (e) => {
        e.preventDefault();
        post(route('vendor.register.complete'), {
            onSuccess: () => {
                toast.success(t('vendorAuth.registrationComplete'));
                // Backend handles redirect to dashboard
            },
            onError: (errors) => {
                console.error('Registration errors:', errors);
                toast.error(t('vendorAuth.registrationFailed'));
                setStep(1);
            }
        });
    };

    // Helper to show error only if field is touched or after submit
    const showError = (field: string) => (touched[field] || submitAttempted) && errors[field as keyof typeof errors];

    // Helper to show validation error (frontend validation)
    const showValidationError = (field: string, validationFn: () => string | null) => {
        if (touched[field] || submitAttempted) {
            const backendError = errors[field as keyof typeof errors];
            if (backendError) return backendError;
            return validationFn() || '';
        }
        return '';
    };

    // Password validation helper
    const validatePassword = (password: string) => {
        const minLength = 8;
        const hasUpperCase = /[A-Z]/.test(password);
        const hasLowerCase = /[a-z]/.test(password);
        const hasNumbers = /\d/.test(password);
        const hasSpecialChar = /[!@#$%^&*(),.?":{}|<>]/.test(password);

        if (password.length < minLength) {
            return t('vendorAuth.passwordMinLengthError');
        }
        if (!hasUpperCase) {
            return t('vendorAuth.passwordUppercaseError');
        }
        if (!hasLowerCase) {
            return t('vendorAuth.passwordLowercaseError');
        }
        if (!hasNumbers) {
            return t('vendorAuth.passwordNumberError');
        }
        if (!hasSpecialChar) {
            return t('vendorAuth.passwordSpecialError');
        }
        return null;
    };

    // Password confirmation validation
    const validatePasswordConfirmation = (password: string, confirmation: string) => {
        if (confirmation && password !== confirmation) {
            return t('vendorAuth.passwordsDoNotMatch');
        }
        return null;
    };

    // Handle input changes with error clearing
    const handleInputChange = (field: keyof typeof data, value: string) => {
        setData(field, value);
        // Clear errors for this field when user starts typing
        if (errors[field as keyof typeof errors]) {
            clearErrors(field);
        }
        // Clear password confirmation error when password changes
        if (field === 'password' && errors.password_confirmation) {
            clearErrors('password_confirmation');
        }
    };

    return (
        <AuthLayout title={t('vendorAuth.createAccount')} description={t('vendorAuth.registerDescription')}>
            <Head title={t('vendorAuth.register')} />
            {successMsg && (
                <div className="mb-4 text-center text-sm font-medium text-green-600">{successMsg}</div>
            )}
            {step === 1 && (
                <form className="flex flex-col gap-6" onSubmit={handleRegister}>
                    <div className="grid gap-6">
                        <div className="grid gap-2">
                            <Label htmlFor="brand_name_en">{t('vendorAuth.businessNameEn')}</Label>
                            <Input
                                id="brand_name_en"
                                type="text"
                                autoFocus
                                tabIndex={1}
                                autoComplete="organization"
                                value={data.brand_name_en}
                                onChange={(e) => handleInputChange('brand_name_en', e.target.value)}
                                onBlur={() => setTouched(t => ({ ...t, brand_name_en: true }))}
                                disabled={processing}
                                placeholder={t('vendorAuth.businessNameEnPlaceholder')}
                                required
                            />
                            <InputError message={showError('brand_name_en') ? errors.brand_name_en : ''} className="mt-2" />
                        </div>
                        <div className="grid gap-2">
                            <Label htmlFor="brand_name_ar">{t('vendorAuth.businessNameAr')}</Label>
                            <Input
                                id="brand_name_ar"
                                type="text"
                                tabIndex={1}
                                autoComplete="organization"
                                value={data.brand_name_ar}
                                onChange={(e) => handleInputChange('brand_name_ar', e.target.value)}
                                onBlur={() => setTouched(t => ({ ...t, brand_name_ar: true }))}
                                disabled={processing}
                                placeholder={t('vendorAuth.businessNameArPlaceholder')}
                                dir="rtl"
                                required
                            />
                            <InputError message={showError('brand_name_ar') ? errors.brand_name_ar : ''} className="mt-2" />
                        </div>
                        <div className="grid gap-2">
                            <Label htmlFor="email">{t('vendorAuth.emailAddress')}</Label>
                            <Input
                                id="email"
                                type="email"
                                tabIndex={2}
                                autoComplete="email"
                                value={data.email}
                                onChange={(e) => handleInputChange('email', e.target.value)}
                                onBlur={() => setTouched(t => ({ ...t, email: true }))}
                                disabled={processing}
                                placeholder={t('vendorAuth.emailPlaceholder')}
                                required
                            />
                            <InputError message={showError('email') ? errors.email : ''} />
                        </div>
                        <div className="grid gap-2">
                            <Label htmlFor="phone">{t('vendorAuth.phoneNumber')}</Label>
                            <Input
                                id="phone"
                                type="text"
                                inputMode="numeric"
                                pattern="\d{8}"
                                maxLength={8}
                                tabIndex={3}
                                autoComplete="tel"
                                value={data.phone}
                                onChange={(e) => {
                                    const onlyNums = e.target.value.replace(/\D/g, '').slice(0, 8);
                                    handleInputChange('phone', onlyNums);
                                }}
                                onBlur={() => setTouched(t => ({ ...t, phone: true }))}
                                disabled={processing}
                                placeholder={t('vendorAuth.phonePlaceholder')}
                                required
                            />
                            <InputError
                                message={
                                    showError('phone')
                                        ? (data.phone.length !== 8
                                            ? t('vendorAuth.phoneMustBe8Digits')
                                            : errors.phone)
                                        : ''
                                }
                            />
                        </div>
                        <div className="grid gap-2">
                            <Label htmlFor="password" className="flex items-center gap-1">
                                {t('vendorAuth.password')}
                                <span className="relative register-info ml-1">
                                    <Info className="h-4 w-4 text-blue-500 cursor-pointer" />
                                    <span className="invisible absolute left-6 top-1/2 -translate-y-1/2 z-10 min-w-max rounded bg-gray-800 px-3 py-2 text-xs text-white opacity-0 transition-opacity shadow-lg">
                                        <div className="font-semibold mb-1">{t('vendorAuth.passwordRequirements')}</div>
                                        <ul className="list-disc pl-4">
                                            <li>{t('vendorAuth.passwordMinLength')}</li>
                                            <li>{t('vendorAuth.passwordUppercase')}</li>
                                            <li>{t('vendorAuth.passwordLowercase')}</li>
                                            <li>{t('vendorAuth.passwordNumber')}</li>
                                            <li>{t('vendorAuth.passwordSpecial')}</li>
                                        </ul>
                                    </span>
                                </span>
                            </Label>
                            <div className="relative">
                                <Input
                                    id="password"
                                    type={showPassword ? 'text' : 'password'}
                                    tabIndex={4}
                                    autoComplete="new-password"
                                    value={data.password}
                                    onChange={(e) => {
                                        setData('password', e.target.value);
                                        setTouched(t => ({ ...t, password: true }));
                                    }}
                                    onBlur={() => setTouched(t => ({ ...t, password: true }))}
                                    disabled={processing}
                                    placeholder={t('vendorAuth.passwordPlaceholder')}
                                    required
                                />
                                <button
                                    type="button"
                                    tabIndex={-1}
                                    className="absolute end-2 top-1/2 -translate-y-1/2 p-1 text-muted-foreground"
                                    onClick={() => setShowPassword((v) => !v)}
                                    aria-label={showPassword ? t('vendorAuth.hidePassword') : t('vendorAuth.showPassword')}
                                >
                                    {showPassword ? <EyeOff className="h-4 w-4" /> : <Eye className="h-4 w-4" />}
                                </button>
                            </div>

                            <InputError message={showValidationError('password', () => validatePassword(data.password))} />
                        </div>
                        <div className="grid gap-2">
                            <Label htmlFor="password_confirmation">{t('vendorAuth.confirmPassword')}</Label>
                            <div className="relative">
                                <Input
                                    id="password_confirmation"
                                    type={showConfirmPassword ? 'text' : 'password'}
                                    tabIndex={5}
                                    autoComplete="new-password"
                                    value={data.password_confirmation}
                                    onChange={(e) => handleInputChange('password_confirmation', e.target.value)}
                                    onBlur={() => setTouched(t => ({ ...t, password_confirmation: true }))}
                                    disabled={processing}
                                    placeholder={t('vendorAuth.confirmPasswordPlaceholder')}
                                    required
                                />
                                <button
                                    type="button"
                                    tabIndex={-1}
                                    className="absolute end-2 top-1/2 -translate-y-1/2 p-1 text-muted-foreground"
                                    onClick={() => setShowConfirmPassword((v) => !v)}
                                    aria-label={showConfirmPassword ? t('vendorAuth.hidePassword') : t('vendorAuth.showPassword')}
                                >
                                    {showConfirmPassword ? <EyeOff className="h-4 w-4" /> : <Eye className="h-4 w-4" />}
                                </button>
                            </div>
                            <InputError message={showValidationError('password_confirmation', () => validatePasswordConfirmation(data.password, data.password_confirmation))} />
                        </div>
                        <div className="flex items-start gap-3 rounded-lg border p-4 bg-muted/50">
                            <input
                                id="accept_terms"
                                type="checkbox"
                                tabIndex={6}
                                checked={data.accept_terms}
                                onChange={(e) => setData('accept_terms', e.target.checked)}
                                disabled={processing}
                                className="mt-1 h-4 w-4 rounded border-gray-300 text-primary focus:ring-primary"
                                required
                            />
                            <div>
                                <Label htmlFor="accept_terms" className="cursor-pointer font-medium">
                                    {t('vendorAuth.agreeToTerms')}{' '}
                                    <a
                                        href={route('cms.show', { slug: 'terms-of-vendor' })}
                                        target="_blank"
                                        rel="noopener noreferrer"
                                        className="text-primary underline hover:text-primary/80"
                                        onClick={(e) => e.stopPropagation()}
                                    >
                                        {t('vendorAuth.termsAndConditions')}
                                    </a>
                                </Label>
                                <p className="text-xs text-muted-foreground mt-1">
                                    {t('vendorAuth.mustAcceptTerms')}
                                </p>
                                <InputError message={errors.accept_terms} className="mt-1" />
                            </div>
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
                                required
                            />
                            <div>
                                <Label htmlFor="use_armada_delivery" className="cursor-pointer font-medium">
                                    {t('vendorAuth.agreeExpozaDelivery')}
                                </Label>
                                <p className="text-xs text-muted-foreground mt-1">
                                    {t('vendorAuth.armadaDeliveryHint')}
                                </p>
                            </div>
                        </div>

                        {/* Store Location */}
                        <div className="grid gap-2">
                            <Label className="font-medium">{t('vendorAuth.storeLocation')}</Label>
                            <p className="text-xs text-muted-foreground">
                                {t('vendorAuth.storeLocationHint')}
                            </p>
                            <GoogleMapPicker
                                latitude={data.latitude}
                                longitude={data.longitude}
                                onLocationChange={(lat, lng, address) => {
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
                            <Label htmlFor="address_text">{t('vendorAuth.storeAddress')}</Label>
                            <Input
                                id="address_text"
                                type="text"
                                value={data.address_text}
                                readOnly
                                disabled
                                placeholder={t('vendorAuth.storeAddressPlaceholder')}
                                className="bg-muted cursor-not-allowed"
                            />
                            <p className="text-xs text-muted-foreground">
                                {t('vendorAuth.addressSetFromMap')}
                            </p>
                            <InputError message={errors.address_text} />
                        </div>

                        <Button type="submit" className="mt-2 w-full" tabIndex={7} disabled={processing}>
                            {processing && <LoaderCircle className="h-4 w-4 animate-spin" />}{t('vendorAuth.sendOtp')}
                        </Button>
                    </div>
                    <div className="text-muted-foreground text-center text-sm">
                        {t('vendorAuth.alreadyHaveAccount')}{' '}
                        <TextLink href={route('vendor.login')} tabIndex={7}>{t('vendorAuth.logIn')}</TextLink>
                    </div>
                </form>
            )}
            {step === 2 && (
                <form className="flex flex-col gap-6" onSubmit={handleVerifyOtp}>
                    <div className="grid gap-6">
                        <div className="grid gap-2">
                            <Label htmlFor="otp">{t('vendorAuth.enterOtp')}</Label>
                            <Input
                                id="otp"
                                type="text"
                                inputMode="numeric"
                                pattern="[0-9]*"
                                maxLength={6}
                                required
                                tabIndex={1}
                                value={data.otp}
                                onChange={e => {
                                    const value = e.target.value.replace(/\D/g, '').slice(0, 6);
                                    setData('otp', value);
                                }}
                                placeholder={t('vendorAuth.enterOtpPlaceholder')}
                            />
                            <InputError message={errors['otp' as keyof typeof errors]} />
                        </div>
                        <Button type="submit" className="mt-2 w-full" tabIndex={2} disabled={processing}>{processing && <LoaderCircle className="h-4 w-4 animate-spin" />}{t('vendorAuth.verifyOtp')}</Button>
                    </div>
                </form>
            )}
            {step === 3 && (
                <form className="flex flex-col gap-6" onSubmit={handleComplete}>
                    <div className="grid gap-6">
                        <div className="mb-4 text-center text-sm font-medium text-green-600">{t('vendorAuth.otpVerifiedCompleteHint')}</div>
                        <Button type="submit" className="mt-2 w-full" tabIndex={1} disabled={processing}>{processing && <LoaderCircle className="h-4 w-4 animate-spin" />}{t('vendorAuth.completeRegistration')}</Button>
                    </div>
                </form>
            )}
        </AuthLayout>
    );
}
