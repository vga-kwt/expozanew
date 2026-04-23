<?php

namespace App\Http\Controllers;

use App\Models\AuditLog;
use App\Models\User;
use Illuminate\Http\Request;
use Inertia\Inertia;

class AuditLogController extends Controller
{
    public function index(Request $request)
    {
        $query = AuditLog::with('admin')->orderByDesc('created_at');

        if ($adminId = $request->input('admin_id')) {
            $query->where('admin_id', $adminId);
        }
        if ($action = $request->input('action')) {
            $query->where('action', $action);
        }
        if ($module = $request->input('module')) {
            $query->where('module', $module);
        }
        if ($dateFrom = $request->input('date_from')) {
            $query->whereDate('created_at', '>=', $dateFrom);
        }
        if ($dateTo = $request->input('date_to')) {
            $query->whereDate('created_at', '<=', $dateTo);
        }

        $logs = $query->paginate(20)->withQueryString();
        $admins = User::select('id', 'full_name')->get();
        $modules = AuditLog::select('module')->distinct()->pluck('module');
        $actions = AuditLog::select('action')->distinct()->pluck('action');

        return Inertia::render('AuditLogs/Index', [
            'logs' => $logs,
            'admins' => $admins,
            'modules' => $modules,
            'actions' => $actions,
            'filters' => $request->only(['admin_id', 'action', 'module', 'date_from', 'date_to']),
        ]);
    }

    public function export(Request $request)
    {
        $query = AuditLog::with('admin')->orderByDesc('created_at');

        if ($adminId = $request->input('admin_id')) {
            $query->where('admin_id', $adminId);
        }
        if ($action = $request->input('action')) {
            $query->where('action', $action);
        }
        if ($module = $request->input('module')) {
            $query->where('module', $module);
        }
        if ($dateFrom = $request->input('date_from')) {
            $query->whereDate('created_at', '>=', $dateFrom);
        }
        if ($dateTo = $request->input('date_to')) {
            $query->whereDate('created_at', '<=', $dateTo);
        }

        $logs = $query->get();
        $filename = 'audit_logs_' . now()->format('Y-m-d_H-i-s') . '.csv';
        $headers = [
            'Content-Type' => 'text/csv',
            'Content-Disposition' => 'attachment; filename="' . $filename . '"',
        ];

        $callback = function() use ($logs) {
            $file = fopen('php://output', 'w');
            // CSV Header
            fputcsv($file, ['Admin', 'Action', 'Module', 'Description', 'Changes', 'Timestamp']);
            foreach ($logs as $log) {
                // Format changes as pretty JSON if it's an array/object, else as string
                $changes = $log->changes;
                if (is_array($changes) || is_object($changes)) {
                    $changes = json_encode($changes, JSON_UNESCAPED_UNICODE|JSON_UNESCAPED_SLASHES);
                }
                fputcsv($file, [
                    $log->admin ? $log->admin->name : 'N/A',
                    $log->action,
                    $log->module,
                    $log->description,
                    $changes,
                    $log->created_at ? $log->created_at->format('Y-m-d H:i:s') : '',
                ]);
            }
            fclose($file);
        };
        return response()->stream($callback, 200, $headers);
    }
} 