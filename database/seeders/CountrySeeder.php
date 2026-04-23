<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Country;
use App\Models\State;
use App\Models\City;

class CountrySeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        // Create Kuwait
        $kuwait = Country::updateOrCreate(
            ['name_en' => 'Kuwait'],
            [
                'name_ar' => 'الكويت',
                'status' => 'active',
            ]
        );

        // Create 10 states for Kuwait
        $states = [
            ['en' => 'Al Asimah', 'ar' => 'العاصمة'],
            ['en' => 'Hawalli', 'ar' => 'حولي'],
            ['en' => 'Farwaniya', 'ar' => 'الفروانية'],
            ['en' => 'Ahmadi', 'ar' => 'الأحمدي'],
            ['en' => 'Mubarak Al-Kabeer', 'ar' => 'مبارك الكبير'],
            ['en' => 'Jahra', 'ar' => 'الجهراء'],
            ['en' => 'Sabah Al Ahmad', 'ar' => 'صباح الأحمد'],
            ['en' => 'Wafra', 'ar' => 'الوفرة'],
            ['en' => 'Fintas', 'ar' => 'الفنطاس'],
            ['en' => 'Salwa', 'ar' => 'سلوى'],
        ];

        foreach ($states as $stateData) {
            $state = State::updateOrCreate(
                [
                    'country_id' => $kuwait->id,
                    'name_en' => $stateData['en'],
                ],
                [
                    'name_ar' => $stateData['ar'],
                    'status' => 'active',
                ]
            );

            // Create 1 city for each state (total 10 cities)
            City::updateOrCreate(
                [
                    'country_id' => $kuwait->id,
                    'state_id' => $state->id,
                    'name_en' => $stateData['en'] . ' City',
                ],
                [
                    'name_ar' => 'مدينة ' . $stateData['ar'],
                    'status' => 'active',
                ]
            );
        }
    }
} 