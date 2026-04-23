# S3 Access Denied Fix Guide

## Problem
Getting "Access Denied" error when accessing S3 images:
```
https://expoza-bucket-vga.s3.me-central-1.amazonaws.com/expos/S3yXpoxUmXexacoCwbrigw0QMI8MWVxOVNgeQ515.png
```

## Root Cause
S3 bucket `expoza-bucket-vga` doesn't have public read permissions configured.

## Solution 1: Configure S3 Bucket Policy (Quick Fix)

### Step 1: AWS S3 Console
1. Go to [AWS S3 Console](https://s3.console.aws.amazon.com/)
2. Click on your bucket: `expoza-bucket-vga`
3. Go to "Permissions" tab

### Step 2: Add Bucket Policy
1. Scroll down to "Bucket Policy"
2. Click "Edit"
3. Add this policy:

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "PublicReadGetObject",
            "Effect": "Allow",
            "Principal": "*",
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::expoza-bucket-vga/*"
        }
    ]
}
```

4. Click "Save changes"

### Step 3: Configure Block Public Access
1. In the same "Permissions" tab
2. Click "Edit" on "Block public access (bucket settings)"
3. **Uncheck** "Block all public access"
4. Click "Save changes"
5. Type "confirm" when prompted

## Solution 2: Use CloudFront (More Secure)

### Step 1: Create CloudFront Distribution
1. Go to [CloudFront Console](https://console.aws.amazon.com/cloudfront/)
2. Click "Create Distribution"
3. Set Origin Domain: `expoza-bucket-vga.s3.me-central-1.amazonaws.com`
4. Set Origin Path: (leave empty)
5. Set Default Cache Behavior:
   - Viewer Protocol Policy: "Redirect HTTP to HTTPS"
   - Allowed HTTP Methods: "GET, HEAD, OPTIONS, PUT, POST, PATCH, DELETE"
6. Click "Create Distribution"

### Step 2: Update Laravel Configuration
1. Copy the CloudFront domain (e.g., `d1234567890.cloudfront.net`)
2. Add to your `.env` file:
```env
AWS_URL=https://d1234567890.cloudfront.net
```

3. Clear config cache:
```bash
php artisan config:clear
```

## Solution 3: Use Pre-signed URLs (Most Secure)

If you want to keep files private but still accessible:

### Update S3Service.php
```php
public function url(string $path): ?string
{
    if (!$this->exists($path)) {
        return null;
    }

    if ($this->isS3Active()) {
        // Generate pre-signed URL that expires in 1 hour
        return Storage::disk('s3')->temporaryUrl($path, now()->addHour());
    }

    return asset('storage/' . ltrim($path, '/'));
}
```

## Testing the Fix

After implementing any solution, test with:

```bash
php artisan tinker
```

```php
// Test S3 connection
Storage::disk('s3')->exists('expos/S3yXpoxUmXexacoCwbrigw0QMI8MWVxOVNgeQ515.png');

// Test URL generation
$s3Service = app(\App\Services\S3Service::class);
echo $s3Service->url('expos/S3yXpoxUmXexacoCwbrigw0QMI8MWVxOVNgeQ515.png');
```

## Recommended Approach

**For development/testing**: Use Solution 1 (Bucket Policy)
**For production**: Use Solution 2 (CloudFront) for better performance and security

## Security Considerations

- **Bucket Policy**: Files are publicly accessible to anyone with the URL
- **CloudFront**: Files are accessible but you can add additional security measures
- **Pre-signed URLs**: Most secure, files expire after set time

## Current Configuration

- Bucket: `expoza-bucket-vga`
- Region: `me-central-1`
- Default Disk: `s3`
- URL Format: `https://expoza-bucket-vga.s3.me-central-1.amazonaws.com/`
