<?php

namespace App\Rules;

use Closure;
use Illuminate\Contracts\Validation\ValidationRule;

/**
 * Full / display names with Latin, Arabic, and other Unicode letters, plus spaces and common punctuation.
 */
class UnicodeDisplayName implements ValidationRule
{
    public function validate(string $attribute, mixed $value, Closure $fail): void
    {
        if (! is_string($value)) {
            $fail('The :attribute must be a string.');

            return;
        }

        $trimmed = trim($value);
        $len = mb_strlen($trimmed, 'UTF-8');
        if ($len < 1) {
            $fail('The :attribute is required.');

            return;
        }
        if ($len > 255) {
            $fail('The :attribute must not be greater than 255 characters.');

            return;
        }

        if (! preg_match('/^[\p{L}\p{M}\s\'\-\.]+$/u', $trimmed)) {
            $fail('The :attribute may only contain letters, spaces, hyphens, apostrophes, and periods.');
        }
    }
}
