<?php

namespace App\Services;

use App\Models\Coupon;
use App\Models\CouponUsage;
use App\Models\User;
use Carbon\Carbon;
use Illuminate\Support\Str;

class CouponService
{
    /**
     * Find coupon by raw code (case-insensitive).
     */
    public function findByCode(string $code): ?Coupon
    {
        $normalized = Str::upper(trim($code));

        return Coupon::query()
            ->whereRaw('UPPER(code) = ?', [$normalized])
            ->first();
    }

    /**
     * Validate coupon for a user. Returns [ok, message, coupon|null].
     *
     * @return array{0: bool, 1: string|null, 2: Coupon|null}
     */
    public function validateForUser(?Coupon $coupon, User $user): array
    {
        if (! $coupon) {
            return [false, 'Invalid coupon code.', null];
        }

        if (! $coupon->is_active) {
            return [false, 'This coupon is not active.', null];
        }

        $now = Carbon::now();
        if ($coupon->starts_at && $now->lt($coupon->starts_at)) {
            return [false, 'This coupon is not valid yet.', null];
        }
        if ($coupon->ends_at && $now->gt($coupon->ends_at)) {
            return [false, 'This coupon has expired.', null];
        }

        if ($coupon->usage_limit !== null) {
            $used = CouponUsage::where('coupon_id', $coupon->id)->count();
            if ($used >= $coupon->usage_limit) {
                return [false, 'This coupon has reached its usage limit.', null];
            }
        }

        $perUser = (int) ($coupon->usage_limit_per_user ?? 1);
        if ($perUser > 0) {
            $userUses = CouponUsage::where('coupon_id', $coupon->id)
                ->where('user_id', $user->id)
                ->count();
            if ($userUses >= $perUser) {
                return [false, 'You have already used this coupon the maximum number of times.', null];
            }
        }

        return [true, null, $coupon];
    }

    /**
     * Discount amount from grand total (subtotal + shipping) before discount.
     */
    public function computeDiscountAmount(float $grandTotalBeforeDiscount, Coupon $coupon): float
    {
        if ($grandTotalBeforeDiscount <= 0) {
            return 0.0;
        }

        $pct = (float) $coupon->percentage;
        if ($pct <= 0) {
            return 0.0;
        }
        if ($pct > 100) {
            $pct = 100;
        }

        $discount = round($grandTotalBeforeDiscount * ($pct / 100), 2);

        return min($discount, $grandTotalBeforeDiscount);
    }
}
