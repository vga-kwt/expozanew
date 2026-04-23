<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;
use App\Models\User;
use App\Models\Vendor;

class VendorSeeder extends Seeder
{
    public function run(): void
    {
        // DO NOT delete or truncate any data

        // Get the current max user id and vendor id
        $maxUserId = DB::table('users')->max('id') ?? 0;
        $maxVendorId = DB::table('vendors')->max('id') ?? 0;

        $brands = [
            ['en' => 'OneBrand', 'ar' => 'براند ون'],
            ['en' => 'TwoBrand', 'ar' => 'براند تو'],
            ['en' => 'ThreeBrand', 'ar' => 'براند ثري'],
            ['en' => 'FourBrand', 'ar' => 'براند فور'],
            ['en' => 'FiveBrand', 'ar' => 'براند فايف'],
            ['en' => 'SixBrand', 'ar' => 'براند سكس'],
            ['en' => 'SevenBrand', 'ar' => 'براند سفن'],
            ['en' => 'EightBrand', 'ar' => 'براند إيت'],
            ['en' => 'NineBrand', 'ar' => 'براند ناين'],
            ['en' => 'TenBrand', 'ar' => 'براند تن'],
        ];

        for ($i = 0; $i < 10; $i++) {
            $brand = $brands[$i];
            $name = 'Vendor ' . ($i + 1 + $maxVendorId);
            $email = 'vendor' . ($i + 1 + $maxVendorId) . '@example.com';
            $mobile = '900000000' . ($i + 1 + $maxVendorId);
            $categoryId = (($i + $maxVendorId) % 5) + 1;
            $commission = 10 + $i;
            $kycStatus = $i % 2 === 0 ? 'approved' : 'pending';
            $isVerified = $i % 2 === 0;

            // Create user
            $user = User::create([
                'full_name' => $name,
                'email' => $email,
                'password' => bcrypt('password'), // default password
                'role' => 'vendor',
                'status' => 'active',
            ]);

            // Create vendor
            Vendor::create([
                'user_id' => $user->id,
                'category_id' => $categoryId,
                'name' => $name,
                'brand_name_en' => $brand['en'],
                'brand_name_ar' => $brand['ar'],
                'description_en' => 'Sample description for ' . $name,
                'description_ar' => 'وصف تجريبي لـ ' . $name,
                'logo' => 'logos/vendor' . ($i + 1 + $maxVendorId) . '.png',
                'mobile' => $mobile,
                'email' => $email,
                'status' => 'active',
                'commission' => $commission,
                'kyc_status' => $kycStatus,
                'kyc_rejection_reason_en' => null,
                'kyc_rejection_reason_ar' => null,
                'kyc_documents' => '{"civil_id":"kyc-documents\/djkBjbXoUXghx2d4imHHOVZVxC8noUi0OLwTZ7Dh.png","address_proof":"kyc-documents\/F56KduLqlXGwAvy5WTNpP9DyDCv8pK8drsgUpB34.png"}',
                'is_verified' => $isVerified,
                'created_at' => now(),
                'updated_at' => now(),
            ]);
        }
    }
}
