<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <title>Order Invoice</title>
    <style>
        body { font-family: DejaVu Sans, sans-serif; color: #222; }
        .header { text-align: center; margin-bottom: 30px; }
        .title { font-size: 24px; font-weight: bold; }
        .info-table, .products-table { width: 100%; border-collapse: collapse; margin-bottom: 20px; }
        .info-table td { padding: 4px 8px; }
        .products-table th, .products-table td { border: 1px solid #ddd; padding: 8px; }
        .products-table th { background: #f5f5f5; }
        .total { text-align: right; font-size: 18px; font-weight: bold; }
    </style>
</head>
<body>
    <div class="header">
        <div class="title">Order Invoice</div>
        <div>Order ID: <strong>{{ $order->id }}</strong></div>
        <div>Date: <strong>{{ $order->created_at->format('d M Y, H:i') }}</strong></div>
    </div>
    <table class="info-table">
        <tr>
            <td><strong>User Name:</strong></td>
            <td>{{ $order->user->full_name }}</td>
        </tr>
        <tr>
            <td><strong>User Email:</strong></td>
            <td>{{ $order->user->email }}</td>
        </tr>
        <tr>
            <td><strong>Status:</strong></td>
            <td>{{ ucfirst($order->order_status) }}</td>
        </tr>
    </table>
    <table class="products-table">
        <thead>
            <tr>
                <th>Product</th>
                <th>Quantity</th>
                <th>Price</th>
                <th>Subtotal</th>
            </tr>
        </thead>
        <tbody>
            @foreach($order->orderItems as $item)
                <tr>
                    <td>{{ $item->product->name_en }}</td>
                    <td>{{ $item->quantity }}</td>
                    <td>₹{{ number_format($item->price, 2) }}</td>
                    <td>₹{{ number_format($item->total_amount, 2) }}</td>
                </tr>
            @endforeach
        </tbody>
    </table>
    <div class="total">
        Total Amount: ₹{{ number_format($order->total_amount, 2) }}
    </div>
</body>
</html> 