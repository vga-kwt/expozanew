<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Carbon;
use Symfony\Component\HttpFoundation\Response;

class CheckVendorSubscription
{
    /**
     * Handle an incoming request.
     *
     * @param  \Closure(\Illuminate\Http\Request): (\Symfony\Component\HttpFoundation\Response)  $next
     */
    public function handle(Request $request, Closure $next): Response
    {
        $user = Auth::user();
        
        if (!$user || !$user->hasRole('vendor')) {
            return $next($request);
        }

        $vendor = $user->vendor;
        
        if (!$vendor) {
            return redirect()->route('dashboard')->with('error', 'Vendor profile not found');
        }

        // Check if vendor has active subscription
        $hasActiveSubscription = $vendor->hasActiveSubscription();
        
        if (!$hasActiveSubscription) {
            $currentRoute = $request->route() ? $request->route()->getName() : null;
            
            // Allow access to subscription-related routes
            $allowedRoutes = [
                'vendor.subscription',
                'vendor.subscribe',
                'vendor.subscribe.payWithMyFatoorah',
                'vendor.subscribe.callback',
                'vendor.subscribe.error',
                'vendor.subscription.renew',
                'vendor.subscription.upgrade',
                'vendor.subscription.cancel',
                'logout',
                'vendor.profile.index',
                'vendor.profile.kyc-status',
                'vendor.profile.resend-kyc',
            ];
            
            if (!in_array($currentRoute, $allowedRoutes)) {
                // Always redirect to subscription page (Inertia will handle it properly)
                return redirect()->route('vendor.subscription')
                    ->with('error', 'Please subscribe to a plan to access the dashboard');
            }
        }

        return $next($request);
    }
}

