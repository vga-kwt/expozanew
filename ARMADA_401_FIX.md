# Armada 401 Unauthorized Error - Fix Applied

## Problem
Armada API calls were failing with `401 Unauthorized` error when creating orders.

## Root Cause
The issue was related to API key selection and authorization header format. The system was using the regular API key first, but might need to use the main API key instead.

## Fix Applied

### 1. Updated API Key Selection Priority
- **Before**: Used `ARMADA_API_KEY` first, then fallback to `ARMADA_MAIN_API_KEY`
- **After**: Prefers `ARMADA_MAIN_API_KEY` first, then fallback to `ARMADA_API_KEY`

### 2. Added Automatic Retry Logic
- If API call fails with 401 using regular API key, automatically retries with main API key
- Better error logging to help diagnose issues

### 3. Added API Key Validation
- Validates that API key is set before making API calls
- Provides clear error messages if API key is missing

## Verification Steps

### Step 1: Check .env File
Verify these variables are set correctly in your `.env` file:

```env
ARMADA_ENABLED=true
ARMADA_BASE_URL=https://staging.api.armadadelivery.com
# OR for production:
# ARMADA_BASE_URL=https://api.armadadelivery.com

ARMADA_MAIN_API_KEY=main_52e1cc75e683fb92b8fe472mi11h723
ARMADA_API_KEY=d9049c2d-37af-4812-a658-34a997736b56
ARMADA_BRANCH_ID=NAQSH
ARMADA_WEBHOOK_KEY=vE6gH8Rt2L1sK9w
```

### Step 2: Clear Config Cache
```bash
php artisan config:clear
php artisan config:cache
```

### Step 3: Verify Configuration
```bash
php artisan tinker
```

```php
echo config('armada.enabled'); // Should be true
echo config('armada.main_api_key'); // Should show your main API key
echo config('armada.api_key'); // Should show your regular API key
echo config('armada.branch_id'); // Should show NAQSH
echo config('armada.base_url'); // Should show correct URL
```

### Step 4: Test Order Creation
Try creating/confirming an order again and check the logs:

```bash
tail -f storage/logs/laravel.log | grep -i armada
```

## What to Check if Still Getting 401

### 1. API Key Validity
- Log in to Armada Dashboard
- Go to Settings → API Settings
- Verify your API keys are active and not expired
- Copy fresh API keys if needed

### 2. Base URL
- **Staging**: `https://staging.api.armadadelivery.com`
- **Production**: `https://api.armadadelivery.com`
- Make sure you're using the correct URL for your environment

### 3. Branch ID
- Verify `ARMADA_BRANCH_ID` matches your branch name in Armada dashboard
- Case-sensitive: `NAQSH` vs `naqsh` matters

### 4. API Key Format
- Main API Key should start with `main_` (e.g., `main_52e1cc75e683fb92b8fe472mi11h723`)
- Regular API Key is usually a UUID format (e.g., `d9049c2d-37af-4812-a658-34a997736b56`)

### 5. Check Logs for Details
The updated code now logs:
- Which API key type is being used
- Authorization header preview
- Detailed error messages with suggestions

## Expected Log Output (Success)

```
[timestamp] local.INFO: ArmadaService initialized
[timestamp] local.INFO: Prepared Armada Order Data
[timestamp] local.INFO: Armada Create Order Request
[timestamp] local.INFO: Armada API Request Headers
[timestamp] local.INFO: Armada Create Order Response {"status_code":200,"successful":true}
[timestamp] local.INFO: Armada Order Created Successfully
```

## Expected Log Output (After Fix - Retry)

If regular API key fails, you'll see:
```
[timestamp] local.WARNING: Armada API returned 401 with regular API key, trying main API key
[timestamp] local.INFO: Retrying with main API key
[timestamp] local.INFO: Armada Create Order Response {"status_code":200,"successful":true}
```

## If Problem Persists

1. **Verify API Keys in Armada Dashboard**
   - Check if keys are active
   - Regenerate if needed
   - Update `.env` file with new keys

2. **Check API Key Permissions**
   - Ensure API key has permission to create orders
   - Check branch access permissions

3. **Verify Network/Firewall**
   - Ensure server can reach Armada API
   - Check if any firewall is blocking requests

4. **Contact Armada Support**
   - If API keys are correct but still getting 401
   - Provide them with:
     - Your branch ID
     - API key type (main or regular)
     - Request headers (from logs)
     - Error response

## Code Changes Summary

### File: `app/Services/ArmadaService.php`

1. **Constructor**: Now prefers `main_api_key` over `api_key`
2. **createOrder()**: 
   - Added API key validation
   - Added automatic retry with main API key on 401 error
   - Enhanced error logging with suggestions

## Testing

After applying the fix, test by:
1. Creating a new order
2. Confirming an existing order
3. Check logs for successful API calls

If you see `status_code: 200` in logs, the fix is working! ✅

---

**Last Updated**: 2025-11-27
**Status**: Fix Applied - Ready for Testing

