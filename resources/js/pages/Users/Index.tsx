/* eslint-disable @typescript-eslint/no-explicit-any */
import { ActionButtonDelete, ActionButtonSuspend } from '@/components/action-button';
import { StatusFilter } from '@/components/ui/StatusFilter';
import { Badge } from '@/components/ui/badge';
import { Button } from '@/components/ui/button';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Dialog, DialogContent, DialogDescription, DialogFooter, DialogHeader, DialogTitle } from '@/components/ui/dialog';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Pagination } from '@/components/ui/pagination';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select';
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs';
import AppLayout from '@/layouts/app-layout';
import { Head, router, usePage } from '@inertiajs/react';
import { Calendar, Download, Edit, Eye, EyeOff, Mail, Phone, ShoppingCart, User, UserCheck, UserX } from 'lucide-react';
import { useEffect, useState } from 'react';
import { Toaster, toast } from 'react-hot-toast';
import { formatAddress } from '@/utils/formatAddress';

interface User {
    id: number;
    full_name: string;
    email: string;
    phone: string | null;
    mobile: string | null;
    status: string;
    created_at: string;
    last_login?: string;
    total_orders?: number;
    total_spent?: string;
}

interface Vendor {
    name: string;
    email?: string;
    mobile?: string;
    user_id?: number;
    user?: {
        id: number;
        addresses?: Array<{
            id: number;
            full_name: string;
            line_1: string;
            line_2?: string;
            phone?: string;
            pincode?: string;
            city?: { id: number; name_en: string; name_ar: string };
            state?: { id: number; name_en: string; name_ar: string };
            country?: { id: number; name_en: string; name_ar: string };
        }>;
    };
}

interface Order {
    id: number;
    vendor_id: number;
    order_code: string;
    order_status?: string;
    total_amount: string;
    created_at: string;
    vendor?: Vendor;
    sub_total_amount?: string;
    tax_amount?: string;
    discount_amount?: string;
    payment_method?: string;
    payment_status?: string;
    delivery_status?: string;
    total_items?: number;
    shipping_address?: string;
    billing_address?: string;
    refund_status?: string;
    refund_approved_by?: string;
    refund_rejection_reason_en?: string;
    refund_rejection_reason_ar?: string;
    customer_name?: string;
    customer_email?: string;
    customer_mobile?: string;
    customer_address?: string;
    products?: Array<{
        id: number;
        product_name: string;
        quantity: number;
        amount: number;
    }>;
    tracking?: {
        tracking_number?: string;
        tracking_url?: string;
        delivery_status?: string;
        carrier?: string;
        estimated_delivery?: string;
    };
}

function EditUserModal({
    user,
    isOpen,
    onClose,
    onSave,
}: {
    user: User | null;
    isOpen: boolean;
    onClose: () => void;
    onSave: (data: Partial<User>) => void;
}) {
    const [form, setForm] = useState({ full_name: '', email: '', phone: '', mobile: '', status: 'active' as 'active' | 'suspended' });
    useEffect(() => {
        if (user) setForm({ full_name: user.full_name, email: user.email, mobile: user.mobile || '', phone: user.phone || '', status: user.status as 'active' | 'suspended' });
    }, [user]);
    if (!user) return null;
    return (
        <Dialog open={isOpen} onOpenChange={onClose}>
            <DialogContent className="max-w-lg">
                <DialogHeader>
                    <DialogTitle>Edit User</DialogTitle>
                </DialogHeader>
                <div className="space-y-4">
                    <div>
                        <label className="mb-1 block font-medium">Full Name</label>
                        <Input placeholder="Full Name" value={form.full_name} onChange={(e) => setForm({ ...form, full_name: e.target.value })} />
                    </div>
                    <div>
                        <label className="mb-1 block font-medium">Email</label>
                        <Input placeholder="Email" value={form.email} onChange={(e) => setForm({ ...form, email: e.target.value })} />
                    </div>
                    {/* <div>
                        <label className="mb-1 block font-medium">Phone</label>
                        <Input placeholder="Phone" value={form.phone} onChange={(e) => setForm({ ...form, phone: e.target.value })} />
                    </div> */}
                    <div>
                        <label className="mb-1 block font-medium">Mobile</label>
                        <Input placeholder="Mobile" value={form.mobile} onChange={(e) => setForm({ ...form, mobile: e.target.value })} />
                    </div>
                    <div>
                        <label className="mb-1 block font-medium">Status</label>
                        <Select value={form.status} onValueChange={(value: 'active' | 'suspended') => setForm({ ...form, status: value })}>
                            <SelectTrigger>
                                <SelectValue placeholder="Select status" />
                            </SelectTrigger>
                            <SelectContent>
                                <SelectItem value="active">Active</SelectItem>
                                <SelectItem value="suspended">Suspended</SelectItem>
                            </SelectContent>
                        </Select>
                    </div>
                </div>
                <DialogFooter>
                    <Button variant="outline" onClick={onClose}>
                        Cancel
                    </Button>
                    <Button onClick={() => onSave(form)}>Save</Button>
                </DialogFooter>
            </DialogContent>
        </Dialog>
    );
}

function UserProfileModal({
    user,
    isOpen,
    onClose,
    openEditModal,
    openOrderModal,
    // onToggleSuspend,
    onRequestSuspend,
}: {
    user: User | null;
    isOpen: boolean;
    onClose: () => void;
    openEditModal: (user: User) => void;
    openOrderModal: (user: User) => void;
    // onToggleSuspend: (user: User) => void;
    onRequestSuspend: (user: User) => void;
}) {
    const [tab, setTab] = useState('profile');
    if (!user) return null;

    return (
        <Dialog open={isOpen} onOpenChange={onClose}>
            <DialogContent className="max-w-2xl">
                <DialogHeader>
                    <DialogTitle className="flex items-center">
                        <User className="mr-2 h-5 w-5" />
                        User Profile: {user.full_name}
                    </DialogTitle>
                </DialogHeader>

                <Tabs value={tab} onValueChange={setTab} className="w-full">
                    <TabsList className="grid w-full grid-cols-2">
                        <TabsTrigger value="profile">Profile</TabsTrigger>
                        <TabsTrigger value="stats">Statistics</TabsTrigger>
                    </TabsList>

                    <TabsContent value="profile" className="space-y-4 p-4">
                        <Card>
                            <CardHeader>
                                <CardTitle>Personal Information</CardTitle>
                            </CardHeader>
                            <CardContent className="space-y-3">
                                <div className="flex items-center space-x-3">
                                    <User className="h-4 w-4 text-gray-500" />
                                    <div>
                                        <div className="text-sm text-gray-500">Full Name</div>
                                        <div className="font-medium">{user.full_name}</div>
                                    </div>
                                </div>
                                <div className="flex items-center space-x-3">
                                    <Mail className="h-4 w-4 text-gray-500" />
                                    <div>
                                        <div className="text-sm text-gray-500">Email Address</div>
                                        <div className="font-medium">{user.email}</div>
                                    </div>
                                </div>
                                <div className="flex items-center space-x-3">
                                    <Phone className="h-4 w-4 text-gray-500" />
                                    <div>
                                        <div className="text-sm text-gray-500">Phone Number</div>
                                        <div className="font-medium">{user.phone || user.mobile || 'Not provided'}</div>
                                    </div>
                                </div>
                                <div className="flex items-center space-x-3">
                                    <Calendar className="h-4 w-4 text-gray-500" />
                                    <div>
                                        <div className="text-sm text-gray-500">Member Since</div>
                                        <div className="font-medium">{new Date(user.created_at).toLocaleDateString()}</div>
                                    </div>
                                </div>
                                <div className="flex items-center space-x-3">
                                    {user.status === 'active' ? (
                                        <UserCheck className="h-4 w-4 text-green-500" />
                                    ) : (
                                        <UserX className="h-4 w-4 text-red-500" />
                                    )}
                                    <div>
                                        <div className="text-sm text-gray-500">Account Status</div>
                                        <div className="font-medium">
                                            <UserStatusBadge status={user.status} />
                                        </div>
                                    </div>
                                </div>
                                {user.last_login && (
                                    <div className="flex items-center space-x-3">
                                        <Calendar className="h-4 w-4 text-gray-500" />
                                        <div>
                                            <div className="text-sm text-gray-500">Last Login</div>
                                            <div className="font-medium">{new Date(user.last_login).toLocaleString()}</div>
                                        </div>
                                    </div>
                                )}
                            </CardContent>
                        </Card>
                    </TabsContent>

                    <TabsContent value="stats" className="space-y-4 p-4">
                        <div className="grid grid-cols-1 gap-4 md:grid-cols-2">
                            <Card>
                                <CardHeader>
                                    <CardTitle className="flex items-center">
                                        <ShoppingCart className="mr-2 h-4 w-4" />
                                        Order Statistics
                                    </CardTitle>
                                </CardHeader>
                                <CardContent>
                                    <div className="text-2xl font-bold">{user.total_orders || 0}</div>
                                    <p className="text-sm text-gray-500">Total Orders</p>
                                </CardContent>
                            </Card>

                            <Card>
                                <CardHeader>
                                    <CardTitle className="flex items-center">Spending Statistics</CardTitle>
                                </CardHeader>
                                <CardContent>
                                    <div className="text-2xl font-bold">KWD {user.total_spent || '0.00'}</div>
                                    <p className="text-sm text-gray-500">Total Spent</p>
                                </CardContent>
                            </Card>
                        </div>

                        <Card>
                            <CardHeader>
                                <CardTitle>Quick Actions</CardTitle>
                            </CardHeader>
                            <CardContent className="space-y-2">
                                <Button className="w-full dark:bg-white dark:text-black" variant="outline" onClick={() => openEditModal(user)}>
                                    <Edit className="mr-2 h-4 w-4" />
                                    Edit Profile
                                </Button>
                                <Button className="w-full dark:bg-white dark:text-black" variant="outline" onClick={() => openOrderModal(user)}>
                                    <ShoppingCart className="mr-2 h-4 w-4" />
                                    View Order History
                                </Button>
                                <Button className="w-full dark:bg-white dark:text-black" variant="outline" onClick={() => onRequestSuspend(user)}>
                                    {user.status === 'active' ? <UserX className="mr-2 h-4 w-4" /> : <UserCheck className="mr-2 h-4 w-4" />}
                                    {user.status === 'active' ? 'Suspend User' : 'Activate User'}
                                </Button>
                            </CardContent>
                        </Card>
                    </TabsContent>
                </Tabs>
            </DialogContent>
        </Dialog>
    );
}

function OrderHistoryModal({ user, isOpen, onClose }: { user: User | null; isOpen: boolean; onClose: () => void }) {
    const [orders, setOrders] = useState<Order[]>([]);
    const [loading, setLoading] = useState(false);
    const [search, setSearch] = useState('');
    const [page, setPage] = useState(1);
    const [selectedOrder, setSelectedOrder] = useState<Order | null>(null);
    const [isOrderDetailsOpen, setOrderDetailsOpen] = useState(false);
    const [orderToDelete, setOrderToDelete] = useState<Order | null>(null);
    const [orderToCancel, setOrderToCancel] = useState<Order | null>(null);
    const [orderDetailsTab, setOrderDetailsTab] = useState('summary');

    const refreshOrders = () => {
        if (user && isOpen) {
            setLoading(true);
            const params = new URLSearchParams({
                page: String(page),
                search,
            });
            fetch(`/users/${user.id}/show?${params.toString()}`)
                .then((res) => res.json())
                .then((data) => {
                    setOrders(data.orders.data || []);
                    setLoading(false);
                })
                .catch(() => setLoading(false));
        }
    };

    useEffect(() => {
        refreshOrders();
        // eslint-disable-next-line
    }, [user, isOpen, page, search]);

    const confirmDeleteOrder = () => {
        if (!orderToDelete) return;
        router.delete(route('orders.destroy', orderToDelete.id), {
            preserveScroll: true,
            onSuccess: () => {
                toast.success('Order deleted successfully.');
                setOrderToDelete(null);
                refreshOrders();
            },
            onError: () => {
                toast.error('Failed to delete order');
            },
        });
    };

    const confirmCancelOrder = () => {
        if (!orderToCancel) return;
        router.post(
            route('orders.cancel', orderToCancel.id),
            {},
            {
                preserveScroll: true,
                onSuccess: (page: any) => {
                    const flash = (page?.props?.flash || {}) as { success?: string; info?: string; error?: string };
                    if (flash.success) {
                        toast.success(flash.success);
                    } else if (flash.info) {
                        toast(flash.info);
                    } else if (flash.error) {
                        toast.error(flash.error);
                    } else {
                        toast.success('Order cancelled successfully.');
                    }
                    setOrderToCancel(null);
                    refreshOrders();
                },
                onError: (page: any) => {
                    const flash = (page?.props?.flash || {}) as { error?: string };
                    const msg = flash.error || 'Failed to cancel order';
                    toast.error(msg);
                },
            },
        );
    };

    if (!user) return null;

    return (
        <Dialog open={isOpen} onOpenChange={onClose}>
            <DialogContent style={{ maxWidth: '64rem', width: '100%' }}>
                <DialogHeader>
                    <DialogTitle>Order History: {user.full_name}</DialogTitle>
                </DialogHeader>
                <div className="mb-4 flex items-center gap-2">
                    <Input
                        type="text"
                        placeholder="Search orders by ID, status, or date (YYYY-MM-DD)"
                        value={search}
                        onChange={(e) => {
                            setSearch(e.target.value);
                            setPage(1);
                        }}
                        className="w-72"
                    />
                </div>
                <div className="overflow-x-auto">
                    {loading ? (
                        <div className="py-8 text-center text-gray-500">Loading...</div>
                    ) : orders.length === 0 ? (
                        <div className="py-8 text-center text-gray-500">No orders found.</div>
                    ) : (
                        <table className="min-w-full border bg-white dark:bg-neutral-900">
                            <thead>
                                <tr>
                                    <th className="border px-4 py-2">Order ID</th>
                                    <th className="border px-4 py-2">Vendor</th>
                                    <th className="border px-4 py-2">Status</th>
                                    <th className="border px-4 py-2">Total</th>
                                    <th className="border px-4 py-2">Date</th>
                                    <th className="border px-4 py-2">Actions</th>
                                </tr>
                            </thead>
                            <tbody>
                                {orders.map((order) => (
                                    <tr key={order.id} className="text-center">
                                        <td className="border px-4 py-2">{order.order_code}</td>
                                        <td className="border px-4 py-2">{order.vendor?.name || 'N/A'}</td>
                                        <td className="border px-4 py-2">
                                            <Badge variant="secondary" className="bg-transparent text-base font-semibold">
                                                {order.order_status
                                                    ? order.order_status.replace(/_/g, ' ').replace(/\b\w/g, (l) => l.toUpperCase())
                                                    : ''}
                                            </Badge>
                                        </td>
                                        <td className="border px-4 py-2">KWD {order.total_amount}</td>
                                        <td className="border px-4 py-2">{new Date(order.created_at).toLocaleDateString()}</td>
                                        <td className="border px-4 py-2">
                                            <div className="flex items-center">
                                                <Button
                                                    size="sm"
                                                    variant="outline"
                                                    onClick={() => {
                                                        setSelectedOrder(order);
                                                        setOrderDetailsOpen(true);
                                                    }}
                                                >
                                                    <Eye className="mr-1 h-3 w-3" />
                                                    View
                                                </Button>
                                                <Button size="sm" variant="secondary" className="ml-2" onClick={() => setOrderToCancel(order)}>
                                                    Cancel
                                                </Button>
                                                <Button size="sm" variant="destructive" className="ml-2" onClick={() => setOrderToDelete(order)}>
                                                    Delete
                                                </Button>
                                            </div>
                                        </td>
                                    </tr>
                                ))}
                            </tbody>
                        </table>
                    )}
                </div>
            </DialogContent>
            <Dialog open={isOrderDetailsOpen} onOpenChange={setOrderDetailsOpen}>
                <DialogContent className="max-h-[90vh] !max-w-4xl overflow-y-auto">
                    <DialogHeader>
                        <DialogTitle>Order Details{selectedOrder?.order_code ? `: #${selectedOrder.order_code}` : ''}</DialogTitle>
                        <DialogDescription>Complete order information and management</DialogDescription>
                    </DialogHeader>

                    <Tabs value={orderDetailsTab} onValueChange={setOrderDetailsTab} className="w-full">
                        <TabsList className="grid w-full grid-cols-5">
                            <TabsTrigger value="summary">Summary</TabsTrigger>
                            <TabsTrigger value="customer">Customer</TabsTrigger>
                            <TabsTrigger value="vendor">Vendor</TabsTrigger>
                            <TabsTrigger value="products">Products</TabsTrigger>
                            <TabsTrigger value="tracking">Tracking</TabsTrigger>
                        </TabsList>

                        {/* Summary Tab */}
                        <TabsContent value="summary" className="space-y-4 p-4">
                            <div className="space-y-4">
                                <Card>
                                    <CardHeader>
                                        <CardTitle>Order Summary</CardTitle>
                                    </CardHeader>
                                    <CardContent className="space-y-2">
                                        <div className="flex justify-between">
                                            <span>Status:</span>
                                            <span>
                                                <Badge variant="outline" className="bg-yellow-100 text-yellow-800">
                                                    {selectedOrder?.order_status
                                                        ? selectedOrder.order_status.charAt(0).toUpperCase() + selectedOrder.order_status.slice(1)
                                                        : ''}
                                                </Badge>
                                            </span>
                                        </div>
                                        <div className="flex justify-between">
                                            <span>Total Amount:</span>
                                            <span className="font-bold">KWD {selectedOrder?.total_amount}</span>
                                        </div>
                                        <div className="flex justify-between">
                                            <span>Subtotal:</span>
                                            <span>KWD {selectedOrder?.sub_total_amount}</span>
                                        </div>
                                        <div className="flex justify-between">
                                            <span>Tax:</span>
                                            <span>KWD {selectedOrder?.tax_amount}</span>
                                        </div>
                                        <div className="flex justify-between">
                                            <span>Discount:</span>
                                            <span>KWD {selectedOrder?.discount_amount}</span>
                                        </div>
                                        <div className="flex justify-between">
                                            <span>Payment Method:</span>
                                            <span className="rounded bg-yellow-100 px-2 py-1 dark:bg-yellow-900">
                                                {selectedOrder?.payment_method
                                                    ? selectedOrder.payment_method.replace(/_/g, ' ').replace(/\b\w/g, (l) => l.toUpperCase())
                                                    : 'Credit Card'}
                                            </span>
                                        </div>
                                        <div className="flex justify-between">
                                            <span>Order Date:</span>
                                            <span>
                                                {selectedOrder
                                                    ? new Date(selectedOrder.created_at)
                                                        .toLocaleString('en-GB', {
                                                            day: '2-digit',
                                                            month: '2-digit',
                                                            year: 'numeric',
                                                            hour: '2-digit',
                                                            minute: '2-digit',
                                                            hour12: false,
                                                        })
                                                        .replace(',', '') + ' PM'
                                                    : ''}
                                            </span>
                                        </div>
                                    </CardContent>
                                </Card>
                            </div>
                        </TabsContent>

                        {/* Customer Tab */}
                        <TabsContent value="customer" className="space-y-4 p-4">
                            <Card className="mb-4">
                                <CardHeader>
                                    <CardTitle>Customer Information</CardTitle>
                                </CardHeader>
                                <CardContent className="space-y-2 p-4">
                                    <div>
                                        <strong>Name:</strong> {selectedOrder?.customer_name || 'N/A'}
                                    </div>
                                    <div>
                                        <strong>Email:</strong> {selectedOrder?.customer_email || 'N/A'}
                                    </div>
                                    <div>
                                        <strong>Mobile:</strong> {selectedOrder?.customer_mobile || 'Not provided'}
                                    </div>
                                    <div>
                                        <strong>Address:</strong>
                                        <p className="text-sm mt-1">
                                            {selectedOrder?.customer_address || 'Not provided'}
                                        </p>
                                    </div>
                                </CardContent>
                            </Card>
                            <Card className="mb-4">
                                <CardHeader>
                                    <CardTitle>Order Information</CardTitle>
                                </CardHeader>
                                <CardContent className="space-y-2 p-4">
                                    <div>
                                        <strong>Order ID:</strong> #{selectedOrder?.order_code}
                                    </div>
                                    <div>
                                        <strong>Payment Status:</strong>{' '}
                                        <Badge variant="outline" className="ml-2 bg-yellow-100 text-yellow-800">
                                            {selectedOrder?.payment_status
                                                ? selectedOrder.payment_status.charAt(0).toUpperCase() + selectedOrder.payment_status.slice(1)
                                                : ''}
                                        </Badge>
                                    </div>
                                    <div>
                                        <strong>Delivery Status:</strong>{' '}
                                        <Badge variant="outline" className="ml-2 bg-blue-100 text-blue-800">
                                            {selectedOrder?.delivery_status
                                                ? selectedOrder.delivery_status.charAt(0).toUpperCase() + selectedOrder.delivery_status.slice(1)
                                                : ''}
                                        </Badge>
                                    </div>
                                    <div>
                                        <strong>Total Items:</strong> {selectedOrder?.total_items}
                                    </div>
                                </CardContent>
                            </Card>
                            <Card className="mb-4">
                                <CardHeader>
                                    <CardTitle>Addresses</CardTitle>
                                </CardHeader>
                                <CardContent className="grid grid-cols-1 gap-4 p-4 md:grid-cols-2">
                                    <div>
                                        <h4 className="mb-2 font-semibold">Shipping Address</h4>
                                        <p className="text-sm whitespace-pre-line">{formatAddress(selectedOrder?.shipping_address)}</p>
                                    </div>
                                    <div>
                                        <h4 className="mb-2 font-semibold">Pickup Address</h4>
                                        <p className="text-sm ">
                                            {selectedOrder?.vendor?.user?.addresses && selectedOrder.vendor.user.addresses.length > 0
                                                ? (() => {
                                                    const vendorAddress = selectedOrder.vendor.user.addresses[0];
                                                    const parts: string[] = [];
                                                    // if (vendorAddress.full_name) parts.push(vendorAddress.full_name);
                                                    if (vendorAddress.line_1) parts.push(vendorAddress.line_1);
                                                    if (vendorAddress.line_2) parts.push(vendorAddress.line_2);
                                                    const locationParts: string[] = [];
                                                    if (vendorAddress.city?.name_en) locationParts.push(vendorAddress.city.name_en);
                                                    if (vendorAddress.state?.name_en) locationParts.push(vendorAddress.state.name_en);
                                                    if (vendorAddress.country?.name_en) locationParts.push(vendorAddress.country.name_en);
                                                    if (locationParts.length > 0) parts.push(locationParts.join(', '));
                                                    if (vendorAddress.pincode) parts.push(vendorAddress.pincode);
                                                    if (vendorAddress.phone) parts.push(`Phone: ${vendorAddress.phone}`);
                                                    return parts.length > 0 ? parts.join('\n') : 'Not provided';
                                                })()
                                                : 'Not provided'}
                                        </p>
                                    </div>
                                </CardContent>
                            </Card>
                        </TabsContent>

                        {/* Vendor Tab */}
                        <TabsContent value="vendor" className="space-y-4 p-4">
                            <Card>
                                <CardHeader>
                                    <CardTitle>Vendor Information</CardTitle>
                                </CardHeader>
                                <CardContent className="space-y-2 p-4">
                                    <div>
                                        <strong>Name:</strong> {selectedOrder?.vendor?.name || 'N/A'}
                                    </div>
                                    <div>
                                        <strong>Email:</strong> {selectedOrder?.vendor?.email || 'Not provided'}
                                    </div>
                                    <div>
                                        <strong>Mobile:</strong> {selectedOrder?.vendor?.mobile || 'Not provided'}
                                    </div>
                                    <div>
                                        <strong>Address:</strong>
                                        <p className="text-sm mt-1">
                                            {selectedOrder?.vendor?.user?.addresses && selectedOrder.vendor.user.addresses.length > 0
                                                ? (() => {
                                                    const vendorAddress = selectedOrder.vendor.user.addresses[0];
                                                    const parts: string[] = [];
                                                    if (vendorAddress.line_1) parts.push(vendorAddress.line_1);
                                                    if (vendorAddress.line_2) parts.push(vendorAddress.line_2);
                                                    const locationParts: string[] = [];
                                                    if (vendorAddress.city?.name_en) locationParts.push(vendorAddress.city.name_en);
                                                    if (vendorAddress.state?.name_en) locationParts.push(vendorAddress.state.name_en);
                                                    if (vendorAddress.country?.name_en) locationParts.push(vendorAddress.country.name_en);
                                                    if (locationParts.length > 0) parts.push(locationParts.join(', '));
                                                    if (vendorAddress.pincode) parts.push(vendorAddress.pincode);
                                                    if (vendorAddress.phone) parts.push(`Phone: ${vendorAddress.phone}`);
                                                    return parts.length > 0 ? parts.join(', ') : 'Not provided';
                                                })()
                                                : 'Not provided'}
                                        </p>
                                    </div>
                                </CardContent>
                            </Card>
                        </TabsContent>

                        {/* Products Tab */}
                        <TabsContent value="products" className="space-y-4 p-4">
                            <Card>
                                <CardHeader>
                                    <CardTitle>Ordered Products</CardTitle>
                                </CardHeader>
                                <CardContent className="p-4">
                                    {selectedOrder?.products && selectedOrder.products.length > 0 ? (
                                        <div className="space-y-3">
                                            {selectedOrder.products.map((item) => (
                                                <div key={item.id} className="flex items-center justify-between rounded border p-3">
                                                    <div>
                                                        <div className="font-medium">{item.product_name || 'Product'}</div>
                                                        <div className="text-sm text-gray-500">
                                                            Qty: {item.quantity} × KWD {item.amount}
                                                        </div>
                                                    </div>
                                                    <div className="font-bold">KWD {(item.quantity * item.amount).toFixed(2)}</div>
                                                </div>
                                            ))}
                                        </div>
                                    ) : (
                                        <p className="text-gray-500">No products found for this order.</p>
                                    )}
                                </CardContent>
                            </Card>
                        </TabsContent>

                        {/* Tracking Tab */}
                        <TabsContent value="tracking" className="space-y-4 p-4">
                            <Card>
                                <CardHeader>
                                    <CardTitle className="flex items-center">
                                        <span className="mr-2">🚚</span>
                                        Delivery Tracking
                                    </CardTitle>
                                </CardHeader>
                                <CardContent className="p-4">
                                    {selectedOrder?.tracking &&
                                        (selectedOrder.tracking.tracking_number ||
                                            selectedOrder.tracking.delivery_status ||
                                            selectedOrder.tracking.tracking_url) ? (
                                        <div className="space-y-4">
                                            <div className="grid grid-cols-1 gap-4 md:grid-cols-2">
                                                <div>
                                                    <strong>Tracking Number:</strong> {selectedOrder.tracking.tracking_number || 'Not available'}
                                                </div>
                                                <div>
                                                    <strong>Carrier:</strong> {selectedOrder.tracking.carrier || 'Unknown'}
                                                </div>
                                                <div>
                                                    <strong>Status:</strong>
                                                    <span className="ml-2 inline-block rounded bg-blue-100 px-2 py-1 text-xs font-semibold text-blue-800">
                                                        {selectedOrder.tracking.delivery_status
                                                            ? selectedOrder.tracking.delivery_status
                                                                .replace(/_/g, ' ')
                                                                .replace(/^\w/, (c) => c.toUpperCase())
                                                            : 'Unknown'}
                                                    </span>
                                                </div>
                                                <div>
                                                    <strong>Estimated Delivery:</strong>{' '}
                                                    {selectedOrder.tracking.estimated_delivery || 'Not available'}
                                                </div>
                                            </div>
                                        </div>
                                    ) : (
                                        <p className="text-gray-500">No tracking information available for this order.</p>
                                    )}
                                </CardContent>
                            </Card>
                        </TabsContent>
                    </Tabs>
                </DialogContent>
            </Dialog>
            <Dialog open={!!orderToDelete} onOpenChange={(open) => !open && setOrderToDelete(null)}>
                <DialogContent>
                    <DialogHeader>
                        <DialogTitle>Delete Order</DialogTitle>
                        <DialogTitle>Are you sure you want to delete this order? This action cannot be undone.</DialogTitle>
                    </DialogHeader>
                    <div className="flex justify-end gap-2">
                        <Button variant="outline" onClick={() => setOrderToDelete(null)}>
                            Cancel
                        </Button>
                        <Button variant="destructive" onClick={confirmDeleteOrder}>
                            Delete
                        </Button>
                    </div>
                </DialogContent>
            </Dialog>
            <Dialog open={!!orderToCancel} onOpenChange={(open) => !open && setOrderToCancel(null)}>
                <DialogContent>
                    <DialogHeader>
                        <DialogTitle>Cancel Order</DialogTitle>
                        <DialogTitle>Are you sure you want to cancel this order?</DialogTitle>
                    </DialogHeader>
                    <div className="flex justify-end gap-2">
                        <Button variant="outline" onClick={() => setOrderToCancel(null)}>
                            Back
                        </Button>
                        <Button variant="secondary" onClick={confirmCancelOrder}>
                            Cancel Order
                        </Button>
                    </div>
                </DialogContent>
            </Dialog>
        </Dialog>
    );
}

const UserStatusBadge = ({ status }: { status: string }) => {
    switch (status) {
        case 'active':
            return (
                <Badge variant="default" className="bg-green-500 hover:bg-green-600">
                    Active
                </Badge>
            );
        case 'suspended':
            return <Badge variant="destructive">Suspended</Badge>;
        default:
            return <Badge variant="secondary">{status}</Badge>;
    }
};

function UsersPage() {
    const { props } = usePage();
    const users = props.users as any;
    const filters = props.filters as { search: string; status: string; fromDate: string; toDate: string };

    const [search, setSearch] = useState(filters.search || '');
    const [status, setStatus] = useState(filters.status || '');
    const [fromDate, setFromDate] = useState(filters.fromDate || '');
    const [toDate, setToDate] = useState(filters.toDate || '');

    // Pagination state
    const currentPage = users.current_page;
    const lastPage = users.last_page;
    const perPage = users.per_page;
    const total = users.total;
    const links = users.links;

    const handlePageChange = (pageNum: number) => {
        router.get(
            route('users.index'),
            {
                search,
                status,
                fromDate,
                toDate,
                page: pageNum,
            },
            { preserveState: true, replace: true },
        );
    };

    const [selectedUser, setSelectedUser] = useState<User | null>(null);
    const [isEditModalOpen, setEditModalOpen] = useState(false);
    const [isProfileModalOpen, setProfileModalOpen] = useState(false);
    const [isOrderModalOpen, setOrderModalOpen] = useState(false);
    const [isDeleteModalOpen, setDeleteModalOpen] = useState(false);
    const [isCreateModalOpen, setCreateModalOpen] = useState(false);
    const [createForm, setCreateForm] = useState({ full_name: '', email: '', phone: '', status: 'active', password: '' });
    const [isSuspendDialogOpen, setSuspendDialogOpen] = useState(false);
    const [userToSuspend, setUserToSuspend] = useState<User | null>(null);
    const [suspendAction, setSuspendAction] = useState<'suspend' | 'activate'>('suspend');
    const [errors, setErrors] = useState<{ [key: string]: string } | null>(null);
    const [showPassword, setShowPassword] = useState(false);

    type Flash = { success?: string; error?: string };
    const flash = (props.flash || {}) as Flash;

    useEffect(() => {
        if (flash.success && flash.success !== '') {
            toast.success(flash.success);
        }
        if (flash.error && flash.error !== '') {
            toast.error(flash.error);
        }
    }, [flash.success, flash.error]);

    useEffect(() => {
        router.get(route('users.index'), { search, status, fromDate, toDate }, { preserveState: true, replace: true });
    }, [search, status, fromDate, toDate]);

    // Removed old client-side filtering and pagination logic

    const openEditModal = (user: User) => {
        setSelectedUser(user);
        setEditModalOpen(true);
    };

    const openProfileModal = (user: User) => {
        setSelectedUser(user);
        setProfileModalOpen(true);
    };

    const openOrderModal = (user: User) => {
        setSelectedUser(user);
        setOrderModalOpen(true);
    };

    const handleSave = (data: Partial<User>) => {
        if (selectedUser) {
            router.put(route('users.update', selectedUser.id), data, {
                preserveState: false,
                preserveScroll: true,
            });
        }
    };

    const handleSuspend = (user: User) => {
        router.post(
            route('users.suspend', user.id),
            {},
            {
                preserveState: false,
                preserveScroll: true,
            },
        );
    };

    const handleDelete = (user: User) => {
        setSelectedUser(user);
        setDeleteModalOpen(true);
    };

    const confirmDelete = () => {
        if (selectedUser) {
            router.delete(route('users.destroy', selectedUser.id), {
                preserveState: false,
                preserveScroll: true,
            });
        }
    };

    const exportUsers = () => {
        const params = new URLSearchParams({ search, status });
        if (fromDate) params.append('fromDate', fromDate);
        if (toDate) params.append('toDate', toDate);
        window.open(`/users/export?${params.toString()}`, '_blank');
    };

    // Add a handler to open the suspend/activate confirmation dialog from profile modal
    const handleRequestSuspend = (user: User) => {
        setUserToSuspend(user);
        setSuspendAction(user.status === 'active' ? 'suspend' : 'activate');
        setSuspendDialogOpen(true);
    };

    return (
        <div className="p-6">
            <div className="mb-4 flex items-center justify-between">
                <h1 className="text-2xl font-bold">User Manager</h1>
                <div className="flex items-center gap-2">
                    <Input
                        type="text"
                        placeholder="Search by name, email, phone..."
                        value={search}
                        onChange={(e) => setSearch(e.target.value)}
                        className="w-64"
                    />
                    <div className="flex gap-2">
                        <Input
                            type="date"
                            value={fromDate}
                            onChange={(e) => {
                                setFromDate(e.target.value);
                                if (toDate && e.target.value && toDate < e.target.value) {
                                    setToDate(e.target.value);
                                }
                            }}
                            className="w-full min-w-[120px]"
                            placeholder="From date"
                            min="2015-01-01"
                        />
                        <Input
                            type="date"
                            value={toDate}
                            onChange={(e) => setToDate(e.target.value)}
                            className="w-full min-w-[120px]"
                            placeholder="To date"
                            min="2015-01-01"
                        />
                    </div>
                    <StatusFilter
                        value={status || 'all'}
                        onChange={(value) => setStatus(value === 'all' ? '' : value)}
                        statusOptions={[
                            { value: 'all', label: 'All Statuses' },
                            { value: 'active', label: 'Active' },
                            { value: 'suspended', label: 'Suspended' },
                        ]}
                        placeholder="Filter by status"
                        className="w-[180px]"
                    />
                    <Button onClick={exportUsers} variant="outline">
                        <Download className="mr-2 h-4 w-4" />
                        Export CSV
                    </Button>
                    <Button onClick={() => setCreateModalOpen(true)} variant="default">
                        Create User
                    </Button>
                </div>
            </div>
            <div className="overflow-x-auto">
                <table className="min-w-full border bg-white dark:bg-neutral-900">
                    <thead>
                        <tr>
                            <th className="border px-4 py-2">#</th>
                            <th className="border px-4 py-2">Full Name</th>
                            <th className="border px-4 py-2">Email</th>
                            <th className="border px-4 py-2">Phone</th>
                            <th className="border px-4 py-2">Status</th>
                            <th className="border px-4 py-2">Joined</th>
                            <th className="border px-4 py-2">Orders</th>
                            <th className="border px-4 py-2">Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        {users.data.map((user: any, idx: number) => (
                            <tr key={user.id}>
                                <td className="border px-4 py-2 text-center">{(currentPage - 1) * perPage + idx + 1}</td>
                                <td className="border px-4 py-2">{user.full_name}</td>
                                <td className="border px-4 py-2">{user.email}</td>
                                <td className="border px-4 py-2">{user.phone || user.mobile || 'N/A'}</td>
                                <td className="border px-4 py-2 text-center">
                                    <span
                                        className={
                                            'inline-block min-w-[90px] rounded px-2 py-1 text-center text-xs font-semibold text-white ' +
                                            (['active', 'suspended'].includes(user.status)
                                                ? ({ active: 'bg-green-600', suspended: 'bg-red-600' } as const)[
                                                user.status as 'active' | 'suspended'
                                                ]
                                                : 'bg-gray-400')
                                        }
                                    >
                                        {user.status === 'active'
                                            ? 'Active'
                                            : user.status === 'suspended'
                                                ? 'Suspended'
                                                : user.status.charAt(0).toUpperCase() + user.status.slice(1)}
                                    </span>
                                </td>
                                <td className="border px-4 py-2 text-center">{new Date(user.created_at).toLocaleDateString()}</td>
                                <td className="border px-4 py-2 text-center">{user.total_orders || 0}</td>
                                <td className="space-x-2 border px-4 py-2 text-center">
                                    <Button size="sm" variant="outline" onClick={() => openProfileModal(user)}>
                                        View
                                    </Button>
                                    <Button size="sm" variant="outline" onClick={() => openEditModal(user)}>
                                        Edit
                                    </Button>
                                    <Button size="sm" variant="outline" onClick={() => openOrderModal(user)}>
                                        Orders
                                    </Button>
                                    <ActionButtonSuspend
                                        btnTitle={user.status === 'active' ? 'Suspend' : 'Activate'}
                                        variant={user.status === 'active' ? 'outline' : 'default'}
                                        onClick={() => {
                                            setUserToSuspend(user);
                                            setSuspendAction(user.status === 'active' ? 'suspend' : 'activate');
                                            setSuspendDialogOpen(true);
                                        }}
                                    />
                                    <ActionButtonDelete btnTitle="Delete" onClick={() => handleDelete(user)} />
                                </td>
                            </tr>
                        ))}
                    </tbody>
                </table>
            </div>
            {/* Pagination */}
            {lastPage > 1 && (
                <div className="mt-6">
                    <Pagination
                        currentPage={currentPage}
                        lastPage={lastPage}
                        total={total}
                        perPage={perPage}
                        links={links}
                        onPageChange={handlePageChange}
                    />
                </div>
            )}

            {/* Modals */}
            <EditUserModal user={selectedUser} isOpen={isEditModalOpen} onClose={() => setEditModalOpen(false)} onSave={handleSave} />
            <UserProfileModal
                user={selectedUser}
                isOpen={isProfileModalOpen}
                onClose={() => setProfileModalOpen(false)}
                openEditModal={openEditModal}
                openOrderModal={openOrderModal}
                // Removed onToggleSuspend prop as it is no longer used
                onRequestSuspend={handleRequestSuspend}
            />
            <OrderHistoryModal user={selectedUser} isOpen={isOrderModalOpen} onClose={() => setOrderModalOpen(false)} />
            <Dialog open={isCreateModalOpen} onOpenChange={setCreateModalOpen}>
                <DialogContent className="max-w-lg">
                    <DialogHeader>
                        <DialogTitle>Create New User</DialogTitle>
                    </DialogHeader>
                    <div className="space-y-4">
                        <div>
                            <Label htmlFor="fullName">Full Name <span className='text-red-500'>*</span></Label>
                            <Input
                                id="fullName"
                                placeholder="Full Name"
                                value={createForm.full_name}
                                onChange={(e) => setCreateForm({ ...createForm, full_name: e.target.value })}
                            />
                            {errors?.full_name && <div className="mt-1 text-xs text-red-500">{errors.full_name}</div>}
                        </div>
                        <div>
                            <Label htmlFor="email">Email <span className='text-red-500'>*</span></Label>
                            <Input
                                id="email"
                                placeholder="Email"
                                value={createForm.email}
                                onChange={(e) => setCreateForm({ ...createForm, email: e.target.value })}
                            />
                            {errors?.email && <div className="mt-1 text-xs text-red-500">{errors.email}</div>}
                        </div>
                        <div>
                            <Label htmlFor="phone">Phone</Label>
                            <Input
                                id="phone"
                                placeholder="Phone"
                                value={createForm.phone}
                                onChange={(e) => setCreateForm({ ...createForm, phone: e.target.value })}
                            />
                            {errors?.phone && <div className="mt-1 text-xs text-red-500">{errors.phone}</div>}
                        </div>
                        <div>
                            <Label htmlFor="fullName">Status <span className='text-red-500'>*</span></Label>
                            <Select value={createForm.status} onValueChange={(value) => setCreateForm({ ...createForm, status: value })}>
                                <SelectTrigger>
                                    <SelectValue placeholder="Status" />
                                </SelectTrigger>
                                <SelectContent>
                                    <SelectItem value="active">Active</SelectItem>
                                    <SelectItem value="suspended">Suspended</SelectItem>
                                </SelectContent>
                            </Select>
                            {errors?.status && <div className="mt-1 text-xs text-red-500">{errors.status}</div>}
                        </div>
                        <div className="relative">
                            <Label htmlFor="password">Password <span className='text-red-500'>*</span></Label>
                            <div className="relative">
                                <Input
                                    id="password"
                                    placeholder="Password"
                                    type={showPassword ? 'text' : 'password'}
                                    value={createForm.password}
                                    onChange={(e) => setCreateForm({ ...createForm, password: e.target.value })}
                                    className="h-10 pr-10"
                                />
                                <button
                                    type="button"
                                    className="absolute top-1/2 right-2 flex -translate-y-1/2 cursor-pointer items-center text-gray-500"
                                    onClick={() => setShowPassword((v: boolean) => !v)}
                                    tabIndex={-1}
                                    aria-label={showPassword ? 'Hide password' : 'Show password'}
                                >
                                    {showPassword ? <EyeOff className="h-5 w-5" /> : <Eye className="h-5 w-5" />}
                                </button>
                            </div>
                            {typeof errors?.password === 'string' && (
                                <div className="mt-1 text-xs text-red-500">
                                    {errors.password.toLowerCase().includes('format')
                                        ? 'Password must be at least 8 characters, include 1 uppercase letter and 1 number.'
                                        : errors.password}
                                </div>
                            )}
                            {Array.isArray(errors?.password) && errors.password.length > 0 && (
                                <div className="mt-1 text-xs text-red-500">{errors.password[0]}</div>
                            )}
                        </div>
                    </div>
                    <DialogFooter>
                        <Button variant="outline" onClick={() => setCreateModalOpen(false)}>
                            Cancel
                        </Button>
                        <Button
                            onClick={() => {
                                router.post(route('users.store'), createForm, {
                                    preserveState: true,
                                    onSuccess: () => {
                                        setCreateModalOpen(false);
                                        setErrors(null);
                                    },
                                    onError: (err) => {
                                        const newErrorsPayload = {
                                            ...err,
                                            ...(!createForm.phone && { phone: 'Phone is required' }),
                                        };
                                        setErrors(newErrorsPayload);
                                    },
                                });
                            }}
                        >
                            Create
                        </Button>
                    </DialogFooter>
                </DialogContent>
            </Dialog>

            {/* Delete Confirmation Modal */}
            <Dialog open={isDeleteModalOpen} onOpenChange={setDeleteModalOpen}>
                <DialogContent>
                    <DialogHeader>
                        <DialogTitle>Confirm Deletion</DialogTitle>
                    </DialogHeader>
                    <div className="py-4">
                        <p>Are you sure you want to delete user "{selectedUser?.full_name}"? This action cannot be undone.</p>
                    </div>
                    <DialogFooter>
                        <Button variant="outline" onClick={() => setDeleteModalOpen(false)}>
                            Cancel
                        </Button>
                        <Button variant="destructive" onClick={confirmDelete}>
                            Delete
                        </Button>
                    </DialogFooter>
                </DialogContent>
            </Dialog>
            <Dialog open={isSuspendDialogOpen} onOpenChange={setSuspendDialogOpen}>
                <DialogContent>
                    <DialogHeader>
                        <DialogTitle>{suspendAction === 'suspend' ? 'Suspend User' : 'Activate User'}</DialogTitle>
                    </DialogHeader>
                    <div className="py-4">
                        <p>
                            Are you sure you want to {suspendAction} user "{userToSuspend?.full_name}"?
                        </p>
                    </div>
                    <DialogFooter>
                        <Button variant="outline" onClick={() => setSuspendDialogOpen(false)}>
                            Cancel
                        </Button>
                        <Button
                            variant={suspendAction === 'suspend' ? 'destructive' : 'default'}
                            onClick={() => {
                                if (userToSuspend) {
                                    if (suspendAction === 'suspend') {
                                        router.post(
                                            route('users.suspend', userToSuspend.id),
                                            {},
                                            { preserveState: false, onSuccess: () => setSuspendDialogOpen(false) },
                                        );
                                    } else {
                                        router.post(
                                            route('users.unsuspend', userToSuspend.id),
                                            {},
                                            { preserveState: false, onSuccess: () => setSuspendDialogOpen(false) },
                                        );
                                    }
                                }
                            }}
                        >
                            {suspendAction === 'suspend' ? 'Suspend' : 'Activate'}
                        </Button>
                    </DialogFooter>
                </DialogContent>
            </Dialog>
        </div>
    );
}

const UsersIndex = () => (
    <AppLayout>
        <Head title="Users Manager" />
        <UsersPage />
        <Toaster position="top-right" />
    </AppLayout>
);

export default UsersIndex;
