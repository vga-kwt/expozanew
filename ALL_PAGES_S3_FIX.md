# All Pages - S3 Images Fix

## Summary
Fixed image display across all pages to use S3-compatible URLs through model accessors.

## Problem
All pages were using hardcoded `/storage/` paths which don't work with S3 URLs.

## Pages Fixed

### 1. Admin Ads Index
**File:** `resources/js/pages/Ads/Index.tsx`
- **Before:** `src={/storage/${ad.banners}}`
- **After:** `src={ad.banner_url}`
- **Accessor:** `Ad::getBannerUrlAttribute()`

### 2. Vendor Ads Index
**File:** `resources/js/pages/Vendor/Ads/Index.tsx`
- **Before:** `src={/storage/${ad.banners}}`
- **After:** `src={ad.banner_url}`
- **Accessor:** `Ad::getBannerUrlAttribute()`

### 3. Categories Index
**File:** `resources/js/pages/Categories/Index.tsx`
- **Before:** `src={/storage/${cat.image}}`
- **After:** `src={cat.image_url}`
- **Accessor:** `Category::getImageUrlAttribute()`
- **Also fixed:** Image preview in edit form

### 4. Vendors Index
**File:** `resources/js/pages/Vendors/Index.tsx`

**Location 1 - Edit Dialog:**
- **Before:** `src={vendor.logo.startsWith('http') ? vendor.logo : /storage/${vendor.logo}}`
- **After:** `src={vendor.logo_url}`

**Location 2 - View Dialog:**
- **Before:** Same conditional check
- **After:** `src={vendor.logo_url}`

**Location 3 - KYC Documents:**
- **Before:** `url = /storage/${url}` (for kyc-documents/)
- **After:** Removed (already full URLs from accessor)
- **Accessor:** `Vendor::getKycDocumentsUrlsAttribute()`

### 5. Expos Index
**File:** `resources/js/pages/Expos/Index.tsx`

**Background Image:**
- **Before:** `src={selectedExpo.background_image.startsWith('http') ? ... : /storage/${...}}`
- **After:** `src={selectedExpo.background_image_url}`
- **Accessor:** `Expo::getBackgroundImageUrlAttribute()`

**Banner Image:**
- **Before:** Same conditional check
- **After:** `src={selectedExpo.banner_image_url}`
- **Accessor:** `Expo::getBannerImageUrlAttribute()`

### 6. Products Edit
**File:** `resources/js/pages/Products/Edit.tsx`
- Already fixed in previous update for delete functionality
- Uses: `product.image_url_full` and `product.gallery_urls`

## Model Accessors Used

### Ad Model
```php
protected $appends = ['banner_url'];

public function getBannerUrlAttribute()
{
    if (!$this->banners) return null;
    $disk = config('filesystems.default', 's3');
    return $disk === 's3' 
        ? \Storage::disk('s3')->url($this->banners)
        : asset('storage/' . $this->banners);
}
```

### Category Model
```php
protected $appends = ['image_url'];

public function getImageUrlAttribute()
{
    if (!$this->image) return null;
    $disk = config('filesystems.default', 's3');
    return $disk === 's3'
        ? \Storage::disk('s3')->url($this->image)
        : asset('storage/' . $this->image);
}
```

### Vendor Model
```php
protected $appends = ['logo_url', 'kyc_documents_urls'];

public function getLogoUrlAttribute() { /* ... */ }
public function getKycDocumentsUrlsAttribute() { /* ... */ }
```

### Expo Model
```php
protected $appends = ['background_image_url', 'banner_image_url'];

public function getBackgroundImageUrlAttribute() { /* ... */ }
public function getBannerImageUrlAttribute() { /* ... */ }
```

### Product Model
```php
protected $appends = ['image_url_full', 'gallery_urls'];

public function getImageUrlFullAttribute() { /* ... */ }
public function getGalleryUrlsAttribute() { /* ... */ }
```

## Benefits

### Before (Hardcoded Paths)
```tsx
// ❌ Only works with local storage
<img src={`/storage/${image.path}`} />

// ❌ Conditional checks everywhere
<img src={
    image.startsWith('http') 
        ? image 
        : `/storage/${image}`
} />
```

### After (Model Accessors)
```tsx
// ✅ Works with both S3 and local
<img src={model.image_url} />

// ✅ Clean, no conditionals needed
<img src={category.image_url} />
```

## Files Changed

### Index/List Pages
1. `resources/js/pages/Ads/Index.tsx` ✅
2. `resources/js/pages/Vendor/Ads/Index.tsx` ✅
3. `resources/js/pages/Categories/Index.tsx` ✅
4. `resources/js/pages/Vendors/Index.tsx` ✅
5. `resources/js/pages/Expos/Index.tsx` ✅

### Edit/Form Pages
6. `resources/js/pages/Ads/Edit.tsx` ✅
7. `resources/js/pages/Ads/AdForm.tsx` ✅
8. `resources/js/pages/Vendor/Ads/Edit.tsx` ✅
9. `resources/js/pages/Vendor/Ads/AdForm.tsx` ✅
10. `resources/js/pages/Expos/Edit.tsx` ✅
11. `resources/js/pages/Vendor/Profile/Index.tsx` ✅
12. `resources/js/pages/Products/Edit.tsx` ✅

## Testing

### How to Test
1. Refresh browser (Ctrl + Shift + R)
2. Navigate to each page:
   - `/ads` - Check ad banners
   - `/vendor/ads` - Check ad banners
   - `/categories` - Check category images
   - `/vendors` - Check vendor logos & KYC docs
   - `/expos` - Check background & banner images
   - `/products/*/edit` - Check product images
3. All images should load from S3 URLs

### Expected URLs
```
S3: https://expoza-bucket-vga.s3.me-central-1.amazonaws.com/products/image.png
Local: http://127.0.0.1:8000/storage/products/image.png
```

## Result
✅ All pages now support both S3 and local storage  
✅ Automatic switching based on `FILESYSTEM_DISK` config  
✅ Clean code without conditional checks  
✅ Works across admin and vendor portals  

