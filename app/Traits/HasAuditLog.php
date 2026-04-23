<?php

namespace App\Traits;

use App\Services\AuditLogService;

trait HasAuditLog
{
    /**
     * Create an audit log entry
     *
     * @param string $action The action performed
     * @param string $module The module/feature
     * @param string|null $description Optional description
     * @param array|null $changes Optional array of changes
     * @return \App\Models\AuditLog|null
     */
    protected function auditLog(
        string $action,
        string $module,
        ?string $description = null,
        ?array $changes = null
    ) {
        return AuditLogService::log($action, $module, $description, $changes);
    }

    /**
     * Log a create action
     */
    protected function auditLogCreate(string $module, ?string $description = null, ?array $changes = null)
    {
        return AuditLogService::logCreate($module, $description, $changes);
    }

    /**
     * Log an update action
     */
    protected function auditLogUpdate(string $module, ?string $description = null, ?array $changes = null)
    {
        return AuditLogService::logUpdate($module, $description, $changes);
    }

    /**
     * Log a delete action
     */
    protected function auditLogDelete(string $module, ?string $description = null, ?array $changes = null)
    {
        return AuditLogService::logDelete($module, $description, $changes);
    }

    /**
     * Log a view action
     */
    protected function auditLogView(string $module, ?string $description = null)
    {
        return AuditLogService::logView($module, $description);
    }
}

