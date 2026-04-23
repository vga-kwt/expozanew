<?php

namespace Database\Seeders;

use App\Models\User;
// use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    /**
     * Seed the application's database.
     */
    public function run(): void
    {
        // User::factory(10)->create();

        $this->call([
            RoleSeeder::class,
            PermissionSeeder::class,
            SubscriptionSeeder::class,
            UserSeeder::class,
            CountrySeeder::class,
            StateSeeder::class,
            CitySeeder::class,
            // AddressSeeder::class,
            // ExpoSeeder::class,
            // ExpoVendorSeeder::class,
            // SlotBookingSeeder::class,
            // CategorySeeder::class,
            // ProductSeeder::class,
            // OrderSeeder::class,
            // ExpoProductSeeder::class,
            // VendorSeeder::class,
            // VendorSubscriptionSeeder::class,
            // AdSeeder::class,
            // SectionSeeder::class,
            CmsPageSeeder::class,
            // FinanceSeeder::class,
            // VendorPayoutSeeder::class,
            // AuditLogSeeder::class,
            // FaqSeeder::class
        ]);
    }
}
