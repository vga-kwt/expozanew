# Armada 401 Error - Quick Fix Guide

## Current Problem
Armada API is returning 401 Unauthorized for all authorization formats. This means API keys are invalid or expired.

## ✅ Good News
**Order is still being created successfully!** Armada failure doesn't block order creation.

## Quick Solutions

### Solution 1: Temporarily Disable Armada (Immediate Fix)

1. Open `.env` file
2. Find this line:
   ```env
   ARMADA_ENABLED=true
   ```
3. Change to:
   ```env
   ARMADA_ENABLED=false
   ```
4. Run:
   ```bash
   php artisan config:clear
   ```

**Result**: Orders will create normally without Armada integration.

### Solution 2: Fix API Keys (Proper Fix)

#### Step 1: Get Fresh API Keys
1. Login to **Armada Merchant Dashboard**
2. Go to **Settings → API Settings**
3. Copy:
   - Main API Key (starts with `main_`)
   - API Key (UUID format)
   - Branch ID
   - Webhook Key

#### Step 2: Update .env File
```env
ARMADA_ENABLED=true
ARMADA_BASE_URL=https://staging.api.armadadelivery.com
# OR for production:
# ARMADA_BASE_URL=https://api.armadadelivery.com

ARMADA_MAIN_API_KEY=your_fresh_main_api_key_here
ARMADA_API_KEY=your_fresh_api_key_here
ARMADA_BRANCH_ID=your_branch_id_here
ARMADA_WEBHOOK_KEY=your_webhook_key_here
```

#### Step 3: Clear Config Cache
```bash
php artisan config:clear
php artisan config:cache
```

#### Step 4: Test
Try creating/confirming an order again.

## Verify Current Configuration

Run this to check your current config:

```bash
php artisan tinker
```

```php
echo "Armada Enabled: " . (config('armada.enabled') ? 'YES' : 'NO') . "\n";
echo "Base URL: " . config('armada.base_url') . "\n";
echo "Main API Key: " . (config('armada.main_api_key') ? substr(config('armada.main_api_key'), 0, 20) . '...' : 'NOT SET') . "\n";
echo "API Key: " . (config('armada.api_key') ? substr(config('armada.api_key'), 0, 20) . '...' : 'NOT SET') . "\n";
echo "Branch ID: " . config('armada.branch_id') . "\n";
```

## What's Happening Now

1. ✅ **Order is created** - Status set to 'confirmed'
2. ✅ **Fulfillment is created** - Fulfillment record saved
3. ✅ **Notification is sent** - User gets confirmation notification
4. ⚠️ **Armada sync fails** - But this doesn't block order creation
5. ⚠️ **Warning message shown** - "Order confirmed, but Armada sync failed"

## Current Logs Show

- ✅ Order ID 76 was created successfully
- ⚠️ Armada sync failed (401 Unauthorized)
- ✅ Order status: confirmed
- ✅ Order is in database

## Recommended Action

**For immediate use**: Disable Armada temporarily
```env
ARMADA_ENABLED=false
```

**For long-term**: Fix API keys in Armada Dashboard and update .env

## Need Help?

If API keys are correct but still getting 401:
1. Contact Armada Support
2. Provide them:
   - Your branch ID
   - Error logs
   - API key type you're using
   - Base URL (staging/production)

---

**Last Updated**: 2025-11-27
**Status**: Order creation works, Armada sync needs API key fix

