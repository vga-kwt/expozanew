import { Button } from '@/components/ui/button';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogTrigger } from '@/components/ui/dialog';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import AppLayout from '@/layouts/app-layout';
import { Head, router, useForm } from '@inertiajs/react';
import { CheckCircle2, List, Pencil, Plus, Search, Trash2, XCircle } from 'lucide-react';
import { useEffect, useState } from 'react';

interface Permission {
    id: number;
    name: string;
    created_at: string;
}

interface Props {
    permissions: {
        data: Permission[];
        current_page: number;
        last_page: number;
        per_page: number;
        total: number;
        from: number;
        to: number;
        links: {
            url: string | null;
            label: string;
            active: boolean;
        }[];
    };
    filters: {
        search: string;
    };
    flash?: {
        success?: string;
        error?: string;
    };
}

export default function PermissionsIndex({ permissions, flash, filters }: Props) {
    const [open, setOpen] = useState(false);
    const [editId, setEditId] = useState<number | null>(null);
    const [showToast, setShowToast] = useState(false);
    const [toastType, setToastType] = useState<'success' | 'error'>('success');
    const [toastMessage, setToastMessage] = useState('');
    const { data, setData, post, put, processing, errors, reset } = useForm({
        name: '',
    });
    const [search, setSearch] = useState(filters.search || '');

    useEffect(() => {
        if (flash?.success) {
            setToastType('success');
            setToastMessage(flash.success);
            setShowToast(true);
        } else if (flash?.error) {
            setToastType('error');
            setToastMessage(flash.error);
            setShowToast(true);
        }
    }, [flash]);

    useEffect(() => {
        if (showToast) {
            const timer = setTimeout(() => setShowToast(false), 3000);
            return () => clearTimeout(timer);
        }
    }, [showToast]);

    const handleSearch = () => {
        router.get(
            route('permissions.index'),
            { search },
            {
                preserveState: true,
                replace: true,
            },
        );
    };

    const handleOpenCreate = () => {
        setEditId(null);
        setData({ name: '' });
        setOpen(true);
    };

    const handleOpenEdit = (permission: Permission) => {
        setEditId(permission.id);
        setData({ name: permission.name });
        setOpen(true);
    };

    const handleClose = () => {
        setOpen(false);
        setEditId(null);
        reset();
    };

    const handleSubmit = (e: React.FormEvent<HTMLFormElement>) => {
        e.preventDefault();
        if (editId) {
            put(route('permissions.update', editId), {
                onSuccess: handleClose,
            });
        } else {
            post(route('permissions.store'), {
                onSuccess: handleClose,
            });
        }
    };

    const handleDelete = (id: number) => {
        if (confirm('Are you sure you want to delete this permission?')) {
            router.delete(route('permissions.destroy', id));
        }
    };

    const handlePageChange = (url: string | null) => {
        if (url) {
            router.get(url, {}, { preserveState: true, preserveScroll: true });
        }
    };

    return (
        <AppLayout>
            <Head title="Permissions" />
            <div className="from-background to-muted/20 flex h-full flex-1 flex-col gap-6 rounded-xl bg-gradient-to-br p-6">
                {showToast && (
                    <div
                        className={`fixed top-4 right-4 z-50 flex items-center gap-2 rounded-lg p-4 shadow-lg ${toastType === 'success' ? 'bg-green-500' : 'bg-red-500'} animate-in fade-in slide-in-from-top-5 text-white`}
                    >
                        {toastType === 'success' ? <CheckCircle2 className="h-5 w-5" /> : <XCircle className="h-5 w-5" />}
                        <span>{toastMessage}</span>
                    </div>
                )}
                <div className="flex items-center justify-between">
                    <div>
                        <h1 className="flex items-center gap-2 text-3xl font-bold tracking-tight">
                            <List className="h-7 w-7" />
                            Permissions
                        </h1>
                        <p className="text-muted-foreground mt-1">Manage permissions</p>
                    </div>
                    <Dialog open={open} onOpenChange={setOpen}>
                        <DialogTrigger asChild>
                            <Button className="bg-primary hover:bg-primary/90 shadow-lg" onClick={handleOpenCreate}>
                                <Plus className="mr-2 h-4 w-4" />
                                New Permission
                            </Button>
                        </DialogTrigger>
                        <DialogContent className="max-h-[90vh] overflow-y-auto sm:max-w-[500px]">
                            <DialogHeader>
                                <DialogTitle className="text-xl">{editId ? 'Edit Permission' : 'Create New Permission'}</DialogTitle>
                            </DialogHeader>
                            <form onSubmit={handleSubmit} className="mt-4 space-y-6">
                                <div>
                                    <Label htmlFor="name">Permission Name</Label>
                                    <Input id="name" value={data.name} onChange={(e) => setData('name', e.target.value)} className="mt-1" required />
                                    {errors.name && <div className="mt-1 text-xs text-red-500">{errors.name}</div>}
                                </div>
                                <Button type="submit" disabled={processing} className="w-full">
                                    {editId ? 'Update Permission' : 'Create Permission'}
                                </Button>
                            </form>
                        </DialogContent>
                    </Dialog>
                </div>
                <Card>
                    <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-4">
                        <CardTitle>Permissions List</CardTitle>
                        <div className="relative">
                            <Search className="text-muted-foreground absolute top-2.5 left-2.5 h-4 w-4" />
                            <Input
                                placeholder="Search by name..."
                                value={search}
                                onChange={(e) => setSearch(e.target.value)}
                                onKeyDown={(e) => {
                                    if (e.key === 'Enter') handleSearch();
                                }}
                                className="bg-background w-full rounded-lg pl-8 md:w-[200px] lg:w-[336px]"
                            />
                        </div>
                    </CardHeader>
                    <CardContent>
                        <div className="overflow-x-auto">
                            <table className="min-w-full divide-y divide-gray-200">
                                <thead>
                                    <tr>
                                        <th className="px-6 py-3 text-left text-xs font-medium tracking-wider uppercase">Name</th>
                                        <th className="px-6 py-3 text-left text-xs font-medium tracking-wider uppercase">Created At</th>
                                        <th className="px-6 py-3 text-left text-xs font-medium tracking-wider uppercase">Action</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    {permissions.data.length === 0 ? (
                                        <tr>
                                            <td colSpan={3} className="px-6 py-4 text-center">
                                                No permissions found.
                                            </td>
                                        </tr>
                                    ) : (
                                        permissions.data.map((permission) => (
                                            <tr key={permission.id}>
                                                <td className="px-6 py-4 font-medium whitespace-nowrap">{permission.name}</td>
                                                <td className="px-6 py-4 whitespace-nowrap">
                                                    {permission.created_at ? new Date(permission.created_at).toLocaleString() : '-'}
                                                </td>
                                                <td className="flex gap-2 px-6 py-4 whitespace-nowrap">
                                                    <Button size="sm" variant="outline" onClick={() => handleOpenEdit(permission)}>
                                                        <Pencil className="h-4 w-4" />
                                                    </Button>
                                                    <Button size="sm" variant="destructive" onClick={() => handleDelete(permission.id)}>
                                                        <Trash2 className="h-4 w-4" />
                                                    </Button>
                                                </td>
                                            </tr>
                                        ))
                                    )}
                                </tbody>
                            </table>
                        </div>
                    </CardContent>
                </Card>
                <div className="flex items-center justify-between">
                    <div className="text-muted-foreground text-sm">
                        Showing {permissions.from} to {permissions.to} of {permissions.total} results
                    </div>
                    {permissions.links.length > 3 && (
                        <div className="flex items-center gap-1">
                            {permissions.links.map((link, index) => (
                                <Button
                                    key={index}
                                    onClick={() => handlePageChange(link.url)}
                                    disabled={!link.url || link.active}
                                    size="sm"
                                    variant={link.active ? 'default' : 'outline'}
                                >
                                    <span dangerouslySetInnerHTML={{ __html: link.label }} />
                                </Button>
                            ))}
                        </div>
                    )}
                </div>
            </div>
        </AppLayout>
    );
}
