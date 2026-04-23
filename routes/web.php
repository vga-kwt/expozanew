<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\DashboardController;
use App\Http\Controllers\PermissionController;
use App\Http\Controllers\RoleController;
use App\Http\Controllers\ExpoController;
use App\Http\Controllers\OrderController;
use App\Http\Controllers\UserController;
use App\Http\Controllers\VendorController;
use App\Http\Controllers\VendorProfileController;
use App\Http\Controllers\CategoryController;
use App\Http\Controllers\ProductController;
use App\Http\Controllers\SubscriptionController;
use App\Http\Controllers\AdController;
use App\Http\Controllers\CmsPageController;
use App\Http\Controllers\FinanceController;
use App\Http\Controllers\SettingsController;
use App\Http\Controllers\AuditLogController;
use App\Http\Controllers\Vendor\AdController as VendorAdController;
use App\Http\Controllers\Vendor\FinanceController as VendorFinanceController;
use App\Http\Controllers\Vendor\AnalyticsController as VendorAnalyticsController;
use App\Http\Controllers\VendorSubscriptionController;
use App\Http\Controllers\CountryController;
use App\Http\Controllers\StateController;
use App\Http\Controllers\CityController;
use App\Http\Controllers\PayoutController;
use App\Http\Controllers\SectionController;
use App\Http\Controllers\MyFatoorahTestController;
use App\Http\Controllers\SupportController;
use App\Http\Controllers\CouponController;

Route::middleware(['auth', 'verified'])->group(function () {
    // --- EXPORT ROUTES (Place these FIRST) ---
    Route::get('/city/export', [CityController::class, 'export'])->name('city.export');
    Route::get('/state/export', [StateController::class, 'export'])->name('state.export');
    Route::get('/country/export', [CountryController::class, 'export'])->name('country.export');
    Route::get('/users/export', [UserController::class, 'export'])->name('users.export');
    Route::get('/orders/export', [OrderController::class, 'export'])->name('orders.export');
    Route::get('/expos/export', [ExpoController::class, 'export'])->name('expos.export');
    Route::get('/ads/export', [AdController::class, 'export'])->name('ads.export');
    Route::get('/audit-logs/export', [AuditLogController::class, 'export'])->name('audit-logs.export');
    Route::get('/finance/export/transactions', [FinanceController::class, 'exportTransactions'])->name('finance.export.transactions');
    Route::get('/finance/payouts/export', [PayoutController::class, 'export'])->name('finance.payouts.export');
    Route::get('/vendor/section/export', [SectionController::class, 'export'])->name('section.export');
    // --- END EXPORT ROUTES ---

    Route::get('/dashboard', [DashboardController::class, 'index'])->name('dashboard');
    Route::resource('roles', RoleController::class);
    Route::resource('permissions', PermissionController::class);
    Route::resource('expos', ExpoController::class)->only(['index', 'create', 'store', 'edit', 'update', 'destroy']);
    Route::post('/expos/{expo}/toggle-status', [ExpoController::class, 'toggleStatus'])->name('expos.toggle-status');
    Route::resource('orders', OrderController::class)->only(['index']);
    Route::post('/orders/{id}/cancel', [OrderController::class, 'cancel'])->name('orders.cancel');
    Route::post('/orders/{order}/confirm', [OrderController::class, 'confirm'])->name('orders.confirm');
    Route::post('/orders/{id}/sync-armada', [OrderController::class, 'syncFromArmada'])->name('orders.sync-armada');
    Route::delete('/orders/{id}', [OrderController::class, 'destroy'])->name('orders.destroy');
    Route::get('/orders/{id}/invoice', [OrderController::class, 'generateInvoice'])->name('orders.invoice');
    Route::post('/orders/{id}/send-email', [OrderController::class, 'sendEmailToCustomer'])->name('orders.send-email');
    Route::post('/orders/{id}/contact-vendor', [OrderController::class, 'contactVendor'])->name('orders.contact-vendor');
    Route::post('/orders/{id}/refund/approve', [OrderController::class, 'approveRefund'])->name('orders.refund.approve');
    Route::post('/orders/{id}/refund/reject', [OrderController::class, 'rejectRefund'])->name('orders.refund.reject');
    Route::resource('users', UserController::class)->only(['index', 'store', 'update', 'destroy']);
    Route::post('/users/{user}/suspend', [UserController::class, 'suspend'])->name('users.suspend');
    Route::post('/users/{user}/unsuspend', [UserController::class, 'unsuspend'])->name('users.unsuspend');
    Route::get('/users/{user}/show', [UserController::class, 'show'])->name('users.show');
    Route::resource('vendors', VendorController::class)->only(['index', 'store', 'update', 'destroy']);
    Route::post('/vendors/{vendor}/toggle-status', [VendorController::class, 'toggleStatus'])->name('vendors.toggle-status');
    Route::get('/vendors/{vendor}/show', [VendorController::class, 'show'])->name('vendors.show');
    Route::post('/vendors/{vendor}/kyc-approve', [VendorController::class, 'kycApprove'])->name('vendors.kyc.approve');
    Route::post('/vendors/{vendor}/kyc-reject', [VendorController::class, 'kycReject'])->name('vendors.kyc.reject');
    Route::post('/vendors/{vendor}/create-armada-branch', [VendorController::class, 'createArmadaBranch'])->name('vendors.create-armada-branch');
    Route::post('/vendors/{vendor}/assign-subscription', [VendorController::class, 'assignSubscription'])->name('vendors.assignSubscription');
    Route::post('/vendors/{vendor}/set-commission', [VendorController::class, 'setCommission'])->name('vendors.setCommission');
    Route::resource('categories', CategoryController::class)->only(['index', 'store', 'update', 'destroy']);
    Route::post('/categories/{category}/toggle-status', [CategoryController::class, 'toggleStatus'])->name('categories.toggle-status');
    Route::resource('coupons', CouponController::class)->only(['index', 'store', 'update', 'destroy']);
    Route::post('/coupons/{coupon}/toggle-status', [CouponController::class, 'toggleStatus'])->name('coupons.toggle-status');
    Route::post('/categories/{category}/suspend', [CategoryController::class, 'suspend'])->name('categories.suspend');
    Route::resource('products', ProductController::class);
    Route::post('/products/{product}/suspend', [ProductController::class, 'suspend'])->name('products.suspend');
    Route::resource('subscriptions', SubscriptionController::class);
    Route::post('/subscriptions/{subscription}/suspend', [SubscriptionController::class, 'suspend'])->name('subscriptions.suspend');
    Route::resource('ads', AdController::class);
    Route::post('/ads/{ad}/toggle-status', [AdController::class, 'toggleStatus'])->name('ads.toggle-status');
    Route::resource('cms-pages', CmsPageController::class);
    Route::post('cms-pages/{cmsPage}/suspend', [CmsPageController::class, 'suspend'])->name('cms-pages.suspend');
    Route::get('finance', [FinanceController::class, 'index'])->name('finance.index');
    Route::get('/orders/{id}/tracking', [OrderController::class, 'tracking'])->name('orders.tracking');
    Route::post('/orders/{order}/tracking-update', [OrderController::class, 'updateTracking'])->name('orders.updateTracking');
    Route::get('/vendors/{vendor}/details', [VendorController::class, 'details'])->name('vendors.details');
    Route::post('/vendors/{vendor}/update-subscription', [VendorController::class, 'updateSubscription'])->name('vendors.update-subscription');
    Route::get('/vendors/available-subscriptions', [VendorController::class, 'getAvailableSubscriptions'])->name('vendors.available-subscriptions');
    Route::get('/orders/{id}/json', [OrderController::class, 'show'])->name('orders.show.json');


    // Payout Management Routes
    Route::get('payouts', [PayoutController::class, 'index'])->name('finance.payouts');
    Route::post('payouts/generate', [PayoutController::class, 'generate'])->name('finance.payouts.generate');
    Route::get('payouts/{payout}', [PayoutController::class, 'show'])->name('finance.payouts.show');
    Route::post('payouts/{payout}/approve', [PayoutController::class, 'approve'])->name('finance.payouts.approve');
    Route::post('payouts/{payout}/complete', [PayoutController::class, 'complete'])->name('finance.payouts.complete');
    Route::post('payouts/{payout}/reject', [PayoutController::class, 'reject'])->name('finance.payouts.reject');
    Route::post('payouts/{payout}/cancel', [PayoutController::class, 'cancel'])->name('finance.payouts.cancel');
    Route::get('admin/settings', [SettingsController::class, 'index'])->name('settings.index');
    Route::post('admin/settings', [SettingsController::class, 'update'])->name('settings.update');
    Route::get('audit-logs', [AuditLogController::class, 'index'])->name('audit-logs.index');
    Route::resource('country', CountryController::class);
    Route::resource('state', StateController::class);
    Route::post('/state/{state}/toggle-status', [StateController::class, 'toggleStatus'])->name('state.toggle-status');
    Route::post('/state/{id}/restore', [StateController::class, 'restore'])->name('state.restore');
    Route::delete('/state/{id}/force-delete', [StateController::class, 'forceDelete'])->name('state.force-delete');
    Route::get('/api/states', [StateController::class, 'apiIndex'])->name('state.api.index');
    Route::resource('city', CityController::class);
    Route::post('/city/{city}/toggle-status', [CityController::class, 'toggleStatus'])->name('city.toggle-status');
    Route::post('/city/{id}/restore', [CityController::class, 'restore'])->name('city.restore');
    Route::delete('/city/{id}/force-delete', [CityController::class, 'forceDelete'])->name('city.force-delete');
    Route::get('/api/cities', [CityController::class, 'apiIndex'])->name('city.api.index');
    Route::get('/api/states-by-country', [CityController::class, 'getStatesByCountry'])->name('city.states-by-country');
    Route::post('/country/{country}/toggle-status', [CountryController::class, 'toggleStatus'])->name('country.toggle-status');


    // Vendor Profile Management Routes
    Route::prefix('vendor/')->name('vendor.profile.')->middleware(['auth', 'verified'])->group(function () {
        Route::get('/profile', [VendorProfileController::class, 'index'])->name('index')->middleware('kyc');
        Route::patch('/update', [VendorProfileController::class, 'update'])->name('update')->middleware('kyc');
        Route::post('/upload-logo', [VendorProfileController::class, 'uploadLogo'])->name('upload-logo')->middleware('kyc');
        Route::post('/send-otp', [VendorProfileController::class, 'sendPasswordChangeOTP'])->name('send-otp')->middleware('kyc');
        Route::post('/otp-verify', [VendorProfileController::class, 'verifyPasswordOTP'])->name('otp-verify')->middleware('kyc');
        Route::post('/change-password', [VendorProfileController::class, 'changePassword'])->name('change-password')->middleware('kyc');
        Route::delete('/delete-account', [VendorProfileController::class, 'deleteAccount'])->name('delete-account')->middleware('kyc');
        Route::get('/kyc-status', [VendorProfileController::class, 'kycStatus'])->name('kyc-status');
        Route::post('/resend-kyc', [VendorProfileController::class, 'resendKYC'])->name('resend-kyc');
        Route::post('/update-kyc-document', [VendorProfileController::class, 'updateKYCDocument'])->name('update-kyc-document');
    });

    Route::get('/vendor/orders/export', [OrderController::class, 'vendorExport'])->name('vendor.orders.export');
});

Route::middleware(['auth', 'vendor'])->group(function () {
    // Subscription routes - accessible without active subscription
    Route::get('/vendor/subscription', [VendorSubscriptionController::class, 'show'])->name('vendor.subscription');
    Route::post('/vendor/subscription/renew', [VendorSubscriptionController::class, 'renew']);
    Route::post('/vendor/subscription/upgrade', [VendorSubscriptionController::class, 'upgrade']);
    Route::post('/vendor/subscription/cancel', [VendorSubscriptionController::class, 'cancel']);
    Route::post('/vendor/subscribe', [VendorSubscriptionController::class, 'subscribe'])->name('vendor.subscribe');
    Route::post('/vendor/subscribe/pay-with-myfatoorah', [VendorSubscriptionController::class, 'payWithMyFatoorah'])->name('vendor.subscribe.payWithMyFatoorah');
    Route::get('/vendor/subscribe/callback', [VendorSubscriptionController::class, 'myFatoorahCallback'])->name('vendor.subscribe.callback');
    Route::get('/vendor/subscribe/error', [VendorSubscriptionController::class, 'myFatoorahError'])->name('vendor.subscribe.error');
    
    // All other vendor routes require active subscription
    Route::middleware(['vendor.subscription'])->group(function () {
        Route::get('/vendor/expos', [ExpoController::class, 'vendorList'])->name('vendor.expos.index')->middleware('kyc');
    Route::get('/vendor/expos/{expo}', [ExpoController::class, 'vendorExpoDetails'])->name('vendor.expos.show')->middleware('kyc');
    Route::post('/vendor/expos/{expo}/join', [ExpoController::class, 'joinExpo'])->name('vendor.expos.join')->middleware('kyc');
    Route::post('/vendor/expos/{expo}/book-slots', [ExpoController::class, 'bookSlots'])->name('vendor.expos.book-slots')->middleware('kyc');
    Route::post('/vendor/expos/{expo}/verify-bookings', [ExpoController::class, 'verifyBookings'])->name('vendor.expos.verify-bookings')->middleware('kyc');
    Route::post('/vendor/bookings/{booking}/process-payment', [ExpoController::class, 'processPayment'])->name('vendor.bookings.process-payment')->middleware('kyc');
    Route::get('/vendor/expos/{expo}/available-slots', [ExpoController::class, 'getAvailableSlots'])->name('vendor.expos.available-slots')->middleware('kyc');
    Route::post('/vendor/expos/{expo}/assign-products', [ExpoController::class, 'assignProducts'])->name('vendor.expos.assign-products')->middleware('kyc');
    Route::post('/vendor/expos/{expo}/create-section', [ExpoController::class, 'createSection'])->name('vendor.expos.create-section')->middleware('kyc');
    Route::post('/vendor/expos/{expo}/add-coupon', [ExpoController::class, 'addCoupon'])->name('vendor.expos.add-coupon')->middleware('kyc');
    Route::get('/vendor/my-expos', [ExpoController::class, 'myExpos'])->name('vendor.my-expos.index')->middleware('kyc');

    // Expo Slot Booking MyFatoorah Payment
    Route::post('/vendor/expo-booking/pay-with-myfatoorah', [ExpoController::class, 'payWithMyFatoorah'])->name('vendor.expoBooking.payWithMyFatoorah')->middleware('kyc');
    Route::get('/vendor/expo-booking/callback', [ExpoController::class, 'myFatoorahCallback'])->name('vendor.expoBooking.callback')->middleware('kyc');
    Route::get('/vendor/expo-booking/error', [ExpoController::class, 'myFatoorahError'])->name('vendor.expoBooking.error')->middleware('kyc');

    // expo product management routes
    Route::get('/vendor/expos/{expo}/products', [ExpoController::class, 'getVendorProducts'])->name('vendor.expos.products')->middleware('kyc');
    Route::post('/vendor/expos/{expo}/add-product', [ExpoController::class, 'addProductToExpo'])->name('vendor.expos.add-product')->middleware('kyc');
    Route::delete('/vendor/expos/{expo}/remove-product/{product}', [ExpoController::class, 'removeProductFromExpo'])->name('vendor.expos.remove-product')->middleware('kyc');
    Route::get('/vendor/expos/{expo}/assigned-products', [ExpoController::class, 'getExpoProducts'])->name('vendor.expos.assigned-products')->middleware('kyc');

    // expo section management routes
    Route::get('/vendor/expos/{expo}/sections', [ExpoController::class, 'getVendorSections'])->name('vendor.expos.sections')->middleware('kyc');
    Route::delete('/vendor/expos/{expo}/remove-section/{section}', [ExpoController::class, 'removeSectionFromExpo'])->name('vendor.expos.remove-section')->middleware('kyc');
    Route::get('/vendor/expos/{expo}/assigned-sections', [ExpoController::class, 'getExpoSections'])->name('vendor.expos.assigned-sections')->middleware('kyc');
    Route::post('/vendor/expos/{expo}/create-section', [ExpoController::class, 'createSectionForExpo'])->name('vendor.expos.create-section-new')->middleware('kyc');
    Route::get('/vendor/products', [ProductController::class, 'vendorIndex'])->name('vendor.products.index')->middleware('kyc');
    Route::get('/vendor/orders', [OrderController::class, 'vendorIndex'])->name('vendor.orders')->middleware('kyc');
    Route::get('/vendor/orders/{id}', [OrderController::class, 'show'])->name('vendor.orders.show')->middleware('kyc');
    Route::get('/vendor/orders/{id}/invoice', [OrderController::class, 'generateInvoice'])->name('vendor.orders.invoice')->middleware('kyc');
    Route::post('/vendor/orders/{id}/refund/approve', [OrderController::class, 'approveRefund'])->name('vendor.orders.refund.approve')->middleware('kyc');
    Route::post('/vendor/orders/{id}/refund/reject', [OrderController::class, 'rejectRefund'])->name('vendor.orders.refund.reject')->middleware('kyc');
    Route::post('/vendor/orders/{id}/sync-armada', [OrderController::class, 'syncFromArmada'])->name('vendor.orders.sync-armada')->middleware('kyc');
    Route::get('/vendor/orders/export', [OrderController::class, 'vendorExport'])->name('vendor.orders.export')->middleware('kyc');
    Route::post('/vendor/expos/{expo}/section-add', [ExpoController::class, 'SectionaddToExpo'])->name('vendor.expos.section-add')->middleware('kyc');



    // Vendor Ads Management Routes
    Route::resource('vendor/ads', VendorAdController::class)->names('vendor.ads')->middleware('kyc');
    Route::post('/vendor/ads/{ad}/toggle-status', [VendorAdController::class, 'toggleStatus'])->name('vendor.ads.toggle-status')->middleware('kyc');
    Route::match(['get', 'post'], '/vendor/ads/export', [AdController::class, 'export'])->name('vendor.ads.export')->middleware('kyc');

    // Vendor Finance Management Routes
    Route::get('/vendor/finance', [VendorFinanceController::class, 'index'])->name('vendor.finance.index')->middleware('kyc');
    Route::get('/vendor/payouts', [VendorFinanceController::class, 'payouts'])->name('vendor.finance.payouts')->middleware('kyc');
    Route::get('/vendor/finance/export/transactions', [VendorFinanceController::class, 'exportTransactions'])->name('vendor.finance.export.transactions')->middleware('kyc');
    Route::get('/vendor/finance/export/payouts', [VendorFinanceController::class, 'exportPayouts'])->name('vendor.finance.export.payouts')->middleware('kyc');

    // Vendor Analytics Routes (Premium Only)
    Route::get('/vendor/analytics', [VendorAnalyticsController::class, 'index'])->name('vendor.analytics.index')->middleware('kyc');
    Route::get('/vendor/analytics/export', [VendorAnalyticsController::class, 'exportAnalytics'])->name('vendor.analytics.export')->middleware('kyc');
    Route::get('/vendor/analytics/debug', [VendorAnalyticsController::class, 'debugSalesData'])->name('vendor.analytics.debug')->middleware('kyc');

        Route::resource('vendor/section', SectionController::class)->middleware('kyc');
        Route::put('vendor/section/{section}/status', [SectionController::class, 'updateStatus'])->name('section.updateStatus')->middleware('kyc');

        Route::post('/vendor/expos/{expo}/remove-product/{product}', [ExpoController::class, 'removeProduct'])
            ->name('vendor.expos.removeProduct')->middleware('kyc');
        
        // Test route for MyFatoorah configuration
        // Test route disabled - Live mode only
        // Route::get('/vendor/test-myfatoorah', [VendorSubscriptionController::class, 'testMyFatoorah'])->name('vendor.test.myfatoorah')->middleware('kyc');
    });
    
    // Debug callback route (no auth required)
    Route::get('/debug-callback', [VendorSubscriptionController::class, 'debugCallback'])->name('debug.callback');
});

// MyFatoorah API Key Test Routes (for testing)
// Test routes disabled - Live mode only
// Route::get('/test-myfatoorah', [MyFatoorahTestController::class, 'index'])->name('myfatoorah.test');
// Route::post('/test-myfatoorah-key', [MyFatoorahTestController::class, 'testApiKey'])->name('myfatoorah.test-key');
// Route::get('/test-myfatoorah-key', [MyFatoorahTestController::class, 'testApiKey'])->name('myfatoorah.test-key.get');

// Public CMS Page View Route
Route::get('/cms/{slug}', [CmsPageController::class, 'showBySlug'])->name('cms.show');

// Public Support Page
Route::get('/support', [SupportController::class, 'index'])->name('support');
Route::post('/support', [SupportController::class, 'store'])->name('support.store');


require __DIR__ . '/settings.php';
require __DIR__ . '/auth.php';
