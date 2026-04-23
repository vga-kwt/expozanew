<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <title>Vendor Notification</title>
</head>
<body>
    <h1>Vendor Notification</h1>
    <p>Dear {{ $vendor_name ?? 'Vendor' }},</p>
    <p>{{ $message_body ?? 'No message' }}</p>
    <p>Order ID: #{{ $order_id ?? 'N/A' }}</p>
    <p>Order Date: {{ $order_date ?? 'N/A' }}</p>
    <p>Total Amount: ${{ $total_amount ?? '0.00' }}</p>
    <p>Status: {{ $order_status ?? 'Unknown' }}</p>
    <p>Customer Name: {{ $customer_name ?? 'N/A' }}</p>
    <p>Customer Email: {{ $customer_email ?? 'N/A' }}</p>
    <p>Customer Phone: {{ $customer_phone ?? 'Not provided' }}</p>
    <p>Best regards,<br>The Expo Team</p>
</body>
</html> 