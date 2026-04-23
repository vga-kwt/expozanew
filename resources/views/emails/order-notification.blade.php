<!DOCTYPE html>
<html>

<head>
    <meta charset="utf-8">
    <title>Order Notification</title>
</head>

<body>
    <h1>Order Notification</h1>
    <p>Dear {{ $user_name }},</p>
    <p>{{ $message_body }}</p>
    <p>Order ID: #{{ $order_id }}</p>
    <p>Order Date: {{ $order_date }}</p>
    <p>Total Amount: ${{ $total_amount }}</p>
    <p>Status: {{ $order_status }}</p>
    <p>Best regards,<br>The Expo Team</p>
</body>

</html>
