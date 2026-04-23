# Armada API - Complete Order Management Flow

## Overview
यह document बताता है कि order confirmation के बाद complete flow कैसे Armada API के अनुसार चलेगा।

## Complete Flow

### 1. Order Confirmation (Admin/Vendor)

**Step 1: Admin/Vendor Order Confirm करता है**
```
POST /orders/{id}/confirm
```

**Step 2: System Actions:**
- ✅ Order status `pending` से `confirmed` हो जाता है
- ✅ Fulfillment record create होता है
- ✅ **Armada API में order create होता है** (अगर enabled है)
- ✅ Armada से response में status और tracking number मिलता है
- ✅ Order status Armada के status के अनुसार update होता है
- ✅ `armada_order_id`, `armada_tracking_number` save होते हैं
- ✅ `is_armada_synced = true` set होता है

**Step 3: After Confirmation:**
- Order अब Armada के control में है
- सभी status updates Armada से आएंगे (webhook या manual sync)

### 2. Status Updates Flow

#### Option A: Via Webhook (Automatic)
```
Armada → Webhook → Your System
```

1. Armada में status change होता है
2. Armada webhook send करता है: `POST /api/webhooks/armada`
3. System automatically order status update करता है

#### Option B: Via Manual Sync
```
Admin/Vendor → Sync Button → Armada API → Update Status
```

1. Admin/Vendor "Sync from Armada" button click करता है
2. System Armada API से latest status fetch करता है
3. Order status update होता है

#### Option C: Via Tracking Update (Auto-sync)
```
Order Details Page → Auto-fetch from Armada → Update Status
```

1. Order details page open होता है
2. System automatically Armada से tracking info fetch करता है
3. Status auto-update होता है

### 3. Status Mapping

| Armada Status | Local Order Status | Description |
|---------------|-------------------|-------------|
| `pending` | `pending` | Order created, waiting for confirmation |
| `confirmed` | `confirmed` | Order confirmed by vendor |
| `picked_up` | `processing` | Order picked up from vendor |
| `in_transit` | `shipped` | Order in transit |
| `out_for_delivery` | `out_for_delivery` | Out for delivery |
| `delivered` | `delivered` | Delivered to customer |
| `cancelled` | `cancelled` | Order cancelled |
| `failed` | `failed` | Delivery failed |
| `returned` | `returned` | Order returned |

### 4. Order Tracking

#### For Customers (API)
```
GET /api/orders/{id}/track
```

Response:
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
            "estimated_delivery": "2025-11-18 14:00:00",
            "history": [...]
        }
    }
}
```

#### For Admin/Vendor (Dashboard)
- Order details page में Armada tracking info automatically show होगा
- Real-time status updates
- Tracking number display
- Delivery timeline

### 5. Manual Status Updates

**Important:** अगर order Armada में synced है, तो manual status update करने पर:

1. System पहले Armada से latest status fetch करेगा
2. अगर Armada में status change हुआ है, तो वही status use होगा
3. अगर Armada में status same है, तो manual update Armada में भी sync होगा

### 6. Order Cancellation

**When order is cancelled:**
1. Local order status `cancelled` हो जाता है
2. Armada API में order cancel हो जाता है
3. Customer को notification मिलता है

## Implementation Details

### Order Confirmation Code Flow

```php
// 1. Order confirm होता है
$order->order_status = 'confirmed';

// 2. Armada में order create होता है
$armadaResult = $armadaService->createOrder($orderData);

// 3. Armada response से status update
$armadaStatus = $armadaResult['data']['status'];
$order->order_status = mapArmadaStatus($armadaStatus);
$order->armada_order_id = $armadaResult['armada_order_id'];
$order->armada_tracking_number = $armadaResult['tracking_number'];
$order->is_armada_synced = true;
```

### Status Update Code Flow

```php
// 1. Check if order is synced with Armada
if ($order->is_armada_synced) {
    // 2. Get latest status from Armada
    $armadaOrder = $armadaService->getOrder($order->armada_order_id);
    
    // 3. Update local status from Armada
    $order->order_status = mapArmadaStatus($armadaOrder['status']);
    $order->delivery_status = $armadaOrder['status'];
}
```

## Routes Added

### Admin Routes
```
POST /orders/{id}/sync-armada - Sync order status from Armada
```

### Vendor Routes
```
POST /vendor/orders/{id}/sync-armada - Sync order status from Armada
```

### API Routes
```
GET /api/orders/{id}/track - Track order via Armada
POST /api/webhooks/armada - Receive webhooks from Armada
```

## Database Fields

Orders table में निम्नलिखित fields use होते हैं:

- `armada_order_id` - Armada में order का unique ID
- `armada_tracking_number` - Tracking number
- `armada_response` - Complete API response (JSON)
- `is_armada_synced` - Order Armada में sync है या नहीं (boolean)
- `order_status` - Local order status (Armada status से mapped)
- `delivery_status` - Armada delivery status

## Best Practices

### 1. Always Sync from Armada
- Order details page open होने पर automatically sync करें
- Manual sync button provide करें
- Webhook setup करें for real-time updates

### 2. Error Handling
- अगर Armada API fail हो, तो local order still work करेगा
- Errors को logs में save करें
- Admin को error notifications दें

### 3. Status Priority
1. **Armada Status** (if synced) - Highest priority
2. **Webhook Updates** - Real-time
3. **Manual Sync** - On demand
4. **Local Status** - Fallback

## Testing Checklist

- [ ] Order confirmation creates order in Armada
- [ ] Status updates sync from Armada
- [ ] Tracking number is saved correctly
- [ ] Webhook receives and processes updates
- [ ] Manual sync works correctly
- [ ] Order cancellation works in Armada
- [ ] Error handling works properly
- [ ] Status mapping is correct

## Troubleshooting

### Order not syncing
1. Check `ARMADA_ENABLED=true` in `.env`
2. Verify API key and branch ID
3. Check if address is available
4. Check Laravel logs

### Status not updating
1. Verify order is synced (`is_armada_synced = true`)
2. Check `armada_order_id` is present
3. Try manual sync
4. Check webhook is configured

### Tracking not working
1. Verify `armada_tracking_number` is saved
2. Check API key has tracking permissions
3. Test tracking API manually

---

**Note:** यह flow ensure करता है कि order confirmation के बाद सब कुछ Armada API के अनुसार चले।
