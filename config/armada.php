<?php

return [
    /*
    |--------------------------------------------------------------------------
    | Armada Delivery API Configuration
    |--------------------------------------------------------------------------
    |
    | Configuration for Armada Delivery API integration
    |
    */

    'enabled' => env('ARMADA_ENABLED', false),

    'base_url' => env('ARMADA_BASE_URL', 'https://staging.api.armadadelivery.com'),

    'api_key' => env('ARMADA_API_KEY'),

    'main_api_key' => env('ARMADA_MAIN_API_KEY'),

    'branch_id' => env('ARMADA_BRANCH_ID'),

    'webhook_key' => env('ARMADA_WEBHOOK_KEY'),

    'timeout' => env('ARMADA_TIMEOUT', 30),

    /*
    |--------------------------------------------------------------------------
    | Webhook Configuration
    |--------------------------------------------------------------------------
    |
    | Webhook settings for receiving updates from Armada
    |
    */

    'webhook_secret' => env('ARMADA_WEBHOOK_SECRET'),

    'webhook_url' => env('ARMADA_WEBHOOK_URL', '/api/webhooks/armada'),

    /*
    |--------------------------------------------------------------------------
    | Default Settings
    |--------------------------------------------------------------------------
    |
    | Default values for order creation
    |
    */

    'default_currency' => env('ARMADA_DEFAULT_CURRENCY', 'KWD'),

    'default_country' => env('ARMADA_DEFAULT_COUNTRY', 'KW'),

    /*
    |--------------------------------------------------------------------------
    | Country Code Mapping
    |--------------------------------------------------------------------------
    |
    | Map country names to ISO country codes for Armada API
    |
    */

    'country_codes' => [
        'Kuwait' => 'KW',
        'Bahrain' => 'BH',
        'Saudi Arabia' => 'SA',
        'UAE' => 'AE',
        'Oman' => 'OM',
        'Qatar' => 'QA',
    ],

    /*
    |--------------------------------------------------------------------------
    | Payment Method Mapping
    |--------------------------------------------------------------------------
    |
    | Map internal payment methods to Armada payment methods
    |
    */

    'payment_methods' => [
        'cash_on_delivery' => 'cod',
        'cod' => 'cod',
        'credit_card' => 'card',
        'card' => 'card',
        'knet' => 'knet',
        'visa/master' => 'card',
        'apple pay' => 'card',
        'paypal' => 'paypal',
    ],

    /*
    |--------------------------------------------------------------------------
    | Status Mapping
    |--------------------------------------------------------------------------
    |
    | Map Armada statuses to internal order statuses
    |
    */

    'status_mapping' => [
        'pending' => 'pending',
        'confirmed' => 'confirmed',
        'picked_up' => 'processing',
        'in_transit' => 'shipped',
        'out_for_delivery' => 'out_for_delivery',
        'delivered' => 'delivered',
        'cancelled' => 'cancelled',
        'failed' => 'failed',
        'returned' => 'returned',
    ],
];
