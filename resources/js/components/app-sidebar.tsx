import { useLanguage } from '@/components/language-context';
import { NavMain } from '@/components/nav-main';
import { NavUser } from '@/components/nav-user';
import { Sidebar, SidebarContent, SidebarFooter, SidebarHeader, SidebarMenu, SidebarMenuButton, SidebarMenuItem } from '@/components/ui/sidebar';
import { PageProps, type NavItem } from '@/types';
import { Link, usePage } from '@inertiajs/react';
import {
    BarChart3,
    Bookmark,
    BookOpen,
    Building,
    ClipboardList,
    FileText,
    Folder,
    Globe,
    KeyRound,
    LayoutGrid,
    ListTodo,
    Map,
    MoreHorizontal,
    Shield,
    ShoppingCart,
    Tag,
    User,
    Wallet,
    CreditCard,
} from 'lucide-react';
import AppLogo from './app-logo';

const baseNavItems: NavItem[] = [
    { title: 'Home', titleKey: 'sidebar.home', href: '/dashboard', icon: LayoutGrid },
    { title: 'Expos', titleKey: 'sidebar.expos', href: '/expos', icon: Folder, permission: 'manage_expos' },
    { title: 'Orders', titleKey: 'sidebar.orders', href: '/orders', icon: ClipboardList, permission: 'manage_orders' },
    { title: 'Users', titleKey: 'sidebar.users', href: '/users', icon: BookOpen, permission: 'manage_users' },
    { title: 'Vendors', titleKey: 'sidebar.vendors', href: '/vendors', icon: ListTodo, permission: 'manage_vendors' },
    { title: 'Categories', titleKey: 'sidebar.categories', href: '/categories', icon: Folder, permission: 'manage_categories' },
    { title: 'Products', titleKey: 'sidebar.products', href: '/products', icon: LayoutGrid, permission: 'manage_products' },
    { title: 'Subscriptions', titleKey: 'sidebar.subscriptions', href: '/subscriptions', icon: KeyRound, permission: 'manage_subscriptions' },
    { title: 'Coupons', titleKey: 'sidebar.coupons', href: '/coupons', icon: Tag, permission: 'manage_coupons' },
    { title: 'Ads', titleKey: 'sidebar.ads', href: '/ads', icon: BookOpen, permission: 'manage_ads' },
    { title: 'CMS', titleKey: 'sidebar.cms', href: '/cms-pages', icon: FileText, permission: 'manage_cms' },
    { title: 'Finance', titleKey: 'sidebar.finance', href: '/finance', icon: Wallet, permission: 'manage_finance' },
    { title: 'Payouts', titleKey: 'sidebar.payouts', href: '/payouts', icon: CreditCard, permission: 'manage_finance' },
    { title: 'My Subscription', titleKey: 'sidebar.mySubscription', href: '/vendor/subscription-ui', icon: KeyRound, permission: 'vendor' },
    { title: 'Expos', titleKey: 'sidebar.expos', href: '/vendor/expos', icon: LayoutGrid, permission: 'vendor' },
];

const vendorNavItems: NavItem[] = [
    { title: 'Home', titleKey: 'sidebar.home', href: '/dashboard', icon: LayoutGrid },
    { title: 'Profile Management', titleKey: 'sidebar.profileManagement', href: '/vendor/profile', icon: User, permission: 'manage_own_profile' },
    { title: 'My Products', titleKey: 'sidebar.myProducts', href: '/vendor/products', icon: ShoppingCart, permission: 'manage_own_products' },
    { title: 'My Orders', titleKey: 'sidebar.myOrders', href: '/vendor/orders', icon: ClipboardList, permission: 'manage_own_orders' },
    { title: 'Expo Participation', titleKey: 'sidebar.expoParticipation', href: '/vendor/expos', icon: Folder, permission: 'view_expos' },
    { title: 'My Expos', titleKey: 'sidebar.myExpos', href: '/vendor/my-expos', icon: LayoutGrid, permission: 'view_expos' },
    {
        title: 'Others',
        titleKey: 'sidebar.others',
        href: '#',
        icon: MoreHorizontal,
        children: [
            { title: 'KYC Status', titleKey: 'sidebar.kycStatus', href: '/vendor/kyc-status', icon: Shield, permission: 'view_own_kyc_status' },
            { title: 'My Sections', titleKey: 'sidebar.mySections', href: '/vendor/section', icon: Bookmark },
            { title: 'My Ads', titleKey: 'sidebar.myAds', href: '/vendor/ads', icon: BookOpen, permission: 'manage_own_ads' },
            { title: 'Finance Manager', titleKey: 'sidebar.financeManager', href: '/vendor/finance', icon: BarChart3, permission: 'view_own_finance' },
            { title: 'Payout Management', titleKey: 'sidebar.payoutManagement', href: '/vendor/payouts', icon: CreditCard, permission: 'view_own_finance' },
            { title: 'Analytics', titleKey: 'sidebar.analytics', href: '/vendor/analytics', icon: BarChart3, permission: 'view_own_analytics' },
            { title: 'My Subscriptions', titleKey: 'sidebar.mySubscriptions', href: '/vendor/subscription', icon: KeyRound, permission: 'view_own_subscription' },
        ],
    },
];

const adminNavItems: NavItem[] = [
    { title: 'Settings', titleKey: 'sidebar.settings', href: '/admin/settings', icon: Shield, permission: 'manage_settings' },
    { title: 'Audit Logs', titleKey: 'sidebar.auditLogs', href: '/audit-logs', icon: ListTodo, permission: 'view_audit_logs' },
    { title: 'Country', titleKey: 'sidebar.country', href: '/country', icon: Globe },
    { title: 'State', titleKey: 'sidebar.state', href: '/state', icon: Map },
    { title: 'City', titleKey: 'sidebar.city', href: '/city', icon: Building },
];

export function AppSidebar() {
    const { auth } = usePage<PageProps>().props;
    const permissions = auth.permissions || [];
    const user = auth.user;

    const hasAccess = (item: NavItem) => {
        if (!item.permission) {
            return true;
        }
        return permissions.includes(item.permission);
    };

    // Determine which navigation items to show based on user role
    let mainNavItems: NavItem[] = [];
    let bottomNavItems: NavItem[] = [];

    if (user?.role === 'vendor') {
        // Show vendor-specific navigation; filter "Others" children by permission
        mainNavItems = vendorNavItems
            .filter(hasAccess)
            .map((item) => {
                if (item.children?.length) {
                    const filteredChildren = item.children.filter(hasAccess);
                    return { ...item, children: filteredChildren };
                }
                return item;
            })
            .filter((item) => !item.children || item.children!.length > 0); // hide "Others" if no children
    } else if (user?.role === 'admin' || permissions.includes('manage_users')) {
        // Show admin navigation
        mainNavItems = baseNavItems.filter(hasAccess);
        bottomNavItems = adminNavItems.filter(hasAccess);
    } else {
        // Show base navigation for other roles
        mainNavItems = baseNavItems.filter(hasAccess);
    }

    if (!user) return null; // or a loading spinner

    const { language } = useLanguage();
    const sidebarSide = language === 'ar' ? 'right' : 'left';

    return (
        <Sidebar collapsible="icon" variant="inset" side={sidebarSide}>
            <SidebarHeader>
                <SidebarMenu>
                    <SidebarMenuItem>
                        <SidebarMenuButton size="lg" asChild>
                            <Link href="/dashboard" prefetch>
                                <AppLogo />
                            </Link>
                        </SidebarMenuButton>
                    </SidebarMenuItem>
                </SidebarMenu>
            </SidebarHeader>

            <SidebarContent>
                <NavMain items={mainNavItems} />
                {bottomNavItems.length > 0 && (
                    <>
                        <div className="border-muted my-2 border-t" />
                        <NavMain items={bottomNavItems} />
                    </>
                )}
            </SidebarContent>

            <SidebarFooter>
                <NavUser />
            </SidebarFooter>
        </Sidebar>
    );
}
