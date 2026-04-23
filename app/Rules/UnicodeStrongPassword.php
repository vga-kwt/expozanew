<?php

namespace App\Rules;

use Closure;
use Illuminate\Contracts\Validation\ValidationRule;

/**
 * Min 8 characters; at least one letter (any script), one number (any numeric Unicode), one symbol (not letter, not number, not whitespace).
 */
class UnicodeStrongPassword implements ValidationRule
{
    public function validate(string $attribute, mixed $value, Closure $fail): void
    {
        if (! is_string($value)) {
            $fail('The :attribute must be a string.');

            return;
        }

        if (mb_strlen($value, 'UTF-8') < 8) {
            $fail('The :attribute must be at least 8 characters.');

            return;
        }

        if (! preg_match('/\p{L}/u', $value)) {
            $fail('The :attribute must contain at least one letter.');

            return;
        }

        if (! preg_match('/\p{N}/u', $value)) {
            $fail('The :attribute must contain at least one number.');

            return;
        }

        if (! preg_match('/[^\p{L}\p{N}\s]/u', $value)) {
            $fail('The :attribute must contain at least one symbol (e.g. punctuation).');
        }
    }
}
