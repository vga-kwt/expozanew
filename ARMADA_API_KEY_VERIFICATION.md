# Armada API Key Verification & Troubleshooting

## Current Issue: 401 Unauthorized

Even with `main_api_key`, we're getting 401 Unauthorized. This suggests:

1. **API Key might be invalid/expired**
2. **Authorization format might be wrong**
3. **Base URL might be incorrect**
4. **API keys might not match between .env and Armada Dashboard**

## Quick Verification Steps

### Step 1: Verify API Keys in Armada Dashboard

1. Login to **Armada Merchant Dashboard**
2. Go to **Settings → API Settings**
3. Check:
   - ✅ Main API Key: `main_52e1cc75e683fb92b8fe472mi11h723`
   - ✅ API Key: `d9049c2d-37af-4812-a658-34a997736b56`
   - ✅ Branch ID: `NAQSH`
   - ✅ Webhook Key: `vE6gH8Rt2L1sK9w`

### Step 2: Check .env File

Open `.env` file and verify:

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

**Important**: 
- No extra spaces
- No quotes around values
- Exact match with Armada Dashboard

### Step 3: Clear Config Cache

```bash
php artisan config:clear
php artisan config:cache
```

### Step 4: Test Configuration

```bash
php artisan tinker
```

```php
// Check configuration
echo "Enabled: " . config('armada.enabled') . "\n";
echo "Base URL: " . config('armada.base_url') . "\n";
echo "Main API Key: " . substr(config('armada.main_api_key'), 0, 20) . "...\n";
echo "API Key: " . substr(config('armada.api_key'), 0, 20) . "...\n";
echo "Branch ID: " . config('armada.branch_id') . "\n";
```

## Updated Code Behavior

The code now automatically tries multiple authorization formats:

1. **First attempt**: `Key {main_api_key}` (current)
2. **If 401, tries**:
   - `Bearer {main_api_key}`
   - `{main_api_key}` (no prefix)
   - `Key {regular_api_key}`
   - `Bearer {regular_api_key}`
   - `{regular_api_key}` (no prefix)

## Check Logs for Details

After trying an order, check logs:

```bash
tail -f storage/logs/laravel.log | grep -i armada
```

Look for:
- `Retrying with alternative authorization format` - Shows which formats are being tried
- `Armada API request succeeded` - Success message
- `Armada API still returning 401 after trying all authorization formats` - All formats failed

## Common Issues & Solutions

### Issue 1: API Keys Don't Match Dashboard

**Symptom**: 401 even after trying all formats

**Solution**:
1. Copy fresh API keys from Armada Dashboard
2. Update `.env` file
3. Run `php artisan config:clear`
4. Test again

### Issue 2: Wrong Base URL

**Symptom**: 401 or connection errors

**Solution**:
- **Staging**: `https://staging.api.armadadelivery.com`
- **Production**: `https://api.armadadelivery.com`

Make sure you're using the correct URL for your environment.

### Issue 3: API Keys Expired

**Symptom**: 401 after working previously

**Solution**:
1. Go to Armada Dashboard
2. Regenerate API keys
3. Update `.env` file
4. Clear config cache

### Issue 4: Branch ID Mismatch

**Symptom**: 401 with correct API keys

**Solution**:
- Verify `ARMADA_BRANCH_ID` matches exactly with Armada Dashboard
- Case-sensitive: `NAQSH` vs `naqsh` matters

## Manual API Test

You can test the API directly using curl:

```bash
curl -X POST https://staging.api.armadadelivery.com/v0/deliveries \
  -H "Authorization: Key main_52e1cc75e683fb92b8fe472mi11h723" \
  -H "Content-Type: application/json" \
  -H "order-webhook-key: vE6gH8Rt2L1sK9w" \
  -H "branch-id: NAQSH" \
  -d '{
    "platformName": "expoza",
    "platformData": {
      "orderId": "TEST001",
      "name": "Test Customer",
      "phone": "+96512345678",
      "area": "Al Asimah",
      "street": "Test Street",
      "amount": "100.000",
      "paymentType": "paid"
    },
    "branchId": "NAQSH"
  }'
```

If this also returns 401, the issue is with the API keys themselves, not the code.

## Next Steps

1. ✅ **Verify API keys in Armada Dashboard**
2. ✅ **Update .env file if needed**
3. ✅ **Clear config cache**
4. ✅ **Test order creation**
5. ✅ **Check logs for which authorization format worked (if any)**

## Contact Armada Support

If all formats fail and API keys are correct:

1. Contact Armada Support
2. Provide them:
   - Your branch ID: `NAQSH`
   - API key type you're using
   - Base URL you're using
   - Error logs
   - Request headers (from logs)

---

**Last Updated**: 2025-11-27
**Status**: Enhanced with multiple authorization format retry logic

