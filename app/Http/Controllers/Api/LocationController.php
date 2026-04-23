<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Country;
use App\Models\State;
use App\Models\City;

class LocationController extends Controller
{
    /**
     * Return a standard success response for API endpoints
     */
    protected function successResponse($data, $message = 'Success', $code = 200)
    {
        return response()->json([
            'success' => true,
            'message' => $message,
            'data' => $data,
        ], $code);
    }

    /**
     * @OA\Get(
     *     path="/api/countries",
     *     summary="Get all countries",
     *     tags={"Location"},
     *     @OA\Response(
     *         response=200,
     *         description="List of countries"
     *     )
     * )
     */

    public function countries()
    {
        $countries = Country::where('deleted_at', null)->get();
        return $this->successResponse($countries);
    }

    /**
     * @OA\Get(
     *     path="/api/states/{country_id}",
     *     summary="Get all states for a country",
     *     tags={"Location"},
     *     @OA\Parameter(
     *         name="country_id",
     *         in="path",
     *         required=true,
     *         @OA\Schema(type="integer")
     *     ),
     *     @OA\Response(
     *         response=200,
     *         description="List of states"
     *     )
     * )
     */

    public function states($country_id)
    {
        $states = State::where('country_id', $country_id)->where('deleted_at', null)->get();
        return $this->successResponse($states);
    }

    /**
     * @OA\Get(
     *     path="/api/cities/{country_id}/{state_id}",
     *     summary="Get all cities for a state",
     *     tags={"Location"},
     *     @OA\Parameter(
     *         name="country_id",
     *         in="path",
     *         required=true,
     *         @OA\Schema(type="integer")
     *     ),
     *     @OA\Parameter(
     *         name="state_id",
     *         in="path",
     *         required=true,
     *         @OA\Schema(type="integer")
     *     ),
     *     @OA\Response(
     *         response=200,
     *         description="List of cities"
     *     )
     * )
     */

    public function cities($country_id, $state_id)
    {
        $cities = City::where('country_id', $country_id)->where('state_id', $state_id)->where('deleted_at', null)->get();
        return $this->successResponse($cities);
    }
}
