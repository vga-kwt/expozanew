# Armada API Environment Variables Setup

## Required Environment Variables

`.env` file में निम्नलिखित variables add करें:

```env
# ============================================
# ARMADA API CONFIGURATION
# ============================================

# Enable/Disable Armada Integration
ARMADA_ENABLED=true

# Armada API Base URL
ARMADA_BASE_URL=https://api.armadadelivery.com

# Main API Key (from Armada Dashboard)
ARMADA_MAIN_API_KEY=main_52e1cc75e683fb92b8fe472mi11h723

# API Key (for API requests)
ARMADA_API_KEY=d9049c2d-37af-4812-a658-34a997736b56

# Branch Name
ARMADA_BRANCH_ID=NAQSH

# Webhook Key (for order-webhook-key header)
ARMADA_WEBHOOK_KEY=vE6gH8Rt2L1sK9w

# Webhook URL (where Armada will send updates)
ARMADA_WEBHOOK_URL=https://webhook.site/378d8934-0de5-48cd-9ed4-aeda171faabc

# API Request Timeout (in seconds)
ARMADA_TIMEOUT=30

# Default Currency
ARMADA_DEFAULT_CURRENCY=KWD

# Default Country Code
ARMADA_DEFAULT_COUNTRY=KW
```

## Quick Setup

1. **Open `.env` file**
2. **Add these variables at the end:**

```env
ARMADA_ENABLED=true
ARMADA_BASE_URL=https://api.armadadelivery.com
ARMADA_MAIN_API_KEY=main_52e1cc75e683fb92b8fe472mi11h723
ARMADA_API_KEY=d9049c2d-37af-4812-a658-34a997736b56
ARMADA_BRANCH_ID=NAQSH
ARMADA_WEBHOOK_KEY=vE6gH8Rt2L1sK9w
ARMADA_WEBHOOK_URL=https://webhook.site/378d8934-0de5-48cd-9ed4-aeda171faabc
ARMADA_TIMEOUT=30
ARMADA_DEFAULT_CURRENCY=KWD
ARMADA_DEFAULT_COUNTRY=KW
```

3. **Clear config cache:**

```bash
php artisan config:clear
php artisan config:cache
```

## Verification

Test करने के लिए:

```bash
php artisan tinker
```

```php
echo config('armada.enabled');
echo config('armada.api_key');
echo config('armada.branch_id');
```

## API Endpoints Used

- **Create Order:** `POST /v0/deliveries`
- **Get Order:** `GET /v0/deliveries/{id}`
- **Cancel Order:** `POST /v0/deliveries/{id}/cancel`
- **Update Order:** `PUT /v0/deliveries/{id}`

## Headers Used

- `Authorization: Key {ARMADA_API_KEY}`
- `order-webhook-key: {ARMADA_WEBHOOK_KEY}`
- `Content-Type: application/json`

---

**Note:** Production में deploy करने से पहले webhook URL को अपने actual domain से replace करें।
