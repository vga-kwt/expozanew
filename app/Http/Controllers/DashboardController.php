<?php

namespace App\Http\Controllers;

use App\Models\Vendor;
use App\Services\DashboardService;
use Illuminate\Http\Request;
use Inertia\Inertia;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Auth;

class DashboardController extends Controller
{
    protected $dashboardService;

    public function __construct(DashboardService $dashboardService)
    {
        $this->dashboardService = $dashboardService;
    }

    public function index(Request $request)
    {
        $user = $request->user();
        
        // Ensure user is authenticated
        if (!$user) {
            return redirect()->route('vendor.login')
                ->with('error', 'Please login to continue.');
        }
        
        if ($user->hasRole('vendor')) {
            // Load vendor relationship explicitly
            $vendor = $user->vendor;
            
            // Check if vendor exists
            if (!$vendor) {
                // Vendor profile not found - logout and redirect to login
                Auth::logout();
                $request->session()->invalidate();
                $request->session()->regenerateToken();
                
                return redirect()->route('vendor.login')
                    ->with('error', 'Vendor profile not found. Please contact support.');
            }
            
            $period = $request->input('period', 'month');
            $vendorDashboard = $this->dashboardService->getVendorDashboardData($vendor, $period);
            
            return Inertia::render('dashboard', [
                'vendor_dashboard' => $vendorDashboard,
                'auth' => [
                    'user' => $user,
                    'permissions' => $user->getAllPermissions()->pluck('name'),
                ],
                'top_vendors' => $this->dashboardService->getTopVendors(), // Add this for vendors
                'expos' => $this->dashboardService->getExpos(),
                'categories' => $this->dashboardService->getCategories(),
                'vendors' => $this->dashboardService->getVendors(),
            ]);
        }

        // Admin dashboard
        $filters = [
            'period' => $request->input('period', 'month'),
        ];

        // Log::info('Dashboard period param', ['period' => $filters['period']]);

        $dashboardData = $this->dashboardService->getAdminDashboardData($filters);

        return Inertia::render('dashboard', [
            'stats' => $dashboardData['stats'],
            'sales_data' => $dashboardData['sales_data'],
            'recent_orders' => $dashboardData['recent_orders'],
            'recent_users' => $dashboardData['recent_users'],
            'flash' => [
                'success' => session('success'),
                'error' => session('error')
            ],
            'expos' => $dashboardData['expos'],
            'categories' => $dashboardData['categories'],
            'vendors' => $dashboardData['vendors'],
            'top_vendors' => $dashboardData['top_vendors'],
        ]);
    }
} 
