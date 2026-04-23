<?php

namespace Tests\Unit;

use App\Rules\UnicodeDisplayName;
use App\Rules\UnicodeStrongPassword;
use Illuminate\Support\Facades\Validator;
use Tests\TestCase;

class UnicodeAuthValidationTest extends TestCase
{
    public function test_unicode_display_name_accepts_arabic(): void
    {
        $validator = Validator::make(
            ['full_name' => 'محمد أحمد'],
            ['full_name' => ['required', new UnicodeDisplayName]]
        );

        $this->assertTrue($validator->passes());
    }

    public function test_unicode_display_name_rejects_digits_in_name(): void
    {
        $validator = Validator::make(
            ['full_name' => 'John2'],
            ['full_name' => ['required', new UnicodeDisplayName]]
        );

        $this->assertTrue($validator->fails());
    }

    public function test_unicode_strong_password_accepts_arabic_letter_eastern_digits_and_symbol(): void
    {
        $validator = Validator::make(
            ['password' => 'مرحبا١٢٣!'],
            ['password' => ['required', new UnicodeStrongPassword]]
        );

        $this->assertTrue($validator->passes());
    }

    public function test_unicode_strong_password_rejects_missing_symbol(): void
    {
        $validator = Validator::make(
            ['password' => 'مرحبا١٢٣'],
            ['password' => ['required', new UnicodeStrongPassword]]
        );

        $this->assertTrue($validator->fails());
    }
}
