# MyFatoorah API Key Setup Guide

## Problem
You're getting "Invalid API key" error (HTTP 401) when trying to make payments.

## Solution: Get a Valid API Key from MyFatoorah Dashboard

### Step 1: Login to MyFatoorah Dashboard
1. Go to: https://portal.myfatoorah.com/
2. Login with your **Super Master Account** credentials

### Step 2: Navigate to API Key Settings
1. Click on **"Integration Settings"** in the left menu
2. Click on **"API Key"** option

### Step 3: Generate New Test API Key
Since your `test_mode` is set to `true` in config, you need a **Test API Key**:

1. Click on **"Create"** button
2. Select **"Test"** mode (not Live)
3. Select your country: **KWT (Kuwait)**
4. Set appropriate permissions (make sure payment permissions are enabled)
5. Click **"Generate"** or **"Create"**
6. **Copy the generated API key** immediately (you won't be able to see it again!)

### Step 4: Update API Key in .env File
1. Open: `.env` file in your project root
2. Find or add these lines:
   ```env
   MYFATOORAH_MODE=test
   MYFATOORAH_API_KEY=YOUR_NEW_TEST_API_KEY_HERE
   ```
3. Replace `YOUR_NEW_TEST_API_KEY_HERE` with your actual test API key from MyFatoorah dashboard
4. Make sure `MYFATOORAH_MODE=test` (for test mode) or `MYFATOORAH_MODE=live` (for live mode)
5. Save the `.env` file

### Step 5: Clear Config Cache
Run this command in your terminal:
```bash
php artisan config:clear
```

### Step 6: Test the Payment
Try making a payment again. It should work now!

## Important Notes

### Test vs Live API Keys
- **Test API Key**: Use when `test_mode => true` in config
- **Live API Key**: Use when `test_mode => false` in config
- **Never mix them!** Test key won't work in live mode and vice versa.

### API Key Format
- MyFatoorah API keys are usually very long (600+ characters)
- They contain letters, numbers, and special characters
- Make sure you copy the **entire** key without any spaces

### API Key Permissions
When creating the API key, make sure these permissions are enabled:
- ✅ Send Payment
- ✅ Get Payment Status
- ✅ Execute Payment
- ✅ Initiate Payment

### Country Code
Make sure the country code matches:
- Your MyFatoorah account country
- The `country_iso` in your config file
- Currently set to: `KWT` (Kuwait)

## Troubleshooting

### Still Getting 401 Error?
1. **Verify API key is correct**: Copy-paste again from dashboard
2. **Check test_mode**: Must match API key type (test/live)
3. **Check country code**: Must match your MyFatoorah account
4. **Clear cache**: Run `php artisan config:clear`
5. **Check API key expiration**: Generate a new one if expired
6. **Verify permissions**: Make sure payment permissions are enabled

### API Key Not Working?
- Make sure you're using **Test API Key** for test mode
- Make sure you're using **Live API Key** for live mode
- Check if API key has expired (generate new one)
- Verify country code matches your account

## Support
If issues persist, contact MyFatoorah support:
- Email: tech@myfatoorah.com
- Dashboard: https://portal.myfatoorah.com/

