// Components
import { useState } from 'react';
import { Head } from '@inertiajs/react';
import { LoaderCircle } from 'lucide-react';
import toast from 'react-hot-toast';

import InputError from '@/components/input-error';
import TextLink from '@/components/text-link';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import AuthLayout from '@/layouts/auth-layout';

export default function ForgotPassword() {
    const [step, setStep] = useState<'email' | 'otp' | 'reset'>('email');
    const [email, setEmail] = useState('');
    const [otp, setOtp] = useState('');
    const [password, setPassword] = useState('');
    const [passwordConfirmation, setPasswordConfirmation] = useState('');
    const [processing, setProcessing] = useState(false);
    const [errors, setErrors] = useState<Record<string, string>>({});

    const validatePassword = (password: string) => {
        if (password.length < 8) return 'Password must be at least 8 characters.';
        if (!/[A-Z]/.test(password)) return 'Password must contain at least one uppercase letter.';
        if (!/[0-9]/.test(password)) return 'Password must contain at least one number.';
        return '';
    };

    const handleEmailSubmit = async (e: React.FormEvent) => {
        e.preventDefault();
        setProcessing(true);
        setErrors({});
        try {
            const res = await fetch('/api/send-email-otp', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ email }),
            });
            const data = await res.json();
            if (res.ok) {
                toast.success('OTP sent to your email');
                setStep('otp');
            } else {
                setErrors(data.errors || {});
                toast.error(data.message || 'Failed to send OTP');
            }
        } catch {
            toast.error('Network error');
        } finally {
            setProcessing(false);
        }
    };

    const handleOtpSubmit = async (e: React.FormEvent) => {
        e.preventDefault();
        setProcessing(true);
        setErrors({});
        try {
            const res = await fetch('/api/verify-email-otp', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ email, otp }),
            });
            const data = await res.json();
            if (res.ok) {
                toast.success('OTP verified!');
                setStep('reset');
            } else {
                setErrors(data.errors || {});
                toast.error(data.message || 'Invalid OTP');
            }
        } catch {
            toast.error('Network error');
        } finally {
            setProcessing(false);
        }
    };

    const handleResetSubmit = async (e: React.FormEvent) => {
        e.preventDefault();
        setProcessing(true);
        setErrors({});
        const passwordError = validatePassword(password);
        if (passwordError) {
            toast.error(passwordError);
            setProcessing(false);
            return;
        }
        if (password !== passwordConfirmation) {
            toast.error('Passwords do not match');
            setProcessing(false);
            return;
        }
        try {
            const res = await fetch('/api/reset-password-with-otp', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ email, otp, password, password_confirmation: passwordConfirmation }),
            });
            const data = await res.json();
            if (res.ok) {
                toast.success('Password reset successfully!');
                setStep('email');
                setEmail('');
                setOtp('');
                setPassword('');
                setPasswordConfirmation('');
            } else {
                setErrors(data.errors || {});
                toast.error(data.message || 'Failed to reset password');
            }
        } catch {
            toast.error('Network error');
        } finally {
            setProcessing(false);
        }
    };

    return (
        <AuthLayout title="Forgot password" description="Reset your password with email OTP">
            <Head title="Forgot password" />
            <div className="space-y-6">
                {step === 'email' && (
                    <form onSubmit={handleEmailSubmit}>
                        <div className="grid gap-2">
                            <Label htmlFor="email">Email address</Label>
                            <Input
                                id="email"
                                type="email"
                                name="email"
                                autoComplete="off"
                                value={email}
                                autoFocus
                                onChange={(e) => setEmail(e.target.value)}
                                placeholder="email@example.com"
                                required
                            />
                            <InputError message={errors.email} />
                        </div>
                        <div className="my-6 flex items-center justify-start">
                            <Button className="w-full" disabled={processing}>
                                {processing && <LoaderCircle className="h-4 w-4 animate-spin" />}
                                Send OTP
                            </Button>
                        </div>
                    </form>
                )}
                {step === 'otp' && (
                    <form onSubmit={handleOtpSubmit}>
                        <div className="grid gap-2">
                            <Label htmlFor="otp">Enter OTP</Label>
                            <Input
                                id="otp"
                                type="text"
                                name="otp"
                                autoComplete="off"
                                value={otp}
                                onChange={(e) => setOtp(e.target.value)}
                                placeholder="6-digit code"
                                required
                                maxLength={6}
                            />
                            <InputError message={errors.otp} />
                        </div>
                        <div className="my-6 flex items-center justify-start">
                            <Button className="w-full" disabled={processing}>
                                {processing && <LoaderCircle className="h-4 w-4 animate-spin" />}
                                Verify OTP
                            </Button>
                        </div>
                    </form>
                )}
                {step === 'reset' && (
                    <form onSubmit={handleResetSubmit}>
                        <div className="grid gap-2 mb-5">
                            <Label htmlFor="password">New password</Label>
                            <Input
                                id="password"
                                type="password"
                                name="password"
                                autoComplete="new-password"
                                value={password}
                                onChange={(e) => setPassword(e.target.value)}
                                placeholder="New password"
                                required
                            />
                            <InputError message={errors.password} />
                        </div>
                        <div className="grid gap-2">
                            <Label htmlFor="password_confirmation">Confirm password</Label>
                            <Input
                                id="password_confirmation"
                                type="password"
                                name="password_confirmation"
                                autoComplete="new-password"
                                value={passwordConfirmation}
                                onChange={(e) => setPasswordConfirmation(e.target.value)}
                                placeholder="Confirm password"
                                required
                            />
                            <InputError message={errors.password_confirmation} />
                        </div>
                        <div className="my-6 flex items-center justify-start">
                            <Button className="w-full" disabled={processing}>
                                {processing && <LoaderCircle className="h-4 w-4 animate-spin" />}
                                Reset Password
                            </Button>
                        </div>
                    </form>
                )}
                <div className="text-muted-foreground space-x-1 text-center text-sm">
                    <span>Or, return to</span>
                    <TextLink href={route('login')}>log in</TextLink>
                </div>
            </div>
        </AuthLayout>
    );
}
