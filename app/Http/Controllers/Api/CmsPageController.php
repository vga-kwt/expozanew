<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Api\Controller;
use Illuminate\Http\Request;
use App\Models\CmsPage;

class CmsPageController extends Controller
{
     /**
         * List CMS page by slug (public)
         *
         * @OA\Get(
         *     path="/api/cms-pages/{slug}",
         *     summary="List CMS page by slug (public)",
         *     tags={"CMS Page"},
         *     @OA\Parameter(
         *         name="slug",
         *         in="path",
         *         required=true,
         *         description="Slug of the CMS page",
         *         @OA\Schema(type="string")
         *     ),
         *     @OA\Response(
         *         response=200,
         *         description="CMS Page"
         *     )
         * )
         */
        public function listBySlug($slug)
        {
            $cmsPage = CmsPage::where('slug', $slug)->where('deleted_at', null)->where('status', 'active')->first();
            if (!$cmsPage) {
                return $this->errorResponse('CMS Page not found', 404);
            }
            return $this->successResponse($cmsPage);
        }
}
