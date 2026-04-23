import React, { useState, useEffect } from 'react';
import { useForm, router, Head } from '@inertiajs/react';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select';
import { toast } from 'react-hot-toast';
import AppLayout from '@/layouts/app-layout';
import ReactQuillWrapper from '@/components/ReactQuillWrapper';
import { Plus } from 'lucide-react';
import dayjs from 'dayjs';


interface Expo {
    id: number;
    name_en: string;
    name_ar: string;
    description_en: string;
    description_ar: string;
    background_color: string;
    background_image: string | null;
    font_family: string;
    font_style: string;
    font_size: string;
    font_color: string;
    font_weight: string;
    banner_image: string | null;
    start_date: string;
    end_date: string;
    slot_pricing: string;
    vendor_slot_capacity: string;
    product_capacity_per_slot: string;
    status: string;
}

interface EditExpoProps {
    expo: Expo;
}

const formatDate = (dateStr: string) => {
    if (!dateStr) return '';
    // If already in correct format, return as is
    if (dateStr.includes('T')) return dateStr.slice(0, 16);
    // If only date, append time
    if (/^\d{4}-\d{2}-\d{2}$/.test(dateStr)) return dateStr + 'T00:00';
    return dateStr;
};

const EditExpo = ({ expo }: EditExpoProps) => {
    const { data, setData, processing, errors } = useForm({
        name_en: expo.name_en || '',
        name_ar: expo.name_ar || '',
        description_en: expo.description_en || '',
        description_ar: expo.description_ar || '',
        background_color: expo.background_color || '#ffffff',
        background_image: null as File | null,
        font_family: expo.font_family || 'Arial',
        font_style: expo.font_style || 'normal',
        font_size: expo.font_size || '16',
        font_color: expo.font_color || '#ffffff',
        font_weight: expo.font_weight || '400',
        banner_image: null as File | null,
        start_date: formatDate(expo.start_date),
        end_date: formatDate(expo.end_date),
        slot_pricing: typeof expo.slot_pricing === 'string' ? expo.slot_pricing : JSON.stringify(expo.slot_pricing || []),
        vendor_slot_capacity: expo.vendor_slot_capacity || '',
        product_capacity_per_slot: expo.product_capacity_per_slot || '',
        status: expo.status || 'active',
        free_participation: (expo as any).free_participation || false,
        _method: 'PUT', // For Laravel to recognize as PUT
    });

    const [pricingMode, setPricingMode] = useState<'per_slot' | 'slot_range'>(() => {
            const parsed = JSON.parse(data.slot_pricing || '[]');
            if (Array.isArray(parsed) && parsed[0]?.slot !== undefined) return 'per_slot';
            if (Array.isArray(parsed) && parsed[0]?.from !== undefined) return 'slot_range';
        return 'per_slot';
    });
    const [perSlot, setPerSlot] = useState(() => {
            const parsed = JSON.parse(data.slot_pricing || '[]');
            if (Array.isArray(parsed) && parsed[0]?.slot !== undefined) return parsed;
        return [{ slot: 1, price: '' }];
    });
    const [slotRanges, setSlotRanges] = useState(() => {
            const parsed = JSON.parse(data.slot_pricing || '[]');
            if (Array.isArray(parsed) && parsed[0]?.from !== undefined) return parsed;
        return [{ from: 1, to: 1, price: '' }];
    });

    useEffect(() => {
        if (pricingMode === 'per_slot') {
            setData('slot_pricing', JSON.stringify(perSlot));
        } else {
            setData('slot_pricing', JSON.stringify(slotRanges));
        }
    }, [pricingMode, perSlot, slotRanges]);

    const onSubmit = (e: React.FormEvent) => {
        e.preventDefault();

        const formData = new FormData();
        Object.entries(data).forEach(([key, value]) => {
            // For file fields, only append if a new file is selected
            if ((key === 'background_image' || key === 'banner_image')) {
                if (value instanceof File) {
                    formData.append(key, value);
                }
            } else if (key === 'free_participation') {
                // Convert boolean to string that Laravel accepts: "1" for true, "0" for false
                formData.append(key, value ? '1' : '0');
            } else if (value !== null && value !== undefined) {
                formData.append(key, value as string);
            }
        });

        // Use Inertia router directly for FormData (bypassing useForm's put)
        router.post(route('expos.update', expo.id), formData, {
            forceFormData: true,
            onSuccess: () => {
                toast.success('Expo updated successfully!');
                router.visit(route('expos.index'));
            },
            onError: () => toast.error('Failed to update expo.'),
        });
    };

    return (
        <AppLayout>
            <Head title="Edit Expo" />
            <div className="p-8">
                <h1 className="text-3xl font-bold mb-6 border-b pb-4">Edit Expo</h1>
                <div className="grid grid-cols-1 lg:grid-cols-2 gap-8 min-h-[80vh]">
                    {/* Left: Form */}
                    <form onSubmit={onSubmit} className="space-y-6 ">
                        {/* Expo Name Fields */}
                        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                            <div>
                                <Label htmlFor="name_en">Expo Name (EN)</Label>
                                <Input id="name_en" name="name_en" value={data.name_en} onChange={e => setData('name_en', e.target.value)} />
                                {errors.name_en && <div className="text-red-500 text-xs mt-1">{errors.name_en}</div>}
                            </div>
                            <div>
                                <Label htmlFor="name_ar">Expo Name (AR)</Label>
                                <Input id="name_ar" name="name_ar" value={data.name_ar} onChange={e => setData('name_ar', e.target.value)} dir="rtl" />
                                {errors.name_ar && <div className="text-red-500 text-xs mt-1">{errors.name_ar}</div>}
                            </div>
                        </div>

                        {/* Description Fields */}
                        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                            <div className="h-[250px]">
                                <Label htmlFor="description_en">Description (EN)</Label>
                                <ReactQuillWrapper
                                    value={data.description_en}
                                    onChange={value => setData('description_en', value)}
                                    theme="snow"
                                    style={{ height: "180px" }}
                                />
                                {errors.description_en && <div className="text-red-000 text-xs mt-1">{errors.description_en}</div>}
                            </div>
                            <div className="h-[250px]">
                                <Label htmlFor="description_ar">Description (AR)</Label>
                                <div dir="rtl">
                                    <ReactQuillWrapper
                                        value={data.description_ar}
                                        onChange={value => setData('description_ar', value)}
                                        theme="snow"
                                        style={{ height: "180px" }}
                                    />
                                </div>
                                {errors.description_ar && <div className="text-red-000 text-xs mt-1">{errors.description_ar}</div>}
                            </div>
                        </div>

                        {/* Background Color + Background Image */}
                        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                            <div>
                                <Label htmlFor="background_color">Background Color</Label>
                                <Input id="background_color" type="color" name="background_color" value={data.background_color} onChange={e => setData('background_color', e.target.value)} className="p-1" />
                                {errors.background_color && <div className="text-red-500 text-xs mt-1">{errors.background_color}</div>}
                            </div>
                            <div>
                                <Label htmlFor="background_image">Background Image</Label>
                                <Input id="background_image" type="file" name="background_image" onChange={e => setData('background_image', e.target.files && e.target.files[0] ? e.target.files[0] : null)} accept="image/*" />
                                {errors.background_image && <div className="text-red-500 text-xs mt-1">{errors.background_image}</div>}
                                {expo.background_image && (
                                    <img src={expo.background_image} alt="Current Background" className="w-32 h-16 object-cover mt-2 rounded" />
                                )}
                            </div>
                        </div>

                        {/* Banner Image + Status */}
                        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                            <div>
                                <Label htmlFor="banner_image">Banner Image</Label>
                                <Input id="banner_image" type="file" name="banner_image" onChange={e => setData('banner_image', e.target.files && e.target.files[0] ? e.target.files[0] : null)} accept="image/*" />
                                {errors.banner_image && <div className="text-red-500 text-xs mt-1">{errors.banner_image}</div>}
                                {expo.banner_image && (
                                    <img src={expo.banner_image} alt="Current Banner" className="w-32 h-16 object-cover mt-2 rounded" />
                                )}
                            </div>
                            <div>
                                <Label>Status</Label>
                                <Select value={data.status} onValueChange={value => setData('status', value)}>
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
                                {errors.status && <div className="text-red-500 text-xs mt-1">{errors.status}</div>}
                            </div>
                        </div>

                        {/* Font Family + Font Style */}
                        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                            <div>
                                <Label htmlFor="font_family">Font Family</Label>
                                <Input id="font_family" name="font_family" value={data.font_family} onChange={e => setData('font_family', e.target.value)} />
                                {errors.font_family && <div className="text-red-500 text-xs mt-1">{errors.font_family}</div>}
                            </div>
                            <div>
                                <Label htmlFor="font_style">Font Style</Label>
                                <Select value={data.font_style} onValueChange={value => setData('font_style', value)} name="font_style">
                                    <SelectTrigger id="font_style" className="w-full border rounded px-2 py-2">
                                        <SelectValue>
                                            {data.font_style === "normal"
                                                ? "Normal"
                                                : data.font_style === "italic"
                                                    ? "Italic"
                                                    : "Select font style"}
                                        </SelectValue>
                                    </SelectTrigger>
                                    <SelectContent>
                                        <SelectItem value="normal">Normal</SelectItem>
                                        <SelectItem value="italic">Italic</SelectItem>
                                    </SelectContent>
                                </Select>
                                {errors.font_style && <div className="text-red-500 text-xs mt-1">{errors.font_style}</div>}
                            </div>
                        </div>

                        {/* Font Size + Font Weight + Font Color */}
                        <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                            <div>
                                <Label htmlFor="font_size">Font Size (px)</Label>
                                <Input id="font_size" name="font_size" value={data.font_size} onChange={e => setData('font_size', e.target.value)} />
                                {errors.font_size && <div className="text-red-500 text-xs mt-1">{errors.font_size}</div>}
                            </div>
                            <div>
                                <Label htmlFor="font_weight">Font Weight</Label>
                                <Select value={data.font_weight} onValueChange={value => setData('font_weight', value)} name="font_weight">
                                    <SelectTrigger id="font_weight" className="w-full border rounded px-2 py-2">
                                        <SelectValue>
                                            {data.font_weight
                                                ? [100, 200, 300, 400, 500, 600, 700, 800, 900].includes(Number(data.font_weight))
                                                    ? data.font_weight
                                                    : "Select font weight"
                                                : "Select font weight"}
                                        </SelectValue>
                                    </SelectTrigger>
                                    <SelectContent>
                                        {[100, 200, 300, 400, 500, 600, 700, 800, 900].map(w => (
                                            <SelectItem key={w} value={w.toString()}>{w}</SelectItem>
                                        ))}
                                    </SelectContent>
                                </Select>
                                {errors.font_weight && <div className="text-red-500 text-xs mt-1">{errors.font_weight}</div>}
                            </div>
                            <div>
                                <Label htmlFor="font_color">Font Color</Label>
                                <Input id="font_color" type="color" name="font_color" value={data.font_color} onChange={e => setData('font_color', e.target.value)} className="p-1" />
                                {errors.font_color && <div className="text-red-500 text-xs mt-1">{errors.font_color}</div>}
                            </div>
                        </div>

                        {/* Start Date & End Date */}
                        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                            <div>
                                <Label htmlFor="start_date">Start Date & Time</Label>
                                <Input
                                    id="start_date"
                                    type="datetime-local"
                                    name="start_date"
                                    value={data.start_date ? data.start_date.slice(0, 16) : ''}
                                    onChange={e => setData('start_date', e.target.value)}
                                    min={new Date().toISOString().slice(0, 16)}
                                />
                                {errors.start_date && <div className="text-red-500 text-xs mt-1">{errors.start_date}</div>}
                            </div>
                            <div>
                                <Label htmlFor="end_date">End Date & Time</Label>
                                <Input
                                    id="end_date"
                                    type="datetime-local"
                                    name="end_date"
                                    value={data.end_date ? data.end_date.slice(0, 16) : ''}
                                    min={data.start_date ? data.start_date.slice(0, 16) : undefined}
                                    onChange={e => setData('end_date', e.target.value)}
                                />
                                {errors.end_date && <div className="text-red-500 text-xs mt-1">{errors.end_date}</div>}
                            </div>
                        </div>

                        {/* Slot Pricing + Vendor Slot Capacity */}
                        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                            <div>
                                <Label>Slot Pricing (KWD)</Label>
                                <div className="flex gap-4 mb-2">
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
                                                    onChange={e => {
                                                        const val = parseInt(e.target.value, 10);
                                                        setPerSlot(perSlot.map((s, i) => i === idx ? { ...s, slot: val } : s));
                                                    }}
                                                    className="w-20"
                                                    placeholder="Slot #"
                                                />
                                                <Input
                                                    type="number"
                                                    min={0}
                                                    value={item.price}
                                                    onChange={e => {
                                                        setPerSlot(perSlot.map((s, i) => i === idx ? { ...s, price: e.target.value } : s));
                                                    }}
                                                    className="w-32"
                                                placeholder="Price (KWD)"
                                                />
                                                {perSlot.length > 1 && (
                                                    <Button variant="destructive" size="icon" onClick={() => setPerSlot(perSlot.filter((_, i) => i !== idx))}>×</Button>
                                                )}
                                            </div>
                                        ))}
                                        <Button type="button" variant="outline" size="sm" className="mt-1" onClick={() => setPerSlot([...perSlot, { slot: perSlot.length + 1, price: '' }])}>
                                            <Plus className="w-4 h-4 mr-1" /> Add Another Slot
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
                                                    onChange={e => {
                                                        const val = parseInt(e.target.value, 10);
                                                        setSlotRanges(slotRanges.map((r, i) => i === idx ? { ...r, from: val } : r));
                                                    }}
                                                    className="w-20"
                                                    placeholder="From"
                                                />
                                                <span>–</span>
                                                <Input
                                                    type="number"
                                                    min={item.from}
                                                    value={item.to}
                                                    onChange={e => {
                                                        const val = parseInt(e.target.value, 10);
                                                        setSlotRanges(slotRanges.map((r, i) => i === idx ? { ...r, to: val } : r));
                                                    }}
                                                    className="w-20"
                                                    placeholder="To"
                                                />
                                                <Input
                                                    type="number"
                                                    min={0}
                                                    value={item.price}
                                                    onChange={e => {
                                                        setSlotRanges(slotRanges.map((r, i) => i === idx ? { ...r, price: e.target.value } : r));
                                                    }}
                                                    className="w-32"
                                                placeholder="Price (KWD)"
                                                />
                                                {slotRanges.length > 1 && (
                                                    <Button variant="destructive" size="icon" onClick={() => setSlotRanges(slotRanges.filter((_, i) => i !== idx))}>×</Button>
                                                )}
                                            </div>
                                        ))}
                                        <Button type="button" variant="outline" size="sm" className="mt-1" onClick={() => setSlotRanges([...slotRanges, { from: slotRanges[slotRanges.length - 1]?.to + 1 || 1, to: (slotRanges[slotRanges.length - 1]?.to + 1 || 1), price: '' }])}>
                                            <Plus className="w-4 h-4 mr-1" /> Add Another Range
                                        </Button>
                                    </div>
                                )}
                                <Input id="slot_pricing" hidden name="slot_pricing" value={data.slot_pricing} onChange={e => setData('slot_pricing', e.target.value)} className="mt-2" placeholder='e.g. [{"slot":1,"price":100}] or [{"from":1,"to":5,"price":100}]' readOnly />
                                {errors.slot_pricing && <div className="text-red-500 text-xs mt-1">{errors.slot_pricing}</div>}
                            </div>
                            <div>
                                <Label htmlFor="vendor_slot_capacity">Vendor Slot Capacity</Label>
                                <Input id="vendor_slot_capacity" type="number" name="vendor_slot_capacity" value={data.vendor_slot_capacity} onChange={e => setData('vendor_slot_capacity', e.target.value)} />
                                {errors.vendor_slot_capacity && <div className="text-red-500 text-xs mt-1">{errors.vendor_slot_capacity}</div>}
                            </div>
                        </div>

                        {/* Product Capacity Per Slot (full width) */}
                        <div>
                            <Label htmlFor="product_capacity_per_slot">Product Capacity Per Slot</Label>
                            <Input id="product_capacity_per_slot" type="number" name="product_capacity_per_slot" value={data.product_capacity_per_slot} onChange={e => setData('product_capacity_per_slot', e.target.value)} />
                            {errors.product_capacity_per_slot && <div className="text-red-500 text-xs mt-1">{errors.product_capacity_per_slot}</div>}
                        </div>

                        {/* Free Participation Checkbox */}
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
                            {errors.free_participation && <div className="text-red-500 text-xs mt-1">{errors.free_participation}</div>}
                        </div>

                        {/* Form Actions */}
                        <div className="flex justify-end gap-2">
                            <Button type="submit" disabled={processing}>Update Expo</Button>
                            <Button type="button" variant="outline" onClick={() => router.visit(route('expos.index'))}>Cancel</Button>
                        </div>
                    </form>

                    {/* Right: Preview */}
                    <div className="flex flex-col justify-center items-center w-full h-full">
                        <div
                            className="w-full max-w-xl h-[350px] rounded-2xl overflow-hidden shadow-lg bg-blue-600 flex items-center justify-center relative"
                            style={{
                                background: data.background_color || "#2563eb",
                            }}
                        >
                            {/* Background Image */}
                            {data.background_image
                                ? (
                                    typeof data.background_image === 'string'
                                        ? <img
                                            src={expo.background_image || ''}
                                            alt="Background"
                                            className="absolute inset-0 w-full h-full object-cover"
                                        />
                                        : <img
                                            src={URL.createObjectURL(data.background_image as File)}
                                            alt="Background"
                                            className="absolute inset-0 w-full h-full object-cover"
                                        />
                                )
                                : (expo.background_image && (
                                    <img
                                        src={expo.background_image}
                                        alt="Background"
                                        className="absolute inset-0 w-full h-full object-cover"
                                    />
                                ))
                            }

                            {/* Overlay for text */}
                            <div className="absolute inset-0 bg-black/40 flex flex-col justify-center items-center px-4">
                                <div className="text-center mb-2">
                                    <div
                                        className="mb-1"
                                        dir="rtl"
                                        style={{
                                            fontFamily: data.font_family,
                                            fontStyle: data.font_style,
                                            fontSize: data.font_size ? (data.font_size.match(/px$/) ? data.font_size : `${data.font_size}px`) : '16px',
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
                                            fontSize: data.font_size ? (data.font_size.match(/px$/) ? data.font_size : `${data.font_size}px`) : '16px',
                                            fontWeight: data.font_weight ? (isNaN(Number(data.font_weight)) ? 400 : Number(data.font_weight)) : 400,
                                            color: data.font_color || 'white',
                                        }}
                                    >
                                        {data.name_en || 'Expo name'}
                                    </div>
                                </div>
                                {/* Info Chip */}
                                <div className="flex items-center gap-2 bg-white/80 px-3 py-1 rounded-full text-xs font-medium text-gray-800 shadow">
                                    <span>Starts In: <span className="font-bold text-blue-900">{data.start_date ? dayjs(data.start_date).format('YYYY-MM-DD hh:mm:A') : '--'}</span></span>
                                    <span>Ends In: <span className="font-bold text-blue-900">{data.end_date ? dayjs(data.end_date).format('YYYY-MM-DD hh:mm:A') : '--'}</span></span>
                                </div>
                            </div>
                        </div>
                        {/* Optionally, add demo products or more preview content below */}
                    </div>
                </div>
            </div>
        </AppLayout>
    );
};

export default EditExpo; 