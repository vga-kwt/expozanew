import { type BreadcrumbItem } from '@/types';
import { Head, useForm, router } from '@inertiajs/react';
import { useState } from 'react';
import { Plus, Pencil, Trash2 } from 'lucide-react';
import toast from 'react-hot-toast';

import HeadingSmall from '@/components/heading-small';
import InputError from '@/components/input-error';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Textarea } from '@/components/ui/textarea';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Badge } from '@/components/ui/badge';
import {
    Dialog,
    DialogContent,
    DialogDescription,
    DialogFooter,
    DialogHeader,
    DialogTitle,
} from '@/components/ui/dialog';
import {
    AlertDialog,
    AlertDialogAction,
    AlertDialogCancel,
    AlertDialogContent,
    AlertDialogDescription,
    AlertDialogFooter,
    AlertDialogHeader,
    AlertDialogTitle,
} from '@/components/ui/alert-dialog';
import AppLayout from '@/layouts/app-layout';
import SettingsLayout from '@/layouts/settings/layout';

const breadcrumbs: BreadcrumbItem[] = [
    {
        title: 'FAQ Management',
        href: '/settings/faq',
    },
];

interface Faq {
    id: number;
    question_en: string;
    question_ar: string;
    answer_en: string;
    answer_ar: string;
    status: 'active' | 'inactive';
    sort_order: number;
}

interface FaqPageProps {
    faqs: Faq[];
}

export default function FaqPage({ faqs }: FaqPageProps) {
    const [isModalOpen, setIsModalOpen] = useState(false);
    const [editingFaq, setEditingFaq] = useState<Faq | null>(null);
    const [deleteDialogOpen, setDeleteDialogOpen] = useState(false);
    const [faqToDelete, setFaqToDelete] = useState<Faq | null>(null);
    const [expandedFaqs, setExpandedFaqs] = useState<number[]>([]);

    const { data, setData, post, put, processing, errors, reset } = useForm({
        question_en: '',
        question_ar: '',
        answer_en: '',
        answer_ar: '',
        status: 'active' as 'active' | 'inactive',
        sort_order: 0,
    });

    const openCreateModal = () => {
        setEditingFaq(null);
        reset();
        setIsModalOpen(true);
    };

    const openEditModal = (faq: Faq) => {
        setEditingFaq(faq);
        setData({
            question_en: faq.question_en,
            question_ar: faq.question_ar,
            answer_en: faq.answer_en,
            answer_ar: faq.answer_ar,
            status: faq.status,
            sort_order: faq.sort_order,
        });
        setIsModalOpen(true);
    };

    const closeModal = () => {
        setIsModalOpen(false);
        setEditingFaq(null);
        reset();
    };

    const handleSubmit = (e: React.FormEvent) => {
        e.preventDefault();

        if (editingFaq) {
            put(route('settings.faq.update', editingFaq.id), {
                onSuccess: () => {
                    closeModal();
                    toast.success('FAQ updated successfully!');
                },
                onError: () => {
                    toast.error('Failed to update FAQ.');
                },
            });
        } else {
            post(route('settings.faq.store'), {
                onSuccess: () => {
                    closeModal();
                    toast.success('FAQ created successfully!');
                },
                onError: () => {
                    toast.error('Failed to create FAQ.');
                },
            });
        }
    };

    const handleDelete = () => {
        if (!faqToDelete) return;

        router.delete(route('settings.faq.destroy', faqToDelete.id), {
            onSuccess: () => {
                setDeleteDialogOpen(false);
                setFaqToDelete(null);
                toast.success('FAQ deleted successfully!');
            },
            onError: () => {
                toast.error('Failed to delete FAQ.');
            },
        });
    };

    const toggleExpand = (id: number) => {
        setExpandedFaqs(prev =>
            prev.includes(id) ? prev.filter(faqId => faqId !== id) : [...prev, id]
        );
    };

    return (
        <AppLayout breadcrumbs={breadcrumbs}>
            <Head title="FAQ Management" />

            <SettingsLayout>
                <div className="space-y-6">
                    <div className="flex items-center justify-between">
                        <HeadingSmall
                            title="FAQ Management"
                            description="Manage frequently asked questions in English and Arabic"
                        />
                        <Button onClick={openCreateModal} size="sm">
                            <Plus className="h-4 w-4 mr-2" />
                            Add FAQ
                        </Button>
                    </div>

                    {/* FAQ List */}
                    <div className="space-y-4">
                        {faqs.length === 0 ? (
                            <Card>
                                <CardContent className="py-12 text-center text-muted-foreground">
                                    No FAQs found. Click "Add FAQ" to create one.
                                </CardContent>
                            </Card>
                        ) : (
                            faqs.map((faq, index) => (
                                <Card key={faq.id} className="overflow-hidden">
                                    <CardHeader className="pb-3">
                                        <div className="flex items-start justify-between gap-4">
                                            <div className="flex items-center gap-3 flex-1">
                                                <div className="flex-1">
                                                    <div className="flex items-center gap-2 mb-1">
                                                        <Badge variant={faq.status === 'active' ? 'default' : 'secondary'}>
                                                            {faq.status}
                                                        </Badge>
                                                        <span className="text-xs text-muted-foreground">
                                                            #{index + 1}
                                                        </span>
                                                    </div>
                                                    <button
                                                        onClick={() => toggleExpand(faq.id)}
                                                        className="text-left w-full cursor-pointer hover:text-primary transition-colors"
                                                    >
                                                        <CardTitle className="text-base font-medium flex items-center gap-2">
                                                            <span className="text-muted-foreground">
                                                                {expandedFaqs.includes(faq.id) ? '▼' : '▶'}
                                                            </span>
                                                            <span>{faq.question_en}</span>
                                                        </CardTitle>
                                                    </button>
                                                </div>
                                            </div>
                                            <div className="flex items-center gap-2">
                                                <Button
                                                    variant="outline"
                                                    size="icon"
                                                    onClick={() => openEditModal(faq)}
                                                >
                                                    <Pencil className="h-4 w-4" />
                                                </Button>
                                                <Button
                                                    variant="destructive"
                                                    size="icon"
                                                    onClick={() => {
                                                        setFaqToDelete(faq);
                                                        setDeleteDialogOpen(true);
                                                    }}
                                                >
                                                    <Trash2 className="h-4 w-4" />
                                                </Button>
                                            </div>
                                        </div>
                                    </CardHeader>

                                    {expandedFaqs.includes(faq.id) && (
                                        <CardContent className="pt-0">
                                            <div className="grid grid-cols-1 md:grid-cols-2 gap-6 mt-4">
                                                {/* English */}
                                                <div className="space-y-3 p-4 bg-blue-50 dark:bg-blue-950/30 rounded-lg border border-blue-200 dark:border-blue-800">
                                                    <div className="flex items-center gap-2">
                                                        <Badge variant="outline" className="bg-blue-100 text-blue-700 dark:bg-blue-900 dark:text-blue-300">
                                                            English
                                                        </Badge>
                                                    </div>
                                                    <div>
                                                        <p className="text-sm font-medium text-muted-foreground mb-1">Question:</p>
                                                        <p className="font-medium">{faq.question_en}</p>
                                                    </div>
                                                    <div>
                                                        <p className="text-sm font-medium text-muted-foreground mb-1">Answer:</p>
                                                        <p className="text-sm whitespace-pre-wrap">{faq.answer_en}</p>
                                                    </div>
                                                </div>

                                                {/* Arabic */}
                                                <div className="space-y-3 p-4 bg-green-50 dark:bg-green-950/30 rounded-lg border border-green-200 dark:border-green-800" dir="rtl">
                                                    <div className="flex items-center gap-2">
                                                        <Badge variant="outline" className="bg-green-100 text-green-700 dark:bg-green-900 dark:text-green-300">
                                                            العربية
                                                        </Badge>
                                                    </div>
                                                    <div>
                                                        <p className="text-sm font-medium text-muted-foreground mb-1">السؤال:</p>
                                                        <p className="font-medium">{faq.question_ar}</p>
                                                    </div>
                                                    <div>
                                                        <p className="text-sm font-medium text-muted-foreground mb-1">الإجابة:</p>
                                                        <p className="text-sm whitespace-pre-wrap">{faq.answer_ar}</p>
                                                    </div>
                                                </div>
                                            </div>
                                        </CardContent>
                                    )}
                                </Card>
                            ))
                        )}
                    </div>
                </div>

                {/* Create/Edit Modal */}
                <Dialog open={isModalOpen} onOpenChange={setIsModalOpen}>
                    <DialogContent className="sm:max-w-[900px] max-h-[90vh] overflow-y-auto">
                        <DialogHeader>
                            <DialogTitle>
                                {editingFaq ? 'Edit FAQ' : 'Create New FAQ'}
                            </DialogTitle>
                            <DialogDescription>
                                Enter the question and answer in both English and Arabic.
                            </DialogDescription>
                        </DialogHeader>

                        <form onSubmit={handleSubmit} className="space-y-6">
                            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                                {/* English Column */}
                                <div className="space-y-4 p-4 bg-blue-50 dark:bg-blue-950/30 rounded-lg border border-blue-200 dark:border-blue-800">
                                    <div className="flex items-center gap-2 mb-2">
                                        <Badge variant="outline" className="bg-blue-100 text-blue-700 dark:bg-blue-900 dark:text-blue-300">
                                            English
                                        </Badge>
                                    </div>

                                    <div className="space-y-2">
                                        <Label htmlFor="question_en">Question (EN) *</Label>
                                        <Input
                                            id="question_en"
                                            value={data.question_en}
                                            onChange={(e) => setData('question_en', e.target.value)}
                                            placeholder="Enter question in English"
                                        />
                                        <InputError message={errors.question_en} />
                                    </div>

                                    <div className="space-y-2">
                                        <Label htmlFor="answer_en">Answer (EN) *</Label>
                                        <Textarea
                                            id="answer_en"
                                            value={data.answer_en}
                                            onChange={(e) => setData('answer_en', e.target.value)}
                                            placeholder="Enter answer in English"
                                            rows={5}
                                        />
                                        <InputError message={errors.answer_en} />
                                    </div>
                                </div>

                                {/* Arabic Column */}
                                <div className="space-y-4 p-4 bg-green-50 dark:bg-green-950/30 rounded-lg border border-green-200 dark:border-green-800" dir="rtl">
                                    <div className="flex items-center gap-2 mb-2">
                                        <Badge variant="outline" className="bg-green-100 text-green-700 dark:bg-green-900 dark:text-green-300">
                                            العربية
                                        </Badge>
                                    </div>

                                    <div className="space-y-2">
                                        <Label htmlFor="question_ar">السؤال (AR) *</Label>
                                        <Input
                                            id="question_ar"
                                            value={data.question_ar}
                                            onChange={(e) => setData('question_ar', e.target.value)}
                                            placeholder="أدخل السؤال بالعربية"
                                            dir="rtl"
                                        />
                                        <InputError message={errors.question_ar} />
                                    </div>

                                    <div className="space-y-2">
                                        <Label htmlFor="answer_ar">الإجابة (AR) *</Label>
                                        <Textarea
                                            id="answer_ar"
                                            value={data.answer_ar}
                                            onChange={(e) => setData('answer_ar', e.target.value)}
                                            placeholder="أدخل الإجابة بالعربية"
                                            rows={5}
                                            dir="rtl"
                                        />
                                        <InputError message={errors.answer_ar} />
                                    </div>
                                </div>
                            </div>

                            {/* Status and Sort Order */}
                            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                                <div className="space-y-2">
                                    <Label htmlFor="status">Status</Label>
                                    <Select
                                        value={data.status}
                                        onValueChange={(value: 'active' | 'inactive') => setData('status', value)}
                                    >
                                        <SelectTrigger>
                                            <SelectValue placeholder="Select status" />
                                        </SelectTrigger>
                                        <SelectContent>
                                            <SelectItem value="active">Active</SelectItem>
                                            <SelectItem value="inactive">Inactive</SelectItem>
                                        </SelectContent>
                                    </Select>
                                    <InputError message={errors.status} />
                                </div>

                                <div className="space-y-2">
                                    <Label htmlFor="sort_order">Sort Order</Label>
                                    <Input
                                        id="sort_order"
                                        type="number"
                                        min={0}
                                        value={data.sort_order}
                                        onChange={(e) => setData('sort_order', parseInt(e.target.value) || 0)}
                                        placeholder="0"
                                    />
                                    <InputError message={errors.sort_order} />
                                </div>
                            </div>

                            <DialogFooter>
                                <Button type="button" variant="outline" onClick={closeModal}>
                                    Cancel
                                </Button>
                                <Button type="submit" disabled={processing}>
                                    {processing ? 'Saving...' : editingFaq ? 'Update FAQ' : 'Create FAQ'}
                                </Button>
                            </DialogFooter>
                        </form>
                    </DialogContent>
                </Dialog>

                {/* Delete Confirmation Dialog */}
                <AlertDialog open={deleteDialogOpen} onOpenChange={setDeleteDialogOpen}>
                    <AlertDialogContent>
                        <AlertDialogHeader>
                            <AlertDialogTitle>Are you sure?</AlertDialogTitle>
                            <AlertDialogDescription>
                                This will permanently delete this FAQ. This action cannot be undone.
                            </AlertDialogDescription>
                        </AlertDialogHeader>
                        <AlertDialogFooter>
                            <AlertDialogCancel>Cancel</AlertDialogCancel>
                            <AlertDialogAction onClick={handleDelete} className="bg-destructive text-destructive-foreground hover:bg-destructive/90">
                                Delete
                            </AlertDialogAction>
                        </AlertDialogFooter>
                    </AlertDialogContent>
                </AlertDialog>
            </SettingsLayout>
        </AppLayout>
    );
}

