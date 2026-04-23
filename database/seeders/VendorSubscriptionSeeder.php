<?php

namespace Database\Seeders;

use App\Models\Vendor;
use App\Models\Subscription;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;
use Carbon\Carbon;

class VendorSubscriptionSeeder extends Seeder
{
    public function run(): void
    {
        $vendors = Vendor::inRandomOrder()->take(10)->get();
        $subscriptions = Subscription::all();

        foreach ($vendors as $vendor) {
            $subscription = $subscriptions->random();

            $startDate = Carbon::now()->subDays(rand(0, 60));
            $duration = $subscription->duration === 'monthly' ? 30 : 365;
            $endDate = (clone $startDate)->addDays($duration);

            DB::table('vendor_subscriptions')->insert([
                'vendor_id' => $vendor->id,
                'subscription_id' => $subscription->id,
                'start_date' => $startDate->toDateString(),
                'end_date' => $endDate->toDateString(),
                'status' => 'active',
                'payment_status' => 'paid',
                'transaction_id' => Str::upper(Str::random(10)),
                'created_at' => now(),
                'updated_at' => now(),
            ]);
        }
    }
}
