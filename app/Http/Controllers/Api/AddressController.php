<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Api\Controller;
use App\Models\Address;
use App\Models\City;
use App\Models\Country;
use App\Models\State;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class AddressController extends Controller
{
    /**
     * @OA\Get(
     *     path="/api/addresses",
     *     summary="List all addresses for authenticated user",
     *     tags={"Address"},
     *     security={{"sanctum":{}}},
     *     @OA\Response(
     *         response=200,
     *         description="List of addresses"
     *     )
     * )
     */
    public function index(Request $request)
    {
        $addresses = $request->user()->addresses()
            ->with(['country:id,name_en', 'state:id,name_en', 'city:id,name_en']) // only fetch name_en
            ->where('deleted_at', null)
            ->get()
            ->map(function ($address) {
                return [
                    'id' => $address->id,
                    'user_id' => $address->user_id,
                    'user_role' => $address->role_name,
                    'full_name' => $address->full_name,
                    'phone' => $address->phone,
                    'address_line1' => $address->line_1,
                    'address_line2' => $address->line_2,
                    'country_id' => $address->country_id,
                    'country' => $address->country?->name_en,
                    'state_id' => $address->state_id,
                    'state' => $address->state?->name_en,
                    'city_id' => $address->city_id,
                    'city' => $address->city?->name_en,
                    'postal_code' => $address->pincode,
                    'is_default' => $address->is_default,
                    'created_at' => $address->created_at,
                    'updated_at' => $address->updated_at,
                ];
            });

        return $this->successResponse($addresses);
    }

    /**
     * @OA\Post(
     *     path="/api/addresses",
     *     summary="Store a new address",
     *     tags={"Address"},
     *     security={{"sanctum":{}}},
     *     @OA\RequestBody(
     *         required=true,
     *         @OA\JsonContent(
     *             required={"full_name", "phone", "line_1", "country_id", "state_id", "city_id"},
     *             @OA\Property(property="full_name", type="string", example="testing user"),
     *             @OA\Property(property="phone", type="string", example="9876541236"),
     *             @OA\Property(property="line_1", type="string", example="7564 William Harbors Suite 578"),
     *             @OA\Property(property="line_2", type="string", example="Suite 260"),
     *             @OA\Property(property="country_id", type="integer", example=1),
     *             @OA\Property(property="state_id", type="integer", example=1),
     *             @OA\Property(property="city_id", type="integer", example=1),
     *             @OA\Property(property="pincode", type="string", example="965864"),
     *             @OA\Property(property="is_default", type="boolean", example=true)
     *         )
     *     ),
     *     @OA\Response(
     *         response=201,
     *         description="Address added"
     *     ),
     *     @OA\Response(
     *         response=422,
     *         description="Validation error"
     *     )
     * )
     */

    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'full_name'   => 'required|string|max:255',
            'phone'       => 'required|string|max:20',
            'line_1'      => 'required|string|max:255',
            'line_2'      => 'nullable|string|max:255',
            'country_id'  => 'required|integer|exists:countries,id',
            'state_id'    => 'required|integer|exists:states,id',
            'city_id'     => 'required|integer|exists:cities,id',
            'pincode'     => 'nullable|string|max:20',
            'is_default'  => 'boolean',
        ]);

        if ($validator->fails()) {
            return $this->validationErrorResponse($validator->errors());
        }

        $data = $validator->validated();

        $user = $request->user();
        $data['user_id'] = $user->id;
        $data['role_name'] = $user->role ?? 'user'; // <-- Get role name here

        if (!empty($data['is_default'])) {
            Address::where('user_id', $data['user_id'])
                ->where('role_name', $data['role_name'])
                ->update(['is_default' => false]);
        }

        $address = Address::create($data);

        return $this->successResponse($address, 'Address added', 201);
    }


    public function show(Request $request, $id)
    {
        $user = $request->user();

        $address = Address::where('user_id', $user->id)->where('deleted_at', null)->find($id);

        if (!$address) {
            return $this->notFoundResponse('Address not found');
        }

        return $this->successResponse($address);
    }

    /**
     * @OA\Put(
     *     path="/api/addresses/{id}",
     *     summary="Update an address",
     *     tags={"Address"},
     *     security={{"sanctum":{}}},
     *     @OA\Parameter(
     *         name="id",
     *         in="path",
     *         required=true,
     *         @OA\Schema(type="integer")
     *     ),
     *     @OA\RequestBody(
     *         required=true,
     *         @OA\JsonContent(
     *             required={"full_name", "phone", "line_1", "country_id", "state_id", "city_id"},
     *             @OA\Property(property="full_name", type="string", example="testing user"),
     *             @OA\Property(property="phone", type="string", example="9876541236"),
     *             @OA\Property(property="line_1", type="string", example="7564 William Harbors Suite 578"),
     *             @OA\Property(property="line_2", type="string", example="Suite 260"),
     *             @OA\Property(property="country_id", type="integer", example=1),
     *             @OA\Property(property="state_id", type="integer", example=1),
     *             @OA\Property(property="city_id", type="integer", example=1),
     *             @OA\Property(property="pincode", type="string", example="965864"),
     *             @OA\Property(property="is_default", type="boolean", example=true)
     *         )
     *     ),
     *     @OA\Response(
     *         response=200,
     *         description="Address updated"
     *     )
     * )
     */
    public function update(Request $request, $id)
    {
        $user = $request->user();

        $address = Address::where('user_id', $user->id)->where('deleted_at', null)->findOrFail($id);

        $validator = Validator::make($request->all(), [
            'full_name'   => 'required|string|max:255',
            'phone'       => 'required|string|max:20',
            'line_1'      => 'required|string|max:255',
            'line_2'      => 'nullable|string|max:255',
            'country_id'  => 'required|integer|exists:countries,id',
            'state_id'    => 'required|integer|exists:states,id',
            'city_id'     => 'required|integer|exists:cities,id',
            'pincode'     => 'nullable|string|max:20',
            'is_default'  => 'boolean',
        ]);

        if ($validator->fails()) {
            return $this->validationErrorResponse($validator->errors());
        }

        $data = $validator->validated();
        $data['role_name'] = $user->role ?? 'user';

        if (!empty($data['is_default'])) {
            Address::where('user_id', $user->id)
                ->where('role_name', $data['role_name'])
                ->where('deleted_at', null)
                ->update(['is_default' => false]);
        }

        $address->update($data);

        return $this->successResponse($address, 'Address updated');
    }


    /**
     * @OA\Delete(
     *     path="/api/addresses/{id}",
     *     summary="Delete an address",
     *     tags={"Address"},
     *     security={{"sanctum":{}}},
     *     @OA\Parameter(
     *         name="id",
     *         in="path",
     *         required=true,
     *         @OA\Schema(type="integer")
     *     ),
     *     @OA\Response(
     *         response=200,
     *         description="Address deleted"
     *     )
     * )
     */
    public function destroy(Request $request, $id)
    {
        $address = Address::where('user_id', $request->user()->id)->where('deleted_at', null)->findOrFail($id);
        $address->delete();
        return $this->successResponse(null, 'Address deleted');
    }

   
}
