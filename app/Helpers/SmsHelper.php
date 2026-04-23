<?php

use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

if (!function_exists('send_sms')) {
    /**
     * Send SMS using SMSBox API
     * Matches frontend implementation for consistency
     * 
     * @param string $to Phone number (8 digits without country code)
     * @param string $message Message content
     * @return bool Success status
     */
    function send_sms($to, $message)
    {
        // SMSBox credentials (matching frontend)
        $username = 'Expoza';
        $password = 'VGA116677';
        $customerId = '3504';
        $senderId = 'Expoza';
        $baseUrl = 'https://smsbox.com/smsgateway/services/messaging.asmx/Http_SendSMS';

        // Format phone number - ensure it has 965 prefix
        $phoneNumber = preg_replace('/[^0-9]/', '', $to);

        // If 8 digits, prepend 965
        if (strlen($phoneNumber) === 8) {
            $phoneNumber = '965' . $phoneNumber;
        }
        // If doesn't start with 965, prepend it
        elseif (!str_starts_with($phoneNumber, '965')) {
            $phoneNumber = '965' . $phoneNumber;
        }

        try {
            // Build URL with query parameters (same as frontend)
            $params = [
                'username' => $username,
                'password' => $password,
                'customerid' => $customerId,
                'sendertext' => $senderId,
                'messagebody' => $message,
                'recipientnumbers' => $phoneNumber,
                'defdate' => '',
                'isblink' => 'false',
                'isflash' => 'false',
            ];

            $fullUrl = $baseUrl . '?' . http_build_query($params);

            Log::info('SMSBox Request (Backend)', [
                'phone' => $phoneNumber,
                'original_input' => $to,
                'message' => $message,
                'url' => $fullUrl,
            ]);

            // Send GET request
            $response = Http::timeout(10)->get($baseUrl, $params);

            if ($response->successful()) {
                Log::info('SMSBox Success (Backend)', [
                    'phone' => $phoneNumber,
                    'status' => $response->status(),
                    'response' => $response->body(),
                ]);
                return true;
            } else {
                Log::error('SMSBox Failed (Backend)', [
                    'phone' => $phoneNumber,
                    'status' => $response->status(),
                    'response' => $response->body(),
                ]);
                return false;
            }
        } catch (\Exception $e) {
            Log::error('SMSBox Exception (Backend)', [
                'phone' => $phoneNumber ?? $to,
                'error' => $e->getMessage(),
            ]);
            return false;
        }
    }
}