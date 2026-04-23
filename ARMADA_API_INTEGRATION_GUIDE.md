# Armada API Integration Guide

## Overview
यह guide आपको Armada Delivery API को आपके Expoza project में integrate करने में मदद करेगा।

## Installation Steps

### Step 1: Environment Variables Setup

`.env` file में निम्नलिखित variables add करें:

```env
# Armada API Configuration
ARMADA_ENABLED=true
ARMADA_BASE_URL=https://api.armada.delivery
ARMADA_API_KEY=your_api_key_here
ARMADA_BRANCH_ID=your_branch_id_here
ARMADA_TIMEOUT=30
ARMADA_WEBHOOK_SECRET=your_webhook_secret_here
ARMADA_WEBHOOK_URL=/api/webhooks/armada
ARMADA_DEFAULT_CURRENCY=KWD
ARMADA_DEFAULT_COUNTRY=KW
```

### Step 2: Run Migration

```bash
php artisan migrate
```

यह migration `orders` table में निम्नलिखित fields add करेगी:
- `armada_order_id` - Armada में order का ID
- `armada_tracking_number` - Tracking number
- `armada_response` - Armada API का complete response (JSON)
- `is_armada_synced` - Order Armada में sync है या नहीं

### Step 3: Clear Config Cache

```bash
php artisan config:clear
php artisan config:cache
```

## Features

### 1. Automatic Order Creation
जब भी कोई order create होगा, automatically Armada API में order create हो जाएगा (अगर `ARMADA_ENABLED=true` है)।

### 2. Order Tracking
Customers अपने orders को track कर सकते हैं:
```
GET /api/orders/{id}/track
```

### 3. Order Cancellation
Order cancel करने पर automatically Armada में भी cancel हो जाएगा।

### 4. Webhook Support
Armada से status updates receive करने के लिए webhook endpoint:
```
POST /api/webhooks/armada
```

## API Endpoints

### Order Tracking
```http
GET /api/orders/{id}/track
Authorization: Bearer {token}
```

**Response:**
```json
{
    "success": true,
    "data": {
        "order": {
            "id": 1,
            "order_code": "0001",
            "order_status": "out_for_delivery",
            "armada_tracking_number": "TRACK123456"
        },
        "tracking": {
            "status": "out_for_delivery",
            "location": "Kuwait City",
            "estimated_delivery": "2025-11-18 14:00:00"
        }
    }
}
```

### Webhook Endpoint
```http
POST /api/webhooks/armada
Content-Type: application/json
X-Armada-Signature: {signature}
```

## Configuration

### Country Code Mapping
`config/armada.php` में country codes map करें:
```php
'country_codes' => [
    'Kuwait' => 'KW',
    'Bahrain' => 'BH',
    'Saudi Arabia' => 'SA',
    // Add more as needed
],
```

### Payment Method Mapping
```php
'payment_methods' => [
    'cash_on_delivery' => 'cod',
    'knet' => 'knet',
    'credit_card' => 'card',
    // Add more as needed
],
```

### Status Mapping
```php
'status_mapping' => [
    'pending' => 'pending',
    'confirmed' => 'confirmed',
    'picked_up' => 'processing',
    'in_transit' => 'shipped',
    'out_for_delivery' => 'out_for_delivery',
    'delivered' => 'delivered',
    'cancelled' => 'cancelled',
    'failed' => 'failed',
    'returned' => 'returned',
],
```

## Testing

### Test Order Creation
```bash
php artisan tinker
```

```php
$order = \App\Models\Order::find(1);
$address = \App\Models\Address::find(1);
$armadaService = app(\App\Services\ArmadaService::class);
$orderData = $armadaService->prepareOrderData($order, $address);
$result = $armadaService->createOrder($orderData);
print_r($result);
```

### Test Order Tracking
```php
$armadaService = app(\App\Services\ArmadaService::class);
$result = $armadaService->trackOrder('TRACK123456');
print_r($result);
```

## Troubleshooting

### Issue: Orders not syncing with Armada
**Solution:**
1. Check if `ARMADA_ENABLED=true` in `.env`
2. Verify API key and branch ID
3. Check Laravel logs: `storage/logs/laravel.log`

### Issue: Webhook not receiving updates
**Solution:**
1. Verify webhook URL in Armada dashboard
2. Check webhook secret configuration
3. Ensure webhook endpoint is publicly accessible

### Issue: Tracking not working
**Solution:**
1. Verify order has `armada_tracking_number` or `armada_order_id`
2. Check if `is_armada_synced` is `true`
3. Verify API key has tracking permissions

## Webhook Setup in Armada Dashboard

1. Login to Armada Merchant Dashboard
2. Go to Settings → API Settings
3. Add webhook URL: `https://yourdomain.com/api/webhooks/armada`
4. Set webhook secret (same as `ARMADA_WEBHOOK_SECRET` in `.env`)
5. Enable webhook events:
   - Order Status Updated
   - Order Delivered
   - Order Cancelled

## Order Status Flow

```
pending → confirmed → processing → shipped → out_for_delivery → delivered
                                                      ↓
                                                 cancelled/failed/returned
```

## Support

अगर कोई issue आए तो:
1. Check Laravel logs: `storage/logs/laravel.log`
2. Check Armada API documentation
3. Verify all environment variables are set correctly

## Files Created/Modified

### New Files:
- `app/Services/ArmadaService.php` - Main service class
- `config/armada.php` - Configuration file
- `app/Http/Controllers/Api/ArmadaWebhookController.php` - Webhook handler
- `database/migrations/xxxx_add_armada_fields_to_orders_table.php` - Migration

### Modified Files:
- `app/Models/Order.php` - Added Armada fields
- `app/Http/Controllers/Api/OrderController.php` - Added tracking and cancellation
- `app/Http/Controllers/Api/CheckoutController.php` - Added Armada integration
- `routes/api.php` - Added webhook and tracking routes

---

**Note**: Production में deploy करने से पहले test environment में properly test करें।
