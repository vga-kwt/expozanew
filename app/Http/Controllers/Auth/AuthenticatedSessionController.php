<?php

namespace App\Http\Controllers\Auth;

use App\Http\Controllers\Controller;
use App\Http\Requests\Auth\LoginRequest;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Route;
use Inertia\Inertia;
use Inertia\Response;
use Illuminate\Validation\ValidationException;


class AuthenticatedSessionController extends Controller
{
    /**
     * Show the login page.
     */
    public function create(Request $request): Response
    {
        return Inertia::render('auth/login', [
            'canResetPassword' => Route::has('password.request'),
            'status' => $request->session()->get('status'),
            'error' => $request->session()->get('error'),
        ]);
    }

    /**
     * Handle an incoming authentication request.
     */
    public function store(LoginRequest $request): RedirectResponse
    {
        $request->authenticate();
    
        $user = Auth::user();
    
        if (!$user->hasRole('admin')) {
            Auth::logout();
            throw ValidationException::withMessages([
                'email' => 'This is not your login page. Please use the vendor login.',
            ]);
        }
    
        $user->last_login_at = now();
        $user->save();
    
        // Log login action
        $this->auditLog('login', 'auth', "User {$user->full_name} logged in", [
            'user_id' => $user->id,
            'email' => $user->email,
            'role' => $user->role,
        ]);
    
        $request->session()->regenerate();
    
        return redirect()->intended(route('dashboard'));
    }

    /**
     * Destroy an authenticated session.
     */
    public function destroy(Request $request): RedirectResponse
    {
        $user = Auth::user();
        
        Auth::guard('web')->logout();

        // Log logout action
        if ($user) {
            $this->auditLog('logout', 'auth', "User {$user->full_name} logged out", [
                'user_id' => $user->id,
                'email' => $user->email,
            ]);
        }

        $request->session()->invalidate();
        $request->session()->regenerateToken();

        return redirect('/login');
    }
}
