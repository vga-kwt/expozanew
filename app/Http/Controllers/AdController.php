<?php

namespace App\Http\Controllers;

use App\Models\Ad;
use App\Models\Product;
use App\Models\Vendor;
use App\Models\Expo;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\Log;
use Inertia\Inertia;
use Inertia\Response;

class AdController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index(Request $request): Response
    {
        $query = Ad::query()
            ->with(['product', 'vendor', 'expo']);

        // Search functionality
        if ($request->filled('search')) {
            $search = $request->get('search');
            $query->where(function ($q) use ($search) {
                $q->where('title_en', 'like', "%{$search}%")
                    ->orWhere('title_ar', 'like', "%{$search}%")
                    ->orWhere('description_en', 'like', "%{$search}%")
                    ->orWhere('description_ar', 'like', "%{$search}%")
                    ->orWhere('external_link', 'like', "%{$search}%")
                    // Linked Product
                    ->orWhere(function ($q2) use ($search) {
                        $q2->where('link_type', 'product')
                            ->whereHas('product', function ($q3) use ($search) {
                                $q3->where('name_en', 'like', "%$search%")
                                    ->orWhere('name_ar', 'like', "%$search%");
                            });
                    })
                    // Linked Vendor
                    ->orWhere(function ($q2) use ($search) {
                        $q2->where('link_type', 'vendor')
                            ->whereHas('vendor', function ($q3) use ($search) {
                                $q3->where('name', 'like', "%$search%");
                            });
                    })
                    // Linked Expo
                    ->orWhere(function ($q2) use ($search) {
                        $q2->where('link_type', 'expo')
                            ->whereHas('expo', function ($q3) use ($search) {
                                $q3->where('name_en', 'like', "%$search%")
                                    ->orWhere('name_ar', 'like', "%$search%");
                            });
                    });
            });
        }

        // Filter by status
        if ($request->filled('status') && $request->get('status') !== 'all') {
            $query->where('status', $request->get('status'));
        }

        // Filter by link type
        if ($request->filled('link_type') && $request->get('link_type') !== 'all') {
            $query->where('link_type', $request->get('link_type'));
        }

        // Filter by date range
        if ($request->filled('from_date')) {
            $query->where('start_date', '>=', $request->get('from_date'));
        }
        if ($request->filled('to_date')) {
            $query->where('end_date', '<=', $request->get('to_date'));
        }

        // Filter by linked item name
        if ($request->filled('linked_item')) {
            $name = $request->linked_item;
            $query->where(function ($q) use ($name) {
                $q->where(function ($q2) use ($name) {
                    $q2->where('link_type', 'product')
                        ->whereHas('product', function ($q3) use ($name) {
                            $q3->where('name_en', 'like', "%$name%")
                                ->orWhere('name_ar', 'like', "%$name%");
                        });
                })
                    ->orWhere(function ($q2) use ($name) {
                        $q2->where('link_type', 'vendor')
                            ->whereHas('vendor', function ($q3) use ($name) {
                                $q3->where('name', 'like', "%$name%");
                            });
                    })
                    ->orWhere(function ($q2) use ($name) {
                        $q2->where('link_type', 'expo')
                            ->whereHas('expo', function ($q3) use ($name) {
                                $q3->where('name_en', 'like', "%$name%")
                                    ->orWhere('name_ar', 'like', "%$name%");
                            });
                    });
            });
        }

        // Sort functionality
        $sortBy = $request->get('sort_by', 'created_at');
        $sortOrder = $request->get('sort_order', 'desc');

        if ($sortBy === 'priority') {
            $query->orderBy('priority', $sortOrder);
        } elseif ($sortBy === 'date_range') {
            $query->orderBy('start_date', $sortOrder);
        } else {
            $query->orderBy($sortBy, $sortOrder);
        }

        $ads = $query->paginate(10)->withQueryString();

        // Get options for link types
        $linkTypeOptions = [
            ['value' => 'product', 'label' => 'Product Page'],
            ['value' => 'vendor', 'label' => 'Vendor Profile'],
            ['value' => 'expo', 'label' => 'Expo View'],
            ['value' => 'external', 'label' => 'External Link'],
        ];

        $statusOptions = [
            ['value' => 'draft', 'label' => 'Draft'],
            ['value' => 'active', 'label' => 'Active'],
            ['value' => 'suspended', 'label' => 'Suspended'],
        ];

        // Provide products, vendors, expos for modal form with more details
        $products = Product::select('id', 'name_en', 'name_ar', 'description_en', 'description_ar', 'vendor_id', 'regular_price', 'sale_price')
            ->with('vendor:id,name')
            ->get()
            ->map(function ($product) {
                $vendorName = $product->vendor ? $product->vendor->name : 'N/A';
                $price = $product->sale_price ?? $product->regular_price ?? 'N/A';
                return [
                    'id' => $product->id,
                    'name_en' => $product->name_en,
                    'name_ar' => $product->name_ar,
                    'description_en' => $product->description_en,
                    'description_ar' => $product->description_ar,
                    'vendor_name' => $vendorName,
                    'price' => $price,
                    'display_text' => "{$product->name_en} - KD {$price} ({$vendorName})"
                ];
            });

        $vendors = Vendor::select('id', 'name', 'brand_name_en', 'email', 'mobile', 'kyc_status')
            ->get()
            ->map(function ($vendor) {
                return [
                    'id' => $vendor->id,
                    'name' => $vendor->name,
                    'brand_name_en' => $vendor->brand_name_en,
                    'name_en' => $vendor->brand_name_en ?? $vendor->name, // Fallback for existing frontend usage
                    'name_ar' => $vendor->name,
                    'email' => $vendor->email,
                    'mobile' => $vendor->mobile,
                    'kyc_status' => $vendor->kyc_status,
                    'display_text' => ($vendor->brand_name_en ?? $vendor->name) . " ({$vendor->email}) - {$vendor->kyc_status}"
                ];
            });

        $expos = Expo::select('id', 'name_en as title_en', 'name_ar as title_ar', 'description_en', 'description_ar', 'start_date', 'end_date')
            ->get()
            ->map(function ($expo) {
                return [
                    'id' => $expo->id,
                    'title_en' => $expo->title_en,
                    'title_ar' => $expo->title_ar,
                    'description_en' => $expo->description_en,
                    'description_ar' => $expo->description_ar,
                    'start_date' => $expo->start_date,
                    'end_date' => $expo->end_date,
                    'display_text' => "{$expo->title_en} ({$expo->start_date} - {$expo->end_date})"
                ];
            });

        return Inertia::render('Ads/Index', [
            'ads' => $ads,
            'filters' => $request->only(['search', 'status', 'link_type', 'sort_by', 'sort_order', 'from_date', 'to_date', 'linked_item']),
            'linkTypeOptions' => $linkTypeOptions,
            'statusOptions' => $statusOptions,
            'products' => $products,
            'expos' => $expos,
            'isAdmin' => true, // Admin users have full access
            'subscriptionInfo' => null, // Admin users don't need subscription info
        ]);
    }

    /**
     * Show the form for creating a new resource.
     */
    public function create(): Response
    {
        // Get options for linkable items with more details
        $products = Product::select('id', 'name_en', 'name_ar', 'description_en', 'description_ar', 'vendor_id', 'regular_price', 'sale_price')
            ->with('vendor:id,name')
            ->get()
            ->map(function ($product) {
                $vendorName = $product->vendor ? $product->vendor->name : 'N/A';
                $price = $product->sale_price ?? $product->regular_price ?? 'N/A';
                return [
                    'id' => $product->id,
                    'name_en' => $product->name_en,
                    'name_ar' => $product->name_ar,
                    'description_en' => $product->description_en,
                    'description_ar' => $product->description_ar,
                    'vendor_name' => $vendorName,
                    'price' => $price,
                    'display_text' => "{$product->name_en} - KD {$price} ({$vendorName})"
                ];
            });

        $vendors = Vendor::select('id', 'name', 'brand_name_en', 'email', 'mobile', 'kyc_status')
            ->get()
            ->map(function ($vendor) {
                return [
                    'id' => $vendor->id,
                    'name' => $vendor->name,
                    'brand_name_en' => $vendor->brand_name_en,
                    'name_en' => $vendor->brand_name_en ?? $vendor->name, // Fallback for existing frontend usage
                    'name_ar' => $vendor->name,
                    'email' => $vendor->email,
                    'mobile' => $vendor->mobile,
                    'kyc_status' => $vendor->kyc_status,
                    'display_text' => ($vendor->brand_name_en ?? $vendor->name) . " ({$vendor->email}) - {$vendor->kyc_status}"
                ];
            });

        $expos = Expo::select('id', 'name_en as title_en', 'name_ar as title_ar', 'description_en', 'description_ar', 'start_date', 'end_date')
            ->get()
            ->map(function ($expo) {
                return [
                    'id' => $expo->id,
                    'title_en' => $expo->title_en,
                    'title_ar' => $expo->title_ar,
                    'description_en' => $expo->description_en,
                    'description_ar' => $expo->description_ar,
                    'start_date' => $expo->start_date,
                    'end_date' => $expo->end_date,
                    'display_text' => "{$expo->title_en} ({$expo->start_date} - {$expo->end_date})"
                ];
            });

        $linkTypeOptions = [
            ['value' => 'product', 'label' => 'Product Page'],
            ['value' => 'vendor', 'label' => 'Vendor Profile'],
            ['value' => 'expo', 'label' => 'Expo View'],
            ['value' => 'external', 'label' => 'External Link'],
        ];

        return Inertia::render('Ads/Create', [
            'products' => $products,
            'vendors' => $vendors,
            'expos' => $expos,
            'linkTypeOptions' => $linkTypeOptions,
            'isAdmin' => true, // Admin users have full access
            'subscriptionInfo' => null, // Admin users don't need subscription info
        ]);
    }

    /**
     * Store a newly created resource in storage.
     */
    public function store(Request $request)
    {
        // dd($request->all());
        $validated = $request->validate([
            'vendor_id' => 'nullable|exists:vendors,id',
            'title_en' => 'required|string|max:255',
            'title_ar' => 'required|string|max:255',
            'description_en' => 'nullable|string',
            'description_ar' => 'nullable|string',
            'link_type' => 'required|in:product,vendor,expo,external',
            'link_id' => 'nullable|integer',
            'banners' => 'required|image|mimes:jpeg,png,jpg,gif|max:5120',
            'status' => 'required|in:active,suspended,draft',
            'external_link' => 'nullable|url|required_if:link_type,external',
            'priority' => 'required|integer|min:0|max:100',
            'start_date' => 'nullable|date:Y-m-d H:i|after:now',
            'end_date' => 'nullable|date:Y-m-d H:i|after:start_date',
        ]);

        $disk = config('filesystems.default', 's3');

        // Handle banner upload - store single image filename
        if ($request->hasFile('banners')) {
            $banner = $request->file('banners'); // Single file, not array
            $bannerPath = $banner->store('ads/banners', $disk);
            $validated['banners'] = $bannerPath;
        } else {
            $validated['banners'] = null;
        }

        // Clear link_id if link_type is external
        if ($validated['link_type'] === 'external') {
            $validated['link_id'] = null;
        }

        Ad::create($validated);

        return redirect()->route('ads.index')
            ->with('success', 'Ad created successfully.');
    }

    /**
     * Display the specified resource.
     */
    public function show(Ad $ad): Response
    {
        $ad->load(['product', 'vendor', 'expo']);

        return Inertia::render('Ads/Show', [
            'ad' => $ad,
        ]);
    }

    /**
     * Show the form for editing the specified resource.
     */
    public function edit(Ad $ad): Response
    {
        $ad->load(['product', 'vendor', 'expo']);

        // Get options for linkable items with more details
        $products = Product::select('id', 'name_en', 'name_ar', 'description_en', 'description_ar', 'vendor_id', 'regular_price', 'sale_price')
            ->with('vendor:id,name')
            ->get()
            ->map(function ($product) {
                $vendorName = $product->vendor ? $product->vendor->name : 'N/A';
                $price = $product->sale_price ?? $product->regular_price ?? 'N/A';
                return [
                    'id' => $product->id,
                    'name_en' => $product->name_en,
                    'name_ar' => $product->name_ar,
                    'description_en' => $product->description_en,
                    'description_ar' => $product->description_ar,
                    'vendor_name' => $vendorName,
                    'price' => $price,
                    'display_text' => "{$product->name_en} - KD {$price} ({$vendorName})"
                ];
            });

        $vendors = Vendor::select('id', 'name', 'brand_name_en', 'email', 'mobile', 'kyc_status')
            ->get()
            ->map(function ($vendor) {
                return [
                    'id' => $vendor->id,
                    'name' => $vendor->name,
                    'brand_name_en' => $vendor->brand_name_en,
                    'name_en' => $vendor->brand_name_en ?? $vendor->name, // Fallback for existing frontend usage
                    'name_ar' => $vendor->name,
                    'email' => $vendor->email,
                    'mobile' => $vendor->mobile,
                    'kyc_status' => $vendor->kyc_status,
                    'display_text' => ($vendor->brand_name_en ?? $vendor->name) . " ({$vendor->email}) - {$vendor->kyc_status}"
                ];
            });

        $expos = Expo::select('id', 'name_en as title_en', 'name_ar as title_ar', 'description_en', 'description_ar', 'start_date', 'end_date')
            ->get()
            ->map(function ($expo) {
                return [
                    'id' => $expo->id,
                    'title_en' => $expo->title_en,
                    'title_ar' => $expo->title_ar,
                    'description_en' => $expo->description_en,
                    'description_ar' => $expo->description_ar,
                    'start_date' => $expo->start_date,
                    'end_date' => $expo->end_date,
                    'display_text' => "{$expo->title_en} ({$expo->start_date} - {$expo->end_date})"
                ];
            });

        $linkTypeOptions = [
            ['value' => 'product', 'label' => 'Product Page'],
            ['value' => 'vendor', 'label' => 'Vendor Profile'],
            ['value' => 'expo', 'label' => 'Expo View'],
            ['value' => 'external', 'label' => 'External Link'],
        ];

        return Inertia::render('Ads/Edit', [
            'ad' => $ad,
            'products' => $products,
            'vendors' => $vendors,
            'expos' => $expos,
            'linkTypeOptions' => $linkTypeOptions,
        ]);
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(Request $request, Ad $ad)
    {
        $validated = $request->validate([
            'vendor_id' => 'nullable|exists:vendors,id',
            'title_en' => 'required|string|max:255',
            'title_ar' => 'required|string|max:255',
            'description_en' => 'nullable|string',
            'description_ar' => 'nullable|string',
            'link_type' => 'required|in:product,vendor,expo,external',
            'link_id' => 'nullable|integer',
            'banners' => 'nullable|image|mimes:jpeg,png,jpg,gif|max:5120',
            'status' => 'required|in:active,suspended,draft',
            'external_link' => 'nullable|url|required_if:link_type,external',
            'priority' => 'required|integer|min:0|max:100',
            'start_date' => 'nullable',
            'end_date' => 'nullable',
        ]);

        // Handle banner upload - replace old image with new one
        if ($request->hasFile('banners')) {

            $disk = config('filesystems.default', 's3');

            // Delete old banner if exists
            if ($ad->banners) {
                Storage::disk($disk)->delete($ad->banners);
            }

            // Store new banner
            $banner = $request->file('banners'); // Single file, not array
            $newBannerPath = $banner->store('ads/banners', $disk);
            $validated['banners'] = $newBannerPath;
            Log::info('New banner stored', ['new_banner' => $newBannerPath]);
        } else {
            // Keep existing banner
            $validated['banners'] = $ad->banners;
            Log::info('No new banner uploaded, keeping existing', ['existing_banner' => $ad->banners]);
        }

        // Clear link_id if link_type is external
        if ($validated['link_type'] === 'external') {
            $validated['link_id'] = null;
        }

        $ad->update($validated);
        Log::info('Ad updated successfully', ['ad_id' => $ad->id, 'banners' => $validated['banners']]);

        return redirect()->route('ads.index')
            ->with('success', 'Ad updated successfully.');
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(Ad $ad)
    {
        $disk = config('filesystems.default', 's3');

        // Delete banner image
        if ($ad->banners) {
            Storage::disk($disk)->delete($ad->banners);
        }

        $ad->delete(); // This will now use soft delete since we added SoftDeletes trait

        return redirect()->route('ads.index')
            ->with('success', 'Ad deleted successfully.');
    }

    /**
     * Toggle ad status
     */
    public function toggleStatus(Ad $ad)
    {
        $newStatus = $ad->status === 'active' ? 'suspended' : 'active';
        $ad->update(['status' => $newStatus]);

        return redirect()->route('ads.index')
            ->with('success', "Ad status updated to {$newStatus}.");
    }

    /**
     * Export ads to CSV with filters
     */
    public function export(Request $request)
    {
        try {
            $query = Ad::query()
                ->with(['product', 'vendor', 'expo']);

            // Apply the same filters as the index method
            if ($request->filled('search')) {
                $search = $request->get('search');
                $query->where(function ($q) use ($search) {
                    $q->where('title_en', 'like', "%{$search}%")
                        ->orWhere('title_ar', 'like', "%{$search}%")
                        ->orWhere('description_en', 'like', "%{$search}%")
                        ->orWhere('description_ar', 'like', "%{$search}%")
                        ->orWhere('external_link', 'like', "%{$search}%")
                        // Linked Product
                        ->orWhere(function ($q2) use ($search) {
                            $q2->where('link_type', 'product')
                                ->whereHas('product', function ($q3) use ($search) {
                                    $q3->where('name_en', 'like', "%$search%")
                                        ->orWhere('name_ar', 'like', "%$search%");
                                });
                        })
                        // Linked Vendor
                        ->orWhere(function ($q2) use ($search) {
                            $q2->where('link_type', 'vendor')
                                ->whereHas('vendor', function ($q3) use ($search) {
                                    $q3->where('name', 'like', "%$search%");
                                });
                        })
                        // Linked Expo
                        ->orWhere(function ($q2) use ($search) {
                            $q2->where('link_type', 'expo')
                                ->whereHas('expo', function ($q3) use ($search) {
                                    $q3->where('name_en', 'like', "%$search%")
                                        ->orWhere('name_ar', 'like', "%$search%");
                                });
                        });
                });
            }

            // Filter by status
            if ($request->filled('status') && $request->get('status') !== 'all') {
                $query->where('status', $request->get('status'));
            }

            // Filter by link type
            if ($request->filled('link_type') && $request->get('link_type') !== 'all') {
                $query->where('link_type', $request->get('link_type'));
            }

            // Filter by date range
            if ($request->filled('from_date')) {
                $query->where('start_date', '>=', $request->get('from_date'));
            }
            if ($request->filled('to_date')) {
                $query->where('end_date', '<=', $request->get('to_date'));
            }

            // Filter by linked item name
            if ($request->filled('linked_item')) {
                $name = $request->linked_item;
                $query->where(function ($q) use ($name) {
                    $q->where(function ($q2) use ($name) {
                        $q2->where('link_type', 'product')
                            ->whereHas('product', function ($q3) use ($name) {
                                $q3->where('name_en', 'like', "%$name%")
                                    ->orWhere('name_ar', 'like', "%$name%");
                            });
                    })
                        ->orWhere(function ($q2) use ($name) {
                            $q2->where('link_type', 'vendor')
                                ->whereHas('vendor', function ($q3) use ($name) {
                                    $q3->where('name', 'like', "%$name%");
                                });
                        })
                        ->orWhere(function ($q2) use ($name) {
                            $q2->where('link_type', 'expo')
                                ->whereHas('expo', function ($q3) use ($name) {
                                    $q3->where('name_en', 'like', "%$name%")
                                        ->orWhere('name_ar', 'like', "%$name%");
                                });
                        });
                });
            }

            // Sort functionality
            $sortBy = $request->get('sort_by', 'created_at');
            $sortOrder = $request->get('sort_order', 'desc');

            if ($sortBy === 'priority') {
                $query->orderBy('priority', $sortOrder);
            } elseif ($sortBy === 'date_range') {
                $query->orderBy('start_date', $sortOrder);
            } else {
                $query->orderBy($sortBy, $sortOrder);
            }

            $ads = $query->get();

            $filename = 'ads_export_' . date('Y-m-d_H-i-s') . '.csv';

            $headers = [
                'Content-Type' => 'text/csv; charset=UTF-8',
                'Content-Disposition' => 'attachment; filename="' . $filename . '"',
                'Cache-Control' => 'no-cache, must-revalidate',
                'Pragma' => 'no-cache',
            ];

            $callback = function () use ($ads) {
                $file = fopen('php://output', 'w');

                // Add BOM for UTF-8
                fprintf($file, chr(0xEF) . chr(0xBB) . chr(0xBF));

                // CSV Headers
                fputcsv($file, [
                    '#', // Serial number
                    'ID',
                    'Title (English)',
                    'Title (Arabic)',
                    'Description (English)',
                    'Description (Arabic)',
                    'Link Type',
                    'Linked Item',
                    'External Link',
                    'Status',
                    'Priority',
                    'Start Date',
                    'End Date',
                    'Created At',
                    'Updated At'
                ]);

                // CSV Data
                $i = 1;
                foreach ($ads as $ad) {
                    $linkedItem = '';
                    if ($ad->link_type === 'external') {
                        $linkedItem = $ad->external_link;
                    } else {
                        $item = $ad->product ?? $ad->vendor ?? $ad->expo;
                        if ($item) {
                            if (property_exists($item, 'name_en')) {
                                $linkedItem = $item->name_en . ' (' . $item->name_ar . ')';
                            } else {
                                $linkedItem = $item->title_en . ' (' . $item->title_ar . ')';
                            }
                        }
                    }

                    fputcsv($file, [
                        $i++,
                        $ad->id,
                        $ad->title_en,
                        $ad->title_ar,
                        $ad->description_en,
                        $ad->description_ar,
                        $ad->link_type,
                        $linkedItem,
                        $ad->external_link,
                        $ad->status,
                        $ad->priority,
                        $ad->start_date,
                        $ad->end_date,
                        $ad->created_at,
                        $ad->updated_at
                    ]);
                }

                fclose($file);
            };

            return response()->stream($callback, 200, $headers);
        } catch (\Exception $e) {
            Log::error('Ads export failed', [
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString(),
                'filters' => $request->all()
            ]);

            return response()->json([
                'error' => 'Export failed. Please try again.',
                'message' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Get the appropriate table name for link validation
     */
    private function getLinkTable(?string $linkType): string
    {
        return match ($linkType) {
            'product' => 'products',
            'vendor' => 'vendors',
            'expo' => 'expos',
            default => 'products', // fallback
        };
    }
}