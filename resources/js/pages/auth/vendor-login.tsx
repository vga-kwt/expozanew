import { Head, useForm } from '@inertiajs/react';
import { Eye, EyeOff, LoaderCircle } from 'lucide-react';
import { FormEventHandler, useState } from 'react';
import toast from 'react-hot-toast';

import { useLanguage } from '@/components/language-context';
import InputError from '@/components/input-error';
import TextLink from '@/components/text-link';
import { Button } from '@/components/ui/button';
import { Checkbox } from '@/components/ui/checkbox';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import AuthLayout from '@/layouts/auth-layout';

type LoginForm = {
    identifier: string; // can be email or phone
    password: string;
    remember: boolean;
};

interface LoginProps {
    status?: string;
    canResetPassword: boolean;
    error?: string;
}

export default function VendorLogin({ status, canResetPassword, error }: LoginProps) {
    const { t } = useLanguage();
    const [showPassword, setShowPassword] = useState(false);

    const { data, setData, post, processing, errors, reset } = useForm<Required<LoginForm>>({
        identifier: '',
        password: '',
        remember: false,
    });

    const submit: FormEventHandler = (e) => {
        e.preventDefault();
        post(route('vendor.login'), {
            onFinish: () => reset('password'),
            onError: (errors) => {
                if (errors.identifier) toast.error(errors.identifier);
                if (errors.password) toast.error(errors.password);
            },
            onSuccess: (page) => {
                if (page.props.error) {
                    toast.error(String(page.props.error));
                } else {
                    toast.success(t('vendorAuth.loginSuccess'));
                }
            },
        });
    };

    return (
        <AuthLayout title={t('vendorAuth.logInToAccount')} description={t('vendorAuth.logInDescription')}>
            <Head title={t('vendorAuth.logIn')} />

            {error && <div className="mb-4 text-center text-sm font-medium text-red-600">{error}</div>}

            <form className="flex flex-col gap-6" onSubmit={submit}>
                <div className="grid gap-6">
                    <div className="grid gap-2">
                        <Label htmlFor="email">{t('vendorAuth.emailOrPhone')}</Label>
                        <Input
                            id="email"
                            type="text"
                            autoComplete="email"
                            autoFocus
                            value={data.identifier}
                            onChange={(e) => setData('identifier', e.target.value)}
                            placeholder={t('vendorAuth.emailOrPhonePlaceholder')}
                        />
                        <InputError message={errors.identifier} />
                    </div>
                    <div className="grid gap-2">
                        <div className="flex items-center">
                            <Label htmlFor="password">{t('vendorAuth.password')}</Label>
                            {canResetPassword && (
                                <TextLink href={route('vendor.password.request')} className="ml-auto text-sm" tabIndex={1}>
                                    {t('vendorAuth.forgotPassword')}
                                </TextLink>
                            )}
                        </div>
                        <div className="relative">
                            <Input
                                id="password"
                                type={showPassword ? 'text' : 'password'}
                                autoComplete="current-password"
                                value={data.password}
                                onChange={(e) => setData('password', e.target.value)}
                                placeholder={t('vendorAuth.passwordPlaceholder')}
                            />
                            <Button
                                type="button"
                                variant="ghost"
                                size="sm"
                                className="absolute top-0 right-0 h-full px-3 py-2 hover:bg-transparent"
                                onClick={() => setShowPassword(!showPassword)}
                                aria-label={showPassword ? t('vendorAuth.hidePassword') : t('vendorAuth.showPassword')}
                            >
                                {showPassword ? <EyeOff className="h-4 w-4" /> : <Eye className="h-4 w-4" />}
                            </Button>
                        </div>
                        <InputError message={errors.password} />
                    </div>
                    <div className="flex items-center space-x-3">
                        <Checkbox id="remember" name="remember" checked={data.remember} onClick={() => setData('remember', !data.remember)} />
                        <Label htmlFor="remember">{t('vendorAuth.rememberMe')}</Label>
                    </div>
                    <Button type="submit" className="mt-4 w-full" disabled={processing}>
                        {processing && <LoaderCircle className="h-4 w-4 animate-spin" />}
                        {t('vendorAuth.logIn')}
                    </Button>
                </div>
                <div className="text-muted-foreground text-center text-sm">
                    {t('vendorAuth.dontHaveAccount')} <TextLink href={route('vendor.register')}>{t('vendorAuth.signUp')}</TextLink>
                </div>
            </form>
            {status && <div className="mb-4 text-center text-sm font-medium text-green-600">{status}</div>}
        </AuthLayout>
    );
}
