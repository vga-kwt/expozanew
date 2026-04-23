-- ============================================
-- Armada Order Verification SQL Queries
-- ============================================

-- Query 1: Check All Orders with Armada Data
-- यह query सभी orders दिखाती है जो Armada में sync हैं
SELECT 
    id,
    order_code,
    armada_order_id,
    armada_tracking_number,
    is_armada_synced,
    order_status,
    delivery_status,
    JSON_EXTRACT(armada_response, '$.code') as armada_code,
    JSON_EXTRACT(armada_response, '$.orderStatus') as armada_status,
    JSON_EXTRACT(armada_response, '$.trackingLink') as tracking_link,
    created_at
FROM orders
WHERE is_armada_synced = 1
ORDER BY created_at DESC
LIMIT 20;

-- Query 2: Check Specific Order by ID
-- Replace [ORDER_ID] with actual order ID
SELECT 
    o.id,
    o.order_code,
    o.armada_order_id,
    o.armada_tracking_number,
    o.is_armada_synced,
    o.order_status,
    o.delivery_status,
    JSON_PRETTY(o.armada_response) as armada_response_json,
    f.tracking_number as fulfillment_tracking,
    f.courier_partner,
    f.status as fulfillment_status
FROM orders o
LEFT JOIN fulfillments f ON f.order_id = o.id
WHERE o.id = [ORDER_ID];

-- Query 3: Check Recent Armada Orders with Fulfillment Details
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
    f.status as fulfillment_status,
    CASE 
        WHEN f.tracking_number = o.armada_tracking_number THEN '✅ MATCH'
        ELSE '❌ MISMATCH'
    END as tracking_match,
    o.created_at
FROM orders o
LEFT JOIN fulfillments f ON f.order_id = o.id
WHERE o.is_armada_synced = 1
ORDER BY o.created_at DESC
LIMIT 10;

-- Query 4: Check Orders with Armada Response Details
SELECT 
    id,
    order_code,
    armada_order_id,
    JSON_EXTRACT(armada_response, '$.code') as response_code,
    JSON_EXTRACT(armada_response, '$.orderStatus') as response_status,
    JSON_EXTRACT(armada_response, '$.trackingLink') as tracking_link,
    JSON_EXTRACT(armada_response, '$.qrCodeLink') as qr_code_link,
    JSON_EXTRACT(armada_response, '$.deliveryFee') as delivery_fee,
    JSON_EXTRACT(armada_response, '$.amount') as amount,
    JSON_EXTRACT(armada_response, '$.customerName') as customer_name,
    JSON_EXTRACT(armada_response, '$.customerPhone') as customer_phone,
    created_at
FROM orders
WHERE armada_order_id IS NOT NULL
ORDER BY created_at DESC
LIMIT 10;

-- Query 5: Check Failed Syncs (Orders that should be synced but aren't)
SELECT 
    id,
    order_code,
    armada_order_id,
    is_armada_synced,
    order_status,
    created_at,
    TIMESTAMPDIFF(MINUTE, created_at, NOW()) as minutes_ago
FROM orders
WHERE is_armada_synced = 0 
  AND order_status IN ('confirmed', 'pending')
  AND created_at > DATE_SUB(NOW(), INTERVAL 24 HOUR)
ORDER BY created_at DESC;

-- Query 6: Verify Fulfillment Data Matches Order Data
SELECT 
    f.id as fulfillment_id,
    f.order_id,
    o.order_code,
    f.tracking_number as fulfillment_tracking,
    o.armada_tracking_number as order_tracking,
    f.courier_partner,
    f.status as fulfillment_status,
    o.delivery_status as order_delivery_status,
    CASE 
        WHEN f.tracking_number = o.armada_tracking_number THEN '✅ MATCH'
        ELSE '❌ MISMATCH'
    END as tracking_match,
    CASE 
        WHEN f.courier_partner = 'Armada' THEN '✅ CORRECT'
        ELSE '❌ WRONG'
    END as courier_match
FROM fulfillments f
JOIN orders o ON o.id = f.order_id
WHERE o.is_armada_synced = 1
ORDER BY f.created_at DESC
LIMIT 20;

-- Query 7: Count Orders by Sync Status
SELECT 
    CASE 
        WHEN is_armada_synced = 1 THEN '✅ Synced'
        ELSE '❌ Not Synced'
    END as sync_status,
    COUNT(*) as total_orders,
    COUNT(CASE WHEN order_status = 'confirmed' THEN 1 END) as confirmed,
    COUNT(CASE WHEN order_status = 'pending' THEN 1 END) as pending,
    COUNT(CASE WHEN order_status = 'delivered' THEN 1 END) as delivered
FROM orders
WHERE created_at > DATE_SUB(NOW(), INTERVAL 7 DAY)
GROUP BY is_armada_synced;

-- Query 8: Check Orders Missing Armada Data
SELECT 
    id,
    order_code,
    armada_order_id,
    armada_tracking_number,
    is_armada_synced,
    order_status,
    created_at
FROM orders
WHERE (armada_order_id IS NULL 
   OR armada_tracking_number IS NULL 
   OR is_armada_synced = 0)
  AND order_status IN ('confirmed', 'pending')
  AND created_at > DATE_SUB(NOW(), INTERVAL 24 HOUR)
ORDER BY created_at DESC;

-- Query 9: Get Full Armada Response for Specific Order
-- Replace [ORDER_ID] with actual order ID
SELECT 
    id,
    order_code,
    armada_order_id,
    JSON_PRETTY(armada_response) as full_armada_response
FROM orders
WHERE id = [ORDER_ID]
  AND armada_response IS NOT NULL;

-- Query 10: Check Orders by Armada Status
SELECT 
    JSON_EXTRACT(armada_response, '$.orderStatus') as armada_status,
    COUNT(*) as count,
    GROUP_CONCAT(order_code ORDER BY created_at DESC SEPARATOR ', ') as order_codes
FROM orders
WHERE armada_response IS NOT NULL
  AND created_at > DATE_SUB(NOW(), INTERVAL 7 DAY)
GROUP BY JSON_EXTRACT(armada_response, '$.orderStatus')
ORDER BY count DESC;

-- Query 11: Check Tracking Links
SELECT 
    id,
    order_code,
    armada_order_id,
    JSON_EXTRACT(armada_response, '$.trackingLink') as tracking_link,
    JSON_EXTRACT(armada_response, '$.qrCodeLink') as qr_code_link,
    created_at
FROM orders
WHERE armada_response IS NOT NULL
  AND JSON_EXTRACT(armada_response, '$.trackingLink') IS NOT NULL
ORDER BY created_at DESC
LIMIT 10;

-- Query 12: Summary Report
SELECT 
    COUNT(*) as total_orders,
    COUNT(CASE WHEN is_armada_synced = 1 THEN 1 END) as synced_orders,
    COUNT(CASE WHEN is_armada_synced = 0 THEN 1 END) as not_synced,
    COUNT(CASE WHEN armada_order_id IS NOT NULL THEN 1 END) as has_armada_id,
    COUNT(CASE WHEN armada_tracking_number IS NOT NULL THEN 1 END) as has_tracking,
    COUNT(CASE WHEN armada_response IS NOT NULL THEN 1 END) as has_response,
    ROUND(COUNT(CASE WHEN is_armada_synced = 1 THEN 1 END) * 100.0 / COUNT(*), 2) as sync_percentage
FROM orders
WHERE created_at > DATE_SUB(NOW(), INTERVAL 7 DAY);

