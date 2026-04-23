<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Order Confirmed - Expoza</title>
    <style>
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            line-height: 1.6;
            color: #333;
            max-width: 600px;
            margin: 0 auto;
            padding: 20px;
            background-color: #f4f4f4;
        }
        .email-container {
            background-color: #ffffff;
            border-radius: 8px;
            padding: 30px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        .header {
            text-align: center;
            margin-bottom: 30px;
            padding-bottom: 20px;
            border-bottom: 2px solid #4CAF50;
        }
        .header h1 {
            color: #4CAF50;
            margin: 0;
            font-size: 28px;
        }
        .success-icon {
            font-size: 48px;
            margin-bottom: 10px;
        }
        .order-details {
            background-color: #f9f9f9;
            border-radius: 6px;
            padding: 20px;
            margin: 20px 0;
        }
        .order-details h2 {
            color: #333;
            font-size: 18px;
            margin-top: 0;
            margin-bottom: 15px;
        }
        .detail-row {
            display: flex;
            justify-content: space-between;
            padding: 8px 0;
            border-bottom: 1px solid #e0e0e0;
        }
        .detail-row:last-child {
            border-bottom: none;
        }
        .detail-label {
            font-weight: 600;
            color: #666;
        }
        .detail-value {
            color: #333;
        }
        .message {
            background-color: #e8f5e9;
            border-left: 4px solid #4CAF50;
            padding: 15px;
            margin: 20px 0;
            border-radius: 4px;
        }
        .footer {
            text-align: center;
            margin-top: 30px;
            padding-top: 20px;
            border-top: 1px solid #e0e0e0;
            color: #666;
            font-size: 14px;
        }
        .button {
            display: inline-block;
            background-color: #4CAF50;
            color: #ffffff;
            padding: 12px 30px;
            text-decoration: none;
            border-radius: 5px;
            margin: 20px 0;
            font-weight: 600;
        }
        .button:hover {
            background-color: #45a049;
        }
    </style>
</head>
<body>
    <div class="email-container">
        <div class="header">
            <div class="success-icon">✅</div>
            <h1>Order Confirmed!</h1>
        </div>

        <p>Dear <strong>{{ $user_name }}</strong>,</p>

        <div class="message">
            <p style="margin: 0; font-size: 16px;">
                <strong>Great news! Your order has been confirmed and is now being processed.</strong>
            </p>
        </div>

        <p>We're excited to let you know that your order has been confirmed and our team is preparing it for shipment. You'll receive another notification once your order is dispatched.</p>

        <div class="order-details">
            <h2>Order Details</h2>
            <div class="detail-row">
                <span class="detail-label">Order ID:</span>
                <span class="detail-value"><strong>#{{ str_pad($order_id, 4, '0', STR_PAD_LEFT) }}</strong></span>
            </div>
            <div class="detail-row">
                <span class="detail-label">Order Date:</span>
                <span class="detail-value">{{ $order_date }}</span>
            </div>
            <div class="detail-row">
                <span class="detail-label">Total Amount:</span>
                <span class="detail-value"><strong>KWD {{ $total_amount }}</strong></span>
            </div>
            <div class="detail-row">
                <span class="detail-label">Payment Status:</span>
                <span class="detail-value">{{ $payment_status }}</span>
            </div>
            @if(isset($vendor_name))
            <div class="detail-row">
                <span class="detail-label">Vendor:</span>
                <span class="detail-value">{{ $vendor_name }}</span>
            </div>
            @endif
        </div>

        <p>You can track your order status anytime from your account dashboard. If you have any questions or concerns, please don't hesitate to contact our support team.</p>

        <div style="text-align: center;">
            <a href="{{ $order_url }}" class="button">View Order Details</a>
        </div>

        <div class="footer">
            <p>Thank you for shopping with us!</p>
            <p><strong>The Expoza Team</strong></p>
            <p style="font-size: 12px; color: #999; margin-top: 20px;">
                This is an automated email. Please do not reply to this message.
            </p>
        </div>
    </div>
</body>
</html>

