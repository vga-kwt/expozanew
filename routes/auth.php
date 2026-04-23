<?php

use App\Http\Controllers\Auth\AuthenticatedSessionController;
use App\Http\Controllers\Auth\ConfirmablePasswordController;
use App\Http\Controllers\Auth\EmailVerificationNotificationController;
use App\Http\Controllers\Auth\EmailVerificationPromptController;
use App\Http\Controllers\Auth\NewPasswordController;
use App\Http\Controllers\Auth\PasswordResetLinkController;
use App\Http\Controllers\Auth\RegisteredUserController;
use App\Http\Controllers\Auth\VerifyEmailController;
use App\Http\Controllers\Auth\VendorAuthController;
use Illuminate\Support\Facades\Route;


Route::get('/', function () {
    return redirect()->route('login');
});

Route::middleware('guest')->group(function () {
    Route::get('register', [RegisteredUserController::class, 'create'])
        ->name('register');

    Route::get('login', [AuthenticatedSessionController::class, 'create'])
        ->name('login');

    Route::post('login', [AuthenticatedSessionController::class, 'store']);

    Route::get('forgot-password', [PasswordResetLinkController::class, 'create'])
        ->name('password.request');

    Route::post('forgot-password', [PasswordResetLinkController::class, 'store'])
        ->name('password.email');

    Route::get('reset-password/{token}', [NewPasswordController::class, 'create'])
        ->name('password.reset');

    Route::post('reset-password', [NewPasswordController::class, 'store'])
        ->name('password.store');

    Route::get('vendor/register', [VendorAuthController::class, 'showRegistrationForm'])
        ->name('vendor.register');

    Route::post('vendor/register/send-otp', [VendorAuthController::class, 'sendOTP'])
        ->name('vendor.register.send-otp');

    Route::post('vendor/register/verify-otp', [VendorAuthController::class, 'verifyOTP'])
        ->name('vendor.register.verify-otp');

    Route::post('vendor/register/complete', [VendorAuthController::class, 'completeRegistration'])
        ->name('vendor.register.complete');

    Route::get('vendor/login', [VendorAuthController::class, 'showLoginForm'])
        ->name('vendor.login');

    Route::post('vendor/login', [VendorAuthController::class, 'login']);

    Route::get('vendor/forgot-password', [VendorAuthController::class, 'showForgotPasswordForm'])
        ->name('vendor.password.request');

    Route::post('vendor/forgot-password', [VendorAuthController::class, 'sendPasswordResetEmail'])
        ->name('vendor.password.email');

    Route::get('vendor/reset-password/{token}', [VendorAuthController::class, 'showPasswordResetForm'])
        ->name('vendor.password.reset');

    Route::post('vendor/reset-password', [VendorAuthController::class, 'resetPassword'])
        ->name('vendor.password.update');

    Route::post('vendor/verify-otp', [VendorAuthController::class, 'verifyForgotOtp'])->name('vendor.verify-otp');
    // Route::post('vendor/reset-password', [VendorAuthController::class, 'resetPassword'])->name('vendor.reset-password');
});

Route::middleware('auth')->group(function () {
    Route::get('verify-email', EmailVerificationPromptController::class)
        ->name('verification.notice');

    Route::get('verify-email/{id}/{hash}', VerifyEmailController::class)
        ->middleware(['signed', 'throttle:6,1'])
        ->name('verification.verify');

    Route::post('email/verification-notification', [EmailVerificationNotificationController::class, 'store'])
        ->middleware('throttle:6,1')
        ->name('verification.send');

    Route::get('confirm-password', [ConfirmablePasswordController::class, 'show'])
        ->name('password.confirm');

    Route::post('confirm-password', [ConfirmablePasswordController::class, 'store']);

    Route::post('logout', [AuthenticatedSessionController::class, 'destroy'])
        ->name('logout');

    Route::post('vendor/logout', [VendorAuthController::class, 'logout'])
        ->name('vendor.logout');
});
