<!DOCTYPE html>
<html lang="en" class="light">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>{{ config('app.name', 'Laravel') }}</title>
    <script>
        // Detect and apply theme
        (function() {
            const savedTheme = localStorage.getItem('theme') || 'light';
            const prefersDark = window.matchMedia('(prefers-color-scheme: dark)').matches;
            const theme = savedTheme === 'dark' || (savedTheme === 'system' && prefersDark) ? 'dark' : 'light';
            document.documentElement.classList.remove('light', 'dark');
            document.documentElement.classList.add(theme);
        })();
    </script>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        :root {
            --bg-gradient-start: #667eea;
            --bg-gradient-end: #764ba2;
            --card-bg: #ffffff;
            --text-primary: #1f2937;
            --text-secondary: #6b7280;
            --text-error: #dc2626;
            --btn-primary-bg: #667eea;
            --btn-primary-hover: #5568d3;
            --btn-secondary-bg: #f3f4f6;
            --btn-secondary-hover: #e5e7eb;
            --btn-secondary-text: #374151;
        }
        
        .dark {
            --bg-gradient-start: #1a1a2e;
            --bg-gradient-end: #16213e;
            --card-bg: #1f2937;
            --text-primary: #f9fafb;
            --text-secondary: #d1d5db;
            --text-error: #f87171;
            --btn-primary-bg: #667eea;
            --btn-primary-hover: #5568d3;
            --btn-secondary-bg: #374151;
            --btn-secondary-hover: #4b5563;
            --btn-secondary-text: #f9fafb;
        }
        
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;
            background: linear-gradient(135deg, var(--bg-gradient-start) 0%, var(--bg-gradient-end) 100%);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 2rem;
            color: var(--text-primary);
            transition: background 0.3s ease;
        }
        
        .error-container {
            background: var(--card-bg);
            border-radius: 1rem;
            box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.1), 0 10px 10px -5px rgba(0, 0, 0, 0.04);
            max-width: 700px;
            width: 100%;
            padding: 3rem;
            text-align: center;
            transition: background 0.3s ease, color 0.3s ease;
        }
        
        .error-icon {
            font-size: 4rem;
            margin-bottom: 1.5rem;
        }
        
        .error-title {
            font-size: 2rem;
            font-weight: 700;
            color: var(--text-primary);
            margin-bottom: 1rem;
            transition: color 0.3s ease;
        }

        .error-type {
            font-size: 1.1rem;
            color: var(--text-error);
            margin-bottom: 0.75rem;
            font-weight: 500;
            transition: color 0.3s ease;
            word-break: break-all;
        }
        
        .error-message {
            font-size: 1.125rem;
            color: var(--text-secondary);
            margin-bottom: 2rem;
            line-height: 1.6;
            transition: color 0.3s ease;
        }

        .error-details {
            background: var(--btn-secondary-bg);
            border-radius: 0.5rem;
            padding: 1.5rem;
            margin: 2rem 0;
            text-align: left;
            font-family: 'Courier New', monospace;
            font-size: 0.875rem;
            max-height: 400px;
            overflow-y: auto;
            border: 1px solid var(--btn-secondary-hover);
        }

        .error-details-title {
            font-weight: 600;
            margin-bottom: 0.75rem;
            color: var(--text-primary);
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
        }

        .error-detail-item {
            margin-bottom: 0.5rem;
            color: var(--text-secondary);
        }

        .error-detail-label {
            font-weight: 600;
            color: var(--text-primary);
        }

        .error-stack {
            background: rgba(0, 0, 0, 0.05);
            padding: 1rem;
            border-radius: 0.25rem;
            margin-top: 0.5rem;
            white-space: pre-wrap;
            word-break: break-all;
            font-size: 0.8rem;
            max-height: 300px;
            overflow-y: auto;
        }

        .dark .error-stack {
            background: rgba(255, 255, 255, 0.05);
        }

        .toggle-details {
            background: transparent;
            border: 1px solid var(--btn-primary-bg);
            color: var(--btn-primary-bg);
            padding: 0.5rem 1rem;
            border-radius: 0.25rem;
            cursor: pointer;
            font-size: 0.875rem;
            margin-top: 1rem;
            transition: all 0.2s;
        }

        .toggle-details:hover {
            background: var(--btn-primary-bg);
            color: white;
        }
        
        .actions {
            display: flex;
            gap: 1rem;
            justify-content: center;
            flex-wrap: wrap;
        }
        
        .btn {
            padding: 0.75rem 2rem;
            border: none;
            border-radius: 0.5rem;
            font-size: 1rem;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.2s;
            text-decoration: none;
            display: inline-block;
        }
        
        .btn-primary {
            background: var(--btn-primary-bg);
            color: white;
            transition: background 0.2s ease;
        }
        
        .btn-primary:hover {
            background: var(--btn-primary-hover);
        }
        
        .btn-secondary {
            background: var(--btn-secondary-bg);
            color: var(--btn-secondary-text);
            transition: background 0.2s ease, color 0.2s ease;
        }
        
        .btn-secondary:hover {
            background: var(--btn-secondary-hover);
        }
        
        @media (max-width: 640px) {
            .error-container {
                padding: 2rem 1.5rem;
            }
            
            .error-title {
                font-size: 1.5rem;
            }
            
            .actions {
                flex-direction: column;
            }
            
            .btn {
                width: 100%;
            }
            .error-type {
                font-size: 1rem;
            }
            
            .error-details {
                padding: 1rem;
                font-size: 0.75rem;
            }
        }
    </style>
</head>
<body>
    <div class="error-container">
        <div class="error-icon">
            @if(isset($statusCode))
                @if($statusCode == 404)
                    🔍
                @elseif($statusCode == 403)
                    🔒
                @else
                    ⚠️
                @endif
            @else
                ⚠️
            @endif
        </div>
        {{-- Error code and error type --}}
        @if(isset($statusCode))
            <div class="error-type">
                Error Code: {{ $statusCode }}
                @if(isset($exception) && config('app.debug'))
                    <br>
                    <span style="font-size: 0.9rem;">{{ get_class($exception) }}</span>
                @endif
            </div>
        @endif
        <h1 class="error-title">
            @if(isset($statusCode))
                @if($statusCode == 404)
                    Page Not Found
                @elseif($statusCode == 403)
                    Access Restricted
                @else
                    Service Temporarily Unavailable
                @endif
            @else
                Service Temporarily Unavailable
            @endif
        </h1>
        <p class="error-message">
            @if(isset($message) && !empty($message))
                {{ $message }}
            @elseif(isset($statusCode))
                @if($statusCode == 404)
                    The page you are looking for could not be found. It may have been moved or deleted.
                @elseif($statusCode == 403)
                    You don't have permission to access this resource. Please contact your administrator if you believe this is an error.
                @else
                    We're currently performing maintenance to improve your experience. Please check back in a few moments. Thank you for your patience.
                @endif
            @else
                We're currently performing maintenance to improve your experience. Please check back in a few moments. Thank you for your patience.
            @endif
        </p>

        {{-- Debug Details --}}
        @if(isset($exception) && config('app.debug'))
            <div class="error-details">
                <div class="error-details-title">Error Details:</div>
                
                <div class="error-detail-item">
                    <span class="error-detail-label">Message:</span><br>
                    <span>{{ $exception->getMessage() }}</span>
                </div>
                
                <div class="error-detail-item">
                    <span class="error-detail-label">File:</span><br>
                    <span>{{ $exception->getFile() }}</span>
                </div>
                
                <div class="error-detail-item">
                    <span class="error-detail-label">Line:</span><br>
                    <span>{{ $exception->getLine() }}</span>
                </div>
                
                @if($exception->getCode())
                    <div class="error-detail-item">
                        <span class="error-detail-label">Code:</span><br>
                        <span>{{ $exception->getCode() }}</span>
                    </div>
                @endif
                
                <div class="error-detail-item">
                    <span class="error-detail-label">Stack Trace:</span>
                    <div class="error-stack">{{ $exception->getTraceAsString() }}</div>
                </div>
            </div>
        @endif
        <div class="actions">
            <button class="btn btn-primary" onclick="window.location.reload()">
                Refresh Page
            </button>
        </div>
    </div>
</body>
</html>
