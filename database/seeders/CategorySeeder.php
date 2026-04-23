<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Category;

class CategorySeeder extends Seeder
{
    public function run(): void
    {
        $faker = \Faker\Factory::create();
        $categories = [
            ['Electronics', 'إلكترونيات', 'All kinds of electronic devices and gadgets.'],
            ['Clothing', 'ملابس', 'Clothing and apparel for all ages.'],
            ['Books', 'كتب', 'Books and literature for everyone.'],
            ['Home & Kitchen', 'المنزل والمطبخ', 'Home appliances and kitchenware.'],
            ['Sports', 'رياضة', 'Sports equipment and accessories.'],
            ['Toys', 'ألعاب', 'Toys and games for children.'],
            ['Beauty', 'جمال', 'Beauty and personal care products.'],
            ['Automotive', 'سيارات', 'Automotive parts and accessories.'],
            ['Garden', 'حديقة', 'Garden tools and outdoor supplies.'],
            ['Health', 'صحة', 'Health and wellness products.'],
        ];

        foreach ($categories as $cat) {
            Category::create([
                'parent_id' => null,
                'name_en' => $cat[0],
                'name_ar' => $cat[1],
                'content' => $cat[2],
                'image' => 'https://via.placeholder.com/400x400?text=' . urlencode($cat[0]),
                'status' => 'active',
            ]);
        }
    }
} 