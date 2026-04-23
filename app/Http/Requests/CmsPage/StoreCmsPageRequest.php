<?php

namespace App\Http\Requests\CmsPage;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class StoreCmsPageRequest extends FormRequest
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
     *
     * @return array<string, \Illuminate\Contracts\Validation\ValidationRule|array<mixed>|string>
     */
    public function rules(): array
    {
        return [
            'title_en' => 'required|string|max:255',
            'title_ar' => 'required|string|max:255',
            'content_en' => 'required|string',
            'content_ar' => 'required|string',
            'slug' => 'nullable|string|max:255|unique:cms_pages,slug',
            'meta_title' => 'nullable|string|max:255',
            'meta_description' => 'nullable|string|max:500',
            'meta_keywords' => 'nullable|string|max:255',
            'status' => 'required|in:active,suspended,draft',
        ];
    }

    /**
     * Get custom messages for validator errors.
     *
     * @return array
     */
    public function messages(): array
    {
        return [
            'title_en.required' => 'The English title is required.',
            'title_en.max' => 'The English title may not be greater than 255 characters.',
            'title_ar.required' => 'The Arabic title is required.',
            'title_ar.max' => 'The Arabic title may not be greater than 255 characters.',
            'content_en.required' => 'The English content is required.',
            'content_ar.required' => 'The Arabic content is required.',
            'slug.unique' => 'This slug is already taken.',
            'slug.max' => 'The slug may not be greater than 255 characters.',
            'meta_title.max' => 'The meta title may not be greater than 255 characters.',
            'meta_description.max' => 'The meta description may not be greater than 500 characters.',
            'meta_keywords.max' => 'The meta keywords may not be greater than 255 characters.',
            'status.required' => 'The status is required.',
            'status.in' => 'The status must be active, suspended, or draft.',
        ];
    }

    /**
     * Get custom attributes for validator errors.
     *
     * @return array
     */
    public function attributes(): array
    {
        return [
            'title_en' => 'English title',
            'title_ar' => 'Arabic title',
            'content_en' => 'English content',
            'content_ar' => 'Arabic content',
            'slug' => 'slug',
            'meta_title' => 'meta title',
            'meta_description' => 'meta description',
            'meta_keywords' => 'meta keywords',
            'status' => 'status',
        ];
    }
} 