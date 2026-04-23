<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Api\Controller;
use App\Models\Notification;
use Illuminate\Http\Request;

class NotificationController extends Controller
{
    /**
     * List all notifications for authenticated user
     *
     * @OA\Get(
     *     path="/api/notifications",
     *     summary="List all notifications for authenticated user",
     *     tags={"Notification"},
     *     security={{"sanctum":{}}},
     *     @OA\Response(
     *         response=200,
     *         description="List of notifications"
     *     )
     * )
     */
    public function index(Request $request)
    {
        $perPage = $request->input('per_page', 10);
        $date = $request->input('date');
        $query = Notification::where('user_id', $request->user()->id)
            ->where('deleted_at', null)
            ->orderByDesc('created_at');
        if ($date) {
            $query->whereDate('created_at', $date);
        }
        $notifications = $query->paginate($perPage);
        // Group by Y-m-d
        $flat = collect($notifications->items())->map(function ($n) {
            return [
                'id' => $n->id,
                'order_id' => $n->order_id,
                'user_id' => $n->user_id,
                'title' => $n->title,
                'body' => $n->body,
                'type' => $n->type,
                'is_read' => $n->is_read,
                'data' => $n->data,
                'created_at' => $n->created_at,
                'date' => $n->created_at->format('Y-m-d'),
            ];
        });
        return response()->json([
            'success' => true,
            'message' => 'Notifications retrieved successfully',
            'data' => $flat,
            'pagination' => [
                'total' => $notifications->total(),
                'per_page' => $notifications->perPage(),
                'current_page' => $notifications->currentPage(),
                'last_page' => $notifications->lastPage(),
                'from' => $notifications->firstItem(),
                'to' => $notifications->lastItem()
            ]
        ]);
    }

    /**
     * Mark notification as read
     *
     * @OA\Post(
     *     path="/api/notifications/{id}/read",
     *     summary="Mark notification as read",
     *     tags={"Notification"},
     *     security={{"sanctum":{}}},
     *     @OA\Parameter(
     *         name="id",
     *         in="path",
     *         required=true,
     *         @OA\Schema(type="integer")
     *     ),
     *     @OA\Response(
     *         response=200,
     *         description="Notification marked as read"
     *     )
     * )
     */
    public function markAsRead(Request $request, $id)
    {
        $notification = Notification::where('user_id', $request->user()->id)->where('deleted_at', null)->findOrFail($id);
        $notification->update(['is_read' => true]);
        return response()->json([
            'success' => true,
            'message' => 'Notification marked as read'
        ]);
    }

    /**
     * Delete notification
     *
     * @OA\Delete(
     *     path="/api/notifications/{id}",
     *     summary="Delete notification",
     *     tags={"Notification"},
     *     security={{"sanctum":{}}},
     *     @OA\Parameter(
     *         name="id",
     *         in="path",
     *         required=true,
     *         @OA\Schema(type="integer")
     *     ),
     *     @OA\Response(
     *         response=200,
     *         description="Notification deleted"
     *     )
     * )
     */
    public function destroy(Request $request, $id)
    {
        $notification = Notification::where('user_id', $request->user()->id)->where('deleted_at', null)->findOrFail($id);
        $notification->delete();
        
        return response()->json([
            'success' => true,
            'message' => 'Notification deleted'
        ]);
    }
} 