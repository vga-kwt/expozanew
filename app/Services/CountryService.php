<?php

namespace App\Services;

use App\Models\Country;
use Illuminate\Pagination\LengthAwarePaginator;
use Illuminate\Support\Facades\DB;

class CountryService
{
    /**
     * Get paginated countries with filters
     */
    public function getPaginatedCountries(array $filters = [], int $perPage = 10): LengthAwarePaginator
    {
        $query = Country::query();

        // Apply search filter
        if (!empty($filters['search'])) {
            $query->search($filters['search']);
        }

        // Apply status filter
        if (!empty($filters['status'])) {
            $query->filterByStatus($filters['status']);
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
     * Get all active countries
     */
    public function getActiveCountries()
    {
        return Country::active()->orderBy('name_en')->get();
    }

    /**
     * Create a new country
     */
    public function createCountry(array $data): Country
    {
        return DB::transaction(function () use ($data) {
            return Country::create($data);
        });
    }

    /**
     * Update an existing country
     */
    public function updateCountry(Country $country, array $data): Country
    {
        return DB::transaction(function () use ($country, $data) {
            $country->update($data);
            return $country->fresh();
        });
    }

    /**
     * Toggle country status
     */
    public function toggleStatus(Country $country): Country
    {
        return DB::transaction(function () use ($country) {
            $country->update([
                'status' => $country->status === 'active' ? 'suspended' : 'active'
            ]);
            return $country->fresh();
        });
    }

    /**
     * Soft delete a country
     */
    public function deleteCountry(Country $country): bool
    {
        return DB::transaction(function () use ($country) {
            return $country->delete();
        });
    }

    /**
     * Restore a soft deleted country
     */
    public function restoreCountry(int $countryId): bool
    {
        return DB::transaction(function () use ($countryId) {
            $country = Country::withTrashed()->findOrFail($countryId);
            return $country->restore();
        });
    }

    /**
     * Permanently delete a country
     */
    public function forceDeleteCountry(int $countryId): bool
    {
        return DB::transaction(function () use ($countryId) {
            $country = Country::withTrashed()->findOrFail($countryId);
            return $country->forceDelete();
        });
    }

    /**
     * Get country statistics
     */
    public function getStatistics(): array
    {
        return [
            'total' => Country::count(),
            'active' => Country::active()->count(),
            'suspended' => Country::suspended()->count(),
            'deleted' => Country::onlyTrashed()->count(),
        ];
    }

    /**
     * Get countries for export (with filters, no pagination)
     */
    public function getCountriesForExport(array $filters = [])
    {
        $query = Country::query();

        // Apply search filter
        if (!empty($filters['search'])) {
            $query->search($filters['search']);
        }

        // Apply status filter
        if (!empty($filters['status'])) {
            $query->filterByStatus($filters['status']);
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