<?php

return [
    'username' => env('SMSBOX_USERNAME', 'Expoza'),
    'password' => env('SMSBOX_PASSWORD', 'VGA116677'),
    'url' => env('SMSBOX_URL', 'https://smsbox.com/smsgateway/services/messaging.asmx/Http_SendSMS'),
    'customer_id' => env('SMSBOX_CUSTOMER_ID', '3504'),
    'sender_id' => env('SMSBOX_SENDER_ID', 'Expoza'),
    'default_country_code' => env('SMSBOX_DEFAULT_COUNTRY_CODE', '965'),
    'timeout' => env('SMSBOX_TIMEOUT', 10),
];
