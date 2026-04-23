import { LucideIcon } from 'lucide-react';
import type { Config } from 'ziggy-js';

export interface Auth {
    user: User;
    permissions: string[];
}

export interface BreadcrumbItem {
    title: string;
    href: string;
}

export interface NavGroup {
    title: string;
    items: NavItem[];
}

export interface NavItem {
    title: string;
    titleKey?: string;
    href: string;
    icon?: LucideIcon | null;
    isActive?: boolean;
    permission?: string;
    children?: NavItem[];
}

export type PageProps<T extends Record<string, unknown> = Record<string, unknown>> = T & {
    auth: Auth;
    ziggy: Config & { location: string };
    [key: string]: unknown;
};

export interface SharedData {
    name: string;
    quote: { message: string; author: string };
    auth: Auth;
    ziggy: Config & { location: string };
    sidebarOpen: boolean;
    flash: FlashData;
    [key: string]: unknown;
}

export interface User {
    id: number;
    full_name: string;
    email: string;
    avatar?: string;
    email_verified_at: string | null;
    created_at: string;
    updated_at: string;
    [key: string]: unknown; // This allows for additional properties...
}

export interface FlashData {
    success?: string;
    error?: string;
    otp?: string;
    token?: string;
    [key: string]: string | undefined;
}

export interface Order {
    id: number;
    user_id: number;
    order_identifier?: string;
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
    refund_requested_at?: string;
    refund_rejection_reason_en?: string;
    refund_rejection_reason_ar?: string;
    payment_method?: string;
    transaction_id?: string;
    created_at: string;
    updated_at: string;
    user: User;
    order_items?: OrderItem[];
}

export interface OrderItem {
    id: number;
    order_id: number;
    product_id: number;
    quantity: number;
    price: number;
    tax_amount: number;
    discount_amount: number;
    total_amount: number;
    attributes?: Record<string, unknown>;
    created_at: string;
    updated_at: string;
    product: Product;
}

export interface Product {
    id: number;
    name_en: string;
    name_ar: string;
    description_en?: string;
    description_ar?: string;
    regular_price: number;
    sale_price?: number;
    stock: number;
    gallery?: string[];
    expo_id?: number;
    category_id: number;
    vendor_id: number;
    status: string;
    views?: number;
    created_at: string;
    updated_at: string;
    vendor: Vendor;
}

export interface Vendor {
    id: number;
    name: string;
    brand_name_en?: string | null;
    brand_name_ar?: string | null;
    description_en?: string | null;
    description_ar?: string | null;
    email?: string | null;
    phone?: string | null;
    mobile?: string | null;
    status: string;
    commission?: string | null;
    kyc_status?: string;
    kyc_rejection_reason?: string | null;
    kyc_documents?: unknown[];
    subscription_id?: number | null;
    logo?: string | null;
    created_at: string;
    updated_at: string;
}
