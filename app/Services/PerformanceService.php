<?php

namespace App\Services;

use Illuminate\Database\Eloquent\Builder;
use Illuminate\Http\Request;
use Illuminate\Pagination\LengthAwarePaginator;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\DB;

class PerformanceService
{
    protected FilterService $filterService;

    public function __construct(FilterService $filterService)
    {
        $this->filterService = $filterService;
    }

    /**
     * Get optimized paginated results with caching
     */
    public function getOptimizedResults(
        Builder $query, 
        Request $request, 
        array $filterConfig = [], 
        int $perPage = 10,
        int $cacheMinutes = 5
    ): LengthAwarePaginator {
        // Generate cache key based on request parameters
        $cacheKey = $this->generateCacheKey($request, $filterConfig, $perPage);
        
        // Try to get from cache first
        if (Cache::has($cacheKey)) {
            return Cache::get($cacheKey);
        }

        // Apply filters
        $this->filterService->applyFilters($query, $request, $filterConfig);
        
        // Optimize query
        $this->optimizeQuery($query, $filterConfig);
        
        // Get results with pagination
        $results = $query->paginate($perPage)->withQueryString();
        
        // Cache results
        Cache::put($cacheKey, $results, $cacheMinutes * 60);
        
        return $results;
    }

    /**
     * Optimize query for better performance
     */
    private function optimizeQuery(Builder $query, array $filterConfig = []): void
    {
        // Select only needed columns
        if (isset($filterConfig['select_columns'])) {
            $query->select($filterConfig['select_columns']);
        }

        // Add indexes hints if needed
        if (isset($filterConfig['use_index'])) {
            $query->from(DB::raw($query->getModel()->getTable() . ' USE INDEX (' . $filterConfig['use_index'] . ')'));
        }

        // Limit subqueries
        $query->limit(10000); // Prevent excessive data loading
    }

    /**
     * Generate unique cache key
     */
    private function generateCacheKey(Request $request, array $filterConfig, int $perPage): string
    {
        $params = $request->all();
        $configHash = md5(serialize($filterConfig));
        
        return 'optimized_results_' . md5(serialize($params) . $configHash . $perPage);
    }

    /**
     * Get lazy loaded results for infinite scroll
     */
    public function getLazyLoadedResults(
        Builder $query, 
        Request $request, 
        array $filterConfig = [], 
        int $perPage = 20
    ): array {
        $page = $request->get('page', 1);
        $offset = ($page - 1) * $perPage;
        
        // Apply filters
        $this->filterService->applyFilters($query, $request, $filterConfig);
        
        // Optimize query
        $this->optimizeQuery($query, $filterConfig);
        
        // Get total count (cached)
        $totalCount = $this->getCachedCount($query, $request, $filterConfig);
        
        // Get paginated results
        $results = $query->offset($offset)->limit($perPage)->get();
        
        return [
            'data' => $results,
            'has_more' => ($offset + $perPage) < $totalCount,
            'total' => $totalCount,
            'current_page' => $page,
        ];
    }

    /**
     * Get cached count for performance
     */
    private function getCachedCount(Builder $query, Request $request, array $filterConfig): int
    {
        $cacheKey = 'count_' . md5($query->toSql() . serialize($query->getBindings()));
        
        return Cache::remember($cacheKey, 300, function () use ($query) {
            return $query->count();
        });
    }

    /**
     * Get optimized results with eager loading
     */
    public function getResultsWithEagerLoading(
        Builder $query, 
        Request $request, 
        array $filterConfig = [], 
        array $relations = [],
        int $perPage = 10
    ): LengthAwarePaginator {
        // Apply eager loading
        if (!empty($relations)) {
            $query->with($relations);
        }

        // Apply filters
        $this->filterService->applyFilters($query, $request, $filterConfig);
        
        // Optimize query
        $this->optimizeQuery($query, $filterConfig);
        
        return $query->paginate($perPage)->withQueryString();
    }

    /**
     * Get results with database optimization
     */
    public function getDatabaseOptimizedResults(
        Builder $query, 
        Request $request, 
        array $filterConfig = [], 
        int $perPage = 10
    ): LengthAwarePaginator {
        // Use database-specific optimizations
        $this->applyDatabaseOptimizations($query);
        
        // Apply filters
        $this->filterService->applyFilters($query, $request, $filterConfig);
        
        return $query->paginate($perPage)->withQueryString();
    }

    /**
     * Apply database-specific optimizations
     */
    private function applyDatabaseOptimizations(Builder $query): void
    {
        $connection = $query->getConnection();
        $driver = $connection->getDriverName();

        switch ($driver) {
            case 'mysql':
                // MySQL specific optimizations
                $query->from(DB::raw($query->getModel()->getTable() . ' FORCE INDEX (PRIMARY)'));
                break;
                
            case 'pgsql':
                // PostgreSQL specific optimizations
                $query->from(DB::raw($query->getModel()->getTable() . ' USE INDEX (PRIMARY)'));
                break;
                
            case 'sqlite':
                // SQLite specific optimizations
                $query->from(DB::raw($query->getModel()->getTable() . ' INDEXED BY sqlite_autoindex_' . $query->getModel()->getTable() . '_1'));
                break;
        }
    }

    /**
     * Get results with chunked loading for very large datasets
     */
    public function getChunkedResults(
        Builder $query, 
        Request $request, 
        array $filterConfig = [], 
        int $chunkSize = 1000,
        int $perPage = 10
    ): LengthAwarePaginator {
        // Apply filters
        $this->filterService->applyFilters($query, $request, $filterConfig);
        
        // Get total count
        $total = $query->count();
        
        // Get current page
        $page = $request->get('page', 1);
        $offset = ($page - 1) * $perPage;
        
        // Get results with chunking
        $results = collect();
        $query->chunk($chunkSize, function ($chunk) use (&$results, $offset, $perPage) {
            $results = $results->merge($chunk);
        });
        
        // Slice for pagination
        $paginatedResults = $results->slice($offset, $perPage);
        
        return new LengthAwarePaginator(
            $paginatedResults,
            $total,
            $perPage,
            $page,
            ['path' => $request->url(), 'query' => $request->query()]
        );
    }

    /**
     * Clear performance cache
     */
    public function clearCache(string $pattern = 'optimized_results_*'): void
    {
        if (method_exists(Cache::getStore(), 'flush')) {
            Cache::flush();
        } else {
            // For file cache, clear specific patterns
            $this->clearCacheByPattern($pattern);
        }
    }

    /**
     * Clear cache by pattern
     */
    private function clearCacheByPattern(string $pattern): void
    {
        // Implementation depends on cache driver
        // This is a basic implementation
        Cache::forget($pattern);
    }

    /**
     * Get performance statistics
     */
    public function getPerformanceStats(Builder $query, Request $request, array $filterConfig = []): array
    {
        $startTime = microtime(true);
        
        // Get results
        $results = $this->getOptimizedResults($query, $request, $filterConfig);
        
        $endTime = microtime(true);
        $executionTime = ($endTime - $startTime) * 1000; // Convert to milliseconds
        
        return [
            'execution_time_ms' => round($executionTime, 2),
            'total_records' => $results->total(),
            'per_page' => $results->perPage(),
            'current_page' => $results->currentPage(),
            'last_page' => $results->lastPage(),
            'from' => $results->firstItem(),
            'to' => $results->lastItem(),
            'has_more_pages' => $results->hasMorePages(),
        ];
    }

    /**
     * Optimize images for better loading
     */
    public function optimizeImages(array $images, int $maxWidth = 800, int $quality = 80): array
    {
        return array_map(function ($image) use ($maxWidth, $quality) {
            if (isset($image['url'])) {
                // Add image optimization parameters
                $image['optimized_url'] = $this->getOptimizedImageUrl($image['url'], $maxWidth, $quality);
                $image['thumbnail_url'] = $this->getOptimizedImageUrl($image['url'], 300, 70);
            }
            return $image;
        }, $images);
    }

    /**
     * Get optimized image URL
     */
    private function getOptimizedImageUrl(string $url, int $width, int $quality): string
    {
        // This is a placeholder - implement based on your image optimization service
        // You can use services like Cloudinary, ImageKit, or custom image optimization
        return $url . "?w={$width}&q={$quality}";
    }
} 