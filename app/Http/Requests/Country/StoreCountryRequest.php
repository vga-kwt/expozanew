<?php

namespace App\Http\Requests\Country;

use Illuminate\Foundation\Http\FormRequest;

class StoreCountryRequest extends FormRequest
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
            'name_en' => 'required|string|max:255|unique:countries,name_en',
            'name_ar' => 'nullable|string|max:255|unique:countries,name_ar',
            'status' => 'required|in:active,suspended',
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
            'name_en.required' => 'The English name is required.',
            'name_en.unique' => 'This English name is already taken.',
            'name_en.max' => 'The English name may not be greater than 255 characters.',
            'name_ar.unique' => 'This Arabic name is already taken.',
            'name_ar.max' => 'The Arabic name may not be greater than 255 characters.',
            'status.required' => 'The status is required.',
            'status.in' => 'The status must be either active or suspended.',
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
            'name_en' => 'English name',
            'name_ar' => 'Arabic name',
            'status' => 'status',
        ];
    }
} 