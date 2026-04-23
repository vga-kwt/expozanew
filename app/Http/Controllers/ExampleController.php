<?php

namespace App\Http\Controllers;

use App\Models\User;
use App\Models\Order;
use App\Models\Vendor;
use App\Services\FilterService;
use Illuminate\Http\Request;
use Inertia\Inertia;

class ExampleController extends Controller
{
    protected FilterService $filterService;

    public function __construct(FilterService $filterService)
    {
        $this->filterService = $filterService;
    }

    /**
     * Example: Users with filters
     */
    public function users(Request $request)
    {
        $filterConfig = [
            'search_fields' => ['name', 'email'],
            'status_field' => 'status',
            'date_field' => 'created_at',
            'default_sort' => 'created_at',
            'default_order' => 'desc',
        ];

        $query = User::query();
        $users = $this->filterService->getPaginatedResults($query, $request, $filterConfig, 15);

        $filterOptions = $this->filterService->getCommonFilterOptions();
        $filters = $this->filterService->getFilterData($request);

        return Inertia::render('Users/Index', [
            'users' => $users,
            'filters' => $filters,
            'filterOptions' => $filterOptions,
        ]);
    }

    /**
     * Example: Orders with filters
     */
    public function orders(Request $request)
    {
        $filterConfig = [
            'search_fields' => ['order_number', 'customer_name'],
            'status_field' => 'status',
            'date_field' => 'created_at',
            'price_field' => 'total_amount',
            'user_field' => 'user_id',
            'default_sort' => 'created_at',
            'default_order' => 'desc',
            'custom_filters' => [
                'payment_status' => [
                    'field' => 'payment_status',
                    'operator' => '=',
                ],
                'order_type' => [
                    'field' => 'order_type',
                    'operator' => '=',
                ],
            ],
        ];

        $query = Order::with(['user', 'items']);
        $orders = $this->filterService->getPaginatedResults($query, $request, $filterConfig, 20);

        $filters = $this->filterService->getFilterData($request);
        $hasActiveFilters = $this->filterService->hasActiveFilters($request);
        $activeFilterCount = $this->filterService->getActiveFilterCount($request);

        return Inertia::render('Orders/Index', [
            'orders' => $orders,
            'filters' => $filters,
            'hasActiveFilters' => $hasActiveFilters,
            'activeFilterCount' => $activeFilterCount,
        ]);
    }

    /**
     * Example: Vendors with filters
     */
    public function vendors(Request $request)
    {
        $filterConfig = [
            'search_fields' => ['name', 'email', 'phone'],
            'status_field' => 'status',
            'date_field' => 'created_at',
            'default_sort' => 'name',
            'default_order' => 'asc',
            'custom_filters' => [
                'kyc_status' => [
                    'field' => 'kyc_status',
                    'operator' => '=',
                ],
                'subscription_status' => [
                    'field' => 'subscription_status',
                    'operator' => '=',
                ],
            ],
        ];

        $query = Vendor::with(['user', 'subscription']);
        $vendors = $this->filterService->getPaginatedResults($query, $request, $filterConfig, 12);

        $filters = $this->filterService->getFilterData($request);

        return Inertia::render('Vendors/Index', [
            'vendors' => $vendors,
            'filters' => $filters,
        ]);
    }

    /**
     * Example: Advanced filtering with custom logic
     */
    public function advancedFilter(Request $request)
    {
        $filterConfig = [
            'search_fields' => ['name', 'description'],
            'status_field' => 'status',
            'date_field' => 'created_at',
            'price_field' => 'price',
            'stock_field' => 'stock',
            'default_sort' => 'created_at',
            'default_order' => 'desc',
            'custom_filters' => [
                'category_ids' => [
                    'field' => 'category_id',
                    'operator' => 'in',
                    'transform' => function($value) {
                        return explode(',', $value);
                    },
                ],
                'price_range' => [
                    'field' => 'price',
                    'operator' => 'between',
                    'transform' => function($value) {
                        return explode('-', $value);
                    },
                ],
                'has_images' => [
                    'field' => 'image_url',
                    'operator' => '!=',
                    'transform' => function($value) {
                        return $value === 'true' ? null : 'not_null';
                    },
                ],
            ],
        ];

        $query = \App\Models\Product::with(['category', 'vendor']);
        $products = $this->filterService->getPaginatedResults($query, $request, $filterConfig, 10);

        $filters = $this->filterService->getFilterData($request);
        $filterUrl = $this->filterService->buildFilterUrl($filters, route('products.index'));

        return Inertia::render('Products/AdvancedFilter', [
            'products' => $products,
            'filters' => $filters,
            'filterUrl' => $filterUrl,
        ]);
    }

    /**
     * Example: Clear filters
     */
    public function clearFilters(Request $request)
    {
        $clearedFilters = $this->filterService->clearAllFilters($request);
        
        return redirect()->back()->with('success', 'All filters cleared!');
    }

    /**
     * Example: Clear specific filter
     */
    public function clearFilter(Request $request, string $filterName)
    {
        $remainingFilters = $this->filterService->clearFilter($request, $filterName);
        $filterUrl = $this->filterService->buildFilterUrl($remainingFilters);
        
        return redirect($filterUrl)->with('success', "Filter '{$filterName}' cleared!");
    }
} 