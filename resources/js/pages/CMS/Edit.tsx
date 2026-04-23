import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select';
import AppLayout from '@/layouts/app-layout';
import { Head, router, useForm } from '@inertiajs/react';
import { toast } from 'react-hot-toast';
import ReactQuill from 'react-quill';
import 'react-quill/dist/quill.snow.css';

interface Cms {
    id: number;
    title_en: string;
    title_ar: string;
    content_en: string;
    content_ar: string;
    slug: string;
    meta_title?: string;
    meta_description?: string;
    meta_keywords?: string;
    status: string;
}

interface EditCmsProps {
    page: Cms;
}

const EditCms = ({ page }: EditCmsProps) => {
    const { data, setData, put, processing, errors } = useForm({
        title_en: page.title_en || '',
        title_ar: page.title_ar || '',
        content_en: page.content_en || '',
        content_ar: page.content_ar || '',
        slug: page.slug || '',
        meta_title: page.meta_title || '',
        meta_description: page.meta_description || '',
        meta_keywords: page.meta_keywords || '',
        status: page.status || 'draft',
    });

    const onSubmit = (e: React.FormEvent) => {
        e.preventDefault();
        put(route('cms-pages.update', page.id), {
            onSuccess: () => {
                toast.success('Page updated successfully!');
                router.visit(route('cms-pages.index'));
            },
            onError: () => toast.error('Failed to update page.'),
        });
    };

    const handleStatusChange = (value: string) => {
        setData({ ...data, status: value as Cms['status'] });
    };

    return (
        <AppLayout>
            <Head title="Edit CMS Page" />
            <div className="p-8">
                <h1 className="mb-6 border-b pb-4 text-3xl font-bold">Edit Page: {page.title_en}</h1>
                <div className="min-h-[80vh]">
                    <form onSubmit={onSubmit} className="space-y-6">
                        <div className="grid grid-cols-1 gap-4 md:grid-cols-2">
                            <div>
                                <Label htmlFor="title_en">Title (EN)</Label>
                                <Input id="title_en" name="title_en" value={data.title_en} onChange={(e) => setData('title_en', e.target.value)} />
                                {errors.title_en && <div className="mt-1 text-xs text-red-500">{errors.title_en}</div>}
                            </div>
                            <div>
                                <Label htmlFor="title_ar">Title (AR)</Label>
                                <Input
                                    id="title_ar"
                                    name="title_ar"
                                    value={data.title_ar}
                                    onChange={(e) => setData('title_ar', e.target.value)}
                                    dir="rtl"
                                />
                                {errors.title_ar && <div className="mt-1 text-xs text-red-500">{errors.title_ar}</div>}
                            </div>
                        </div>
                        <div className="grid grid-cols-1 gap-4 md:grid-cols-2">
                            <div className="h-72">
                                <Label htmlFor="content_en">Description (EN)</Label>
                                <ReactQuill
                                    value={data.content_en}
                                    onChange={(value) => setData('content_en', value)}
                                    theme="snow"
                                    className="h-56"
                                />
                                {errors.content_en && <div className="mt-1 text-xs text-red-500">{errors.content_en}</div>}
                            </div>
                            <div className="h-72">
                                <Label htmlFor="content_ar">Description (AR)</Label>
                                <ReactQuill
                                    value={data.content_ar}
                                    onChange={(value) => setData('content_ar', value)}
                                    theme="snow"
                                    className="h-56"
                                />
                                {errors.content_ar && <div className="mt-1 text-xs text-red-500">{errors.content_ar}</div>}
                            </div>
                        </div>
                        <div>
                            <Label htmlFor="slug">Slug</Label>
                            <Input
                                id="slug"
                                name="slug"
                                value={data.slug}
                                onChange={(e) => setData('slug', e.target.value)}
                                required
                                placeholder="page-url-slug"
                            />
                            {errors.slug && <div className="text-sm text-red-500">{errors.slug}</div>}
                        </div>

                        {/* Meta Fields */}
                        <div className="grid grid-cols-1 gap-4 md:grid-cols-2">
                            <div>
                                <Label htmlFor="meta_title">Meta Title</Label>
                                <Input
                                    id="meta_title"
                                    name="meta_title"
                                    value={data.meta_title}
                                    onChange={(e) => setData('meta_title', e.target.value)}
                                    placeholder="SEO meta title"
                                />
                                {errors.meta_title && <div className="mt-1 text-xs text-red-500">{errors.meta_title}</div>}
                            </div>
                            <div>
                                <Label htmlFor="meta_keywords">Meta Keywords</Label>
                                <Input
                                    id="meta_keywords"
                                    name="meta_keywords"
                                    value={data.meta_keywords}
                                    onChange={(e) => setData('meta_keywords', e.target.value)}
                                    placeholder="SEO keywords (comma separated)"
                                />
                                {errors.meta_keywords && <div className="mt-1 text-xs text-red-500">{errors.meta_keywords}</div>}
                            </div>
                        </div>

                        <div>
                            <Label htmlFor="meta_description">Meta Description</Label>
                            <textarea
                                id="meta_description"
                                name="meta_description"
                                value={data.meta_description}
                                onChange={(e) => setData('meta_description', e.target.value)}
                                placeholder="SEO meta description (max 500 characters)"
                                className="w-full rounded-md border border-input bg-background px-3 py-2 text-sm ring-offset-background placeholder:text-muted-foreground focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:cursor-not-allowed disabled:opacity-50"
                                rows={3}
                                maxLength={500}
                            />
                            <div className="mt-1 text-xs text-gray-500">
                                {data.meta_description?.length || 0}/500 characters
                            </div>
                            {errors.meta_description && <div className="mt-1 text-xs text-red-500">{errors.meta_description}</div>}
                        </div>
                        <div>
                            <Label htmlFor="status">Status</Label>
                            <Select value={data.status} onValueChange={handleStatusChange}>
                                <SelectTrigger className="bg-background w-full rounded border px-2 py-2">
                                    <SelectValue placeholder="Select status" />
                                </SelectTrigger>
                                <SelectContent>
                                    <SelectItem value="draft">Draft</SelectItem>
                                    <SelectItem value="active">Active</SelectItem>
                                    <SelectItem value="suspended">Suspended</SelectItem>
                                </SelectContent>
                            </Select>
                            {errors.status && <div className="text-sm text-red-500">{errors.status}</div>}
                        </div>
                        <div className="flex justify-end gap-2">
                            <Button type="submit" disabled={processing}>
                                Update page
                            </Button>
                            <Button type="button" variant="outline" onClick={() => router.visit(route('cms-pages.index'))}>
                                Cancel
                            </Button>
                        </div>
                    </form>
                </div>
            </div>
        </AppLayout>
    );
};

export default EditCms;