<?php

namespace App\Http\Controllers;

use App\Traits\HasAuditLog;
use Illuminate\Routing\Controller as BaseController;

abstract class Controller extends BaseController
{
    use HasAuditLog;
}
