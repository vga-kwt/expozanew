<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

class MyFatoorahTestController extends Controller
{
    public function index()
    {
        return view('test-myfatoorah');
    }
    
    public function testApiKey(Request $request)
    {
        $apiKey = $request->input('api_key') ?: config('myfatoorah.api_key');
        $testMode = config('myfatoorah.test_mode');
        $countryCode = config('myfatoorah.country_iso');
        
        if (empty($apiKey)) {
            return response()->json([
                'success' => false,
                'message' => 'API Key is not set. Please set MYFATOORAH_API_KEY in .env file.',
            ], 400);
        }
        
        // API URL based on test/live mode
        $baseUrl = $testMode 
            ? 'https://apitest.myfatoorah.com'
            : 'https://api.myfatoorah.com';
        
        $testData = [
            'CustomerName' => 'Test Customer',
            'NotificationOption' => 'Lnk',
            'InvoiceValue' => 1.0,
            'DisplayCurrencyIso' => 'KWD',
            'MobileCountryCode' => '+965',
            'CustomerMobile' => '12345678',
            'CustomerEmail' => 'test@example.com',
            'CallBackUrl' => 'http://localhost/callback',
            'ErrorUrl' => 'http://localhost/error',
            'Language' => 'en',
            'CustomerReference' => 'test_' . time(),
        ];
        
        try {
            $response = Http::withHeaders([
                'Authorization' => 'Bearer ' . $apiKey,
                'Content-Type' => 'application/json',
            ])
                ->timeout(10)
                ->post($baseUrl . '/v2/SendPayment', $testData);
            
            $httpStatus = $response->status();
            $responseBody = $response->body();
            $responseJson = $response->json();
            
            if ($httpStatus === 200) {
                if (isset($responseJson['IsSuccess']) && $responseJson['IsSuccess']) {
                    return response()->json([
                        'success' => true,
                        'message' => '✅ API Key is valid and working!',
                        'invoice_url' => $responseJson['Data']['InvoiceURL'] ?? null,
                        'details' => [
                            'mode' => $testMode ? 'Test' : 'Live',
                            'country' => $countryCode,
                            'api_url' => $baseUrl,
                        ],
                    ]);
                } else {
                    return response()->json([
                        'success' => false,
                        'message' => $responseJson['Message'] ?? 'Payment failed',
                        'details' => $responseJson,
                    ], 400);
                }
            } elseif ($httpStatus === 401) {
                return response()->json([
                    'success' => false,
                    'message' => '❌ Invalid API Key (401 Unauthorized)',
                    'instructions' => [
                        '1. Login to: https://portal.myfatoorah.com/',
                        '2. Go to: Integration Settings → API Key',
                        '3. Create a new ' . ($testMode ? 'Test' : 'Live') . ' API Key',
                        '4. Update .env file: MYFATOORAH_API_KEY=your_new_key',
                        '5. Set MYFATOORAH_MODE=' . ($testMode ? 'test' : 'live') . ' in .env',
                        '6. Run: php artisan config:clear',
                    ],
                    'details' => [
                        'http_status' => $httpStatus,
                        'mode' => $testMode ? 'Test' : 'Live',
                        'country' => $countryCode,
                        'api_key_preview' => substr($apiKey, 0, 30) . '...',
                    ],
                ], 401);
            } else {
                return response()->json([
                    'success' => false,
                    'message' => "HTTP {$httpStatus} error",
                    'details' => $responseJson,
                ], $httpStatus);
            }
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Error: ' . $e->getMessage(),
            ], 500);
        }
    }
}

