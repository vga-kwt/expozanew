<?php

namespace App\Http\Controllers;

use App\Http\Controllers\Controller;
use App\Http\Requests\State\StoreStateRequest;
use App\Http\Requests\State\UpdateStateRequest;
use App\Models\State;
use App\Models\Country;
use App\Services\StateService;
use App\Helpers\ExportService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;
use Inertia\Inertia;

class StateController extends Controller
{
    protected $stateService;

    public function __construct(StateService $stateService)
    {
        $this->stateService = $stateService;
    }

    /**
     * Display a listing of the resource.
     */
    public function index(Request $request)
    {
        $filters = $request->only(['search', 'status', 'country_id', 'date_from', 'date_to']);
        $states = $this->stateService->getPaginatedStates($filters, 10);
        $statistics = $this->stateService->getStatistics();
        
        // Get countries for filters
        $countries = Country::active()->orderBy('name_en')->get(['id', 'name_en', 'name_ar']);

        return Inertia::render('State/index', [
            'states' => $states,
            'statistics' => $statistics,
            'filters' => $filters,
            'countries' => $countries,
        ]);
    }

    /**
     * Show the form for creating a new resource.
     */
    public function create()
    {
        $countries = Country::active()->orderBy('name_en')->get(['id', 'name_en', 'name_ar']);

        return Inertia::render('State/Create', [
            'countries' => $countries,
        ]);
    }

    /**
     * Store a newly created resource in storage.
     */
    public function store(StoreStateRequest $request)
    {
        try {
            $state = $this->stateService->createState($request->validated());
            
            return redirect()->route('state.index')
                ->with('success', 'State created successfully.');
        } catch (\Exception $e) {
            return back()->withInput()
                ->with('error', 'Failed to create state. Please try again.');
        }
    }

    /**
     * Display the specified resource.
     */
    public function show(State $state)
    {
        return Inertia::render('State/Show', [
            'state' => $state->load(['country', 'cities']),
        ]);
    }

    /**
     * Show the form for editing the specified resource.
     */
    public function edit(State $state)
    {
        $countries = Country::active()->orderBy('name_en')->get(['id', 'name_en', 'name_ar']);

        return Inertia::render('State/Edit', [
            'state' => $state->load(['country']),
            'countries' => $countries,
        ]);
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(UpdateStateRequest $request, State $state)
    {
        try {
            $this->stateService->updateState($state, $request->validated());
            
            return redirect()->route('state.index')
                ->with('success', 'State updated successfully.');
        } catch (\Exception $e) {
            return back()->withInput()
                ->with('error', 'Failed to update state. Please try again.');
        }
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(State $state)
    {
        try {
            $this->stateService->deleteState($state);
            
            return redirect()->route('state.index')
                ->with('success', 'State deleted successfully.');
        } catch (\Exception $e) {
            return back()->with('error', 'Failed to delete state. Please try again.');
        }
    }

    /**
     * Toggle state status
     */
    public function toggleStatus(State $state)
    {
        try {
            $this->stateService->toggleStatus($state);
            
            return back()->with('success', 'State status updated successfully.');
        } catch (\Exception $e) {
            return back()->with('error', 'Failed to update state status. Please try again.');
        }
    }

    /**
     * Restore a soft deleted state
     */
    public function restore($id)
    {
        try {
            $this->stateService->restoreState($id);
            
            return back()->with('success', 'State restored successfully.');
        } catch (\Exception $e) {
            return back()->with('error', 'Failed to restore state. Please try again.');
        }
    }

    /**
     * Permanently delete a state
     */
    public function forceDelete($id)
    {
        try {
            $this->stateService->forceDeleteState($id);
            
            return back()->with('success', 'State permanently deleted.');
        } catch (\Exception $e) {
            return back()->with('error', 'Failed to permanently delete state. Please try again.');
        }
    }

    /**
     * Export states to CSV
     */
    public function export(Request $request)
    {
        try {
            // Log the request for debugging
            Log::info('State export request received', [
                'filters' => $request->all(),
                'url' => $request->url(),
                'method' => $request->method(),
            ]);
            
            // Get filters from request
            $filters = $request->only(['search', 'status', 'country_id', 'date_from', 'date_to']);
            
            // Get all states with filters (no pagination)
            $states = $this->stateService->getStatesForExport($filters);
            
            // Define CSV headers
            $headers = [
                'ID',
                'Name (English)',
                'Name (Arabic)',
                'Country',
                'Status',
                'Created At',
                'Updated At'
            ];
            
            // Prepare data for CSV
            $data = $states->map(function ($state) {
                return [
                    $state->id,
                    $state->name_en,
                    $state->name_ar,
                    $state->country->name_en ?? '',
                    $state->status === 'active' ? 'Active' : 'Suspended',
                    $state->created_at->format('Y-m-d H:i:s'),
                    $state->updated_at->format('Y-m-d H:i:s')
                ];
            });
            
            // Generate filename with timestamp
            $filename = 'states_' . now()->format('Y-m-d_H-i-s') . '.csv';
            
            Log::info('State export completed', [
                'filename' => $filename,
                'record_count' => $data->count(),
            ]);
            
            return ExportService::streamCsv($data, $filename, $headers);
            
        } catch (\Exception $e) {
            Log::error('State export failed', [
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString(),
            ]);
            
            return back()->with('error', 'Failed to export states. Please try again.');
        }
    }

    /**
     * Get states for API (for dropdowns, etc.)
     */
    public function apiIndex(Request $request)
    {
        $states = State::with(['country'])
            ->active()
            ->when($request->search, function ($query, $search) {
                $query->search($search);
            })
            ->when($request->country_id, function ($query, $countryId) {
                $query->where('country_id', $countryId);
            })
            ->orderBy('name_en')
            ->get(['id', 'name_en', 'name_ar', 'country_id']);

        return response()->json($states);
    }
}
