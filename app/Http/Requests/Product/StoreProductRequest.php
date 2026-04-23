<?php

namespace App\Http\Requests\Product;

use Illuminate\Foundation\Http\FormRequest;

class StoreProductRequest extends FormRequest
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
            // 'regular_price' => 'required|numeric|min:1',
            // 'sale_price' => 'nullable|numeric|min:0',
            'stock' => 'nullable|integer|min:0',
            'views' => 'nullable',
            'attributes' => 'nullable|json', // Stores variants: [{size, color, price, sale_price, stock}]
            'image_url' => 'required|file|mimes:jpeg,png,jpg|max:3072',
            'gallery' => 'nullable|array|min:1|max:5',
            'gallery.*' => 'file|mimes:jpeg,png,jpg|max:3072',
            'category_id' => 'required|exists:categories,id',
            'vendor_id' => 'nullable|exists:vendors,id',
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

            'regular_price.required' => 'Regular price is required.',
            'regular_price.numeric.required' => 'Regular price must be a valid number.',
            'regular_price.min.required' => 'Regular price cannot be negative.',
            'sale_price.numeric' => 'Sale price must be a valid number.',
            'sale_price.min' => 'Sale price cannot be negative.',

            'stock.required' => 'Stock quantity is required.',
            'stock.integer.required' => 'Stock must be a whole number.',
            'stock.min.required' => 'Stock cannot be negative.',

            'views.integer.required' => 'Views must be a whole number.',
            'views.min.required' => 'Views cannot be negative.',

            'attributes.json' => 'Attributes must be in valid JSON format.',

            'image_url.file' => 'Main image must be a valid file.',
            'image_url.mimes.required' => 'Main image must be in JPEG, PNG, JPG, GIF, SVG, or WebP format.',
            'image_url.max.required' => 'Main image size cannot exceed 2MB.',

            'gallery.*.file' => 'Gallery images must be valid files.',
            'gallery.*.mimes.required' => 'Gallery images must be in JPEG, PNG, JPG, GIF, SVG, or WebP format.',
            'gallery.*.max.required' => 'Each gallery image size cannot exceed 2MB.',

            'category_id.required' => 'Please select a category.',
            'category_id.exists' => 'Selected category does not exist.',

            'vendor_id.required' => 'Please select a vendor.',
            'vendor_id.exists' => 'Selected vendor does not exist.',

            // 'status.required' => 'Please select a status.',
            // 'status.in' => 'Status must be active, suspended, or deleted.',
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
        ];
    }

    /**
     * Configure the validator instance.
     */
    public function withValidator($validator)
    {
        $validator->after(function ($validator) {
            // Check if gallery has too many images
            if ($this->hasFile('gallery')) {
                $galleryCount = count($this->file('gallery'));
                if ($galleryCount > 10) {
                    $validator->errors()->add('gallery', 'Maximum 10 images allowed in gallery.');
                }
            }
        });
    }
}
