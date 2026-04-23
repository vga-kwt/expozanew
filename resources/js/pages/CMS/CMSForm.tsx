import { Label } from '@/components/ui/label';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select';
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs';
import { router } from '@inertiajs/react';
import React, { useState } from 'react';
import { Button } from '../../components/ui/button';
import { Card } from '../../components/ui/card';
import { Input } from '../../components/ui/input';

interface CmsPage {
    id?: number;
    title_en: string;
    title_ar: string;
    content_en: string;
    content_ar: string;
    slug: string;
    meta_title?: string;
    meta_description?: string;
    meta_keywords?: string;
    status: 'active' | 'suspended' | 'draft';
    [key: string]: string | number | undefined;
}

interface Props {
    mode: 'create' | 'edit';
    page?: CmsPage;
    onSuccess?: () => void;
}

const initialState: CmsPage = {
    title_en: '',
    title_ar: '',
    content_en: '',
    content_ar: '',
    slug: '',
    meta_title: '',
    meta_description: '',
    meta_keywords: '',
    status: 'draft',
};

// Simple WYSIWYG Editor Component
function WYSIWYGEditor({
    value,
    onChange,
    placeholder = 'Enter content...',
    dir = 'ltr',
}: {
    value: string;
    onChange: (value: string) => void;
    placeholder?: string;
    dir?: 'ltr' | 'rtl';
}) {
    const execCommand = (command: string, value?: string) => {
        document.execCommand(command, false, value);
        const content = document.getElementById('editor')?.innerHTML || '';
        onChange(content);
    };

    const handleInput = () => {
        const content = document.getElementById('editor')?.innerHTML || '';
        onChange(content);
    };

    return (
        <div className="rounded-md border">
            {/* Toolbar */}
            <div className="flex flex-wrap gap-1 border-b bg-gray-50 p-2">
                <Button type="button" size="sm" variant="outline" onClick={() => execCommand('bold')} className="h-8 w-8 p-0">
                    <strong>B</strong>
                </Button>
                <Button type="button" size="sm" variant="outline" onClick={() => execCommand('italic')} className="h-8 w-8 p-0">
                    <em>I</em>
                </Button>
                <Button type="button" size="sm" variant="outline" onClick={() => execCommand('underline')} className="h-8 w-8 p-0">
                    <u>U</u>
                </Button>
                <div className="mx-1 h-6 w-px bg-gray-300"></div>
                <Button type="button" size="sm" variant="outline" onClick={() => execCommand('insertUnorderedList')} className="h-8 w-8 p-0">
                    • List
                </Button>
                <Button type="button" size="sm" variant="outline" onClick={() => execCommand('insertOrderedList')} className="h-8 w-8 p-0">
                    1. List
                </Button>
                <div className="mx-1 h-6 w-px bg-gray-300"></div>
                <Button
                    type="button"
                    size="sm"
                    variant="outline"
                    onClick={() => {
                        const url = prompt('Enter URL:');
                        if (url) execCommand('createLink', url);
                    }}
                    className="h-8 w-8 p-0"
                >
                    🔗
                </Button>
                <Button type="button" size="sm" variant="outline" onClick={() => execCommand('removeFormat')} className="h-8 w-8 p-0">
                    Clear
                </Button>
            </div>

            {/* Editor */}
            <div
                id="editor"
                contentEditable
                className="min-h-[200px] p-3 focus:outline-none"
                onInput={handleInput}
                dir={dir}
                dangerouslySetInnerHTML={{ __html: value }}
                style={{
                    fontFamily: 'Arial, sans-serif',
                    fontSize: '14px',
                    lineHeight: '1.5',
                }}
            />

            {!value && (
                <div className="pointer-events-none absolute top-0 left-0 p-3 text-gray-400" style={{ marginTop: '60px' }}>
                    {placeholder}
                </div>
            )}
        </div>
    );
}

export default function CMSForm({ mode, page, onSuccess }: Props) {
    const [form, setForm] = useState<CmsPage>({
        ...initialState,
        ...page,
        content_en: page?.content_en || '',
        content_ar: page?.content_ar || '',
    });
    const [errors, setErrors] = useState<Record<string, string>>({});
    const [loading, setLoading] = useState(false);
    const [activeTab, setActiveTab] = useState('en');
    const [activePreviewTab, setActivePreviewTab] = useState('preview-en');

    const handleChange = (e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement>) => {
        setForm({ ...form, [e.target.name]: e.target.value });
    };

    const handleContentChange = (field: 'content_en' | 'content_ar', value: string) => {
        setForm({ ...form, [field]: value });
    };

    const handleStatusChange = (value: string) => {
        setForm({ ...form, status: value as CmsPage['status'] });
    };

    const handleSubmit = (e: React.FormEvent) => {
        e.preventDefault();
        setLoading(true);
        setErrors({});
        if (mode === 'create') {
            router.post(route('cms-pages.store'), form, {
                onError: setErrors,
                onFinish: () => setLoading(false),
                onSuccess: () => {
                    if (onSuccess) onSuccess();
                },
            });
        } else if (mode === 'edit' && page) {
            router.put(route('cms-pages.update', page.id), form, {
                onError: setErrors,
                onFinish: () => setLoading(false),
                onSuccess: () => {
                    if (onSuccess) onSuccess();
                },
            });
        }
    };

    return (
        <Card className="mx-auto mt-8 max-w-6xl p-8">
            <form onSubmit={handleSubmit} className="max-h-[80vh] space-y-6 overflow-y-auto pr-2">
                <h2 className="mb-4 text-xl font-bold">{mode === 'create' ? 'Add New Page' : 'Edit Page'}</h2>

                {/* Basic Information */}
                <div className="grid grid-cols-1 gap-4 md:grid-cols-4">
                    <div>
                        <Label htmlFor="title_en">Title (EN)</Label>
                        <Input id="title_en" name="title_en" value={form.title_en} onChange={handleChange} required />
                        {errors.title_en && <div className="text-sm text-red-500">{errors.title_en}</div>}
                    </div>
                    <div>
                        <Label htmlFor="title_ar">Title (AR)</Label>
                        <Input id="title_ar" name="title_ar" value={form.title_ar} onChange={handleChange} required dir="rtl" />
                        {errors.title_ar && <div className="text-sm text-red-500">{errors.title_ar}</div>}
                    </div>
                    <div>
                        <Label htmlFor="slug">Slug</Label>
                        <Input id="slug" name="slug" value={form.slug} onChange={handleChange} required placeholder="page-url-slug" />
                        {errors.slug && <div className="text-sm text-red-500">{errors.slug}</div>}
                    </div>
                    <div>
                        <Label htmlFor="status">Status</Label>
                        <Select value={form.status} onValueChange={handleStatusChange}>
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
                </div>

                {/* Meta Fields */}
                <div className="grid grid-cols-1 gap-4 md:grid-cols-2">
                    <div>
                        <Label htmlFor="meta_title">Meta Title</Label>
                        <Input
                            id="meta_title"
                            name="meta_title"
                            value={form.meta_title || ''}
                            onChange={handleChange}
                            placeholder="SEO meta title"
                        />
                        {errors.meta_title && <div className="text-sm text-red-500">{errors.meta_title}</div>}
                    </div>
                    <div>
                        <Label htmlFor="meta_keywords">Meta Keywords</Label>
                        <Input
                            id="meta_keywords"
                            name="meta_keywords"
                            value={form.meta_keywords || ''}
                            onChange={handleChange}
                            placeholder="SEO keywords (comma separated)"
                        />
                        {errors.meta_keywords && <div className="text-sm text-red-500">{errors.meta_keywords}</div>}
                    </div>
                </div>

                <div>
                    <Label htmlFor="meta_description">Meta Description</Label>
                    <textarea
                        id="meta_description"
                        name="meta_description"
                        value={form.meta_description || ''}
                        onChange={handleChange}
                        placeholder="SEO meta description (max 500 characters)"
                        className="w-full rounded-md border border-input bg-background px-3 py-2 text-sm ring-offset-background placeholder:text-muted-foreground focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:cursor-not-allowed disabled:opacity-50"
                        rows={3}
                        maxLength={500}
                    />
                    <div className="mt-1 text-xs text-gray-500">
                        {(form.meta_description?.length || 0)}/500 characters
                    </div>
                    {errors.meta_description && <div className="text-sm text-red-500">{errors.meta_description}</div>}
                </div>

                {/* Content Editor */}
                <Tabs value={activeTab} onValueChange={setActiveTab} className="w-full">
                    <TabsList className="grid w-full grid-cols-2">
                        <TabsTrigger value="en">English Content</TabsTrigger>
                        <TabsTrigger value="ar">Arabic Content</TabsTrigger>
                    </TabsList>

                    <TabsContent value="en" className="space-y-4">
                        <div>
                            <Label>Content (English)</Label>
                            <WYSIWYGEditor
                                value={form.content_en}
                                onChange={(value) => handleContentChange('content_en', value)}
                                placeholder="Enter English content..."
                                dir="ltr"
                            />
                            {errors.content_en && <div className="mt-1 text-sm text-red-500">{errors.content_en}</div>}
                        </div>
                    </TabsContent>

                    <TabsContent value="ar" className="space-y-4">
                        <div>
                            <Label>Content (Arabic)</Label>
                            <WYSIWYGEditor
                                value={form.content_ar}
                                onChange={(value) => handleContentChange('content_ar', value)}
                                placeholder="أدخل المحتوى بالعربية..."
                                dir="rtl"
                            />
                            {errors.content_ar && <div className="mt-1 text-sm text-red-500">{errors.content_ar}</div>}
                        </div>
                    </TabsContent>
                </Tabs>

                {/* Preview Section */}
                <div className="border-t pt-4">
                    <h3 className="mb-2 text-lg font-semibold">Preview</h3>
                    <Tabs value={activePreviewTab} onValueChange={setActivePreviewTab} className="w-full">
                        <TabsList className="grid w-full grid-cols-2">
                            <TabsTrigger value="preview-en">English Preview</TabsTrigger>
                            <TabsTrigger value="preview-ar">Arabic Preview</TabsTrigger>
                        </TabsList>

                        <TabsContent value="preview-en" className="space-y-4">
                            <div className="rounded-md border bg-white p-4">
                                <h1 className="mb-4 text-2xl font-bold">{form.title_en || 'Page Title'}</h1>
                                <div
                                    className="prose max-w-none"
                                    dangerouslySetInnerHTML={{ __html: form.content_en || '<p>Content will appear here...</p>' }}
                                />
                            </div>
                        </TabsContent>

                        <TabsContent value="preview-ar" className="space-y-4">
                            <div className="rounded-md border bg-white p-4" dir="rtl">
                                <h1 className="mb-4 text-2xl font-bold">{form.title_ar || 'عنوان الصفحة'}</h1>
                                <div
                                    className="prose max-w-none"
                                    dangerouslySetInnerHTML={{ __html: form.content_ar || '<p>سيظهر المحتوى هنا...</p>' }}
                                />
                            </div>
                        </TabsContent>
                    </Tabs>
                </div>

                <div className="mt-6 flex justify-end gap-2">
                    <Button type="submit" disabled={loading}>
                        {loading ? 'Saving...' : mode === 'create' ? 'Create Page' : 'Update Page'}
                    </Button>
                </div>
            </form>
        </Card>
    );
}
