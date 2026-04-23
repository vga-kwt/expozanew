<?php

namespace App\Http\Controllers;

use App\Http\Controllers\Controller;
use App\Http\Requests\City\StoreCityRequest;
use App\Http\Requests\City\UpdateCityRequest;
use App\Models\City;
use App\Models\Country;
use App\Models\State;
use App\Services\CityService;
use App\Helpers\ExportService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;
use Inertia\Inertia;

class CityController extends Controller
{
    protected $cityService;

    public function __construct(CityService $cityService)
    {
        $this->cityService = $cityService;
    }

    /**
     * Display a listing of the resource.
     */
    public function index(Request $request)
    {
        $filters = $request->only(['search', 'status', 'country_id', 'state_id', 'date_from', 'date_to']);
        $cities = $this->cityService->getPaginatedCities($filters, 10);
        $statistics = $this->cityService->getStatistics();

        // Get countries and states for filters
        $countries = Country::active()->orderBy('name_en')->get(['id', 'name_en', 'name_ar']);
        $states = State::active()->orderBy('name_en')->get(['id', 'name_en', 'name_ar', 'country_id']);

        return Inertia::render('City/index', [
            'cities' => $cities,
            'statistics' => $statistics,
            'filters' => $filters,
            'countries' => $countries,
            'states' => $states,
        ]);
    }

    /**
     * Show the form for creating a new resource.
     */
    public function create()
    {
        $countries = Country::active()->orderBy('name_en')->get(['id', 'name_en', 'name_ar']);
        $states = State::active()->orderBy('name_en')->get(['id', 'name_en', 'name_ar', 'country_id']);

        return Inertia::render('City/Create', [
            'countries' => $countries,
            'states' => $states,
        ]);
    }

    /**
     * Store a newly created resource in storage.
     */
    public function store(StoreCityRequest $request)
    {
        try {
            $city = $this->cityService->createCity($request->validated());

            return redirect()->route('city.index')
                ->with('success', 'City created successfully.');
        } catch (\Exception $e) {
            return back()->withInput()
                ->with('error', 'Failed to create city. Please try again.');
        }
    }

    /**
     * Display the specified resource.
     */
    public function show(City $city)
    {
        return Inertia::render('City/Show', [
            'city' => $city->load(['country', 'state']),
        ]);
    }

    /**
     * Show the form for editing the specified resource.
     */
    public function edit(City $city)
    {
        $countries = Country::active()->orderBy('name_en')->get(['id', 'name_en', 'name_ar']);
        $states = State::active()->orderBy('name_en')->get(['id', 'name_en', 'name_ar', 'country_id']);

        return Inertia::render('City/Edit', [
            'city' => $city->load(['country', 'state']),
            'countries' => $countries,
            'states' => $states,
        ]);
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(UpdateCityRequest $request, City $city)
    {
        try {
            $this->cityService->updateCity($city, $request->validated());

            return redirect()->route('city.index')
                ->with('success', 'City updated successfully.');
        } catch (\Exception $e) {
            return back()->withInput()
                ->with('error', 'Failed to update city. Please try again.');
        }
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(City $city)
    {
        try {
            $this->cityService->deleteCity($city);

            return redirect()->route('city.index')
                ->with('success', 'City deleted successfully.');
        } catch (\Exception $e) {
            return back()->with('error', 'Failed to delete city. Please try again.');
        }
    }

    /**
     * Toggle city status
     */
    public function toggleStatus(City $city)
    {
        try {
            $this->cityService->toggleStatus($city);

            return back()->with('success', 'City status updated successfully.');
        } catch (\Exception $e) {
            return back()->with('error', 'Failed to update city status. Please try again.');
        }
    }

    /**
     * Restore a soft deleted city
     */
    public function restore($id)
    {
        try {
            $this->cityService->restoreCity($id);

            return back()->with('success', 'City restored successfully.');
        } catch (\Exception $e) {
            return back()->with('error', 'Failed to restore city. Please try again.');
        }
    }

    /**
     * Permanently delete a city
     */
    public function forceDelete($id)
    {
        try {
            $this->cityService->forceDeleteCity($id);

            return back()->with('success', 'City permanently deleted.');
        } catch (\Exception $e) {
            return back()->with('error', 'Failed to permanently delete city. Please try again.');
        }
    }

    /**
     * Export cities to CSV
     */
    public function export(Request $request)
    {
       
        try {
            // Log the request for debugging
            Log::info('City export request received', [
                'filters' => $request->all(),
                'url' => $request->url(),
                'method' => $request->method(),
            ]);

            // Get filters from request
            $filters = $request->only(['search', 'status', 'country_id', 'state_id', 'date_from', 'date_to']);

            // Get all cities with filters (no pagination)
            $cities = $this->cityService->getCitiesForExport($filters);

            // Define CSV headers
            $headers = [
                'ID',
                'Name (English)',
                'Name (Arabic)',
                'Country',
                'State',
                'Status',
                'Created At',
                'Updated At'
            ];

            // Prepare data for CSV
            $data = $cities->map(function ($city) {
                return [
                    $city->id,
                    $city->name_en,
                    $city->name_ar,
                    $city->country->name_en ?? '',
                    $city->state->name_en ?? '',
                    $city->status === 'active' ? 'Active' : 'Suspended',
                    $city->created_at->format('Y-m-d H:i:s'),
                    $city->updated_at->format('Y-m-d H:i:s')
                ];
            });

            // Generate filename with timestamp
            $filename = 'cities_' . now()->format('Y-m-d_H-i-s') . '.csv';

            Log::info('City export completed', [
                'filename' => $filename,
                'record_count' => $data->count(),
            ]);

            return ExportService::streamCsv($data, $filename, $headers);
        } catch (\Exception $e) {
            Log::error('City export failed', [
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString(),
            ]);

            return back()->with('error', 'Failed to export cities. Please try again.');
        }
    }

    /**
     * Get cities for API (for dropdowns, etc.)
     */
    public function apiIndex(Request $request)
    {
        $cities = City::with(['country', 'state'])
            ->active()
            ->when($request->search, function ($query, $search) {
                $query->search($search);
            })
            ->when($request->country_id, function ($query, $countryId) {
                $query->where('country_id', $countryId);
            })
            ->when($request->state_id, function ($query, $stateId) {
                $query->where('state_id', $stateId);
            })
            ->orderBy('name_en')
            ->get(['id', 'name_en', 'name_ar', 'country_id', 'state_id']);

        return response()->json($cities);
    }

    /**
     * Get states by country for dynamic dropdown
     */
    public function getStatesByCountry(Request $request)
    {
        $states = State::where('country_id', $request->country_id)
            ->active()
            ->orderBy('name_en')
            ->get(['id', 'name_en', 'name_ar']);

        return response()->json($states);
    }
}
