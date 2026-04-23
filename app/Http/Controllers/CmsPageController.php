<?php

namespace App\Http\Controllers;

use App\Models\CmsPage;
use App\Services\CmsPageService;
use App\Http\Requests\CmsPage\StoreCmsPageRequest;
use App\Http\Requests\CmsPage\UpdateCmsPageRequest;
use Illuminate\Http\Request;
use Inertia\Inertia;

class CmsPageController extends Controller
{
    protected CmsPageService $cmsPageService;

    public function __construct(CmsPageService $cmsPageService)
    {
        $this->cmsPageService = $cmsPageService;
    }

    public function index(Request $request)
    {
        $pages = $this->cmsPageService->getCmsPages($request);
        $filterData = $this->cmsPageService->getFiltersData($request);

        return Inertia::render('CMS/Index', [
            'pages' => $pages,
            'filters' => $filterData['filters'],
            'hasActiveFilters' => $filterData['has_active_filters'],
            'activeFilterCount' => $filterData['active_filter_count'],
        ]);
    }

    public function create()
    {
        return Inertia::render('CMS/Create');
    }

    public function store(StoreCmsPageRequest $request)
    {
        $validated = $request->validated();
        $this->cmsPageService->createCmsPage($validated);
        return redirect()->route('cms-pages.index')->with('success', 'CMS page created successfully!');
    }

    public function edit(CmsPage $cmsPage)
    {
        $pageData = $this->cmsPageService->getCmsPageForEdit($cmsPage);
        
        return Inertia::render('CMS/Edit', [
            'page' => $pageData,
        ]);
    }

    public function update(UpdateCmsPageRequest $request, CmsPage $cmsPage)
    {
        $validated = $request->validated();
        $this->cmsPageService->updateCmsPage($cmsPage, $validated);
        return redirect()->route('cms-pages.index')->with('success', 'CMS page updated successfully!');
    }

    public function destroy(CmsPage $cmsPage)
    {
        $this->cmsPageService->deleteCmsPage($cmsPage);
        return redirect()->route('cms-pages.index')->with('success', 'CMS page deleted successfully!');
    }

    public function suspend(CmsPage $cmsPage)
    {
        $oldStatus = $cmsPage->status;
        $this->cmsPageService->suspendCmsPage($cmsPage);
        
        $action = $oldStatus === 'active' ? 'suspended' : 'activated';
        $message = "CMS page {$action} successfully!";
        
        return redirect()->back()->with('success', $message);
    }

    public function show(CmsPage $cmsPage)
    {
        $pageData = $this->cmsPageService->getCmsPageForShow($cmsPage);
        return response()->json($pageData);
    }

    /**
     * Display CMS page publicly by slug
     */
    public function showBySlug($slug)
    {
        $cmsPage = CmsPage::where('slug', $slug)
            ->where('deleted_at', null)
            ->where('status', 'active')
            ->first();

        if (!$cmsPage) {
            abort(404, 'Page not found');
        }

        return Inertia::render('CMS/View', [
            'page' => $cmsPage,
        ]);
    }
}
