<?php

namespace App\Http\Controllers;

use App\Models\Category;
use Illuminate\Http\Request;
use Inertia\Inertia;
use Illuminate\Support\Facades\Storage;

class CategoryController extends Controller
{
    // List categories
    public function index(Request $request)
    {
        $categories = Category::orderByDesc('id')->paginate(10)->withQueryString();
        return Inertia::render('Categories/Index', [
            'categories' => $categories,
        ]);
    }

    // Store new category
    public function store(Request $request)
    {
        $validated = $request->validate([
            'name_en' => 'required|string|max:255',
            'name_ar' => 'required|string|max:255',
            'image' => 'required|image|mimes:jpeg,png,jpg,gif,svg|dimensions:min_width=200,min_height=200',
        ]);
        
        $disk = config('filesystems.default', 's3');
        $path = $request->file('image')->store('categories', $disk);
        $validated['image'] = $path;
        Category::create($validated);
        return redirect()->back()->with('success', 'Category added.');
    }

    // Update category
    public function update(Request $request, Category $category)
    {
        $validated = $request->validate([
            'name_en' => 'required|string|max:255',
            'name_ar' => 'required|string|max:255',
            'image' => 'nullable|image|mimes:jpeg,png,jpg,gif,svg|dimensions:min_width=200,min_height=200',
        ]);
        
        $disk = config('filesystems.default', 's3');
        
        if ($request->hasFile('image')) {
            // Delete old image
            if ($category->image) Storage::disk($disk)->delete($category->image);
            $path = $request->file('image')->store('categories', $disk);
            $validated['image'] = $path;
        }
        $category->update($validated);
        return redirect()->back()->with('success', 'Category updated.');
    }

    // Suspend category
    public function suspend(Category $category)
    {
        $category->update(['status' => 'suspended']);
        return redirect()->back()->with('success', 'Category suspended.');
    }

    // Toggle status (suspend/activate)
    public function toggleStatus(Category $category)
    {
        $category->status = $category->status === 'suspended' ? 'active' : 'suspended';
        $category->save();
        return redirect()->back()->with('success', 'Category status updated!');
    }

    // Delete category
    public function destroy(Category $category)
    {
        $disk = config('filesystems.default', 's3');
        if ($category->image) Storage::disk($disk)->delete($category->image);
        $category->delete();
        return redirect()->back()->with('success', 'Category deleted successfully.');
    }
}
