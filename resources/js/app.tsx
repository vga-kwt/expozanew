import '../css/app.css';
import { createInertiaApp } from '@inertiajs/react';
import { resolvePageComponent } from 'laravel-vite-plugin/inertia-helpers';
import { createRoot } from 'react-dom/client';
import { Toaster } from 'react-hot-toast';
import { LanguageProvider } from './components/language-context';
import { AppearanceProvider } from './context/AppearanceProvider';

// Set up CSRF token for fetch requests
const token = document.head.querySelector('meta[name="csrf-token"]');
if (token) {
    (window as unknown as { Laravel: { csrfToken: string } }).Laravel = {
        csrfToken: token.getAttribute('content') || ''
    };
}

const appName = import.meta.env.VITE_APP_NAME || 'Laravel';

createInertiaApp({
    title: (title) => `${title} - ${appName}`,
    resolve: (name) => resolvePageComponent(`./pages/${name}.tsx`, import.meta.glob('./pages/**/*.tsx')),
    setup({ el, App, props }) {
        const root = createRoot(el);

        root.render(
            <LanguageProvider>
                <AppearanceProvider>
                    <>
                        <App {...props} />
                        <Toaster position="top-right" toastOptions={{ duration: 3000 }} />
                    </>
                </AppearanceProvider>
            </LanguageProvider>,
        );
    },
    progress: {
        color: '#4B5563',
    },
});
