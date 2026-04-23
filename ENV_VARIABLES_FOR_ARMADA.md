# Environment Variables for Armada API Integration

## Required Environment Variables

`.env` file में निम्नलिखित variables add करें:

```env
# ============================================
# ARMADA API CONFIGURATION
# ============================================

# Enable/Disable Armada Integration
ARMADA_ENABLED=true

# Armada API Base URL
ARMADA_BASE_URL=https://api.armada.delivery

# Your Armada API Key (Testing or Production)
ARMADA_API_KEY=your_api_key_here

# Your Armada Branch ID
ARMADA_BRANCH_ID=your_branch_id_here

# API Request Timeout (in seconds)
ARMADA_TIMEOUT=30

# Webhook Secret (for verifying webhook requests from Armada)
ARMADA_WEBHOOK_SECRET=your_webhook_secret_here

# Webhook URL (your application's webhook endpoint)
ARMADA_WEBHOOK_URL=/api/webhooks/armada

# Default Currency (KWD, SAR, BHD, etc.)
ARMADA_DEFAULT_CURRENCY=KWD

# Default Country Code (KW, SA, BH, etc.)
ARMADA_DEFAULT_COUNTRY=KW
```

## Step-by-Step Setup

### Step 1: Open .env File
```bash
nano .env
# or
notepad .env
```

### Step 2: Add Variables
`.env` file के अंत में यह section add करें:

```env
# Armada API Configuration
ARMADA_ENABLED=true
ARMADA_BASE_URL=https://api.armada.delivery
ARMADA_API_KEY=your_testing_api_key_here
ARMADA_BRANCH_ID=your_branch_id_here
ARMADA_TIMEOUT=30
ARMADA_WEBHOOK_SECRET=your_webhook_secret_here
ARMADA_WEBHOOK_URL=/api/webhooks/armada
ARMADA_DEFAULT_CURRENCY=KWD
ARMADA_DEFAULT_COUNTRY=KW
```

### Step 3: Replace Placeholder Values

**ARMADA_API_KEY**: 
- Armada Merchant Dashboard → Settings → API Settings
- Copy your "Main API Key" या "API Key"

**ARMADA_BRANCH_ID**:
- Armada Merchant Dashboard → Settings → API Settings
- Copy your Branch ID

**ARMADA_WEBHOOK_SECRET**:
- Armada Merchant Dashboard → Settings → API Settings
- Webhook Secret generate करें या existing secret use करें

### Step 4: Clear Config Cache

```bash
php artisan config:clear
php artisan config:cache
```

## Example .env Configuration

```env
# Existing variables...
APP_NAME=Expoza
APP_ENV=local
APP_KEY=base64:...
APP_DEBUG=true
APP_URL=http://localhost

# Database...
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=expoza
DB_USERNAME=root
DB_PASSWORD=

# ... other existing variables ...

# ============================================
# ARMADA API CONFIGURATION
# ============================================
ARMADA_ENABLED=true
ARMADA_BASE_URL=https://api.armada.delivery
ARMADA_API_KEY=ak_test_1234567890abcdef
ARMADA_BRANCH_ID=br_1234567890
ARMADA_TIMEOUT=30
ARMADA_WEBHOOK_SECRET=whsec_1234567890abcdef
ARMADA_WEBHOOK_URL=/api/webhooks/armada
ARMADA_DEFAULT_CURRENCY=KWD
ARMADA_DEFAULT_COUNTRY=KW
```

## Testing vs Production

### Testing Environment
```env
ARMADA_ENABLED=true
ARMADA_BASE_URL=https://api.armada.delivery
ARMADA_API_KEY=your_testing_api_key
ARMADA_BRANCH_ID=your_testing_branch_id
```

### Production Environment
```env
ARMADA_ENABLED=true
ARMADA_BASE_URL=https://api.armada.delivery
ARMADA_API_KEY=your_production_api_key
ARMADA_BRANCH_ID=your_production_branch_id
```

## Verification

### Check if Variables are Loaded
```bash
php artisan tinker
```

```php
echo config('armada.enabled');
echo config('armada.api_key');
echo config('armada.branch_id');
```

### Test Connection
```php
$armadaService = app(\App\Services\ArmadaService::class);
print_r($armadaService->getConfiguration());
```

## Important Notes

1. **Never commit .env file** to version control
2. **Use different API keys** for testing and production
3. **Keep webhook secret secure** - don't share it
4. **Update .env.example** file with placeholder values

## Troubleshooting

### Variables Not Loading
```bash
# Clear all caches
php artisan config:clear
php artisan cache:clear
php artisan config:cache
```

### Check Current Configuration
```bash
php artisan config:show armada
```

### Verify .env File
```bash
# Check if variables exist
grep ARMADA .env
```

## Security Best Practices

1. ✅ Use environment-specific API keys
2. ✅ Never hardcode API keys in code
3. ✅ Rotate API keys regularly
4. ✅ Use strong webhook secrets
5. ✅ Restrict API key permissions in Armada dashboard

---

**After adding variables, don't forget to:**
1. Save .env file
2. Run `php artisan config:clear`
3. Run `php artisan config:cache`
4. Test the integration
