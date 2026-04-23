<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

class TestMyFatoorahKey extends Command
{
    protected $signature = 'myfatoorah:test-key {--key=}';
    protected $description = 'Test MyFatoorah API key validity';

    public function handle()
    {
        $apiKey = $this->option('key') ?: config('myfatoorah.api_key');
        $testMode = config('myfatoorah.test_mode');
        $countryCode = config('myfatoorah.country_iso');
        
        if (empty($apiKey)) {
            $this->error('❌ API Key is not set!');
            $this->info('Please set MYFATOORAH_API_KEY in your .env file');
            return 1;
        }
        
        $baseUrl = $testMode 
            ? 'https://apitest.myfatoorah.com'
            : 'https://api.myfatoorah.com';
        
        $this->info('Testing MyFatoorah API Key...');
        $this->info('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        $this->info("Mode: " . ($testMode ? "Test" : "Live"));
        $this->info("Country: {$countryCode}");
        $this->info("API URL: {$baseUrl}/v2/SendPayment");
        $this->info("API Key: " . substr($apiKey, 0, 30) . '...' . substr($apiKey, -10));
        $this->info('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        
        // Test with a minimal payment request
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
            $this->info('Sending test request...');
            
            $response = Http::withHeaders([
                'Authorization' => 'Bearer ' . $apiKey,
                'Content-Type' => 'application/json',
            ])
                ->timeout(10)
                ->post($baseUrl . '/v2/SendPayment', $testData);
            
            $httpStatus = $response->status();
            $responseBody = $response->body();
            $responseJson = $response->json();
            
            $this->info("HTTP Status: {$httpStatus}");
            
            if ($httpStatus === 200) {
                if (isset($responseJson['IsSuccess']) && $responseJson['IsSuccess']) {
                    $this->info('✅ SUCCESS! API Key is valid and working.');
                    $this->info("Invoice URL: " . ($responseJson['Data']['InvoiceURL'] ?? 'N/A'));
                    return 0;
                } else {
                    $errorMsg = $responseJson['Message'] ?? 'Unknown error';
                    $this->warn("⚠️  API responded but payment failed: {$errorMsg}");
                    return 1;
                }
            } elseif ($httpStatus === 401) {
                $this->error('❌ FAILED! Invalid API Key (401 Unauthorized)');
                $this->newLine();
                $this->info('To fix this:');
                $this->info('1. Login to: https://portal.myfatoorah.com/');
                $this->info('2. Go to: Integration Settings → API Key');
                $this->info('3. Create a new ' . ($testMode ? 'Test' : 'Live') . ' API Key');
                $this->info('4. Update .env file: MYFATOORAH_API_KEY=your_new_key');
                $this->info('5. Run: php artisan config:clear');
                return 1;
            } else {
                $errorMsg = $responseJson['Message'] ?? "HTTP {$httpStatus} error";
                $this->error("❌ FAILED! HTTP {$httpStatus}: {$errorMsg}");
                if (!empty($responseJson['ValidationErrors'])) {
                    $this->error('Validation Errors:');
                    foreach ($responseJson['ValidationErrors'] as $error) {
                        $this->error("  - {$error['Name']}: {$error['Error']}");
                    }
                }
                return 1;
            }
        } catch (\Exception $e) {
            $this->error('❌ ERROR: ' . $e->getMessage());
            return 1;
        }
    }
}

