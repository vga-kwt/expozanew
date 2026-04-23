<?php

namespace App\Http\Controllers;

use App\Models\User;
use App\Models\Order;
use Illuminate\Http\Request;
use Inertia\Inertia;
use Illuminate\Support\Facades\Response;

class UserController extends Controller
{
    // List & search users
    public function index(Request $request)
    {
        $query = User::query();

        // Only get users with role 'user'
        $query->where('role', 'user');

        // Search functionality
        if ($search = $request->input('search')) {
            $query->where(function ($q) use ($search) {
                $q->where('full_name', 'like', "%$search%")
                    ->orWhere('email', 'like', "%$search%")
                    ->orWhere('phone', 'like', "%$search%")
                ;
            });
        }

        // Status filter (robust, matches OrdersController)
        $status = $request->input('status');
        if (!empty($status)) {
            $query->where('status', $status);
        }

        // Date filter (orders created_at)
        $fromDate = $request->input('fromDate');
        $toDate = $request->input('toDate');
        if ($fromDate || $toDate) {
            $query->whereHas('orders', function ($q) use ($fromDate, $toDate) {
                if ($fromDate) {
                    $q->whereDate('created_at', '>=', $fromDate);
                }
                if ($toDate) {
                    $q->whereDate('created_at', '<=', $toDate);
                }
            });
        }

        // Add order statistics with proper relationship loading
        $query->withCount(['orders as total_orders'])
            ->withSum(['orders as total_spent'], 'total_amount')
            ->with(['orders' => function($q) {
                $q->select('id', 'user_id', 'order_status', 'total_amount', 'created_at', 'vendor_id')
                    ->with(['vendor:id,name', 'fulfillments' => function($q2) { $q2->latest(); }]);
            }]);

        $users = $query->orderByDesc('id')->paginate(10)->withQueryString();

        // Add tracking info to each user's orders
        $users->getCollection()->transform(function ($user) {
            if ($user->orders) {
                foreach ($user->orders as $order) {
                    $latestFulfillment = $order->fulfillments->first(); // already sorted latest
                    $order->tracking = $latestFulfillment ? [
                        'tracking_number' => $latestFulfillment->tracking_number ?? null,
                        'tracking_url' => $latestFulfillment->tracking_url ?? null,
                        'delivery_status' => $latestFulfillment->status ?? null,
                    ] : null;
                }
            }
            return $user;
        });

        return Inertia::render('Users/Index', [
            'users' => $users,
            'filters' => $request->only(['search', 'status', 'fromDate', 'toDate'])
        ]);
    }

    // Show user profile + order history
    public function show(Request $request, User $user)
    {
        $ordersQuery = Order::where('user_id', $user->id)
            ->with([
                'vendor:id,name,email,mobile,user_id',
                'vendor.user.addresses' => function($q) { 
                    $q->where('role_name', 'vendor')->with(['country', 'state', 'city']); 
                },
                'user',
                'user.addresses' => function($q) { 
                    $q->where('is_default', true)->with(['country', 'state', 'city']); 
                },
                'fulfillments',
                'orderItems.product' // ensure order items and their products are loaded
            ]);

        if ($search = $request->input('search')) {
            $ordersQuery->where(function ($q) use ($search) {
                $q->where('order_code', 'like', "%$search%")
                    ->orWhere('order_status', 'like', "%$search%")
                    ->orWhereDate('created_at', $search);
            });
        }

        $orders = $ordersQuery->orderByDesc('id')->paginate(10);

        // Add customer fields and products to each order
        $orders->getCollection()->transform(function ($order) {
            $user = $order->user;
            $defaultAddress = $user && $user->addresses ? $user->addresses->where('is_default', true)->first() : null;
            $order->customer_name = $user ? $user->full_name : null;
            $order->customer_email = $user ? $user->email : null;
            $order->customer_mobile = $user ? $user->phone : null;
            $order->customer_address = $defaultAddress ? (
                $defaultAddress->line_1 . 
                ($defaultAddress->line_2 ? ', ' . $defaultAddress->line_2 : '') . 
                ($defaultAddress->city ? ', ' . (is_object($defaultAddress->city) && isset($defaultAddress->city->name_en) ? $defaultAddress->city->name_en : (is_string($defaultAddress->city) ? $defaultAddress->city : '')) : '') .
                ($defaultAddress->state && is_object($defaultAddress->state) && isset($defaultAddress->state->name_en) ? ', ' . $defaultAddress->state->name_en : '') .
                ($defaultAddress->country && is_object($defaultAddress->country) && isset($defaultAddress->country->name_en) ? ', ' . $defaultAddress->country->name_en : '') .
                ($defaultAddress->phone ? ' Phone: ' . $defaultAddress->phone : '')
            ) : null;
            // Add ordered products
            $order->products = $order->orderItems->map(function ($item) {
                return [
                    'id' => $item->id,
                    'product_name' => $item->product ? ($item->product->name_en ?? $item->product->name_ar ?? 'Product') : 'Product',
                    'quantity' => $item->quantity,
                    'amount' => $item->amount, // always use price from OrderItem
                ];
            })->values();

            $latestFulfillment = $order->fulfillments()->latest()->first();
            $order->tracking = $latestFulfillment ? [
                'tracking_number' => $latestFulfillment->tracking_number ?? null,
                'tracking_url' => $latestFulfillment->tracking_url ?? null,
                'delivery_status' => $latestFulfillment->status ?? null,
                'carrier' => $latestFulfillment->courier_partner ?? null,
                'estimated_delivery' => $latestFulfillment->estimated_delivery ?? null,
            ] : null;

            return $order;
        });

        return response()->json(['orders' => $orders]);
    }

    // Update user profile
    public function update(Request $request, User $user)
    {
        $validated = $request->validate([
            'full_name' => 'required|string|max:255',
            'email' => 'required|email|max:255|unique:users,email,' . $user->id,
            'phone' => 'nullable|string|max:20',
            'status' => 'required|string|in:active,suspended',
        ]);

        $oldData = $user->only(['full_name', 'email', 'phone', 'status']);
        $user->update($validated);
        
        // Log user update
        $this->auditLogUpdate('user', "Updated user: {$user->full_name}", [
            'user_id' => $user->id,
            'old' => $oldData,
            'new' => $user->only(['full_name', 'email', 'phone', 'status']),
        ]);
        
        return redirect()->back()->with('success', 'User updated successfully.');
    }

    // Suspend user
    public function suspend(User $user)
    {
        $oldStatus = $user->status;
        $user->update(['status' => 'suspended']);
        
        // Log user suspension
        $this->auditLogUpdate('user', "Suspended user: {$user->full_name}", [
            'user_id' => $user->id,
            'old_status' => $oldStatus,
            'new_status' => 'suspended',
        ]);
        
        return redirect()->back()->with('success', 'User suspended successfully.');
    }

    // Unsuspend user
    public function unsuspend(User $user)
    {
        $oldStatus = $user->status;
        $user->update(['status' => 'active']);
        
        // Log user activation
        $this->auditLogUpdate('user', "Activated user: {$user->full_name}", [
            'user_id' => $user->id,
            'old_status' => $oldStatus,
            'new_status' => 'active',
        ]);
        
        return redirect()->back()->with('success', 'User activated successfully.');
    }

    // Delete user
    public function destroy(User $user)
    {
        $userData = [
            'user_id' => $user->id,
            'full_name' => $user->full_name,
            'email' => $user->email,
        ];
        
        $user->forceDelete();
        
        // Log user deletion
        $this->auditLogDelete('user', "Deleted user: {$userData['full_name']}", $userData);
        
        return redirect()->back()->with('success', 'User deleted successfully.');
    }

    // Create new user
    public function store(Request $request)
    {
        // dd($request->all());
        $validated = $request->validate([
            'full_name' => 'required|string|max:255',
            'email' => 'required|email|max:255|unique:users,email',
            'phone' => 'nullable|string|max:20',
            'status' => 'required|string|in:active,suspended',
            'password' => [
                'required',
                'string',
                'min:8',
                'regex:/^(?=.*[A-Z])(?=.*\d).{8,}$/', // at least 1 uppercase, 1 number, min 8 chars
            ],
        ]);
        $validated['password'] = bcrypt($validated['password']);
        $validated['role'] = 'user';
        $user = User::create($validated);
        $user->assignRole('user');
        
        // Log user creation
        $this->auditLogCreate('user', "Created new user: {$user->full_name}", [
            'user_id' => $user->id,
            'email' => $user->email,
            'status' => $user->status,
        ]);
        
        return redirect()->back()->with('success', 'User created successfully.');
    }

    // Export users to CSV
    public function export(Request $request)
    {
        $query = User::query();

        // Apply filters (search, status, fromDate, toDate)
        if ($search = $request->input('search')) {
            $query->where(function ($q) use ($search) {
                $q->where('full_name', 'like', "%$search%")
                  ->orWhere('email', 'like', "%$search%")
                  ->orWhere('phone', 'like', "%$search%");
            });
        }

        if ($status = $request->input('status')) {
            $query->where('status', $status);
        }

        $fromDate = $request->input('fromDate');
        $toDate = $request->input('toDate');
        if ($fromDate || $toDate) {
            $query->whereHas('orders', function ($q) use ($fromDate, $toDate) {
                if ($fromDate) {
                    $q->whereDate('created_at', '>=', $fromDate);
                }
                if ($toDate) {
                    $q->whereDate('created_at', '<=', $toDate);
                }
            });
        }

        // Add order statistics
        $query->withCount('orders as total_orders')
              ->withSum('orders as total_spent', 'total_amount');

        $users = $query->get();

        $filename = 'users_export_' . date('Y-m-d_H-i-s') . '.csv';

        $headers = [
            'Content-Type' => 'text/csv',
            'Content-Disposition' => 'attachment; filename="' . $filename . '"',
        ];

        $callback = function () use ($users) {
            $file = fopen('php://output', 'w');

            // CSV headers
            fputcsv($file, [
                '#', // Serial number column
                'ID',
                'Full Name',
                'Email',
                'Phone',
                'Status',
                'Created At',
                'Last Login',
                'Total Orders',
                'Total Spent'
            ]);

            // CSV data
            $i = 1;
            foreach ($users as $user) {
                fputcsv($file, [
                    $i++, // Serial number
                    $user->id,
                    $user->full_name,
                    $user->email,
                    $user->phone ?? '',
                    $user->status,
                    $user->created_at->format('Y-m-d H:i:s'),
                    $user->last_login ? $user->last_login->format('Y-m-d H:i:s') : '',
                    $user->total_orders ?? 0,
                    $user->total_spent ?? '0.00'
                ]);
            }

            fclose($file);
        };

        return Response::stream($callback, 200, $headers);
    }
}
