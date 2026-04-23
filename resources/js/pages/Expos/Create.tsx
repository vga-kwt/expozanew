import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select';
import AppLayout from '@/layouts/app-layout';
import { formatDate } from '@/utils/formatDate';
import { Head, router, useForm } from '@inertiajs/react';
import { Plus } from 'lucide-react';
import React, { useEffect, useState } from 'react';
import { toast } from 'react-hot-toast';
import ReactQuill from 'react-quill';
import 'react-quill/dist/quill.snow.css';

const CreateExpo = () => {
    const { data, setData, post, processing, errors } = useForm({
        name_en: '',
        name_ar: '',
        description_en: '',
        description_ar: '',
        background_color: '#ffffff',
        background_image: null as File | null,
        font_family: 'Arial',
        font_style: 'normal',
        font_size: '16',
        font_color: '#ffffff',
        font_weight: '400',
        banner_image: null as File | null,
        start_date: '',
        end_date: '',
        status: 'upcoming',
        vendor_slot_capacity: '',
        product_capacity_per_slot: '',
        slot_pricing: '', // This can be a JSON string or handled as needed
        free_participation: false,
    });

    const [pricingMode, setPricingMode] = useState<'per_slot' | 'slot_range'>('per_slot');
    const [perSlot, setPerSlot] = useState([{ slot: 1, price: '' }]);
    const [slotRanges, setSlotRanges] = useState([{ from: 1, to: 1, price: '' }]);

    // Sync to data.slot_pricing as JSON string
    useEffect(() => {
        if (pricingMode === 'per_slot') {
            setData('slot_pricing', JSON.stringify(perSlot));
        } else {
            setData('slot_pricing', JSON.stringify(slotRanges));
        }
    }, [pricingMode, perSlot, slotRanges]);

    const onSubmit = (e: React.FormEvent) => {
        e.preventDefault();
        post(route('expos.store'), {
            forceFormData: true,
            onSuccess: () => {
                toast.success('Expo created successfully!');
                router.visit(route('expos.index'));
            },
            onError: () => toast.error("Please fill mandatory details to create the expo."),
        });
    };

    return (
        <AppLayout>
            <Head title="Create Expo" />
            <div className="p-8">
                <h1 className="mb-6 border-b pb-4 text-3xl font-bold">Create Expo</h1>
                <div className="grid min-h-[80vh] grid-cols-1 gap-8 lg:grid-cols-2">
                    {/* Left: Form */}
                    <form onSubmit={onSubmit} className="space-y-6">
                        <div className="grid grid-cols-1 gap-4 md:grid-cols-2">
                            <div>
                                <Label htmlFor="name_en">Expo Name (EN) <span className='text-red-500'>*</span></Label>
                                <Input id="name_en" name="name_en" value={data.name_en} onChange={(e) => setData('name_en', e.target.value)} />
                                {errors.name_en && <div className="mt-1 text-xs text-red-500">{errors.name_en}</div>}
                            </div>
                            <div>
                                <Label htmlFor="name_ar">Expo Name (AR) <span className='text-red-500'>*</span></Label>
                                <Input
                                    id="name_ar"
                                    name="name_ar"
                                    value={data.name_ar}
                                    onChange={(e) => setData('name_ar', e.target.value)}
                                    dir="rtl"
                                />
                                {errors.name_ar && <div className="mt-1 text-xs text-red-500">{errors.name_ar}</div>}
                            </div>
                        </div>
                        <div className="grid grid-cols-1 gap-4 md:grid-cols-2">
                            <div className="h-[250px]">
                                <Label htmlFor="description_en">Description (EN)</Label>
                                <ReactQuill
                                    value={data.description_en}
                                    onChange={(value) => setData('description_en', value)}
                                    theme="snow"
                                    style={{ height: '180px' }}
                                />
                                {errors.description_en && <div className="mt-1 text-xs text-red-500">{errors.description_en}</div>}
                            </div>
                            <div className="h-[250px]">
                                <Label htmlFor="description_ar">Description (AR)</Label>
                                <ReactQuill
                                    value={data.description_ar}
                                    onChange={(value) => setData('description_ar', value)}
                                    theme="snow"
                                    style={{ height: '180px' }}
                                />
                                {errors.description_ar && <div className="mt-1 text-xs text-red-500">{errors.description_ar}</div>}
                            </div>
                        </div>
                        <div className="grid grid-cols-1 gap-4 md:grid-cols-2">
                            <div>
                                <Label htmlFor="background_color">Background Color</Label>
                                <Input
                                    id="background_color"
                                    type="color"
                                    name="background_color"
                                    value={data.background_color}
                                    onChange={(e) => setData('background_color', e.target.value)}
                                    className="p-1"
                                />
                                {errors.background_color && <div className="mt-1 text-xs text-red-500">{errors.background_color}</div>}
                            </div>
                            <div>
                                <Label htmlFor="background_image">Background Image</Label>
                                <Input
                                    id="background_image"
                                    type="file"
                                    name="background_image"
                                    onChange={(e) => setData('background_image', e.target.files && e.target.files[0] ? e.target.files[0] : null)}
                                    accept="image/*"
                                />
                                {errors.background_image && <div className="mt-1 text-xs text-red-500">{errors.background_image}</div>}
                            </div>
                        </div>
                        <div className="grid grid-cols-1 gap-4 md:grid-cols-2">
                            <div>
                                <Label htmlFor="banner_image">Banner Image</Label>
                                <Input
                                    id="banner_image"
                                    type="file"
                                    name="banner_image"
                                    onChange={(e) => setData('banner_image', e.target.files && e.target.files[0] ? e.target.files[0] : null)}
                                    accept="image/*"
                                />
                                {errors.banner_image && <div className="mt-1 text-xs text-red-500">{errors.banner_image}</div>}
                            </div>
                            <div>
                                <Label htmlFor="status">Status</Label>
                                <Select value={data.status} onValueChange={(value) => setData('status', value)}>
                                    <SelectTrigger>
                                        <SelectValue placeholder="Select status" />
                                    </SelectTrigger>
                                    <SelectContent>
                                        <SelectItem value="upcoming">Upcoming</SelectItem>
                                        <SelectItem value="active">Active</SelectItem>
                                        <SelectItem value="inactive">Inactive</SelectItem>
                                        <SelectItem value="suspended">Suspended</SelectItem>
                                        <SelectItem value="expired">Expired</SelectItem>
                                    </SelectContent>
                                </Select>
                                {errors.status && <div className="mt-1 text-xs text-red-500">{errors.status}</div>}
                            </div>
                        </div>
                        <div className="grid grid-cols-1 gap-4 md:grid-cols-2">
                            <div>
                                <Label htmlFor="font_family">Font Family</Label>
                                <Input
                                    id="font_family"
                                    name="font_family"
                                    value={data.font_family}
                                    onChange={(e) => setData('font_family', e.target.value)}
                                />
                                {errors.font_family && <div className="mt-1 text-xs text-red-500">{errors.font_family}</div>}
                            </div>
                            <div>
                                <Label htmlFor="font_style">Font Style</Label>
                                <Select value={data.font_style} onValueChange={(value) => setData('font_style', value)} name="font_style">
                                    <SelectTrigger id="font_style" className="w-full rounded border px-2 py-2">
                                        <SelectValue placeholder="Select font style" />
                                    </SelectTrigger>
                                    <SelectContent>
                                        <SelectItem value="normal">Normal</SelectItem>
                                        <SelectItem value="italic">Italic</SelectItem>
                                    </SelectContent>
                                </Select>
                                {errors.font_style && <div className="mt-1 text-xs text-red-500">{errors.font_style}</div>}
                            </div>
                        </div>
                        <div className="grid grid-cols-1 gap-4 md:grid-cols-3">
                            <div>
                                <Label htmlFor="font_size">Font Size (px)</Label>
                                <Input
                                    id="font_size"
                                    name="font_size"
                                    value={data.font_size}
                                    onChange={(e) => setData('font_size', e.target.value)}
                                />
                                {errors.font_size && <div className="mt-1 text-xs text-red-500">{errors.font_size}</div>}
                            </div>
                            <div>
                                <Label htmlFor="font_weight">Font Weight</Label>
                                <Select value={data.font_weight} onValueChange={(value) => setData('font_weight', value)} name="font_weight">
                                    <SelectTrigger id="font_weight" className="w-full rounded border px-2 py-2">
                                        <SelectValue placeholder="Select font weight" />
                                    </SelectTrigger>
                                    <SelectContent>
                                        {[100, 200, 300, 400, 500, 600, 700, 800, 900].map((w) => (
                                            <SelectItem key={w} value={w.toString()}>
                                                {w}
                                            </SelectItem>
                                        ))}
                                    </SelectContent>
                                </Select>
                                {errors.font_weight && <div className="mt-1 text-xs text-red-500">{errors.font_weight}</div>}
                            </div>
                            <div>
                                <Label htmlFor="font_color">Font Color</Label>
                                <Input
                                    id="font_color"
                                    type="color"
                                    name="font_color"
                                    value={data.font_color}
                                    onChange={(e) => setData('font_color', e.target.value)}
                                    className="p-1"
                                />
                                {errors.font_color && <div className="mt-1 text-xs text-red-500">{errors.font_color}</div>}
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
                                    onChange={(e) => setData('start_date', e.target.value)}
                                    min={new Date().toISOString().slice(0, 16)}
                                />

                                {errors.start_date && <div className="mt-1 text-xs text-red-500">{errors.start_date}</div>}
                            </div>
                            <div>
                                <Label htmlFor="end_date">End Date & Time <span className='text-red-500'>*</span></Label>
                                <Input
                                    id="end_date"
                                    type="datetime-local"
                                    name="end_date"
                                    value={data.end_date}
                                    min={data.start_date || undefined} // yahan start_date ka value set karo
                                    onChange={(e) => setData('end_date', e.target.value)}
                                />
                                {errors.end_date && <div className="mt-1 text-xs text-red-500">{errors.end_date}</div>}
                            </div>
                        </div>
                        <div className="grid grid-cols-1 gap-4 md:grid-cols-2">
                            <div>
                                <Label htmlFor="vendor_slot_capacity">Vendor Slot Capacity <span className='text-red-500'>*</span></Label>
                                <Input
                                    id="vendor_slot_capacity"
                                    type="number"
                                    name="vendor_slot_capacity"
                                    value={data.vendor_slot_capacity}
                                    onChange={(e) => setData('vendor_slot_capacity', e.target.value)}
                                />
                                {errors.vendor_slot_capacity && <div className="mt-1 text-xs text-red-500">{errors.vendor_slot_capacity}</div>}
                            </div>
                            <div>
                                <Label htmlFor="product_capacity_per_slot">Product Capacity Per Slot <span className='text-red-500'>*</span></Label>
                                <Input
                                    id="product_capacity_per_slot"
                                    type="number"
                                    name="product_capacity_per_slot"
                                    value={data.product_capacity_per_slot}
                                    onChange={(e) => setData('product_capacity_per_slot', e.target.value)}
                                />
                                {errors.product_capacity_per_slot && (
                                    <div className="mt-1 text-xs text-red-500">{errors.product_capacity_per_slot}</div>
                                )}
                            </div>
                        </div>
                        <div>
                            <Label>Slot Pricing (KWD)</Label>
                            <div className="mb-2 flex gap-4">
                                <label className="flex items-center gap-1">
                                    <input
                                        type="radio"
                                        name="pricingMode"
                                        value="per_slot"
                                        checked={pricingMode === 'per_slot'}
                                        onChange={() => setPricingMode('per_slot')}
                                    />
                                    Per Slot
                                </label>
                                <label className="flex items-center gap-1">
                                    <input
                                        type="radio"
                                        name="pricingMode"
                                        value="slot_range"
                                        checked={pricingMode === 'slot_range'}
                                        onChange={() => setPricingMode('slot_range')}
                                    />
                                    Slot Range
                                </label>
                            </div>

                            {pricingMode === 'per_slot' ? (
                                <div className="space-y-2">
                                    {perSlot.map((item, idx) => (
                                        <div key={idx} className="flex items-center gap-2">
                                            <Input
                                                type="number"
                                                min={1}
                                                value={item.slot}
                                                onChange={(e) => {
                                                    const val = parseInt(e.target.value, 10);
                                                    setPerSlot(perSlot.map((s, i) => (i === idx ? { ...s, slot: val } : s)));
                                                }}
                                                className="w-20"
                                                placeholder="Slot #"
                                            />
                                            <Input
                                                type="number"
                                                min={0}
                                                value={item.price}
                                                onChange={(e) => {
                                                    setPerSlot(perSlot.map((s, i) => (i === idx ? { ...s, price: e.target.value } : s)));
                                                }}
                                                className="w-32"
                                                placeholder="Price (KWD)"
                                            />
                                            {perSlot.length > 1 && (
                                                <Button
                                                    variant="destructive"
                                                    size="icon"
                                                    onClick={() => setPerSlot(perSlot.filter((_, i) => i !== idx))}
                                                >
                                                    ×
                                                </Button>
                                            )}
                                        </div>
                                    ))}
                                    <Button
                                        type="button"
                                        variant="outline"
                                        size="sm"
                                        className="mt-1"
                                        onClick={() => setPerSlot([...perSlot, { slot: perSlot.length + 1, price: '' }])}
                                    >
                                        <Plus className="mr-1 h-4 w-4" /> Add Another Slot
                                    </Button>
                                </div>
                            ) : (
                                <div className="space-y-2">
                                    {slotRanges.map((item, idx) => (
                                        <div key={idx} className="flex items-center gap-2">
                                            <Input
                                                type="number"
                                                min={1}
                                                value={item.from}
                                                onChange={(e) => {
                                                    const val = parseInt(e.target.value, 10);
                                                    setSlotRanges(slotRanges.map((r, i) => (i === idx ? { ...r, from: val } : r)));
                                                }}
                                                className="w-20"
                                                placeholder="From"
                                            />
                                            <span>–</span>
                                            <Input
                                                type="number"
                                                min={item.from}
                                                value={item.to}
                                                onChange={(e) => {
                                                    const val = parseInt(e.target.value, 10);
                                                    setSlotRanges(slotRanges.map((r, i) => (i === idx ? { ...r, to: val } : r)));
                                                }}
                                                className="w-20"
                                                placeholder="To"
                                            />
                                            <Input
                                                type="number"
                                                min={0}
                                                value={item.price}
                                                onChange={(e) => {
                                                    setSlotRanges(slotRanges.map((r, i) => (i === idx ? { ...r, price: e.target.value } : r)));
                                                }}
                                                className="w-32"
                                                placeholder="Price (KWD)"
                                            />
                                            {slotRanges.length > 1 && (
                                                <Button
                                                    variant="destructive"
                                                    size="icon"
                                                    onClick={() => setSlotRanges(slotRanges.filter((_, i) => i !== idx))}
                                                >
                                                    ×
                                                </Button>
                                            )}
                                        </div>
                                    ))}
                                    <Button
                                        type="button"
                                        variant="outline"
                                        size="sm"
                                        className="mt-1"
                                        onClick={() =>
                                            setSlotRanges([
                                                ...slotRanges,
                                                {
                                                    from: slotRanges[slotRanges.length - 1]?.to + 1 || 1,
                                                    to: slotRanges[slotRanges.length - 1]?.to + 1 || 1,
                                                    price: '',
                                                },
                                            ])
                                        }
                                    >
                                        <Plus className="mr-1 h-4 w-4" /> Add Another Range
                                    </Button>
                                </div>
                            )}
                            <Input
                                id="slot_pricing"
                                hidden
                                name="slot_pricing"
                                value={data.slot_pricing}
                                onChange={(e) => setData('slot_pricing', e.target.value)}
                                className="mt-2"
                                placeholder='e.g. [{"slot":1,"price":100}] or [{"from":1,"to":5,"price":100}]'
                                readOnly
                            />
                            {errors.slot_pricing && <div className="mt-1 text-xs text-red-500">{errors.slot_pricing}</div>}
                        </div>
                        <div className="flex items-center gap-2">
                            <input
                                type="checkbox"
                                id="free_participation"
                                name="free_participation"
                                checked={data.free_participation}
                                onChange={(e) => setData('free_participation', e.target.checked)}
                                className="h-4 w-4 rounded border-gray-300 text-primary focus:ring-primary"
                            />
                            <Label htmlFor="free_participation" className="cursor-pointer">
                                Free Participation
                            </Label>
                            {errors.free_participation && <div className="mt-1 text-xs text-red-500">{errors.free_participation}</div>}
                        </div>
                        <div className="flex justify-end gap-2">
                            <Button type="submit" disabled={processing}>
                                Create Expo
                            </Button>
                            <Button type="button" variant="outline" onClick={() => router.visit(route('expos.index'))}>
                                Cancel
                            </Button>
                        </div>
                    </form>

                    {/* Right: Preview */}
                    <div className="flex h-full w-full flex-col items-center justify-center">
                        <div
                            className="relative flex h-[350px] w-full max-w-xl items-center justify-center overflow-hidden rounded-2xl bg-blue-600 shadow-lg"
                            style={{
                                background: data.background_color || '#2563eb',
                            }}
                        >
                            {/* Background Image */}
                            {data.background_image && (
                                <img
                                    src={
                                        typeof data.background_image === 'string' ? data.background_image : URL.createObjectURL(data.background_image)
                                    }
                                    alt="Background"
                                    className="absolute inset-0 h-full w-full object-cover"
                                />
                            )}

                            {/* Overlay for text */}
                            <div className="absolute inset-0 flex flex-col items-center justify-center bg-black/40 px-4">
                                <div className="mb-2 text-center">
                                    <div
                                        className="mb-1"
                                        dir="rtl"
                                        style={{
                                            fontFamily: data.font_family,
                                            fontStyle: data.font_style,
                                            fontSize: data.font_size
                                                ? data.font_size.match(/px$/)
                                                    ? data.font_size
                                                    : `${data.font_size}px`
                                                : '16px',
                                            fontWeight: data.font_weight ? (isNaN(Number(data.font_weight)) ? 400 : Number(data.font_weight)) : 400,
                                            color: data.font_color || 'white',
                                        }}
                                    >
                                        {data.name_ar || 'اسم المعرض'}
                                    </div>
                                    <div
                                        style={{
                                            fontFamily: data.font_family,
                                            fontStyle: data.font_style,
                                            fontSize: data.font_size
                                                ? data.font_size.match(/px$/)
                                                    ? data.font_size
                                                    : `${data.font_size}px`
                                                : '16px',
                                            fontWeight: data.font_weight ? (isNaN(Number(data.font_weight)) ? 400 : Number(data.font_weight)) : 400,
                                            color: data.font_color || 'white',
                                        }}
                                    >
                                        {data.name_en || 'Expo name'}
                                    </div>
                                </div>
                                <div className="flex items-center gap-2 rounded-full bg-white/80 px-3 py-1 text-xs font-medium text-gray-800 shadow">
                                    <span>
                                        Starts In:{' '}
                                        <span className="font-bold text-blue-900">{data.start_date ? formatDate(data.start_date) : '--'}</span>
                                    </span>
                                    <span>
                                        Ends In: <span className="font-bold text-blue-900">{data.end_date ? formatDate(data.end_date) : '--'}</span>
                                    </span>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </AppLayout>
    );
};

export default CreateExpo;
