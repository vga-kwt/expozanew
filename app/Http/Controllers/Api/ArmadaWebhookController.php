<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Api\Controller;
use App\Services\ArmadaService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;

class ArmadaWebhookController extends Controller
{
    protected $armadaService;

    public function __construct(ArmadaService $armadaService)
    {
        $this->armadaService = $armadaService;
    }

    /**
     * Handle webhook from Armada Delivery
     * 
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function handle(Request $request)
    {
        try {
            // Verify webhook signature if configured
            if (config('armada.webhook_secret')) {
                $signature = $request->header('X-Armada-Signature');
                if (!$this->verifySignature($request->all(), $signature)) {
                    return response()->json([
                        'success' => false,
                        'message' => 'Invalid signature',
                    ], 401);
                }
            }

            $webhookData = $request->all();
            
            Log::info('Armada Webhook Received', [
                'data' => $webhookData,
            ]);

            $result = $this->armadaService->handleWebhook($webhookData);

            if ($result['success']) {
                return response()->json([
                    'success' => true,
                    'message' => 'Webhook processed successfully',
                ]);
            }

            return response()->json([
                'success' => false,
                'message' => $result['error'] ?? 'Failed to process webhook',
            ], 400);

        } catch (\Exception $e) {
            Log::error('Armada Webhook Error', [
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString(),
            ]);

            return response()->json([
                'success' => false,
                'message' => 'Internal server error',
            ], 500);
        }
    }

    /**
     * Verify webhook signature
     * 
     * @param array $payload
     * @param string|null $signature
     * @return bool
     */
    protected function verifySignature(array $payload, ?string $signature): bool
    {
        if (!$signature) {
            return false;
        }

        $secret = config('armada.webhook_secret');
        $expectedSignature = hash_hmac('sha256', json_encode($payload), $secret);

        return hash_equals($expectedSignature, $signature);
    }
}