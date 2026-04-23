import { Head, router } from '@inertiajs/react';
import { Button } from '@/components/ui/button';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Plus, Pencil, Trash2, CheckCircle2, XCircle } from 'lucide-react';
import { Link } from '@inertiajs/react';
import AppLayout from '@/layouts/app-layout';
import { useState, useEffect } from 'react';
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogTrigger } from '@/components/ui/dialog';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { useForm } from '@inertiajs/react';

interface Permission {
    id: number;
    name: string;
}

interface Role {
    id: number;
    name: string;
    permissions: Permission[];
}

interface Props {
    roles: {
        data: Role[];
        current_page: number;
        last_page: number;
        per_page: number;
        total: number;
        from: number;
        to: number;
    };
    permissions: Permission[];
    flash?: {
        success?: string;
        error?: string;
    };
}

export default function RolesIndex({ roles, permissions, flash }: Props) {
    const [showToast, setShowToast] = useState(false);
    const [toastMessage, setToastMessage] = useState('');
    const [toastType, setToastType] = useState<'success' | 'error'>('success');
    const [isOpen, setIsOpen] = useState(false);
    const [editingRole, setEditingRole] = useState<Role | null>(null);
    const { data, setData, post, put, processing, errors, reset } = useForm({
        name: '',
        permissions: [] as number[],
    });

    useEffect(() => {
        if (flash?.success) {
            setToastMessage(flash.success);
            setToastType('success');
            setShowToast(true);
        } else if (flash?.error) {
            setToastMessage(flash.error);
            setToastType('error');
            setShowToast(true);
        }
    }, [flash]);

    useEffect(() => {
        if (showToast) {
            const timer = setTimeout(() => {
                setShowToast(false);
            }, 3000);
            return () => clearTimeout(timer);
        }
    }, [showToast]);

    const handleDelete = (roleId: number) => {
        if (confirm('Are you sure you want to delete this role?')) {
            router.delete(route('roles.destroy', roleId));
        }
    };

    const openCreateModal = () => {
        setEditingRole(null);
        setData({ name: '', permissions: [] });
        setIsOpen(true);
    };

    const openEditModal = (role: Role) => {
        setEditingRole(role);
        setData({
            name: role.name,
            permissions: role.permissions.map((p) => p.id),
        });
        setIsOpen(true);
    };

    const handleSubmit = (e: React.FormEvent<HTMLFormElement>) => {
        e.preventDefault();
        if (editingRole) {
            put(route('roles.update', editingRole.id), {
                onSuccess: () => {
                    setIsOpen(false);
                    reset();
                    setEditingRole(null);
                },
            });
        } else {
            post(route('roles.store'), {
                onSuccess: () => {
                    setIsOpen(false);
                    reset();
                },
            });
        }
    };

    const handlePermissionChange = (id: number) => {
        setData('permissions', data.permissions.includes(id)
            ? data.permissions.filter((pid) => pid !== id)
            : [...data.permissions, id]);
    };

    return (
        <AppLayout>
            <Head title="Roles" />
            <div className="flex h-full flex-1 flex-col gap-6 rounded-xl p-6 bg-gradient-to-br from-background to-muted/20">
                {showToast && (
                    <div className={`fixed top-4 right-4 z-50 flex items-center gap-2 rounded-lg p-4 shadow-lg ${toastType === 'success' ? 'bg-green-500' : 'bg-red-500'} text-white animate-in fade-in slide-in-from-top-5`}>
                        {toastType === 'success' ? (
                            <CheckCircle2 className="h-5 w-5" />
                        ) : (
                            <XCircle className="h-5 w-5" />
                        )}
                        <span>{toastMessage}</span>
                    </div>)}
                <div className="flex justify-between items-center">
                    <div>
                        <h1 className="text-3xl font-bold tracking-tight">Roles</h1>
                        <p className="text-muted-foreground mt-1">Manage roles and assign permissions</p>
                    </div>
                    <Dialog open={isOpen} onOpenChange={setIsOpen}>
                        <DialogTrigger asChild>
                            <Button className="bg-primary hover:bg-primary/90 shadow-lg" onClick={openCreateModal}>
                                <Plus className="h-4 w-4 mr-2" />
                                New Role
                            </Button>
                        </DialogTrigger>
                        <DialogContent className="sm:max-w-[600px] max-h-[90vh] overflow-y-auto">
                            <DialogHeader>
                                <DialogTitle className="text-xl">{editingRole ? 'Edit Role' : 'Create New Role'}</DialogTitle>
                            </DialogHeader>
                            <form onSubmit={handleSubmit} className="space-y-6 mt-4">
                                <div>
                                    <Label htmlFor="name">Role Name</Label>
                                    <Input
                                        id="name"
                                        value={data.name}
                                        onChange={e => setData('name', e.target.value)}
                                        className="mt-1"
                                        required
                                    />
                                    {errors.name && <div className="text-red-500 text-xs mt-1">{errors.name}</div>}
                                </div>
                                <div>
                                    <Label>Permissions</Label>
                                    <div className="flex flex-wrap gap-4 mt-4">
                                        {permissions.map((perm) => (
                                            <label key={perm.id} className="flex items-center gap-2 bg-gray-100 rounded-lg px-3 py-2 shadow-sm border border-gray-200">
                                                <input
                                                    type="checkbox"
                                                    checked={data.permissions.includes(perm.id)}
                                                    onChange={() => handlePermissionChange(perm.id)}
                                                />
                                                <span className="font-medium text-sm text-gray-700">{perm.name}</span>
                                            </label>
                                        ))}
                                    </div>
                                    {errors.permissions && <div className="text-red-500 text-xs mt-1">{errors.permissions}</div>}
                                </div>
                                <Button type="submit" disabled={processing} className="w-full">{editingRole ? 'Update Role' : 'Create Role'}</Button>
                            </form>
                        </DialogContent>
                    </Dialog>
                </div>
                <Card>
                    <CardHeader>
                        <CardTitle>Roles List</CardTitle>
                    </CardHeader>
                    <CardContent>
                        <div className="overflow-x-auto">
                            <table className="min-w-full divide-y divide-gray-200">
                                <thead>
                                    <tr>
                                        <th className="px-6 py-3 text-left text-xs font-medium uppercase tracking-wider">Name</th>
                                        <th className="px-6 py-3 text-left text-xs font-medium uppercase tracking-wider">Permissions</th>
                                        <th className="px-6 py-3">Action</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    {roles.data.map((role) => (
                                        <tr key={role.id}>
                                            <td className="px-6 py-4 whitespace-nowrap font-medium">{role.name}</td>
                                            <td className="px-6 py-4 whitespace-nowrap">
                                                {role.permissions.length > 0 ? (
                                                    <ul className="flex flex-wrap gap-2">
                                                        {role.permissions.map((perm) => (
                                                            <li key={perm.id} className="bg-gray-200 text-black rounded px-2 py-1 text-xs">{perm.name}</li>
                                                        ))}
                                                    </ul>
                                                ) : (
                                                    <span className="text-gray-400 text-xs">No permissions</span>
                                                )}
                                            </td>
                                            <td className="px-6 py-4 whitespace-nowrap flex gap-2">
                                                <Button size="sm" variant="outline" onClick={() => openEditModal(role)}>
                                                    <Pencil className="h-4 w-4" />
                                                </Button>
                                                <Button size="sm" variant="destructive" onClick={() => handleDelete(role.id)}>
                                                    <Trash2 className="h-4 w-4" />
                                                </Button>
                                            </td>
                                        </tr>
                                    ))}
                                </tbody>
                            </table>
                        </div>
                    </CardContent>
                </Card>
            </div>
        </AppLayout>
    );
} 