<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Api\Controller;
use App\Models\Product;
use App\Models\Category;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\Storage;
use App\Models\Expo;
use App\Models\ExpoVendor;
use App\Models\ExpoProduct;
use App\Models\Wishlist;
/**
 * @OA\Schema(
 *   schema="Product",
 *   type="object",
 *   @OA\Property(property="id", type="integer"),
 *   @OA\Property(property="vendor_id", type="integer"),
 *   @OA\Property(property="category_id", type="integer"),
 *   @OA\Property(property="name_en", type="string"),
 *   @OA\Property(property="name_ar", type="string"),
 *   @OA\Property(property="description_en", type="string"),
 *   @OA\Property(property="description_ar", type="string"),
 *   @OA\Property(property="price", type="number", format="float"),
 *   @OA\Property(property="discount_price", type="number", format="float"),
 *   @OA\Property(property="images", type="array", @OA\Items(type="string")),
 *   @OA\Property(property="status", type="string", enum={"active", "inactive", "out_of_stock"}),
 *   @OA\Property(property="created_at", type="string", format="date-time"),
 *   @OA\Property(property="updated_at", type="string", format="date-time"),
 *   @OA\Property(property="category", type="object"),
 *   @OA\Property(property="vendor", type="object")
 * )
 */

class ProductController extends Controller
{
    /**
     * Admin: List all products
     */
    public function index(Request $request)
    {
        $products = Product::with(['vendor.user', 'category'])
            ->where('deleted_at', null)
            ->when($request->search, function ($query, $search) {
                $query->where('name_en', 'like', "%{$search}%")
                    ->orWhere('name_ar', 'like', "%{$search}%");
            })
            ->when($request->category_id, function ($query, $categoryId) {
                $query->where('category_id', $categoryId);
            })
            ->when($request->vendor_id, function ($query, $vendorId) {
                $query->where('vendor_id', $vendorId);
            })
            ->when($request->status, function ($query, $status) {
                $query->where('status', $status);
            })
            ->latest()
            ->paginate(10);

        return $this->successResponse($products);
    }

    /**
     * Admin: Show product details
     */
    public function show($id)
    {
        $product = Product::with(['vendor.user', 'category'])->where('deleted_at', null)->findOrFail($id);
        return $this->successResponse($product);
    }

    /**
     * Admin: Create product
     */
    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'name_en' => 'required|string|max:255',
            'name_ar' => 'required|string|max:255',
            'description_en' => 'nullable|string',
            'description_ar' => 'nullable|string',
            'price' => 'required|numeric|min:0',
            'category_id' => 'required|exists:categories,id',
            'vendor_id' => 'required|exists:vendors,id',
            'images' => 'nullable|array',
            'images.*' => 'image|mimes:jpeg,png,jpg,gif,svg|max:2048',
            'status' => 'required|in:active,suspended',
        ]);

        if ($validator->fails()) {
            return $this->validationErrorResponse($validator->errors());
        }

        $data = $validator->validated();

        // Handle image uploads
        if ($request->hasFile('images')) {
            $imagePaths = [];
            foreach ($request->file('images') as $image) {
                $imagePaths[] = $image->store('products', config('filesystems.default', 's3'));
            }
            $data['images'] = json_encode($imagePaths);
        }

        $product = Product::create($data);

        return $this->successResponse($product->load(['vendor.user', 'category']), 'Product created successfully', 201);
    }

    /**
     * Admin: Update product
     */
    public function update(Request $request, $id)
    {
        $product = Product::findOrFail($id);

        $validator = Validator::make($request->all(), [
            'name_en' => 'required|string|max:255',
            'name_ar' => 'required|string|max:255',
            'description_en' => 'nullable|string',
            'description_ar' => 'nullable|string',
            'price' => 'required|numeric|min:0',
            'category_id' => 'required|exists:categories,id',
            'vendor_id' => 'required|exists:vendors,id',
            'images' => 'nullable|array',
            'images.*' => 'image|mimes:jpeg,png,jpg,gif,svg|max:2048',
            'status' => 'required|in:active,suspended',
        ]);

        if ($validator->fails()) {
            return $this->validationErrorResponse($validator->errors());
        }

        $data = $validator->validated();

        // Handle image uploads
        if ($request->hasFile('images')) {
            // Delete old images
            if ($product->images) {
                $oldImages = json_decode($product->images, true);
                foreach ($oldImages as $oldImage) {
                    Storage::disk(config('filesystems.default', 's3'))->delete($oldImage);
                }
            }

            $imagePaths = [];
            foreach ($request->file('images') as $image) {
                $imagePaths[] = $image->store('products', config('filesystems.default', 's3'));
            }
            $data['images'] = json_encode($imagePaths);
        }

        $product->update($data);

        return $this->successResponse($product->load(['vendor.user', 'category']), 'Product updated successfully');
    }

    /**
     * Admin: Delete product
     */
    public function destroy($id)
    {
        $product = Product::findOrFail($id);

        // Delete images
        if ($product->images) {
            $images = json_decode($product->images, true);
            foreach ($images as $image) {
                Storage::disk(config('filesystems.default', 's3'))->delete($image);
            }
        }

        $product->delete();

        return $this->successResponse(null, 'Product deleted successfully');
    }

    /**
     * Admin: Suspend product
     */
    public function suspend($id)
    {
        $product = Product::findOrFail($id);
        $product->update(['status' => 'suspended']);

        return $this->successResponse(null, 'Product suspended successfully');
    }

    /**
     * Vendor: List own products
     */
    public function vendorIndex(Request $request)
    {
        $user = $request->user();
        $vendor = $user->vendor;

        if (!$vendor) {
            return $this->forbiddenResponse('User is not a vendor');
        }

        $products = Product::with(['category'])
            ->where('deleted_at', null)
            ->where('vendor_id', $vendor->id)
            ->when($request->search, function ($query, $search) {
                $query->where(function ($q) use ($search) {
                    $q->where('name_en', 'like', "%{$search}%")
                      ->orWhere('name_ar', 'like', "%{$search}%");
                });
            })
            ->when($request->category_id, function ($query, $categoryId) {
                $query->where('category_id', $categoryId);
            })
            ->when($request->status, function ($query, $status) {
                $query->where('status', $status);
            })
            ->latest()
            ->paginate(10);

        return $this->successResponse($products);
    }

    /**
     * Vendor: Show own product
     */
    public function vendorShow($id, Request $request)
    {
        $user = $request->user();
        $vendor = $user->vendor;

        if (!$vendor) {
            return $this->forbiddenResponse('User is not a vendor');
        }

        $product = Product::with(['category'])
            ->where('vendor_id', $vendor->id)
            ->where('deleted_at', null)
            ->findOrFail($id);

        return $this->successResponse($product);
    }

    /**
     * Vendor: Create product
     */
    public function vendorStore(Request $request)
    {
        $user = $request->user();
        $vendor = $user->vendor;

        if (!$vendor) {
            return $this->forbiddenResponse('User is not a vendor');
        }

        $validator = Validator::make($request->all(), [
            'name_en' => 'required|string|max:255',
            'name_ar' => 'required|string|max:255',
            'description_en' => 'nullable|string',
            'description_ar' => 'nullable|string',
            'price' => 'required|numeric|min:0',
            'category_id' => 'required|exists:categories,id',
            'images' => 'nullable|array',
            'images.*' => 'image|mimes:jpeg,png,jpg,gif,svg|max:2048',
            'status' => 'required|in:active,suspended',
        ]);

        if ($validator->fails()) {
            return $this->validationErrorResponse($validator->errors());
        }

        $data = $validator->validated();
        $data['vendor_id'] = $vendor->id;

        // Handle image uploads
        if ($request->hasFile('images')) {
            $imagePaths = [];
            foreach ($request->file('images') as $image) {
                $imagePaths[] = $image->store('products', config('filesystems.default', 's3'));
            }
            $data['images'] = json_encode($imagePaths);
        }

        $product = Product::create($data);

        return $this->successResponse($product->load(['category']), 'Product created successfully', 201);
    }

    /**
     * Vendor: Update own product
     */
    public function vendorUpdate(Request $request, $id)
    {
        $user = $request->user();
        $vendor = $user->vendor;

        if (!$vendor) {
            return $this->forbiddenResponse('User is not a vendor');
        }

        $product = Product::where('vendor_id', $vendor->id)->findOrFail($id);

        $validator = Validator::make($request->all(), [
            'name_en' => 'required|string|max:255',
            'name_ar' => 'required|string|max:255',
            'description_en' => 'nullable|string',
            'description_ar' => 'nullable|string',
            'price' => 'required|numeric|min:0',
            'category_id' => 'required|exists:categories,id',
            'images' => 'nullable|array',
            'images.*' => 'image|mimes:jpeg,png,jpg,gif,svg|max:2048',
            'status' => 'required|in:active,suspended',
        ]);

        if ($validator->fails()) {
            return $this->validationErrorResponse($validator->errors());
        }

        $data = $validator->validated();

        // Handle image uploads
        if ($request->hasFile('images')) {
            // Delete old images
            if ($product->images) {
                $oldImages = json_decode($product->images, true);
                foreach ($oldImages as $oldImage) {
                    Storage::disk(config('filesystems.default', 's3'))->delete($oldImage);
                }
            }

            $imagePaths = [];
            foreach ($request->file('images') as $image) {
                $imagePaths[] = $image->store('products', config('filesystems.default', 's3'));
            }
            $data['images'] = json_encode($imagePaths);
        }

        $product->update($data);

        return $this->successResponse($product->load(['category']), 'Product updated successfully');
    }

    /**
     * Vendor: Delete own product
     */
    public function vendorDestroy($id, Request $request)
    {
        $user = $request->user();
        $vendor = $user->vendor;

        if (!$vendor) {
            return $this->forbiddenResponse('User is not a vendor');
        }

        $product = Product::where('vendor_id', $vendor->id)->findOrFail($id);

        // Delete images
        if ($product->images) {
            $images = json_decode($product->images, true);
            foreach ($images as $image) {
                Storage::disk(config('filesystems.default', 's3'))->delete($image);
            }
        }

        $product->delete();

        return $this->successResponse(null, 'Product deleted successfully');
    }

    /**
     * @OA\Post(
     *     path="/api/expo-products/{expoId}/{vendorId}",
     *     summary="Get expo products with filters (POST)",
     *     tags={"Products"},
     *     @OA\Parameter(
     *         name="expoId",
     *         in="path",
     *         required=true,
     *         @OA\Schema(type="integer")
     *     ),
     *     @OA\Parameter(
     *         name="vendorId",
     *         in="path",
     *         required=true,
     *         @OA\Schema(type="integer")
     *     ),
     *     @OA\RequestBody(
     *         required=false,
     *         @OA\JsonContent(
     *             @OA\Property(property="category_id", type="integer"),
     *             @OA\Property(property="min_price", type="number"),
     *             @OA\Property(property="max_price", type="number"),
     *             @OA\Property(property="search", type="string"),
     *             @OA\Property(property="sort_by", type="string", enum={"price_low", "price_high", "name", "newest"}),
     *             @OA\Property(property="page", type="integer"),
     *             @OA\Property(property="per_page", type="integer")
     *         )
     *     ),
     *     @OA\Response(
     *         response=200,
     *         description="List of expo products",
     *         @OA\JsonContent(
     *             type="object",
     *             @OA\Property(property="success", type="boolean"),
     *             @OA\Property(property="data", type="object",
     *                 @OA\Property(property="items", type="array", @OA\Items(ref="#/components/schemas/Product")),
     *                 @OA\Property(property="pagination", type="object",
     *                     @OA\Property(property="total", type="integer"),
     *                     @OA\Property(property="per_page", type="integer"),
     *                     @OA\Property(property="current_page", type="integer"),
     *                     @OA\Property(property="last_page", type="integer"),
     *                     @OA\Property(property="from", type="integer"),
     *                     @OA\Property(property="to", type="integer")
     *                 )
     *             ),
     *             @OA\Property(property="message", type="string")
     *         )
     *     )
     * )
     */
    public function expoProducts(Request $request, $expoId, $vendorId)
    {
        $perPage = $request->input('per_page', 12);

        $expoVendor = ExpoVendor::where('expo_id', $expoId)->where('vendor_id', $vendorId)->where('deleted_at', null)->first();
        if (!$expoVendor) {
            return $this->forbiddenResponse('User is not a vendor');
        }
        $query = ExpoProduct::with(['product', 'product.category', 'product.vendor'])
        ->where('expo_products.vendor_id', $vendorId)
        ->where('expo_products.expo_id', $expoId);

            if ($request->filled('category_id')) {
                $query->whereHas('product', function ($q) use ($request) {
                    $q->where('category_id', $request->category_id);
                });
            }
            
            if ($request->filled('min_price')) {
                $query->whereHas('product', function ($q) use ($request) {
                    $q->where('sale_price', '>=', $request->min_price);
                });
            }
            
            if ($request->filled('max_price')) {
                $query->whereHas('product', function ($q) use ($request) {
                    $q->where('sale_price', '<=', $request->max_price);
                });
            }
            
            if ($request->filled('search')) {
                $query->whereHas('product', function ($q) use ($request) {
                    $q->where('name_en', 'like', '%' . $request->search . '%')
                      ->orWhere('name_ar', 'like', '%' . $request->search . '%');
                });
            }
            
            if ($request->filled('sort_by') && in_array(strtolower($request->sort_by), ['asc', 'desc'])) {
                // Join the product table if sorting by product.name
                $query->join('products', 'expo_products.product_id', '=', 'products.id')
                      ->orderBy('products.name_en', strtolower($request->sort_by))
                      ->select('expo_products.*'); // Required to avoid column conflict issues
            }
            
        
        if ($request->filled('page')) {
            $query->paginate($perPage);
        }

        $products = $query->paginate($perPage);
        
        return response()->json([
            'success' => true,
            'data' =>$products->items(),
            'pagination' => [
                    'total' => $products->total(),
                    'per_page' => $products->perPage(),
                    'current_page' => $products->currentPage(),
                    'last_page' => $products->lastPage(),
                    'from' => $products->firstItem(),
                    'to' => $products->lastItem()
                ],
            'message' => 'Products fetched successfully'
        ]);
    }

    /**
     * Get similar products by category (excluding current product)
     * @OA\Get(
     *     path="/api/products/{productId}/similar",
     *     summary="Get similar products",
     *     tags={"Products"},
     *     @OA\Parameter(
     *         name="productId",
     *         in="path",
     *         required=true,
     *         @OA\Schema(type="integer")
     *     ),
     *     @OA\Response(
     *         response=200,
     *         description="List of similar products",
     *         @OA\JsonContent(
     *             type="object",
     *             @OA\Property(property="success", type="boolean"),
     *             @OA\Property(property="data", type="array", @OA\Items(ref="#/components/schemas/Product")),
     *             @OA\Property(property="message", type="string")
     *         )
     *     )
     * )
     */
    public function similarProducts($productId)
    {
        $product = Product::with(['vendor', 'category'])
            ->whereNull('deleted_at')
            ->findOrFail($productId);

        $activeExpoIds = Expo::where('status', 'active')->pluck('id');
        $productIdsInActiveExpos = ExpoProduct::whereIn('expo_id', $activeExpoIds)->pluck('product_id')->unique()->values();

        $similar = Product::with(['vendor', 'category'])
            ->where('category_id', $product->category_id)
            ->where('id', '!=', $productId)
            ->where('status', 'active')
            ->whereNull('deleted_at')
            ->whereIn('id', $productIdsInActiveExpos)
            ->latest()
            ->limit(6)
            ->get();

        return response()->json([
            'success' => true,
            'message' => 'Similar products fetched successfully',
            'data' => $similar
        ]);
    }

    public function expoProductsList($expoId)
    {
        $expo = Expo::find($expoId);
        if (!$expo || $expo->status !== 'active') {
            return response()->json([
                'success' => true,
                'message' => 'Expo products fetched successfully',
                'data' => [],
            ]);
        }

        $expoProducts = ExpoProduct::with(['product', 'product.category', 'product.vendor'])
            ->where('expo_id', $expoId)
            ->whereNull('deleted_at')
            ->orderByDesc('created_at')
            ->take(6)
            ->get();

        // Transformation is handled automatically in Product model's toArray() method
        $transformedData = $expoProducts->map(function ($expoProduct) {
            return $expoProduct->toArray();
        });

        return response()->json([
            'success' => true,
            'message' => 'Expo products fetched successfully',
            'data' => $transformedData
        ]);
    }

    /**
     * Public: Get product details for API.
     * Returns 404 if the product is not part of any active expo.
     */
    public function details($productId)
    {
        $product = Product::with(['vendor.user', 'category', 'reviews.user'])
            ->where('id', $productId)
            ->whereNull('deleted_at')
            ->first();

        if (!$product) {
            return $this->errorResponse('Product not found', 404);
        }

        $activeExpoIds = Expo::where('status', 'active')->pluck('id');
        $isInActiveExpo = ExpoProduct::where('product_id', $product->id)->whereIn('expo_id', $activeExpoIds)->exists();
        if (!$isInActiveExpo) {
            return $this->errorResponse('Product not found', 404);
        }

        // Get product data - transformation is handled automatically in Product model's toArray()
        $productArray = $product->toArray();
        
        // Return only public information
        $productData = [
            'id' => $productArray['id'],
            'name_en' => $productArray['name_en'],
            'name_ar' => $productArray['name_ar'],
            'description_en' => $productArray['description_en'],
            'description_ar' => $productArray['description_ar'],
            'regular_price' => $productArray['regular_price'],
            'sale_price' => $productArray['sale_price'],
            'stock' => $productArray['stock'],
            'views' => $productArray['views'],
            'image_url' => $productArray['image_url'], // Already transformed by model
            'gallery' => $productArray['gallery'], // Already transformed by model
            'attributes' => $productArray['attributes'],
            'status' => $productArray['status'],
            'created_at' => $productArray['created_at'],
            'updated_at' => $productArray['updated_at'],
            'category' => $product->category ? [
                'id' => $product->category->id,
                'name_en' => $product->category->name_en,
                'name_ar' => $product->category->name_ar,
            ] : null,
            'vendor' => $product->vendor ? [
                'id' => $product->vendor->id,
                'company_name' => $product->vendor->company_name,
                'name' => $product->vendor->name,
                'logo' => $product->vendor->logo ? asset('storage/' . $product->vendor->logo) : null,
                'user' => [
                    'id' => $product->vendor->user->id,
                    'name' => $product->vendor->user->name,
                    'email' => $product->vendor->user->email,
                ],
            ] : null,
            'reviews' => $product->reviews->map(function ($review) {
                return [
                    'id' => $review->id,
                    'rating' => $review->rating,
                    'comment' => $review->comment,
                    'created_at' => $review->created_at,
                    'user' => [
                        'id' => $review->user->id,
                        'name' => $review->user->name,
                    ],
                ];
            }),
            'average_rating' => $product->reviews->avg('rating'),
            'total_reviews' => $product->reviews->count(),
        ];

        return $this->successResponse($productData);
    }
}
