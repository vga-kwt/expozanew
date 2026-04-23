<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\ExpoController;
use App\Http\Controllers\Api\VendorController;
use App\Http\Controllers\Api\ProductController;
use App\Http\Controllers\Api\CategoryController;
use App\Http\Controllers\Api\OrderController;
use App\Http\Controllers\Api\AdController;
use App\Http\Controllers\Api\UserController;
use App\Http\Controllers\Api\SubscriptionController;
use App\Http\Controllers\Api\FinanceController;
use App\Http\Controllers\Api\CmsPageController;
use App\Http\Controllers\Api\AuditLogController;
use App\Http\Controllers\Api\SettingsController;
use App\Http\Controllers\Api\OtpController;
use App\Http\Controllers\Api\ProfileController;
use App\Http\Controllers\Api\AddressController;
use App\Http\Controllers\Api\WishlistController;
use App\Http\Controllers\Api\NotificationController;
use App\Http\Controllers\Api\FaqController;
use App\Http\Controllers\Api\SupportController;
use App\Http\Controllers\Api\CartController;
use App\Http\Controllers\Api\CheckoutController;
use App\Http\Controllers\Api\ExpoVendorController;
use App\Http\Controllers\Api\LocationController;
use App\Http\Controllers\Api\ReviewController;
use App\Http\Controllers\Api\ProductSearchController;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
|
| Here is where you can register API routes for your application. These
| routes are loaded by the RouteServiceProvider and all of them will
| be assigned to the "api" middleware group. Make something great!
|
*/



// Public expo routes
Route::get('/expos/active', [ExpoController::class, 'activeExpos']);
Route::get('/expos/upcoming', [ExpoController::class, 'upcomingExpos']);

// Banner ads
Route::get('/banner-ads', [AdController::class, 'activeBannerAds']);

// product details  
Route::get('/product-details/{productId}', [ProductController::class, 'details']);

// vendor details
Route::get('/vendor-details/{vendorId}', [VendorController::class, 'details']);

// Expo vendors and products
Route::post('/expo-vendors/{expoId}', [ExpoVendorController::class, 'index']);
Route::get('/expo-featured-vendors/{expoId}', [ExpoVendorController::class, 'featuredVendors']);
Route::post('/expo-products/{expoId}/{vendorId}', [ProductController::class, 'expoProducts']);
Route::get('/expo-products/{expoId}', [ProductController::class, 'expoProductsList']);

// Similar products
Route::get('/products/{productId}/similar', [ProductController::class, 'similarProducts']);

// Product search
Route::post('/search/products', [ProductSearchController::class, 'search']);

Route::get('/expo-details/{expoId}', [ExpoController::class, 'details']);



// OTP-based authentication (SRS)
Route::post('/send-otp', [OtpController::class, 'sendOtp']);
Route::post('/verify-otp', [OtpController::class, 'verifyOtp']);
Route::post('/signup', [OtpController::class, 'signup']);
Route::post('/login', [OtpController::class, 'login']);
Route::post('/forgot-password', [OtpController::class, 'forgotPassword']);
Route::post('/check-validated', [OtpController::class, 'checkValidated']);
Route::post('/resend-otp', [OtpController::class,'resendOtp']);

// Socialite signin
Route::post('/google-signin', [OtpController::class, 'googleSignIn']);
Route::post('/apple-signin', [OtpController::class, 'appleSignIn']);

// Public countries, states, cities
Route::get('/countries', [LocationController::class, 'countries']);
Route::get('/states/{country_id}', [LocationController::class, 'states']);
Route::get('/cities/{country_id}/{state_id}', [LocationController::class, 'cities']);

// Public product reviews
Route::get('/reviews/product/{productId}', [ReviewController::class, 'productReviews']);

Route::post('/profile/change-language', [ProfileController::class, 'changeLanguage']);

// Protected routes
Route::middleware('auth:sanctum')->group(function () {
    Route::post('/logout', [AuthController::class, 'logout']);
    Route::get('/user', [AuthController::class, 'user']);
    Route::put('/user/profile', [AuthController::class, 'updateProfile']);
    Route::put('/user/password', [AuthController::class, 'updatePassword']);


    // Profile section (SRS)
    Route::get('/profile', [ProfileController::class, 'show']);
    Route::post('/profile', [ProfileController::class, 'update']);
    Route::post('/profile/send-otp', [ProfileController::class, 'sendOtp']);
    Route::post('/profile/change-mobile', [ProfileController::class, 'changeMobile']);
    Route::post('/profile/change-password', [ProfileController::class, 'changePassword']);
    Route::delete('/profile', [ProfileController::class, 'destroy']);

    // Addresses (SRS)
    Route::get('/addresses', [AddressController::class, 'index']);
    Route::post('/addresses', [AddressController::class, 'store']);
    Route::get('/addresses/{id}', [AddressController::class, 'show']);
    Route::put('/addresses/{id}', [AddressController::class, 'update']);
    Route::delete('/addresses/{id}', [AddressController::class, 'destroy']);

    // Wishlist (SRS)
    Route::get('/wishlist', [WishlistController::class, 'index']);
    Route::post('/wishlist/add', [WishlistController::class, 'store']);
    Route::post('/wishlist', [WishlistController::class, 'store']);
    Route::delete('/wishlist/remove/{id}', [WishlistController::class, 'destroy']);
    Route::delete('/wishlist/clear', [WishlistController::class, 'clear']);
    Route::get('/all-wishlist', [WishlistController::class, 'allWishlist']);

    // Notifications (SRS)
    Route::get('/notifications', [NotificationController::class, 'index']);
    Route::post('/notifications/{id}/read', [NotificationController::class, 'markAsRead']);
    Route::delete('/notifications/{id}', [NotificationController::class, 'destroy']);

    // Cart (SRS)
    Route::get('/cart', [CartController::class, 'index']);
    Route::post('/cart/add', [CartController::class, 'add']);
    Route::put('/cart/update/{id}', [CartController::class, 'update']);
    Route::delete('/cart/remove/{id}', [CartController::class, 'remove']);
    Route::delete('/cart/clear', [CartController::class, 'clear']);
    Route::post('/cart/coupon/validate', [CartController::class, 'validateCoupon']);
    Route::delete('/cart/coupon', [CartController::class, 'removeCoupon']);

    // Checkout (SRS)
    Route::post('/checkout/confirm', [CheckoutController::class, 'checkoutOrConfirm']);

    // Orders (SRS)
    Route::get('/orders', [OrderController::class, 'index']);
    Route::get('/past-orders', [OrderController::class, 'pastOrders']);
    Route::get('/orders/{id}', [OrderController::class, 'show']);
    Route::post('/orders/place', [OrderController::class, 'place']);
    Route::post('/orders/cancel/{id}', [OrderController::class, 'cancel']);
    Route::post('/orders/{id}/refund', [OrderController::class, 'requestRefund']);
    Route::get('/orders/{id}/invoice', [OrderController::class, 'getInvoice']);
    Route::get('/orders/{id}/status', [OrderController::class, 'OrdersStatus']);
    Route::get('/orders/{id}/track', [OrderController::class, 'track']);
    Route::get('/all-orders', [OrderController::class,'allOrders']);
    
    // Reviews
    Route::get('/reviews', [ReviewController::class, 'index']);
    Route::get('/reviews/{id}', [ReviewController::class, 'show']);
    Route::post('/reviews', [ReviewController::class, 'store']);
    // Review specific order items
    Route::post('/order-items/review', [ReviewController::class, 'reviewOrderItems']);
    Route::put('/reviews/{id}', [ReviewController::class, 'update']);
    Route::delete('/reviews/{id}', [ReviewController::class, 'destroy']);
    // Get review status for each item in an order
    Route::get('/orders/{order_id}/items/review-status', [ReviewController::class, 'orderItemsReviewStatus']);


});

// FAQ (public)
Route::get('/cms-pages/{slug}', [CmsPageController::class, 'listBySlug']);

Route::get('faqs', [FaqController::class, 'index']);
// Contact Support (public)
Route::post('/contact-support', [SupportController::class, 'contact']);

// New email OTP endpoints
Route::post('/send-email-otp', [AuthController::class, 'sendEmailOtp']);
Route::post('/verify-email-otp', [AuthController::class, 'verifyEmailOtp']);
Route::post('/reset-password-with-otp', [AuthController::class, 'resetPasswordWithOtp']);

// Armada Webhook (public, but should be secured with signature verification)
Route::post('/webhooks/armada', [\App\Http\Controllers\Api\ArmadaWebhookController::class, 'handle']);
