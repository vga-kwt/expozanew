# Armada API Integration - Admin & Vendor Dashboard

## Overview
Armada API integration को Admin और Vendor dashboard के order management में add किया गया है। अब जब भी order confirm होगा या status update होगा, automatically Armada API में sync होगा।

## Features Added

### 1. Order Confirmation Integration
जब Admin या Vendor order confirm करते हैं:
- Order `pending` से `confirmed` हो जाता है
- अगर order पहले से Armada में sync नहीं है, तो automatically Armada में order create होगा
- अगर order पहले से sync है, तो status update होगा

### 2. Order Status Update Integration
जब order status update होता है (processing, shipped, delivered, etc.):
- Status automatically Armada API में sync होगा
- Real-time tracking updates मिलेंगे

### 3. Order Cancellation Integration
जब order cancel होता है:
- Armada API में भी order cancel हो जाएगा
- Customer को notification मिलेगा

## Modified Files

### `app/Http/Controllers/OrderController.php`
- `confirm()` method में Armada integration add की गई
- `updateTracking()` method में status sync add किया गया
- `cancel()` method में Armada cancellation add किया गया
- `mapOrderStatusToArmadaStatus()` helper method add किया गया

## How It Works

### Order Confirmation Flow

1. **Admin/Vendor clicks "Confirm Order"**
   ```
   POST /orders/{id}/confirm
   ```

2. **System checks:**
   - Order status is `pending`
   - Armada is enabled (`ARMADA_ENABLED=true`)
   - Order is not already synced

3. **If not synced:**
   - Get customer address
   - Prepare order data for Armada
   - Create order in Armada API
   - Save Armada order ID and tracking number

4. **If already synced:**
   - Update order status in Armada to `confirmed`

### Status Update Flow

1. **Admin/Vendor updates order status**
   ```
   POST /orders/{order}/tracking-update
   ```

2. **System:**
   - Updates local order status
   - Maps status to Armada format
   - Updates status in Armada API

### Status Mapping

| Local Status | Armada Status |
|-------------|---------------|
| pending | pending |
| confirmed | confirmed |
| processing | picked_up |
| shipped | in_transit |
| out_for_delivery | out_for_delivery |
| delivered | delivered |
| cancelled | cancelled |
| failed | failed |
| returned | returned |

## Configuration

### Environment Variables
```env
ARMADA_ENABLED=true
ARMADA_BASE_URL=https://api.armada.delivery
ARMADA_API_KEY=your_api_key_here
ARMADA_BRANCH_ID=your_branch_id_here
```

### Enable/Disable
अगर आप temporarily Armada integration disable करना चाहते हैं:
```env
ARMADA_ENABLED=false
```

## Testing

### Test Order Confirmation
1. Admin/Vendor dashboard में जाएं
2. एक pending order select करें
3. "Confirm Order" button click करें
4. Check करें:
   - Order status `confirmed` हो गया
   - `armada_order_id` database में save हुआ
   - `is_armada_synced` = `true`

### Test Status Update
1. Order details page में जाएं
2. Tracking status update करें
3. Check करें:
   - Local status update हुआ
   - Armada API में भी status update हुआ

### Check Logs
```bash
tail -f storage/logs/laravel.log
```

## Error Handling

### If Armada API Fails
- Order confirmation/update still succeeds locally
- Error is logged in Laravel logs
- Admin/Vendor को error message नहीं दिखेगा (silent failure)
- Order manually sync करने का option available है

### Common Issues

**Issue: Order not syncing**
- Check `ARMADA_ENABLED=true` in `.env`
- Verify API key and branch ID
- Check Laravel logs for errors
- Ensure customer address is available

**Issue: Status not updating**
- Verify order is already synced (`is_armada_synced = true`)
- Check `armada_order_id` is present
- Verify API key has update permissions

## Database Fields

Orders table में निम्नलिखित fields add किए गए:
- `armada_order_id` - Armada में order का unique ID
- `armada_tracking_number` - Tracking number
- `armada_response` - Complete API response (JSON)
- `is_armada_synced` - Sync status (boolean)

## API Endpoints Used

### Create Order
```
POST /api/v1/orders
```

### Update Order Status
```
PUT /api/v1/orders/{id}/status
```

### Cancel Order
```
POST /api/v1/orders/{id}/cancel
```

## Frontend Integration

Frontend में कोई changes की जरूरत नहीं है। Existing buttons और forms same तरीके से काम करेंगे, बस backend में automatically Armada sync होगा।

## Next Steps

1. **Test thoroughly** in staging environment
2. **Monitor logs** for any errors
3. **Verify** orders are syncing correctly
4. **Check** tracking numbers are being saved
5. **Test** webhook integration for status updates

## Support

अगर कोई issue आए:
1. Check Laravel logs: `storage/logs/laravel.log`
2. Verify environment variables
3. Test API connection manually
4. Check Armada dashboard for order status

---

**Note**: Production में deploy करने से पहले test environment में properly test करें।
