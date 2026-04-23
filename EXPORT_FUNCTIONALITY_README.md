# Export Functionality Documentation

## Overview
This project includes a comprehensive export system that allows users to download data in CSV format. The system consists of:

1. **Backend Export Service** (`app/Helpers/ExportService.php`)
2. **Frontend Export Service** (`resources/js/utils/exportService.ts`)
3. **Reusable Export Button Component** (`resources/js/components/export-button.tsx`)

## Backend Implementation

### ExportService Helper
Located at `app/Helpers/ExportService.php`, this service provides:
- `streamCsv()` - Streams CSV data to browser for download
- `exportCollection()` - Exports collection with custom headers

### Controller Export Methods
Each controller has an `export()` method that:
- Applies filters from request
- Gets data without pagination
- Defines CSV headers
- Prepares data for CSV
- Returns CSV download response

Example from `CityController`:
```php
public function export(Request $request)
{
    try {
        $filters = $request->only(['search', 'status', 'country_id', 'state_id', 'date_from', 'date_to']);
        $cities = $this->cityService->getCitiesForExport($filters);
        
        $headers = [
            'ID', 'Name (English)', 'Name (Arabic)', 'Country', 'State', 'Status', 'Created At', 'Updated At'
        ];
        
        $data = $cities->map(function ($city) {
            return [
                $city->id,
                $city->name_en,
                $city->name_ar,
                $city->country->name_en ?? '',
                $city->state->name_en ?? '',
                $city->status === 'active' ? 'Active' : 'Suspended',
                $city->created_at->format('Y-m-d H:i:s'),
                $city->updated_at->format('Y-m-d H:i:s')
            ];
        });
        
        $filename = 'cities_' . now()->format('Y-m-d_H-i-s') . '.csv';
        return ExportService::streamCsv($data, $filename, $headers);
    } catch (\Exception $e) {
        return back()->with('error', 'Failed to export cities. Please try again.');
    }
}
```

## Frontend Implementation

### ExportService Utility
Located at `resources/js/utils/exportService.ts`, this service provides:
- Generic `exportToCSV()` method for any endpoint
- Specific methods for each data type (cities, countries, states, etc.)
- Automatic filter handling
- Error handling and user feedback

### ExportButton Component
Located at `resources/js/components/export-button.tsx`, this reusable component provides:
- Loading state during export
- Consistent styling
- Error handling
- Accessibility features

## Usage Examples

### Basic Usage in a Component
```tsx
import ExportButton from '@/components/export-button';
import ExportService from '@/utils/exportService';
import { toast } from 'react-hot-toast';

const MyComponent = () => {
    const handleExport = async () => {
        try {
            await ExportService.exportCities({
                search: 'search term',
                status: 'active',
                country_id: '1'
            });
            toast.success('Cities exported successfully');
        } catch (error) {
            toast.error('Failed to export cities');
        }
    };

    return (
        <ExportButton 
            title="Export Cities" 
            onClick={handleExport}
        />
    );
};
```

### With Filters
```tsx
const handleExport = async () => {
    try {
        const exportFilters = { ...localFilters };
        // Remove 'all' values for export
        Object.keys(exportFilters).forEach(key => {
            if (exportFilters[key] === 'all') {
                delete exportFilters[key];
            }
        });
        
        await ExportService.exportCities(exportFilters);
        toast.success('Cities exported successfully');
    } catch (error) {
        toast.error('Failed to export cities');
    }
};
```

## Available Export Endpoints

| Data Type | Endpoint | Method |
|-----------|----------|--------|
| Cities | `/city/export` | `ExportService.exportCities()` |
| Countries | `/country/export` | `ExportService.exportCountries()` |
| States | `/state/export` | `ExportService.exportStates()` |
| Users | `/users/export` | `ExportService.exportUsers()` |
| Orders | `/orders/export` | `ExportService.exportOrders()` |
| Ads | `/ads/export` | `ExportService.exportAds()` |
| Expos | `/expos/export` | `ExportService.exportExpos()` |
| Audit Logs | `/audit-logs/export` | `ExportService.exportAuditLogs()` |
| Finance Transactions | `/finance/export/transactions` | `ExportService.exportFinanceTransactions()` |
| Vendor Payouts | `/finance/payouts/export` | `ExportService.exportVendorPayouts()` |

## Filter Parameters

All export methods accept the following filter parameters:
- `search` - Search term
- `status` - Status filter (active, suspended, etc.)
- `country_id` - Country ID filter
- `state_id` - State ID filter
- `date_from` - Start date filter
- `date_to` - End date filter

Additional parameters may be available for specific data types.

## Features

### Automatic Features
- **UTF-8 BOM**: Proper encoding for international characters
- **Filename Generation**: Automatic timestamp-based filenames
- **Filter Application**: Current page filters are applied to export
- **Error Handling**: Comprehensive error handling with user feedback
- **Loading States**: Visual feedback during export process

### Security
- **Authentication Required**: All export endpoints require authentication
- **Authorization**: Respects user permissions
- **Input Validation**: Filters are validated before processing

### Performance
- **Streaming**: Large datasets are streamed to prevent memory issues
- **No Pagination**: Export includes all filtered data
- **Efficient Queries**: Optimized database queries for export

## Adding New Export Types

### Backend Steps
1. Add export method to controller
2. Add route in `routes/web.php`
3. Add service method if needed

### Frontend Steps
1. Add method to `ExportService`
2. Create component with export button
3. Add proper error handling

## Troubleshooting

### Common Issues
1. **Export fails silently**: Check browser console for errors
2. **Large exports timeout**: Consider implementing chunked exports
3. **Encoding issues**: Ensure UTF-8 BOM is included
4. **Permission denied**: Check user authentication and authorization

### Debug Tips
- Check browser network tab for failed requests
- Verify route exists and is accessible
- Ensure controller method handles errors properly
- Test with small datasets first 