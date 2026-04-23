<?php

namespace App\Http\Controllers;

use App\Models\Coupon;
use Illuminate\Http\Request;
use Inertia\Inertia;

class CouponController extends Controller
{
    public function index(Request $request)
    {
        $query = Coupon::query()->orderByDesc('id');

        if ($search = $request->string('search')->trim()->toString()) {
            $query->where('code', 'like', '%'.$search.'%');
        }
        if ($request->filled('status')) {
            if ($request->input('status') === 'active') {
                $query->where('is_active', true);
            } elseif ($request->input('status') === 'inactive') {
                $query->where('is_active', false);
            }
        }

        $coupons = $query->paginate(15)->withQueryString();

        return Inertia::render('Coupons/Index', [
            'coupons' => $coupons,
            'filters' => [
                'search' => $request->input('search', ''),
                'status' => $request->input('status', ''),
            ],
        ]);
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'code' => 'required|string|max:64|unique:coupons,code',
            'percentage' => 'required|numeric|min:0|max:100',
            'starts_at' => 'nullable|date',
            'ends_at' => 'nullable|date|after_or_equal:starts_at',
            'usage_limit' => 'nullable|integer|min:1',
            'usage_limit_per_user' => 'nullable|integer|min:1',
            'is_active' => 'boolean',
        ]);

        $validated['code'] = strtoupper(trim($validated['code']));
        $validated['usage_limit_per_user'] = $validated['usage_limit_per_user'] ?? 1;
        if (! array_key_exists('is_active', $validated)) {
            $validated['is_active'] = $request->boolean('is_active', true);
        }

        Coupon::create($validated);

        return redirect()->back()->with('success', 'Coupon created.');
    }

    public function update(Request $request, Coupon $coupon)
    {
        $validated = $request->validate([
            'code' => 'required|string|max:64|unique:coupons,code,'.$coupon->id,
            'percentage' => 'required|numeric|min:0|max:100',
            'starts_at' => 'nullable|date',
            'ends_at' => 'nullable|date|after_or_equal:starts_at',
            'usage_limit' => 'nullable|integer|min:1',
            'usage_limit_per_user' => 'nullable|integer|min:1',
            'is_active' => 'boolean',
        ]);

        $validated['code'] = strtoupper(trim($validated['code']));
        if (array_key_exists('usage_limit_per_user', $validated) && $validated['usage_limit_per_user'] === null) {
            $validated['usage_limit_per_user'] = 1;
        }
        if (! array_key_exists('is_active', $validated)) {
            $validated['is_active'] = $request->boolean('is_active');
        }

        $coupon->update($validated);

        return redirect()->back()->with('success', 'Coupon updated.');
    }

    public function destroy(Coupon $coupon)
    {
        $coupon->delete();

        return redirect()->back()->with('success', 'Coupon deleted.');
    }

    public function toggleStatus(Coupon $coupon)
    {
        $coupon->update(['is_active' => ! $coupon->is_active]);

        return redirect()->back()->with('success', 'Coupon status updated.');
    }
}
