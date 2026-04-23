<?php

namespace App\Services;

use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;

/**
 * S3 Service for handling AWS S3 operations
 * 
 * This service provides a centralized way to interact with AWS S3
 * for file uploads, downloads, and management.
 */
class S3Service
{
    /**
     * Get the configured storage disk
     *
     * @return string
     */
    public function getDisk(): string
    {
        return config('filesystems.default', 's3');
    }

    /**
     * Check if S3 is the active storage driver
     *
     * @return bool
     */
    public function isS3Active(): bool
    {
        return $this->getDisk() === 's3';
    }

    /**
     * Upload a file to S3
     *
     * @param UploadedFile $file
     * @param string $directory
     * @param string|null $filename
     * @param string $visibility
     * @return string|false Path to uploaded file or false on failure
     */
    public function upload(UploadedFile $file, string $directory = 'uploads', ?string $filename = null, string $visibility = 'public'): string|false
    {
        if (!$file->isValid()) {
            return false;
        }

        $filename = $filename ?? $this->generateUniqueFilename($file);
        $path = $directory . '/' . $filename;

        $uploaded = Storage::disk($this->getDisk())->putFileAs(
            $directory,
            $file,
            $filename,
            $visibility
        );

        return $uploaded ?: false;
    }

    /**
     * Upload file content directly to S3
     *
     * @param string $path
     * @param string $content
     * @param string $visibility
     * @return bool
     */
    public function put(string $path, string $content, string $visibility = 'public'): bool
    {
        return Storage::disk($this->getDisk())->put($path, $content, $visibility);
    }

    /**
     * Delete a file from S3
     *
     * @param string $path
     * @return bool
     */
    public function delete(string $path): bool
    {
        if ($this->exists($path)) {
            return Storage::disk($this->getDisk())->delete($path);
        }

        return false;
    }

    /**
     * Delete multiple files from S3
     *
     * @param array $paths
     * @return bool
     */
    public function deleteMultiple(array $paths): bool
    {
        $existingPaths = array_filter($paths, fn($path) => $this->exists($path));
        
        if (empty($existingPaths)) {
            return false;
        }

        return Storage::disk($this->getDisk())->delete($existingPaths);
    }

    /**
     * Check if a file exists on S3
     *
     * @param string $path
     * @return bool
     */
    public function exists(string $path): bool
    {
        return Storage::disk($this->getDisk())->exists($path);
    }

    /**
     * Get the URL for a file
     *
     * @param string $path
     * @return string|null
     */
    public function url(string $path): ?string
    {
        if (!$this->exists($path)) {
            return null;
        }

        if ($this->isS3Active()) {
            return Storage::disk('s3')->url($path);
        }

        return asset('storage/' . ltrim($path, '/'));
    }

    /**
     * Generate a temporary URL for private files
     *
     * @param string $path
     * @param int $expirationMinutes
     * @return string|null
     */
    public function temporaryUrl(string $path, int $expirationMinutes = 60): ?string
    {
        if (!$this->exists($path) || !$this->isS3Active()) {
            return null;
        }

        return Storage::disk('s3')->temporaryUrl(
            $path,
            now()->addMinutes($expirationMinutes)
        );
    }

    /**
     * Get file size in bytes
     *
     * @param string $path
     * @return int|false
     */
    public function size(string $path): int|false
    {
        if (!$this->exists($path)) {
            return false;
        }

        return Storage::disk($this->getDisk())->size($path);
    }

    /**
     * Get file's last modified time
     *
     * @param string $path
     * @return int|false
     */
    public function lastModified(string $path): int|false
    {
        if (!$this->exists($path)) {
            return false;
        }

        return Storage::disk($this->getDisk())->lastModified($path);
    }

    /**
     * Get file content
     *
     * @param string $path
     * @return string|false
     */
    public function get(string $path): string|false
    {
        if (!$this->exists($path)) {
            return false;
        }

        return Storage::disk($this->getDisk())->get($path);
    }

    /**
     * Download a file
     *
     * @param string $path
     * @param string|null $name
     * @return \Symfony\Component\HttpFoundation\StreamedResponse
     */
    public function download(string $path, ?string $name = null)
    {
        return Storage::disk($this->getDisk())->download($path, $name);
    }

    /**
     * List all files in a directory
     *
     * @param string $directory
     * @param bool $recursive
     * @return array
     */
    public function files(string $directory = '', bool $recursive = false): array
    {
        if ($recursive) {
            return Storage::disk($this->getDisk())->allFiles($directory);
        }

        return Storage::disk($this->getDisk())->files($directory);
    }

    /**
     * List all directories in a path
     *
     * @param string $directory
     * @param bool $recursive
     * @return array
     */
    public function directories(string $directory = '', bool $recursive = false): array
    {
        if ($recursive) {
            return Storage::disk($this->getDisk())->allDirectories($directory);
        }

        return Storage::disk($this->getDisk())->directories($directory);
    }

    /**
     * Copy a file
     *
     * @param string $from
     * @param string $to
     * @return bool
     */
    public function copy(string $from, string $to): bool
    {
        if (!$this->exists($from)) {
            return false;
        }

        return Storage::disk($this->getDisk())->copy($from, $to);
    }

    /**
     * Move a file
     *
     * @param string $from
     * @param string $to
     * @return bool
     */
    public function move(string $from, string $to): bool
    {
        if (!$this->exists($from)) {
            return false;
        }

        return Storage::disk($this->getDisk())->move($from, $to);
    }

    /**
     * Generate a unique filename
     *
     * @param UploadedFile $file
     * @return string
     */
    protected function generateUniqueFilename(UploadedFile $file): string
    {
        $extension = $file->getClientOriginalExtension();
        $originalName = pathinfo($file->getClientOriginalName(), PATHINFO_FILENAME);
        $slug = Str::slug($originalName);
        
        return $slug . '_' . uniqid() . '_' . time() . '.' . $extension;
    }

    /**
     * Upload multiple files
     *
     * @param array $files
     * @param string $directory
     * @param string $visibility
     * @return array Array of uploaded file paths
     */
    public function uploadMultiple(array $files, string $directory = 'uploads', string $visibility = 'public'): array
    {
        $uploadedPaths = [];

        foreach ($files as $file) {
            if ($file instanceof UploadedFile && $file->isValid()) {
                $path = $this->upload($file, $directory, null, $visibility);
                if ($path) {
                    $uploadedPaths[] = $path;
                }
            }
        }

        return $uploadedPaths;
    }

    /**
     * Get file MIME type
     *
     * @param string $path
     * @return string|false
     */
    public function mimeType(string $path): string|false
    {
        if (!$this->exists($path)) {
            return false;
        }

        return Storage::disk($this->getDisk())->mimeType($path);
    }

    /**
     * Make a directory
     *
     * @param string $path
     * @return bool
     */
    public function makeDirectory(string $path): bool
    {
        return Storage::disk($this->getDisk())->makeDirectory($path);
    }

    /**
     * Delete a directory
     *
     * @param string $directory
     * @return bool
     */
    public function deleteDirectory(string $directory): bool
    {
        return Storage::disk($this->getDisk())->deleteDirectory($directory);
    }

    /**
     * Get S3 bucket name
     *
     * @return string|null
     */
    public function getBucketName(): ?string
    {
        return config('filesystems.disks.s3.bucket');
    }

    /**
     * Get S3 region
     *
     * @return string|null
     */
    public function getRegion(): ?string
    {
        return config('filesystems.disks.s3.region');
    }

    /**
     * Get formatted file size
     *
     * @param string $path
     * @return string|null
     */
    public function getFormattedSize(string $path): ?string
    {
        $bytes = $this->size($path);

        if ($bytes === false) {
            return null;
        }

        $units = ['B', 'KB', 'MB', 'GB', 'TB'];
        $bytes = max($bytes, 0);
        $pow = floor(($bytes ? log($bytes) : 0) / log(1024));
        $pow = min($pow, count($units) - 1);
        $bytes /= pow(1024, $pow);

        return round($bytes, 2) . ' ' . $units[$pow];
    }

    /**
     * Check if file is an image
     *
     * @param string $path
     * @return bool
     */
    public function isImage(string $path): bool
    {
        $mimeType = $this->mimeType($path);

        if (!$mimeType) {
            return false;
        }

        return str_starts_with($mimeType, 'image/');
    }

    /**
     * Get S3 configuration
     *
     * @return array
     */
    public function getConfiguration(): array
    {
        return [
            'disk' => $this->getDisk(),
            'is_s3_active' => $this->isS3Active(),
            'bucket' => $this->getBucketName(),
            'region' => $this->getRegion(),
            'url' => config('filesystems.disks.s3.url'),
        ];
    }
}

