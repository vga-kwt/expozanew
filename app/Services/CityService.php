<?php

namespace App\Services;

use App\Models\City;
use Illuminate\Pagination\LengthAwarePaginator;
use Illuminate\Support\Facades\DB;

class CityService
{
    /**
     * Get paginated cities with filters
     */
    public function getPaginatedCities(array $filters = [], int $perPage = 10): LengthAwarePaginator
    {
        $query = City::with(['country', 'state']);

        // Apply search filter
        if (!empty($filters['search'])) {
            $query->search($filters['search']);
        }

        // Apply status filter
        if (!empty($filters['status'])) {
            $query->filterByStatus($filters['status']);
        }

        // Apply country filter
        if (!empty($filters['country_id'])) {
            $query->filterByCountry($filters['country_id']);
        }

        // Apply state filter
        if (!empty($filters['state_id'])) {
            $query->filterByState($filters['state_id']);
        }

        // Apply date filters
        if (!empty($filters['date_from'])) {
            $query->whereDate('created_at', '>=', $filters['date_from']);
        }

        if (!empty($filters['date_to'])) {
            $query->whereDate('created_at', '<=', $filters['date_to']);
        }

        return $query->orderBy('created_at', 'desc')->paginate($perPage);
    }

    /**
     * Get all active cities
     */
    public function getActiveCities()
    {
        return City::with(['country', 'state'])->active()->orderBy('name_en')->get();
    }

    /**
     * Create a new city
     */
    public function createCity(array $data): City
    {
        return DB::transaction(function () use ($data) {
            return City::create($data);
        });
    }

    /**
     * Update an existing city
     */
    public function updateCity(City $city, array $data): City
    {
        return DB::transaction(function () use ($city, $data) {
            $city->update($data);
            return $city->fresh();
        });
    }

    /**
     * Toggle city status
     */
    public function toggleStatus(City $city): City
    {
        return DB::transaction(function () use ($city) {
            $city->update([
                'status' => $city->status === 'active' ? 'suspended' : 'active'
            ]);
            return $city->fresh();
        });
    }

    /**
     * Soft delete a city
     */
    public function deleteCity(City $city): bool
    {
        return DB::transaction(function () use ($city) {
            return $city->delete();
        });
    }

    /**
     * Restore a soft deleted city
     */
    public function restoreCity(int $cityId): bool
    {
        return DB::transaction(function () use ($cityId) {
            $city = City::withTrashed()->findOrFail($cityId);
            return $city->restore();
        });
    }

    /**
     * Permanently delete a city
     */
    public function forceDeleteCity(int $cityId): bool
    {
        return DB::transaction(function () use ($cityId) {
            $city = City::withTrashed()->findOrFail($cityId);
            return $city->forceDelete();
        });
    }

    /**
     * Get city statistics
     */
    public function getStatistics(): array
    {
        return [
            'total' => City::count(),
            'active' => City::active()->count(),
            'suspended' => City::suspended()->count(),
            'deleted' => City::onlyTrashed()->count(),
        ];
    }

    /**
     * Get cities for export (with filters, no pagination)
     */
    public function getCitiesForExport(array $filters = [])
    {
        $query = City::with(['country', 'state']);

        // Apply search filter
        if (!empty($filters['search'])) {
            $query->search($filters['search']);
        }

        // Apply status filter
        if (!empty($filters['status'])) {
            $query->filterByStatus($filters['status']);
        }

        // Apply country filter
        if (!empty($filters['country_id'])) {
            $query->filterByCountry($filters['country_id']);
        }

        // Apply state filter
        if (!empty($filters['state_id'])) {
            $query->filterByState($filters['state_id']);
        }

        // Apply date filters
        if (!empty($filters['date_from'])) {
            $query->whereDate('created_at', '>=', $filters['date_from']);
        }

        if (!empty($filters['date_to'])) {
            $query->whereDate('created_at', '<=', $filters['date_to']);
        }

        return $query->orderBy('created_at', 'desc')->get();
    }
} 