import { DropdownMenuGroup, DropdownMenuItem, DropdownMenuLabel, DropdownMenuSeparator } from '@/components/ui/dropdown-menu';
import { UserInfo } from '@/components/user-info';
import { useMobileNavigation } from '@/hooks/use-mobile-navigation';
import { useLanguage } from '@/components/language-context';
import { type User } from '@/types';
import { Link, router } from '@inertiajs/react';
import { LogOut, Settings } from 'lucide-react';

interface UserMenuContentProps {
    user: User;
}

export function UserMenuContent({ user }: UserMenuContentProps) {
    const { t } = useLanguage();
    const cleanup = useMobileNavigation();

    return (
        <>
            <DropdownMenuLabel className="p-0 font-normal">
                <div className="flex items-center gap-2 px-1 py-1.5 text-left text-sm">
                    <UserInfo user={user} showEmail={true} />
                </div>
            </DropdownMenuLabel>
            <DropdownMenuSeparator />
            {user.role !== 'vendor' && (
                <DropdownMenuGroup>
                    <DropdownMenuItem asChild>
                        <Link className="block w-full" href={route('profile.edit')} as="button" prefetch onClick={cleanup}>
                            <Settings className="mr-2" />
                            Settings
                        </Link>
                    </DropdownMenuItem>
                </DropdownMenuGroup>
            )}
            <DropdownMenuSeparator />
            <DropdownMenuItem asChild>
                <button
                    className="block w-full text-left"
                    onClick={(e) => {
                        e.preventDefault();
                        cleanup();
                        // Use router.post for proper logout with Inertia
                        router.post(route(user.role === 'vendor' ? 'vendor.logout' : 'logout'), {}, {
                            onSuccess: () => {
                                // Force full page reload to clear all cached data
                                window.location.href = route(user.role === 'vendor' ? 'vendor.login' : 'login');
                            },
                            onError: () => {
                                // Even on error, redirect to login
                                window.location.href = route(user.role === 'vendor' ? 'vendor.login' : 'login');
                            },
                        });
                    }}
                >
                    <LogOut className="mr-2 inline" />
                    {t('common.logout')}
                </button>
            </DropdownMenuItem>
        </>
    );
}
