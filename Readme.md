# Expo Project Setup Guide

## Requirements
- PHP 8.1+
- Composer
- Node.js 16+
- npm or yarn
- MySQL or MariaDB
- XAMPP (recommended for Windows)

## 1. Clone the Repository
```bash
git clone <your-repo-url> expo-project
cd expo-project
```

## 2. Backend Setup (Laravel)

### Install PHP Dependencies
```bash
composer install
```

### Copy and Configure Environment
```bash
cp .env.example .env
```
- Edit `.env` and set your database credentials and other environment variables as needed.

### Generate Application Key
```bash
php artisan key:generate
```

### Run Migrations and Seeders
```bash
php artisan migrate --seed
```

### (Optional) Storage Link
```bash
php artisan storage:link
```

### Start Laravel Development Server
```bash
php artisan serve
```

## 3. Frontend Setup (React + Vite)

### Install Node Dependencies
```bash
cd resources/js
npm install
# or
# yarn install
```

### Build Frontend Assets
```bash
npm run build
# or
# yarn build
```

### For Development (Hot Reload)
```bash
npm run dev
# or
# yarn dev
```

## 4. Installation & Setup Flow
- **Clone the Repository:**
  - Use `git clone <your-repo-url> expo-project` to download the project.
- **Backend Setup (Laravel):**
  - Install PHP dependencies: `composer install`
  - Copy and configure environment: `cp .env.example .env`, then edit `.env` for your database/mail settings.
  - Generate application key: `php artisan key:generate`
  - Run migrations and seeders: `php artisan migrate --seed`
  - (Optional) Link storage: `php artisan storage:link`
  - Start the Laravel server: `php artisan serve`
- **Frontend Setup (React + Vite):**
  - Go to `resources/js`
  - Install node dependencies: `npm install` or `yarn install`
  - Build frontend assets: `npm run build` or `yarn build`
  - For development: `npm run dev` or `yarn dev`
- **Testing & Troubleshooting:**
  - Run tests: `php artisan test` or `./vendor/bin/pest`
  - Clear cache/config/routes/views as needed
  - If on Windows, use XAMPP for easy Apache/MySQL management

## 5. Project Flow
- **Authentication & Authorization:** Secure login/registration for users, vendors, and admins. Role-based access control for all features.
- **User Management:**
  - Admins: Create, edit, suspend, and delete users and vendors.
  - Users: View and update their profiles, manage passwords.
- **Expo Management:**
  - Vendors/Admins: Create, edit, and manage expos, assign products to expos, manage expo slots.
  - Users: View available expos, book slots, and manage their bookings.
- **Order Management:**
  - Users: View and manage their orders, track order status.
  - Admins: View, filter, and manage all orders, process refunds/cancellations.
- **Product Management:**
  - Vendors/Admins: Add, edit, assign, and manage products. Set product availability for expos.
  - Users: Browse products by expo, category, or search.
- **Finance & Reporting:**
  - Admins: View transactions, payouts, and generate/export financial reports with advanced filters.
  - Vendors: View sales and payout status.
- **Content Management (CMS):**
  - Admins: Manage CMS pages, FAQs, banners, and static content.
- **Notifications:**
  - Users/Vendors: Receive real-time notifications for orders, bookings, payouts, and important events.
- **Export & Data Tools:**
  - Export data (orders, users, financials) as CSV with applied filters.
- **Audit & Logs:**
  - Admins: View audit logs for critical actions and changes.

## 6. Useful Commands
- Run tests:
  ```bash
  php artisan test
  # or
  ./vendor/bin/pest
  ```
- Clear cache:
  ```bash
  php artisan cache:clear
  php artisan config:clear
  php artisan route:clear
  php artisan view:clear
  ```
- Re-run migrations:
  ```bash
  php artisan migrate:fresh --seed
  ```

## 7. Troubleshooting
- Ensure your `.env` is configured correctly for database and mail.
- If you get permission errors, try:
  ```bash
  chmod -R 775 storage bootstrap/cache
  ```
- For Windows, use XAMPP to manage Apache/MySQL easily.

---

For more details, see the code comments and documentation in each module.
