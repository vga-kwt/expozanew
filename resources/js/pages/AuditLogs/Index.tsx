import { Head, Link, router } from '@inertiajs/react';
import React, { useState } from 'react';
import { Button } from '../../components/ui/button';
import { Card, CardContent, CardHeader, CardTitle } from '../../components/ui/card';
import { Input } from '../../components/ui/input';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '../../components/ui/select';
import AppLayout from '../../layouts/app-layout';

interface AuditLog {
    id: number;
    admin: { id: number; full_name: string } | null;
    action: string;
    module: string;
    description: string;
    changes: any;
    created_at: string;
}

interface Props {
    logs: {
        data: AuditLog[];
        current_page: number;
        last_page: number;
        per_page: number;
        total: number;
        links: { url: string | null; label: string; active: boolean }[];
    };
    admins: { id: number; full_name: string }[];
    modules: string[];
    actions: string[];
    filters: {
        admin_id?: string;
        action?: string;
        module?: string;
        date_from?: string;
        date_to?: string;
    };
}

export default function AuditLogsIndex({ logs, admins, modules, actions, filters }: Props) {
    const [localFilters, setLocalFilters] = useState({
        admin_id: filters.admin_id || 'all',
        action: filters.action || 'all',
        module: filters.module || 'all',
        date_from: filters.date_from || '',
        date_to: filters.date_to || '',
    });

    const handleFilterChange = (key: string, value: string) => {
        setLocalFilters((prev) => ({ ...prev, [key]: value }));
    };

    const applyFilters = () => {
        const params = { ...localFilters } as Record<string, string>;
        Object.keys(params).forEach((key) => {
            if (params[key] === 'all') delete params[key];
        });
        router.get(route('audit-logs.index'), params, { preserveState: true, preserveScroll: true });
    };

    const exportLogs = () => {
        const params = { ...localFilters } as Record<string, string>;
        Object.keys(params).forEach((key) => {
            if (params[key] === 'all') delete params[key];
        });
        const search = new URLSearchParams(params);
        window.open(`${route('audit-logs.export')}?${search.toString()}`, '_blank');
    };

    return (
        <div className="space-y-6 p-6">
            <Head title="Audit Logs" />
            <div className="flex items-center justify-between">
                <h1 className="text-2xl font-bold">Audit Logs</h1>
                <Button onClick={exportLogs} variant="outline">
                    Export CSV
                </Button>
            </div>

            <Card>
                <CardHeader>
                    <CardTitle>Filter Logs</CardTitle>
                </CardHeader>
                <CardContent>
                    <div className="grid grid-cols-1 gap-4 md:grid-cols-5">
                        <div>
                            <label className="text-sm font-medium">Admin User</label>
                            <Select value={localFilters.admin_id} onValueChange={(v) => handleFilterChange('admin_id', v)}>
                                <SelectTrigger>
                                    <SelectValue placeholder="All Admins" />
                                </SelectTrigger>
                                <SelectContent>
                                    <SelectItem value="all">All</SelectItem>
                                    {admins.map((admin) => (
                                        <SelectItem key={admin.id} value={admin.id.toString()}>
                                            {admin.full_name}
                                        </SelectItem>
                                    ))}
                                </SelectContent>
                            </Select>
                        </div>
                        <div>
                            <label className="text-sm font-medium">Action</label>
                            <Select value={localFilters.action} onValueChange={(v) => handleFilterChange('action', v)}>
                                <SelectTrigger>
                                    <SelectValue placeholder="All Actions" />
                                </SelectTrigger>
                                <SelectContent>
                                    <SelectItem value="all">All</SelectItem>
                                    {actions.map((action) => (
                                        <SelectItem key={action} value={action}>
                                            {action}
                                        </SelectItem>
                                    ))}
                                </SelectContent>
                            </Select>
                        </div>
                        <div>
                            <label className="text-sm font-medium">Module</label>
                            <Select value={localFilters.module} onValueChange={(v) => handleFilterChange('module', v)}>
                                <SelectTrigger>
                                    <SelectValue placeholder="All Modules" />
                                </SelectTrigger>
                                <SelectContent>
                                    <SelectItem value="all">All</SelectItem>
                                    {modules.map((module) => (
                                        <SelectItem key={module} value={module}>
                                            {module}
                                        </SelectItem>
                                    ))}
                                </SelectContent>
                            </Select>
                        </div>
                        <div>
                            <label className="text-sm font-medium">Date From</label>
                            <Input
                                type="date"
                                value={localFilters.date_from}
                                min="2015-01-01"
                                onChange={(e) => handleFilterChange('date_from', e.target.value)}
                            />
                        </div>
                        <div>
                            <label className="text-sm font-medium">Date To</label>
                            <Input
                                type="date"
                                value={localFilters.date_to}
                                min="2015-01-01"
                                onChange={(e) => handleFilterChange('date_to', e.target.value)}
                            />
                        </div>
                    </div>
                    <div className="mt-4 flex justify-end">
                        <Button onClick={applyFilters} className="w-40">
                            Apply Filters
                        </Button>
                    </div>
                </CardContent>
            </Card>

            <Card>
                <CardHeader>
                    <CardTitle>Logs</CardTitle>
                </CardHeader>
                <CardContent>
                    <div className="overflow-x-auto">
                        <table className="min-w-full divide-y divide-gray-200 dark:divide-gray-700">
                            <thead>
                                <tr>
                                    <th className="px-4 py-2">Admin</th>
                                    <th className="px-4 py-2">Action</th>
                                    <th className="px-4 py-2">Module</th>
                                    <th className="px-4 py-2">Description</th>
                                    <th className="px-4 py-2">Timestamp</th>
                                </tr>
                            </thead>
                            <tbody>
                                {logs.data.length === 0 && (
                                    <tr>
                                        <td colSpan={5} className="py-4 text-center text-gray-500">
                                            No logs found.
                                        </td>
                                    </tr>
                                )}
                                {logs.data.map((log) => (
                                    <tr key={log.id} className="text-center hover:bg-gray-50 dark:hover:bg-gray-800">
                                        <td className="px-4 py-2 text-center">{log.admin ? log.admin.full_name : 'N/A'}</td>
                                        <td className="px-4 py-2 text-center">{log.action}</td>
                                        <td className="px-4 py-2 text-center">{log.module}</td>
                                        <td className="max-w-xs truncate px-4 py-2 text-center" title={log.description}>
                                            {log.description}
                                        </td>
                                        <td className="px-4 py-2 text-center text-sm">{new Date(log.created_at).toLocaleString()}</td>
                                    </tr>
                                ))}
                            </tbody>
                        </table>
                    </div>
                    <div className="mt-4 flex justify-center">
                        {logs.links.map((link, i) => (
                            <Button key={i} asChild variant={link.active ? 'default' : 'outline'} disabled={!link.url} className="mx-1">
                                {link.url ? (
                                    <Link href={link.url} preserveScroll preserveState>
                                        {link.label.replace(/&laquo;|&raquo;/g, '')}
                                    </Link>
                                ) : (
                                    <span>{link.label.replace(/&laquo;|&raquo;/g, '')}</span>
                                )}
                            </Button>
                        ))}
                    </div>
                </CardContent>
            </Card>
        </div>
    );
}

AuditLogsIndex.layout = (page: React.ReactNode) => <AppLayout children={page} />;
