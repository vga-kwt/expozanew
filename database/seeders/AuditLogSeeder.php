<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\AuditLog;

class AuditLogSeeder extends Seeder
{
    public function run(): void
    {
        AuditLog::create([
            'admin_id' => 1,
            'action' => 'login',
            'module' => 'auth',
            'description' => 'User logged in',
            'changes' => '{}',
            'created_at' => now(),
        ]);
        AuditLog::create([
            'admin_id' => 1,
            'action' => 'update_profile',
            'module' => 'user',
            'description' => 'User updated profile',
            'changes' => '{}',
            'created_at' => now(),
        ]);
    }
}