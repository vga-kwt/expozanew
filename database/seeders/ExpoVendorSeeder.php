<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;
use Carbon\Carbon;
use App\Models\Expo;
use App\Models\Vendor;
use App\Models\ExpoVendor;
use App\Models\Address;

class ExpoVendorSeeder extends Seeder
{
    public function run()
    {
        $expos = Expo::all();
        $vendors = Vendor::all();
        
        // Get available address IDs
        $addressIds = Address::pluck('id')->toArray();
        
        foreach ($expos as $expo) {
            foreach ($vendors as $vendor) {
                // Use a random address ID if available, otherwise null
                $addressId = !empty($addressIds) ? $addressIds[array_rand($addressIds)] : null;
                
                ExpoVendor::firstOrCreate([
                    'expo_id' => $expo->id,
                    'vendor_id' => $vendor->id,
                ], [
                    'name'           => $vendor->name,
                    'description'    => 'Description for vendor ' . $vendor->id,
                    'address_id'     => $addressId,
                    'email'          => $vendor->email,
                    'mobile'         => $vendor->mobile ?? '555000' . str_pad($vendor->id, 3, '0', STR_PAD_LEFT),
                    'slot'           => rand(1, 20),
                    'status'         => ['active','pending'][array_rand(['active','pending'])],
                    'products_count' => rand(1, 50),
                    'notes'          => 'Notes for vendor ' . $vendor->id,
                    'approved_at'    => Carbon::now()->subDays(rand(1, 30)),
                    'joined_at'      => Carbon::now()->subDays(rand(1, 30)),
                    'created_at'     => Carbon::now()->subDays(rand(1, 30)),
                    'updated_at'     => Carbon::now(),
                ]);
            }
        }
    }
}
