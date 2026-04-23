/* eslint-disable @typescript-eslint/no-explicit-any */
import { Badge } from '@/components/ui/badge';
import { Button } from '@/components/ui/button';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Dialog, DialogContent, DialogDescription, DialogHeader, DialogTitle } from '@/components/ui/dialog';
import { Input } from '@/components/ui/input';
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs';
import { Textarea } from '@/components/ui/textarea';
import { Head, router } from '@inertiajs/react';
import dayjs from 'dayjs';
import { AlertTriangle, CheckCircle, Clock, Package, Truck } from 'lucide-react';
import { useCallback, useEffect, useState } from 'react';
import toast from 'react-hot-toast';
import { formatAddress } from '@/utils/formatAddress';

interface User {
    id: number;
    full_name: string;
    email: string;
    mobile?: string;
    address?: string;
}
interface Product {
    sale_price: string;
    id: number;
    name_en: string;
    name_ar: string;
    vendor_name?: string;
    pivot: {
        quantity: number;
        price: string;
    };
}
interface OrderItem {
    id: number;
    order_id: number;
    product_id: number;
    quantity: number;
    amount: number;
    tax_amount: number;
    discount_applied: number;
    total_amount: number;
    delivery_status: string;
    attributes?: Record<string, unknown>;
    created_at: string;
    updated_at: string;
    product: Product;
}
interface DeliveryTracking {
    tracking_number?: string;
    carrier?: string;
    status?: string;
    estimated_delivery?: string;
    current_location?: string;
    last_update?: string;
    events?: Array<{
        timestamp: string;
        status: string;
        location: string;
        description: string;
    }>;
}
interface Vendor {
    id: number;
    name: string;
    email: string;
    mobile?: string;
    use_armada_delivery?: boolean;
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
    order_code: string;
    user_id: number;
    coupon_id?: string;
    shipping_address?: string;
    billing_address: string;
    total_items: number;
    sub_total_amount: number;
    tax_amount: number;
    discount_amount: number;
    total_amount: number;
    order_status: string;
    payment_status: string;
    delivery_status: string;
    refund_status?: string;
    refund_approved_by?: string;
    refund_approver?: {
        id: number;
        full_name: string;
        email: string;
    };
    refund_requested_at?: string | null;
    refund_rejection_reason_en?: string | null;
    refund_rejection_reason_ar?: string | null;
    payment_method?: string;
    transaction_id?: string;
    created_at: string;
    updated_at: string;
    user: User;
    vendor?: Vendor;
    order_items?: OrderItem[];
    is_refundable?: boolean;
    shipping_fee?: number;
}
interface VendorOrderDetailsModalProps {
    isOpen: boolean;
    onClose: () => void;
    order: Order | null;
}

const VendorOrderDetailsModal: React.FC<VendorOrderDetailsModalProps> = ({ isOpen, onClose, order }) => {
    const [activeTab, setActiveTab] = useState('summary');
    const [showRejectForm, setShowRejectForm] = useState(false);
    const [rejectReasonEN, setRejectReasonEN] = useState('');
    const [rejectReasonAR, setRejectReasonAR] = useState('');
    const [loading, setLoading] = useState(false);
    const [trackingData, setTrackingData] = useState<DeliveryTracking | null>(null);
    const [fetchingTracking, setFetchingTracking] = useState(false);
    const [showEmailModal, setShowEmailModal] = useState(false);
    const [showVendorContactModal, setShowVendorContactModal] = useState(false);
    const [emailSubject, setEmailSubject] = useState('');
    const [emailMessage, setEmailMessage] = useState('');
    const [vendorContactSubject, setVendorContactSubject] = useState('');
    const [vendorContactMessage, setVendorContactMessage] = useState('');
    const [sendingEmail, setSendingEmail] = useState(false);

    // Fetch delivery tracking data
    const fetchTrackingData = useCallback(async () => {
        if (!order) return;
        setFetchingTracking(true);
        try {
            const response = await fetch(`/vendor/orders/${order.id}`, {
                headers: {
                    'Accept': 'application/json',
                    'X-Requested-With': 'XMLHttpRequest'
                }
            });
            
            // Check if response is JSON
            const contentType = response.headers.get('content-type');
            if (!contentType || !contentType.includes('application/json')) {
                throw new Error('Server returned non-JSON response. Please try again later.');
            }
            
            const data = await response.json();
            
            // Handle KYC error specifically
            if (response.status === 403 && data.error === 'KYC not approved') {
                console.error('KYC not approved. Please complete your KYC verification to access this feature.');
                // Optionally redirect to KYC page
                if (data.redirect_to) {
                    window.location.href = data.redirect_to;
                }
                return;
            }
            
            if (data && data.tracking_number) {
                setTrackingData({
                    tracking_number: data.tracking_number,
                    carrier: data.courier_partner || '',
                    status: data.delivery_status || '',
                });
            } else {
                setTrackingData(null);
            }
        } catch (error) {
            console.error('Failed to fetch tracking data:', error);
            setTrackingData(null);
        } finally {
            setFetchingTracking(false);
        }
    }, [order]);

    useEffect(() => {
        if (isOpen && order) {
            fetchTrackingData();
        }
    }, [fetchTrackingData, isOpen, order]);

    if (!order) return null;

    // Approve refund
    const handleApprove = () => {
        setLoading(true);
        router.post(
            route('orders.refund.approve', order.id),
            {},
            {
                onSuccess: () => {
                    setLoading(false);
                    onClose();
                },
                preserveState: false,
                preserveScroll: true,
            },
        );
    };

    // Reject refund
    const handleReject = () => {
        setLoading(true);
        router.post(
            route('orders.refund.reject', order.id),
            {
                refund_rejection_reason_en: rejectReasonEN,
                refund_rejection_reason_ar: rejectReasonAR,
            },
            {
                onSuccess: () => {
                    setLoading(false);
                    onClose();
                },
                preserveState: false,
                preserveScroll: true,
            },
        );
    };

    // Handle download invoice
    const handleDownloadInvoice = (orderId: number) => {
        window.open(route('orders.invoice', orderId), '_blank');
    };

    // Handle send email to customer
    const handleSendEmailToCustomer = async () => {
        if (!order || !emailSubject || !emailMessage) return;

        setSendingEmail(true);
        try {
            await router.post(
                route('orders.send-email', order.id),
                {
                    subject: emailSubject,
                    message: emailMessage,
                },
                {
                    preserveState: false,
                    preserveScroll: true,
                    onSuccess: (page) => {
                        const flash = page.props.flash as { success?: string; error?: string };
                        if (flash?.success) {
                            setShowEmailModal(false);
                            setEmailSubject('');
                            setEmailMessage('');
                        } else if (flash?.error) {
                            toast.error('Failed to send email: ' + flash.error);
                        }
                    },
                    onError: (errors) => {
                        console.error('Email errors:', errors);
                        toast.error('Error sending email: ' + Object.values(errors).join(', '));
                    },
                    onFinish: () => {
                        setSendingEmail(false);
                    },
                },
            );
        } catch (error) {
            console.error('Email error:', error);
            toast.error('Error sending email: ' + (error instanceof Error ? error.message : 'Unknown error'));
            setSendingEmail(false);
        }
    };

    // Handle contact vendor
    const handleContactVendor = async () => {
        if (!order || !vendorContactSubject || !vendorContactMessage) return;

        setSendingEmail(true);
        try {
            await router.post(
                route('orders.contact-vendor', order.id),
                {
                    subject: vendorContactSubject,
                    message: vendorContactMessage,
                },
                {
                    preserveState: false,
                    preserveScroll: true,
                    onSuccess: (page) => {
                        const flash = page.props.flash as { success?: string; error?: string };
                        if (flash?.success) {
                            setShowVendorContactModal(false);
                            setVendorContactSubject('');
                            setVendorContactMessage('');
                        } else if (flash?.error) {
                            toast.error('Failed to send email: ' + flash.error);
                        }
                    },
                    onError: (errors: any) => {
                        console.error('Email errors:', errors);
                        toast.error('Error sending email: ' + Object.values(errors).join(', '));
                    },
                    onFinish: () => {
                        setSendingEmail(false);
                    },
                },
            );
        } catch (error) {
            console.error('Email error:', error);
            toast.error('Error sending email: ' + (error instanceof Error ? error.message : 'Unknown error'));
            setSendingEmail(false);
        }
    };

    // Show refund status label
    const refundStatusLabel = (status: string | null | undefined) => {
        if (!status) return 'No refund';
        if (status === 'pending') return 'Pending';
        if (status === 'approved') return 'Approved';
        if (status === 'rejected') return 'Rejected';
        return status;
    };

    // Get status badge color
    const getStatusBadge = (status: string) => {
        switch (status.toLowerCase()) {
            case 'pending':
                return (
                    <Badge variant="secondary">
                        <Clock className="mr-1 h-3 w-3" />
                        Pending
                    </Badge>
                );
            case 'processing':
                return (
                    <Badge variant="default">
                        <Package className="mr-1 h-3 w-3" />
                        Processing
                    </Badge>
                );
            case 'completed':
                return (
                    <Badge variant="default" className="bg-green-500">
                        <CheckCircle className="mr-1 h-3 w-3" />
                        Completed
                    </Badge>
                );
            case 'refunded':
                return (
                    <Badge variant="destructive">
                        <AlertTriangle className="mr-1 h-3 w-3" />
                        Refunded
                    </Badge>
                );
            default:
                return <Badge>{status}</Badge>;
        }
    };

    return (
        <>
            <Head title="Order Details" />
            <Dialog open={isOpen} onOpenChange={onClose}>
                <DialogContent className="no-vertical-scrollbar max-h-[90vh] max-w-4xl overflow-y-auto">
                    <DialogHeader>
                        <DialogTitle>Order Details: #{order?.order_code}</DialogTitle>
                        <DialogDescription>Complete order information and management</DialogDescription>
                    </DialogHeader>
                    <Tabs value={activeTab} onValueChange={setActiveTab} className="w-full">
                        <TabsList className="grid w-full grid-cols-5">
                            <TabsTrigger value="summary">Summary</TabsTrigger>
                            <TabsTrigger value="customer">Customer</TabsTrigger>
                            <TabsTrigger value="products">Products</TabsTrigger>
                            <TabsTrigger value="tracking">Tracking</TabsTrigger>
                        </TabsList>
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
                                                {getStatusBadge(
                                                    order?.order_status
                                                        ? order?.order_status.replace(/_/g, ' ').replace(/\b\w/g, (l) => l.toUpperCase())
                                                        : '',
                                                )}
                                            </span>
                                        </div>
                                        <div className="flex justify-between">
                                            <span>Total Amount:</span>
                                            <span className="font-bold">KWD {order?.total_amount}</span>
                                        </div>
                                        <div className="flex justify-between">
                                            <span>Subtotal:</span>
                                            <span>KWD {order?.sub_total_amount}</span>
                                        </div>
                                        <div className="flex justify-between">
                                            <span>Tax:</span>
                                            <span>KWD {order?.tax_amount}</span>
                                        </div>
                                        <div className="flex justify-between">
                                            <span>Discount:</span>
                                            <span>KWD {order?.discount_amount}</span>
                                        </div>
                                        <div className="flex justify-between">
                                            <span>Shipping Fee:</span>
                                            <span>KWD {order?.shipping_fee}</span>
                                        </div>
                                        <div className="flex justify-between">
                                            <span>Payment Method:</span>
                                            <span className="rounded bg-yellow-100 px-2 py-1 dark:bg-yellow-900">
                                                {order?.payment_method
                                                    ? order?.payment_method.replace(/_/g, ' ').replace(/\b\w/g, (l) => l.toUpperCase())
                                                    : 'Credit Card'}
                                            </span>
                                        </div>
                                        <div className="flex justify-between">
                                            <span>Order Date:</span>
                                            <span>{dayjs(order?.created_at).format('YYYY-MM-DD hh:mm:A')}</span>
                                        </div>
                                    </CardContent>
                                </Card>

                                <Card>
                                    <CardHeader>
                                        <CardTitle>Quick Actions</CardTitle>
                                    </CardHeader>
                                    <CardContent className="space-y-2 p-4 flex items-center gap-5">
                                        <Button className="w-full dark:bg-white dark:text-black m-0" variant="outline" onClick={() => handleDownloadInvoice(order?.id)}>
                                            Download Invoice
                                        </Button>
                                        <Button className="w-full dark:bg-white dark:text-black m-0" variant="outline" onClick={() => setShowEmailModal(true)}>
                                            Send Email to Customer
                                        </Button>
                                        <Button className="w-full dark:bg-white dark:text-black m-0" variant="outline" onClick={() => setShowVendorContactModal(true)}>
                                            Contact Vendor
                                        </Button>
                                    </CardContent>
                                </Card>
                            </div>
                        </TabsContent>
                        <TabsContent value="customer" className="space-y-4 p-4">
                            <Card className="mb-4">
                                <CardHeader>
                                    <CardTitle>Customer Information</CardTitle>
                                </CardHeader>
                                <CardContent className="space-y-2 p-4">
                                    <div>
                                        <strong>Name:</strong> {order?.user.full_name}
                                    </div>
                                    <div>
                                        <strong>Email:</strong> {order?.user.email}
                                    </div>
                                    <div>
                                        <strong>Mobile:</strong> {order?.user.mobile || 'Not provided'}
                                    </div>
                                    <div>
                                        <strong>Address:</strong> {order?.user.address || 'Not provided'}
                                    </div>
                                </CardContent>
                            </Card>
                            <Card className="mb-4">
                                <CardHeader>
                                    <CardTitle>Order Information</CardTitle>
                                </CardHeader>
                                <CardContent className="space-y-2 p-4">
                                    <div>
                                        <strong>Order ID:</strong> #{order?.order_code}
                                    </div>
                                    <div>
                                        <strong>Payment Status:</strong>{' '}
                                        <Badge variant="outline" className="ml-2 bg-yellow-100 text-yellow-800">
                                            {order?.payment_status.charAt(0).toUpperCase() + order?.payment_status.slice(1)}
                                        </Badge>
                                    </div>
                                    <div>
                                        <strong>Delivery Status:</strong>{' '}
                                        <Badge variant="outline" className="ml-2 bg-blue-100 text-blue-800">
                                            {order?.delivery_status.charAt(0).toUpperCase() + order?.delivery_status.slice(1)}
                                        </Badge>
                                    </div>
                                    <div>
                                        <strong>Total Items:</strong> {order?.total_items}
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
                                        <p className="text-sm whitespace-pre-line">{formatAddress(order?.shipping_address)}</p>
                                    </div>
                                    <div>
                                        <h4 className="mb-2 font-semibold">Pickup Address</h4>
                                        <p className="text-sm ">
                                            {order?.vendor?.user?.addresses && order.vendor.user.addresses.length > 0
                                                ? (() => {
                                                    const vendorAddress = order.vendor.user.addresses[0];
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
                        <TabsContent value="products" className="space-y-4 p-4">
                            <Card>
                                <CardHeader>
                                    <CardTitle>Ordered Products</CardTitle>
                                </CardHeader>
                                <CardContent className="p-4">
                                    {order?.order_items && order?.order_items.length > 0 ? (
                                        <div className="space-y-3">
                                            {order?.order_items.map((item: OrderItem) => {
                                                let salePrice = item.product?.sale_price;
                                                if (salePrice == null && item.amount && item.quantity) {
                                                    salePrice = (item.amount / item.quantity).toFixed(2);
                                                }
                                                return (
                                                    <div key={item.id} className="flex items-center justify-between rounded border p-3">
                                                        <div>
                                                            <div className="font-medium">{item.product.name_en}</div>
                                                            <div className="text-sm text-gray-500">
                                                                Qty: {item.quantity} × KWD {salePrice ?? '-'}
                                                            </div>
                                                        </div>
                                                        <div className="font-bold">KWD {item.amount}</div>
                                                    </div>
                                                );
                                            })}
                                        </div>
                                    ) : (
                                        <p className="text-gray-500">No products found for this order?.</p>
                                    )}
                                </CardContent>
                            </Card>
                        </TabsContent>
                        <TabsContent value="tracking" className="space-y-4 p-4">
                            <Card>
                                <CardHeader>
                                    <CardTitle className="flex items-center">
                                        <Truck className="mr-2 h-5 w-5" />
                                        Delivery Tracking
                                    </CardTitle>
                                </CardHeader>
                                <CardContent className="p-4">
                                    {fetchingTracking ? (
                                        <p className="py-8 text-center">Loading tracking data...</p>
                                    ) : trackingData?.tracking_number ? (
                                        <div className="space-y-4">
                                            <div className="grid grid-cols-1 gap-4 md:grid-cols-2">
                                                <div>
                                                    <strong>Tracking Number:</strong> {trackingData.tracking_number}
                                                </div>
                                                <div>
                                                    <strong>Carrier:</strong> {trackingData?.carrier || 'Unknown'}
                                                </div>
                                                <div>
                                                    <strong>Status:</strong>
                                                    <span className="ml-2 inline-block rounded bg-blue-100 px-2 py-1 text-xs font-semibold text-blue-800">
                                                        {trackingData?.status
                                                            ? trackingData.status.charAt(0).toUpperCase() + trackingData.status.slice(1)
                                                            : 'Unknown'}
                                                    </span>
                                                </div>
                                                <div>
                                                    <strong>Estimated Delivery:</strong> {trackingData?.estimated_delivery || 'Not available'}
                                                </div>
                                            </div>

                                            {trackingData?.events && (
                                                <div>
                                                    <h4 className="mb-3 font-semibold">Tracking Events</h4>
                                                    <div className="space-y-3">
                                                        {trackingData.events.map((event, index) => (
                                                            <div key={index} className="flex items-start space-x-3 rounded border p-3">
                                                                <div className="mt-2 h-2 w-2 rounded-full bg-blue-500"></div>
                                                                <div className="flex-1">
                                                                    <div className="font-medium">{event.status}</div>
                                                                    <div className="text-sm text-gray-500">{event.location}</div>
                                                                    <div className="text-sm text-gray-600">{event.description}</div>
                                                                    <div className="mt-1 text-xs text-gray-400">
                                                                        {new Date(event.timestamp).toLocaleString()}
                                                                    </div>
                                                                </div>
                                                            </div>
                                                        ))}
                                                    </div>
                                                </div>
                                            )}

                                            <Button onClick={fetchTrackingData} disabled={fetchingTracking} className="w-full">
                                                {fetchingTracking ? 'Refreshing...' : 'Refresh Tracking'}
                                            </Button>
                                        </div>
                                    ) : (
                                        <p className="text-gray-500">No tracking information available for this order?.</p>
                                    )}
                                </CardContent>
                            </Card>
                        </TabsContent>
                    </Tabs>
                    {/* Refund Management */}
                    <div className="mt-6 border-t pt-4">
                        <h3 className="mb-2 font-semibold">Refund Management</h3>
                        <div className="flex items-center gap-2">
                            <strong>Status:</strong>
                            <span
                                className={`inline-block rounded px-2 py-1 text-xs font-semibold ${
                                    order?.refund_status === 'approved'
                                        ? 'bg-green-100 text-green-800'
                                        : order?.refund_status === 'rejected'
                                          ? 'bg-red-100 text-red-800'
                                          : order?.refund_status === 'pending'
                                            ? 'bg-yellow-100 text-yellow-800'
                                            : 'bg-gray-100 text-gray-800'
                                } `}
                            >
                                {refundStatusLabel(order?.refund_status)}
                            </span>
                        </div>
                        {order?.refund_requested_at && (
                            <div className="mt-1 text-sm text-gray-600">
                                <strong>Refund Requested At:</strong> {dayjs(order?.refund_requested_at).format('YYYY-MM-DD hh:mm:A')}
                            </div>
                        )}

                        {order?.refund_status === 'pending' && !showRejectForm && (
                            <div className="mt-2 flex gap-2">
                                <Button onClick={handleApprove} disabled={loading}>
                                    Approve
                                </Button>
                                <Button variant="destructive" onClick={() => setShowRejectForm(true)} disabled={loading}>
                                    Reject
                                </Button>
                            </div>
                        )}
                        {order?.refund_status === 'pending' && showRejectForm && (
                            <div className="mt-2 space-y-2">
                                <div>
                                    <label className="mb-1 block text-sm font-medium">Rejection Reason (EN)</label>
                                    <Textarea
                                        placeholder="Enter rejection reason in English"
                                        value={rejectReasonEN}
                                        onChange={(e) => setRejectReasonEN(e.target.value)}
                                        className="min-h-[80px]"
                                    />
                                </div>
                                <div>
                                    <label className="mb-1 block text-sm font-medium">Rejection Reason (AR)</label>
                                    <Textarea
                                        placeholder="ادخل سبب الرفض بالعربية"
                                        value={rejectReasonAR}
                                        onChange={(e) => setRejectReasonAR(e.target.value)}
                                        dir="rtl"
                                        className="min-h-[80px]"
                                    />
                                </div>
                                <div className="mt-2 flex gap-2">
                                    <Button onClick={handleReject} disabled={loading || !rejectReasonEN || !rejectReasonAR}>
                                        Submit Rejection
                                    </Button>
                                    <Button variant="outline" onClick={() => setShowRejectForm(false)} disabled={loading}>
                                        Cancel
                                    </Button>
                                </div>
                            </div>
                        )}
                        {order?.refund_status === 'rejected' && (
                            <div className="mt-2">
                                <p>
                                    <strong>Rejection Reason (EN):</strong> {order?.refund_rejection_reason_en}
                                </p>
                                <p>
                                    <strong>Rejection Reason (AR):</strong> {order?.refund_rejection_reason_ar}
                                </p>
                                <p>
                                    <strong>Rejected By:</strong> {order?.refund_approver 
                                        ? (order.refund_approver.full_name 
                                            ? `${order.refund_approver.full_name}${order.refund_approver.email ? ` (${order.refund_approver.email})` : ''}`
                                            : order.refund_approver.email || 'N/A')
                                        : (order?.refund_approved_by || 'N/A')}
                                </p>
                            </div>
                        )}
                        {order?.refund_status === 'approved' && (
                            <div className="mt-2">
                                <p className="font-semibold text-green-600">
                                    Refund Approved by {order?.refund_approver 
                                        ? (order.refund_approver.full_name 
                                            ? `${order.refund_approver.full_name}${order.refund_approver.email ? ` (${order.refund_approver.email})` : ''}`
                                            : order.refund_approver.email || 'N/A')
                                        : (order?.refund_approved_by || 'N/A')}
                                </p>
                            </div>
                        )}
                        {!order?.refund_status && <div className="mt-2 text-gray-500">No refund requested for this order?.</div>}
                    </div>
                </DialogContent>
            </Dialog>

            {/* Email to Customer Modal */}
            <Dialog open={showEmailModal} onOpenChange={setShowEmailModal}>
                <DialogContent className="max-w-md">
                    <DialogHeader>
                        <DialogTitle>Send Email to Customer</DialogTitle>
                        <DialogDescription>Send a custom email to the customer about this order?.</DialogDescription>
                    </DialogHeader>
                    <div className="space-y-4">
                        <div>
                            <label className="mb-1 block text-sm font-medium">Subject</label>
                            <Input value={emailSubject} onChange={(e) => setEmailSubject(e.target.value)} placeholder="Enter email subject" />
                        </div>
                        <div>
                            <label className="mb-1 block text-sm font-medium">Message</label>
                            <Textarea
                                value={emailMessage}
                                onChange={(e) => setEmailMessage(e.target.value)}
                                placeholder="Enter your message"
                                className="min-h-[100px] text-start"
                            />
                        </div>
                        <div className="flex gap-2">
                            <Button onClick={handleSendEmailToCustomer} disabled={sendingEmail || !emailSubject || !emailMessage} className="flex-1">
                                {sendingEmail ? 'Sending...' : 'Send Email'}
                            </Button>
                            <Button variant="outline" onClick={() => setShowEmailModal(false)} disabled={sendingEmail}>
                                Cancel
                            </Button>
                        </div>
                    </div>
                </DialogContent>
            </Dialog>

            {/* Contact Vendor Modal */}
            <Dialog open={showVendorContactModal} onOpenChange={setShowVendorContactModal}>
                <DialogContent className="max-w-md">
                    <DialogHeader>
                        <DialogTitle>Contact Vendor</DialogTitle>
                        <DialogDescription>Send a message to the vendor(s) about this order?.</DialogDescription>
                    </DialogHeader>
                    <div className="space-y-4">
                        <div>
                            <label className="mb-1 block text-sm font-medium">Subject</label>
                            <Input
                                value={vendorContactSubject}
                                onChange={(e) => setVendorContactSubject(e.target.value)}
                                placeholder="Enter email subject"
                            />
                        </div>
                        <div>
                            <label className="mb-1 block text-sm font-medium">Message</label>
                            <Textarea
                                value={vendorContactMessage}
                                onChange={(e) => setVendorContactMessage(e.target.value)}
                                placeholder="Enter your message"
                                className="min-h-[100px] text-start"
                            />
                        </div>
                        <div className="flex gap-2">
                            <Button
                                onClick={handleContactVendor}
                                disabled={sendingEmail || !vendorContactSubject || !vendorContactMessage}
                                className="flex-1"
                            >
                                {sendingEmail ? 'Sending...' : 'Send Email'}
                            </Button>
                            <Button variant="outline" onClick={() => setShowVendorContactModal(false)} disabled={sendingEmail}>
                                Cancel
                            </Button>
                        </div>
                    </div>
                </DialogContent>
            </Dialog>
        </>
    );
};

export default VendorOrderDetailsModal;
