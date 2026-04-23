import { useLanguage } from '@/components/language-context';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select';
import AppLayout from '@/layouts/app-layout';
import { Head, router, useForm, usePage } from '@inertiajs/react';
import { useState } from 'react';
import { toast } from 'react-hot-toast';
import ReactQuill from 'react-quill';
import 'react-quill/dist/quill.snow.css';
import { Plus, Trash2 } from 'lucide-react';

interface Product {
    id: number;
    name_en: string;
    name_ar: string;
    description_en?: string;
    description_ar?: string;
    price: string;
    regular_price: number;
    sale_price?: number;
    stock: number;
    status: 'active' | 'suspended' | 'deleted';
    images?: { url: string; name: string }[];
    gallery?: string[];
    image_url?: string;
    attributes?: { key: string; value: string }[];
    category: { id: number; name_en: string };
    vendor: { id: number; name: string };
    expo?: { id: number; name_en: string };
    section?: { id: number; name_en: string };
    created_at?: string;
    discount?: string;
    category_id: string | null;
    section_id: string | null;
    expo_id: string | null;
    variants?: Array<{
        id?: number;
        size: string;
        color: string;
        price: number;
        sale_price: number;
        stock: number;
        sizeStockPairs?: Array<{ size: string; stock: number }>;
    }>;
}

interface EditProps {
    product: Product;
    categories: { id: number; name_en: string }[];
    vendors: { id: number; name: string }[];
    expos: { id: number; name_en: string }[];
    sections: { id: number; name_en: string }[];
    [key: string]: unknown;
}

const Edit = ({ auth }: { auth: { user: { role: string }; permissions: string[] } }) => {
    const { t } = useLanguage();
    const userRole = auth.user.role;
    const { product, categories, vendors } = usePage<EditProps>().props;

    interface SizeStockPair {
        size: string;
        stock: number;
        price: number;
        sale_price: number;
    }

    interface ProductVariant {
        size: string;
        color: string;
        stock: number;
        sizeStockPairs: SizeStockPair[];
    }

    const { data, setData, processing, errors, setError } = useForm({
        name_en: product?.name_en || '',
        name_ar: product?.name_ar || '',
        description_en: product?.description_en || '',
        description_ar: product?.description_ar || '',
        price: product?.price || '',
        regular_price: product?.regular_price?.toString() || '',
        sale_price: product?.sale_price?.toString() || '',
        stock: product?.stock || 0,
        views: 0,
        attributes: '',
        image_url: null as File | null,
        gallery: [] as File[],
        category_id: product?.category_id?.toString() || '',
        vendor_id: product?.vendor?.id?.toString() || '',
        expo_id: product?.expo_id?.toString() || '',
        section_id: product?.section_id?.toString() || '',
        status: product?.status || 'active',
        existing_images: product?.images || [],
        removed_images: [] as string[],
    });

    // Initialize variants from product attributes or empty array
    const [variants, setVariants] = useState<ProductVariant[]>(() => {
        // Check if variants exist (mapped from attributes in backend)
        if (product?.variants && Array.isArray(product.variants) && product.variants.length > 0) {
            return product.variants.map((v) => ({
                size: v.size || '',
                color: v.color || '',
                stock: v.stock || 0,
                sizeStockPairs: (v.sizeStockPairs || []).map((pair: { size: string; stock: number; price?: number; sale_price?: number }) => ({
                    size: pair.size || '',
                    stock: pair.stock || 0,
                    price: pair.price || 0,
                    sale_price: pair.sale_price || 0,
                })),
            }));
        }
        // Fallback: check attributes directly
        if (product?.attributes && Array.isArray(product.attributes) && product.attributes.length > 0) {
            return product.attributes.map((v: Record<string, unknown>) => ({
                size: (v.size as string) || '',
                color: (v.color as string) || '',
                stock: (v.stock as number) || 0,
                sizeStockPairs: ((v.sizeStockPairs as SizeStockPair[]) || []).map((pair) => ({
                    size: pair.size || '',
                    stock: pair.stock || 0,
                    price: pair.price || 0,
                    sale_price: pair.sale_price || 0,
                })),
            }));
        }
        return [
            {
                size: '',
                color: '',
                stock: 0,
                sizeStockPairs: [],
            },
        ];
    });

    // Initialize expanded variants for variants that already have sizeStockPairs
    const [expandedVariants, setExpandedVariants] = useState<Set<number>>(() => {
        const expanded = new Set<number>();
        if (product?.variants && Array.isArray(product.variants)) {
            product.variants.forEach((v, index) => {
                if (v.sizeStockPairs && Array.isArray(v.sizeStockPairs) && v.sizeStockPairs.length > 0) {
                    expanded.add(index);
                }
            });
        } else if (product?.attributes && Array.isArray(product.attributes)) {
            product.attributes.forEach((v: Record<string, unknown>, index: number) => {
                if (v.sizeStockPairs && Array.isArray(v.sizeStockPairs) && (v.sizeStockPairs as unknown[]).length > 0) {
                    expanded.add(index);
                }
            });
        }
        return expanded;
    });

    // Variant handlers
    const handleAddVariant = () => {
        setVariants([
            ...variants,
            {
                size: '',
                color: '',
                stock: 0,
                sizeStockPairs: [],
            },
        ]);
    };

    const handleRemoveVariant = (index: number) => {
        if (variants.length > 1) {
            setVariants(variants.filter((_, i) => i !== index));
            const newExpanded = new Set(expandedVariants);
            newExpanded.delete(index);
            setExpandedVariants(newExpanded);
        } else {
            toast.error('At least one variant is required');
        }
    };

    const handleVariantChange = (index: number, field: keyof ProductVariant, value: string | number) => {
        setVariants(
            variants.map((variant, i) => (i === index ? { ...variant, [field]: value } : variant))
        );
    };

    const toggleSizeStock = (variantIndex: number) => {
        setExpandedVariants(prev => {
            const newExpanded = new Set(prev);
            if (newExpanded.has(variantIndex)) {
                newExpanded.delete(variantIndex);
            } else {
                newExpanded.add(variantIndex);
            }
            return newExpanded;
        });
    };

    const addSizeStockPair = (variantIndex: number) => {
        setVariants(variants.map((variant, i) => 
            i === variantIndex 
                ? { ...variant, sizeStockPairs: [...variant.sizeStockPairs, { size: '', stock: 0, price: 0, sale_price: 0 }] }
                : variant
        ));
    };

    const removeSizeStockPair = (variantIndex: number, pairIndex: number) => {
        setVariants(variants.map((variant, i) => 
            i === variantIndex 
                ? { ...variant, sizeStockPairs: variant.sizeStockPairs.filter((_, idx) => idx !== pairIndex) }
                : variant
        ));
    };

    const handleSizeStockChange = (variantIndex: number, pairIndex: number, field: 'size' | 'stock' | 'price' | 'sale_price', value: string | number) => {
        setVariants(variants.map((variant, i) => 
            i === variantIndex 
                ? { 
                    ...variant, 
                    sizeStockPairs: variant.sizeStockPairs.map((pair, idx) => 
                        idx === pairIndex ? { ...pair, [field]: value } : pair
                    )
                }
                : variant
        ));
    };

    const handleRemoveExistingImage = (imgUrl: string) => {
        let storagePath = imgUrl;
        
        if (imgUrl.includes('/storage/')) {
            const urlParts = imgUrl.split('/storage/');
            storagePath = urlParts.length > 1 ? urlParts[1] : imgUrl;
        } else if (imgUrl.includes('amazonaws.com/')) {
            const urlParts = imgUrl.split('amazonaws.com/');
            storagePath = urlParts.length > 1 ? urlParts[1] : imgUrl;
        } else if (!imgUrl.startsWith('http')) {
            storagePath = imgUrl;
        }

        setData('removed_images', [...data.removed_images, storagePath]);
        setData(
            'existing_images',
            data.existing_images.filter((img: { url: string }) => img.url !== imgUrl),
        );
    };

    const handleMainImageChange = (e: React.ChangeEvent<HTMLInputElement>) => {
        const file = e.target.files && e.target.files[0];
        if (file) {
            const existingMainImage = data.existing_images.find((img: { url: string; name: string }) => img.url.includes(product?.image_url || ''));

            if (existingMainImage) {
                let storagePath = existingMainImage.url;
                
                if (existingMainImage.url.includes('/storage/')) {
                    const urlParts = existingMainImage.url.split('/storage/');
                    storagePath = urlParts.length > 1 ? urlParts[1] : existingMainImage.url;
                } else if (existingMainImage.url.includes('amazonaws.com/')) {
                    const urlParts = existingMainImage.url.split('amazonaws.com/');
                    storagePath = urlParts.length > 1 ? urlParts[1] : existingMainImage.url;
                } else if (!existingMainImage.url.startsWith('http')) {
                    storagePath = existingMainImage.url;
                }
                
                setData('removed_images', [...data.removed_images, storagePath]);
                setData(
                    'existing_images',
                    data.existing_images.filter((img: { url: string }) => img.url !== existingMainImage.url),
                );
            }

            setData('image_url', file);
        }
    };

    const onSubmit = (e: React.FormEvent) => {
        e.preventDefault();

        // Create FormData for file uploads
        const formData = new FormData();

        // Add all form data
        formData.append('name_en', data.name_en);
        formData.append('name_ar', data.name_ar);
        formData.append('description_en', data.description_en || '');
        formData.append('description_ar', data.description_ar || '');
        formData.append('price', data.price);
        formData.append('regular_price', data.regular_price);
        formData.append('sale_price', data.sale_price);
        formData.append('stock', '0'); // Will be updated with total stock from variants
        formData.append('views', data.views.toString());
        formData.append('category_id', data.category_id);
        formData.append('vendor_id', data.vendor_id);
        formData.append('expo_id', data.expo_id || '');
        formData.append('section_id', data.section_id || '');
        formData.append('status', data.status);
        formData.append('_method', 'put');

        // Calculate total stock from all variants and sizeStockPairs
        const totalStock = variants.reduce((sum, variant) => {
            const variantStock = Number(variant.stock) || 0;
            const pairsStock = variant.sizeStockPairs.reduce((pairSum, pair) => pairSum + (Number(pair.stock) || 0), 0);
            return sum + variantStock + pairsStock;
        }, 0);

        // Append variants data as attributes
        const variantsToSubmit = variants.map((variant) => ({
            size: variant.size,
            color: variant.color,
            stock: variant.stock,
            sizeStockPairs: variant.sizeStockPairs,
        }));
        formData.append('attributes', JSON.stringify(variantsToSubmit));

        // Update stock field with total stock from variants
        formData.set('stock', totalStock.toString());

        // Handle file uploads - only append if it's a new File
        // Don't append existing image_url as string, let backend keep existing one
        if (data.image_url instanceof File) {
            formData.append('image_url', data.image_url);
        }
        // If no new file is selected, don't append image_url at all
        // Backend will keep the existing image_url automatically

        if (data.gallery && Array.isArray(data.gallery) && data.gallery.length > 0) {
            data.gallery.forEach((file: File) => {
                if (file instanceof File) {
                    formData.append('gallery[]', file);
                }
            });
        }

        // Handle removed images
        if (data.removed_images && Array.isArray(data.removed_images)) {
            data.removed_images.forEach((imagePath: string) => {
                formData.append('removed_images[]', imagePath);
            });
        }

        // Use router.post with _method: 'put' for FormData uploads
        router.post(route('products.update', product.id), formData, {
            onSuccess: () => {
                toast.success(t('products.updatedSuccess'));
            },
            onError: () => {
                toast.error(t('products.updatedError'));
            },
        });
    };

    return (
        <AppLayout>
            <Head title={t('products.editProduct')} />
            <div className="p-8">
                <h1 className="mb-6 border-b pb-4 text-3xl font-bold">{t('products.editProduct')}</h1>
                <div className="min-h-[80vh]">
                    <form onSubmit={onSubmit} method="post" className="space-y-5">
                        <div className="rounded-lg border p-6">
                            <h2 className="mb-4 text-xl font-semibold">{t('products.basicInformation')}</h2>
                            <div className="grid grid-cols-2 gap-4">
                                <div>
                                    <label htmlFor="name_en" className="mb-1 block font-medium">
                                        {t('products.nameEn')} <span className='text-red-500'>*</span>
                                    </label>
                                    <Input
                                        id="name_en"
                                        placeholder={t('products.nameEn')}
                                        value={data.name_en}
                                        onChange={(e) => {
                                            setData('name_en', e.target.value);
                                            if (errors.name_en) setError('name_en', '');
                                        }}
                                        className={errors.name_en ? 'border-red-500' : ''}
                                    />
                                    {errors.name_en && <p className="mt-1 text-sm text-red-500">{errors.name_en}</p>}
                                </div>
                                <div>
                                    <label htmlFor="name_ar" className="mb-1 block font-medium">
                                        {t('products.nameAr')} <span className='text-red-500'>*</span>
                                    </label>
                                    <Input
                                        id="name_ar"
                                        placeholder={t('products.nameAr')}
                                        value={data.name_ar}
                                        onChange={(e) => {
                                            setData('name_ar', e.target.value);
                                            if (errors.name_ar) setError('name_ar', '');
                                        }}
                                        dir="rtl"
                                        className={errors.name_ar ? 'border-red-500' : ''}
                                    />
                                    {errors.name_ar && <p className="mt-1 text-sm text-red-500">{errors.name_ar}</p>}
                                </div>
                            </div>
                            <div className="mt-4 grid h-60 grid-cols-2 gap-4">
                                <div>
                                    <label className="mb-1 block font-medium">{t('products.descriptionEn')}</label>
                                    <ReactQuill
                                        theme="snow"
                                        value={data.description_en}
                                        onChange={(v) => {
                                            setData('description_en', v);
                                            if (errors.description_en) setError('description_en', '');
                                        }}
                                        className={`h-40 ${errors.description_en ? 'border-red-500' : ''}`}
                                    />
                                    {errors.description_en && <p className="mt-1 text-sm text-red-500">{errors.description_en}</p>}
                                </div>
                                <div>
                                    <label className="mb-1 block font-medium">{t('products.descriptionAr')}</label>
                                    <ReactQuill
                                        theme="snow"
                                        value={data.description_ar}
                                        onChange={(v) => {
                                            setData('description_ar', v);
                                            if (errors.description_ar) setError('description_ar', '');
                                        }}
                                        className={`h-40 ${errors.description_ar ? 'border-red-500' : ''}`}
                                    />
                                    {errors.description_ar && <p className="mt-1 text-sm text-red-500">{errors.description_ar}</p>}
                                </div>
                            </div>
                            {userRole === 'vendor' && (
                                <div className="mt-2 grid grid-cols-2 gap-4">
                                    <div>
                                        <label className="mb-1 block font-medium">{t('products.category')} <span className='text-red-500'>*</span></label>
                                        <Select value={data.category_id || ''} onValueChange={(v) => setData('category_id', v)}>
                                            <SelectTrigger className={errors.category_id ? 'border-red-500' : ''}>
                                                <SelectValue placeholder={t('products.category')} />
                                            </SelectTrigger>
                                            <SelectContent>
                                                {categories?.map((c: { id: number; name_en: string }) => (
                                                    <SelectItem key={c.id} value={c.id.toString()}>
                                                        {c.name_en}
                                                    </SelectItem>
                                                ))}
                                            </SelectContent>
                                        </Select>
                                        {errors.category_id && <p className="mt-1 text-sm text-red-500">{errors.category_id}</p>}
                                    </div>
                                    <div>
                                        <label className="mb-1 block font-medium">{t('products.status')}</label>
                                        <Select value={data.status || 'active'} onValueChange={(v) => setData('status', v as 'active' | 'suspended' | 'deleted')}>
                                            <SelectTrigger className={errors.status ? 'border-red-500' : ''}>
                                                <SelectValue placeholder={t('products.status')} />
                                            </SelectTrigger>
                                            <SelectContent>
                                                <SelectItem value="active">{t('expos.active')}</SelectItem>
                                                <SelectItem value="suspended">{t('expos.suspended')}</SelectItem>
                                                <SelectItem value="deleted">{t('products.deleted')}</SelectItem>
                                            </SelectContent>
                                        </Select>
                                        {errors.status && <p className="mt-1 text-sm text-red-500">{errors.status}</p>}
                                    </div>
                                </div>
                            )}
                        </div>
                        {userRole !== 'vendor' && (
                            <div className="rounded-lg border p-6">
                                <h2 className="mb-4 text-xl font-semibold">{t('products.categoriesAndRelations')}</h2>
                                <div className="grid grid-cols-2 gap-4">
                                    <div>
                                        <label className="mb-1 block font-medium">{t('products.category')} <span className='text-red-500'>*</span></label>
                                        <Select value={data.category_id || ''} onValueChange={(v) => setData('category_id', v)}>
                                            <SelectTrigger className={errors.category_id ? 'border-red-500' : ''}>
                                                <SelectValue placeholder={t('products.category')} />
                                            </SelectTrigger>
                                            <SelectContent>
                                                {categories?.map((c: { id: number; name_en: string }) => (
                                                    <SelectItem key={c.id} value={c.id.toString()}>
                                                        {c.name_en}
                                                    </SelectItem>
                                                ))}
                                            </SelectContent>
                                        </Select>
                                        {errors.category_id && <p className="mt-1 text-sm text-red-500">{errors.category_id}</p>}
                                    </div>
                                    <div>
                                        <label className="mb-1 block font-medium">{t('products.vendor')}</label>
                                        <Select value={data.vendor_id || ''} onValueChange={(v) => {
                                            setData('vendor_id', v);
                                            if (errors.vendor_id) setError('vendor_id', '');
                                        }}>
                                            <SelectTrigger className={errors.vendor_id ? 'border-red-500' : ''}>
                                                <SelectValue placeholder={t('products.vendor')} />
                                            </SelectTrigger>
                                            <SelectContent>
                                                {vendors?.map((v: { id: number; name: string }) => (
                                                    <SelectItem key={v.id} value={v.id.toString()}>
                                                        {v.name}
                                                    </SelectItem>
                                                ))}
                                            </SelectContent>
                                        </Select>
                                        {errors.vendor_id && <p className="mt-1 text-sm text-red-500">{errors.vendor_id}</p>}
                                    </div>
                                </div>
                            </div>
                        )}

                        <div className="rounded-lg border p-6">
                            <h2 className="mb-4 text-xl font-semibold">{t('products.images')}</h2>
                            <div className="grid grid-cols-2 gap-4">
                                <div>
                                    <label className="mb-1 block font-medium">{t('products.mainImage')} <span className='text-red-500'>*</span></label>
                                    <Input
                                        type="file"
                                        accept="image/*"
                                        onChange={(e) => {
                                            handleMainImageChange(e);
                                            if (errors.image_url) setError('image_url', '');
                                        }}
                                        className={errors.image_url ? 'border-red-500' : ''}
                                    />
                                    {errors.image_url && <p className="mt-1 text-sm text-red-500">{errors.image_url}</p>}
                                    {data.existing_images && data.existing_images.length > 0 && (
                                        <div className="mt-3">
                                            <p className="mb-2 text-sm text-gray-600">{t('products.currentMainImage')}:</p>
                                            <div className="flex flex-wrap gap-2">
                                                {data.existing_images
                                                    .filter((img: { url: string; name: string }) => img.url.includes(product?.image_url || ''))
                                                    .map((img: { url: string; name: string }, idx: number) => (
                                                        <div key={idx} className="group relative">
                                                            <img
                                                                src={img.url}
                                                                alt={img.name}
                                                                className="h-32 w-32 rounded border bg-gray-100 object-cover"
                                                            />
                                                            <Button
                                                                size="sm"
                                                                variant="destructive"
                                                                className="absolute top-1 right-1 opacity-80 group-hover:opacity-100"
                                                                onClick={() => handleRemoveExistingImage(img.url)}
                                                            >
                                                                ×
                                                            </Button>
                                                        </div>
                                                    ))}
                                            </div>
                                        </div>
                                    )}
                                </div>
                                <div>
                                    <label className="mb-1 block font-medium">{t('products.galleryImages')}</label>
                                    <Input
                                        type="file"
                                        accept="image/*"
                                        multiple
                                        onChange={(e) => {
                                            setData('gallery', Array.from(e.target.files || []));
                                            if (errors.gallery) setError('gallery', '');
                                        }}
                                        className={errors.gallery ? 'border-red-500' : ''}
                                    />
                                    {errors.gallery && <p className="mt-1 text-sm text-red-500">{errors.gallery}</p>}
                                    {data.existing_images && data.existing_images.length > 0 && (
                                        <div className="mt-3">
                                            <p className="mb-2 text-sm text-gray-600">{t('products.currentGalleryImages')}:</p>
                                            <div className="flex flex-wrap gap-2">
                                                {data.existing_images
                                                    .filter((img: { url: string; name: string }) => !img.url.includes(product?.image_url || ''))
                                                    .map((img: { url: string; name: string }, idx: number) => (
                                                        <div key={idx} className="group relative">
                                                            <img
                                                                src={img.url}
                                                                alt={img.name}
                                                                className="h-24 w-24 rounded border bg-gray-100 object-cover"
                                                            />
                                                            <Button
                                                                size="sm"
                                                                variant="destructive"
                                                                className="absolute top-1 right-1 opacity-80 group-hover:opacity-100"
                                                                onClick={() => handleRemoveExistingImage(img.url)}
                                                            >
                                                                ×
                                                            </Button>
                                                        </div>
                                                    ))}
                                            </div>
                                        </div>
                                    )}
                                </div>
                            </div>
                        </div>

                        <div className="rounded-lg border p-6">
                            <div className="mb-4 flex items-center justify-between">
                                <h2 className="text-xl font-semibold">{t('products.productInventory')}</h2>
                                <Button type="button" onClick={handleAddVariant} variant="outline" size="sm">
                                    <Plus className="mr-2 h-4 w-4" />
                                    {t('products.addVariant')}
                                </Button>
                            </div>
                            <div className="space-y-4">
                                {/* Variant Rows */}
                                {variants.map((variant, variantIndex) => (
                                    <div key={variantIndex} className="rounded-lg border p-3">
                                        <div className="grid grid-cols-12 gap-3 items-center">
                                            <div className="col-span-3">
                                                <label className="mb-1 block text-xs font-medium">{t('products.color')}</label>
                                                <Input
                                                    type="color"
                                                    value={variant.color || '#000000'}
                                                    onChange={(e) => handleVariantChange(variantIndex, 'color', e.target.value)}
                                                    className="h-9 w-full cursor-pointer"
                                                    title={t('products.selectColor')}
                                                />
                                            </div>
                                            <div className="col-span-9 flex items-center gap-2 justify-end">
                                                <Button
                                                    type="button"
                                                    variant="outline"
                                                    size="sm"
                                                    onClick={() => toggleSizeStock(variantIndex)}
                                                    className="h-9 px-3 text-xs"
                                                    title={t('products.toggleSizeStock')}
                                                >
                                                    {expandedVariants.has(variantIndex) ? '−' : '+'} {t('products.sizeStock')}
                                                </Button>
                                                {variants.length > 1 && (
                                                    <Button
                                                        type="button"
                                                        variant="destructive"
                                                        size="sm"
                                                        onClick={() => handleRemoveVariant(variantIndex)}
                                                        className="h-9 w-9 p-0"
                                                        title={t('products.removeVariant')}
                                                    >
                                                        <Trash2 className="h-4 w-4" />
                                                    </Button>
                                                )}
                                            </div>
                                        </div>
                                        {expandedVariants.has(variantIndex) && (
                                            <div className="mt-4 rounded-lg border p-4 dark:bg-gray-800/50">
                                                <div className="mb-3 flex items-center justify-between">
                                                    <span className="text-sm font-semibold">{t('products.sizeStockCombinations')}</span>
                                                    <Button
                                                        type="button"
                                                        variant="outline"
                                                        size="sm"
                                                        onClick={() => addSizeStockPair(variantIndex)}
                                                        className="h-8 px-3 text-xs"
                                                    >
                                                        <Plus className="mr-1 h-3 w-3" />
                                                        {t('products.addPair')}
                                                    </Button>
                                                </div>
                                                {variant.sizeStockPairs.length > 0 && (
                                                    <div className="mb-2 grid grid-cols-12 gap-2 px-2 text-xs font-semibold text-gray-600 dark:text-gray-400">
                                                        <div className="col-span-2">{t('products.size')}</div>
                                                        <div className="col-span-2">{t('products.stock')}</div>
                                                        <div className="col-span-2">
                                                            {t('products.price')} <span className="text-red-500">*</span>
                                                        </div>
                                                        <div className="col-span-2">{t('products.salePrice')}</div>
                                                    </div>
                                                )}
                                                <div className="space-y-2">
                                                    {variant.sizeStockPairs.map((pair, pairIndex) => (
                                                        <div key={pairIndex} className="grid grid-cols-12 gap-2 items-center">
                                                            <div className="col-span-2">
                                                                <Input
                                                                    placeholder={t('products.sizePlaceholder')}
                                                                    value={pair.size}
                                                                    onChange={(e) => handleSizeStockChange(variantIndex, pairIndex, 'size', e.target.value)}
                                                                    className="h-9 text-xs"
                                                                />
                                                            </div>
                                                            <div className="col-span-2">
                                                                <Input
                                                                    placeholder={t('products.stockQuantity')}
                                                                    type="number"
                                                                    min="0"
                                                                    value={pair.stock || ''}
                                                                    onChange={(e) => {
                                                                        let val = e.target.value;
                                                                        if (val.length > 1 && val.startsWith('0')) {
                                                                            val = val.replace(/^0+/, '');
                                                                        }
                                                                        handleSizeStockChange(variantIndex, pairIndex, 'stock', val === '' ? 0 : Number(val));
                                                                    }}
                                                                    className="h-9 text-xs"
                                                                />
                                                            </div>
                                                            <div className="col-span-2">
                                                                <Input
                                                                    placeholder={t('products.price')}
                                                                    type="number"
                                                                    min="0"
                                                                    step="0.01"
                                                                    value={pair.price || ''}
                                                                    onChange={(e) => {
                                                                        let val = e.target.value;
                                                                        if (val.length > 1 && val.startsWith('0')) {
                                                                            val = val.replace(/^0+/, '');
                                                                        }
                                                                        handleSizeStockChange(variantIndex, pairIndex, 'price', val === '' ? 0 : Number(val));
                                                                    }}
                                                                    className="h-9 text-xs"
                                                                />
                                                            </div>
                                                            <div className="col-span-2">
                                                                <Input
                                                                    placeholder={t('products.salePrice')}
                                                                    type="number"
                                                                    min="0"
                                                                    step="0.01"
                                                                    value={pair.sale_price || ''}
                                                                    onChange={(e) => {
                                                                        let val = e.target.value;
                                                                        if (val.length > 1 && val.startsWith('0')) {
                                                                            val = val.replace(/^0+/, '');
                                                                        }
                                                                        handleSizeStockChange(variantIndex, pairIndex, 'sale_price', val === '' ? 0 : Number(val));
                                                                    }}
                                                                    className="h-9 text-xs"
                                                                />
                                                            </div>
                                                            <div className="col-span-2 flex justify-start">
                                                                <Button
                                                                    type="button"
                                                                    variant="destructive"
                                                                    size="sm"
                                                                    onClick={() => removeSizeStockPair(variantIndex, pairIndex)}
                                                                    className="h-9 w-9 p-0"
                                                                    title={t('products.removeSizeStockPair')}
                                                                >
                                                                    <Trash2 className="h-4 w-4" />
                                                                </Button>
                                                            </div>
                                                        </div>
                                                    ))}
                                                    {variant.sizeStockPairs.length === 0 && (
                                                        <p className="text-xs text-gray-500 dark:text-gray-400 text-center py-4">
                                                            {t('products.noSizeStockPairsYet')}
                                                        </p>
                                                    )}
                                                </div>
                                            </div>
                                        )}
                                    </div>
                                ))}
                            </div>
                            {(errors as Record<string, string>).variants && (
                                <p className="mt-2 text-sm text-red-500">{(errors as Record<string, string>).variants}</p>
                            )}
                        </div>

                        <div className="flex justify-end gap-2">
                            <Button type="submit" disabled={processing}>
                                {processing ? t('products.updating') : t('products.updateProduct')}
                            </Button>
                            <Button
                                type="button"
                                variant="outline"
                                onClick={() => {
                                    const routeName = userRole === 'vendor' ? 'vendor.products.index' : 'products.index';
                                    router.visit(route(routeName));
                                }}
                            >
                                {t('common.cancel')}
                            </Button>
                        </div>
                    </form>
                </div>
            </div>
        </AppLayout>
    );
};

export default Edit;
