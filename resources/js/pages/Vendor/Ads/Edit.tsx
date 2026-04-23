import React, { useState, useEffect } from 'react';
import { useLanguage } from '@/components/language-context';
import { useForm } from '@inertiajs/react';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select';
import { Textarea } from '@/components/ui/textarea';
import AppLayout from '@/layouts/app-layout';
import { Head, Link, router } from '@inertiajs/react';
import { ArrowLeft } from 'lucide-react';
import { toast } from 'react-hot-toast';
import { format, parse } from 'date-fns';



interface Product {
    id: number;
    name_en: string;
    name_ar: string;
    price: number;
    status: string;
    category: {
        name_en: string;
        name_ar: string;
    };
}

interface Expo {
    id: number;
    title_en: string;
    title_ar: string;
    status: string;
}

interface Vendor {
    id: number;
    name_en: string;
    name_ar: string;
}

interface Ad {
    id: number;
    title_en: string;
    title_ar: string;
    description_en?: string;
    description_ar?: string;
    banners?: string;
    link_type: string;
    link_id?: number;
    external_link?: string;
    status: string;
    priority: number;
    start_date?: string;
    end_date?: string;
    vendor_id?: number;
}

interface EditAdProps {
    ad: Ad;
    products: Product[];
    expos: Expo[];
    linkTypeOptions: { value: string; label: string }[];
    vendors: Vendor[];
}

const EditAd = ({ ad, products, expos, linkTypeOptions, vendors }: EditAdProps) => {
    const { t } = useLanguage();
    const { data, setData, put, post, processing, errors } = useForm({
        title_en: ad.title_en || '',
        title_ar: ad.title_ar || '',
        description_en: ad.description_en || '',
        description_ar: ad.description_ar || '',
        banners: '', // Don't initialize with existing banner filename
        link_type: ad.link_type || 'product',
        link_id: ad.link_id?.toString() || '',
        external_link: ad.external_link || '',
        status: ad.status || 'draft',
        priority: ad.priority || 50,
        start_date: ad.start_date || '',
        end_date: ad.end_date || '',
        vendor_id: ad.vendor_id?.toString() || '',
        _method: 'PUT',
    });

    const [selectedImage, setSelectedImage] = useState<File | null>(null);
    const [imagePreview, setImagePreview] = useState<string | null>(ad.banners || null);
    const [imageValidation, setImageValidation] = useState<{ valid: boolean; message: string }>({ valid: true, message: '' });

    // Get tomorrow's date in Indian timezone
    const getTomorrowDate = () => {
        const tomorrow = new Date();
        tomorrow.setDate(tomorrow.getDate() + 1);
        tomorrow.setHours(0, 0, 0, 0);
        const indianTime = new Date(tomorrow.toLocaleString("en-US", { timeZone: "Asia/Kolkata" }));
        return formatDateTimeLocal(indianTime.toISOString());
    };

    useEffect(() => {
        if (ad) {
            setData('title_en', ad.title_en || '');
            setData('title_ar', ad.title_ar || '');
            setData('description_en', ad.description_en || '');
            setData('description_ar', ad.description_ar || '');
            // Don't set banners field with existing filename - it should only contain File objects
            setData('link_type', ad.link_type || 'product');
            setData('link_id', ad.link_id?.toString() || '');
            setData('external_link', ad.external_link || '');
            setData('status', ad.status || 'draft');
            setData('priority', ad.priority || 50);
            setData('start_date', ad.start_date || '');
            setData('end_date', ad.end_date || '');
            setData('vendor_id', ad.vendor_id?.toString() || '');
            setImagePreview(ad.banners || null);
        }
    }, [ad]);

    const handleImageChange = (e: React.ChangeEvent<HTMLInputElement>) => {
        const file = e.target.files?.[0];
        if (!file) return;

        if (!file.type.startsWith('image/')) {
            setImageValidation({ valid: false, message: 'Please select a valid image file.' });
            return;
        }

        if (file.size > 5 * 1024 * 1024) {
            setImageValidation({ valid: false, message: 'Image size must be less than 5MB.' });
            return;
        }

        const img = new Image();
        img.onload = () => {
            const minWidth = 320;
            const maxWidth = 750;
            const minHeight = 100;
            const maxHeight = 200;
            const minAspectRatio = 1.6;
            const maxAspectRatio = 7.5;
            const aspectRatio = img.width / img.height;

            // if (
            //     img.width < minWidth || img.width > maxWidth ||
            //     img.height < minHeight || img.height > maxHeight ||
            //     aspectRatio < minAspectRatio || aspectRatio > maxAspectRatio
            // ) {
            //     setImageValidation({
            //         valid: false,
            //         message: `Image must be ${minWidth}-${maxWidth}px wide, ${minHeight}-${maxHeight}px tall with aspect ratio ${minAspectRatio}–${maxAspectRatio}.`,
            //     });
            //     return;
            // }

            setImageValidation({ valid: true, message: '' });
            setImagePreview(URL.createObjectURL(file));
            setData('banners', file); // ✅ store image in form
        };

        img.src = URL.createObjectURL(file);
    };


    const handleSubmit = (e: React.FormEvent) => {
        e.preventDefault();

        if (!imageValidation.valid) {
            toast.error(imageValidation.message);
            return;
        }

        const formData = new FormData();

        Object.keys(data).forEach(key => {
            if (key === 'banners') return; // ❌ skip banners here
            const value = data[key as keyof typeof data];
            if (value !== null && value !== undefined) {
                formData.append(key, value as string);
            }
        });

        if (selectedImage) {
            formData.append('banners', selectedImage); // ✅ Correct type
        }

        // Add method spoofing for PUT request
        formData.append('_method', 'PUT');

        post(route('vendor.ads.update', ad.id), {
            forceFormData: true,
            onSuccess: () => {
                toast.success('Ad updated successfully!');
                router.visit(route('vendor.ads.index'));
            },
            onError: (errors: any) => {
                console.error('Update errors:', errors);
                toast.error('Failed to update ad.');
            },
        });
    };


    const getLinkableItems = () => {
        switch (data.link_type) {
            case 'product':
                return products.map(product => ({
                    id: product.id,
                    name: product.name_en,
                    name_ar: product.name_ar,
                    type: 'Product'
                }));
            case 'expo':
                return expos.map(expo => ({
                    id: expo.id,
                    name: expo.title_en,
                    name_ar: expo.title_ar,
                    type: 'Expo'
                }));
            default:
                return [];
        }
    };

    function formatDateTimeLocal(dt: string) {
        if (!dt) return '';
        const date = new Date(dt);
        const year = date.getFullYear();
        const month = String(date.getMonth() + 1).padStart(2, '0');
        const day = String(date.getDate()).padStart(2, '0');
        const hours = String(date.getHours()).padStart(2, '0');
        const minutes = String(date.getMinutes()).padStart(2, '0');
        return `${year}-${month}-${day}T${hours}:${minutes}`;
    }

    function formatDateTimeForBackend(dt: string) {
        if (!dt) return '';
        const date = new Date(dt);
        return date.toISOString();
    }

    const validateStartDate = (dateString: string) => {
        if (!dateString) return true;
        const selectedDate = new Date(dateString);
        const tomorrow = new Date();
        tomorrow.setDate(tomorrow.getDate() + 1);
        tomorrow.setHours(0, 0, 0, 0);
        return selectedDate >= tomorrow;
    };

    function formatDateToInput(value: string | Date) {
        if (!value) return null;
        try {
            return typeof value === 'string' ? parse(value, 'yyyy-MM-dd HH:mm:ss', new Date()) : new Date(value);
        } catch {
            return null;
        }
    }

    function formatToBackend(value: string | Date) {
        return format(value, 'yyyy-MM-dd HH:mm:ss'); // Format to send
    }



    return (
        <AppLayout>
            <Head title={t('vendor.editAd')} />

            <div className="space-y-6 p-6">
                {/* Header */}
                <div className="flex items-center justify-between">
                    <div className="flex items-center gap-4">

                        <div>
                            <h1 className="text-2xl font-bold text-gray-900 dark:text-white">
                                Edit Ad
                            </h1>
                            <p className="text-sm text-gray-600 dark:text-gray-400">
                                Update the details of this promotional banner
                            </p>
                        </div>
                    </div>
                </div>

                {/* Main Content - Form and Preview */}
                <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
                    {/* Form Section */}
                    <div className="lg:col-span-2">
                        <div className="bg-white dark:bg-[#171717] rounded-lg border border-gray-200 dark:border-gray-700">
                            <div className="p-6">
                                <form onSubmit={handleSubmit} className="space-y-6">
                                    <div className="grid grid-cols-1 gap-4 md:grid-cols-2">
                                        <div>
                                            <Label htmlFor="title_en">Title (EN) <span className='text-red-500'>*</span></Label>
                                            <Input
                                                id="title_en"
                                                name="title_en"
                                                value={data.title_en}
                                                onChange={e => setData('title_en', e.target.value)}
                                            />
                                            {errors.title_en && <div className="mt-1 text-xs text-red-500">{errors.title_en}</div>}
                                        </div>
                                        <div>
                                            <Label htmlFor="title_ar">Title (AR) <span className='text-red-500'>*</span></Label>
                                            <Input
                                                id="title_ar"
                                                name="title_ar"
                                                value={data.title_ar}
                                                onChange={e => setData('title_ar', e.target.value)}
                                                dir="rtl"
                                            />
                                            {errors.title_ar && <div className="mt-1 text-xs text-red-500">{errors.title_ar}</div>}
                                        </div>
                                    </div>

                                    <div className="grid grid-cols-1 gap-4 md:grid-cols-2">
                                        <div className="h-[200px]">
                                            <Label htmlFor="description_en">Description (English)</Label>
                                            <Textarea id="description_en" className='dark:bg-[#171717] dark:text-white h-[180px]' value={data.description_en} onChange={e => setData('description_en', e.target.value)} placeholder="Enter English description" />
                                            {errors.description_en && <div className="mt-1 text-xs text-red-500">{errors.description_en}</div>}
                                        </div>
                                        <div className="h-[200px]">
                                            <Label htmlFor="description_ar">Description (Arabic)</Label>
                                            <Textarea id="description_ar" className='dark:bg-[#171717] dark:text-white h-[180px]' value={data.description_ar} onChange={e => setData('description_ar', e.target.value)} placeholder="أدخل الوصف بالعربية" dir="rtl" />
                                            {errors.description_ar && <div className="mt-1 text-xs text-red-500">{errors.description_ar}</div>}
                                        </div>
                                    </div>

                                    <div className="grid grid-cols-1 gap-4 md:grid-cols-2">

                                        <div>
                                            <label htmlFor="background_color">Vendors </label>
                                            <Select value={data.vendor_id} onValueChange={value => setData('vendor_id', value)}>
                                                <SelectTrigger>
                                                    <SelectValue placeholder="Select vendor" />
                                                </SelectTrigger>
                                                <SelectContent className='dark:bg-[#171717] dark:text-white'>
                                                    {vendors.map(vendor => (
                                                        <SelectItem key={vendor.id} value={vendor.id.toString()}>{vendor.name_en}</SelectItem>
                                                    ))}
                                                </SelectContent>
                                            </Select>
                                            {errors.vendor_id && <div className="mt-1 text-xs text-red-500">{errors.vendor_id}</div>}
                                        </div>
                                    </div>

                                    <div className="grid grid-cols-1 gap-4 md:grid-cols-2">
                                        <div>
                                            <Label htmlFor="priority">Priority</Label>
                                            <Input
                                                id="priority"
                                                name="priority"
                                                type="number"
                                                value={data.priority}
                                                onChange={e => setData('priority', parseInt(e.target.value) || 0)}
                                                min={0}
                                            />
                                            {errors.priority && <div className="mt-1 text-xs text-red-500">{errors.priority}</div>}
                                        </div>
                                        <div>
                                            <Label htmlFor="status">Status</Label>
                                            <Select value={data.status} onValueChange={value => setData('status', value)}>
                                                <SelectTrigger>
                                                    <SelectValue placeholder="Select status" />
                                                </SelectTrigger>
                                                <SelectContent className='dark:bg-[#171717] dark:text-white'>
                                                    <SelectItem value="draft">Draft</SelectItem>
                                                    <SelectItem value="active">Active</SelectItem>
                                                    <SelectItem value="suspended">Suspended</SelectItem>
                                                </SelectContent>
                                            </Select>
                                            {errors.status && <div className="mt-1 text-xs text-red-500">{errors.status}</div>}
                                        </div>
                                    </div>

                                    <div className="grid grid-cols-1 gap-4 md:grid-cols-2">
                                        <div>
                                            <Label htmlFor="start_date">Start Date & Time <span className='text-red-500'>*</span></Label>
                                            <Input
                                                id="start_date"
                                                type="datetime-local"
                                                name="start_date"
                                                value={data.start_date}
                                                onChange={e => setData('start_date', e.target.value)}
                                            />
                                            {errors.start_date && <div className="mt-1 text-xs text-red-500">{errors.start_date}</div>}
                                        </div>
                                        <div>
                                            <Label htmlFor="end_date">End Date & Time</Label>
                                            <Input
                                                id="end_date"
                                                type="datetime-local"
                                                name="end_date"
                                                value={data.end_date}
                                                onChange={e => setData('end_date', e.target.value)}
                                                min={data.start_date || formatDateTimeLocal(getTomorrowDate())}
                                            />
                                            {errors.end_date && <div className="mt-1 text-xs text-red-500">{errors.end_date}</div>}
                                        </div>
                                    </div>

                                    {/* Banner Image */}
                                    <div className="bg-card dark:bg-[#171717] space-y-4 rounded-xl border p-6 shadow-sm">
                                        <Label htmlFor="banners">Upload Banner Image</Label>
                                        <Input id="banners" type="file" accept="image/*" onChange={handleImageChange} className="cursor-pointer" />
                                        <p className="mt-1 text-sm text-gray-500">Recommended: 320x180px, Max: 2MB</p>
                                        {data.banners && (
                                            <div className="mt-2 p-3 bg-yellow-50 border border-yellow-200 rounded-lg">
                                                <p className="text-sm text-yellow-800 font-medium">⚠️ Update Notice:</p>
                                                <p className="text-sm text-yellow-700">Uploading a new image will replace the existing banner.</p>
                                            </div>
                                        )}
                                        {errors.banners && <div className="mt-1 text-xs text-red-500">{errors.banners}</div>}

                                    </div>

                                    {/* Link Configuration */}
                                    <div className="space-y-4 bg-card dark:bg-[#171717] p-6 rounded-xl border shadow-sm">
                                        <Label htmlFor="link_type">Link Type</Label>
                                        <Select value={data.link_type} onValueChange={value => setData('link_type', value)}>
                                            <SelectTrigger><SelectValue placeholder="Select link type" /></SelectTrigger>
                                            <SelectContent className='dark:bg-[#171717] dark:text-white'>
                                                {linkTypeOptions.map(option => (
                                                    <SelectItem key={option.value} value={option.value}>{option.label}</SelectItem>
                                                ))}
                                            </SelectContent>
                                        </Select>

                                        {data.link_type === 'external' ? (
                                            <div>
                                                <Label htmlFor="external_link">External URL</Label>
                                                <Input
                                                    id="external_link"
                                                    type="url"
                                                    value={data.external_link}
                                                    onChange={e => setData('external_link', e.target.value)}
                                                    placeholder="https://example.com"
                                                />
                                            </div>
                                        ) : data.link_type && data.link_type !== 'vendor' ? (
                                            <div>
                                                <Label htmlFor="link_id">Select {data.link_type}</Label>
                                                <Select value={data.link_id?.toString() || ''} onValueChange={value => setData('link_id', value)}>
                                                    <SelectTrigger><SelectValue placeholder={`Select ${data.link_type}`} /></SelectTrigger>
                                                    <SelectContent className='dark:bg-[#171717] dark:text-white'>
                                                        {getLinkableItems().map(item => (
                                                            <SelectItem key={item.id} value={item.id.toString()}>{item.name}</SelectItem>
                                                        ))}
                                                    </SelectContent>
                                                </Select>
                                            </div>
                                        ) : null}
                                    </div>

                                    <div className="flex justify-end gap-2">
                                        <Link href={route('vendor.ads.index')}>
                                            <Button variant="ghost" size="sm" className="mr-2">
                                                <ArrowLeft className="mr-2 h-4 w-4" />
                                                Back to Ads
                                            </Button>
                                        </Link>
                                        <Button type="submit" disabled={processing}>
                                            {processing ? 'Updating...' : 'Update Ad'}
                                        </Button>
                                        <Button type="button" variant="outline" onClick={() => router.visit(route('vendor.ads.index'))}>
                                            Cancel
                                        </Button>
                                    </div>
                                </form>
                            </div>
                        </div>
                    </div>

                    {/* Mobile Preview Section */}
                    <div className="lg:col-span-1">
                        <div className="bg-white dark:bg-[#171717] rounded-lg border border-gray-200 dark:border-gray-700 sticky top-6">
                            <div className="p-6">
                                <h3 className="text-lg font-semibold text-gray-900 dark:text-white mb-4">
                                    📱 Mobile Preview
                                </h3>

                                {/* Mobile Frame */}
                                <div className="mx-auto max-w-[280px]">
                                    <div className="relative bg-black rounded-[2.5rem] p-2 shadow-xl">
                                        {/* Screen */}
                                        <div className="bg-white dark:bg-gray-900 rounded-[2rem] overflow-hidden h-[500px] relative">
                                            {/* Status Bar */}
                                            <div className="bg-gray-100 dark:bg-gray-800 px-4 py-2 flex justify-between items-center text-xs">
                                                <span className="font-medium">9:41</span>
                                                <div className="flex items-center gap-1">
                                                    <div className="w-4 h-2 bg-green-500 rounded-sm"></div>
                                                    <span>100%</span>
                                                </div>
                                            </div>

                                            {/* App Header */}
                                            <div className="bg-blue-600 text-white px-4 py-3">
                                                <h4 className="font-semibold text-sm">Expo App</h4>
                                            </div>

                                            {/* Content Area */}
                                            <div className="p-4 space-y-4 h-full overflow-y-auto">
                                                {/* Banner Preview */}
                                                <div className="space-y-2">
                                                    <p className="text-xs text-gray-500 dark:text-gray-400">Featured Banner</p>
                                                    {imagePreview || data.banners ? (
                                                        <div className="relative rounded-lg overflow-hidden shadow-md">
                                                            <img
                                                                src={imagePreview || data.banners}
                                                                alt="Banner preview"
                                                                className="w-full h-24 object-cover"
                                                            />
                                                            {data.title_en && (
                                                                <div className="absolute bottom-0 left-0 right-0 bg-gradient-to-t from-black/70 to-transparent p-2">
                                                                    <p className="text-white text-xs font-medium truncate">
                                                                        {data.title_en}
                                                                    </p>
                                                                </div>
                                                            )}
                                                        </div>
                                                    ) : (
                                                        <div className="w-full h-24 bg-gray-200 dark:bg-gray-700 rounded-lg flex items-center justify-center">
                                                            <div className="text-center">
                                                                <div className="text-2xl mb-1">🖼️</div>
                                                                <p className="text-xs text-gray-500 dark:text-gray-400">
                                                                    {ad.banners ? 'Current banner' : 'Upload banner to preview'}
                                                                </p>
                                                            </div>
                                                        </div>
                                                    )}
                                                </div>

                                                {/* Sample Content */}
                                                <div className="space-y-3">
                                                    <p className="text-xs text-gray-500 dark:text-gray-400">Other Content</p>
                                                    <div className="grid grid-cols-2 gap-2">
                                                        <div className="bg-gray-100 dark:bg-gray-800 rounded-lg p-3">
                                                            <div className="w-full h-16 bg-gray-300 dark:bg-gray-600 rounded mb-2"></div>
                                                            <p className="text-xs font-medium">Product 1</p>
                                                            <p className="text-xs text-gray-500">$29.99</p>
                                                        </div>
                                                        <div className="bg-gray-100 dark:bg-gray-800 rounded-lg p-3">
                                                            <div className="w-full h-16 bg-gray-300 dark:bg-gray-600 rounded mb-2"></div>
                                                            <p className="text-xs font-medium">Product 2</p>
                                                            <p className="text-xs text-gray-500">$39.99</p>
                                                        </div>
                                                    </div>
                                                </div>

                                                {/* Banner Info */}
                                                {(data.title_en || data.description_en) && (
                                                    <div className="bg-blue-50 dark:bg-blue-900/20 rounded-lg p-3 border border-blue-200 dark:border-blue-800">
                                                        <p className="text-xs font-medium text-blue-800 dark:text-blue-200 mb-1">
                                                            Banner Details:
                                                        </p>
                                                        {data.title_en && (
                                                            <p className="text-xs text-blue-700 dark:text-blue-300 mb-1">
                                                                <strong>Title:</strong> {data.title_en}
                                                            </p>
                                                        )}
                                                        {data.description_en && (
                                                            <p className="text-xs text-blue-700 dark:text-blue-300">
                                                                <strong>Description:</strong> {data.description_en.substring(0, 50)}{data.description_en.length > 50 ? '...' : ''}
                                                            </p>
                                                        )}
                                                    </div>
                                                )}
                                            </div>
                                        </div>
                                    </div>
                                </div>

                                {/* Preview Info */}
                                <div className="mt-4 text-center">
                                    <p className="text-xs text-gray-500 dark:text-gray-400">
                                        This shows how your banner will appear in the mobile app
                                    </p>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </AppLayout>
    );
};

export default EditAd;
