<?php

namespace App\Http\Controllers;

use App\Models\Subscription;
use Illuminate\Http\Request;
use Inertia\Inertia;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Auth;
use App\Models\FinanceTransaction;
use App\Models\VendorSubscription;

class SubscriptionController extends Controller
{
    // List & filter subscriptions
    public function index(Request $request)
    {
        $subscriptions = Subscription::query()
            ->when($request->search, function ($q, $search) {
                $q->where(function ($query) use ($search) {
                    $query->where('title_en', 'like', "%{$search}%")
                        ->orWhere('title_ar', 'like', "%{$search}%")
                        ->orWhere('description_en', 'like', "%{$search}%");
                });
            })
            ->when($request->price, fn($q) => $q->where('price', $request->price))
            ->when($request->duration, fn($q) => $q->where('duration', $request->duration))
            ->when($request->status, fn($q) => $q->where('status', $request->status))
            ->orderBy('sort_order')
            ->orderBy('price')
            ->paginate(10)
            ->withQueryString();

        return Inertia::render('Subscriptions/Index', [
            'subscriptions' => $subscriptions,
            'filters' => $request->only(['search', 'price', 'duration', 'status']),
        ]);
    }

    // Store new subscription
    public function store(Request $request)
    {
        $validated = $request->validate([
            'title_en' => 'required|string|max:255',
            'title_ar' => 'required|string|max:255',
            'description_en' => 'nullable|string',
            'description_ar' => 'nullable|string',
            'features' => 'nullable|string',
            'price' => 'required|numeric|min:0',
            'duration' => 'required|in:monthly,yearly',
            'status' => 'required|in:active,suspended,deleted',
            'sort_order' => 'nullable|integer|min:0',
            'ad_limit' => 'nullable|integer|min:0',
        ], [
            'title_en.required' => 'English title is required.',
            'title_en.max' => 'English title cannot exceed 255 characters.',
            'title_ar.required' => 'Arabic title is required.',
            'title_ar.max' => 'Arabic title cannot exceed 255 characters.',
            'price.required' => 'Price is required.',
            'price.numeric' => 'Price must be a valid number.',
            'price.min' => 'Price must be at least 0.',
            'duration.required' => 'Duration is required.',
            'duration.in' => 'Duration must be either monthly or yearly.',
            'status.required' => 'Status is required.',
            'status.in' => 'Status must be active, suspended, or deleted.',
            'sort_order.integer' => 'Sort order must be a valid number.',
            'sort_order.min' => 'Sort order must be at least 0.',
            'ad_limit.integer' => 'Ad limit must be a valid number.',
            'ad_limit.min' => 'Ad limit must be at least 0.',
        ]);

        try {
            Subscription::create($validated);
            return redirect()->back()->with('success', 'Subscription plan added successfully.');
        } catch (\Exception $e) {
            return redirect()->back()->withErrors(['error' => 'Failed to create subscription. Please try again.'])->withInput();
        }
    }

    // Update subscription
    public function update(Request $request, Subscription $subscription)
    {
        $validated = $request->validate([
            'title_en' => 'required|string|max:255',
            'title_ar' => 'required|string|max:255',
            'description_en' => 'nullable|string',
            'description_ar' => 'nullable|string',
            'features' => 'nullable|string',
            'price' => 'required|numeric|min:0',
            'duration' => 'required|in:monthly,yearly',
            'status' => 'required|in:active,suspended,deleted',
            'sort_order' => 'nullable|integer|min:0',
            'ad_limit' => 'nullable|integer|min:0',
        ], [
            'title_en.required' => 'English title is required.',
            'title_en.max' => 'English title cannot exceed 255 characters.',
            'title_ar.required' => 'Arabic title is required.',
            'title_ar.max' => 'Arabic title cannot exceed 255 characters.',
            'price.required' => 'Price is required.',
            'price.numeric' => 'Price must be a valid number.',
            'price.min' => 'Price must be at least 0.',
            'duration.required' => 'Duration is required.',
            'duration.in' => 'Duration must be either monthly or yearly.',
            'status.required' => 'Status is required.',
            'status.in' => 'Status must be active, suspended, or deleted.',
            'sort_order.integer' => 'Sort order must be a valid number.',
            'sort_order.min' => 'Sort order must be at least 0.',
            'ad_limit.integer' => 'Ad limit must be a valid number.',
            'ad_limit.min' => 'Ad limit must be at least 0.',
        ]);

        try {
            $subscription->update($validated);
            return redirect()->back()->with('success', 'Subscription plan updated successfully.');
        } catch (\Exception $e) {
            return redirect()->back()->withErrors(['error' => 'Failed to update subscription. Please try again.'])->withInput();
        }
    }

    // Suspend or activate subscription
    public function suspend(Subscription $subscription)
    {
        try {
            $newStatus = $subscription->status === 'suspended' ? 'active' : 'suspended';
            $subscription->update(['status' => $newStatus]);

            $message = $newStatus === 'active' ? 'Subscription plan activated successfully.' : 'Subscription plan suspended successfully.';
            return redirect()->back()->with('success', $message);
        } catch (\Exception $e) {
            return redirect()->back()->withErrors(['error' => 'Failed to update subscription status. Please try again.']);
        }
    }

    // Delete subscription
    public function destroy(Subscription $subscription)
    {
        try {
            $subscription->delete(); // This will now use soft delete since we added SoftDeletes trait
            return redirect()->back()->with('success', 'Subscription plan deleted successfully.');
        } catch (\Exception $e) {
            return redirect()->back()->withErrors(['error' => 'Failed to delete subscription. Please try again.']);
        }
    }

   
}