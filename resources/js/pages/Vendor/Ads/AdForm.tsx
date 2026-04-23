import React, { useState, useEffect } from 'react';
import { useForm } from '@inertiajs/react';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select';
import { Textarea } from '@/components/ui/textarea';
import InputError from '@/components/input-error';
import { router } from '@inertiajs/react';

interface AdFormProps {
  ad?: {
    id: number;
    title_en: string;
    title_ar: string;
    banners: string;
    banner_url?: string;
    link_type: string;
    link_id: number | null;
    external_link: string | null;
    status: 'draft' | 'active' | 'suspended';
    priority: number;
    start_date: string | null;
    end_date: string | null;
    description_en: string | null;
    description_ar: string | null;
  };
  products: Array<{ id: number; name_en: string; name_ar: string }>;
  expos: Array<{ id: number; title_en: string; title_ar: string }>;
  linkTypeOptions: Array<{ value: string; label: string }>;
  onSuccess?: () => void;
}

export function AdForm({ ad, products, expos, linkTypeOptions, onSuccess }: AdFormProps) {
  // Get tomorrow's date in Indian timezone
  const getTomorrowDate = () => {
    const tomorrow = new Date();
    tomorrow.setDate(tomorrow.getDate() + 1);
    tomorrow.setHours(0, 0, 0, 0); // Set to start of day
    
    // Convert to Indian timezone
    const indianTime = new Date(tomorrow.toLocaleString("en-US", {timeZone: "Asia/Kolkata"}));
    return formatDateTimeLocal(indianTime.toISOString());
  };

  const { data, setData, post, processing, errors, reset } = useForm({
    title_en: ad?.title_en || '',
    title_ar: ad?.title_ar || '',
    banners: ad?.banners || '',
    link_type: ad?.link_type || '',
    link_id: ad?.link_id || null,
    external_link: ad?.external_link || '',
    status: ad?.status || 'draft',
    priority: ad?.priority || 50,
    start_date: ad?.start_date || getTomorrowDate(),
    end_date: ad?.end_date || '',
    description_en: ad?.description_en || '',
    description_ar: ad?.description_ar || '',
  });

  const [selectedImage, setSelectedImage] = useState<File | null>(null);
  const [imagePreview, setImagePreview] = useState<string | null>(ad?.banner_url || null);
  const [imageValidation, setImageValidation] = useState<{ valid: boolean; message: string }>({ valid: true, message: '' });

  useEffect(() => {
    if (ad) {
      setData('title_en', ad.title_en);
      setData('title_ar', ad.title_ar);
      setData('banners', ad.banners);
      setData('link_type', ad.link_type);
      setData('link_id', ad.link_id);
      setData('external_link', ad.external_link || '');
      setData('status', ad.status);
      setData('priority', ad.priority);
      setData('start_date', ad.start_date || '');
      setData('end_date', ad.end_date || '');
      setData('description_en', ad.description_en || '');
      setData('description_ar', ad.description_ar || '');
      setImagePreview(ad.banner_url || null);
    }
  }, [ad]);

  const handleImageChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (!file) return;

    // Validate file type
    if (!file.type.startsWith('image/')) {
      setImageValidation({ valid: false, message: 'Please select a valid image file.' });
      return;
    }

    // Validate file size (2MB max)
    if (file.size > 2 * 1024 * 1024) {
      setImageValidation({ valid: false, message: 'Image size must be less than 2MB.' });
      return;
    }

    // Validate image dimensions
    const img = new Image();
    img.onload = () => {
      // Mobile banner dimensions: width should be 320-750px, height should be 100-200px
      const minWidth = 320;
      const maxWidth = 750;
      const minHeight = 100;
      const maxHeight = 200;
      const aspectRatio = img.width / img.height;
      const idealAspectRatio = 3.2; // 640x200 is ideal

      if (img.width < minWidth || img.width > maxWidth) {
        setImageValidation({
          valid: false,
          message: `Image width must be between ${minWidth}px and ${maxWidth}px. Current: ${img.width}px`
        });
        return;
      }

      if (img.height < minHeight || img.height > maxHeight) {
        setImageValidation({
          valid: false,
          message: `Image height must be between ${minHeight}px and ${maxHeight}px. Current: ${img.height}px`
        });
        return;
      }

      // Warn about aspect ratio but don't block
      if (Math.abs(aspectRatio - idealAspectRatio) > 1) {
        setImageValidation({
          valid: true,
          message: `Warning: For best results, use an aspect ratio close to 3.2:1 (e.g., 640x200). Current: ${aspectRatio.toFixed(2)}:1`
        });
      } else {
        setImageValidation({ valid: true, message: '' });
      }

      setSelectedImage(file);
      setImagePreview(URL.createObjectURL(file));
    };
    img.onerror = () => {
      setImageValidation({ valid: false, message: 'Failed to load image. Please try again.' });
    };
    img.src = URL.createObjectURL(file);
  };

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();

    if (!imageValidation.valid) {
      return;
    }

    const formData = new FormData();
    formData.append('title_en', data.title_en);
    formData.append('title_ar', data.title_ar);
    formData.append('description_en', data.description_en || '');
    formData.append('description_ar', data.description_ar || '');
    formData.append('link_type', data.link_type || '');
    if (data.link_id) formData.append('link_id', data.link_id.toString());
    if (data.external_link) formData.append('external_link', data.external_link);
    formData.append('status', data.status);
    formData.append('priority', data.priority.toString());
    formData.append('start_date', formatDateTimeForBackend(data.start_date));
    formData.append('end_date', formatDateTimeForBackend(data.end_date));

    // Image logic
    if (selectedImage) {
      formData.append('banners', selectedImage);
    } else if (ad && !selectedImage) {
      // Don't append banner_image, backend will keep old image
    }

    if (ad) {
      // For PUT, add _method override
      formData.append('_method', 'PUT');
      // Use router.post for FormData with method override
      router.post(`/vendor/ads/${ad.id}`, formData, {
        forceFormData: true,
        onSuccess: () => {
          if (onSuccess) onSuccess();
        }
      });
    } else {
      router.post('/vendor/ads', formData, {
        forceFormData: true,
        onSuccess: () => {
          if (onSuccess) onSuccess();
        }
      });
    }
  };

  const getLinkableItems = () => {
    switch (data.link_type) {
      case 'product':
        return products.map(item => ({
          value: item.id.toString(),
          label: `${item.name_en} (${item.name_ar})`
        }));
      case 'expo':
        return expos.map(item => ({
          value: item.id.toString(),
          label: `${item.title_en} (${item.title_ar})`
        }));
      default:
        return [];
    }
  };

  function formatDateTimeLocal(dt: string) {
    if (!dt) return '';
    
    // If already in correct format (YYYY-MM-DDTHH:MM), return as is
    if (/^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}$/.test(dt)) {
      return dt;
    }
    
    // If it's a date string, convert to datetime-local format
    const date = new Date(dt);
    if (isNaN(date.getTime())) return '';
    
    // Format to YYYY-MM-DDTHH:MM
    const year = date.getFullYear();
    const month = String(date.getMonth() + 1).padStart(2, '0');
    const day = String(date.getDate()).padStart(2, '0');
    const hours = String(date.getHours()).padStart(2, '0');
    const minutes = String(date.getMinutes()).padStart(2, '0');
    
    return `${year}-${month}-${day}T${hours}:${minutes}`;
  }

  function formatDateTimeForBackend(dt: string) {
    if (!dt) return '';
    
    // If it's already in datetime-local format (YYYY-MM-DDTHH:MM), convert to backend format
    if (/^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}$/.test(dt)) {
      const date = new Date(dt);
      if (isNaN(date.getTime())) return '';
      
      // Format to Y-m-d H:i:s for backend (IST timezone)
      const year = date.getFullYear();
      const month = String(date.getMonth() + 1).padStart(2, '0');
      const day = String(date.getDate()).padStart(2, '0');
      const hours = String(date.getHours()).padStart(2, '0');
      const minutes = String(date.getMinutes()).padStart(2, '0');
      const seconds = String(date.getSeconds()).padStart(2, '0');
      
      return `${year}-${month}-${day} ${hours}:${minutes}:${seconds}`;
    }
    
    // If it's already in backend format, return as is
    if (/^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}$/.test(dt)) {
      return dt;
    }
    
    // Otherwise, try to parse and format
    const date = new Date(dt);
    if (isNaN(date.getTime())) return '';
    
    const year = date.getFullYear();
    const month = String(date.getMonth() + 1).padStart(2, '0');
    const day = String(date.getDate()).padStart(2, '0');
    const hours = String(date.getHours()).padStart(2, '0');
    const minutes = String(date.getMinutes()).padStart(2, '0');
    const seconds = String(date.getSeconds()).padStart(2, '0');
    
    return `${year}-${month}-${day} ${hours}:${minutes}:${seconds}`;
  }

  // Function to validate start date is in the future
  const validateStartDate = (dateString: string) => {
    if (!dateString) return true;
    const selectedDate = new Date(dateString);
    const now = new Date();
    return selectedDate > now;
  };

  return (
    <form onSubmit={handleSubmit} className="space-y-6 max-h-[80vh] overflow-y-auto pr-2">
      <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
        {/* Basic Information */}
        <div className="space-y-4 bg-card p-6 rounded-xl border shadow-sm">
          <Label htmlFor="title_en">Title (English)</Label>
          <Input id="title_en" value={data.title_en} onChange={e => setData('title_en', e.target.value)} placeholder="Enter English title" />
          <InputError message={errors.title_en} className="mt-1" />

          <Label htmlFor="title_ar">Title (Arabic)</Label>
          <Input id="title_ar" value={data.title_ar} onChange={e => setData('title_ar', e.target.value)} placeholder="أدخل العنوان بالعربية" dir="rtl" />
          <InputError message={errors.title_ar} className="mt-1" />

          <Label htmlFor="description_en">Description (English)</Label>
          <Textarea id="description_en" value={data.description_en} onChange={e => setData('description_en', e.target.value)} placeholder="Enter English description" />
          <InputError message={errors.description_en} className="mt-1" />

          <Label htmlFor="description_ar">Description (Arabic)</Label>
          <Textarea id="description_ar" value={data.description_ar} onChange={e => setData('description_ar', e.target.value)} placeholder="أدخل الوصف بالعربية" dir="rtl" />
          <InputError message={errors.description_ar} className="mt-1" />

          <Label htmlFor="status">Status</Label>
          <Select value={data.status} onValueChange={value => setData('status', value as any)}>
            <SelectTrigger><SelectValue placeholder="Select status" /></SelectTrigger>
            <SelectContent>
              <SelectItem value="draft">Draft</SelectItem>
              <SelectItem value="active">Active</SelectItem>
              <SelectItem value="suspended">Suspended</SelectItem>
            </SelectContent>
          </Select>
          <InputError message={errors.status} className="mt-1" />

          <Label htmlFor="priority">Display Priority</Label>
          <Input id="priority" type="number" min="0" max="100" value={data.priority} onChange={e => setData('priority', parseInt(e.target.value))} placeholder="0-100" />
          <InputError message={errors.priority} className="mt-1" />

          <Label htmlFor="start_date">Start Date & Time (IST)</Label>
          <Input
            id="start_date"
            type="datetime-local"
            value={formatDateTimeLocal(data.start_date)}
            min={formatDateTimeLocal(new Date().toISOString())} // Cannot select past dates
            onChange={e => {
              const value = e.target.value;
              setData('start_date', value);
              // If end date is before start date, clear it
              if (data.end_date && value && new Date(value) >= new Date(data.end_date)) {
                setData('end_date', '');
              }
            }}
          />
          <p className="text-xs text-muted-foreground">Start date must be in the future</p>
          <InputError message={errors.start_date} className="mt-1" />

          <Label htmlFor="end_date">End Date & Time (IST)</Label>
          <Input
            id="end_date"
            type="datetime-local"
            value={formatDateTimeLocal(data.end_date)}
            min={
              data.start_date
                ? (() => {
                  // Add 1 minute to start_date to ensure end_date is after start_date
                  const d = new Date(data.start_date);
                  d.setMinutes(d.getMinutes() + 1);
                  return formatDateTimeLocal(d.toISOString());
                })()
                : undefined
            }
            onChange={e => setData('end_date', e.target.value)}
          />
          <p className="text-xs text-muted-foreground">End date must be after start date</p>
          <InputError message={errors.end_date} className="mt-1" />
        </div>

        {/* Banner Image */}
        <div className="bg-card space-y-4 rounded-xl border p-6 shadow-sm">
          <Label htmlFor="banners">Upload Banner Image</Label>
          <Input id="banners" type="file" accept="image/*" onChange={handleImageChange} className="cursor-pointer" />
          <p className="mt-1 text-sm text-gray-500">Recommended: 320x180px, Max: 2MB</p>
          {ad && ad.banners && (
            <div className="mt-2 p-3 bg-yellow-50 border border-yellow-200 rounded-lg">
              <p className="text-sm text-yellow-800 font-medium">⚠️ Update Notice:</p>
              <p className="text-sm text-yellow-700">Uploading a new image will replace the existing banner.</p>
            </div>
          )}
          <InputError message={errors.banners} className="mt-1" />
          {imagePreview && (
            <div className="mt-4">
              <Label>Preview</Label>
              <div className="mt-2">
                <img src={imagePreview} alt="Banner preview" className="h-32 w-full object-cover rounded-lg border" />
              </div>
            </div>
          )}
        </div>
      </div>

      {/* Link Configuration */}
      <div className="space-y-4 bg-card p-6 rounded-xl border shadow-sm">
        <Label htmlFor="link_type">Link Type</Label>
        <Select value={data.link_type} onValueChange={value => setData('link_type', value)}>
          <SelectTrigger><SelectValue placeholder="Select link type" /></SelectTrigger>
          <SelectContent>
            {linkTypeOptions.map(option => (
              <SelectItem key={option.value} value={option.value}>{option.label}</SelectItem>
            ))}
          </SelectContent>
        </Select>
        <InputError message={errors.link_type} className="mt-1" />

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
            <InputError message={errors.external_link} className="mt-1" />
          </div>
        ) : data.link_type && data.link_type !== 'vendor' ? (
          <div>
            <Label htmlFor="link_id">Select {data.link_type}</Label>
            <Select value={data.link_id?.toString() || ''} onValueChange={value => setData('link_id', parseInt(value))}>
              <SelectTrigger><SelectValue placeholder={`Select ${data.link_type}`} /></SelectTrigger>
              <SelectContent>
                {getLinkableItems().map(item => (
                  <SelectItem key={item.value} value={item.value}>{item.label}</SelectItem>
                ))}
              </SelectContent>
            </Select>
            <InputError message={errors.link_id} className="mt-1" />
          </div>
        ) : null}
      </div>

      {/* Submit Button */}
      <div className="flex justify-end gap-4 pt-4 border-t">
        <Button
          type="button"
          variant="outline"
          onClick={() => {
            reset();
            setSelectedImage(null);
            setImagePreview(null);
            setImageValidation({ valid: true, message: '' });
          }}
        >
          Reset
        </Button>
        <Button
          type="submit"
          disabled={processing || !imageValidation.valid}
        >
          {processing ? 'Saving...' : (ad ? 'Update Ad' : 'Create Ad')}
        </Button>
      </div>
    </form>
  );
} 