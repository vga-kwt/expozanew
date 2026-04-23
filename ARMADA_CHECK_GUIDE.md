# Armada Create Order - Verification Guide

यह guide आपको बताता है कि Armada Create Order सही तरीके से काम कर रहा है या नहीं, इसकी जांच कैसे करें।

## 📋 Table of Contents
1. [Log Files में Check करना](#1-log-files-में-check-करना)
2. [Database में Check करना](#2-database-में-check-करना)
3. [Success Indicators](#3-success-indicators)
4. [Error Indicators](#4-error-indicators)
5. [SQL Queries for Verification](#5-sql-queries-for-verification)

---

## 1. Log Files में Check करना

### Location
```
storage/logs/laravel.log
```

### Step-by-Step Log Check

#### Step 1: ArmadaService Initialization
```
[timestamp] local.INFO: ArmadaService initialized
```
**Check करें:**
- ✅ `api_key_set: true` - API key set है
- ✅ `branch_id: "NAQSH"` - Branch ID set है
- ✅ `base_url` correct है

**Example:**
```json
{
  "base_url": "https://staging.api.armadadelivery.com",
  "api_key_set": true,
  "api_key_type": "api_key",
  "api_key_preview": "d9049c2d-37af-4...",
  "branch_id": "NAQSH"
}
```

#### Step 2: Order Data Preparation
```
[timestamp] local.INFO: Prepared Armada Order Data
```
**Check करें:**
- ✅ Order ID और Order Code present हैं
- ✅ Customer name, phone, address correct हैं
- ✅ Amount correct है
- ✅ Payment type correct है

**Example:**
```json
{
  "order_id": 56,
  "order_code": "0056",
  "armada_order_data": {
    "platformName": "expoza",
    "platformData": {
      "orderId": "0056",
      "name": "Miss Ally Medhurst III",
      "phone": "+965936-512-7343",
      "area": "Al Asimah",
      "street": "8010 Ziemann Ridge Suite 012",
      "amount": "2460.000",
      "paymentType": "paid"
    },
    "branchId": "NAQSH"
  }
}
```

#### Step 3: API Request
```
[timestamp] local.INFO: Armada Create Order Request
```
**Check करें:**
- ✅ URL correct है: `https://staging.api.armadadelivery.com/v0/deliveries`
- ✅ `api_key: "SET"` - API key present है
- ✅ Order data complete है

#### Step 4: API Response
```
[timestamp] local.INFO: Armada Create Order Response
```
**Check करें:**
- ✅ `status_code: 200` - Success response
- ✅ `successful: true` - Request successful
- ✅ Response में `code` field present है (यह tracking number है)

**Important Fields in Response:**
```json
{
  "code": "3DF774BA2F",  // ← Armada Order ID / Tracking Number
  "deliveryFee": 2,
  "amount": 2460,
  "orderStatus": "pending",
  "trackingLink": "https://staging.tracking.armadadelivery.com/...",
  "qrCodeLink": "https://armada-sand.s3.eu-central-1.amazonaws.com/...",
  "customerAddress": "...",
  "customerLocation": {
    "latitude": 29.3342457,
    "longitude": 47.9812152
  }
}
```

#### Step 5: Database Update Confirmation
```
[timestamp] local.INFO: Order updated with Armada data in database
```
**Check करें:**
- ✅ `armada_order_id` present है
- ✅ `armada_tracking_number` present है
- ✅ `is_armada_synced: true` - Sync successful
- ✅ `armada_response_stored: true` - Response stored
- ✅ `armada_response_keys` में सभी fields present हैं

**Example:**
```json
{
  "order_id": 56,
  "armada_order_id": "3DF774BA2F",
  "armada_tracking_number": "3DF774BA2F",
  "is_armada_synced": true,
  "armada_response_stored": true,
  "armada_response_keys": [
    "code",
    "deliveryFee",
    "amount",
    "customerAddress",
    "customerLocation",
    "customerName",
    "customerPhone",
    "orderStatus",
    "estimatedDistance",
    "estimatedDuration",
    "driver",
    "trackingLink",
    "qrCodeLink",
    "orderCreatedAt",
    "currency"
  ]
}
```

#### Step 6: Fulfillment Update
```
[timestamp] local.INFO: Fulfillment updated with Armada data
```
**Check करें:**
- ✅ `tracking_number` set है
- ✅ `courier_partner: "Armada"` - Correct partner
- ✅ `saved: true` - Fulfillment saved

---

## 2. Database में Check करना

### Orders Table में Check करें

#### Required Columns:
- `armada_order_id` - Armada का order ID (e.g., "3DF774BA2F")
- `armada_tracking_number` - Tracking number (same as armada_order_id)
- `armada_response` - Complete JSON response
- `is_armada_synced` - Should be `1` (true) if successful

### Fulfillments Table में Check करें

#### Required Fields:
- `tracking_number` - Should match `armada_tracking_number`
- `courier_partner` - Should be "Armada"
- `status` - Delivery status from Armada

---

## 3. Success Indicators

### ✅ Success के लिए ये सभी True होने चाहिए:

1. **Log में Success Messages:**
   - ✅ "ArmadaService initialized" with `api_key_set: true`
   - ✅ "Prepared Armada Order Data" with complete data
   - ✅ "Armada Create Order Response" with `status_code: 200`
   - ✅ "Armada Order Created Successfully"
   - ✅ "Order updated with Armada data in database" with `armada_response_stored: true`
   - ✅ "Fulfillment updated with Armada data" with `saved: true`

2. **Database में:**
   - ✅ `orders.armada_order_id` is NOT NULL
   - ✅ `orders.armada_tracking_number` is NOT NULL
   - ✅ `orders.is_armada_synced` = 1 (true)
   - ✅ `orders.armada_response` contains JSON data
   - ✅ `fulfillments.tracking_number` matches `armada_tracking_number`
   - ✅ `fulfillments.courier_partner` = "Armada"

3. **Response में:**
   - ✅ `code` field present (Armada Order ID)
   - ✅ `trackingLink` present
   - ✅ `qrCodeLink` present
   - ✅ `orderStatus` present

---

## 4. Error Indicators

### ❌ Error के लिए ये Check करें:

1. **API Key Issues:**
   ```
   "api_key_set": false
   ```
   **Solution:** Check `.env` file में `ARMADA_API_KEY` set है या नहीं

2. **Branch ID Missing:**
   ```
   "branch_id": null
   ```
   **Solution:** Check `.env` file में `ARMADA_BRANCH_ID` set है या नहीं

3. **API Error Response:**
   ```
   "status_code": 400, 401, 403, 500, etc.
   "successful": false
   ```
   **Solution:** Check error message in log for details

4. **Address Not Found:**
   ```
   "Address search from user default": {"address_found": false}
   ```
   **Solution:** Ensure user has a valid address

5. **Database Update Failed:**
   ```
   "armada_response_stored": false
   ```
   **Solution:** Check database connection and table structure

---

## 5. SQL Queries for Verification

### Query 1: Check Orders with Armada Data
```sql
SELECT 
    id,
    order_code,
    armada_order_id,
    armada_tracking_number,
    is_armada_synced,
    JSON_EXTRACT(armada_response, '$.code') as armada_code,
    JSON_EXTRACT(armada_response, '$.orderStatus') as armada_status,
    JSON_EXTRACT(armada_response, '$.trackingLink') as tracking_link,
    created_at
FROM orders
WHERE is_armada_synced = 1
ORDER BY created_at DESC
LIMIT 10;
```

### Query 2: Check Recent Armada Orders
```sql
SELECT 
    o.id,
    o.order_code,
    o.armada_order_id,
    o.armada_tracking_number,
    o.is_armada_synced,
    o.order_status,
    o.delivery_status,
    f.tracking_number as fulfillment_tracking,
    f.courier_partner,
    f.status as fulfillment_status
FROM orders o
LEFT JOIN fulfillments f ON f.order_id = o.id
WHERE o.is_armada_synced = 1
ORDER BY o.created_at DESC
LIMIT 10;
```

### Query 3: Check Armada Response Data
```sql
SELECT 
    id,
    order_code,
    armada_order_id,
    JSON_PRETTY(armada_response) as armada_response_json
FROM orders
WHERE armada_order_id IS NOT NULL
ORDER BY created_at DESC
LIMIT 5;
```

### Query 4: Check Failed Syncs
```sql
SELECT 
    id,
    order_code,
    armada_order_id,
    is_armada_synced,
    order_status,
    created_at
FROM orders
WHERE is_armada_synced = 0 
  AND order_status = 'confirmed'
  AND created_at > DATE_SUB(NOW(), INTERVAL 24 HOUR)
ORDER BY created_at DESC;
```

### Query 5: Verify Fulfillment Data
```sql
SELECT 
    f.id,
    f.order_id,
    o.order_code,
    f.tracking_number,
    f.courier_partner,
    f.status,
    o.armada_tracking_number,
    CASE 
        WHEN f.tracking_number = o.armada_tracking_number THEN 'MATCH'
        ELSE 'MISMATCH'
    END as tracking_match
FROM fulfillments f
JOIN orders o ON o.id = f.order_id
WHERE f.courier_partner = 'Armada'
ORDER BY f.created_at DESC
LIMIT 10;
```

---

## 6. Quick Verification Checklist

### After Order Confirmation, Check:

- [ ] Log file में "ArmadaService initialized" message है
- [ ] Log file में "Prepared Armada Order Data" message है
- [ ] Log file में "Armada Create Order Response" with status_code: 200 है
- [ ] Log file में "Order updated with Armada data in database" message है
- [ ] Log में `armada_response_stored: true` है
- [ ] Database में `orders.armada_order_id` NOT NULL है
- [ ] Database में `orders.armada_tracking_number` NOT NULL है
- [ ] Database में `orders.is_armada_synced` = 1 है
- [ ] Database में `fulfillments.tracking_number` matches है
- [ ] Database में `fulfillments.courier_partner` = "Armada" है

---

## 7. Common Issues & Solutions

### Issue 1: API Key Not Set
**Symptom:** `api_key_set: false` in logs
**Solution:** 
```env
ARMADA_API_KEY=your-api-key-here
ARMADA_BRANCH_ID=NAQSH
```

### Issue 2: Address Not Found
**Symptom:** `address_found: false` in logs
**Solution:** Ensure user has a default address or address_id in order

### Issue 3: Response Not Stored
**Symptom:** `armada_response_stored: false` in logs
**Solution:** Check if `armada_response` column exists in orders table

### Issue 4: Order Status Overwritten
**Symptom:** Order status becomes "pending" after confirmation
**Solution:** Already fixed - order_status won't be overwritten if already "confirmed"

---

## 8. Testing Steps

1. **Create a Test Order:**
   - Go to checkout
   - Complete order with valid address
   - Confirm order

2. **Check Logs:**
   ```bash
   tail -f storage/logs/laravel.log | grep -i armada
   ```

3. **Check Database:**
   ```sql
   SELECT * FROM orders WHERE id = [ORDER_ID];
   SELECT * FROM fulfillments WHERE order_id = [ORDER_ID];
   ```

4. **Verify Tracking:**
   - Check `armada_response` JSON में `trackingLink` है
   - Open tracking link in browser
   - Verify order appears in Armada dashboard

---

## 9. Log Message Flow (Complete Sequence)

```
1. Address search from user default
2. ArmadaService initialized
3. Prepared Armada Order Data
4. Armada Create Order Request
5. Armada API Request Headers
6. Armada Create Order Response (status_code: 200)
7. Armada Order Created Successfully
8. Armada Create Order Result
9. Armada API Response
10. Order updated with Armada data in database
11. Fulfillment updated with Armada data
12. Order created in Armada successfully with tracking
```

अगर ये सभी messages log में दिख रहे हैं, तो Armada Create Order successfully complete हो गया है! ✅

