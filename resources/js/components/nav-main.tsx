import {
    SidebarGroup,
    SidebarGroupLabel,
    SidebarMenu,
    SidebarMenuButton,
    SidebarMenuItem,
    SidebarMenuSub,
    SidebarMenuSubButton,
    SidebarMenuSubItem,
} from '@/components/ui/sidebar';
import { Collapsible, CollapsibleContent, CollapsibleTrigger } from '@/components/ui/collapsible';
import { useLanguage } from '@/components/language-context';
import { type NavItem } from '@/types';
import { Link, usePage } from '@inertiajs/react';
import { ChevronRight } from 'lucide-react';

function getTitle(item: NavItem, t: (key: string) => string): string {
    return item.titleKey ? t(item.titleKey) : item.title;
}

export function NavMain({ items = [] }: { items: NavItem[] }) {
    const page = usePage();
    const { t } = useLanguage();

    const isActive = (href?: string) => {
        if (!href || href === '#') return false;
        const currentPath = page.url.split('?')[0];
        const itemPath = href.split('?')[0];
        return currentPath === itemPath || (itemPath !== '/' && currentPath.startsWith(itemPath));
    };

    const isChildActive = (item: NavItem) =>
        item.children?.some((child) => isActive(child.href)) ?? false;

    return (
        <SidebarGroup className="px-2 py-0">
            <SidebarGroupLabel>{t('sidebar.platform')}</SidebarGroupLabel>
            <SidebarMenu>
                {items.map((item) =>
                    item.children?.length ? (
                        <SidebarMenuItem key={item.title}>
                            <Collapsible defaultOpen={isChildActive(item)} className="group/collapsible">
                                <CollapsibleTrigger asChild>
                                    <SidebarMenuButton
                                        isActive={isChildActive(item)}
                                        tooltip={{ children: getTitle(item, t) }}
                                    >
                                        {item.icon && <item.icon />}
                                        <span>{getTitle(item, t)}</span>
                                        <ChevronRight className="ml-auto size-4 transition-transform group-data-[state=open]/collapsible:rotate-90" />
                                    </SidebarMenuButton>
                                </CollapsibleTrigger>
                                <CollapsibleContent>
                                    <SidebarMenuSub>
                                        {item.children.map((child) => (
                                            <SidebarMenuSubItem key={child.title}>
                                                <SidebarMenuSubButton
                                                    asChild
                                                    isActive={isActive(child.href)}
                                                >
                                                    <Link href={child.href} prefetch>
                                                        {child.icon && <child.icon />}
                                                        <span>{getTitle(child, t)}</span>
                                                    </Link>
                                                </SidebarMenuSubButton>
                                            </SidebarMenuSubItem>
                                        ))}
                                    </SidebarMenuSub>
                                </CollapsibleContent>
                            </Collapsible>
                        </SidebarMenuItem>
                    ) : (
                        <SidebarMenuItem key={item.title}>
                            <SidebarMenuButton
                                asChild
                                isActive={isActive(item.href)}
                                tooltip={{ children: getTitle(item, t) }}
                            >
                                <Link href={item.href} prefetch>
                                    {item.icon && <item.icon />}
                                    <span>{getTitle(item, t)}</span>
                                </Link>
                            </SidebarMenuButton>
                        </SidebarMenuItem>
                    )
                )}
            </SidebarMenu>
        </SidebarGroup>
    );
}
