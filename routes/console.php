<?php

use Illuminate\Foundation\Inspiring;
use Illuminate\Support\Facades\Artisan;
use Illuminate\Support\Facades\Schedule;

/*
|--------------------------------------------------------------------------
| Console Routes
|--------------------------------------------------------------------------
|
| This file is where you may define all of your Closure based console
| commands. Each Closure is bound to a command instance allowing a
| simple approach to interacting with each command's IO methods.
|
*/

Artisan::command('inspire', function () {
    $this->comment(Inspiring::quote());
})->purpose('Display an inspiring quote');

// Schedule the expo expiry command to run daily
Schedule::command('expos:expire')->daily();

// Schedule payout generation based on settings
Schedule::call(function () {
    $payoutFrequency = \App\Models\Setting::where('key', 'payout_frequency')->value('value') ?? '15_days';
    
    switch ($payoutFrequency) {
        case '15_days':
            // Run on 16th (end of first period) and last day of month (end of second period)
            $dayOfMonth = now()->day;
            $lastDayOfMonth = now()->endOfMonth()->day;
            
            if ($dayOfMonth === 16 || $dayOfMonth === $lastDayOfMonth) {
                \Illuminate\Support\Facades\Artisan::call('payouts:generate');
            }
            break;
        case 'monthly':
            // Run on 1st of every month (for previous month's earnings)
            if (now()->day === 1) {
                \Illuminate\Support\Facades\Artisan::call('payouts:generate');
            }
            break;
        case 'custom':
            // Check if today matches custom date
            $customDate = \App\Models\Setting::where('key', 'custom_payout_date')->value('value');
            if ($customDate && now()->format('Y-m-d') === \Carbon\Carbon::parse($customDate)->format('Y-m-d')) {
                \Illuminate\Support\Facades\Artisan::call('payouts:generate');
            }
            break;
    }
})->daily(); // Check daily, but only run based on frequency logic
