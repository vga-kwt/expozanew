import { AppContent } from '@/components/app-content';
import { AppShell } from '@/components/app-shell';
import { AppSidebar } from '@/components/app-sidebar';
import { AppSidebarHeader } from '@/components/app-sidebar-header';
import { type BreadcrumbItem } from '@/types';
import { type PropsWithChildren, useEffect } from 'react';
import { router } from '@inertiajs/react';
import toast from 'react-hot-toast';

export default function AppSidebarLayout({ children, breadcrumbs = [] }: PropsWithChildren<{ breadcrumbs?: BreadcrumbItem[] }>) {
    useEffect(() => {
        const INACTIVITY_LIMIT = 15 * 60 * 1000; // 15 minutes
        let timer: NodeJS.Timeout;
        const resetTimer = () => {
            clearTimeout(timer);
            timer = setTimeout(() => {
                toast('You have been logged out due to inactivity.', { icon: '⏰' });
                router.post(route('logout'));
            }, INACTIVITY_LIMIT);
        };
        const events = ['mousemove', 'keydown', 'click', 'scroll'];
        events.forEach(event => window.addEventListener(event, resetTimer));
        resetTimer();
        return () => {
            clearTimeout(timer);
            events.forEach(event => window.removeEventListener(event, resetTimer));
        };
    }, []);

    return (
        <AppShell variant="sidebar">
            <AppSidebar />
            <AppContent variant="sidebar">
                <AppSidebarHeader breadcrumbs={breadcrumbs} />
                {children}
            </AppContent>
        </AppShell>
    );
}
