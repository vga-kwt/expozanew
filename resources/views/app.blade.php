<!DOCTYPE html>
<html lang="{{ str_replace('_', '-', app()->getLocale()) }}" @class(['dark' => ($appearance ?? 'system') == 'dark'])>
    <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <meta name="csrf-token" content="{{ csrf_token() }}">

        {{-- Inline script to detect system dark mode preference and apply it immediately --}}
        <script>
            (function() {
                const appearance = '{{ $appearance ?? "system" }}';

                if (appearance === 'system') {
                    const prefersDark = window.matchMedia('(prefers-color-scheme: dark)').matches;

                    if (prefersDark) {
                        document.documentElement.classList.add('dark');
                    }
                }

                window.__google_maps_api_key = '{{ config("services.google_maps.api_key", "") }}';
            })();
        </script>

        {{-- Inline style to set the HTML background color based on our theme in app.css --}}
        <style>
            html {
                background-color: oklch(1 0 0);
            }

            html.dark {
                background-color: oklch(0.145 0 0);
            }
        </style>

        <title inertia>{{ config('app.name', 'Laravel') }}</title>

        <link rel="icon" type="image/svg+xml" href="/black-logo.svg" />
        <link rel="alternate icon" type="image/x-icon" href="/black-logo.svg" />

        <link rel="preconnect" href="https://fonts.bunny.net">
        <link href="https://fonts.bunny.net/css?family=instrument-sans:400,500,600" rel="stylesheet" />

        @routes
        @php
            // Check if Vite manifest exists
            $manifestPath = public_path('build/manifest.json');
            $manifestExists = file_exists($manifestPath);
            
            // In production, we need the manifest file
            if (!$manifestExists && app()->environment('production')) {
                // Try to create build directory if it doesn't exist
                $buildDir = public_path('build');
                if (!is_dir($buildDir)) {
                    @mkdir($buildDir, 0755, true);
                }
            }
        @endphp
        
        @if($manifestExists || !app()->environment('production'))
        @viteReactRefresh
        @vite(['resources/js/app.tsx', "resources/js/pages/{$page['component']}.tsx"])
        @else
            {{-- Production environment without manifest - show helpful error --}}
            <style>
                .build-error {
                    display: flex;
                    align-items: center;
                    justify-content: center;
                    height: 100vh;
                    flex-direction: column;
                    font-family: system-ui, -apple-system, sans-serif;
                    background: #f9fafb;
                    padding: 2rem;
                }
                .build-error h1 {
                    color: #dc2626;
                    margin-bottom: 1rem;
                    font-size: 1.5rem;
                }
                .build-error p {
                    color: #6b7280;
                    margin-bottom: 0.5rem;
                    text-align: center;
                }
                .build-error code {
                    background: #f3f4f6;
                    padding: 0.25rem 0.5rem;
                    border-radius: 0.25rem;
                    font-family: 'Courier New', monospace;
                    color: #1f2937;
                }
            </style>
            <div class="build-error">
                <h1>⚠️ Build Required</h1>
                <p>The Vite manifest file is missing.</p>
                <p>To fix this, run the following commands on your server:</p>
                <p><code>npm install</code></p>
                <p><code>npm run build</code></p>
                <p style="margin-top: 1rem; font-size: 0.875rem;">The manifest file should be located at:<br><code style="font-size: 0.75rem;">{{ public_path('build/manifest.json') }}</code></p>
            </div>
        @endif
        @inertiaHead
    </head>
    <body class="font-sans antialiased">
        @inertia
    </body>
</html>
