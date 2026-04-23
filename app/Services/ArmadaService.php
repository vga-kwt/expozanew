<?php

namespace App\Services;

use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;
use Exception;

/**
 * Armada Delivery API Service
 * 
 * This service handles all interactions with Armada Delivery API
 * for order management, tracking, and delivery operations.
 */
class ArmadaService
{
    protected $baseUrl;
    protected $apiKey;
    protected $branchId;
    protected $timeout;

    public function __construct()
    {
        $this->baseUrl = config('armada.base_url', 'https://api.armadadelivery.com');
        // For order creation, use regular API key first (main API key is not allowed for order creation)
        // Main API key is typically used for admin/dashboard operations
        $this->apiKey = config('armada.api_key') ?? config('armada.main_api_key');
        $this->branchId = config('armada.branch_id');
        $this->timeout = config('armada.timeout', 30);
        
        // Check if API keys are valid (basic validation)
        $this->validateApiKeys();
        
        // Log configuration for debugging
        Log::info('ArmadaService initialized', [
            'base_url' => $this->baseUrl,
            'api_key_set' => !empty($this->apiKey),
            'api_key_type' => config('armada.api_key') ? 'api_key' : 'main_api_key',
            'api_key_preview' => $this->apiKey ? substr($this->apiKey, 0, 15) . '...' : 'NOT SET',
            'branch_id' => $this->branchId,
            'main_api_key_available' => !empty(config('armada.main_api_key')),
            'regular_api_key_available' => !empty(config('armada.api_key')),
            'note' => 'Using regular API key for order operations (main API key not allowed for order creation)',
        ]);
    }

    /**
     * Validate API keys format
     * 
     * @return void
     */
    protected function validateApiKeys(): void
    {
        $mainApiKey = config('armada.main_api_key');
        $regularApiKey = config('armada.api_key');
        
        if (empty($mainApiKey) && empty($regularApiKey)) {
            Log::warning('Armada API keys not configured', [
                'suggestion' => 'Please set ARMADA_MAIN_API_KEY or ARMADA_API_KEY in .env file',
            ]);
            return;
        }
        
        // Check if main API key format is correct (should start with 'main_')
        if ($mainApiKey && !str_starts_with($mainApiKey, 'main_')) {
            Log::warning('Armada main API key format might be incorrect', [
                'expected_format' => 'main_xxxxxxxxx',
                'actual_preview' => substr($mainApiKey, 0, 20) . '...',
                'suggestion' => 'Main API key should start with "main_" prefix',
            ]);
        }
    }

    /**
     * Create a new branch in Armada (v0 API)
     *
     * Uses ARMADA_MAIN_API_KEY for authorization.
     *
     * @param \App\Models\Vendor $vendor
     * @return array ['success' => bool, 'branch_id' => string|null, 'branch_key' => string|null, 'error' => string|null]
     */
    public function createBranch($vendor): array
    {
        try {
            $mainApiKey = config('armada.main_api_key');
            if (empty($mainApiKey)) {
                throw new Exception('Armada main API key is not configured. Required for branch creation.');
            }

            $phone = $vendor->mobile ?? $vendor->phone ?? '';
            if ($phone && !str_starts_with($phone, '+')) {
                $phone = '+965' . ltrim($phone, '0');
            }

            // Default to Kuwait City center if vendor has no coordinates (e.g. registered before location was required)
            $defaultLat = 29.3759;
            $defaultLng = 47.9774;
            $lat = $vendor->latitude !== null && $vendor->latitude !== '' ? (float) $vendor->latitude : $defaultLat;
            $lng = $vendor->longitude !== null && $vendor->longitude !== '' ? (float) $vendor->longitude : $defaultLng;
            if ($vendor->latitude === null && $vendor->longitude === null) {
                Log::warning('Armada Create Branch: vendor has no coordinates, using default (Kuwait City)', [
                    'vendor_id' => $vendor->id,
                ]);
            }

            $branchData = [
                'name' => $vendor->brand_name_en ?? $vendor->name ?? 'Vendor',
                'phone' => $phone,
                'address' => [
                    'location' => [
                        'latitude' => $lat,
                        'longitude' => $lng,
                    ],
                    'firstLine' => $vendor->address_text ?? '',
                ],
                'webhook' => config('armada.webhook_url', ''),
            ];

            Log::info('Armada Create Branch Request', [
                'url' => $this->baseUrl . '/v0/branches',
                'vendor_id' => $vendor->id,
                'branch_data' => $branchData,
            ]);

            $response = Http::timeout($this->timeout)
                ->withHeaders([
                    'Authorization' => 'Key ' . $mainApiKey,
                    'Content-Type' => 'application/json',
                    'Accept' => 'application/json',
                ])
                ->post($this->baseUrl . '/v0/branches', $branchData);

            if ($response->successful()) {
                $responseData = $response->json();

                Log::info('Armada Branch Created Successfully', [
                    'vendor_id' => $vendor->id,
                    'branch_id' => $responseData['_id'] ?? null,
                    'branch_key' => $responseData['key'] ? substr($responseData['key'], 0, 15) . '...' : null,
                ]);

                return [
                    'success' => true,
                    'branch_id' => $responseData['_id'] ?? null,
                    'branch_key' => $responseData['key'] ?? null,
                    'data' => $responseData,
                ];
            }

            Log::error('Armada Create Branch Failed', [
                'vendor_id' => $vendor->id,
                'status_code' => $response->status(),
                'response_body' => $response->body(),
            ]);

            return [
                'success' => false,
                'error' => 'Armada API Error (Status: ' . $response->status() . '): ' . $response->body(),
            ];
        } catch (Exception $e) {
            Log::error('Armada Create Branch Exception', [
                'vendor_id' => $vendor->id ?? null,
                'error' => $e->getMessage(),
            ]);

            return [
                'success' => false,
                'error' => $e->getMessage(),
            ];
        }
    }

    /**
     * Update an existing branch in Armada (v0 API)
     *
     * Uses the vendor's branch API key (armada_branch_key). Armada requires the regular/branch key for updates, not the main key.
     *
     * @param \App\Models\Vendor $vendor
     * @return array ['success' => bool, 'error' => string|null]
     */
    public function updateBranch($vendor): array
    {
        if (empty($vendor->armada_branch_id)) {
            return ['success' => true];
        }
        if (empty($vendor->armada_branch_key)) {
            Log::warning('Armada update branch skipped: vendor has no branch key', ['vendor_id' => $vendor->id]);
            return ['success' => false, 'error' => 'Vendor has no Armada branch key.'];
        }

        try {
            $branchApiKey = $vendor->armada_branch_key;

            $phone = $vendor->mobile ?? $vendor->phone ?? '';
            if ($phone && !str_starts_with($phone, '+')) {
                $phone = '+965' . ltrim($phone, '0');
            }

            $defaultLat = 29.3759;
            $defaultLng = 47.9774;
            $lat = $vendor->latitude !== null && $vendor->latitude !== '' ? (float) $vendor->latitude : $defaultLat;
            $lng = $vendor->longitude !== null && $vendor->longitude !== '' ? (float) $vendor->longitude : $defaultLng;

            $branchData = [
                'name' => $vendor->brand_name_en ?? $vendor->name ?? 'Vendor',
                'phone' => $phone,
                'address' => [
                    'location' => [
                        'latitude' => $lat,
                        'longitude' => $lng,
                    ],
                    'firstLine' => $vendor->address_text ?? '',
                ],
                'webhook' => config('armada.webhook_url', ''),
            ];

            $url = $this->baseUrl . '/v0/branches/' . $vendor->armada_branch_id;
            Log::info('Armada Update Branch Request', [
                'url' => $url,
                'vendor_id' => $vendor->id,
                'branch_data' => $branchData,
            ]);

            $response = Http::timeout($this->timeout)
                ->withHeaders([
                    'Authorization' => 'Key ' . $branchApiKey,
                    'Content-Type' => 'application/json',
                    'Accept' => 'application/json',
                ])
                ->put($url, $branchData);

            if ($response->successful()) {
                Log::info('Armada Branch Updated Successfully', [
                    'vendor_id' => $vendor->id,
                    'branch_id' => $vendor->armada_branch_id,
                ]);
                return ['success' => true, 'error' => null];
            }

            Log::warning('Armada Update Branch Failed', [
                'vendor_id' => $vendor->id,
                'status_code' => $response->status(),
                'response_body' => $response->body(),
            ]);
            return [
                'success' => false,
                'error' => 'Armada API Error (Status: ' . $response->status() . '): ' . $response->body(),
            ];
        } catch (Exception $e) {
            Log::error('Armada Update Branch Exception', [
                'vendor_id' => $vendor->id ?? null,
                'error' => $e->getMessage(),
            ]);
            return [
                'success' => false,
                'error' => $e->getMessage(),
            ];
        }
    }

    /**
     * Delete a branch in Armada (v0 API)
     *
     * Uses ARMADA_MAIN_API_KEY for authorization.
     *
     * @param string $branchId Armada branch _id
     * @return array ['success' => bool, 'error' => string|null]
     */
    public function deleteBranch(string $branchId): array
    {
        try {
            $mainApiKey = config('armada.main_api_key');
            if (empty($mainApiKey)) {
                throw new Exception('Armada main API key is not configured. Required for branch deletion.');
            }

            $url = $this->baseUrl . '/v0/branches/' . $branchId;
            Log::info('Armada Delete Branch Request', ['url' => $url, 'branch_id' => $branchId]);

            $response = Http::timeout($this->timeout)
                ->withHeaders([
                    'Authorization' => 'Key ' . $mainApiKey,
                    'Accept' => 'application/json',
                ])
                ->delete($url);

            if ($response->successful()) {
                Log::info('Armada Branch Deleted Successfully', ['branch_id' => $branchId]);
                return ['success' => true, 'error' => null];
            }

            Log::warning('Armada Delete Branch Failed', [
                'branch_id' => $branchId,
                'status_code' => $response->status(),
                'response_body' => $response->body(),
            ]);
            return [
                'success' => false,
                'error' => 'Armada API Error (Status: ' . $response->status() . '): ' . $response->body(),
            ];
        } catch (Exception $e) {
            Log::error('Armada Delete Branch Exception', [
                'branch_id' => $branchId,
                'error' => $e->getMessage(),
            ]);
            return [
                'success' => false,
                'error' => $e->getMessage(),
            ];
        }
    }

    /**
     * Create a new order in Armada
     * 
     * @param array $orderData
     * @param string|null $branchApiKey  Vendor's branch API key (overrides global key)
     * @return array
     * @throws Exception
     */
    public function createOrder(array $orderData, ?string $branchApiKey = null): array
    {
        try {
            // Log the request data
            Log::info('Armada Create Order Request', [
                'url' => $this->baseUrl . '/v0/deliveries',
                'api_key' => $this->apiKey ? 'SET' : 'NOT SET',
                'branch_id' => $this->branchId,
                'order_data' => $orderData,
            ]);

            // Use vendor branch key if provided, otherwise fall back to global key
            $apiKeyToUse = $branchApiKey ?? $this->apiKey;

            if (empty($apiKeyToUse)) {
                throw new Exception('Armada API key is not configured. Please set ARMADA_API_KEY or ARMADA_MAIN_API_KEY in .env file, or ensure vendor has a branch key.');
            }

            $isMainApiKey = str_starts_with($apiKeyToUse ?? '', 'main_');
            
            $authHeader = 'Key ' . $apiKeyToUse;
            
            $headers = [
                'Authorization' => $authHeader,
                'Content-Type' => 'application/json',
                'Accept' => 'application/json',
            ];
            
            // Add webhook key if available
            $webhookKey = config('armada.webhook_key');
            if ($webhookKey) {
                $headers['order-webhook-key'] = $webhookKey;
            }
            
            Log::info('Armada API Request Headers', [
                'authorization_format' => 'Key prefix',
                'authorization_preview' => substr($authHeader, 0, 30) . '...',
                'using_branch_key' => $branchApiKey !== null,
                'api_key_type' => $branchApiKey ? 'vendor_branch_key' : ($isMainApiKey ? 'main_api_key' : 'api_key'),
                'api_key_length' => strlen($apiKeyToUse ?? ''),
                'has_webhook_key' => !empty($webhookKey),
                'base_url' => $this->baseUrl,
                'headers_keys' => array_keys($headers),
            ]);
            
            $response = Http::timeout($this->timeout)
                ->withHeaders($headers)
                ->post($this->baseUrl . '/v0/deliveries', $orderData);
            
            // If 400 error with "Main API Key is not allowed" message, try with regular API key
            if ($response->status() === 400) {
                $responseBody = $response->json();
                $errorMessage = $responseBody['message'] ?? $response->body();
                
                if (str_contains(strtolower($errorMessage), 'main api key is not allowed')) {
                    Log::warning('Main API Key not allowed for order creation, trying regular API key', [
                        'error_message' => $errorMessage,
                    ]);
                    
                    // Try with regular API key if we're currently using main API key
                    if ($isMainApiKey && config('armada.api_key')) {
                        $regularApiKey = config('armada.api_key');
                        $authHeader = 'Key ' . $regularApiKey;
                        $headers['Authorization'] = $authHeader;
                        
                        Log::info('Retrying with regular API key', [
                            'authorization_preview' => substr($authHeader, 0, 30) . '...',
                        ]);
                        
                        $response = Http::timeout($this->timeout)
                            ->withHeaders($headers)
                            ->post($this->baseUrl . '/v0/deliveries', $orderData);
                        
                        // If successful, log it
                        if ($response->successful()) {
                            Log::info('Armada API request succeeded with regular API key', [
                                'status_code' => $response->status(),
                            ]);
                        }
                    }
                }
            }
            
            // If 401 Unauthorized, try alternative approaches
            if ($response->status() === 401) {
                $errorDetails = [
                    'status_code' => 401,
                    'response_body' => $response->body(),
                    'api_key_type_used' => $isMainApiKey ? 'main_api_key' : 'api_key',
                    'base_url' => $this->baseUrl,
                ];
                
                $retryAttempts = [];
                
                // Try alternative authorization formats
                $authFormats = [
                    'Bearer ' . $apiKeyToUse,
                    $apiKeyToUse, // No prefix
                ];
                
                // If using main API key, also try regular API key
                if ($isMainApiKey && config('armada.api_key')) {
                    $regularApiKey = config('armada.api_key');
                    $authFormats[] = 'Key ' . $regularApiKey;
                    $authFormats[] = 'Bearer ' . $regularApiKey;
                    $authFormats[] = $regularApiKey;
                }
                
                // If using regular API key, also try main API key
                if (!$isMainApiKey && config('armada.main_api_key')) {
                    $mainApiKey = config('armada.main_api_key');
                    $authFormats[] = 'Key ' . $mainApiKey;
                    $authFormats[] = 'Bearer ' . $mainApiKey;
                    $authFormats[] = $mainApiKey;
                }
                
                // Remove duplicates
                $authFormats = array_unique($authFormats);
                
                Log::warning('Armada API returned 401, trying alternative authorization formats', array_merge($errorDetails, [
                    'attempts_to_try' => count($authFormats),
                ]));
                
                // Try each authorization format
                foreach ($authFormats as $index => $authFormat) {
                    // Skip the format we already tried
                    if ($authFormat === $authHeader) {
                        continue;
                    }
                    
                    $headers['Authorization'] = $authFormat;
                    
                    Log::info('Retrying with alternative authorization format', [
                        'attempt' => $index + 1,
                        'format_preview' => substr($authFormat, 0, 30) . '...',
                        'format_type' => str_starts_with($authFormat, 'Bearer ') ? 'Bearer' : (str_starts_with($authFormat, 'Key ') ? 'Key' : 'Plain'),
                    ]);
                    
                    $response = Http::timeout($this->timeout)
                        ->withHeaders($headers)
                        ->post($this->baseUrl . '/v0/deliveries', $orderData);
                    
                    $retryAttempts[] = [
                        'format' => substr($authFormat, 0, 30) . '...',
                        'status_code' => $response->status(),
                    ];
                    
                    // If successful, break out of loop
                    if ($response->successful()) {
                        Log::info('Armada API request succeeded with alternative authorization format', [
                            'successful_format' => substr($authFormat, 0, 30) . '...',
                            'status_code' => $response->status(),
                        ]);
                        break;
                    }
                }
                
                // If still 401 after all attempts, log detailed error
                if ($response->status() === 401) {
                    Log::error('Armada API still returning 401 after trying all authorization formats', [
                        'original_format' => substr($authHeader, 0, 30) . '...',
                        'retry_attempts' => $retryAttempts,
                        'response_body' => $response->body(),
                        'suggestions' => [
                            '1. Verify API keys in Armada Dashboard are active and not expired',
                            '2. Check if API keys match between .env and Armada Dashboard',
                            '3. Verify base URL is correct (staging vs production)',
                            '4. Check branch ID is correct and matches Armada Dashboard',
                            '5. Contact Armada support with these logs if issue persists',
                            '6. To temporarily disable Armada, set ARMADA_ENABLED=false in .env',
                        ],
                        'temporary_solution' => 'Set ARMADA_ENABLED=false in .env to disable Armada integration temporarily',
                    ]);
                    
                    // Don't throw exception - allow order to be created locally
                    // The calling code will handle the failure gracefully
                }
            }

            // Log response details
            Log::info('Armada Create Order Response', [
                'status_code' => $response->status(),
                'successful' => $response->successful(),
                'response_body' => $response->body(),
                'response_json' => $response->json(),
            ]);

            if ($response->successful()) {
                $responseData = $response->json();
                
                // Extract order ID and tracking number from response
                // Armada uses 'code' field as tracking/order identifier
                $armadaOrderId = $responseData['id'] ?? $responseData['orderId'] ?? $responseData['code'] ?? null;
                $trackingNumber = $responseData['trackingNumber'] ?? $responseData['tracking_number'] ?? $responseData['code'] ?? null;
                
                Log::info('Armada Order Created Successfully', [
                    'response_data' => $responseData,
                    'armada_order_id' => $armadaOrderId,
                    'tracking_number' => $trackingNumber,
                    'order_status' => $responseData['orderStatus'] ?? null,
                ]);
                
                return [
                    'success' => true,
                    'data' => $responseData,
                    'armada_order_id' => $armadaOrderId,
                    'tracking_number' => $trackingNumber,
                ];
            }

            // Log error response
            $errorBody = $response->body();
            Log::error('Armada API Error Response', [
                'status_code' => $response->status(),
                'error_body' => $errorBody,
                'order_data' => $orderData,
            ]);

            // Don't throw exception - return error so order can still be created locally
            // The calling code should handle this gracefully
            return [
                'success' => false,
                'error' => 'Armada API Error (Status: ' . $response->status() . '): ' . $errorBody,
                'error_type' => 'armada_api_error',
                'status_code' => $response->status(),
            ];
        } catch (Exception $e) {
            Log::error('Armada Create Order Exception', [
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString(),
                'order_data' => $orderData,
            ]);

            // Don't throw exception - return error so order can still be created locally
            return [
                'success' => false,
                'error' => $e->getMessage(),
                'error_type' => 'armada_exception',
            ];
        }
    }

    /**
     * Get order details from Armada
     * 
     * @param string $armadaOrderId
     * @return array
     */
    public function getOrder(string $armadaOrderId): array
    {
        try {
            $response = Http::timeout($this->timeout)
                ->withHeaders([
                    'Authorization' => 'Key ' . $this->apiKey,
                    'Accept' => 'application/json',
                ])
                ->get($this->baseUrl . '/v0/deliveries/' . $armadaOrderId);

            if ($response->successful()) {
                return [
                    'success' => true,
                    'data' => $response->json(),
                ];
            }

            // If order not found (404), return success false but don't throw exception
            if ($response->status() === 404) {
                Log::warning('Armada order not found', [
                    'armada_order_id' => $armadaOrderId,
                    'response' => $response->body(),
                ]);
                
                return [
                    'success' => false,
                    'error' => 'Order not found in Armada',
                    'not_found' => true,
                ];
            }

            throw new Exception('Armada API Error (Status: ' . $response->status() . '): ' . $response->body());
        } catch (Exception $e) {
            Log::error('Armada Get Order Error', [
                'error' => $e->getMessage(),
                'armada_order_id' => $armadaOrderId,
            ]);

            return [
                'success' => false,
                'error' => $e->getMessage(),
            ];
        }
    }

    /**
     * Track order status
     * 
     * @param string $trackingNumber
     * @return array
     */
    public function trackOrder(string $trackingNumber): array
    {
        try {
            $response = Http::timeout($this->timeout)
                ->withHeaders([
                    'Authorization' => 'Key ' . $this->apiKey,
                    'Accept' => 'application/json',
                ])
                ->get($this->baseUrl . '/v0/deliveries/' . $trackingNumber);

            if ($response->successful()) {
                return [
                    'success' => true,
                    'data' => $response->json(),
                ];
            }

            throw new Exception('Armada API Error: ' . $response->body());
        } catch (Exception $e) {
            Log::error('Armada Track Order Error', [
                'error' => $e->getMessage(),
                'tracking_number' => $trackingNumber,
            ]);

            return [
                'success' => false,
                'error' => $e->getMessage(),
            ];
        }
    }

    /**
     * Cancel order in Armada
     * 
     * @param string $armadaOrderId
     * @param string|null $reason
     * @return array
     */
    public function cancelOrder(string $armadaOrderId, ?string $reason = null): array
    {
        try {
            $data = [];
            if ($reason) {
                $data['reason'] = $reason;
            }

            $response = Http::timeout($this->timeout)
                ->withHeaders([
                    'Authorization' => 'Key ' . $this->apiKey,
                    'Content-Type' => 'application/json',
                    'Accept' => 'application/json',
                ])
                ->post($this->baseUrl . '/v0/deliveries/' . $armadaOrderId . '/cancel', $data);

            if ($response->successful()) {
                return [
                    'success' => true,
                    'data' => $response->json(),
                ];
            }

            throw new Exception('Armada API Error: ' . $response->body());
        } catch (Exception $e) {
            Log::error('Armada Cancel Order Error', [
                'error' => $e->getMessage(),
                'armada_order_id' => $armadaOrderId,
            ]);

            return [
                'success' => false,
                'error' => $e->getMessage(),
            ];
        }
    }

    /**
     * Update order status
     * 
     * @param string $armadaOrderId
     * @param string $status
     * @return array
     */
    public function updateOrderStatus(string $armadaOrderId, string $status): array
    {
        try {
            $response = Http::timeout($this->timeout)
                ->withHeaders([
                    'Authorization' => 'Key ' . $this->apiKey,
                    'Content-Type' => 'application/json',
                    'Accept' => 'application/json',
                ])
                ->put($this->baseUrl . '/v0/deliveries/' . $armadaOrderId, [
                    'status' => $status,
                ]);

            if ($response->successful()) {
                return [
                    'success' => true,
                    'data' => $response->json(),
                ];
            }

            // If order not found (404), return success false but don't throw exception
            if ($response->status() === 404) {
                Log::warning('Armada order not found for status update', [
                    'armada_order_id' => $armadaOrderId,
                    'status' => $status,
                    'response' => $response->body(),
                ]);
                
                return [
                    'success' => false,
                    'error' => 'Order not found in Armada',
                    'not_found' => true,
                ];
            }

            throw new Exception('Armada API Error (Status: ' . $response->status() . '): ' . $response->body());
        } catch (Exception $e) {
            Log::error('Armada Update Order Status Error', [
                'error' => $e->getMessage(),
                'armada_order_id' => $armadaOrderId,
                'status' => $status,
            ]);

            return [
                'success' => false,
                'error' => $e->getMessage(),
            ];
        }
    }

    /**
     * Prepare order data for Armada API
     * 
     * @param \App\Models\Order $order
     * @param \App\Models\Address $address
     * @return array
     */
    public function prepareOrderData($order, $address): array
    {
        // Load relationships if not already loaded
        if (!$address->relationLoaded('city')) {
            $address->load('city');
        }
        if (!$address->relationLoaded('state')) {
            $address->load('state');
        }
        if (!$address->relationLoaded('country')) {
            $address->load('country');
        }
        if (!$order->relationLoaded('user')) {
            $order->load('user');
        }
        if (!$order->relationLoaded('orderItems')) {
            $order->load('orderItems.product');
        }

        // Get country code
        $countryCode = $this->getCountryCode($address->country_id ?? null);
        
        // Prepare phone number (ensure it starts with +)
        $phone = $address->phone ?? $order->user->mobile ?? '';
        if ($phone && !str_starts_with($phone, '+')) {
            // Add country code if not present
            if ($countryCode === 'KW' && !str_starts_with($phone, '965')) {
                $phone = '+965' . ltrim($phone, '0');
            } elseif ($countryCode === 'BH' && !str_starts_with($phone, '973')) {
                $phone = '+973' . ltrim($phone, '0');
            } elseif ($countryCode === 'SA' && !str_starts_with($phone, '966')) {
                $phone = '+966' . ltrim($phone, '0');
            } else {
                $phone = '+' . ltrim($phone, '+');
            }
        }

        // Prepare location data (if available)
        $location = null;
        // You can add latitude/longitude if available in address model
        // $location = [
        //     'latitude' => $address->latitude ?? null,
        //     'longitude' => $address->longitude ?? null,
        // ];

        // Prepare address based on country
        $addressData = [];
        
        if ($countryCode === 'KW' || $countryCode === 'BH') {
            // For Kuwait and Bahrain - use location or full address
            if ($location) {
                $addressData['location'] = $location;
            } else {
                // Full address format for Kuwait/Bahrain
                $addressData['area'] = $address->state->name_en ?? '';
                $addressData['block'] = '';
                $addressData['street'] = $address->line_1 ?? '';
                $addressData['buildingNumber'] = $address->line_2 ?? '';
            }
        } elseif ($countryCode === 'SA') {
            // For Saudi Arabia - use location, shortAddress, or firstLine
            if ($location) {
                $addressData['location'] = $location;
            } else {
                // Use firstLine for Saudi Arabia
                $addressData['firstLine'] = trim(implode(', ', array_filter([
                    $address->line_1,
                    $address->line_2,
                    $address->city->name_en ?? '',
                ])));
            }
        }

        // Prepare order data according to Armada API format
        $orderData = [
            'platformName' => 'expoza',
            'platformData' => [
                'orderId' => $order->order_code ?? 'ORD-' . $order->id,
                'name' => $address->full_name ?? $order->user->full_name ?? 'Customer',
                'phone' => $phone,
                ...$addressData, // Spread address data
                'amount' => number_format($order->total_amount, 3, '.', ''),
                'paymentType' => $this->mapPaymentMethod($order->payment_method),
            ],
        ];
        
        return $orderData;
    }

    /**
     * Get country code for Armada
     * 
     * @param int|null $countryId
     * @return string
     */
    protected function getCountryCode(?int $countryId): string
    {
        if (!$countryId) {
            return 'KW'; // Default to Kuwait
        }

        $country = \App\Models\Country::find($countryId);
        if (!$country) {
            return 'KW';
        }

        // Map country names to codes
        $countryCodeMap = [
            'Kuwait' => 'KW',
            'Bahrain' => 'BH',
            'Saudi Arabia' => 'SA',
            'UAE' => 'AE',
            'Oman' => 'OM',
            'Qatar' => 'QA',
        ];

        $countryName = $country->name_en ?? '';
        return $countryCodeMap[$countryName] ?? 'KW';
    }

    /**
     * Map payment method to Armada format
     * 
     * @param string|null $paymentMethod
     * @return string
     */
    protected function mapPaymentMethod(?string $paymentMethod): string
    {
        $paymentMethodMap = [
            'cash_on_delivery' => 'cod',
            'cod' => 'cod',
            'credit_card' => 'paid',
            'card' => 'paid',
            'knet' => 'paid',
            'visa/master' => 'paid',
            'apple pay' => 'paid',
            'paypal' => 'paid',
            'paid' => 'paid',
            'unpaid' => 'cod',
            'pending' => 'cod',
        ];

        // Check if payment status is paid
        $paymentStatus = strtolower($paymentMethod ?? '');
        
        // If payment is already done, return 'paid', otherwise 'cod'
        if (in_array($paymentStatus, ['paid', 'credit_card', 'card', 'knet', 'visa/master', 'apple pay', 'paypal'])) {
            return 'paid';
        }

        return 'cod';
    }

    /**
     * Map Armada status to our order status
     * 
     * @param string $armadaStatus
     * @return string
     */
    public function mapArmadaStatusToOrderStatus(string $armadaStatus): string
    {
        $statusMap = [
            'pending' => 'pending',
            'confirmed' => 'confirmed',
            'picked_up' => 'processing',
            'in_transit' => 'shipped',
            'out_for_delivery' => 'out_for_delivery',
            'delivered' => 'delivered',
            'cancelled' => 'cancelled',
            'failed' => 'failed',
            'returned' => 'returned',
        ];

        return $statusMap[strtolower($armadaStatus)] ?? 'pending';
    }
    
    /**
     * Map Armada status to delivery status enum
     * 
     * @param string $armadaStatus
     * @return string
     */
    public function mapArmadaStatusToDeliveryStatus(string $armadaStatus): string
    {
        $status = strtolower($armadaStatus);
        
        $statusMap = [
            'pending' => 'pending',
            'confirmed' => 'processing',
            'picked_up' => 'processing',
            'pickedup' => 'processing',
            'in_transit' => 'shipped',
            'intransit' => 'shipped',
            'out_for_delivery' => 'out_for_delivery',
            'outfordelivery' => 'out_for_delivery',
            'delivered' => 'delivered',
            'cancelled' => 'returned',
            'canceled' => 'returned',
            'failed' => 'failed',
            'returned' => 'returned',
        ];

        return $statusMap[$status] ?? 'pending';
    }

    /**
     * Get fulfillment flags based on Armada status
     * 
     * @param string $armadaStatus
     * @return array
     */
    public function getFulfillmentFlagsFromArmadaStatus(string $armadaStatus): array
    {
        $status = strtolower($armadaStatus);
        
        return [
            'is_ready' => in_array($status, ['confirmed', 'picked_up', 'in_transit', 'out_for_delivery', 'delivered']),
            'is_dispatched' => in_array($status, ['in_transit', 'out_for_delivery', 'delivered']),
            'in_transit' => in_array($status, ['in_transit', 'out_for_delivery', 'delivered']),
            'is_delivered' => ($status === 'delivered'),
            'is_rto' => ($status === 'returned'),
            'is_rto_recieved' => ($status === 'returned'),
        ];
    }

    /**
     * Handle webhook from Armada
     * 
     * @param array $webhookData
     * @return array
     */
    public function handleWebhook(array $webhookData): array
    {
        try {
            $orderNumber = $webhookData['order_number'] ?? $webhookData['order_id'] ?? null;
            $status = $webhookData['status'] ?? null;
            $trackingNumber = $webhookData['tracking_number'] ?? null;

            if (!$orderNumber) {
                throw new Exception('Order number not found in webhook data');
            }

            // Find order by order_code or armada_order_id
            $order = \App\Models\Order::where('order_code', $orderNumber)
                ->orWhere('armada_order_id', $orderNumber)
                ->first();

            if (!$order) {
                throw new Exception('Order not found: ' . $orderNumber);
            }

            // Update order status
            if ($status) {
                $orderStatus = $this->mapArmadaStatusToOrderStatus($status);
                $order->update([
                    'order_status' => $orderStatus,
                    'delivery_status' => $status,
                ]);
            }

            // Update tracking number
            if ($trackingNumber) {
                $order->update([
                    'armada_tracking_number' => $trackingNumber,
                ]);
            }

            // Update fulfillment with Armada tracking data
            $fulfillment = $order->fulfillments()->latest()->first();
            if ($fulfillment) {
                // Update tracking information
                if ($trackingNumber) {
                    $fulfillment->tracking_number = $trackingNumber;
                }
                if (!$fulfillment->courier_partner || $fulfillment->courier_partner !== 'Armada') {
                    $fulfillment->courier_partner = 'Armada';
                }
                
                // Get fulfillment flags from Armada status
                if ($status) {
                    $fulfillmentFlags = $this->getFulfillmentFlagsFromArmadaStatus($status);
                    $fulfillment->status = $status;
                    $fulfillment->is_ready = $fulfillmentFlags['is_ready'];
                    $fulfillment->is_dispatched = $fulfillmentFlags['is_dispatched'];
                    $fulfillment->in_transit = $fulfillmentFlags['in_transit'];
                    $fulfillment->is_delivered = $fulfillmentFlags['is_delivered'];
                    $fulfillment->is_rto = $fulfillmentFlags['is_rto'];
                    $fulfillment->is_rto_recieved = $fulfillmentFlags['is_rto_recieved'];
                    
                    // Update timestamps
                    $now = now();
                    if ($fulfillment->is_ready && !$fulfillment->is_ready_at) {
                        $fulfillment->is_ready_at = $now;
                    }
                    if ($fulfillment->is_dispatched && !$fulfillment->is_dispatched_at) {
                        $fulfillment->is_dispatched_at = $now;
                    }
                    if ($fulfillment->in_transit && !$fulfillment->in_transit_at) {
                        $fulfillment->in_transit_at = $now;
                    }
                    if ($fulfillment->is_delivered && !$fulfillment->is_delivered_at) {
                        $fulfillment->is_delivered_at = $now;
                    }
                    if ($fulfillment->is_rto && !$fulfillment->is_rto_at) {
                        $fulfillment->is_rto_at = $now;
                    }
                    if ($fulfillment->is_rto_recieved && !$fulfillment->is_rto_recieved_at) {
                        $fulfillment->is_rto_recieved_at = $now;
                    }
                }
                
                $fulfillment->save();
            }

            return [
                'success' => true,
                'message' => 'Webhook processed successfully',
            ];
        } catch (Exception $e) {
            Log::error('Armada Webhook Error', [
                'error' => $e->getMessage(),
                'webhook_data' => $webhookData,
            ]);

            return [
                'success' => false,
                'error' => $e->getMessage(),
            ];
        }
    }
}
