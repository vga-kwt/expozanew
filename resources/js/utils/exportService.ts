interface ExportFilters {
    search?: string;
    status?: string;
    country_id?: string;
    state_id?: string;
    date_from?: string;
    date_to?: string;
    [key: string]: string | undefined;
}

class ExportService {
    /**
     * Export data to CSV with filters
     */
    static async exportToCSV(endpoint: string, filters: ExportFilters = {}): Promise<void> {
        try {
            // Build query parameters
            const params = new URLSearchParams();
            Object.entries(filters).forEach(([key, value]) => {
                if (value && value !== 'all' && value !== '') {
                    params.append(key, value);
                }
            });
            
            // Get CSRF token from meta tag
            const csrfToken = document.querySelector('meta[name="csrf-token"]')?.getAttribute('content');
            
            // console.log('Exporting to:', `${endpoint}?${params.toString()}`);
            
            const response = await fetch(`${endpoint}?${params.toString()}`, {
                method: 'GET',
                headers: {
                    'X-CSRF-TOKEN': csrfToken || '',
                    'Accept': 'text/csv, application/json',
                },
                credentials: 'same-origin',
            });
            
            // console.log('Response status:', response.status);
            // console.log('Response headers:', Object.fromEntries(response.headers.entries()));
            
            if (!response.ok) {
                const errorData = await response.json().catch(() => ({}));
                console.error('Export error:', errorData);
                throw new Error(errorData.message || `Export failed: ${response.status}`);
            }
            
            // Get the filename from the response headers
            const contentDisposition = response.headers.get('content-disposition');
            let filename = 'export.csv';
            if (contentDisposition) {
                const filenameMatch = contentDisposition.match(/filename="(.+)"/);
                if (filenameMatch) {
                    filename = filenameMatch[1];
                }
            }
            
            // Create blob and download
            const blob = await response.blob();
            const url = window.URL.createObjectURL(blob);
            const a = document.createElement('a');
            a.href = url;
            a.download = filename;
            document.body.appendChild(a);
            a.click();
            window.URL.revokeObjectURL(url);
            document.body.removeChild(a);
        } catch (error) {
            console.error('Export failed:', error);
            throw error;
        }
    }

    /**
     * Export cities to CSV
     */
    static async exportCities(filters: ExportFilters = {}): Promise<void> {
        return this.exportToCSV('/city/export', filters);
    }

    /**
     * Export states to CSV
     */
    static async exportStates(filters: ExportFilters = {}): Promise<void> {
        return this.exportToCSV(route('state.export'), filters);
    }

    /**
     * Export countries to CSV
     */
    static async exportCountries(filters: ExportFilters = {}): Promise<void> {
        return this.exportToCSV(route('country.export'), filters);
    }

    /**
     * Export users to CSV
     */
    static async exportUsers(filters: ExportFilters = {}): Promise<void> {
        return this.exportToCSV(route('users.export'), filters);
    }

    /**
     * Export orders to CSV
     */
    static async exportOrders(filters: ExportFilters = {}): Promise<void> {
        return this.exportToCSV(route('orders.export'), filters);
    }

    /**
     * Export expos to CSV
     */
    static async exportExpos(filters: ExportFilters = {}): Promise<void> {
        return this.exportToCSV(route('expos.export'), filters);
    }

    /**
     * Export ads to CSV
     */
    static async exportAds(filters: ExportFilters = {}): Promise<void> {
        return this.exportToCSV(route('ads.export'), filters);
    }

    /**
     * Export audit logs to CSV
     */
    static async exportAuditLogs(filters: ExportFilters = {}): Promise<void> {
        return this.exportToCSV(route('audit-logs.export'), filters);
    }

    /**
     * Export finance transactions to CSV
     */
    static async exportFinanceTransactions(filters: ExportFilters = {}): Promise<void> {
        return this.exportToCSV(route('finance.export.transactions'), filters);
    }

    /**
     * Export vendor payouts to CSV
     */
    static async exportVendorPayouts(filters: ExportFilters = {}): Promise<void> {
        return this.exportToCSV(route('finance.payouts.export'), filters);
    }

    /**
     * Export sections to CSV
     */
    static async exportSections(filters: ExportFilters = {}): Promise<void> {
        return this.exportToCSV(route('section.export'), filters);
    }
}

export default ExportService;
export type { ExportFilters }; 