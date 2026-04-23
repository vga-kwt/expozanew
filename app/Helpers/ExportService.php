<?php

namespace App\Helpers;

use Illuminate\Http\Response;
use Illuminate\Support\Collection;

class ExportService
{
    /**
     * Stream CSV data to browser for download
     */
    public static function streamCsv($data, $filename, $headers = [])
    {
        // Set headers for CSV download
        $response = new Response();
        $response->header('Content-Type', 'text/csv; charset=UTF-8');
        $response->header('Content-Disposition', 'attachment; filename="' . $filename . '"');
        $response->header('Cache-Control', 'no-cache, must-revalidate');
        $response->header('Pragma', 'no-cache');
        $response->header('Expires', '0');

        // Start output buffering
        ob_start();

        // Output UTF-8 BOM for proper encoding
        echo "\xEF\xBB\xBF";

        // Create output stream
        $output = fopen('php://output', 'w');

        // Write headers if provided
        if (!empty($headers)) {
            fputcsv($output, $headers);
        }

        // Write data rows
        foreach ($data as $row) {
            if (is_array($row)) {
                fputcsv($output, $row);
            } elseif (is_object($row) && method_exists($row, 'toArray')) {
                fputcsv($output, $row->toArray());
            }
        }

        fclose($output);

        // Get the content and clear buffer
        $content = ob_get_clean();

        return $response->setContent($content);
    }

    /**
     * Export collection with custom headers
     */
    public static function exportCollection($collection, $filename, $headers = [])
    {
        $data = $collection->map(function ($item) {
            return $item->toArray();
        });

        return self::streamCsv($data, $filename, $headers);
    }
} 