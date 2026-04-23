<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Country;
use App\Models\State;

class StateSeeder extends Seeder
{
    public function run()
    {
        $kuwait = Country::where('name_en', 'Kuwait')->first();
        if (!$kuwait) return;

        $states = [
            ['name_en' => 'Al Asimah', 'name_ar' => 'العاصمة'],
            ['name_en' => 'Hawalli', 'name_ar' => 'حولي'],
            ['name_en' => 'Farwaniya', 'name_ar' => 'الفروانية'],
            ['name_en' => 'Ahmadi', 'name_ar' => 'الأحمدي'],
            ['name_en' => 'Mubarak Al-Kabeer', 'name_ar' => 'مبارك الكبير'],
            ['name_en' => 'Jahra', 'name_ar' => 'الجهراء'],
        ];

        foreach ($states as $state) {
            State::updateOrCreate(
                [
                    'country_id' => $kuwait->id,
                    'name_en' => $state['name_en'],
                ],
                [
                    'name_ar' => $state['name_ar'],
                    'status' => 'active',
                ]
            );
        }
    }
} 