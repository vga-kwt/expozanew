<?php

namespace App\Http\Controllers;

use App\Http\Controllers\Controller;
use App\Http\Requests\Section\StoreSectionRequest;
use App\Http\Requests\Section\UpdateSectionRequest;
use App\Models\Category;
use App\Models\Product;
use App\Models\Section;
use App\Models\SectionProduct;
use App\Services\SectionService;
use App\Helpers\ExportService;
use Illuminate\Http\Request;
use Inertia\Inertia;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;

class SectionController extends Controller
{
    protected $service;

    public function __construct(SectionService $service)
    {
        $this->service = $service;
    }

    public function index(Request $request)
    {
        // Get filters from request
        $filters = $request->only(['search', 'status', 'date_from', 'date_to', 'category_id']);

        // Get authenticated user and vendor
        $user = $request->user();
        $vendor = $user->vendor;

        if (!$vendor) {
            return redirect()->back()->withErrors(['error' => 'Vendor profile not found.']);
        }

        // Use service to get filtered sections
        $sections = $this->service->list($filters, $request);

        // Get all categories
        $categories = Category::get();

        // Get ALL vendor's products for modal (not filtered)
        $allProducts = Product::where('vendor_id', $vendor->id)->get();
        // Get filtered products for table display (if category filter is applied)
        $filteredProducts = $allProducts;
        if (!empty($filters['category_id']) && $filters['category_id'] !== 'all') {
            $filteredProducts = $allProducts->where('category_id', $filters['category_id']);
        }

        return Inertia::render('Vendor/Sections/Index', [
            'sections' => $sections,
            'category' => $categories,
            'product' => $allProducts, // Always pass all products for modal
            'filters' => $filters,
        ]);
    }



    public function export(Request $request)
    {
        try {
            // Get filters from request
            $filters = $request->only(['search', 'status', 'date_from', 'date_to']);

            // Get all sections with filters (no pagination)
            $sections = $this->service->getSectionsForExport($filters);

            // Define CSV headers
            $headers = [
                'ID',
                'Section Name',
                'Category',
                'Status',
                'Products Count',
                'Created At',
                'Updated At'
            ];

            // Prepare data for CSV
            $data = $sections->map(function ($section) {
                return [
                    $section->id,
                    $section->name,
                    $section->category?->name_en ?? $section->category?->name ?? 'N/A',
                    $section->status === 'active' ? 'Active' : 'Suspended',
                    $section->sectionProducts?->count() ?? 0,
                    $section->created_at->format('Y-m-d H:i:s'),
                    $section->updated_at->format('Y-m-d H:i:s')
                ];
            });

            // Generate filename with timestamp
            $filename = 'sections_' . now()->format('Y-m-d_H-i-s') . '.csv';

            return ExportService::streamCsv($data, $filename, $headers);
        } catch (\Exception $e) {
            Log::error('Section export failed', [
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString(),
            ]);
            return back()->with('error', 'Failed to export sections. Please try again.');
        }
    }

    public function store(StoreSectionRequest $request)
    {
        // Get the vendor ID from the authenticated user
        $user = $request->user();
        $vendor = $user->vendor;
        
        if (!$vendor) {
            return redirect()->back()->with('error', 'Vendor profile not found.');
        }

        // Create the section
        $section = Section::create([
            'name' => $request->name,
            'category_id' => $request->category_id,
            'vendor_id' => $vendor->id,
            'status' => $request->status,
        ]);

        // Store products in section_products
        foreach ($request->product_ids as $productId) {
            SectionProduct::create([
                'section_id' => $section->id,
                'product_id' => $productId,
                'vendor_id' => $vendor->id,
            ]);
        }

        return redirect()->back()->with('success', 'Section created successfully.');
    }

    public function update(UpdateSectionRequest $request, Section $section)
    {
        // Get the vendor ID from the authenticated user
        $user = $request->user();
        $vendor = $user->vendor;
        
        if (!$vendor) {
            return redirect()->back()->with('error', 'Vendor profile not found.');
        }

        DB::transaction(function () use ($request, $section, $vendor) {
            $section->update([
                'name' => $request->name,
                'category_id' => $request->category_id,
                'status' => $request->status,
            ]);

            // Remove old products
            SectionProduct::where('section_id', $section->id)->delete();

            // Add new products
            foreach ($request->product_ids as $productId) {
                SectionProduct::create([
                    'section_id' => $section->id,
                    'product_id' => $productId,
                    'vendor_id' => $vendor->id,
                ]);
            }
        });

        return redirect()->back()->with('success', 'Section updated successfully.');
    }

    public function updateStatus(Request $request, Section $section)
    {
        $section->update(['status' => $request->status]);
        return back()->with('success', 'Section status updated!');
    }

    public function destroy(Section $section)
    {
        $section->delete(); // This will soft delete
        return back()->with('success', 'Section deleted!');
    }
}
