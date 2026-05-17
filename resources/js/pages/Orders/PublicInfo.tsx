import { Head, usePage } from '@inertiajs/react';
import dayjs from 'dayjs';

export default function OrderPublicInfo() {
    const { props } = usePage();
    const order = props.order as any;

    const statusColor: Record<string, string> = {
        pending: 'bg-yellow-100 text-yellow-800',
        confirmed: 'bg-blue-100 text-blue-800',
        processing: 'bg-indigo-100 text-indigo-800',
        shipped: 'bg-purple-100 text-purple-800',
        delivered: 'bg-green-100 text-green-800',
        cancelled: 'bg-red-100 text-red-800',
    };

    return (
        <>
            <Head title={`Order ${order.order_code}`} />
            <div className="min-h-screen bg-gray-50 py-10 px-4">
                <div className="max-w-xl mx-auto bg-white rounded-2xl shadow-lg overflow-hidden">
                    {/* Header */}
                    <div className="bg-black text-white px-6 py-5">
                        <h1 className="text-xl font-bold">Order #{order.order_code}</h1>
                        <p className="text-sm text-gray-300 mt-1">{dayjs(order.created_at).format('DD MMM YYYY, hh:mm A')}</p>
                    </div>

                    <div className="px-6 py-5 space-y-5">
                        {/* Status Row */}
                        <div className="flex flex-wrap gap-2">
                            <span className={`px-3 py-1 rounded-full text-xs font-semibold ${statusColor[order.order_status] || 'bg-gray-100 text-gray-700'}`}>
                                Order: {order.order_status?.replace(/_/g, ' ')}
                            </span>
                            <span className={`px-3 py-1 rounded-full text-xs font-semibold ${statusColor[order.delivery_status] || 'bg-gray-100 text-gray-700'}`}>
                                Delivery: {order.delivery_status?.replace(/_/g, ' ')}
                            </span>
                            <span className={`px-3 py-1 rounded-full text-xs font-semibold ${statusColor[order.payment_status] || 'bg-gray-100 text-gray-700'}`}>
                                Payment: {order.payment_status}
                            </span>
                        </div>

                        {/* Customer */}
                        <section>
                            <h2 className="text-sm font-semibold text-gray-500 uppercase tracking-wide mb-2">Customer</h2>
                            <div className="bg-gray-50 rounded-lg p-4 space-y-1 text-sm">
                                <div><span className="font-medium">Name:</span> {order.customer.name}</div>
                                <div><span className="font-medium">Email:</span> {order.customer.email}</div>
                                <div><span className="font-medium">Mobile:</span> {order.customer.mobile}</div>
                                <div><span className="font-medium">Address:</span> {order.shipping_address}</div>
                            </div>
                        </section>

                        {/* Vendor */}
                        <section>
                            <h2 className="text-sm font-semibold text-gray-500 uppercase tracking-wide mb-2">Vendor</h2>
                            <div className="bg-gray-50 rounded-lg p-4 space-y-1 text-sm">
                                <div><span className="font-medium">Name:</span> {order.vendor.name}</div>
                                <div><span className="font-medium">Email:</span> {order.vendor.email}</div>
                                <div><span className="font-medium">Mobile:</span> {order.vendor.mobile}</div>
                            </div>
                        </section>

                        {/* Items */}
                        <section>
                            <h2 className="text-sm font-semibold text-gray-500 uppercase tracking-wide mb-2">Items</h2>
                            <div className="bg-gray-50 rounded-lg divide-y text-sm">
                                {order.items.map((item: any, i: number) => (
                                    <div key={i} className="flex justify-between px-4 py-3">
                                        <span>{item.name} × {item.quantity}</span>
                                        <span className="font-medium">KWD {item.amount}</span>
                                    </div>
                                ))}
                                <div className="flex justify-between px-4 py-3 font-bold">
                                    <span>Total</span>
                                    <span>KWD {order.total_amount}</span>
                                </div>
                            </div>
                        </section>

                        {/* Armada */}
                        {order.armada && (
                            <section>
                                <h2 className="text-sm font-semibold text-gray-500 uppercase tracking-wide mb-2">Delivery (Armada)</h2>
                                <div className="bg-gray-50 rounded-lg p-4 space-y-1 text-sm">
                                    <div><span className="font-medium">Tracking #:</span> {order.armada.tracking_number}</div>
                                    <div><span className="font-medium">Status:</span> {order.armada.order_status}</div>
                                    {order.armada.delivery_fee && <div><span className="font-medium">Delivery Fee:</span> KWD {order.armada.delivery_fee}</div>}
                                    {order.armada.customer_address && <div><span className="font-medium">Delivery Address:</span> {order.armada.customer_address}</div>}
                                    {order.armada.driver?.name && <div><span className="font-medium">Driver:</span> {order.armada.driver.name} {order.armada.driver.phoneNumber && `(${order.armada.driver.phoneNumber})`}</div>}
                                    {order.armada.tracking_link && (
                                        <a href={order.armada.tracking_link} target="_blank" rel="noopener noreferrer"
                                            className="inline-block mt-2 text-blue-600 underline text-xs break-all">
                                            Track on Armada →
                                        </a>
                                    )}
                                </div>
                            </section>
                        )}
                    </div>
                </div>
            </div>
        </>
    );
}
