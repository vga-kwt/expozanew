<?php

namespace App\Services;

use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Storage;

class ImageService
{
    /**
     * Upload a single image
     *
     * @param UploadedFile|null $image
     * @param string $directory
     * @param array $options
     * @return string|null
     */
    public function uploadImage(?UploadedFile $image, string $directory = 'products', array $options = []): ?string
    {
        if (!$image || !$image->isValid()) {
            return null;
        }

        $this->validateImage($image, $options);
        $filename = $this->generateUniqueFilename($image);
        $disk = config('filesystems.default', 's3');
        
        // Upload to configured disk (S3 or public)
        $path = $image->storeAs($directory, $filename, $disk);
        
        return $path;
    }

    /**
     * Delete an image from storage
     *
     * @param string|null $imagePath
     * @return bool
     */
    public function deleteImage(?string $imagePath): bool
    {
        if (!$imagePath) {
            return false;
        }

        $disk = config('filesystems.default', 's3');
        
        // Use Storage facade for both S3 and local
        try {
            $exists = Storage::disk($disk)->exists($imagePath);
        } catch (\Throwable $e) {
            $exists = false;
        }

        if ($exists) {
            return Storage::disk($disk)->delete($imagePath);
        }

        return false;
    }

    /**
     * Update image (delete old and upload new)
     *
     * @param UploadedFile|null $newImage
     * @param string|null $oldImagePath
     * @param string $directory
     * @param array $options
     * @return string|null
     */
    public function updateImage(?UploadedFile $newImage, ?string $oldImagePath, string $directory = 'products', array $options = []): ?string
    {
        // Delete old image if exists
        if ($oldImagePath) {
            $this->deleteImage($oldImagePath);
        }

        // Upload new image
        return $this->uploadImage($newImage, $directory, $options);
    }

    /**
     * Validate image file
     *
     * @param UploadedFile $image
     * @param array $options
     * @throws \Exception
     */
    private function validateImage(UploadedFile $image, array $options = []): void
    {
        $maxSize = $options['max_size'] ?? 2048; // 2MB default
        $allowedMimes = $options['allowed_mimes'] ?? ['jpeg', 'png', 'jpg', 'gif', 'svg'];

        if (!$image->isValid()) {
            throw new \Exception('Invalid image file');
        }

        if ($image->getSize() > ($maxSize * 1024)) {
            throw new \Exception("Image size must be less than {$maxSize}KB");
        }

        if (!in_array($image->getClientOriginalExtension(), $allowedMimes)) {
            throw new \Exception('Invalid image format. Allowed: ' . implode(', ', $allowedMimes));
        }
    }

    /**
     * Generate unique filename
     *
     * @param UploadedFile $image
     * @return string
     */
    private function generateUniqueFilename(UploadedFile $image): string
    {
        $extension = $image->getClientOriginalExtension();
        $filename = uniqid() . '_' . time() . '.' . $extension;
        
        return $filename;
    }

    /**
     * Get image URL for public access
     *
     * @param string|null $imagePath
     * @return string|null
     */
    public function getImageUrl(?string $imagePath): ?string
    {
        if (!$imagePath) {
            return null;
        }

        $disk = config('filesystems.default', 's3');
        
        // For S3, get the full URL; for local, use asset
        if ($disk === 's3') {
            return Storage::disk('s3')->url($imagePath);
        }
        
        return asset('storage/' . ltrim($imagePath, '/'));
    }
} 