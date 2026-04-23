<?php

namespace App\Services;

use Illuminate\Http\UploadedFile;
use Illuminate\Support\Collection;

class MultipleImageService
{
    protected ImageService $imageService;

    public function __construct(ImageService $imageService)
    {
        $this->imageService = $imageService;
    }

    /**
     * Upload multiple images
     *
     * @param array|null $images
     * @param string $directory
     * @param array $options
     * @return array
     */
    public function uploadMultipleImages(?array $images, string $directory = 'products', array $options = []): array
    {
        if (!$images || empty($images)) {
            return [];
        }

        $uploadedPaths = [];

        foreach ($images as $image) {
            if ($image instanceof UploadedFile && $image->isValid()) {
                $path = $this->imageService->uploadImage($image, $directory, $options);
                if ($path) {
                    $uploadedPaths[] = $path;
                }
            }
        }

        return $uploadedPaths;
    }

    /**
     * Add new images to existing gallery
     *
     * @param array|null $newImages
     * @param array $existingGallery
     * @param string $directory
     * @param array $options
     * @return array
     */
    public function addToGallery(?array $newImages, array $existingGallery = [], string $directory = 'products', array $options = []): array
    {
        $uploadedPaths = $this->uploadMultipleImages($newImages, $directory, $options);
        return array_merge($existingGallery, $uploadedPaths);
    }

    /**
     * Remove images from gallery
     *
     * @param array $imagesToRemove
     * @param array $currentGallery
     * @return array
     */
    public function removeFromGallery(array $imagesToRemove, array $currentGallery): array
    {
        foreach ($imagesToRemove as $imagePath) {
            $this->imageService->deleteImage($imagePath);
            $currentGallery = array_filter($currentGallery, function($path) use ($imagePath) {
                return $path !== $imagePath;
            });
        }

        return array_values($currentGallery);
    }

    /**
     * Update gallery (remove old images and add new ones)
     *
     * @param array|null $newImages
     * @param array $currentGallery
     * @param array $imagesToRemove
     * @param string $directory
     * @param array $options
     * @return array
     */
    public function updateGallery(?array $newImages, array $currentGallery = [], array $imagesToRemove = [], string $directory = 'products', array $options = []): array
    {
        $galleryAfterRemoval = $this->removeFromGallery($imagesToRemove, $currentGallery);
        return $this->addToGallery($newImages, $galleryAfterRemoval, $directory, $options);
    }

    /**
     * Get gallery URLs for public access
     *
     * @param array $gallery
     * @return array
     */
    public function getGalleryUrls(array $gallery): array
    {
        $urls = [];
        $disk = config('filesystems.default', 'public');

        foreach ($gallery as $imagePath) {
            // Only add images that actually exist
            if (\Illuminate\Support\Facades\Storage::disk($disk)->exists($imagePath)) {
                $url = $this->imageService->getImageUrl($imagePath);
                if ($url) {
                    $urls[] = [
                        'url' => $url,
                        'path' => $imagePath,
                        'name' => basename($imagePath)
                    ];
                }
            }
        }

        return $urls;
    }

    /**
     * Validate multiple images
     *
     * @param array|null $images
     * @param array $options
     * @return bool
     */
    public function validateMultipleImages(?array $images, array $options = []): bool
    {
        if (!$images) {
            return true;
        }

        $maxCount = $options['max_count'] ?? 10;
        $maxSize = $options['max_size'] ?? 2048; // 2MB per image

        if (count($images) > $maxCount) {
            throw new \Exception("Maximum {$maxCount} images allowed");
        }

        foreach ($images as $image) {
            if ($image instanceof UploadedFile) {
                if ($image->getSize() > ($maxSize * 1024)) {
                    throw new \Exception("Each image must be less than {$maxSize}KB");
                }
            }
        }

        return true;
    }

    /**
     * Get total size of gallery
     *
     * @param array $gallery
     * @return int
     */
    public function getGallerySize(array $gallery): int
    {
        $totalSize = 0;
        $disk = config('filesystems.default', 's3');

        foreach ($gallery as $imagePath) {
            if (\Illuminate\Support\Facades\Storage::disk($disk)->exists($imagePath)) {
                $totalSize += \Illuminate\Support\Facades\Storage::disk($disk)->size($imagePath);
            }
        }

        return $totalSize;
    }
} 