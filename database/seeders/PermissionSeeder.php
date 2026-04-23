<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Spatie\Permission\Models\Role;
use Spatie\Permission\Models\Permission;

class PermissionSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        // Define all permissions
        $adminPermissions = [
            'view_role', 'create_role', 'edit_role', 'delete_role',
            'view_permission', 'create_permission', 'edit_permission', 'delete_permission',
            'manage_users', 'view_users', 'create_users', 'edit_users', 'delete_users',
            'manage_vendors', 'view_vendors', 'edit_vendors', 'delete_vendors', 'approve_vendors',
            'manage_expos',
            'manage_orders',
            'manage_categories',
            'manage_products',
            'manage_subscriptions',
            'manage_ads',
            'manage_cms',
            'manage_finance',
            'manage_coupons',
            'manage_settings',
            'view_audit_logs',
        ];

        $vendorPermissions = [
            // Vendor Dashboard
            'view_own_dashboard',
            // Profile Management
            'manage_own_profile',
            'view_own_kyc_status',
            'change_own_password',
            'delete_own_account',
            // Product & Inventory Management
            'manage_own_products',
            'create_own_product',
            'edit_own_product',
            'delete_own_product',
            'suspend_own_product',
            'assign_product_to_category',
            'assign_product_to_section',
            // Expo Participation & Management
            'view_expos',
            'join_expo',
            'manage_own_expo_participation',
            'assign_products_to_expo',
            'create_section_in_expo',
            'add_coupon_to_expo_product',
            // Order Management
            'manage_own_orders',
            'view_own_orders',
            'approve_refund_request',
            'reject_refund_request',
            'generate_invoice',
            // Finance Manager
            'view_own_finance',
            'view_own_payouts',
            'export_own_finance_csv',
            // Ads Manager
            'manage_own_ads',
            'create_own_ad',
            'edit_own_ad',
            'delete_own_ad',
            'suspend_own_ad',
            // Subscription Management
            'view_own_subscription',
            'upgrade_own_subscription',
            'renew_own_subscription',
            'cancel_own_subscription',
            // Reports & Analytics (Premium)
            'view_own_analytics',
            'export_own_analytics_csv',
        ];

        // Create permissions
        foreach (array_merge($adminPermissions, $vendorPermissions) as $permission) {
            Permission::firstOrCreate(['name' => $permission, 'guard_name' => 'web']);
        }

        // Assign permissions to roles
        $adminRole = Role::firstOrCreate(['name' => 'admin']);
        $adminRole->syncPermissions($adminPermissions);

        $vendorRole = Role::firstOrCreate(['name' => 'vendor']);
        $vendorRole->syncPermissions($vendorPermissions);
    }
}
