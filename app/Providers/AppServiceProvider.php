<?php

namespace App\Providers;

use Illuminate\Support\ServiceProvider;
use Illuminate\Support\Facades\Auth;
use Inertia\Inertia;

class AppServiceProvider extends ServiceProvider
{
    /**
     * Register any application services.
     */
    public function register(): void
    {
        //
    }

    /**
     * Bootstrap any application services.
     */
    public function boot(): void
    {
        Inertia::share([
            'auth' => function () {
                $user = Auth::user();
                return [
                    'user' => $user ? array_merge(
                        $user->toArray(),
                        ['role' => $user->role ?? $user->getRoleNames()->first()]
                    ) : null,
                    'role' => $user ? ($user->role ?? $user->getRoleNames()->first()) : null,
                    'permissions' => $user ? $user->getAllPermissions()->pluck('name') : [],
                ];
            },
        ]);
    }
}
