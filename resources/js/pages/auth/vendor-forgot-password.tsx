import { useState } from 'react';
import { Head, useForm, router } from '@inertiajs/react';
import { Errors } from '@inertiajs/core';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import toast from 'react-hot-toast';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Phone, ArrowLeft, Eye, EyeOff } from 'lucide-react'; // Added icons
import AuthLayout from '@/layouts/auth-layout';
import InputError from '@/components/input-error';
import { FlashData } from '@/types';
import React from 'react';
import { useOtp } from '@/hooks/use-otp';

interface Props {
    flash: FlashData;
}

export default function VendorForgotPassword({ flash }: Props) {
    const [step, setStep] = useState(1);
    const [success, setSuccess] = useState(flash?.success || '');
    const [resetToken, setResetToken] = useState(flash?.token || '');
    const [password, setPassword] = useState('');
    const [passwordConfirmation, setPasswordConfirmation] = useState('');
    const [showPassword, setShowPassword] = useState(false); // Added state
    const [showConfirmPassword, setShowConfirmPassword] = useState(false); // Added state
    const { data, setData, post, processing, errors } = useForm({ phone: '', otp: '' });

    // Use the custom hook
    const { generateAndSendOtp, verifyLocalOtp, otpSent, loading: otpLoading } = useOtp();

    // Step 1: Send OTP
    const handleSendOtp = (e: React.FormEvent) => {
        e.preventDefault();

        // First check if user exists via backend
        post(route('vendor.password.email'), {
            onSuccess: async () => {
                // If user exists, backend returns success. Now generate & send OTP from frontend.
                await generateAndSendOtp(data.phone, 'Your OTP for Expoza password reset is:');
                setStep(2);
            },
            onError: (err) => {
                console.error("User check failed", err);
                // Errors are displayed by InputError component
            }
        });
    };

    // Step 2: Verify OTP
    const handleVerifyOtp = (e: React.FormEvent) => {
        e.preventDefault();

        // Frontend verification
        if (verifyLocalOtp(data.otp)) {
            // OTP matched! Call backend to get reset token
            post(route('vendor.verify-otp'), {
                onSuccess: (page) => {
                    const flash = page.props.flash as FlashData; // Cast to known type
                    if (flash?.token) {
                        setResetToken(flash.token);
                        setStep(3);
                    } else {
                        toast.error('Failed to get reset token from backend.');
                    }
                },
                onError: (err) => {
                    console.error("Backend OTP verification failed", err);
                }
            });
        } else {
            toast.error('Invalid OTP');
        }
    };

    // Step 3: Reset Password
    const handleResetPassword = (e: React.FormEvent) => {
        e.preventDefault();

        // Use manual router visit to include all data (password state + phone/token)
        router.post(route('vendor.password.update'), {
            phone: data.phone,
            token: resetToken,
            password,
            password_confirmation: passwordConfirmation,
        }, {
            onSuccess: () => {
                setStep(4);
                toast.success('Password reset successfully!');
            },
            onError: (err) => {
                console.error("Password reset failed", err);
                // We can also assume specific errors map to fields if needed
            }
        });
    };

    // Listen for Inertia page changes to update flash/token/step
    React.useEffect(() => {
        if (flash?.success) setSuccess(flash.success);
        if (flash?.token) setResetToken(flash.token);
        // Step logic: if token present, move to step 3
        if (flash?.token) setStep(3);
    }, [flash.success, flash.token]);

    return (
        <AuthLayout title="Forgot Password" description="Enter your phone number to receive password reset instructions">
            <Head title="Forgot Password" />
            <div className="flex items-center justify-center p-4">
                <Card className="w-full max-w-md">
                    <CardHeader className="text-center">
                        <CardTitle className="text-2xl">Forgot Password</CardTitle>
                        <CardDescription>
                            Vendor password reset with OTP verification
                        </CardDescription>
                    </CardHeader>
                    <CardContent>
                        {success && step !== 3 && (
                            <div className="mb-4 p-3 bg-green-50 border border-green-200 rounded-lg text-sm text-green-800 text-center">
                                {success}
                            </div>
                        )}
                        {step === 1 && (
                            <form onSubmit={handleSendOtp} className="space-y-4">
                                <div className="p-3 bg-blue-50 border border-blue-200 rounded-lg text-sm text-blue-800">
                                    We'll send password reset instructions to the email associated with your phone number.
                                </div>
                                <div>
                                    <Label htmlFor="phone">Phone Number</Label>
                                    <div className="relative">
                                        <Phone className="absolute left-3 top-3 h-4 w-4 text-muted-foreground" />
                                        <Input
                                            id="phone"
                                            type="tel"
                                            value={data.phone}
                                            onChange={(e) => setData('phone', e.target.value)}
                                            className="pl-10"
                                            placeholder="12345678"
                                            pattern="[0-9]{8}"
                                            required
                                        />
                                    </div>
                                    {errors.phone && <InputError message={errors.phone} />}
                                </div>
                                <Button type="submit" className="w-full" disabled={processing}>
                                    {processing ? 'Sending...' : 'Send OTP'}
                                </Button>
                            </form>
                        )}
                        {step === 2 && (
                            <form onSubmit={handleVerifyOtp} className="space-y-4">
                                <div>
                                    <Label htmlFor="otp">OTP</Label>
                                    <Input
                                        id="otp"
                                        type="text"
                                        value={data.otp}
                                        onChange={(e) => setData('otp', e.target.value)}
                                        placeholder="Enter OTP"
                                        required
                                    />
                                </div>
                                <Button type="submit" className="w-full" disabled={processing}>
                                    {processing ? 'Verifying...' : 'Verify OTP'}
                                </Button>
                            </form>
                        )}
                        {step === 3 && (
                            <form onSubmit={handleResetPassword} className="space-y-4">
                                <div>
                                    <Label htmlFor="password">New Password</Label>
                                    <div className="relative">
                                        <Input
                                            id="password"
                                            type={showPassword ? 'text' : 'password'}
                                            value={password}
                                            onChange={(e) => setPassword(e.target.value)}
                                            placeholder="New password"
                                            required
                                        />
                                        <button
                                            type="button"
                                            onClick={() => setShowPassword(!showPassword)}
                                            className="absolute right-3 top-1/2 -translate-y-1/2 text-gray-500 hover:text-gray-700"
                                        >
                                            {showPassword ? <EyeOff className="h-4 w-4" /> : <Eye className="h-4 w-4" />}
                                        </button>
                                    </div>
                                </div>
                                <div>
                                    <Label htmlFor="password_confirmation">Confirm New Password</Label>
                                    <div className="relative">
                                        <Input
                                            id="password_confirmation"
                                            type={showConfirmPassword ? 'text' : 'password'}
                                            value={passwordConfirmation}
                                            onChange={(e) => setPasswordConfirmation(e.target.value)}
                                            placeholder="Confirm new password"
                                            required
                                        />
                                        <button
                                            type="button"
                                            onClick={() => setShowConfirmPassword(!showConfirmPassword)}
                                            className="absolute right-3 top-1/2 -translate-y-1/2 text-gray-500 hover:text-gray-700"
                                        >
                                            {showConfirmPassword ? <EyeOff className="h-4 w-4" /> : <Eye className="h-4 w-4" />}
                                        </button>
                                    </div>
                                </div>
                                <Button type="submit" className="w-full" disabled={processing}>
                                    {processing ? 'Resetting...' : 'Reset Password'}
                                </Button>
                            </form>
                        )}
                        {step === 4 && (
                            <div className="text-center text-green-700 font-semibold">
                                Password reset successfully! <a href={route('vendor.login')} className="text-blue-600 underline ml-2">Login</a>
                            </div>
                        )}
                        <div className="mt-6 text-center">
                            <a
                                href={route('vendor.login')}
                                className="inline-flex items-center text-sm text-muted-foreground hover:text-foreground"
                            >
                                <ArrowLeft className="h-4 w-4 mr-1" />
                                Back to login
                            </a>
                        </div>
                    </CardContent>
                </Card>
            </div>
        </AuthLayout>
    );
} 
