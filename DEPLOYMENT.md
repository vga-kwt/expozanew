# Deployment Instructions

## Building Frontend Assets for Production

Before deploying to production, you must build the frontend assets using Vite.

### Steps:

1. **Install Dependencies** (if not already installed):
   ```bash
   npm install
   ```

2. **Build for Production**:
   ```bash
   npm run build
   ```

   This will create the `public/build/manifest.json` file and all compiled assets.

3. **Verify Build**:
   Check that the following files exist:
   - `public/build/manifest.json`
   - `public/build/assets/` (directory with compiled JS/CSS files)

### Important Notes:

- The build process must be run on the server or in your CI/CD pipeline
- Never commit the `public/build/` directory to version control (it's in `.gitignore`)
- After each deployment, run `npm run build` to regenerate assets
- If you see "Vite manifest not found" error, it means the build step was skipped

### Troubleshooting:

If you see the error: `ViteManifestNotFoundException`

1. Check if `public/build/manifest.json` exists
2. If not, run `npm run build`
3. Ensure the `public/build/` directory has proper permissions (755)
4. Clear Laravel cache: `php artisan config:clear` and `php artisan cache:clear`

