import { Card, CardContent, CardHeader, CardTitle } from './card';
import { Link } from '@inertiajs/react';

interface StatCardProps {
    title: string;
    value: React.ReactNode;
    icon: React.ElementType;
    description: React.ReactNode;
    link?: string;
}

export function StatCard({ title, value, icon: Icon, description, link }: StatCardProps) {
    const cardContent = (
        <Card>
            <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                <CardTitle className="text-sm font-medium">{title}</CardTitle>
                <Icon className="h-4 w-4 text-muted-foreground" />
            </CardHeader>
            <CardContent>
                <div className="text-2xl font-bold capitalize">{value}</div>
                <p className="text-xs text-muted-foreground">{description}</p>
            </CardContent>
        </Card>
    );
    return link ? <Link href={link}>{cardContent}</Link> : cardContent;
} 