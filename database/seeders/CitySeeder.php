<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Country;
use App\Models\State;
use App\Models\City;

class CitySeeder extends Seeder
{
    public function run()
    {
        $kuwait = Country::first();
        if (!$kuwait) return;

        $states = [
            'Al Asimah' => [
                ['en' => 'Kuwait City', 'ar' => 'مدينة الكويت'],
                ['en' => 'Sharq', 'ar' => 'شرق'],
                ['en' => 'Mirqab', 'ar' => 'مرقاب'],
                ['en' => 'Dasman', 'ar' => 'دسمان'],
            ],
            'Hawalli' => [
                ['en' => 'Hawalli', 'ar' => 'حولي'],
                ['en' => 'Salmiya', 'ar' => 'السالمية'],
                ['en' => 'Jabriya', 'ar' => 'الجابرية'],
                ['en' => 'Rumaithiya', 'ar' => 'الرميثية'],
            ],
            'Farwaniya' => [
                ['en' => 'Farwaniya', 'ar' => 'الفروانية'],
                ['en' => 'Khaitan', 'ar' => 'خيطان'],
                ['en' => 'Jleeb Al-Shuyoukh', 'ar' => 'جليب الشيوخ'],
                ['en' => 'Abdullah Al-Mubarak', 'ar' => 'عبدالله المبارك'],
            ],
            'Ahmadi' => [
                ['en' => 'Ahmadi', 'ar' => 'الأحمدي'],
                ['en' => 'Fahaheel', 'ar' => 'الفحيحيل'],
                ['en' => 'Mangaf', 'ar' => 'المنقف'],
                ['en' => 'Abu Halifa', 'ar' => 'أبو حليفة'],
            ],
            'Mubarak Al-Kabeer' => [
                ['en' => 'Mubarak Al-Kabeer', 'ar' => 'مبارك الكبير'],
                ['en' => 'Sabhan', 'ar' => 'صبحان'],
                ['en' => 'Qurain', 'ar' => 'القرين'],
                ['en' => 'Qusour', 'ar' => 'القصور'],
            ],
            'Jahra' => [
                ['en' => 'Jahra', 'ar' => 'الجهراء'],
                ['en' => 'Saad Al Abdullah', 'ar' => 'سعد العبدالله'],
                ['en' => 'Al Oyoun', 'ar' => 'العيون'],
                ['en' => 'Al Naseem', 'ar' => 'النسيم'],
            ],
        ];

        foreach ($states as $stateName => $cities) {
            $state = State::where('country_id', $kuwait->id)->where('name_en', $stateName)->first();
            if (!$state) continue;
            foreach ($cities as $city) {
                City::updateOrCreate(
                    [
                        'country_id' => $kuwait->id,
                        'state_id' => $state->id,
                        'name_en' => $city['en'],
                    ],
                    [
                        'name_ar' => $city['ar'],
                        'status' => 'active',
                    ]
                );
            }
        }
    }
} 