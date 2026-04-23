<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class SubscriptionSeeder extends Seeder
{
    public function run(): void
    {
        DB::table('subscriptions')->insert([
            [
                'title_en' => 'Basic Plan',
                'title_ar' => 'الخطة الأساسية',
                'description_en' => 'Access to basic features with limited support.',
                'description_ar' => 'الوصول إلى الميزات الأساسية مع دعم محدود.',
                'features' => json_encode(['1 ad', 'Basic support', 'No premium features']),
                'price' => 9.99,
                'duration' => 'monthly',
                'status' => 'active',
                'sort_order' => 1,
                'ad_limit' => 1,
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'title_en' => 'Standard Plan',
                'title_ar' => 'الخطة القياسية',
                'description_en' => 'More features and better support.',
                'description_ar' => 'مزيد من الميزات ودعم أفضل.',
                'features' => json_encode(['5 ads', 'Standard support', 'Access to analytics']),
                'price' => 24.99,
                'duration' => 'monthly',
                'status' => 'active',
                'sort_order' => 2,
                'ad_limit' => 5,
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'title_en' => 'Premium Plan',
                'title_ar' => 'الخطة المميزة',
                'description_en' => 'All features unlocked with priority support.',
                'description_ar' => 'جميع الميزات مفعلة مع دعم أولوية.',
                'features' => json_encode(['Unlimited ads', 'Priority support', 'Featured listings']),
                'price' => 49.99,
                'duration' => 'monthly',
                'status' => 'active',
                'sort_order' => 3,
                'ad_limit' => 999,
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'title_en' => 'Basic Plan (Yearly)',
                'title_ar' => 'الخطة الأساسية (سنوي)',
                'description_en' => 'Yearly access to basic features with limited support.',
                'description_ar' => 'الوصول السنوي إلى الميزات الأساسية مع دعم محدود.',
                'features' => json_encode(['12 ads', 'Basic support', 'No premium features']),
                'price' => 99.99,
                'duration' => 'yearly',
                'status' => 'active',
                'sort_order' => 4,
                'ad_limit' => 12,
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'title_en' => 'Standard Plan (Yearly)',
                'title_ar' => 'الخطة القياسية (سنوي)',
                'description_en' => 'Yearly plan with more features and better support.',
                'description_ar' => 'خطة سنوية مع مزيد من الميزات ودعم أفضل.',
                'features' => json_encode(['60 ads', 'Standard support', 'Access to analytics']),
                'price' => 249.99,
                'duration' => 'yearly',
                'status' => 'active',
                'sort_order' => 5,
                'ad_limit' => 60,
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'title_en' => 'Premium Plan (Yearly)',
                'title_ar' => 'الخطة المميزة (سنوي)',
                'description_en' => 'All features unlocked with priority support for a year.',
                'description_ar' => 'جميع الميزات مفعلة مع دعم أولوية لمدة سنة.',
                'features' => json_encode(['Unlimited ads', 'Priority support', 'Featured listings']),
                'price' => 499.99,
                'duration' => 'yearly',
                'status' => 'active',
                'sort_order' => 6,
                'ad_limit' => 999,
                'created_at' => now(),
                'updated_at' => now(),
            ],
        ]);
    }
}
