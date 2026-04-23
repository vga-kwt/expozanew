# Armada Enable Karne Ka Guide

## Problem
Armada data store nahi ho raha kyunki **Armada disabled hai**.

## Current Status
- ❌ `ARMADA_ENABLED=false` (disabled)
- ✅ API keys set hain
- ✅ Branch ID set hai

## Solution: Armada Enable Karo

### Step 1: .env File Mein Change Karo

`.env` file open karo aur yeh line find karo:

```env
ARMADA_ENABLED=false
```

Isko change karo:

```env
ARMADA_ENABLED=true
```

### Step 2: Config Cache Clear Karo

```bash
php artisan config:clear
php artisan config:cache
```

### Step 3: Verify Karo

```bash
php artisan tinker
```

```php
echo config('armada.enabled'); // Should output: 1 or true
```

### Step 4: Test Karo

1. Ek new order confirm karo
2. phpMyAdmin mein check karo:
   ```sql
   SELECT 
       id,
       order_code,
       armada_order_id,
       armada_tracking_number,
       is_armada_synced
   FROM orders
   ORDER BY id DESC
   LIMIT 1;
   ```

## Important Notes

1. **Agar API keys invalid hain**, to phir bhi 401 error aayega
2. **Lekin ab Armada integration try karega** - pehle to skip ho raha tha
3. **API keys fix karni padegi** taaki data actually store ho

## Next Steps After Enabling

1. ✅ Armada enable karo (above steps)
2. ⚠️ Agar phir bhi 401 aaye, to API keys fix karo
3. ✅ Fresh API keys Armada Dashboard se lo
4. ✅ `.env` file update karo
5. ✅ Test karo

---

**Current Issue**: Armada disabled hai, isliye code Armada integration skip kar raha hai.

