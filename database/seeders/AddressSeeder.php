<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Address;
use App\Models\User;

class AddressSeeder extends Seeder
{
    public function run(): void
    {
        $users = User::where('role', 'user')->get();
        foreach ($users as $user) {
            Address::create([
                'user_id'    => $user->id,
                'role_name'  => $user->role, // yahan user ka actual role aa jayega
                'full_name'  => $user->full_name,
                'line_1'     => fake()->streetAddress,
                'line_2'     => fake()->secondaryAddress,
                'country_id' => 1,
                'state_id'   => 1,
                'city_id'     => 1,
                'pincode'    => fake()->postcode,
                'is_default' => true,
                'phone'      => fake()->phoneNumber,
                'status'     => 'active',
            ]);
        }
    }
} 