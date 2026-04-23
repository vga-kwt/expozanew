import { ActionButtonDelete, ActionButtonSuspend } from '@/components/action-button';
import { StatusFilter } from '@/components/ui/StatusFilter';
import { Button } from '@/components/ui/button';
import { Dialog, DialogContent, DialogFooter, DialogHeader, DialogTitle } from '@/components/ui/dialog';
import { Input } from '@/components/ui/input';
import { Pagination as ShadcnPagination } from '@/components/ui/pagination';
import AppLayout from '@/layouts/app-layout';
import { Head, router, usePage } from '@inertiajs/react';
import { useEffect, useRef, useState } from 'react';
import { toast } from 'react-hot-toast';

interface Category {
    id: number;
    name_en: string;
    name_ar: string;
    image: string;
    status: string;
}
interface PaginatedCategories {
    data: Category[];
    links: { url: string | null; label: string; active: boolean }[];
    current_page: number;
    last_page: number;
    total: number;
    per_page: number;
}

function CategoryModal({
    category,
    isOpen,
    onClose,
    onSave,
}: {
    category: Category | null;
    isOpen: boolean;
    onClose: () => void;
    onSave: (data: FormData) => void;
}) {
    const [form, setForm] = useState({ name_en: '', name_ar: '', image: null as File | null, imagePreview: '', isEdit: false });
    const [error, setError] = useState('');
    const fileInputRef = useRef<HTMLInputElement>(null);
    const [loading, setLoading] = useState(false);
    useEffect(() => {
        if (category) {
            setForm({
                name_en: category.name_en || '',
                name_ar: category.name_ar || '',
                image: null,
                imagePreview: category.image_url || '',
                isEdit: true,
            });
        } else {
            setForm({ name_en: '', name_ar: '', image: null, imagePreview: '', isEdit: false });
        }
        setError('');
    }, [category, isOpen]);
    const handleImageChange = (e: React.ChangeEvent<HTMLInputElement>) => {
        const file = e.target.files?.[0];
        if (file) {
            const img = new window.Image();
            img.onload = function () {
                if (img.width < 200 || img.height < 200) {
                    setError('Image resolution must be at least 200x200px');
                    setForm((f) => ({ ...f, image: null, imagePreview: '' }));
                } else {
                    setError('');
                    setForm((f) => ({ ...f, image: file, imagePreview: URL.createObjectURL(file) }));
                }
            };
            img.src = URL.createObjectURL(file);
        }
    };
    const handleSave = () => {
        if (!form.name_en || !form.name_ar || (!form.isEdit && !form.image)) {
            setError('All fields are required');
            return;
        }
        if (error) return;
        setLoading(true); // Start loading
        const data = new FormData();
        data.append('name_en', form.name_en);
        data.append('name_ar', form.name_ar);
        if (form.image) data.append('image', form.image);
        if (form.isEdit) {
            data.append('_method', 'PUT');
            router.post(route('categories.update', category?.id), data, {
                forceFormData: true,
                onSuccess: () => {
                    setLoading(false);
                    onClose();
                },
                onError: () => setLoading(false),
                preserveState: false,
            });
        } else {
            router.post(route('categories.store'), data, {
                forceFormData: true,
                onSuccess: () => {
                    setLoading(false);
                    onClose();
                },
                onError: () => setLoading(false),
                preserveState: false,
            });
        }
    };
    return (
        <Dialog open={isOpen} onOpenChange={onClose}>
            <DialogContent className="max-w-lg">
                <DialogHeader>
                    <DialogTitle>{form.isEdit ? 'Edit Category' : 'Add Category'}</DialogTitle>
                </DialogHeader>
                <div className="space-y-4">
                    <div>
                        <label className="mb-1 block font-medium">Category Name (EN) {!form.isEdit && <span className='text-red-500'>*</span>}</label>
                        <Input placeholder="Name (EN)" value={form.name_en} onChange={(e) => setForm((f) => ({ ...f, name_en: e.target.value }))} />
                    </div>
                    <div>
                        <label className="mb-1 block font-medium">Category Name (AR) {!form.isEdit && <span className='text-red-500'>*</span>}</label>
                        <Input
                            placeholder="Name (AR)"
                            value={form.name_ar}
                            onChange={(e) => setForm((f) => ({ ...f, name_ar: e.target.value }))}
                            dir="rtl"
                        />
                    </div>
                    <div>
                        <label className="mb-1 block font-medium">
                            Category Image {!form.isEdit && <span className='text-red-500'>*</span>}
                            <span className="text-muted-foreground ml-2 text-xs">(Recommended size: 150x150)</span>
                        </label>
                        <Input type="file" accept="image/*" ref={fileInputRef} onChange={handleImageChange} />
                        {form.imagePreview && <img src={form.imagePreview} alt="Preview" className="mt-2 h-16 w-16 rounded object-cover" />}
                    </div>
                    {error && <div className="text-sm text-red-500">{error}</div>}
                </div>
                <DialogFooter>
                    <Button variant="outline" onClick={onClose} disabled={loading}>
                        Cancel
                    </Button>
                    <Button onClick={handleSave} disabled={loading}>
                        {loading ? (
                            <span className="flex items-center gap-2">
                                <span className="loader h-4 w-4 animate-spin rounded-full border-2 border-t-2 border-gray-200 border-t-blue-500" />
                                {form.isEdit ? 'Updating...' : 'Adding...'}
                            </span>
                        ) : form.isEdit ? (
                            'Update'
                        ) : (
                            'Add'
                        )}
                    </Button>
                </DialogFooter>
            </DialogContent>
        </Dialog>
    );
}

function CategoriesPage() {
    const { props } = usePage();
    const categories = props.categories as PaginatedCategories;
    const [modalOpen, setModalOpen] = useState(false);
    const [editCategory, setEditCategory] = useState<Category | null>(null);
    const [suspendDialogOpen, setSuspendDialogOpen] = useState(false);
    const [deleteDialogOpen, setDeleteDialogOpen] = useState(false);
    const [categoryToAct, setCategoryToAct] = useState<Category | null>(null);
    // Add status filter state
    const [status, setStatus] = useState('all');
    // Add name search state
    const [search, setSearch] = useState('');
    // Filter categories by status and name
    const filteredCategories = categories.data.filter((cat) => {
        const statusMatch = status === 'all' || cat.status === status;
        const nameMatch =
            !search || cat.name_en.toLowerCase().includes(search.toLowerCase()) || cat.name_ar.toLowerCase().includes(search.toLowerCase());
        return statusMatch && nameMatch;
    });
    const openAddModal = () => {
        setEditCategory(null);
        setModalOpen(true);
    };
    const openEditModal = (cat: Category) => {
        setEditCategory(cat);
        setModalOpen(true);
    };
    const handleSave = (data: FormData) => {
        if (editCategory) {
            data.append('_method', 'PUT');
            router.post(route('categories.update', editCategory.id), data, {
                forceFormData: true,
                onSuccess: () => setModalOpen(false),
                preserveState: false,
            });
        } else {
            router.post(route('categories.store'), data, {
                forceFormData: true,
                onSuccess: () => setModalOpen(false),
                preserveState: false,
            });
        }
    };
    const handleDelete = (cat: Category) => {
        router.delete(route('categories.destroy', cat.id), { preserveState: false });
    };
    const handleSuspend = (cat: Category) => {
        router.post(route('categories.toggle-status', cat.id), {}, { preserveState: false });
    };
    const { flash } = usePage<{ flash?: { success?: string } }>().props;
    useEffect(() => {
        if (flash?.success) {
            toast.success(flash.success);
        }
    }, [flash?.success]);
    return (
        <div className="p-6">
            <div className="mb-4 flex items-center justify-between">
                <h1 className="text-2xl font-bold">Category Manager</h1>
                <div className="flex items-center gap-2">
                    <Input type="text" placeholder="Search by name..." value={search} onChange={(e) => setSearch(e.target.value)} className="w-64" />
                    <StatusFilter
                        value={status}
                        onChange={setStatus}
                        statusOptions={[
                            { value: 'all', label: 'All Statuses' },
                            { value: 'active', label: 'Active' },
                            { value: 'suspended', label: 'Suspended' },
                        ]}
                        placeholder="Filter by status"
                        className="w-40"
                    />
                    <Button onClick={openAddModal}>Add Category</Button>
                </div>
            </div>
            <div className="overflow-x-auto">
                <table className="min-w-full border bg-white dark:bg-neutral-900">
                    <thead>
                        <tr>
                            <th className="border px-4 py-2">#</th>
                            <th className="border px-4 py-2">Name (EN)</th>
                            <th className="border px-4 py-2">Name (AR)</th>
                            <th className="border px-4 py-2">Image</th>
                            <th className="border px-4 py-2">Status</th>
                            <th className="border px-4 py-2">Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        {filteredCategories.map((cat, idx) => (
                            <tr key={cat.id} className="text-center">
                                <td className="border px-4 py-2 text-center">{idx + 1}</td>
                                <td className="border px-4 py-2 text-center">{cat.name_en}</td>
                                <td className="border px-4 py-2 text-center">{cat.name_ar}</td>
                                <td className="border px-4 py-2 text-center">
                                    {cat.image_url && (
                                        <a href={cat.image_url} target="_blank" rel="noopener noreferrer" title="View full image">
                                            <img
                                                src={cat.image_url}
                                                alt="Category"
                                                className="mx-auto h-16 w-24 rounded object-cover transition-transform hover:scale-105"
                                                onLoad={(e) => {
                                                    const img = e.currentTarget;
                                                    if (img.naturalWidth < 200 || img.naturalHeight < 100) {
                                                        img.style.border = '2px solid red';
                                                        img.title = 'Image resolution too low';
                                                    }
                                                }}
                                            />
                                        </a>
                                    )}
                                </td>
                                <td className="border px-4 py-2 text-center">
                                    <span
                                        className={
                                            'inline-block min-w-[90px] rounded px-2 py-1 text-center text-xs font-semibold text-white ' +
                                            ({
                                                active: 'bg-green-600',
                                                suspended: 'bg-red-600',
                                            }[cat.status] || 'bg-gray-400')
                                        }
                                    >
                                        {cat.status === 'active'
                                            ? 'Active'
                                            : cat.status === 'suspended'
                                              ? 'Suspended'
                                              : cat.status.charAt(0).toUpperCase() + cat.status.slice(1)}
                                    </span>
                                </td>
                                <td className="space-x-2 border px-4 py-2 text-center">
                                    <Button size="sm" variant="outline" onClick={() => openEditModal(cat)}>
                                        Edit
                                    </Button>
                                    <ActionButtonSuspend
                                        variant={cat.status === 'active' ? 'outline' : 'default'}
                                        onClick={() => {
                                            setCategoryToAct(cat);
                                            setSuspendDialogOpen(true);
                                        }}
                                        btnTitle={cat.status === 'active' ? 'Suspend' : 'Activate'}
                                    />
                                    <ActionButtonDelete
                                        btnTitle="Delete"
                                        onClick={() => {
                                            setCategoryToAct(cat);
                                            setDeleteDialogOpen(true);
                                        }}
                                    />
                                </td>
                            </tr>
                        ))}
                    </tbody>
                </table>
            </div>
            {/* Pagination */}
            {categories.last_page > 1 && (
                <div className="mt-6">
                    <ShadcnPagination
                        currentPage={categories.current_page}
                        lastPage={categories.last_page}
                        total={categories.total}
                        perPage={categories.per_page}
                        links={categories.links}
                        onPageChange={(pageNum: number) => {
                            router.get(
                                route('categories.index'),
                                {
                                    page: pageNum,
                                    // add other filters if needed
                                },
                                { preserveState: true, replace: true },
                            );
                        }}
                    />
                </div>
            )}
            <CategoryModal category={editCategory} isOpen={modalOpen} onClose={() => setModalOpen(false)} onSave={handleSave} />
            <Dialog open={suspendDialogOpen} onOpenChange={setSuspendDialogOpen}>
                <DialogContent>
                    <DialogHeader>
                        <DialogTitle>{categoryToAct?.status === 'suspended' ? 'Activate Category' : 'Suspend Category'}</DialogTitle>
                    </DialogHeader>
                    <div>
                        {categoryToAct?.status === 'suspended'
                            ? 'Are you sure you want to activate this category?'
                            : 'Are you sure you want to suspend this category?'}
                    </div>
                    <DialogFooter>
                        <Button variant="outline" onClick={() => setSuspendDialogOpen(false)}>
                            Cancel
                        </Button>
                        <Button
                            variant={categoryToAct?.status === 'suspended' ? 'default' : 'destructive'}
                            onClick={() => {
                                if (categoryToAct) {
                                    handleSuspend(categoryToAct);
                                    setSuspendDialogOpen(false);
                                    setCategoryToAct(null);
                                }
                            }}
                        >
                            {categoryToAct?.status === 'suspended' ? 'Activate' : 'Suspend'}
                        </Button>
                    </DialogFooter>
                </DialogContent>
            </Dialog>
            <Dialog open={deleteDialogOpen} onOpenChange={setDeleteDialogOpen}>
                <DialogContent>
                    <DialogHeader>
                        <DialogTitle>Delete Category</DialogTitle>
                    </DialogHeader>
                    <div>Are you sure you want to delete this category?</div>
                    <DialogFooter>
                        <Button variant="outline" onClick={() => setDeleteDialogOpen(false)}>
                            Cancel
                        </Button>
                        <Button
                            variant="destructive"
                            onClick={() => {
                                if (categoryToAct) {
                                    handleDelete(categoryToAct);
                                    setDeleteDialogOpen(false);
                                    setCategoryToAct(null);
                                }
                            }}
                        >
                            Delete
                        </Button>
                    </DialogFooter>
                </DialogContent>
            </Dialog>
        </div>
    );
}

const CategoriesIndex = () => (
    <AppLayout>
        <Head title="Categories Manager" />
        <CategoriesPage />
    </AppLayout>
);

export default CategoriesIndex;
