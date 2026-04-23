<?php

namespace App\Http\Controllers;

use App\Models\SupportRequest;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use Inertia\Inertia;

class SupportController extends Controller
{
    /**
     * Show support page
     */
    public function index()
    {
        return Inertia::render('Support');
    }

    /**
     * Store support request from web form
     */
    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'name' => 'required|string|max:255',
            'subject' => 'required|string|max:255',
            'message' => 'required|string',
            'contact_info' => 'required|string|max:255',
        ]);

        if ($validator->fails()) {
            return redirect()->back()
                ->withErrors($validator)
                ->withInput();
        }

        $support = SupportRequest::create([
            'user_id' => $request->user()?->id,
            'name' => $request->name,
            'subject' => $request->subject,
            'message' => $request->message,
            'contact_info' => $request->contact_info,
            'status' => 'pending',
        ]);

        return redirect()->back()->with('success', 'Support request submitted successfully! We will get back to you soon.');
    }
}

