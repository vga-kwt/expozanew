<?php

namespace App\Services;

use Illuminate\Database\Eloquent\Builder;
use Illuminate\Http\Request;
use Illuminate\Pagination\LengthAwarePaginator;

class FilterService
{
    /**
     * Apply common filters to any model query
     */
    public function applyFilters(Builder $query, Request $request, array $filterConfig = []): Builder
    {
        // Search filter
        if ($request->filled('search') && trim($request->search) !== '') {
            $searchFields = $filterConfig['search_fields'] ?? ['name'];
            $this->applySearchFilter($query, trim($request->search), $searchFields);
        }

        // Status filter
        if ($request->filled('status') && $request->status !== 'all' && $request->status !== '') {
            $statusField = $filterConfig['status_field'] ?? 'status';
            $query->where($statusField, $request->status);
        }

        // Date range filter
        if ($request->filled('date_from') || $request->filled('date_to')) {
            $dateField = $filterConfig['date_field'] ?? 'created_at';
            $this->applyDateRangeFilter($query, $request, $dateField);
        }

        // Category filter
        if ($request->filled('category_id') && $request->category_id !== 'all' && $request->category_id !== '') {
            $categoryField = $filterConfig['category_field'] ?? 'category_id';
            $query->where($categoryField, $request->category_id);
        }

        // Vendor filter
        if ($request->filled('vendor_id') && $request->vendor_id !== 'all' && $request->vendor_id !== '') {
            $vendorField = $filterConfig['vendor_field'] ?? 'vendor_id';
            $query->where($vendorField, $request->vendor_id);
        }

        // User filter
        if ($request->filled('user_id') && $request->user_id !== 'all' && $request->user_id !== '') {
            $userField = $filterConfig['user_field'] ?? 'user_id';
            $query->where($userField, $request->user_id);
        }

        // Price range filter
        if ($request->filled('price_from') || $request->filled('price_to')) {
            $priceField = $filterConfig['price_field'] ?? 'price';
            $this->applyPriceRangeFilter($query, $request, $priceField);
        }

        // Stock filter
        if ($request->filled('stock_from') || $request->filled('stock_to')) {
            $stockField = $filterConfig['stock_field'] ?? 'stock';
            $this->applyStockRangeFilter($query, $request, $stockField);
        }

        // Custom filters
        if (isset($filterConfig['custom_filters'])) {
            $this->applyCustomFilters($query, $request, $filterConfig['custom_filters']);
        }

        return $query;
    }

    /**
     * Apply search filter with multiple fields
     */
    private function applySearchFilter(Builder $query, string $search, array $searchFields): void
    {
        $query->where(function ($q) use ($search, $searchFields) {
            foreach ($searchFields as $field) {
                $q->orWhere($field, 'like', "%{$search}%");
            }
        });
    }

    /**
     * Apply date range filter
     */
    private function applyDateRangeFilter(Builder $query, Request $request, string $dateField): void
    {
        if ($request->filled('date_from')) {
            $query->whereDate($dateField, '>=', $request->date_from);
        }
        
        if ($request->filled('date_to')) {
            $query->whereDate($dateField, '<=', $request->date_to);
        }
    }

    /**
     * Apply price range filter
     */
    private function applyPriceRangeFilter(Builder $query, Request $request, string $priceField): void
    {
        if ($request->filled('price_from')) {
            $query->where($priceField, '>=', $request->price_from);
        }
        
        if ($request->filled('price_to')) {
            $query->where($priceField, '<=', $request->price_to);
        }
    }

    /**
     * Apply stock range filter
     */
    private function applyStockRangeFilter(Builder $query, Request $request, string $stockField): void
    {
        if ($request->filled('stock_from')) {
            $query->where($stockField, '>=', $request->stock_from);
        }
        
        if ($request->filled('stock_to')) {
            $query->where($stockField, '<=', $request->stock_to);
        }
    }

    /**
     * Apply custom filters
     */
    private function applyCustomFilters(Builder $query, Request $request, array $customFilters): void
    {
        foreach ($customFilters as $filterName => $config) {
            if ($request->filled($filterName)) {
                $field = $config['field'] ?? $filterName;
                $operator = $config['operator'] ?? '=';
                $value = $request->input($filterName);
                
                if (isset($config['transform'])) {
                    $value = $config['transform']($value);
                }
                
                $query->where($field, $operator, $value);
            }
        }
    }

    /**
     * Get paginated results with filters
     */
    public function getPaginatedResults(Builder $query, Request $request, array $filterConfig = [], int $perPage = 10): LengthAwarePaginator
    {
        $this->applyFilters($query, $request, $filterConfig);
        
        $sortBy = $request->get('sort_by', $filterConfig['default_sort'] ?? 'id');
        $sortOrder = $request->get('sort_order', $filterConfig['default_order'] ?? 'desc');
        
        $query->orderBy($sortBy, $sortOrder);
        
        return $query->paginate($perPage)->withQueryString();
    }

    /**
     * Get filter data for forms
     */
    public function getFilterData(Request $request, array $allowedFilters = []): array
    {
        $filters = [];
        
        $defaultFilters = [
            'search', 'status', 'category_id', 'vendor_id', 'user_id',
            'date_from', 'date_to', 'price_from', 'price_to',
            'stock_from', 'stock_to', 'sort_by', 'sort_order'
        ];
        
        $filtersToInclude = empty($allowedFilters) ? $defaultFilters : $allowedFilters;
        
        foreach ($filtersToInclude as $filter) {
            if ($request->has($filter)) {
                $value = $request->input($filter);
                
                // Only include non-empty values
                if ($value !== null && $value !== '' && $value !== 'all') {
                    // For search, also check if it's not just whitespace
                    if ($filter === 'search') {
                        if (trim($value) !== '') {
                            $filters[$filter] = trim($value);
                        }
                    } else {
                        $filters[$filter] = $value;
                    }
                }
            }
        }
        
        return $filters;
    }

    /**
     * Get common filter options
     */
    public function getCommonFilterOptions(): array
    {
        return [
            'status_options' => [
                'all' => 'All Status',
                'active' => 'Active',
                'inactive' => 'Inactive',
                'suspended' => 'Suspended',
                'deleted' => 'Deleted',
            ],
            'sort_options' => [
                'id' => 'ID',
                'name' => 'Name',
                'created_at' => 'Created Date',
                'updated_at' => 'Updated Date',
                'price' => 'Price',
                'stock' => 'Stock',
            ],
            'sort_order_options' => [
                'asc' => 'Ascending',
                'desc' => 'Descending',
            ],
        ];
    }

    /**
     * Build filter URL with parameters
     */
    public function buildFilterUrl(array $filters, string $baseUrl = ''): string
    {
        $queryParams = http_build_query(array_filter($filters));
        return $baseUrl . ($queryParams ? '?' . $queryParams : '');
    }

    /**
     * Clear specific filter
     */
    public function clearFilter(Request $request, string $filterName): array
    {
        $filters = $request->all();
        unset($filters[$filterName]);
        return $filters;
    }

    /**
     * Clear all filters
     */
    public function clearAllFilters(Request $request): array
    {
        $defaultFilters = [
            'search', 'status', 'category_id', 'vendor_id', 'user_id',
            'date_from', 'date_to', 'price_from', 'price_to',
            'stock_from', 'stock_to'
        ];
        
        $cleanParams = [];
        
        // Keep only non-filter parameters like page, sort_by, sort_order
        foreach ($request->all() as $key => $value) {
            if (!in_array($key, $defaultFilters)) {
                $cleanParams[$key] = $value;
            }
        }
        
        return $cleanParams;
    }

    /**
     * Check if any filters are applied
     */
    public function hasActiveFilters(Request $request, array $excludeFilters = []): bool
    {
        $defaultFilters = [
            'search', 'status', 'category_id', 'vendor_id', 'user_id',
            'date_from', 'date_to', 'price_from', 'price_to',
            'stock_from', 'stock_to'
        ];
        
        $filtersToCheck = array_diff($defaultFilters, $excludeFilters);
        
        foreach ($filtersToCheck as $filter) {
            if ($request->has($filter)) {
                $value = $request->input($filter);
                if ($value !== null && $value !== '' && $value !== 'all') {
                    if ($filter === 'search' && trim($value) === '') {
                        continue;
                    }
                    return true;
                }
            }
        }
        
        return false;
    }

    /**
     * Get active filter count
     */
    public function getActiveFilterCount(Request $request, array $excludeFilters = []): int
    {
        $defaultFilters = [
            'search', 'status', 'category_id', 'vendor_id', 'user_id',
            'date_from', 'date_to', 'price_from', 'price_to',
            'stock_from', 'stock_to'
        ];
        
        $filtersToCheck = array_diff($defaultFilters, $excludeFilters);
        $count = 0;
        
        foreach ($filtersToCheck as $filter) {
            if ($request->has($filter)) {
                $value = $request->input($filter);
                if ($value !== null && $value !== '' && $value !== 'all') {
                    if ($filter === 'search' && trim($value) === '') {
                        continue;
                    }
                    $count++;
                }
            }
        }
        
        return $count;
    }
} 