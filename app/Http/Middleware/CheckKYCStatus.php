<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Symfony\Component\HttpFoundation\Response;

class CheckKYCStatus
{
    /**
     * Handle an incoming request.
     *
     * @param  \Closure(\Illuminate\Http\Request): (\Symfony\Component\HttpFoundation\Response)  $next
     */
    public function handle(Request $request, Closure $next, string $feature = null): Response
    {
        $user = Auth::user();
        
        if (!$user || !$user->hasRole('vendor')) {
            return $next($request);
        }

        $vendor = $user->vendor;
        
        if (!$vendor) {
            return redirect()->route('dashboard')->with('error', 'Vendor profile not found');
        }

        // If KYC is not approved, force redirect to KYC status page unless already there or logging out
        if ($vendor->kyc_status !== 'approved') {
            $currentRoute = $request->route() ? $request->route()->getName() : null;
            $allowedRoutes = [
                'vendor.profile.kyc-status',
                'vendor.profile.resend-kyc',
                'logout',
            ];
            if (!in_array($currentRoute, $allowedRoutes)) {
                // // For AJAX/API requests, return JSON response instead of redirecting
                // if ($request->ajax() || $request->wantsJson() || $request->expectsJson() || 
                //     $request->header('X-Requested-With') === 'XMLHttpRequest' || 
                //     strpos($request->header('Accept'), 'application/json') !== false) {
                //     return response()->json([
                //         'error' => 'KYC not approved',
                //         'message' => 'Please complete your KYC verification to access this feature',
                //         'redirect_to' => route('vendor.profile.kyc-status')
                //     ], 403);
                // }
                
                return redirect()->route('vendor.profile.kyc-status')->with('errer', 'Please complete your KYC verification to access this feature');
            }
        }

        return $next($request);
    }
}
