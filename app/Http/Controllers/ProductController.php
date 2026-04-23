<?php

namespace App\Http\Controllers;

use App\Models\Product;
use App\Services\ProductService;
use App\Http\Requests\Product\StoreProductRequest;
use App\Http\Requests\Product\UpdateProductRequest;
use Illuminate\Http\Request;
use Inertia\Inertia;

class ProductController extends Controller
{
    protected ProductService $productService;

    public function __construct(ProductService $productService)
    {
        $this->productService = $productService;
    }

    public function index(Request $request)
    {
        $products = $this->productService->getProducts($request);
        $formData = $this->productService->getFormData();
        $filterData = $this->productService->getFiltersData($request);

        return Inertia::render('Products/Index', [
            'products' => $products,
            'categories' => $formData['categories'],
            'vendors' => $formData['vendors'],
            'expos' => $formData['expos'],
            'filters' => $filterData['filters'],
            'hasActiveFilters' => $filterData['has_active_filters'],
            'activeFilterCount' => $filterData['active_filter_count'],
        ]);
    }

    public function show(Product $product)
    {
        $productData = $this->productService->getProductForShow($product);
        return response()->json($productData);
    }

    public function store(StoreProductRequest $request)
    {
        $validated = $request->validated();
        $user = $request->user();
        if ($user && method_exists($user, 'vendor') && $user->vendor) {
            $validated['vendor_id'] = $user->vendor->id;
        }

        $this->productService->createProduct($validated);

        if ($user && method_exists($user, 'vendor') && $user->vendor) {
            return redirect()->route('vendor.products.index')->with('success', 'Product created!');
        } else {
            return redirect()->route('products.index')->with('success', 'Product created!');
        }
    }

    public function edit(Product $product)
    {
        $productData = $this->productService->getProductForEdit($product);
        $formData = $this->productService->getFormData();

        return Inertia::render('Products/Edit', [
            'product' => $productData,
            'categories' => $formData['categories'],
            'vendors' => $formData['vendors'],
            'expos' => $formData['expos'],
            'sections' => $formData['sections'],
        ]);
    }

    public function update(UpdateProductRequest $request, Product $product)
    {
        $validated = $request->validated();
        $user = $request->user();
        $this->productService->updateProduct($product, $validated);
        if ($user && method_exists($user, 'vendor') && $user->vendor) {
            return redirect()->route('vendor.products.index')->with('success', 'Product updated successfully!');
        } else {
            return redirect()->route('products.index')->with('success', 'Product updated successfully!');
        }
    }

    public function suspend(Product $product)
    {
        $oldStatus = $product->status;
        $this->productService->suspendProduct($product);

        $action = $oldStatus === 'active' ? 'suspended' : 'activated';
        $message = "Product {$action} successfully!";

        return redirect()->back()->with('success', $message);
    }

    public function destroy(Product $product, Request $request)
    {
        $user = $request->user();
        $this->productService->deleteProduct($product);
        if ($user && method_exists($user, 'vendor') && $user->vendor) {
            return redirect()->route('vendor.products.index')->with('success', 'Product deleted successfully!');
        } else {
            return redirect()->route('products.index')->with('success', 'Product deleted!');
        }
    }

    public function vendorIndex(Request $request)
    {
        $user = $request->user();
        
        // Ensure user is authenticated
        if (!$user) {
            return redirect()->route('vendor.login')->with('error', 'Please login to continue.');
        }
        
        // Load vendor relationship explicitly to ensure it's available
        $vendor = $user->vendor;
        
        if (!$vendor) {
            return redirect()->route('vendor.login')->with('error', 'Vendor profile not found. Please contact support.');
        }

        // Ensure vendor ID is valid
        if (!$vendor->id) {
            return redirect()->route('vendor.login')->with('error', 'Invalid vendor profile.');
        }

        $products = $this->productService->getVendorProducts($request, $vendor);
        $formData = $this->productService->getFormData();
        $filterData = $this->productService->getFiltersData($request);

        return Inertia::render('Products/VendorIndex', [
            'products' => $products,
            'categories' => $formData['categories'],
            'expos' => $formData['expos'],
            'filters' => $filterData['filters'],
            'hasActiveFilters' => $filterData['has_active_filters'],
            'activeFilterCount' => $filterData['active_filter_count'],
        ]);
    }

    public function create()
    {
        $formData = $this->productService->getFormData();

        return Inertia::render('Products/Create', [
            'categories' => $formData['categories'],
            'vendors' => $formData['vendors'],
            'expos' => $formData['expos'],
            'sections' => $formData['sections'],
        ]);
    }

    /**
     * Get products with lazy loading for infinite scroll
     */
    public function lazyLoad(Request $request)
    {
        $result = $this->productService->getProductsLazyLoad($request);

        return response()->json($result);
    }

    /**
     * Get products with chunked loading for very large datasets
     */
    public function chunked(Request $request)
    {
        $products = $this->productService->getProductsChunked($request);
        $formData = $this->productService->getFormData();
        $filters = $this->productService->getFiltersData($request);

        return Inertia::render('Products/ChunkedIndex', [
            'products' => $products,
            'categories' => $formData['categories'],
            'vendors' => $formData['vendors'],
            'expos' => $formData['expos'],
            'filters' => $filters,
        ]);
    }



    /**
     * Get performance statistics
     */
    public function performanceStats(Request $request)
    {
        $stats = $this->productService->getProductsPerformanceStats($request);

        return response()->json($stats);
    }
}
