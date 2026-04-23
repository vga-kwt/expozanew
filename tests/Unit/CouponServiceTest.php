<?php

namespace Tests\Unit;

use App\Models\Coupon;
use App\Services\CouponService;
use Tests\TestCase;

class CouponServiceTest extends TestCase
{
    /**
     * Pure unit test (no DB) — project sqlite migrations may not run in CI.
     */
    public function test_compute_discount_caps_at_grand_total(): void
    {
        $coupon = new Coupon([
            'percentage' => 100,
        ]);

        $service = app(CouponService::class);
        $amount = $service->computeDiscountAmount(50.00, $coupon);

        $this->assertEquals(50.00, $amount);
    }

    public function test_compute_discount_percentage(): void
    {
        $coupon = new Coupon([
            'percentage' => 10,
        ]);

        $service = app(CouponService::class);
        $amount = $service->computeDiscountAmount(200.00, $coupon);

        $this->assertEquals(20.00, $amount);
    }
}
