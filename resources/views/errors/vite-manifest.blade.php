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
            --code-bg: #f3f4f6;
            --code-text: #1f2937;
            --btn-primary-bg: #667eea;
            --btn-primary-hover: #5568d3;
        }
        
        .dark {
            --bg-gradient-start: #1a1a2e;
            --bg-gradient-end: #16213e;
            --card-bg: #1f2937;
            --text-primary: #f9fafb;
            --text-secondary: #d1d5db;
            --text-error: #f87171;
            --code-bg: #374151;
            --code-text: #f9fafb;
            --btn-primary-bg: #667eea;
            --btn-primary-hover: #5568d3;
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
            max-width: 600px;
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
        
        .error-message {
            font-size: 1.125rem;
            color: var(--text-secondary);
            margin-bottom: 2rem;
            line-height: 1.6;
            transition: color 0.3s ease;
        }
        
        .steps {
            text-align: left;
            margin-bottom: 2rem;
            background: var(--code-bg);
            border-radius: 0.5rem;
            padding: 1.5rem;
            transition: background 0.3s ease;
        }
        
        .steps h3 {
            font-size: 1rem;
            font-weight: 600;
            color: var(--text-primary);
            margin-bottom: 1rem;
            transition: color 0.3s ease;
        }
        
        .steps ol {
            list-style: decimal;
            padding-left: 1.5rem;
            color: var(--text-secondary);
            transition: color 0.3s ease;
        }
        
        .steps li {
            margin-bottom: 0.75rem;
            line-height: 1.6;
        }
        
        .steps code {
            background: var(--code-bg);
            padding: 0.25rem 0.5rem;
            border-radius: 0.25rem;
            font-family: 'Courier New', monospace;
            font-size: 0.875rem;
            color: var(--code-text);
            transition: background 0.3s ease, color 0.3s ease;
        }
        
        .command-box {
            margin-top: 1rem;
            padding: 1rem;
            background: #1f2937;
            border-radius: 0.5rem;
            color: #f9fafb;
        }
        
        .dark .command-box {
            background: #0f172a;
        }
        
        .command-box code {
            color: #10b981;
            background: transparent;
            display: block;
            margin-bottom: 0.5rem;
        }
        
        .refresh-btn {
            background: var(--btn-primary-bg);
            color: white;
            padding: 0.75rem 2rem;
            border: none;
            border-radius: 0.5rem;
            font-size: 1rem;
            font-weight: 600;
            cursor: pointer;
            transition: background 0.2s ease;
        }
        
        .refresh-btn:hover {
            background: var(--btn-primary-hover);
        }
        
        @media (max-width: 640px) {
            .error-container {
                padding: 2rem 1.5rem;
            }
            
            .error-title {
                font-size: 1.5rem;
            }
        }
    </style>
</head>
<body>
    <div class="error-container">
        <div class="error-icon">⚠️</div>
        <h1 class="error-title">Application Under Maintenance</h1>
        <p class="error-message">
            We're currently updating the application. Please check back in a few moments.
        </p>
        
        <div class="steps">
            <h3>For Administrators:</h3>
            <p style="color: var(--text-secondary); margin-bottom: 1rem; font-size: 0.9rem;">
                The application assets need to be built. Run these commands on the server:
            </p>
            <div class="command-box">
                <code>npm install</code>
                <code>npm run build</code>
            </div>
        </div>
        
        <button class="refresh-btn" onclick="window.location.reload()">
            Refresh Page
        </button>
    </div>
</body>
</html>
