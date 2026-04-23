# Live/Production S3 Bucket Setup Guide

## Overview
यह guide आपको live/production environment में S3 bucket setup करने में मदद करेगा।

## Step 1: AWS S3 Bucket Create करें

### 1.1 AWS Console में जाएं
1. [AWS S3 Console](https://s3.console.aws.amazon.com/) पर जाएं
2. "Create bucket" पर click करें

### 1.2 Bucket Configuration
```
Bucket name: expoza-bucket-vga (या आपका preferred name)
Region: me-central-1 (या आपका preferred region)
```

### 1.3 Public Access Settings
**Important**: Production के लिए सही settings करें

1. **Block public access settings** में:
   - ✅ "Block all public access" को **UNCHECK** करें
   - ✅ "Block public access to buckets and objects granted through new public bucket or access point policies" को **UNCHECK** करें
   - ✅ बाकी options को **CHECKED** रखें

2. Warning message आने पर "I acknowledge that the current settings might result in this bucket and the objects within becoming public" को check करें

## Step 2: Bucket Policy Setup

### 2.1 Bucket Policy Add करें
1. Bucket के "Permissions" tab में जाएं
2. "Bucket policy" section में "Edit" click करें
3. नीचे दिया गया policy add करें:

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

**Note**: `expoza-bucket-vga` को अपने bucket name से replace करें।

## Step 3: CORS Configuration

### 3.1 CORS Policy Add करें
1. Same "Permissions" tab में
2. "Cross-origin resource sharing (CORS)" section में "Edit" click करें
3. नीचे दिया गया CORS configuration add करें:

```json
[
    {
        "AllowedHeaders": ["*"],
        "AllowedMethods": ["GET", "POST", "PUT", "DELETE", "HEAD"],
        "AllowedOrigins": ["*"],
        "ExposeHeaders": ["ETag"]
    }
]
```

## Step 4: IAM User Create करें

### 4.1 IAM Console में जाएं
1. [AWS IAM Console](https://console.aws.amazon.com/iam/) पर जाएं
2. "Users" → "Create user" click करें

### 4.2 User Configuration
```
User name: expoza-s3-user
Access type: Programmatic access
```

### 4.3 Permissions Attach करें
1. "Attach policies directly" select करें
2. "AmazonS3FullAccess" policy search करें और select करें
3. "Next" → "Create user" click करें

### 4.4 Access Keys Save करें
**Important**: Access keys को safe place में save करें
```
Access Key ID: AKIA...
Secret Access Key: ...
```

## Step 5: Environment Variables Setup

### 5.1 Production .env File में Add करें
```env
# S3 Configuration
FILESYSTEM_DISK=s3
AWS_ACCESS_KEY_ID=your_access_key_here
AWS_SECRET_ACCESS_KEY=your_secret_key_here
AWS_DEFAULT_REGION=me-central-1
AWS_BUCKET=expoza-bucket-vga
AWS_URL=https://expoza-bucket-vga.s3.me-central-1.amazonaws.com
```

### 5.2 Server पर Environment Variables Set करें
```bash
# cPanel/WHM में
export AWS_ACCESS_KEY_ID="your_access_key_here"
export AWS_SECRET_ACCESS_KEY="your_secret_key_here"
export AWS_DEFAULT_REGION="me-central-1"
export AWS_BUCKET="expoza-bucket-vga"
export FILESYSTEM_DISK="s3"
```

## Step 6: Laravel Configuration

### 6.1 Config Cache Clear करें
```bash
php artisan config:clear
php artisan config:cache
```

### 6.2 Storage Link (अगर local storage भी use करना है)
```bash
php artisan storage:link
```

## Step 7: Testing

### 7.1 S3 Connection Test करें
```bash
php artisan tinker
```

```php
// Test S3 connection
Storage::disk('s3')->exists('test.txt');

// Test file upload
Storage::disk('s3')->put('test.txt', 'Hello World');

// Test file URL
Storage::disk('s3')->url('test.txt');
```

### 7.2 Browser में Test करें
1. किसी भी image का URL copy करें
2. Browser में paste करें
3. Image load होना चाहिए

## Step 8: Common Issues और Solutions

### Issue 1: Access Denied Error
**Solution**: Bucket policy सही से setup नहीं हुआ है
- Bucket policy में `"Principal": "*"` check करें
- Block public access settings check करें

### Issue 2: CORS Error
**Solution**: CORS policy add करें
- Bucket के CORS section में proper configuration add करें

### Issue 3: Images नहीं दिख रहे
**Solution**: 
1. Environment variables check करें
2. Config cache clear करें
3. File paths check करें

### Issue 4: Upload नहीं हो रहा
**Solution**:
1. IAM user permissions check करें
2. Access keys सही हैं या नहीं check करें

## Step 9: Security Best Practices

### 9.1 Bucket Policy को Restrict करें (Optional)
अगर आप specific domains से ही access चाहते हैं:

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "PublicReadGetObject",
            "Effect": "Allow",
            "Principal": "*",
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::expoza-bucket-vga/*",
            "Condition": {
                "StringLike": {
                    "aws:Referer": [
                        "https://yourdomain.com/*",
                        "https://www.yourdomain.com/*"
                    ]
                }
            }
        }
    ]
}
```

### 9.2 IAM User को Specific Permissions दें
```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:GetObject",
                "s3:PutObject",
                "s3:DeleteObject",
                "s3:ListBucket"
            ],
            "Resource": [
                "arn:aws:s3:::expoza-bucket-vga",
                "arn:aws:s3:::expoza-bucket-vga/*"
            ]
        }
    ]
}
```

## Step 10: Monitoring और Maintenance

### 10.1 CloudWatch Logs Enable करें
1. S3 bucket के "Properties" tab में जाएं
2. "Server access logging" enable करें

### 10.2 Cost Monitoring
1. AWS Cost Explorer में जाकर S3 costs monitor करें
2. Unnecessary files को delete करते रहें

## Troubleshooting Commands

```bash
# Check current configuration
php artisan config:show filesystems

# Test S3 service
php artisan tinker
$s3Service = app(\App\Services\S3Service::class);
$s3Service->getConfiguration();

# Clear all caches
php artisan cache:clear
php artisan config:clear
php artisan view:clear
php artisan route:clear
```

## Support

अगर कोई issue आए तो:
1. AWS CloudTrail logs check करें
2. Laravel logs check करें: `storage/logs/laravel.log`
3. Browser console में errors check करें

---

**Note**: Production environment में S3 setup करने से पहले backup ले लें और test environment में पहले try करें।
