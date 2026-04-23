<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Faq;

class FaqSeeder extends Seeder
{
    public function run(): void
    {
        Faq::create([
            'question' => 'How do I place an order?',
            'answer' => 'You can place an order by adding items to your cart and checking out.',
        ]);
        Faq::create([
            'question' => 'What is the return policy?',
            'answer' => 'You can return items within 30 days of purchase.',
        ]);
    }
} 