<?php

namespace App\Traits;

use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Storage;

trait HandlesFileUploads
{
    /**
     * Get the default storage disk
     *
     * @return string
     */
    protected function getStorageDisk(): string
    {
        return config('filesystems.default', 's3');
    }

    /**
     * Upload a file to storage
     *
     * @param UploadedFile $file
     * @param string $directory
     * @param string|null $disk
     * @return string|false
     */
    protected function uploadFile(UploadedFile $file, string $directory = 'uploads', ?string $disk = null): string|false
    {
        $disk = $disk ?? $this->getStorageDisk();
        
        if (!$file->isValid()) {
            return false;
        }

        return $file->store($directory, $disk);
    }

    /**
     * Upload a file with a custom name
     *
     * @param UploadedFile $file
     * @param string $directory
     * @param string $filename
     * @param string|null $disk
     * @return string|false
     */
    protected function uploadFileAs(UploadedFile $file, string $directory, string $filename, ?string $disk = null): string|false
    {
        $disk = $disk ?? $this->getStorageDisk();
        
        if (!$file->isValid()) {
            return false;
        }

        return $file->storeAs($directory, $filename, $disk);
    }

    /**
     * Delete a file from storage
     *
     * @param string $path
     * @param string|null $disk
     * @return bool
     */
    protected function deleteFile(string $path, ?string $disk = null): bool
    {
        $disk = $disk ?? $this->getStorageDisk();
        
        if (Storage::disk($disk)->exists($path)) {
            return Storage::disk($disk)->delete($path);
        }

        return false;
    }

    /**
     * Delete multiple files from storage
     *
     * @param array $paths
     * @param string|null $disk
     * @return bool
     */
    protected function deleteFiles(array $paths, ?string $disk = null): bool
    {
        $disk = $disk ?? $this->getStorageDisk();
        
        $existingPaths = array_filter($paths, fn($path) => Storage::disk($disk)->exists($path));
        
        if (empty($existingPaths)) {
            return false;
        }

        return Storage::disk($disk)->delete($existingPaths);
    }

    /**
     * Get file URL
     *
     * @param string $path
     * @param string|null $disk
     * @return string|null
     */
    protected function getFileUrl(string $path, ?string $disk = null): ?string
    {
        $disk = $disk ?? $this->getStorageDisk();
        
        if (!Storage::disk($disk)->exists($path)) {
            return null;
        }

        return Storage::disk($disk)->url($path);
    }

    /**
     * Get temporary URL for a file (S3 only)
     *
     * @param string $path
     * @param int $expirationMinutes
     * @param string|null $disk
     * @return string|null
     */
    protected function getTemporaryUrl(string $path, int $expirationMinutes = 60, ?string $disk = null): ?string
    {
        $disk = $disk ?? $this->getStorageDisk();
        
        if ($disk !== 's3' || !Storage::disk($disk)->exists($path)) {
            return null;
        }

        return Storage::disk('s3')->temporaryUrl($path, now()->addMinutes($expirationMinutes));
    }

    /**
     * Check if file exists
     *
     * @param string $path
     * @param string|null $disk
     * @return bool
     */
    protected function fileExists(string $path, ?string $disk = null): bool
    {
        $disk = $disk ?? $this->getStorageDisk();
        
        return Storage::disk($disk)->exists($path);
    }

    /**
     * Move/Rename a file
     *
     * @param string $from
     * @param string $to
     * @param string|null $disk
     * @return bool
     */
    protected function moveFile(string $from, string $to, ?string $disk = null): bool
    {
        $disk = $disk ?? $this->getStorageDisk();
        
        if (!Storage::disk($disk)->exists($from)) {
            return false;
        }

        return Storage::disk($disk)->move($from, $to);
    }

    /**
     * Copy a file
     *
     * @param string $from
     * @param string $to
     * @param string|null $disk
     * @return bool
     */
    protected function copyFile(string $from, string $to, ?string $disk = null): bool
    {
        $disk = $disk ?? $this->getStorageDisk();
        
        if (!Storage::disk($disk)->exists($from)) {
            return false;
        }

        return Storage::disk($disk)->copy($from, $to);
    }
}

