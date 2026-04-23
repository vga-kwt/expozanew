import { Breadcrumbs } from '@/components/breadcrumbs';
import { SidebarTrigger } from '@/components/ui/sidebar';
import { useAppearance } from '@/hooks/use-appearance';
import { useLanguage } from '@/components/language-context';
import { type BreadcrumbItem as BreadcrumbItemType } from '@/types';
import { Moon, Sun } from 'lucide-react';

export function AppSidebarHeader({ breadcrumbs = [] }: { breadcrumbs?: BreadcrumbItemType[] }) {
    const { appearance, updateAppearance } = useAppearance();
    const { language, setLanguage } = useLanguage();
    const isRtl = language === 'ar';
    // In RTL, flex reverses so Sun is on the right and Moon on the left; flip circle position so the highlight matches the active theme
    const circleOnStart = (appearance === 'light' && !isRtl) || (appearance === 'dark' && isRtl);
    return (
        <header className="border-sidebar-border/50 flex h-16 shrink-0 items-center justify-between gap-2 border-b px-6 transition-[width,height] ease-linear group-has-data-[collapsible=icon]/sidebar-wrapper:h-12 md:px-4">
            <div className="flex w-full items-center justify-between gap-2">
                <SidebarTrigger className="-ml-1" />
                <Breadcrumbs breadcrumbs={breadcrumbs} />
                <div className="flex items-center gap-2">
                    <div className="flex rounded-md border border-sidebar-border bg-sidebar p-0.5">
                        <button
                            type="button"
                            onClick={() => setLanguage('en')}
                            className={`rounded px-2 py-1 text-xs font-medium transition-colors ${language === 'en' ? 'bg-sidebar-accent text-sidebar-accent-foreground' : 'text-muted-foreground hover:text-foreground'}`}
                        >
                            EN
                        </button>
                        <button
                            type="button"
                            onClick={() => setLanguage('ar')}
                            className={`rounded px-2 py-1 text-xs font-medium transition-colors ${language === 'ar' ? 'bg-sidebar-accent text-sidebar-accent-foreground' : 'text-muted-foreground hover:text-foreground'}`}
                        >
                            AR
                        </button>
                    </div>
                    <button
                        onClick={() => updateAppearance(appearance === 'light' ? 'dark' : 'light')}
                        className={`relative flex h-10 w-20 cursor-pointer items-center justify-between rounded-full px-3 ${appearance === 'light' ? 'bg-[#fafafa]' : 'bg-[#171717]'}`}
                    >
                        <Sun size={16} className="relative z-20 text-white dark:text-white/50" />
                        <Moon size={16} className="relative z-20 text-black/50 dark:text-white" />
                        <div
                            className={`absolute top-1 left-1 h-8 w-8 rounded-full bg-blue-800 dark:bg-blue-900 transition-transform duration-500 ${circleOnStart ? 'translate-x-0' : 'translate-x-10'}`}
                        />
                    </button>
                </div>
            </div>
        </header>
    );
}
