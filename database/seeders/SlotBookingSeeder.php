<?php

namespace Database\Seeders;

use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use App\Models\SlotBooking;
use App\Models\Expo;
use App\Models\Vendor;

class SlotBookingSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        // Get some expos and vendors for testing
        $expos = Expo::take(3)->get();
        $vendors = Vendor::take(5)->get();

        if ($expos->isEmpty() || $vendors->isEmpty()) {
            $this->command->info('No expos or vendors found. Please run ExpoSeeder and VendorSeeder first.');
            return;
        }

        foreach ($expos as $expo) {
            foreach ($vendors->take(2) as $vendor) {
                // Create a sample booking for each vendor-expo combination
                $bookedSlots = [1]; // Sample slots
                $totalAmount = count($bookedSlots) * 100; // $100 per slot

                SlotBooking::create([
                    'expo_id' => $expo->id,
                    'vendor_id' => $vendor->id,
                    'booked_slots' => $bookedSlots,
                    'total_amount' => $totalAmount,
                    'slot_number' => $bookedSlots[0],
                    'payment_status' => 'paid',
                    'transaction_id' => 'TXN_' . time() . '_' . rand(1000, 9999),
                ]);
            }
        }

        $this->command->info('SlotBookingSeeder completed successfully.');
    }
} 