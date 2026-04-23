<?php

namespace App\Services;

use App\Models\Product;
use App\Models\Category;
use App\Models\Vendor;
use App\Models\Expo;
use App\Models\Section;
use Illuminate\Http\Request;
use Illuminate\Pagination\LengthAwarePaginator;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Support\Facades\Storage;

class ProductService
{
    protected ImageService $imageService;
    protected MultipleImageService $multipleImageService;
    protected FilterService $filterService;
    protected PerformanceService $performanceService;

    public function __construct(
        ImageService $imageService,
        MultipleImageService $multipleImageService,
        FilterService $filterService,
        PerformanceService $performanceService
    ) {
        $this->imageService = $imageService;
        $this->multipleImageService = $multipleImageService;
        $this->filterService = $filterService;
        $this->performanceService = $performanceService;
    }

    /**
     * Get all products with filters and pagination (Optimized for large datasets)
     */
    public function getProducts(Request $request): LengthAwarePaginator
    {
        $filterConfig = [
            'search_fields' => ['name_en', 'name_ar'],
            'status_field' => 'status',
            'category_field' => 'category_id',
            'vendor_field' => 'vendor_id',
            'date_field' => 'created_at',
            'price_field' => 'regular_price',
            'stock_field' => 'stock',
            'default_sort' => 'id',
            'default_order' => 'desc',
            'select_columns' => [
                'id',
                'name_en',
                'name_ar',
                'regular_price',
                'sale_price',
                'stock',
                'status',
                'image_url',
                'gallery',
                'category_id',
                'vendor_id',
                'created_at',
                'updated_at'
            ],
        ];


        // Force fresh data by clearing any potential caching
        // Admin should see ALL products from ALL vendors (no vendor_id filter unless explicitly requested)
        $query = Product::with(['category:id,name_en', 'vendor:id,name,brand_name_en']);

        // Explicitly exclude soft deleted products
        // IMPORTANT: No vendor_id filter here - admin must see all vendors' products
        // Only filter by vendor_id if explicitly requested in the request parameters

        // Always force fresh data to prevent caching issues
        $query->reorder();

        // Clear cache to ensure fresh data (especially important for admin to see all products)
        $this->performanceService->clearCache('optimized_results_*');

        // If there are flash messages, disable caching to ensure fresh data
        $disableCache = $request->session()->has('flash.success') || $request->session()->has('flash.error');

        // Always disable cache for admin product listing to ensure all vendors' products are shown
        $disableCache = true;

        $products = $this->performanceService->getOptimizedResults($query, $request, $filterConfig, 10, 0); // 0 cache minutes to ensure fresh data

        // Transform products to include proper image URLs (optimized)
        $products->getCollection()->transform(function ($product) {
            $productData = $product->toArray();
            $productData['images'] = $this->transformProductImages($product);
            return $productData;
        });

        return $products;
    }

    /**
     * Get vendor products with filters (Optimized)
     */
    public function getVendorProducts(Request $request, $vendor): LengthAwarePaginator
    {
        // Validate vendor ID
        if (!$vendor || !$vendor->id) {
            throw new \Exception('Invalid vendor provided');
        }

        // Get filters from request (same pattern as SectionController)
        $filters = $request->only(['search', 'status', 'category_id', 'date_from', 'date_to']);

        // Build query with vendor_id filter FIRST - same pattern as SectionService
        // Direct query without FilterService to ensure vendor isolation
        $query = Product::where('vendor_id', $vendor->id)
            ->with(['category:id,name_en', 'expo:id,name_en']);

        // Apply search filter
        if (!empty($filters['search'])) {
            $query->where(function ($q) use ($filters) {
                $q->where('name_en', 'like', '%' . $filters['search'] . '%')
                    ->orWhere('name_ar', 'like', '%' . $filters['search'] . '%');
            });
        }

        // Apply status filter
        if (!empty($filters['status']) && $filters['status'] !== 'all') {
            $query->where('status', $filters['status']);
        }

        // Apply category filter
        if (!empty($filters['category_id']) && $filters['category_id'] !== 'all') {
            $query->where('category_id', $filters['category_id']);
        }

        // Apply date filters
        if (!empty($filters['date_from'])) {
            $query->whereDate('created_at', '>=', $filters['date_from']);
        }

        if (!empty($filters['date_to'])) {
            $query->whereDate('created_at', '<=', $filters['date_to']);
        }

        // Order and paginate - same pattern as SectionService
        return $query->orderBy('created_at', 'desc')->paginate(10)->withQueryString();
    }

    /**
     * Get product for edit with all relations
     */
    public function getProductForEdit(Product $product): array
    {
        $productData = $product->toArray();
        $productData['images'] = $this->transformProductImages($product);

        // Map attributes to variants for frontend (variants are stored in attributes field)
        if (isset($productData['attributes']) && is_array($productData['attributes'])) {
            $productData['variants'] = $productData['attributes'];
        } else {
            $productData['variants'] = [];
        }

        return $productData;
    }

    /**
     * Get product for show with all relations
     */
    public function getProductForShow(Product $product): array
    {
        $product->load(['category', 'vendor', 'expo']);
        $productArr = $product->toArray();
        $productArr['images'] = $this->transformProductImages($product);

        return $productArr;
    }

    /**
     * Create new product
     */
    public function createProduct(array $validated): Product
    {
        // dd($validated['attributes']);
        $validated['image_url'] = $this->imageService->uploadImage($validated['image_url'] ?? null);
        $validated['gallery'] = $this->multipleImageService->uploadMultipleImages($validated['gallery'] ?? null);

        $validated['attributes'] = $this->processAttributes($validated['attributes'] ?? null);

        $product = Product::create($validated);

        // Clear cache to ensure fresh data is loaded
        $this->performanceService->clearCache('optimized_results_*');

        return $product;
    }

    /**
     * Update existing product
     */
    public function updateProduct(Product $product, array $validated): bool
    {
        // Handle image_url - check if it's a file upload or existing path
        if (isset($validated['image_url'])) {
            if ($validated['image_url'] instanceof \Illuminate\Http\UploadedFile) {
                // New file uploaded - use ImageService to update
                $validated['image_url'] = $this->imageService->updateImage(
                    $validated['image_url'],
                    $product->image_url
                );
            } else {
                // Existing image path - keep it as is
                $validated['image_url'] = $validated['image_url'];
            }
        } else {
            // No image_url provided - keep existing one
            $validated['image_url'] = $product->image_url;
        }

        // Ensure removed_images is properly sanitized
        $removedImages = $this->sanitizeRemovedImages($validated['removed_images'] ?? []);

        $validated['gallery'] = $this->multipleImageService->updateGallery(
            $validated['gallery'] ?? null,
            $product->gallery ?? [],
            $removedImages
        );

        $validated['attributes'] = $this->processAttributes($validated['attributes'] ?? null);

        $result = $product->update($validated);

        // Clear cache to ensure fresh data is loaded
        if ($result) {
            $this->performanceService->clearCache('optimized_results_*');
        }

        return $result;
    }

    /**
     * Get all common data for forms
     */
    public function getFormData(): array
    {
        return [
            'categories' => Category::all(),
            'vendors' => Vendor::all(),
            'expos' => Expo::all(),
            'sections' => Section::all(),
        ];
    }

    /**
     * Get filters data
     */
    public function getFiltersData(Request $request): array
    {
        $filters = $this->filterService->getFilterData($request, [
            'search',
            'category_id',
            'vendor_id',
            'status',
            'date_from',
            'date_to',
            'price_from',
            'price_to',
            'stock_from',
            'stock_to',
            'sort_by',
            'sort_order'
        ]);

        return [
            'filters' => $filters,
            'has_active_filters' => $this->filterService->hasActiveFilters($request),
            'active_filter_count' => $this->filterService->getActiveFilterCount($request),
        ];
    }

    /**
     * Transform product images for frontend
     */
    private function transformProductImages(Product $product): array
    {
        $images = $this->multipleImageService->getGalleryUrls($product->gallery ?? []);
        $disk = config('filesystems.default', 'public');

        // Only add main image if it exists
        if ($product->image_url && Storage::disk($disk)->exists($product->image_url)) {
            $mainImageUrl = $this->imageService->getImageUrl($product->image_url);
            if ($mainImageUrl) {
                $images[] = [
                    'url' => $mainImageUrl,
                    'path' => $product->image_url,
                    'name' => basename($product->image_url)
                ];
            }
        }

        return $images;
    }

    /**
     * Process attributes (variants) from JSON string to array
     */
    private function processAttributes(?string $attributes): array
    {
        if (!$attributes)
            return [];

        $decoded = json_decode($attributes, true);
        return (json_last_error() === JSON_ERROR_NONE && is_array($decoded)) ? $decoded : [];
    }

    /**
     * Sanitize removed images array
     */
    private function sanitizeRemovedImages($removedImages): array
    {
        if (!is_array($removedImages)) {
            return [];
        }

        return array_filter($removedImages, function ($image) {
            return is_string($image) && !empty(trim($image));
        });
    }

    /**
     * Toggle product status between 'active' and 'suspended'
     */
    public function suspendProduct(Product $product): bool
    {
        $newStatus = $product->status === 'suspended' ? 'active' : 'suspended';
        $result = $product->update(['status' => $newStatus]);

        // Clear cache to ensure fresh data is loaded
        if ($result) {
            $this->performanceService->clearCache('optimized_results_*');
        }

        return $result;
    }

    /**
     * Delete product (soft delete)
     */
    public function deleteProduct(Product $product): bool
    {
        $result = $product->delete();

        // Clear cache to ensure fresh data is loaded
        if ($result) {
            $this->performanceService->clearCache('optimized_results_*');
        }

        return $result;
    }

    /**
     * Get product statistics
     */
    public function getProductStats(): array
    {
        return [
            'total' => Product::count(),
            'active' => Product::where('status', 'active')->count(),
            'suspended' => Product::where('status', 'suspended')->count(),
            'deleted' => Product::where('status', 'deleted')->count(),
        ];
    }

    /**
     * Get vendor product statistics
     */
    public function getVendorProductStats($vendor): array
    {
        return [
            'total' => $vendor->products()->count(),
            'active' => $vendor->products()->where('status', 'active')->count(),
            'suspended' => $vendor->products()->where('status', 'suspended')->count(),
        ];
    }

    /**
     * Get products with lazy loading for infinite scroll
     */
    public function getProductsLazyLoad(Request $request): array
    {
        $filterConfig = [
            'search_fields' => ['name_en', 'name_ar'],
            'status_field' => 'status',
            'category_field' => 'category_id',
            'vendor_field' => 'vendor_id',
            'select_columns' => [
                'id',
                'name_en',
                'name_ar',
                'regular_price',
                'sale_price',
                'stock',
                'status',
                'image_url',
                'gallery',
                'category_id',
                'vendor_id',
                'created_at'
            ],
        ];

        $query = Product::with(['category:id,name_en', 'vendor:id,name,brand_name_en']);
        return $this->performanceService->getLazyLoadedResults($query, $request, $filterConfig, 20);
    }

    /**
     * Get products with chunked loading for very large datasets
     */
    public function getProductsChunked(Request $request): LengthAwarePaginator
    {
        $filterConfig = [
            'search_fields' => ['name_en', 'name_ar'],
            'status_field' => 'status',
            'category_field' => 'category_id',
            'vendor_field' => 'vendor_id',
        ];

        $query = Product::with(['category:id,name_en', 'vendor:id,name,brand_name_en']);
        return $this->performanceService->getChunkedResults($query, $request, $filterConfig, 1000, 10);
    }

    /**
     * Get performance statistics for products
     */
    public function getProductsPerformanceStats(Request $request): array
    {
        $filterConfig = [
            'search_fields' => ['name_en', 'name_ar'],
            'status_field' => 'status',
            'category_field' => 'category_id',
            'vendor_field' => 'vendor_id',
        ];

        $query = Product::with(['category:id,name_en', 'vendor:id,name,brand_name_en']);
        return $this->performanceService->getPerformanceStats($query, $request, $filterConfig);
    }

    /**
     * Debug method to check if cache is working properly
     */
    public function debugCacheStatus(Request $request): array
    {
        $filterConfig = [
            'search_fields' => ['name_en', 'name_ar'],
            'status_field' => 'status',
            'category_field' => 'category_id',
            'vendor_field' => 'vendor_id',
        ];

        $query = Product::with(['category:id,name_en', 'vendor:id,name,brand_name_en']);
        $cacheKey = 'optimized_results_' . md5(serialize($request->all()) . md5(serialize($filterConfig)) . 10);

        return [
            'cache_exists' => \Illuminate\Support\Facades\Cache::has($cacheKey),
            'cache_key' => $cacheKey,
            'total_products' => Product::count(),
            'active_products' => Product::where('status', 'active')->count(),
            'suspended_products' => Product::where('status', 'suspended')->count(),
            'has_flash_messages' => $request->session()->has('flash.success') || $request->session()->has('flash.error'),
        ];
    }
}