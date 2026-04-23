<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\User;
use Spatie\Permission\Models\Role;
use Illuminate\Support\Str;
use App\Models\Vendor;
use App\Models\Subscription;
use App\Models\VendorSubscription;

class UserSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        // Create admin user
        $admin = User::firstOrCreate(
            ['email' => 'admin@example.com'],
            [
                'full_name' => 'Admin User',
                'email_verified_at' => now(),
                'password' => bcrypt('Admin@123'),
                'role' => 'admin'
            ]
        );
        $admin->assignRole('admin');

        // Create vendor user
        $vendor = User::firstOrCreate(
            ['email' => 'vendor@example.com'],
            [
                'full_name' => 'Vendor User',
                'email_verified_at' => now(),
                'password' => bcrypt('Vendor@123'),
                'role' => 'vendor'
            ]
        );
        $vendor->assignRole('vendor');

        // Create vendor profile for vendor user
        Vendor::firstOrCreate([
            'user_id' => $vendor->id,
        ], [
            'category_id' => null,
            'name' => 'Testing Vendor',
            'brand_name_en' => null,
            'brand_name_ar' => null,
            'description_en' => null,
            'description_ar' => null,
            'logo' => null,
            'mobile' => $vendor->mobile ?? '00000000',
            'email' => $vendor->email,
            'status' => 'active',
            'commission' => 10,
            'kyc_status' => 'approved',
            'kyc_rejection_reason_en' => null,
            'kyc_rejection_reason_ar' => null,
            'kyc_documents' => null,
            'is_verified' => true,
        ]);

        // Create 20 fake users with role 'user'
        User::factory()
            ->count(1)
            ->create([
                'role' => 'user',
            ])
            ->each(function ($user) {
                $user->assignRole('user');
            });

        $vendors = Vendor::all();
        $subscriptions = Subscription::pluck('id')->toArray();

        foreach ($vendors as $vendor) {
            VendorSubscription::create([
                'vendor_id'        => $vendor->id,
                'subscription_id'  => fake()->randomElement($subscriptions),
                'start_date'       => now()->subDays(rand(0, 365)),
                'end_date'         => now()->addDays(rand(30, 365)),
                'status'           => fake()->randomElement(['active', 'expired', 'pending']),
                'payment_status'   => fake()->randomElement(['paid', 'pending', 'failed']),
                'transaction_id'   => 'TXN' . fake()->unique()->numerify('########'),
            ]);
        }
    }
}
