interface Column<T> {
    label: string;
    accessor: keyof T;
    isStatus?: boolean;
}

interface TableProps<T> {
    columns: Column<T>[];
    data: T[];
    loading: boolean;
}

const statusColors: Record<string, string> = {
    pending: 'bg-yellow-100 text-yellow-800',
    completed: 'bg-green-100 text-green-800',
    cancelled: 'bg-red-100 text-red-800',
    active: 'bg-green-100 text-green-800',
    inactive: 'bg-gray-100 text-gray-800',
    default: 'bg-gray-200 text-gray-800',
};

const Table = <T extends Record<string, unknown>>({ columns, data, loading }: TableProps<T>) => {
    return (
        <div className="overflow-x-auto rounded-xl border border-gray-200 shadow-sm">
            <table className="min-w-full divide-y divide-gray-200 text-sm">
                <thead className="bg-gray-100">
                    <tr>
                        {columns.map((col, columnIndex: number) => (
                            <th key={columnIndex} className="px-4 py-3 text-left font-semibold whitespace-nowrap text-gray-700">
                                {col.label}
                            </th>
                        ))}
                    </tr>
                </thead>

                <tbody className="divide-y divide-gray-100 bg-white">
                    {loading ? (
                        <tr>
                            <td colSpan={columns.length} className="py-6 text-center">
                                <span className="text-gray-500">Loading...</span>
                            </td>
                        </tr>
                    ) : data.length === 0 ? (
                        <tr>
                            <td colSpan={columns.length} className="py-6 text-center">
                                <span className="text-gray-500">No data available</span>
                            </td>
                        </tr>
                    ) : (
                        data.map((row, rowIndex: number) => (
                            <tr key={rowIndex} className="transition hover:bg-gray-50">
                                {columns.map((col, colIndex: number) => {
                                    const rawValue = row[col.accessor];
                                    const value = typeof rawValue === 'string' || typeof rawValue === 'number' ? rawValue : String(rawValue);

                                    return (
                                        <td key={colIndex} className="px-4 py-3 whitespace-nowrap">
                                            {col.isStatus ? (
                                                <span
                                                    className={`rounded-full px-2 py-1 text-xs font-medium capitalize ${
                                                        statusColors[String(value).toLowerCase()] || statusColors['default']
                                                    }`}
                                                >
                                                    {value}
                                                </span>
                                            ) : (
                                                <span className="text-gray-800">{value}</span>
                                            )}
                                        </td>
                                    );
                                })}
                            </tr>
                        ))
                    )}
                </tbody>
            </table>
        </div>
    );
};

export default Table;
