/* eslint-disable @typescript-eslint/no-explicit-any */
import { ActionButtonDelete } from '@/components/action-button';
import { useLanguage } from '@/components/language-context';
import { StatusFilter } from '@/components/ui/StatusFilter';
import { Badge } from '@/components/ui/badge';
import { Button } from '@/components/ui/button';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Dialog, DialogContent, DialogDescription, DialogHeader, DialogTitle } from '@/components/ui/dialog';
import { Input } from '@/components/ui/input';
import { Pagination } from '@/components/ui/pagination';
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs';
import { Textarea } from '@/components/ui/textarea';
import { toast } from 'react-hot-toast';
import AppLayout from '@/layouts/app-layout';
import { Head, router, usePage } from '@inertiajs/react';
import dayjs from 'dayjs';
import { throttle } from 'lodash';
import { AlertTriangle, CheckCircle, Clock, Package, Truck } from 'lucide-react';
import { useCallback, useEffect, useRef, useState } from 'react';
import ExportButton from '@/components/export-button';
import * as RadixCheckbox from '@radix-ui/react-checkbox';
import { CheckIcon } from '@radix-ui/react-icons';
import { formatAddress } from '@/utils/formatAddress';


interface User {
    id: number;
    full_name: string;
    email: string;
    mobile?: string;
    address?: string;
}
interface Vendor {
    id: number;
    name: string;
    email: string; // Make email required
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

interface Product {
    sale_price: string;
    id: number;
    name_en: string;
    name_ar: string;
    vendor?: Vendor;
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
    is_ready?: number;
    is_dispatched?: number;
    in_transit?: number;
    is_delivered?: number;
    is_rto?: number;
    is_rto_recieved?: number;
}
interface Order {
    id: number;
    order_code: number;
    user_id: number;
    coupon_id?: string;
    shipping_address: string;
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
    vendor: Vendor;
    orderItems?: OrderItem[];
    is_refundable?: boolean;
    shipping_fee?: number;
    armada_response?: any;
    armada_tracking_number?: string;
    armada_order_id?: string;
    is_armada_synced?: boolean;
}

// Full-featured OrderDetailsModal from Orders/Index.tsx
function OrderDetailsModal({ order, isOpen, onClose }: { order: Order | null; isOpen: boolean; onClose: () => void }) {
    const { t } = useLanguage();
    const [activeTab, setActiveTab] = useState('summary');
    const [showRejectForm, setShowRejectForm] = useState(false);
    const [rejectReasonEN, setRejectReasonEN] = useState('');
    const [rejectReasonAR, setRejectReasonAR] = useState('');
    const [loading, setLoading] = useState(false);
    // Default tracking data for new orders or no tracking info
    const defaultTrackingData = {
        is_ready: 0,
        is_dispatched: 0,
        in_transit: 0,
        is_delivered: 0,
        is_rto: 0,
        is_rto_recieved: 0,
        // Add other fields as needed
    };

    const [trackingData, setTrackingData] = useState<any>(defaultTrackingData);
    const [trackingEvents, setTrackingEvents] = useState<any[]>([]);
    const [fetchingTracking, setFetchingTracking] = useState(false);
    const [showEmailModal, setShowEmailModal] = useState(false);
    const [showVendorContactModal, setShowVendorContactModal] = useState(false);
    const [emailSubject, setEmailSubject] = useState('');
    const [emailMessage, setEmailMessage] = useState('');
    const [vendorContactSubject, setVendorContactSubject] = useState('');
    const [vendorContactMessage, setVendorContactMessage] = useState('');
    const [sendingEmail, setSendingEmail] = useState(false);
    const [showApproveConfirm, setShowApproveConfirm] = useState(false);
    const [trackingError, setTrackingError] = useState<string | null>(null);

    // Fetch delivery tracking data
    const fetchTrackingData = useCallback(async () => {
        if (!order) return;
        setFetchingTracking(true);
        try {
            const response = await fetch(`/orders/${order.id}/tracking`);
            const data = await response.json();
            if (data && data.tracking_number) {
                setTrackingData({
                    tracking_number: data.tracking_number,
                    carrier: data.courier_partner || '',
                    status: data.delivery_status || '',
                    is_ready: data.is_ready == 1 ? 1 : 0,
                    is_dispatched: data.is_dispatched == 1 ? 1 : 0,
                    in_transit: data.in_transit == 1 ? 1 : 0,
                    is_delivered: data.is_delivered == 1 ? 1 : 0,
                    is_rto: data.is_rto == 1 ? 1 : 0,
                    is_rto_recieved: data.is_rto_recieved == 1 ? 1 : 0,
                });
                // Set timeline events (single event)
                setTrackingEvents(data.events || []);
            } else {
                setTrackingData(null);
                setTrackingEvents([]);
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
    }, [isOpen, order]);

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
                            toast.success('Email sent successfully!');
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
                            toast.success('Email sent successfully!');
                            setShowVendorContactModal(false);
                            setVendorContactSubject('');
                            setVendorContactMessage('');
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

    // Show refund status label
    const refundStatusLabel = (status: string | null | undefined) => {
        if (!status) return t('orders.noRefund');
        if (status === 'pending') return t('orders.pending');
        if (status === 'approved') return t('orders.approved');
        if (status === 'rejected') return t('orders.rejected');
        return status;
    };

    // Get status badge color
    const getStatusBadge = (status: string) => {
        switch (status.toLowerCase()) {
            case 'pending':
                return (
                    <Badge variant="secondary">
                        <Clock className="mr-1 h-3 w-3" />
                        {t('orders.pending')}
                    </Badge>
                );
            case 'processing':
                return (
                    <Badge variant="default">
                        <Package className="mr-1 h-3 w-3" />
                        {t('orders.processing')}
                    </Badge>
                );
            case 'completed':
                return (
                    <Badge variant="default" className="bg-green-500">
                        <CheckCircle className="mr-1 h-3 w-3" />
                        {t('orders.completed')}
                    </Badge>
                );
            case 'refunded':
                return (
                    <Badge variant="destructive">
                        <AlertTriangle className="mr-1 h-3 w-3" />
                        {t('orders.refunded')}
                    </Badge>
                );
            default:
                return <Badge>{status}</Badge>;
        }
    };

    return (
        <>
            <Head title={t('orders.orderDetails')} />
            <Dialog open={isOpen} onOpenChange={onClose}>
                <DialogContent className="max-h-[90vh] !max-w-4xl overflow-y-auto">
                    <DialogHeader>
                        <DialogTitle>{t('orders.orderDetails')}: #{order.order_code}</DialogTitle>
                        <DialogDescription>Complete order information and management</DialogDescription>
                    </DialogHeader>

                    <Tabs value={activeTab} onValueChange={setActiveTab} className="w-full">
                        <TabsList className="grid w-full grid-cols-5">
                            <TabsTrigger value="summary">Summary</TabsTrigger>
                            <TabsTrigger value="customer">{t('orders.customer')}</TabsTrigger>
                            <TabsTrigger value="refund">Refund</TabsTrigger>
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
                                            <span>{t('orders.statusLabel')}</span>
                                            <span>
                                                {getStatusBadge(
                                                    order.order_status
                                                        ? order.order_status.replace(/_/g, ' ').replace(/\b\w/g, (l) => l.toUpperCase())
                                                        : '',
                                                )}
                                            </span>
                                        </div>
                                        <div className="flex justify-between">
                                            <span>{t('orders.totalAmount')}</span>
                                            <span className="font-bold">KWD {order.total_amount}</span>
                                        </div>
                                        <div className="flex justify-between">
                                            <span>Subtotal:</span>
                                            <span>KWD {order.sub_total_amount}</span>
                                        </div>
                                        <div className="flex justify-between">
                                            <span>Tax:</span>
                                            <span>KWD {order.tax_amount}</span>
                                        </div>
                                        <div className="flex justify-between">
                                            <span>Discount:</span>
                                            <span>KWD {order.discount_amount}</span>
                                        </div>
                                        <div className="flex justify-between">
                                            <span>Shipping Fee:</span>
                                            <span>KWD {order.shipping_fee}</span>
                                        </div>
                                        <div className="flex justify-between">
                                            <span>{t('orders.paymentMethod')}</span>
                                            <span className="rounded bg-yellow-100 px-2 py-1 dark:bg-yellow-900">
                                                {order.payment_method
                                                    ? order.payment_method.replace(/_/g, ' ').replace(/\b\w/g, (l) => l.toUpperCase())
                                                    : 'Credit Card'}
                                            </span>
                                        </div>
                                        <div className="flex justify-between">
                                            <span>{t('orders.orderDate')}</span>
                                            <span>{dayjs(order.created_at).format('YYYY-MM-DD hh:mm:A')}</span>
                                        </div>
                                    </CardContent>
                                </Card>

                                <Card>
                                    <CardHeader>
                                        <CardTitle>Quick Actions</CardTitle>
                                    </CardHeader>
                                    <CardContent className="space-y-2 p-4 flex items-center gap-5">
                                        <Button className="w-full dark:bg-white dark:text-black m-0" onClick={() => handleDownloadInvoice(order.id)}>
                                            Download Invoice
                                        </Button>
                                        <Button className="w-full dark:bg-white dark:text-black m-0" onClick={() => setShowEmailModal(true)}>
                                            {t('orders.sendEmailToCustomer')}
                                        </Button>
                                        <Button className="w-full dark:bg-white dark:text-black m-0" onClick={() => setShowVendorContactModal(true)}>
                                            Contact Vendor
                                        </Button>
                                    </CardContent>
                                </Card>
                            </div>
                        </TabsContent>
                        <TabsContent value="customer" className="space-y-4 p-4">
                            <Card className="mb-4">
                                <CardHeader>
                                    <CardTitle>{t('orders.customerInformation')}</CardTitle>
                                </CardHeader>
                                <CardContent className="space-y-2 p-4">
                                    <div>
                                        <strong>Name:</strong> {order.user.full_name}
                                    </div>
                                    <div>
                                        <strong>Email:</strong> {order.user.email}
                                    </div>
                                    <div>
                                        <strong>Mobile:</strong> {order.user.mobile || 'Not provided'}
                                    </div>
                                    <div>
                                        <strong>Address:</strong> {order.user.address || 'Not provided'}
                                    </div>
                                </CardContent>
                            </Card>
                            <Card className="mb-4">
                                <CardHeader>
                                    <CardTitle>Order Information</CardTitle>
                                </CardHeader>
                                <CardContent className="space-y-2 p-4">
                                    <div>
                                        <strong>{t('orders.orderIdLabel')}</strong> #{order.order_code}
                                    </div>
                                    <div>
                                        <strong>{t('orders.paymentStatusLabel')}</strong>{' '}
                                        <Badge variant="outline" className="ml-2 bg-yellow-100 text-yellow-800">
                                            {order.payment_status.charAt(0).toUpperCase() + order.payment_status.slice(1)}
                                        </Badge>
                                    </div>
                                    <div>
                                        <strong>{t('orders.deliveryStatusLabel')}</strong>{' '}
                                        <Badge variant="outline" className="ml-2 bg-blue-100 text-blue-800">
                                            {order.delivery_status.charAt(0).toUpperCase() + order.delivery_status.slice(1)}
                                        </Badge>
                                    </div>
                                    <div>
                                        <strong>{t('orders.totalItems')}</strong> {order.total_items}
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
                                        <p className="text-sm whitespace-pre-line">{formatAddress(order.shipping_address)}</p>
                                    </div>
                                    <div>
                                        <h4 className="mb-2 font-semibold">Pickup Address</h4>
                                        <p className="text-sm ">
                                            {order.vendor?.user?.addresses && order.vendor.user.addresses.length > 0
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
                        <TabsContent value="refund" className="space-y-4 p-4">
                            <Card>
                                <CardHeader>
                                    <CardTitle>{t('orders.refundManagement')}</CardTitle>
                                </CardHeader>
                                <CardContent>
                                    <div className="flex items-center gap-2 mb-2">
                                        <strong>{t('orders.statusLabel')}</strong>
                                        <span
                                            className={`inline-block rounded px-2 py-1 text-xs font-semibold ${order.refund_status === 'approved'
                                                ? 'bg-green-100 text-green-800'
                                                : order.refund_status === 'rejected'
                                                    ? 'bg-red-100 text-red-800'
                                                    : order.refund_status === 'pending'
                                                        ? 'bg-yellow-100 text-yellow-800'
                                                        : 'bg-gray-100 text-gray-800'
                                                } `}
                                        >
                                            {refundStatusLabel(order.refund_status)}
                                        </span>
                                    </div>
                                    {/* Refund request timestamp */}
                                    {order.refund_requested_at && (
                                        <div className="mb-2 text-sm text-gray-600">
                                            <strong>Refund Requested At:</strong> {dayjs(order.refund_requested_at).format('YYYY-MM-DD hh:mm:A')}
                                        </div>
                                    )}

                                    {order.refund_status === 'pending' && !showRejectForm && (
                                        <div className="mt-2 flex gap-2">
                                            <Button onClick={() => setShowApproveConfirm(true)} disabled={loading}>
                                                {t('orders.approve')}
                                            </Button>
                                            <Button variant="destructive" onClick={() => setShowRejectForm(true)} disabled={loading}>
                                                {t('orders.reject')}
                                            </Button>
                                        </div>
                                    )}
                                    {order.refund_status === 'pending' && showRejectForm && (
                                        <div className="mt-2 space-y-2">
                                            <div>
                                                <label className="mb-1 block text-sm font-medium">{t('orders.rejectionReasonEn')}</label>
                                                <Textarea
                                                    placeholder="Enter rejection reason in English"
                                                    value={rejectReasonEN}
                                                    onChange={(e: React.ChangeEvent<HTMLTextAreaElement>) => setRejectReasonEN(e.target.value)}
                                                    className="min-h-[80px]"
                                                />
                                            </div>
                                            <div>
                                                <label className="mb-1 block text-sm font-medium">{t('orders.rejectionReasonAr')}</label>
                                                <Textarea
                                                    placeholder="ادخل سبب الرفض بالعربية"
                                                    value={rejectReasonAR}
                                                    onChange={(e: React.ChangeEvent<HTMLTextAreaElement>) => setRejectReasonAR(e.target.value)}
                                                    dir="rtl"
                                                    className="min-h-[80px]"
                                                />
                                            </div>
                                            <div className="mt-2 flex gap-2">
                                                <Button onClick={handleReject} disabled={loading || !rejectReasonEN || !rejectReasonAR}>
                                                    {t('orders.submitRejection')}
                                                </Button>
                                                <Button variant="outline" onClick={() => setShowRejectForm(false)} disabled={loading}>
                                                    {t('common.cancel')}
                                                </Button>
                                            </div>
                                        </div>
                                    )}
                                    {order.refund_status === 'rejected' && (
                                        <div className="mt-2">
                                            <p>
                                                <strong>{t('orders.rejectionReasonEnLabel')}</strong> {order.refund_rejection_reason_en}
                                            </p>
                                            <p>
                                                <strong>{t('orders.rejectionReasonArLabel')}</strong> {order.refund_rejection_reason_ar}
                                            </p>
                                            <p>
                                                <strong>{t('orders.rejectedBy')}</strong> {order.refund_approver 
                                                    ? (order.refund_approver.full_name 
                                                        ? `${order.refund_approver.full_name}${order.refund_approver.email ? ` (${order.refund_approver.email})` : ''}`
                                                        : order.refund_approver.email || 'N/A')
                                                    : (order.refund_approved_by || 'N/A')}
                                            </p>
                                        </div>
                                    )}
                                    {order.refund_status === 'approved' && (
                                        <div className="mt-2">
                                            <p className="font-semibold text-green-600">
                                                {t('orders.refundApprovedBy')} {order.refund_approver 
                                                    ? (order.refund_approver.full_name 
                                                        ? `${order.refund_approver.full_name}${order.refund_approver.email ? ` (${order.refund_approver.email})` : ''}`
                                                        : order.refund_approver.email || 'N/A')
                                                    : (order.refund_approved_by || 'N/A')}
                                            </p>
                                        </div>
                                    )}
                                    {!order.refund_status && <div className="mt-2 text-gray-500">No refund requested for this order.</div>}
                                </CardContent>
                            </Card>
                        </TabsContent>

                        <TabsContent value="products" className="space-y-4 p-4">
                            <Card>
                                <CardHeader>
                                    <CardTitle>Ordered Products</CardTitle>
                                </CardHeader>
                                <CardContent className="p-4">
                                    {order.orderItems && order.orderItems.length > 0 ? (
                                        <div className="space-y-3">
                                            {order.orderItems.map((item: OrderItem) => {
                                                const productName = item.product.name_en;
                                                // Try to get sale_price from item.product, fallback to item.amount/item.quantity, then '-'
                                                let salePrice = item.product?.sale_price;
                                                if (salePrice == null && item.amount && item.quantity) {
                                                    salePrice = (item.amount / item.quantity).toFixed(2);
                                                }
                                                return (
                                                    <div key={item.id} className="flex items-center justify-between rounded border p-3">
                                                        <div>
                                                            <div className="font-medium">{productName}</div>
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
                                        <p className="text-gray-500">No products found for this order.</p>
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
                                    {/* Check if vendor uses Armada delivery */}
                                    {(() => {
                                        const vendorUsesArmada = order?.vendor?.use_armada_delivery;
                                        
                                        if (vendorUsesArmada) {
                                            // Armada Tracking UI (read-only)
                                            return (
                                                <div className="space-y-4">
                                                    <div className="grid grid-cols-2 gap-4">
                                                        <div>
                                                            <strong>Tracking Number:</strong>
                                                            <Input
                                                                value={trackingData?.tracking_number || order?.armada_tracking_number || ''}
                                                                readOnly
                                                                className="bg-[#171717]"
                                                            />
                                                        </div>
                                                        <div>
                                                            <strong>Carrier:</strong>
                                                            <Input
                                                                value={trackingData?.carrier || 'Armada'}
                                                                readOnly
                                                                className="bg-[#171717]"
                                                            />
                                                        </div>
                                                    </div>
                                                    
                                                    {/* Armada Tracking Link */}
                                                    <div className="mt-4">
                                                        <h3 className="text-lg font-semibold mb-3">Delivery Tracking</h3>
                                                        {(trackingData?.tracking_link || order?.armada_tracking_number || trackingData?.tracking_number) ? (
                                                            <div>
                                                                <a
                                                                    href={
                                                                        trackingData?.tracking_link ||
                                                                        (order?.armada_response as any)?.trackingLink ||
                                                                        (order?.armada_response as any)?.tracking_link ||
                                                                        `https://staging.tracking.armadadelivery.com/${order?.armada_tracking_number || trackingData?.tracking_number}`
                                                                    }
                                                                    target="_blank"
                                                                    rel="noopener noreferrer"
                                                                    className="text-blue-600 hover:text-blue-800 underline cursor-pointer inline-flex items-center gap-2"
                                                                >
                                                                    <Truck className="h-4 w-4" />
                                                                    {trackingData?.tracking_link ||
                                                                        (order?.armada_response as any)?.trackingLink ||
                                                                        (order?.armada_response as any)?.tracking_link ||
                                                                        `https://staging.tracking.armadadelivery.com/${order?.armada_tracking_number || trackingData?.tracking_number}`}
                                                                </a>
                                                            </div>
                                                        ) : (
                                                            <div className="text-gray-500 text-sm">
                                                                Tracking link will be available once the order is synced with Armada.
                                                            </div>
                                                        )}
                                                    </div>
                                                </div>
                                            );
                                        } else {
                                            // Custom Tracking UI - Vendor can add their own tracking
                                            return (
                                                <div className="space-y-4">
                                                    <div className="grid grid-cols-2 gap-4">
                                                        <div>
                                                            <strong>Tracking Number:</strong>
                                                            <Input
                                                                value={trackingData?.tracking_number || ''}
                                                                onChange={e => setTrackingData((td: any) => ({ ...td, tracking_number: e.target.value }))}
                                                                placeholder="Enter tracking number"
                                                            />
                                                        </div>
                                                        <div>
                                                            <strong>Carrier:</strong>
                                                            <Input
                                                                value={trackingData?.carrier || ''}
                                                                onChange={e => setTrackingData((td: any) => ({ ...td, carrier: e.target.value }))}
                                                                placeholder="Enter carrier name"
                                                            />
                                                        </div>
                                                    </div>
                                                    
                                                    {/* Custom Tracking Checkboxes */}
                                                    <div className="grid grid-cols-3 gap-4 mt-4">
                                                        <div>
                                                            <div className="flex items-center gap-2">
                                                                <input
                                                                    type="checkbox"
                                                                    id="vendor_is_ready"
                                                                    checked={trackingData?.is_ready == 1 || trackingData?.is_ready === true}
                                                                    onChange={e => {
                                                                        const isChecked = e.target.checked ? 1 : 0;
                                                                        setTrackingData((td: any) => ({
                                                                            ...td,
                                                                            is_ready: isChecked,
                                                                            ...(isChecked === 0 ? {
                                                                                is_dispatched: 0,
                                                                                in_transit: 0,
                                                                                is_delivered: 0,
                                                                                is_rto: 0,
                                                                                is_rto_recieved: 0,
                                                                            } : {})
                                                                        }));
                                                                    }}
                                                                    className="w-5 h-5 cursor-pointer"
                                                                />
                                                                <span>Ready</span>
                                                            </div>
                                                        </div>
                                                        <div>
                                                            <div className="flex items-center gap-2">
                                                                <input
                                                                    type="checkbox"
                                                                    id="vendor_is_dispatched"
                                                                    checked={trackingData?.is_dispatched == 1 || trackingData?.is_dispatched === true}
                                                                    disabled={!trackingData?.is_ready}
                                                                    onChange={e => {
                                                                        if (!trackingData?.is_ready) return;
                                                                        const isChecked = e.target.checked ? 1 : 0;
                                                                        setTrackingData((td: any) => ({
                                                                            ...td,
                                                                            is_dispatched: isChecked,
                                                                            ...(isChecked === 0 ? {
                                                                                in_transit: 0,
                                                                                is_delivered: 0,
                                                                                is_rto: 0,
                                                                                is_rto_recieved: 0,
                                                                            } : {})
                                                                        }));
                                                                    }}
                                                                    className="w-5 h-5 cursor-pointer disabled:opacity-50"
                                                                />
                                                                <span>Dispatched</span>
                                                            </div>
                                                        </div>
                                                        <div>
                                                            <div className="flex items-center gap-2">
                                                                <input
                                                                    type="checkbox"
                                                                    id="vendor_in_transit"
                                                                    checked={trackingData?.in_transit == 1 || trackingData?.in_transit === true}
                                                                    disabled={!trackingData?.is_dispatched}
                                                                    onChange={e => {
                                                                        if (!trackingData?.is_dispatched) return;
                                                                        const isChecked = e.target.checked ? 1 : 0;
                                                                        setTrackingData((td: any) => ({
                                                                            ...td,
                                                                            in_transit: isChecked,
                                                                            ...(isChecked === 0 ? {
                                                                                is_delivered: 0,
                                                                                is_rto: 0,
                                                                                is_rto_recieved: 0,
                                                                            } : {})
                                                                        }));
                                                                    }}
                                                                    className="w-5 h-5 cursor-pointer disabled:opacity-50"
                                                                />
                                                                <span>In Transit</span>
                                                            </div>
                                                        </div>
                                                        <div>
                                                            <div className="flex items-center gap-2">
                                                                <input
                                                                    type="checkbox"
                                                                    id="vendor_is_delivered"
                                                                    checked={trackingData?.is_delivered == 1 || trackingData?.is_delivered === true}
                                                                    disabled={!trackingData?.in_transit}
                                                                    onChange={e => {
                                                                        if (!trackingData?.in_transit) return;
                                                                        const isChecked = e.target.checked ? 1 : 0;
                                                                        setTrackingData((td: any) => ({
                                                                            ...td,
                                                                            is_delivered: isChecked,
                                                                            ...(isChecked === 0 ? {
                                                                                is_rto: 0,
                                                                                is_rto_recieved: 0,
                                                                            } : {})
                                                                        }));
                                                                    }}
                                                                    className="w-5 h-5 cursor-pointer disabled:opacity-50"
                                                                />
                                                                <span>Delivered</span>
                                                            </div>
                                                        </div>
                                                        <div>
                                                            <div className="flex items-center gap-2">
                                                                <input
                                                                    type="checkbox"
                                                                    id="vendor_is_rto"
                                                                    checked={trackingData?.is_rto == 1 || trackingData?.is_rto === true}
                                                                    disabled={!trackingData?.is_delivered}
                                                                    onChange={e => {
                                                                        if (!trackingData?.is_delivered) return;
                                                                        const isChecked = e.target.checked ? 1 : 0;
                                                                        setTrackingData((td: any) => ({
                                                                            ...td,
                                                                            is_rto: isChecked,
                                                                            ...(isChecked === 0 ? {
                                                                                is_rto_recieved: 0,
                                                                            } : {})
                                                                        }));
                                                                    }}
                                                                    className="w-5 h-5 cursor-pointer disabled:opacity-50"
                                                                />
                                                                <span>RTO</span>
                                                            </div>
                                                        </div>
                                                        <div>
                                                            <div className="flex items-center gap-2">
                                                                <input
                                                                    type="checkbox"
                                                                    id="vendor_is_rto_recieved"
                                                                    checked={trackingData?.is_rto_recieved == 1 || trackingData?.is_rto_recieved === true}
                                                                    disabled={!trackingData?.is_rto}
                                                                    onChange={e => {
                                                                        if (!trackingData?.is_rto) return;
                                                                        setTrackingData((td: any) => ({
                                                                            ...td,
                                                                            is_rto_recieved: e.target.checked ? 1 : 0
                                                                        }));
                                                                    }}
                                                                    className="w-5 h-5 cursor-pointer disabled:opacity-50"
                                                                />
                                                                <span>RTO Received</span>
                                                            </div>
                                                        </div>
                                                    </div>
                                                    
                                                    <Button
                                                        className="w-full mt-4"
                                                        onClick={() => {
                                                            if (!trackingData) {
                                                                alert('Tracking data not loaded. Please refresh and try again.');
                                                                return;
                                                            }
                                                            const rawPayload = {
                                                                order_status: order.order_status,
                                                                delivery_status: trackingData?.status,
                                                                tracking_number: trackingData?.tracking_number,
                                                                courier_partner: trackingData?.carrier,
                                                                tracking_status: trackingData?.status,
                                                                is_ready: trackingData?.is_ready ? 1 : 0,
                                                                is_dispatched: trackingData?.is_dispatched ? 1 : 0,
                                                                in_transit: trackingData?.in_transit ? 1 : 0,
                                                                is_delivered: trackingData?.is_delivered ? 1 : 0,
                                                                is_rto: trackingData?.is_rto ? 1 : 0,
                                                                is_rto_recieved: trackingData?.is_rto_recieved ? 1 : 0,
                                                            };
                                                            const payload = Object.fromEntries(
                                                                Object.entries(rawPayload).filter(([, v]) => v !== '' && v !== null && v !== undefined)
                                                            );
                                                            router.post(`/orders/${order.id}/tracking-update`, payload, {
                                                                onSuccess: () => {
                                                                    toast.success('Tracking updated successfully!');
                                                                    window.location.reload();
                                                                },
                                                                onError: (errors) => {
                                                                    console.error('Tracking update failed:', errors);
                                                                    toast.error('Failed to save tracking data');
                                                                }
                                                            });
                                                        }}
                                                    >
                                                        Save Tracking
                                                    </Button>
                                                </div>
                                            );
                                        }
                                    })()}
                                </CardContent>
                            </Card>
                        </TabsContent>
                    </Tabs>
                </DialogContent>
            </Dialog>

            {/* Email to Customer Modal */}
            <Dialog open={showEmailModal} onOpenChange={setShowEmailModal}>
                <DialogContent className="max-w-md">
                    <DialogHeader>
                        <DialogTitle>{t('orders.sendEmailToCustomer')}</DialogTitle>
                        <DialogDescription>Send a custom email to the customer about this order.</DialogDescription>
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
                        <DialogDescription>Send a message to the vendor(s) about this order.</DialogDescription>
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

            {/* Approve Confirmation Dialog */}
            <Dialog open={showApproveConfirm} onOpenChange={setShowApproveConfirm}>
                <DialogContent>
                    <DialogHeader>
                        <DialogTitle>{t('orders.approveRefund')}</DialogTitle>
                        <DialogDescription>Are you sure you want to approve this refund?</DialogDescription>
                    </DialogHeader>
                    <div className="flex justify-end gap-2 mt-4">
                        <Button variant="outline" onClick={() => setShowApproveConfirm(false)}>
                            {t('common.cancel')}
                        </Button>
                        <Button variant="default" onClick={() => { setShowApproveConfirm(false); handleApprove(); }}>
                            {t('orders.approve')}
                        </Button>
                    </div>
                </DialogContent>
            </Dialog>


        </>
    );
}

const VendorIndex = () => {
    const { t } = useLanguage();
    // Remove PaginatedOrders and Tracking types, use Order[] directly
    const { orders, filters } = usePage<{ orders: { data: Order[]; links: any[]; current_page: number; per_page: number; total: number; last_page: number; filters: any }; filters: any }>().props;
    const [selectedOrder, setSelectedOrder] = useState<Order | null>(null);
    const [detailsModalOpen, setDetailsModalOpen] = useState(false);
    const [tab, setTab] = useState(filters?.status || 'all');
    const [search, setSearch] = useState(filters?.search || '');
    const [orderStatus, setOrderStatus] = useState(filters?.filter_status || '');
    const [paymentStatus, setPaymentStatus] = useState(filters?.payment_status || '');
    const [dateFrom, setDateFrom] = useState(filters?.date_from || '');
    const [dateTo, setDateTo] = useState(filters?.date_to || '');
    const throttledFn = useRef<any>(null);
    const [orderToDelete, setOrderToDelete] = useState<Order | null>(null);
    const [orderToCancel, setOrderToCancel] = useState<Order | null>(null);
    const [orderToConfirm, setOrderToConfirm] = useState<Order | null>(null);


    const handleDeleteOrder = (order: Order) => setOrderToDelete(order);
    const handleCancelOrder = (order: Order) => setOrderToCancel(order);

    const confirmDeleteOrder = () => {
        if (!orderToDelete) return;
        router.delete(route('orders.destroy', orderToDelete.id), {
            onSuccess: () => {
                toast.success('Order deleted successfully.');
                setOrderToDelete(null);
            },
            onError: () => toast.error('Failed to delete order'),
        });
    };

    const refreshOrders = () => { };
    const confirmCancelOrder = () => {
        if (!orderToCancel) return;
        router.post(
            route('orders.cancel', orderToCancel.id),
            {},
            {
                preserveScroll: true,
                // eslint-disable-next-line @typescript-eslint/no-explicit-any
                onSuccess: (page: any) => {
                    const flash = page.props.flash as { success?: string; info?: string; error?: string };
                    if (flash?.success) {
                        toast.success(flash.success);
                    } else if (flash?.info) {
                        toast(flash.info);
                    } else if (flash?.error) {
                        toast.error(flash.error);
                    } else {
                        toast.success('Order cancelled successfully.');
                    }
                    setOrderToCancel(null);
                    refreshOrders();
                },
                // eslint-disable-next-line @typescript-eslint/no-explicit-any
                onError: (page: any) => {
                    const flash = page.props.flash as { error?: string };
                    const msg = flash.error || 'Failed to cancel order';
                    toast.error(msg);
                },
            },
        );
    };

    const handleConfirmOrder = (order: Order) => {
        setOrderToConfirm(order);
    };

    const confirmOrder = () => {
        if (!orderToConfirm) return;
        router.post(
            route('orders.confirm', orderToConfirm.id),
            {},
            {
                preserveScroll: true,
                onSuccess: (page: any) => {
                    const flash = page.props.flash as { success?: string; info?: string; error?: string };
                    if (flash?.success) {
                        toast.success(flash.success);
                    } else if (flash?.info) {
                        toast(flash.info);
                    } else if (flash?.error) {
                        toast.error(flash.error);
                    } else {
                        toast.success('Order confirmed successfully.');
                    }
                    setOrderToConfirm(null);
                    refreshOrders?.();
                },
                onError: (page: any) => {
                    const flash = page.props.flash as { error?: string };
                    const msg = flash.error || 'Failed to confirm order';
                    toast.error(msg);
                },
            }
        );
    };

    useEffect(() => {

        throttledFn.current = throttle(() => {
            router.get(
                '/vendor/orders',
                {
                    status: tab,
                    search: search,
                    date_from: dateFrom,
                    date_to: dateTo,
                    filter_status: orderStatus,
                    payment_status: paymentStatus,
                },
                { preserveState: true, replace: true },
            );
        }, 300);

        return () => {
            throttledFn.current?.cancel?.();
        };
    }, [dateFrom, dateTo, orderStatus, paymentStatus, search, tab]);

    useEffect(() => {
        throttledFn.current();
    }, [tab, search, dateFrom, dateTo, orderStatus, paymentStatus]);

    const handlePageChange = (pageNum: number) => {
        router.get(
            '/vendor/orders',
            {
                status: tab,
                search,
                date_from: dateFrom,
                date_to: dateTo,
                filter_status: status,
                page: pageNum,
            },
            { preserveState: true, replace: true },
        );
    };

    return (
        <AppLayout>
            <Head title={t('orders.vendorOrders')} />
            <div className="p-6">
                <h1 className="mb-4 text-2xl font-bold">{t('orders.myOrders')}</h1>
                <div className="mb-4 flex gap-2">
                    <Button
                        variant={tab === 'all' ? 'default' : 'outline'}
                        onClick={() => {
                            setTab('all');
                            router.get('/vendor/orders', { status: 'all' }, { preserveState: true, replace: true });
                        }}
                    >
                        {t('orders.allOrders')}
                    </Button>
                    <Button
                        variant={tab === 'current' ? 'default' : 'outline'}
                        onClick={() => {
                            setTab('current');
                            router.get('/vendor/orders', { status: 'current' }, { preserveState: true, replace: true });
                        }}
                    >
                        {t('orders.currentOrders')}
                    </Button>

                    <ExportButton
                        title={t('orders.exportToCsv')}
                        onClick={() => {
                            const params = new URLSearchParams();
                            if (search) params.append('search', search);
                            if (orderStatus && orderStatus !== 'all') params.append('status', orderStatus);
                            if (paymentStatus && paymentStatus !== 'all') params.append('payment_status', paymentStatus);
                            if (dateFrom) params.append('date_from', dateFrom);
                            if (dateTo) params.append('date_to', dateTo);
                            const url = params.toString() ? `${route('vendor.orders.export')}?${params.toString()}` : route('vendor.orders.export');
                            window.location.href = url;
                        }}
                    />
                </div>
                <div className="mb-4 flex flex-wrap items-center justify-end gap-2">
                    <Input
                        type="text"
                        placeholder={t('orders.searchByOrderIdOrUser')}
                        value={search}
                        onChange={(e) => setSearch(e.target.value)}
                        className="w-auto"
                    />
                    <StatusFilter
                        value={orderStatus || 'all'}
                        onChange={(value) => setOrderStatus(value === 'all' ? '' : value)}
                        className="w-40" />
                    <StatusFilter
                        className="w-52"
                        value={paymentStatus || 'all'}
                        onChange={(value) => setPaymentStatus(value === 'all' ? '' : value)}
                        statusOptions={[
                            { value: 'all', label: t('orders.allPaymentStatuses') },
                            { value: 'paid', label: 'Paid' },
                            { value: 'unpaid', label: 'Unpaid' },
                            { value: 'pending', label: t('orders.pending') },
                            { value: 'failed', label: 'Failed' },
                            { value: 'refunded', label: t('orders.refunded') },
                            // { value: 'cancelled', label: 'Cancelled' },
                        ]}
                        placeholder={t('orders.filterByPaymentStatus')}
                    />
                    <Input type="date" value={dateFrom} onChange={(e) => setDateFrom(e.target.value)} className="w-40" />
                    <Input type="date" value={dateTo} onChange={(e) => setDateTo(e.target.value)} className="w-40" />
                </div>
                <div className="w-full overflow-x-auto">
                    <table className="w-full border bg-white dark:bg-neutral-900">
                        <thead>
                            <tr>
                                <th className="border px-4 py-2">#</th>
                                <th className="border px-4 py-2">{t('orders.orderId')}</th>
                                <th className="border px-4 py-2">{t('orders.customer')}</th>
                                <th className="border px-4 py-2">{t('orders.products')}</th>
                                <th className="border px-4 py-2">{t('orders.total')}</th>
                                <th className="border px-4 py-2">{t('common.status')}</th>
                                <th className="border px-4 py-2">{t('orders.paymentStatus')}</th>
                                <th className="border px-4 py-2">{t('orders.date')}</th>
                                <th className="border px-4 py-2">{t('common.actions')}</th>
                            </tr>
                        </thead>
                        <tbody>
                            {Array.isArray(orders?.data) && orders.data.length > 0 ? (
                                orders.data.map((order: Order, index: number) => (
                                    <tr key={index}>
                                        <td className="border px-4 py-2 text-center">{(orders.current_page - 1) * orders.per_page + index + 1}</td>
                                        <td className="border px-4 py-2 text-center">{order.order_code}</td>
                                        <td className="border px-4 py-2 text-center">{order.user.full_name}</td>
                                        <td className="border px-4 py-2 text-center">
                                            {Array.isArray(order?.orderItems) && order.orderItems.length > 0 ? (
                                                order.orderItems.map((item: OrderItem) => (
                                                    <div key={item.id} className="">
                                                        {item.product?.name_en || 'Product Unavailable'} 
                                                    </div>
                                                ))
                                            ) : (
                                                <span>No products</span>
                                            )}
                                        </td>
                                        <td className="border px-4 py-2 text-center">{order.total_amount}</td>
                                        <td className="border px-4 py-2 text-center capitalize">
                                            {(() => {
                                                // If refund is requested (pending), show "Refund Requested" status
                                                if (order.refund_status === 'pending') {
                                                    return (
                                                        <span className="inline-block w-28 rounded px-2 py-1 text-center text-xs font-semibold text-white bg-orange-500">
                                                            {t('orders.refundRequested')}
                                                        </span>
                                                    );
                                                }
                                                // Otherwise show regular order status
                                                const status = order.order_status ?? '';
                                                return (
                                                    <span
                                                        className={
                                                            'inline-block w-28 rounded px-2 py-1 text-center text-xs font-semibold text-white ' +
                                                            ({
                                                                pending: 'bg-yellow-500',
                                                                processing: 'bg-blue-500',
                                                                shipped: 'bg-indigo-500',
                                                                out_for_delivery: 'bg-cyan-600',
                                                                delivered: 'bg-green-600',
                                                                cancelled: 'bg-gray-500',
                                                                returned: 'bg-orange-500',
                                                                failed: 'bg-red-600',
                                                                confirmed: 'bg-green-600',
                                                                'ready_for_pickup': 'bg-green-600',
                                                            } as Record<string, string>)[status] || 'bg-gray-400'
                                                        }
                                                    >
                                                        {status.replace(/_/g, ' ').replace(/\b\w/g, (l) => l.toUpperCase())}
                                                    </span>
                                                );
                                            })()}
                                        </td>
                                        <td className="border px-4 py-2 text-center">
                                            <span
                                                className={
                                                    'inline-block w-28 rounded px-2 py-1 text-center text-xs font-semibold text-white ' +
                                                    ({
                                                        paid: 'bg-green-600',
                                                        unpaid: 'bg-gray-400',
                                                        pending: 'bg-yellow-500',
                                                        failed: 'bg-red-600',
                                                        refunded: 'bg-blue-500',
                                                        cancelled: 'bg-gray-500',
                                                    } as Record<string, string>)[order?.payment_status ?? ''] || 'bg-gray-400'
                                                }
                                            >
                                                {order?.payment_status
                                                    ? order?.payment_status.replace(/_/g, ' ').replace(/\b\w/g, (l) => l.toUpperCase())
                                                    : 'N/A'}
                                            </span>
                                        </td>
                                        <td className="border px-4 py-2 text-center">
                                            {order.created_at ? dayjs(order.created_at).format('YYYY-MM-DD hh:mm:A') : ''}
                                        </td>
                                        <td className="w-auto border px-4 py-2 text-center">
                                            <div className="flex h-full gap-2">
                                                <Button size="sm" onClick={() => { setSelectedOrder(order); setDetailsModalOpen(true); }}>
                                                    {t('orders.view')}
                                                </Button>
                                                {order.order_status === 'pending' && (
                                                    <Button
                                                        size="sm"
                                                        variant="default"
                                                        className="bg-green-600 hover:bg-green-700 text-white"
                                                        onClick={() => handleConfirmOrder(order)}
                                                    >
                                                        {t('orders.confirm')}
                                                    </Button>
                                                )}
                                                {/* Hide Cancel button if delivered, returned, cancelled, or if paid & shipped */}
                                                {!(
                                                    ['delivered', 'returned', 'cancelled'].includes(order.order_status) ||
                                                    (order.payment_status === 'paid' && order.order_status === 'shipped')
                                                ) && (
                                                        <Button size="sm" variant="secondary" onClick={() => handleCancelOrder(order)}>
                                                            {t('common.cancel')}
                                                        </Button>
                                                    )}
                                                {/* <ActionButtonDelete
                                                    btnTitle="Delete"
                                                    onClick={() => handleDeleteOrder(order)}
                                                /> */}
                                            </div>
                                        </td>
                                    </tr>
                                ))
                            ) : (
                                <tr>
                                    <td colSpan={7} className="text-muted-foreground py-4 text-center">
                                        {t('orders.noOrdersFound')}
                                    </td>
                                </tr>
                            )}
                        </tbody>
                    </table>
                </div>
                {orders.last_page > 1 && (
                    <div className="mt-6">
                        <Pagination
                            currentPage={orders.current_page}
                            lastPage={orders.last_page}
                            total={orders.total}
                            perPage={orders.per_page}
                            links={orders.links}
                            onPageChange={handlePageChange}
                        />
                    </div>
                )}
                <OrderDetailsModal order={selectedOrder} isOpen={detailsModalOpen} onClose={() => setDetailsModalOpen(false)} />
            </div>
            <Dialog open={!!orderToDelete} onOpenChange={(open) => !open && setOrderToDelete(null)}>
                <DialogContent>
                    <DialogHeader>
                        <DialogTitle>Delete Order</DialogTitle>
                        <DialogDescription>Are you sure you want to delete this order? This action cannot be undone.</DialogDescription>
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
                        <DialogDescription>Are you sure you want to cancel this order?</DialogDescription>
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
            {/* Confirm Order Dialog */}
            <Dialog open={!!orderToConfirm} onOpenChange={(open) => !open && setOrderToConfirm(null)}>
                <DialogContent>
                    <DialogHeader>
                        <DialogTitle>Confirm Order</DialogTitle>
                        <DialogDescription>Are you sure you want to confirm this order?</DialogDescription>
                    </DialogHeader>
                    <div className="flex justify-end gap-2">
                        <Button variant="outline" onClick={() => setOrderToConfirm(null)}>
                            Back
                        </Button>
                        <Button variant="default" onClick={confirmOrder}>
                            {t('orders.confirm')}
                        </Button>
                    </div>
                </DialogContent>
            </Dialog>
        </AppLayout>
    );
};

export default VendorIndex;
