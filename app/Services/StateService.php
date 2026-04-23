<?php

namespace App\Services;

use App\Models\State;
use Illuminate\Pagination\LengthAwarePaginator;
use Illuminate\Support\Facades\DB;

class StateService
{
    /**
     * Get paginated states with filters
     */
    public function getPaginatedStates(array $filters = [], int $perPage = 10): LengthAwarePaginator
    {
        $query = State::with(['country']);

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
     * Get all active states
     */
    public function getActiveStates()
    {
        return State::with(['country'])->active()->orderBy('name_en')->get();
    }

    /**
     * Create a new state
     */
    public function createState(array $data): State
    {
        return DB::transaction(function () use ($data) {
            return State::create($data);
        });
    }

    /**
     * Update an existing state
     */
    public function updateState(State $state, array $data): State
    {
        return DB::transaction(function () use ($state, $data) {
            $state->update($data);
            return $state->fresh();
        });
    }

    /**
     * Toggle state status
     */
    public function toggleStatus(State $state): State
    {
        return DB::transaction(function () use ($state) {
            $state->update([
                'status' => $state->status === 'active' ? 'suspended' : 'active'
            ]);
            return $state->fresh();
        });
    }

    /**
     * Soft delete a state
     */
    public function deleteState(State $state): bool
    {
        return DB::transaction(function () use ($state) {
            return $state->delete();
        });
    }

    /**
     * Restore a soft deleted state
     */
    public function restoreState(int $stateId): bool
    {
        return DB::transaction(function () use ($stateId) {
            $state = State::withTrashed()->findOrFail($stateId);
            return $state->restore();
        });
    }

    /**
     * Permanently delete a state
     */
    public function forceDeleteState(int $stateId): bool
    {
        return DB::transaction(function () use ($stateId) {
            $state = State::withTrashed()->findOrFail($stateId);
            return $state->forceDelete();
        });
    }

    /**
     * Get state statistics
     */
    public function getStatistics(): array
    {
        return [
            'total' => State::count(),
            'active' => State::active()->count(),
            'suspended' => State::suspended()->count(),
            'deleted' => State::onlyTrashed()->count(),
        ];
    }

    /**
     * Get states for export (with filters, no pagination)
     */
    public function getStatesForExport(array $filters = [])
    {
        $query = State::with(['country']);

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