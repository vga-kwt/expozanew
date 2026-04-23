<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class IsVendor
{
    /**
     * Handle an incoming request.
     */
    public function handle(Request $request, Closure $next): Response
    {
        $user = $request->user();
        if (!$user || !method_exists($user, 'vendor') || !$user->vendor) {
            return redirect()->back()->withErrors(['error' => 'You must be a vendor to access this page.']);
        }
        return $next($request);
    }
} 