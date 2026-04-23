<?php

namespace App\Http\Controllers;

use App\Models\Setting;
use Illuminate\Http\Request;
use Inertia\Inertia;

class SettingsController extends Controller
{
    public function index()
    {
        $settings = Setting::pluck('value', 'key')->toArray();
        return Inertia::render('Settings/Index', [
            'settings' => $settings,
        ]);
    }

    public function update(Request $request)
    {
        $data = $request->validate([
            'payout_frequency' => 'required|string|in:daily,weekly,monthly,custom,15_days',
            'custom_payout_date' => 'nullable|date',
            'vendor_commission' => 'required|numeric|min:0|max:100',
            'gateway_fees' => 'required|numeric|min:0|max:100',
            'admin_notifications' => 'required|boolean',
            'delivery_fee_per_km' => 'nullable|numeric|min:0',
            'base_delivery_fee' => 'nullable|numeric|min:0',
            'free_delivery_threshold' => 'nullable|numeric|min:0',
        ]);

        // Convert empty strings to null for nullable fields
        $nullableFields = ['custom_payout_date', 'delivery_fee_per_km', 'base_delivery_fee', 'free_delivery_threshold'];
        foreach ($nullableFields as $field) {
            if (isset($data[$field]) && ($data[$field] === '' || $data[$field] === null)) {
                $data[$field] = null;
            }
        }

        // Convert boolean to string for storage
        if (isset($data['admin_notifications'])) {
            $data['admin_notifications'] = $data['admin_notifications'] ? '1' : '0';
        }

        // Convert all values to strings for storage (as settings table stores values as strings)
        foreach ($data as $key => $value) {
            $valueToStore = $value === null ? null : (string) $value;
            Setting::updateOrCreate(['key' => $key], ['value' => $valueToStore]);
        }

        return back()->with('success', 'Settings updated!');
    }
} 