import { useLanguage } from '@/components/language-context';
import { Link } from '@inertiajs/react';
import { type PropsWithChildren } from 'react';

interface AuthLayoutProps {
    name?: string;
    title?: string;
    description?: string;
}

export default function AuthSimpleLayout({ children, title, description }: PropsWithChildren<AuthLayoutProps>) {
    const { language, setLanguage } = useLanguage();
    return (
        <div className="bg-background flex min-h-svh flex-col items-center justify-center gap-6 p-6 md:p-10">
            <div className="absolute top-4 right-4 flex rounded-md border border-sidebar-border bg-sidebar p-0.5">
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
            <div className="w-full max-w-sm">
                <div className="flex flex-col gap-8">
                    <div className="flex flex-col items-center gap-4">
                        <Link href={route('dashboard')} className="flex flex-col items-center gap-2 font-medium">
                            <div className="mb-1 flex h-9 w-9 items-center justify-center rounded-md">
                                <img src={`${window.location.origin}/Group.svg`} alt="logo" />
                            </div>
                            <span className="sr-only">{title}</span>
                        </Link>

                        <div className="space-y-2 text-center">
                            <h1 className="text-xl font-medium">{title}</h1>
                            <p className="text-muted-foreground text-center text-sm">{description}</p>
                        </div>
                    </div>
                    {children}
                </div>
            </div>
        </div>
    );
}
