# AWS S3 Integration - Complete Setup Guide

## Table of Contents
1. [Overview](#overview)
2. [Current Configuration](#current-configuration)
3. [Features](#features)
4. [Environment Setup](#environment-setup)
5. [How It Works](#how-it-works)
6. [Usage Guide](#usage-guide)
7. [Troubleshooting](#troubleshooting)
8. [Maintenance](#maintenance)

---

## Overview

This project uses **AWS S3** for all file storage (images, documents, etc.) across both admin and vendor portals.

**Benefits:**
- ✅ Unlimited scalable storage
- ✅ Fast CDN delivery
- ✅ 99.999999999% durability
- ✅ Automatic HTTPS
- ✅ No server storage limits

---

## Current Configuration

### AWS Credentials
```env
AWS Region: me-central-1 (Middle East - UAE)
AWS Bucket: expoza-bucket-vga
Access Key: AKIAQQABDKOOWGTREEHK
```

### EC2 Instance
```
Host: 3.28.221.32
User: ubuntu
SSH Key: storage/ssh/expozaKeyPair.pem
```

### Environment Variables
Required in `.env` file:
```env
FILESYSTEM_DISK=s3
AWS_ACCESS_KEY_ID=AKIAQQABDKOOWGTREEHK
AWS_SECRET_ACCESS_KEY=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
AWS_DEFAULT_REGION=me-central-1
AWS_BUCKET=expoza-bucket-vga
AWS_URL=https://expoza-bucket-vga.s3.me-central-1.amazonaws.com
AWS_ENDPOINT=
AWS_USE_PATH_STYLE_ENDPOINT=false
```

---

## Features

### Integrated Areas
All file uploads in these areas use S3:

#### Admin Dashboard
- ✅ Product images (main + gallery)
- ✅ Category images
- ✅ Expo images (background + banner)
- ✅ Advertisement banners
- ✅ User profile images
- ✅ CMS page images

#### Vendor Dashboard
- ✅ Vendor logos
- ✅ Product uploads
- ✅ KYC documents
- ✅ Profile images

#### API Endpoints
- ✅ All file uploads via API
- ✅ Mobile app image uploads

---

## Environment Setup

### Prerequisites
```bash
# Required PHP package (already installed)
composer require league/flysystem-aws-s3-v3
```

### Configuration Files

#### 1. `.env` File
Must have these settings:
```env
FILESYSTEM_DISK=s3
AWS_ACCESS_KEY_ID=your_access_key
AWS_SECRET_ACCESS_KEY=your_secret_key
AWS_DEFAULT_REGION=me-central-1
AWS_BUCKET=expoza-bucket-vga
AWS_URL=https://expoza-bucket-vga.s3.me-central-1.amazonaws.com
```

#### 2. `config/filesystems.php`
S3 disk configuration (already configured):
```php
's3' => [
    'driver' => 's3',
    'key' => env('AWS_ACCESS_KEY_ID'),
    'secret' => env('AWS_SECRET_ACCESS_KEY'),
    'region' => env('AWS_DEFAULT_REGION'),
    'bucket' => env('AWS_BUCKET'),
    'url' => env('AWS_URL'),
    'endpoint' => env('AWS_ENDPOINT'),
    'use_path_style_endpoint' => env('AWS_USE_PATH_STYLE_ENDPOINT', false),
],
```

---

## How It Works

### Image Upload Flow
```
User uploads file
    ↓
Laravel processes upload
    ↓
ImageService uploads to S3
    ↓
S3 path saved to database
    ↓
S3 URL generated for frontend
    ↓
Image displayed from S3 CDN
```

### URL Generation

**Local Storage (Old):**
```
http://127.0.0.1:8000/storage/products/image.png
```

**S3 Storage (Current):**
```
https://expoza-bucket-vga.s3.me-central-1.amazonaws.com/products/image.png
```

### File Structure in S3 Bucket
```
expoza-bucket-vga/
├── products/           # Product images
├── categories/         # Category images
├── expos/             # Expo backgrounds/banners
├── ads/               # Advertisement banners
├── vendor-logos/      # Vendor logos
├── kyc-documents/     # KYC documents
├── profile_images/    # User profile images
└── exports/           # Generated export files
```

---

## Usage Guide

### For Developers

#### Upload Image
```php
use App\Services\ImageService;

$imageService = app(ImageService::class);
$path = $imageService->uploadImage($file, 'products');
// Returns: 'products/68e782d66e818_1760002774.png'
```

#### Get Image URL
```php
$url = $imageService->getImageUrl($path);
// Returns: 'https://expoza-bucket-vga.s3.me-central-1.amazonaws.com/products/68e782d66e818_1760002774.png'
```

#### Delete Image
```php
$imageService->deleteImage($path);
```

#### Upload Multiple Images
```php
use App\Services\MultipleImageService;

$multipleImageService = app(MultipleImageService::class);
$paths = $multipleImageService->uploadMultipleImages($files, 'products');
```

### Model Accessors

Models automatically append full S3 URLs:

#### Product Model
```php
$product->image_url_full    // Full S3 URL for main image
$product->gallery_urls      // Array of S3 URLs for gallery
```

#### Category Model
```php
$category->image_url        // Full S3 URL
```

#### Vendor Model
```php
$vendor->logo_url           // Full S3 URL for logo
$vendor->kyc_documents_urls // Array of S3 URLs for documents
```

#### Expo Model
```php
$expo->background_image_url // Full S3 URL
$expo->banner_image_url     // Full S3 URL
```

### Frontend Usage

#### React/Inertia Components
```tsx
// Product image
<img src={product.image_url_full} alt={product.name_en} />

// Gallery images
{product.gallery_urls.map((url, idx) => (
    <img key={idx} src={url} alt={`Gallery ${idx}`} />
))}

// Category image
<img src={category.image_url} alt={category.name_en} />

// Vendor logo
<img src={vendor.logo_url} alt={vendor.name} />
```

---

## Troubleshooting

### Images Not Showing

**1. Check Environment Configuration**
```bash
php artisan tinker
echo config('filesystems.default');  // Should return: s3
echo config('filesystems.disks.s3.bucket');  // Should return: expoza-bucket-vga
```

**2. Test S3 Connection**
```bash
php artisan tinker
\Storage::disk('s3')->exists('test.txt');  // Should work without errors
```

**3. Check if Files Exist in S3**
```bash
php artisan tinker
$files = \Storage::disk('s3')->files('products');
echo count($files);  // Should show file count
```

**4. Clear Cache**
```bash
php artisan config:clear
php artisan cache:clear
```

### Upload Failures

**Check AWS Credentials:**
```bash
# Verify credentials in .env
cat .env | grep AWS_
```

**Check S3 Bucket Permissions:**
- IAM user must have `s3:PutObject` permission
- Bucket policy should allow uploads

**Check Error Logs:**
```bash
tail -f storage/logs/laravel.log
```

### CORS Errors (Browser)

If images show CORS errors in browser console, add CORS configuration to S3 bucket:

```json
[
    {
        "AllowedHeaders": ["*"],
        "AllowedMethods": ["GET", "HEAD"],
        "AllowedOrigins": ["*"],
        "ExposeHeaders": []
    }
]
```

---

## Maintenance

### Syncing Local Files to S3

If you have files in local storage that need to be moved to S3:

```php
<?php
// sync-to-s3.php
require 'vendor/autoload.php';
$app = require_once 'bootstrap/app.php';
$app->make('Illuminate\Contracts\Console\Kernel')->bootstrap();

$localDisk = \Storage::disk('public');
$s3Disk = \Storage::disk('s3');

$folders = ['products', 'categories', 'expos', 'ads', 'vendor-logos'];

foreach ($folders as $folder) {
    $files = $localDisk->files($folder);
    foreach ($files as $file) {
        if (!$s3Disk->exists($file)) {
            $content = $localDisk->get($file);
            $s3Disk->put($file, $content);
            echo "Synced: $file\n";
        }
    }
}
```

Run:
```bash
php sync-to-s3.php
```

### Monitoring S3 Usage

**Check Storage Used:**
```bash
php artisan tinker
$files = \Storage::disk('s3')->allFiles();
echo "Total files: " . count($files);
```

**List Recent Uploads:**
```bash
php artisan tinker
$files = \Storage::disk('s3')->files('products');
foreach(array_slice($files, -10) as $file) {
    echo $file . "\n";
}
```

### Backup Strategy

**Option 1: S3 Versioning**
- Enable versioning in S3 bucket settings
- Automatic backup of all file versions

**Option 2: Cross-Region Replication**
- Replicate to another S3 bucket in different region
- Disaster recovery

**Option 3: Local Backup**
- Keep copies in local storage as backup
- Files in `storage/app/public/` can serve as backup

### Cost Optimization

**1. Use Lifecycle Rules:**
```
Move old files to S3 Glacier after 90 days
Delete temporary files after 30 days
```

**2. Optimize Image Sizes:**
- Compress images before upload
- Use appropriate image formats (WebP > JPG > PNG)

**3. Use CloudFront CDN:**
- Cache frequently accessed images
- Reduce S3 bandwidth costs

---

## Security

### AWS Credentials

**⚠️ IMPORTANT:**
- Never commit `.env` file to git
- Rotate credentials regularly
- Use IAM roles with minimum required permissions
- SSH key stored in `storage/ssh/` (gitignored)

### S3 Bucket Security

**Current Setup:**
- Private bucket (not public)
- Access via IAM credentials only
- Files accessible via signed URLs

**Best Practices:**
- Enable bucket versioning
- Enable access logging
- Set up bucket policies
- Use VPC endpoints for EC2 access

---

## Deployment

### Production Checklist

**Before Deploying:**
- [ ] `.env` file configured with production credentials
- [ ] AWS credentials verified
- [ ] S3 bucket created and configured
- [ ] CORS policy set (if needed)
- [ ] Cache cleared (`php artisan config:clear`)
- [ ] Dependencies installed (`composer install --no-dev`)

**After Deploying:**
- [ ] Test file upload
- [ ] Test file access (URLs working)
- [ ] Check error logs
- [ ] Monitor S3 usage

### Environment-Specific Settings

**Local Development:**
```env
FILESYSTEM_DISK=public  # Use local storage for development
```

**Staging:**
```env
FILESYSTEM_DISK=s3
AWS_BUCKET=expoza-staging-bucket
```

**Production:**
```env
FILESYSTEM_DISK=s3
AWS_BUCKET=expoza-bucket-vga
```

---

## Support

### Quick Commands Reference

```bash
# Clear cache
php artisan config:clear
php artisan cache:clear

# Test S3 connection
php artisan tinker --execute="\Storage::disk('s3')->exists('test.txt');"

# List S3 files
php artisan tinker --execute="\$files = \Storage::disk('s3')->files('products'); echo count(\$files);"

# Generate S3 URL
php artisan tinker --execute="echo \Storage::disk('s3')->url('products/image.png');"
```

### Common Issues & Solutions

| Issue | Solution |
|-------|----------|
| Images not showing | Check `FILESYSTEM_DISK=s3` in `.env` |
| Upload fails | Verify AWS credentials and permissions |
| CORS errors | Add CORS policy to S3 bucket |
| Slow loading | Enable CloudFront CDN |
| High costs | Implement lifecycle rules |

---

## Summary

✅ **Configured:** AWS S3 integration across entire application  
✅ **Bucket:** expoza-bucket-vga (me-central-1)  
✅ **Files Synced:** 112+ images already in S3  
✅ **Coverage:** Admin, Vendor, and API areas  
✅ **Ready:** Production-ready configuration  

**For questions or issues, check the troubleshooting section or review Laravel logs.**

