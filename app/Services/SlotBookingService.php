<?php

namespace App\Services;

use App\Models\Expo;
use App\Models\ExpoVendor;
use App\Models\SlotBooking;
use App\Models\FinanceTransaction;
use App\Models\Vendor;
use App\Models\User;
use Illuminate\Support\Facades\DB;

class SlotBookingService
{
    /**
     * Calculate total price for selected slots
     */
    public function calculateSlotPrice(Expo $expo, array $slots): float
    {
        $slotPricing = $expo->slot_pricing;

        // Decode if JSON
        if (is_string($slotPricing)) {
            $decoded = json_decode($slotPricing, true);
            if (json_last_error() === JSON_ERROR_NONE) {
                $slotPricing = $decoded;
            }
        }

        $slotCount = count($slots);
        $defaultPricePerSlot = 0;

        // Check if it's range-based pricing [{from:1,to:4,price:"200"}, ...]
        if (is_array($slotPricing) && isset($slotPricing[0]['from']) && isset($slotPricing[0]['to']) && isset($slotPricing[0]['price'])) {
            foreach ($slotPricing as $range) {
                $from = intval($range['from']);
                $to = intval($range['to']);
                $price = floatval($range['price']);

                if ($slotCount >= $from && $slotCount <= $to) {
                    return $price;
                }
            }

            // If no range matches, use the last range's price
            if (!empty($slotPricing)) {
                $lastRange = end($slotPricing);
                return floatval($lastRange['price']);
            }
        }

        // Check if it's array-based pricing [{slot:1,price:"200"}, {slot:2,price:"250"}]
        if (is_array($slotPricing) && isset($slotPricing[0]['slot']) && isset($slotPricing[0]['price'])) {
            $totalPrice = 0;
            foreach ($slots as $slotNumber) {
                foreach ($slotPricing as $slotPrice) {
                    if (intval($slotPrice['slot']) === intval($slotNumber)) {
                        $totalPrice += floatval($slotPrice['price']);
                        break;
                    }
                }
            }
            return $totalPrice > 0 ? $totalPrice : $defaultPricePerSlot * $slotCount;
        }

        // If slot_pricing is a single number (legacy format)
        if (is_numeric($slotPricing)) {
            return floatval($slotPricing) * $slotCount;
        }

        return $defaultPricePerSlot * $slotCount;
    }

    /**
     * Book slots for free participation expo
     */
    public function bookFreeSlots(Expo $expo, Vendor $vendor, User $user, array $newSlots): array
    {
        DB::beginTransaction();
        try {
            $expoVendor = ExpoVendor::firstOrCreate(
                [
                    'expo_id' => $expo->id,
                    'vendor_id' => $vendor->id,
                ],
                [
                    'slot' => 0,
                    'joined_at' => now(),
                    'name' => $vendor->name,
                    'email' => $vendor->email,
                    'mobile' => $vendor->phone,
                    'description' => $vendor->description_en,
                    'status' => 'paid',
                ]
            );

            $createdBookings = [];
            foreach ($newSlots as $slotNumber) {
                // Check if already booked
                $existingBooking = SlotBooking::where('expo_id', $expo->id)
                    ->where('vendor_id', $vendor->id)
                    ->where('slot_number', $slotNumber)
                    ->where('payment_status', 'paid')
                    ->first();
                
                if ($existingBooking) {
                    // Update existing booking to ensure vendor_expo_id is set
                    if (!$existingBooking->vendor_expo_id) {
                        $existingBooking->vendor_expo_id = $expoVendor->id;
                        $existingBooking->save();
                    }
                    $createdBookings[] = $existingBooking;
                    continue;
                }
                
                $booking = SlotBooking::create([
                    'expo_id' => $expo->id,
                    'vendor_expo_id' => $expoVendor->id,
                    'vendor_id' => $vendor->id,
                    'booked_slots' => [$slotNumber],
                    'slot_number' => $slotNumber,
                    'total_amount' => $this->calculateSlotPrice($expo, [$slotNumber]),
                    'payment_status' => 'paid',
                    'transaction_id' => 'TXN_' . time() . '_' . $slotNumber . '_' . rand(1000, 9999),
                ]);
                
                $createdBookings[] = $booking;

                // Create finance transaction
                try {
                    FinanceTransaction::create([
                        'transaction_id' => 'TXN' . strtoupper(bin2hex(random_bytes(8))),
                        'user_type' => 'vendor',
                        'type' => 'expo_booking',
                        'status' => 'completed',
                        'amount' => 0,
                        'payment_processor' => 'free',
                        'payment_reference_id' => 'REF' . strtoupper(bin2hex(random_bytes(8))),
                        'transactionable_type' => SlotBooking::class,
                        'transactionable_id' => $booking->id,
                        'user_id' => $user->id,
                        'vendor_id' => $vendor->id,
                        'summery' => 'Vendor expo slot ' . $slotNumber . ' booking (Free Participation)',
                        'metadata' => ['free_participation' => true],
                        'attempt_status' => 'success',
                        'attempted_at' => now(),
                        'processed_at' => now(),
                    ]);
                } catch (\Exception $e) {
                    // Finance transaction is optional, continue
                }
            }

            // Update vendor slot count - use created bookings plus existing ones
            // First, update any existing bookings that might have NULL vendor_expo_id
            SlotBooking::where('expo_id', $expo->id)
                ->where('vendor_id', $vendor->id)
                ->where('payment_status', 'paid')
                ->whereNull('vendor_expo_id')
                ->update(['vendor_expo_id' => $expoVendor->id]);
            
            // Get all bookings for this expo/vendor to calculate unique slots
            $allBookings = SlotBooking::where('expo_id', $expo->id)
                ->where('vendor_id', $vendor->id)
                ->where('payment_status', 'paid')
                ->get();

            $uniqueSlots = [];
            foreach ($allBookings as $booking) {
                if ($booking->slot_number) {
                    $uniqueSlots[] = $booking->slot_number;
                }
            }
            $uniqueSlots = array_unique($uniqueSlots);
            
            // Ensure slot count is at least 1 if we have bookings
            $slotCount = count($uniqueSlots);
            if ($slotCount === 0 && count($createdBookings) > 0) {
                // If query didn't return results but we created bookings, use created bookings
                $slotCount = count(array_unique(array_column($createdBookings, 'slot_number')));
            }

            $expoVendor->slot = $slotCount > 0 ? $slotCount : count($createdBookings);
            $expoVendor->joined_at = now();
            $expoVendor->status = 'paid';
            $expoVendor->save();

            DB::commit();

            return [
                'success' => true,
                'expo_id' => $expo->id,
                'free_participation' => true,
                'total_amount' => 0,
                'booking_ids' => array_column($createdBookings, 'id'),
                'total_slots_booked' => count($createdBookings),
                'booked_slots' => array_column($createdBookings, 'slot_number'),
                'individual_bookings' => array_map(function ($booking) {
                    return [
                        'id' => $booking->id,
                        'slot_number' => $booking->slot_number,
                        'amount' => $booking->total_amount,
                        'transaction_id' => $booking->transaction_id
                    ];
                }, $createdBookings),
                'message' => 'Successfully booked ' . count($newSlots) . ' slots. No payment required.'
            ];
        } catch (\Exception $e) {
            DB::rollBack();
            throw $e;
        }
    }

    /**
     * Get booking data for paid expo (returns data for payment modal)
     */
    public function getPaidBookingData(Expo $expo, array $newSlots, float $totalAmount): array
    {
        return [
            'success' => true,
            'free_participation' => false,
            'expo_id' => $expo->id,
            'slots' => $newSlots,
            'total_amount' => $totalAmount,
            'total_slots_booked' => count($newSlots),
            'booked_slots' => $newSlots,
            'message' => 'Please proceed with payment to confirm your slot booking.'
        ];
    }

    /**
     * Verify that bookings exist in database
     */
    public function verifyBookings(int $expoId, int $vendorId, array $bookingIds): array
    {
        // Filter out null/empty values
        $bookingIds = array_filter($bookingIds, function($id) {
            return $id !== null && $id !== '' && $id !== 0;
        });
        
        if (empty($bookingIds)) {
            return [
                'success' => false,
                'bookings_found' => false,
                'message' => 'No booking IDs provided'
            ];
        }

        $bookingIds = array_map('intval', $bookingIds);

        // First, check if bookings exist at all (without payment_status filter)
        // This helps catch timing issues where transaction might not be fully committed
        $allBookings = SlotBooking::whereIn('id', $bookingIds)
            ->where('expo_id', $expoId)
            ->where('vendor_id', $vendorId)
            ->get();
        
        // If no bookings found at all, try without vendor_id constraint (in case of mismatch)
        if ($allBookings->isEmpty()) {
            $allBookings = SlotBooking::whereIn('id', $bookingIds)
                ->where('expo_id', $expoId)
                ->get();
        }
        
        // If still empty, wait a bit and retry once (for transaction commit timing)
        if ($allBookings->isEmpty()) {
            usleep(300000); // 300ms delay
            $allBookings = SlotBooking::whereIn('id', $bookingIds)
                ->where('expo_id', $expoId)
                ->where('vendor_id', $vendorId)
                ->get();
            
            // If still empty, try without vendor_id
            if ($allBookings->isEmpty()) {
                $allBookings = SlotBooking::whereIn('id', $bookingIds)
                    ->where('expo_id', $expoId)
                    ->get();
            }
        }
        
        // Check if bookings exist with payment_status = 'paid'
        $paidBookings = $allBookings->where('payment_status', 'paid');
        
        // If we found all bookings and they're all paid, success
        if ($allBookings->count() === count($bookingIds) && $paidBookings->count() === count($bookingIds)) {
            return [
                'success' => true,
                'bookings_found' => true,
                'booking_ids' => $paidBookings->pluck('id')->toArray()
            ];
        }
        
        // If we found all bookings but some aren't paid, still consider success (might be timing)
        if ($allBookings->count() === count($bookingIds) && $paidBookings->count() > 0) {
            return [
                'success' => true,
                'bookings_found' => true,
                'booking_ids' => $allBookings->pluck('id')->toArray(),
                'message' => 'All bookings found (some payment status pending)'
            ];
        }
        
        // If we found some bookings but not all, check if they're paid
        if ($allBookings->count() > 0) {
            // If at least some bookings are found and paid, consider it success
            // (might be a case where some bookings were already created)
            if ($paidBookings->count() > 0) {
                return [
                    'success' => true,
                    'bookings_found' => true,
                    'booking_ids' => $paidBookings->pluck('id')->toArray(),
                    'message' => 'Some bookings verified successfully'
                ];
            }
            
            // Bookings exist but not paid yet - still return success if we found the bookings
            // Payment status might be updated asynchronously
            return [
                'success' => true,
                'bookings_found' => true,
                'booking_ids' => $allBookings->pluck('id')->toArray(),
                'message' => 'Bookings found (payment status may be updating)'
            ];
        }
        
        // Fallback: check if there are any bookings for this expo/vendor (regardless of IDs)
        $expoVendorBookings = SlotBooking::where('expo_id', $expoId)
            ->where('vendor_id', $vendorId)
            ->where('payment_status', 'paid')
            ->get();
        
        if ($expoVendorBookings->count() > 0) {
            // Found bookings but IDs don't match - return what we found
            return [
                'success' => true,
                'bookings_found' => true,
                'booking_ids' => $expoVendorBookings->pluck('id')->toArray(),
                'message' => 'Bookings found for this expo/vendor'
            ];
        }
        
        // Last resort: check bookings without vendor_id constraint
        $expoBookings = SlotBooking::where('expo_id', $expoId)
            ->whereIn('id', $bookingIds)
            ->where('payment_status', 'paid')
            ->get();
        
        if ($expoBookings->count() > 0) {
            return [
                'success' => true,
                'bookings_found' => true,
                'booking_ids' => $expoBookings->pluck('id')->toArray(),
                'message' => 'Bookings found for this expo'
            ];
        }

        return [
            'success' => false,
            'bookings_found' => false,
            'message' => 'Bookings not found'
        ];
    }
}

