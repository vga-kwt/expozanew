<?php

namespace App\Http\Requests\Product;

use Illuminate\Foundation\Http\FormRequest;

class UpdateProductRequest extends FormRequest
{
    /**
     * Determine if the user is authorized to make this request.
     */
    public function authorize(): bool
    {
        return true;
    }

    /**
     * Get the validation rules that apply to the request.
     */
    public function rules(): array
    {
        return [
            'name_en' => 'required|string|max:255',
            'name_ar' => 'required|string|max:255',
            'description_en' => 'nullable|string',
            'description_ar' => 'nullable|string',
            // 'regular_price' => 'nullable|numeric|min:0',
            // 'sale_price' => 'nullable|numeric|min:0',
            'stock' => 'nullable|integer|min:0',
            'views' => 'nullable|integer|min:0',
            'attributes' => 'nullable|json', // Stores variants: [{size, color, price, sale_price, stock}]
            'image_url' => 'nullable', // Allow both file uploads and string values
            'gallery' => 'nullable|array|min:1|max:5',
            'gallery.*' => 'file|mimes:jpeg,png,jpg|max:3072',
            'category_id' => 'required|exists:categories,id',
            'vendor_id' => 'nullable|exists:vendors,id',
            'removed_images' => 'nullable|array',
            'removed_images.*' => 'nullable|string',
        ];
    }

    /**
     * Get custom error messages for validation rules.
     */
    public function messages(): array
    {
        return [
            'name_en.required' => 'Product name in English is required.',
            'name_en.max' => 'Product name in English cannot exceed 255 characters.',
            'name_ar.required' => 'Product name in Arabic is required.',
            'name_ar.max' => 'Product name in Arabic cannot exceed 255 characters.',
            
            'regular_price.numeric' => 'Regular price must be a valid number.',
            'regular_price.min' => 'Regular price cannot be negative.',
            'sale_price.numeric' => 'Sale price must be a valid number.',
            'sale_price.min' => 'Sale price cannot be negative.',
            
            'stock.required' => 'Stock quantity is required.',
            'stock.integer' => 'Stock must be a whole number.',
            'stock.min' => 'Stock cannot be negative.',
            
            'views.integer' => 'Views must be a whole number.',
            'views.min' => 'Views cannot be negative.',
            
            'attributes.json' => 'Attributes must be in valid JSON format.',
            
            'image_url.file' => 'Main image must be a valid file.',
            'image_url.mimes' => 'Main image must be in JPEG, PNG, JPG, GIF, SVG, or WebP format.',
            'image_url.max' => 'Main image size cannot exceed 2MB.',
            
            'gallery.*.file' => 'Gallery images must be valid files.',
            'gallery.*.mimes' => 'Gallery images must be in JPEG, PNG, JPG, GIF, SVG, or WebP format.',
            'gallery.*.max' => 'Each gallery image size cannot exceed 2MB.',
            
            'category_id.required' => 'Please select a category.',
            'category_id.exists' => 'Selected category does not exist.',
            
            'vendor_id.required' => 'Please select a vendor.',
            'vendor_id.exists' => 'Selected vendor does not exist.',
            
            'removed_images.array' => 'Removed images must be an array or valid JSON string.',
            'removed_images.*.string' => 'Removed image path must be a string.',
        ];
    }

    /**
     * Get custom attributes for validator errors.
     */
    public function attributes(): array
    {
        return [
            'name_en' => 'product name (English)',
            'name_ar' => 'product name (Arabic)',
            'description_en' => 'description (English)',
            'description_ar' => 'description (Arabic)',
            'regular_price' => 'regular price',
            'sale_price' => 'sale price',
            'stock' => 'stock quantity',
            'views' => 'views count',
            'attributes' => 'product attributes',
            'image_url' => 'main image',
            'gallery' => 'gallery images',
            'category_id' => 'category',
            'vendor_id' => 'vendor',
            'status' => 'product status',
            'removed_images' => 'removed images',
        ];
    }

    /**
     * Configure the validator instance.
     */
    public function withValidator($validator)
    {
        $validator->after(function ($validator) {
            // Handle image_url field - validate file uploads if present
            $imageUrl = $this->input('image_url');
            if ($imageUrl instanceof \Illuminate\Http\UploadedFile) {
                // Validate file upload
                $allowedMimes = ['jpeg', 'png', 'jpg', 'gif', 'svg', 'webp'];
                $maxSize = 2048; // 2MB
                
                if (!$imageUrl->isValid()) {
                    $validator->errors()->add('image_url', 'Invalid image file.');
                } elseif ($imageUrl->getSize() > ($maxSize * 1024)) {
                    $validator->errors()->add('image_url', "Image size must be less than {$maxSize}KB.");
                } elseif (!in_array($imageUrl->getClientOriginalExtension(), $allowedMimes)) {
                    $validator->errors()->add('image_url', 'Invalid image format. Allowed: ' . implode(', ', $allowedMimes));
                }
            } elseif ($imageUrl !== null && !is_string($imageUrl)) {
                $validator->errors()->add('image_url', 'Image URL must be a valid file or string.');
            }

            // Handle removed_images field - convert to array if needed
            $removedImages = $this->input('removed_images');
            if ($removedImages !== null) {
                if (is_string($removedImages)) {
                    // Try to decode JSON string
                    $decoded = json_decode($removedImages, true);
                    if (json_last_error() === JSON_ERROR_NONE && is_array($decoded)) {
                        $this->merge(['removed_images' => $decoded]);
                    } else {
                        // If it's not JSON, treat as comma-separated string
                        $this->merge(['removed_images' => array_filter(array_map('trim', explode(',', $removedImages)))]);
                    }
                } elseif (!is_array($removedImages)) {
                    $validator->errors()->add('removed_images', 'Removed images must be an array or valid JSON string.');
                    return;
                }
                
                // Ensure all removed_images are strings
                $removedImages = $this->input('removed_images');
                if (is_array($removedImages)) {
                    $filteredImages = array_filter($removedImages, function($image) {
                        return is_string($image) && !empty(trim($image));
                    });
                    $this->merge(['removed_images' => array_values($filteredImages)]);
                }
                
                // Debug logging (remove in production)
                \Illuminate\Support\Facades\Log::info('Removed images processed:', [
                    'original' => $this->input('removed_images'),
                    'final' => $this->input('removed_images')
                ]);
            }

            // Check if gallery has too many images (including existing ones)
            if ($this->hasFile('gallery')) {
                $newImagesCount = count($this->file('gallery'));
                $removedImagesCount = count($this->input('removed_images', []));
                
                // Get current product to check existing gallery count
                $product = $this->route('product');
                $existingGalleryCount = count($product->gallery ?? []);
                
                $finalCount = $existingGalleryCount - $removedImagesCount + $newImagesCount;
                
                if ($finalCount > 10) {
                    $validator->errors()->add('gallery', 'Maximum 10 images allowed in gallery. You currently have ' . $existingGalleryCount . ' images.');
                }
            }
        });
    }
} 