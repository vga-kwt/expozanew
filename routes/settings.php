<?php

use App\Http\Controllers\Settings\PasswordController;
use App\Http\Controllers\Settings\ProfileController;
use App\Http\Controllers\FaqController;
use Illuminate\Support\Facades\Route;
use Inertia\Inertia;

Route::middleware('auth')->group(function () {
    Route::redirect('settings', 'settings/profile');

    Route::get('settings/profile', [ProfileController::class, 'edit'])->name('profile.edit');
    Route::patch('settings/profile', [ProfileController::class, 'update'])->name('profile.update');
    Route::delete('settings/profile', [ProfileController::class, 'destroy'])->name('profile.destroy');

    Route::get('settings/password', [PasswordController::class, 'edit'])->name('password.edit');
    Route::put('settings/password', [PasswordController::class, 'update'])->name('password.update');

    // FAQ Management
    Route::get('settings/faq', [FaqController::class, 'index'])->name('settings.faq.index');
    Route::post('settings/faq', [FaqController::class, 'store'])->name('settings.faq.store');
    Route::put('settings/faq/{faq}', [FaqController::class, 'update'])->name('settings.faq.update');
    Route::delete('settings/faq/{faq}', [FaqController::class, 'destroy'])->name('settings.faq.destroy');

    Route::get('settings/appearance', function () {
        return Inertia::render('Settings/appearance');
    })->name('appearance');
});
