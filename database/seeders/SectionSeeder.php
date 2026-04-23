<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Section;
use App\Models\SectionProduct;

class SectionSeeder extends Seeder
{
    public function run(): void
    {
        // Seed Sections
        $sections = [
            [
                'name' => 'Featured',
                'category_id' => 1,
                'vendor_id' => 1,
                'status' => 'active',
            ],
            [
                'name' => 'New Arrivals',
                'category_id' => 1,
                'vendor_id' => 1,
                'status' => 'active',
            ],
            [
                'name' => 'Best Sellers',
                'category_id' => 2,
                'vendor_id' => 2,
                'status' => 'active',
            ],
            [
                'name' => 'Discounted',
                'category_id' => 2,
                'vendor_id' => 2,
                'status' => 'active',
            ],
        ];

        foreach ($sections as $section) {
            Section::create($section);
        }

        // Seed SectionProducts
        // Assuming SectionProduct model exists and product/vendor/section IDs 1-2 exist
        $sectionProducts = [
            [
                'section_id' => 1,
                'product_id' => 1,
                'vendor_id' => 1,
            ],
            [
                'section_id' => 1,
                'product_id' => 2,
                'vendor_id' => 1,
            ],
            [
                'section_id' => 2,
                'product_id' => 3,
                'vendor_id' => 1,
            ],
            [
                'section_id' => 3,
                'product_id' => 4,
                'vendor_id' => 2,
            ],
            [
                'section_id' => 4,
                'product_id' => 5,
                'vendor_id' => 2,
            ],
        ];

        foreach ($sectionProducts as $sp) {
            SectionProduct::create($sp);
        }
    }
}
