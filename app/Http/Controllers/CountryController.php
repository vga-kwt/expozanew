<?php

namespace App\Http\Controllers;

use App\Http\Controllers\Controller;
use App\Http\Requests\Country\StoreCountryRequest;
use App\Http\Requests\Country\UpdateCountryRequest;
use App\Models\Country;
use App\Services\CountryService;
use App\Helpers\ExportService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;
use Inertia\Inertia;

class CountryController extends Controller
{
    protected $countryService;

    public function __construct(CountryService $countryService)
    {
        $this->countryService = $countryService;
    }

    /**
     * Display a listing of the resource.
     */
    public function index(Request $request)
    {
        $filters = $request->only(['search', 'status', 'date_from', 'date_to']);
        $countries = $this->countryService->getPaginatedCountries($filters, 10);
        $statistics = $this->countryService->getStatistics();

        return Inertia::render('Country/index', [
            'countries' => $countries,
            'statistics' => $statistics,
            'filters' => $filters,
        ]);
    }

    /**
     * Show the form for creating a new resource.
     */
    public function create()
    {
        return Inertia::render('Country/Create');
    }

    /**
     * Store a newly created resource in storage.
     */
    public function store(StoreCountryRequest $request)
    {
        try {
            $country = $this->countryService->createCountry($request->validated());
            
            return redirect()->route('country.index')
                ->with('success', 'Country created successfully.');
        } catch (\Exception $e) {
            return back()->withInput()
                ->with('error', 'Failed to create country. Please try again.');
        }
    }

    /**
     * Display the specified resource.
     */
    public function show(Country $country)
    {
        return Inertia::render('Country/Show', [
            'country' => $country->load(['states', 'cities']),
        ]);
    }

    /**
     * Show the form for editing the specified resource.
     */
    public function edit(Country $country)
    {
        return Inertia::render('Country/Edit', [
            'country' => $country,
        ]);
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(UpdateCountryRequest $request, Country $country)
    {
        try {
            $this->countryService->updateCountry($country, $request->validated());
            
            return redirect()->route('country.index')
                ->with('success', 'Country updated successfully.');
        } catch (\Exception $e) {
            return back()->withInput()
                ->with('error', 'Failed to update country. Please try again.');
        }
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(Country $country)
    {
        try {
            $this->countryService->deleteCountry($country);
            
            return redirect()->route('country.index')
                ->with('success', 'Country deleted successfully.');
        } catch (\Exception $e) {
            return back()->with('error', 'Failed to delete country. Please try again.');
        }
    }

    /**
     * Toggle country status
     */
    public function toggleStatus(Country $country)
    {
        try {
            $this->countryService->toggleStatus($country);
            
            return back()->with('success', 'Country status updated successfully.');
        } catch (\Exception $e) {
            return back()->with('error', 'Failed to update country status. Please try again.');
        }
    }

    /**
     * Restore a soft deleted country
     */
    public function restore($id)
    {
        try {
            $this->countryService->restoreCountry($id);
            
            return back()->with('success', 'Country restored successfully.');
        } catch (\Exception $e) {
            return back()->with('error', 'Failed to restore country. Please try again.');
        }
    }

    /**
     * Permanently delete a country
     */
    public function forceDelete($id)
    {
        try {
            $this->countryService->forceDeleteCountry($id);
            
            return back()->with('success', 'Country permanently deleted.');
        } catch (\Exception $e) {
            return back()->with('error', 'Failed to permanently delete country. Please try again.');
        }
    }

    /**
     * Export countries to CSV
     */
    public function export(Request $request)
    {
        try {
            // Log the request for debugging
            Log::info('Country export request received', [
                'filters' => $request->all(),
                'url' => $request->url(),
                'method' => $request->method(),
            ]);
            
            // Get filters from request
            $filters = $request->only(['search', 'status', 'date_from', 'date_to']);
            
            // Get all countries with filters (no pagination)
            $countries = $this->countryService->getCountriesForExport($filters);
            
            // Define CSV headers
            $headers = [
                'ID',
                'Name (English)',
                'Name (Arabic)',
                'Status',
                'Created At',
                'Updated At'
            ];
            
            // Prepare data for CSV
            $data = $countries->map(function ($country) {
                return [
                    $country->id,
                    $country->name_en,
                    $country->name_ar,
                    $country->status === 'active' ? 'Active' : 'Suspended',
                    $country->created_at->format('Y-m-d H:i:s'),
                    $country->updated_at->format('Y-m-d H:i:s')
                ];
            });
            
            // Generate filename with timestamp
            $filename = 'countries_' . now()->format('Y-m-d_H-i-s') . '.csv';
            
            Log::info('Country export completed', [
                'filename' => $filename,
                'record_count' => $data->count(),
            ]);
            
            return ExportService::streamCsv($data, $filename, $headers);
            
        } catch (\Exception $e) {
            Log::error('Country export failed', [
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString(),
            ]);
            
            return back()->with('error', 'Failed to export countries. Please try again.');
        }
    }

    /**
     * Get countries for API (for dropdowns, etc.)
     */
    public function apiIndex(Request $request)
    {
        $countries = Country::active()
            ->when($request->search, function ($query, $search) {
                $query->search($search);
            })
            ->orderBy('name_en')
            ->get(['id', 'name_en', 'name_ar']);

        return response()->json($countries);
    }
}
