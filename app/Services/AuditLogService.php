<?php

namespace App\Services;

use App\Models\AuditLog;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Log;

class AuditLogService
{
    /**
     * Create an audit log entry
     *
     * @param string $action The action performed (e.g., 'create', 'update', 'delete', 'login')
     * @param string $module The module/feature (e.g., 'user', 'order', 'expo', 'product')
     * @param string|null $description Optional description
     * @param array|null $changes Optional array of changes (before/after values)
     * @param int|null $adminId Optional admin ID (defaults to authenticated user)
     * @return AuditLog|null
     */
    public static function log(
        string $action,
        string $module,
        ?string $description = null,
        ?array $changes = null,
        ?int $adminId = null
    ): ?AuditLog {
        try {
            // Get admin ID from authenticated user if not provided
            if ($adminId === null) {
                $user = Auth::user();
                $adminId = $user ? $user->id : null;
            }

            // Only log if admin ID is available
            if ($adminId === null) {
                Log::warning('AuditLog: Cannot create log without admin_id', [
                    'action' => $action,
                    'module' => $module,
                ]);
                return null;
            }

            // Create the audit log
            $auditLog = AuditLog::create([
                'admin_id' => $adminId,
                'action' => $action,
                'module' => $module,
                'description' => $description,
                'changes' => $changes ? json_encode($changes) : null,
                'created_at' => now(),
            ]);

            return $auditLog;
        } catch (\Exception $e) {
            Log::error('AuditLog: Failed to create audit log', [
                'error' => $e->getMessage(),
                'action' => $action,
                'module' => $module,
                'admin_id' => $adminId,
            ]);
            return null;
        }
    }

    /**
     * Log a create action
     */
    public static function logCreate(string $module, ?string $description = null, ?array $changes = null, ?int $adminId = null): ?AuditLog
    {
        return self::log('create', $module, $description ?? "Created new {$module}", $changes, $adminId);
    }

    /**
     * Log an update action
     */
    public static function logUpdate(string $module, ?string $description = null, ?array $changes = null, ?int $adminId = null): ?AuditLog
    {
        return self::log('update', $module, $description ?? "Updated {$module}", $changes, $adminId);
    }

    /**
     * Log a delete action
     */
    public static function logDelete(string $module, ?string $description = null, ?array $changes = null, ?int $adminId = null): ?AuditLog
    {
        return self::log('delete', $module, $description ?? "Deleted {$module}", $changes, $adminId);
    }

    /**
     * Log a view action
     */
    public static function logView(string $module, ?string $description = null, ?int $adminId = null): ?AuditLog
    {
        return self::log('view', $module, $description ?? "Viewed {$module}", null, $adminId);
    }

    /**
     * Log a login action
     */
    public static function logLogin(?string $description = null, ?int $adminId = null): ?AuditLog
    {
        return self::log('login', 'auth', $description ?? 'User logged in', null, $adminId);
    }

    /**
     * Log a logout action
     */
    public static function logLogout(?string $description = null, ?int $adminId = null): ?AuditLog
    {
        return self::log('logout', 'auth', $description ?? 'User logged out', null, $adminId);
    }
}

