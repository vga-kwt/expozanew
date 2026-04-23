const ConfirmationModal = ({
    isOpen,
    onClose,
    onConfirm,
    title = 'Delete Item',
    message = 'Are you sure you want to delete this item? This action cannot be undone.',
}: {
    isOpen: boolean;
    onClose: () => void;
    onConfirm: () => void;
    title?: string;
    message?: string;
}) => {
    if (!isOpen) return null;
    return (
        <div className="bg-opacity-40 fixed inset-0 z-50 flex items-center justify-center bg-black">
            <div className="animate-fadeIn w-[90%] max-w-md rounded-xl bg-white shadow-lg">
                <div className="p-6">
                    <h2 className="text-lg font-semibold text-gray-800">{title}</h2>
                    <p className="mt-2 text-sm text-gray-600">{message}</p>
                </div>
                <div className="flex justify-end gap-3 px-6 pb-6">
                    <button onClick={onClose} className="rounded bg-gray-200 px-4 py-2 text-sm font-medium text-gray-700 hover:bg-gray-300">
                        Cancel
                    </button>
                    <button onClick={onConfirm} className="rounded bg-red-600 px-4 py-2 text-sm font-medium text-white hover:bg-red-700">
                        Delete
                    </button>
                </div>
            </div>
        </div>
    );
};

export default ConfirmationModal;
