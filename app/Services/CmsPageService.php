<?php

namespace App\Services;

use App\Models\CmsPage;
use Illuminate\Http\Request;
use Illuminate\Pagination\LengthAwarePaginator;
use Illuminate\Support\Str;

class CmsPageService
{
    protected FilterService $filterService;
    protected PerformanceService $performanceService;

    public function __construct(
        FilterService $filterService,
        PerformanceService $performanceService
    ) {
        $this->filterService = $filterService;
        $this->performanceService = $performanceService;
    }

    /**
     * Get all CMS pages with filters and pagination
     */
    public function getCmsPages(Request $request): LengthAwarePaginator
    {
        $filterConfig = [
            'search_fields' => ['title_en', 'title_ar', 'slug'],
            'status_field' => 'status',
            'date_field' => 'created_at',
            'default_sort' => 'id',
            'default_order' => 'desc',
            'select_columns' => [
                'id', 'title_en', 'title_ar', 'slug', 'status', 
                'meta_title', 'meta_description', 'meta_keywords',
                'created_at', 'updated_at'
            ],
        ];

        // Force fresh data by clearing any potential caching
        $query = CmsPage::query();
        
        // Always force fresh data to prevent caching issues
        $query->reorder();
        
        // If there are flash messages, disable caching to ensure fresh data
        $disableCache = $request->session()->has('flash.success') || $request->session()->has('flash.error');
        
        if ($disableCache) {
            // Clear any existing cache
            $this->performanceService->clearCache('cms_pages_*');
        }
        
        $pages = $this->performanceService->getOptimizedResults($query, $request, $filterConfig, 10, $disableCache ? 0 : 5);

        return $pages;
    }

    /**
     * Get CMS page for edit
     */
    public function getCmsPageForEdit(CmsPage $cmsPage): array
    {
        return $cmsPage->toArray();
    }

    /**
     * Get CMS page for show
     */
    public function getCmsPageForShow(CmsPage $cmsPage): array
    {
        return $cmsPage->toArray();
    }

    /**
     * Create new CMS page
     */
    public function createCmsPage(array $validated): CmsPage
    {
        // Generate slug if not provided
        if (empty($validated['slug'])) {
            $validated['slug'] = $this->generateUniqueSlug($validated['title_en']);
        }

        $cmsPage = CmsPage::create($validated);
        
        // Clear cache to ensure fresh data is loaded
        $this->performanceService->clearCache('cms_pages_*');
        
        return $cmsPage;
    }

    /**
     * Update existing CMS page
     */
    public function updateCmsPage(CmsPage $cmsPage, array $validated): bool
    {
        // Generate slug if not provided
        if (empty($validated['slug'])) {
            $validated['slug'] = $this->generateUniqueSlug($validated['title_en'], $cmsPage->id);
        }

        $result = $cmsPage->update($validated);
        
        // Clear cache to ensure fresh data is loaded
        if ($result) {
            $this->performanceService->clearCache('cms_pages_*');
        }
        
        return $result;
    }

    /**
     * Toggle CMS page status between 'active' and 'suspended'
     */
    public function suspendCmsPage(CmsPage $cmsPage): bool
    {
        $newStatus = $cmsPage->status === 'suspended' ? 'active' : 'suspended';
        $result = $cmsPage->update(['status' => $newStatus]);
        
        // Clear cache to ensure fresh data is loaded
        if ($result) {
            $this->performanceService->clearCache('cms_pages_*');
        }
        
        return $result;
    }

    /**
     * Delete CMS page (soft delete)
     */
    public function deleteCmsPage(CmsPage $cmsPage): bool
    {
        $result = $cmsPage->delete();
        
        // Clear cache to ensure fresh data is loaded
        if ($result) {
            $this->performanceService->clearCache('cms_pages_*');
        }
        
        return $result;
    }

    /**
     * Get filters data
     */
    public function getFiltersData(Request $request): array
    {
        $filters = $this->filterService->getFilterData($request, [
            'search', 'status', 'date_from', 'date_to', 'sort_by', 'sort_order'
        ]);
        
        return [
            'filters' => $filters,
            'has_active_filters' => $this->filterService->hasActiveFilters($request),
            'active_filter_count' => $this->filterService->getActiveFilterCount($request),
        ];
    }

    /**
     * Get CMS page statistics
     */
    public function getCmsPageStats(): array
    {
        return [
            'total' => CmsPage::count(),
            'active' => CmsPage::where('status', 'active')->count(),
            'suspended' => CmsPage::where('status', 'suspended')->count(),
            'draft' => CmsPage::where('status', 'draft')->count(),
        ];
    }

    /**
     * Generate unique slug from title
     */
    private function generateUniqueSlug(string $title, ?int $excludeId = null): string
    {
        $baseSlug = Str::slug($title);
        $slug = $baseSlug;
        $counter = 1;

        while ($this->slugExists($slug, $excludeId)) {
            $slug = $baseSlug . '-' . $counter;
            $counter++;
        }

        return $slug;
    }

    /**
     * Check if slug exists
     */
    private function slugExists(string $slug, ?int $excludeId = null): bool
    {
        $query = CmsPage::where('slug', $slug);
        
        if ($excludeId) {
            $query->where('id', '!=', $excludeId);
        }
        
        return $query->exists();
    }

    /**
     * Debug method to check if cache is working properly
     */
    public function debugCacheStatus(Request $request): array
    {
        $filterConfig = [
            'search_fields' => ['title_en', 'title_ar', 'slug'],
            'status_field' => 'status',
        ];

        $query = CmsPage::query();
        $cacheKey = 'cms_pages_' . md5(serialize($request->all()) . md5(serialize($filterConfig)) . 10);
        
        return [
            'cache_exists' => \Illuminate\Support\Facades\Cache::has($cacheKey),
            'cache_key' => $cacheKey,
            'total_pages' => CmsPage::count(),
            'active_pages' => CmsPage::where('status', 'active')->count(),
            'suspended_pages' => CmsPage::where('status', 'suspended')->count(),
            'draft_pages' => CmsPage::where('status', 'draft')->count(),
            'has_flash_messages' => $request->session()->has('flash.success') || $request->session()->has('flash.error'),
        ];
    }
} 