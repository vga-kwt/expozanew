<?php

return [
    /**
     * API Token Key (string)
     * Accepted value:
     * Live Token: https://myfatoorah.readme.io/docs/live-token
     * 
     * Get your API key from: https://portal.myfatoorah.com → Integration Settings → API Key
     * For live mode, use Live API key
     */
    'api_key' => env('MYFATOORAH_API_KEY', 'SK_KWT_YSvHAOWZ5rLU79mEqRMEa5yaTwrBuCnj8mkVfwqItFpi8C0LKRuCjDmR2UHdVZVm'),
    /**
     * Test Mode (boolean)
     * Accepted value: true for the test mode or false for the live mode
     * LIVE MODE: Set to false for production
     */
    'test_mode' => false, // LIVE MODE - Testing disabled
    /**
     * Country ISO Code (string)
     * Accepted value: KWT, SAU, ARE, QAT, BHR, OMN, JOD, or EGY.
     * For Kuwait, UAE, Bahrain, Jordan, Oman: Use KWT, ARE, BHR, JOD, or OMN
     * API URL: https://api.myfatoorah.com/
     * Portal URL: https://portal.myfatoorah.com/
     */
    'country_iso' => env('MYFATOORAH_COUNTRY_ISO', 'KWT'),
    /**
     * Save card (boolean)
     * Accepted value: true if you want to enable save card options.
     * You should contact your account manager to enable this feature in your MyFatoorah account as well.
     */
    'save_card' => true,
    /**
     * Webhook secret key (string)
     * Enable webhook on your MyFatoorah account setting then paste the secret key here.
     * The webhook link is: https://{example.com}/myfatoorah/webhook
     */
    'webhook_secret_key' => '',
    /**
     * Register Apple Pay (boolean)
     * Set it to true to show the Apple Pay on the checkout page.
     * First, verify your domain with Apple Pay before you set it to true.
     * You can either follow the steps here: https://docs.myfatoorah.com/docs/apple-pay#verify-your-domain-with-apple-pay or contact the MyFatoorah support team (tech@myfatoorah.com).
     */
    'register_apple_pay' => false
];
