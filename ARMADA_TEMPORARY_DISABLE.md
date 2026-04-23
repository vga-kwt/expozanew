# Armada Integration - Temporary Disable Guide

## Problem
Armada API is returning 401 Unauthorized for all authorization formats. This means:
- API keys might be invalid/expired
- API keys don't match Armada Dashboard
- Base URL might be incorrect

## Solution: Temporarily Disable Armada

Agar order create karna hai aur Armada API keys fix nahi ho rahe, to temporarily Armada disable kar sakte hain:

### Step 1: Disable Armada in .env

`.env` file mein yeh change karein:

```env
# Change this:
ARMADA_ENABLED=false

# Instead of:
# ARMADA_ENABLED=true
```

### Step 2: Clear Config Cache

```bash
php artisan config:clear
php artisan config:cache
```

### Step 3: Test Order Creation

Ab order create/confirm karein - Armada integration skip ho jayegi aur order normally create hoga.

## Important Notes

1. **Order will still be created** - Armada failure se order creation block nahi hota
2. **Manual tracking** - Agar Armada disable hai, to manually tracking add karna padega
3. **Re-enable later** - Jab API keys fix ho jayen, to `ARMADA_ENABLED=true` kar do

## Re-enable Armada

Jab API keys fix ho jayen:

1. **Update .env**:
   ```env
   ARMADA_ENABLED=true
   ARMADA_MAIN_API_KEY=your_new_main_api_key
   ARMADA_API_KEY=your_new_api_key
   ```

2. **Clear config cache**:
   ```bash
   php artisan config:clear
   php artisan config:cache
   ```

3. **Test order creation**

## Current Status

- ✅ Order creation works even if Armada fails
- ✅ All authorization formats tried (5 attempts)
- ❌ All formats returning 401 - API keys need to be verified/updated

## Next Steps

1. **Verify API Keys in Armada Dashboard**
   - Login to Armada Merchant Dashboard
   - Go to Settings → API Settings
   - Copy fresh API keys
   - Update `.env` file

2. **Or Temporarily Disable**
   - Set `ARMADA_ENABLED=false` in `.env`
   - Orders will create without Armada integration

---

**Last Updated**: 2025-11-27

