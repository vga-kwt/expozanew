<?php

use App\Http\Middleware\HandleAppearance;
use App\Http\Middleware\HandleInertiaRequests;
use App\Http\Middleware\CheckKYCStatus;
use App\Http\Middleware\IsVendor;
use App\Http\Middleware\CheckVendorSubscription;
use Illuminate\Foundation\Application;
use Illuminate\Foundation\Configuration\Exceptions;
use Illuminate\Foundation\Configuration\Middleware;
use Illuminate\Http\Middleware\AddLinkHeadersForPreloadedAssets;
use Illuminate\Auth\AuthenticationException;
use Illuminate\Foundation\ViteManifestNotFoundException;
use Illuminate\Validation\ValidationException;

return Application::configure(basePath: dirname(__DIR__))
    ->withRouting(
        web: __DIR__.'/../routes/web.php',
        api: __DIR__.'/../routes/api.php',
        commands: __DIR__.'/../routes/console.php',
        health: '/up',
    )
    ->withMiddleware(function (Middleware $middleware) {
        $middleware->encryptCookies(except: ['appearance', 'sidebar_state']);

        $middleware->web(append: [
            HandleAppearance::class,
            HandleInertiaRequests::class,
            AddLinkHeadersForPreloadedAssets::class,
        ]);

        // Register custom middleware aliases
        $middleware->alias([
            'kyc' => CheckKYCStatus::class,
            'vendor' => IsVendor::class,
            'vendor.subscription' => CheckVendorSubscription::class,
        ]);
    })
    ->withExceptions(function (Exceptions $exceptions) {
        // Handle authentication exceptions for API routes
        $exceptions->render(function (AuthenticationException $e, $request) {
            // Check if this is an API request
            if ($request->is('api/*') || $request->expectsJson()) {
                return response()->json([
                    'success' => false,
                    'message' => 'Unauthenticated. Please login to your account.',
                ], 401);
            }
            
            // For web requests, redirect to login or show error page
            return response()->view('errors.general', [
                'statusCode' => 401,
                'message' => 'You need to be authenticated to access this page.',
            ], 401);
        });
        
        // Handle Vite manifest not found exception - show specific error page
        $exceptions->render(function (ViteManifestNotFoundException $e, $request) {
            // Don't show Vite error for API requests
            if ($request->is('api/*') || $request->expectsJson()) {
                return response()->json([
                    'success' => false,
                    'message' => 'Application assets are not built. Please contact administrator.',
                ], 500);
            }
            
            $manifestPath = $e->getMessage();
            
            // Extract path from error message if possible
            if (preg_match('/at: (.+)/', $manifestPath, $matches)) {
                $manifestPath = $matches[1];
            }
            
            return response()->view('errors.vite-manifest', [
                'manifestPath' => $manifestPath,
            ], 500);
        });
        
        // Handle 404 Not Found exceptions
        $exceptions->render(function (\Symfony\Component\HttpKernel\Exception\NotFoundHttpException $e, $request) {
            if ($request->is('api/*') || $request->expectsJson()) {
                return response()->json([
                    'success' => false,
                    'message' => 'The requested resource was not found.',
                ], 404);
            }
            
            return response()->view('errors.general', [
                'statusCode' => 404,
                'message' => 'The page you are looking for could not be found.',
            ], 404);
        });
        
        // Handle 403 Forbidden exceptions
        $exceptions->render(function (\Symfony\Component\HttpKernel\Exception\AccessDeniedHttpException $e, $request) {
            if ($request->is('api/*') || $request->expectsJson()) {
                return response()->json([
                    'success' => false,
                    'message' => 'You don\'t have permission to access this resource.',
                ], 403);
            }
            
            return response()->view('errors.general', [
                'statusCode' => 403,
                'message' => 'You don\'t have permission to access this resource.',
            ], 403);
        });
        
        // Handle ValidationException - let Inertia handle it automatically
        $exceptions->render(function (ValidationException $e, $request) {
            // For API requests, return JSON with validation errors
            if ($request->is('api/*') || $request->expectsJson()) {
                return response()->json([
                    'success' => false,
                    'message' => 'Validation failed.',
                    'errors' => $e->errors(),
                ], 422);
            }
            
            // For Inertia and regular web requests, redirect back with errors
            // Inertia will automatically pick up these errors and display them in the form
            return redirect()->back()
                ->withInput()
                ->withErrors($e->errors());
        });
        
        // Handle all other exceptions - show general error page
        $exceptions->render(function (\Throwable $e, $request) {
            // Handle API requests - return JSON
            if ($request->is('api/*') || $request->expectsJson()) {
                $statusCode = 500;
                if ($e instanceof \Symfony\Component\HttpKernel\Exception\HttpException) {
                    $statusCode = $e->getStatusCode();
                }
                
                return response()->json([
                    'success' => false,
                    'message' => config('app.debug') ? $e->getMessage() : 'An error occurred. Please try again later.',
                    'error' => config('app.debug') ? [
                        'file' => $e->getFile(),
                        'line' => $e->getLine(),
                        'trace' => $e->getTraceAsString(),
                    ] : null,
                ], $statusCode);
            }
            
            // Get status code
            $statusCode = 500;
            if ($e instanceof \Symfony\Component\HttpKernel\Exception\HttpException) {
                $statusCode = $e->getStatusCode();
            } elseif ($e instanceof \Illuminate\Http\Exceptions\HttpResponseException) {
                $statusCode = $e->getResponse()->getStatusCode();
            }
            
            // Get user-friendly error message
            $message = 'Something went wrong. Please try again later.';
            
            if (config('app.debug')) {
                // In debug mode, show actual error message
                $message = $e->getMessage();
            } else {
                // In production, show user-friendly messages based on error type
                if ($statusCode == 404) {
                    $message = 'The page you are looking for could not be found.';
                } elseif ($statusCode == 403) {
                    $message = 'You don\'t have permission to access this resource.';
                } elseif ($statusCode == 500) {
                    $message = 'Something went wrong on our end. Please try again later.';
                } elseif ($statusCode == 503) {
                    $message = 'The service is temporarily unavailable. Please try again later.';
                }
            }
            
            return response()->view('errors.general', [
                'statusCode' => $statusCode,
                'message' => $message,
                'exception' => config('app.debug') ? $e : null,
            ], $statusCode);
        });
    })->create();
