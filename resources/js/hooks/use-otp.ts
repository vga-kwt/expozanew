import { useState } from 'react';
import toast from 'react-hot-toast';

export const useOtp = () => {
    const [generatedOtp, setGeneratedOtp] = useState<string | null>(null);
    const [otpSent, setOtpSent] = useState(false);
    const [loading, setLoading] = useState(false);

    /**
     * Generates a random 6-digit OTP and sends it via SMS Gateway
     * @param phone Phone number (without country code)
     * @param messagePrefix Message prefix (e.g., "Your OTP is:")
     * @param countryCode Country code (default: 965)
     */
    const generateAndSendOtp = async (phone: string, messagePrefix: string = 'Your OTP is:', countryCode: string = '965') => {
        setLoading(true);
        const otp = Math.floor(100000 + Math.random() * 900000).toString();

        // Construct message and URL
        const phoneNumber = `${countryCode}${phone}`;
        const messageBody = `${messagePrefix} ${otp}`;
        const smsUrl = `https://smsbox.com/smsgateway/services/messaging.asmx/Http_SendSMS?username=Expoza&password=VGA116677&customerid=3504&sendertext=Expoza&messagebody=${encodeURIComponent(messageBody)}&recipientnumbers=${phoneNumber}&defdate=&isblink=false&isflash=false`;

        // Log URL for verification
        // console.log('Sending OTP via SMSBox:', smsUrl);

        try {
            await fetch(smsUrl, {
                method: 'GET',
                mode: 'no-cors' // Response is opaque, we assume success
            });

            // On success (or presumed success)
            setGeneratedOtp(otp);
            setOtpSent(true);
            toast.success(`OTP sent to ${phoneNumber}`);

            // Log for debugging in console (since smsbox might fail CORS silently)
            // console.log('UseOtp Hook: Generated OTP:', otp);
        } catch (error) {
            console.error('SMS Gateway Error:', error);
            // Fallback: still set OTP so user can test if they saw console log or if it actually worked
            setGeneratedOtp(otp);
            setOtpSent(true);
            toast.success('OTP Generated (SMS network check required)');
        } finally {
            setLoading(false);
        }
        return otp;
    };

    /**
     * Verifies the input OTP against the generated OTP
     */
    const verifyLocalOtp = (inputOtp: string) => {
        if (!generatedOtp) return false;
        return inputOtp === generatedOtp;
    };

    /**
     * Resets the OTP state
     */
    const resetOtp = () => {
        setGeneratedOtp(null);
        setOtpSent(false);
        setLoading(false);
    };

    return {
        generatedOtp,
        otpSent,
        loading,
        generateAndSendOtp,
        verifyLocalOtp,
        resetOtp
    };
};
