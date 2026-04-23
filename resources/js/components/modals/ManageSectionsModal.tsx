import React, { useState, useEffect, useRef } from 'react';
import { useLanguage } from '@/components/language-context';
import { Dialog, DialogContent, DialogHeader, DialogTitle } from '@/components/ui/dialog';
import { Button } from '@/components/ui/button';
import { Alert, AlertDescription } from '@/components/ui/alert';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Loader2, X, Plus, FolderOpen, CheckCircle, AlertCircle, Bookmark } from 'lucide-react';
import {
    Select,
    SelectContent,
    SelectItem,
    SelectTrigger,
    SelectValue,
} from '@/components/ui/select';

interface Section {
    id: number;
    name: string;
    name_en?: string;
    name_ar?: string;
    category_id?: number;
    category?: {
        id: number;
        name_en: string;
    };
    status?: string;
    created_at?: string;
}

interface Category {
    id: number;
    name_en: string;
    name_ar?: string;
}

interface Product {
    id: number;
    name_en: string;
    name_ar?: string;
    category_id?: number;
}

interface ManageSectionsModalProps {
    isOpen: boolean;
    onClose: () => void;
    expoId: number;
    expoName: string;
    categories: Category[];
    slotId?: number; // Add slotId prop
}

export default function ManageSectionsModal({
    isOpen,
    onClose,
    expoId,
    expoName,
    categories,
    slotId
}: ManageSectionsModalProps) {
    const { t } = useLanguage();
    const [isLoading, setIsLoading] = useState(false);
    const [isDropdownOpen, setIsDropdownOpen] = useState(false);
    const [allSections, setAllSections] = useState<Section[]>([]);
    const [assignedSections, setAssignedSections] = useState<Section[]>([]);
    const [selectedSectionIds, setSelectedSectionIds] = useState<string[]>([]);
    const [error, setError] = useState<string | null>(null);
    const [success, setSuccess] = useState<string | null>(null);
    const dropdownRef = useRef<HTMLDivElement>(null);

    // Create new section state
    const [showCreateForm, setShowCreateForm] = useState(false);
    const [newSectionName, setNewSectionName] = useState('');
    const [selectedCategoryId, setSelectedCategoryId] = useState<string>('');
    const [availableProducts, setAvailableProducts] = useState<Product[]>([]);
    const [selectedProductIds, setSelectedProductIds] = useState<string[]>([]);

    // Load sections when modal opens or slot changes
    useEffect(() => {
        if (isOpen) {
            loadSections();
            loadAvailableProducts();
        }
    }, [isOpen, expoId, slotId]);

    // Handle clicks outside dropdown
    useEffect(() => {
        const handleClickOutside = (event: MouseEvent) => {
            if (dropdownRef.current && !dropdownRef.current.contains(event.target as Node)) {
                setIsDropdownOpen(false);
            }
        };

        if (isDropdownOpen) {
            document.addEventListener('mousedown', handleClickOutside);
        }

        return () => {
            document.removeEventListener('mousedown', handleClickOutside);
        };
    }, [isDropdownOpen]);

    const loadSections = async () => {
        setIsLoading(true);
        setError(null);

        try {
            const url = new URL(`/vendor/expos/${expoId}/sections`, window.location.origin);
            if (slotId) {
                url.searchParams.append('slot_id', slotId.toString());
            }
            
            const response = await fetch(url.toString());
            const data = await response.json();

            if (response.ok) {
                // console.log('Sections data:', data);
                setAllSections(data.all_sections || []);
                setAssignedSections(data.assigned_sections || []);
            } else {
                setError(data.error || 'Failed to load sections');
            }
        } catch (error) {
            console.error('Load sections error:', error);
            setError('Network error. Please try again.');
        } finally {
            setIsLoading(false);
        }
    };

    const loadAvailableProducts = async () => {
        try {
            const response = await fetch(`/vendor/expos/${expoId}/products`);
            const data = await response.json();

            if (response.ok) {
                setAvailableProducts(data.all_products || []);
            }
        } catch (error) {
            console.error('Load products error:', error);
        }
    };

    const handleAddSections = async () => {
        if (selectedSectionIds.length === 0) return;

        setIsLoading(true);
        setError(null);
        setSuccess(null);

        try {
            const response = await fetch(route('vendor.expos.section-add', expoId), {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'X-CSRF-TOKEN': document.querySelector('meta[name="csrf-token"]')?.getAttribute('content') || '',
                },
                body: JSON.stringify({ section_ids: selectedSectionIds, slot_id: slotId }),
            });

            const data = await response.json();

            if (response.ok) {
                setSuccess(data.message || `Successfully added ${selectedSectionIds.length} section(s)`);
                setSelectedSectionIds([]);
                await loadSections(); // Reload to get updated lists
            } else {
                // Handle detailed error response
                if (data.message) {
                    setError(data.message);
                } else if (data.error) {
                    setError(data.error);
                } else {
                    setError('Failed to add sections');
                }
            }
        } catch (error) {
            console.error('Add sections error:', error);
            setError('Network error. Please try again.');
        } finally {
            setIsLoading(false);
        }
    };

    const handleSectionToggle = (sectionId: string) => {
        setSelectedSectionIds(prev => {
            if (prev.includes(sectionId)) {
                return prev.filter(id => id !== sectionId);
            } else {
                return [...prev, sectionId];
            }
        });
    };

    const handleRemoveSection = async (sectionId: number) => {
        setIsLoading(true);
        setError(null);
        setSuccess(null);

        try {
            const url = new URL(route('vendor.expos.remove-section', [expoId, sectionId]), window.location.origin);
            if (slotId) {
                url.searchParams.append('slot_id', slotId.toString());
            }
            
            const response = await fetch(url.toString(), {
                method: 'DELETE',
                headers: {
                    'X-CSRF-TOKEN': document.querySelector('meta[name="csrf-token"]')?.getAttribute('content') || '',
                },
            });

            const data = await response.json();

            if (response.ok) {
                setSuccess(data.message);
                await loadSections(); // Reload to get updated lists
            } else {
                setError(data.error || 'Failed to remove section');
            }
        } catch (error) {
            console.error('Remove section error:', error);
            setError('Network error. Please try again.');
        } finally {
            setIsLoading(false);
        }
    };

    const handleCreateSection = async () => {
        if (!newSectionName || !selectedCategoryId) {
            setError('Section name and category are required.');
            return;
        }

        setIsLoading(true);
        setError(null);
        setSuccess(null);

        try {
            const response = await fetch(route('vendor.expos.section-create', expoId), {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'X-CSRF-TOKEN': document.querySelector('meta[name="csrf-token"]')?.getAttribute('content') || '',
                },
                body: JSON.stringify({
                    name: newSectionName,
                    category_id: selectedCategoryId,
                    product_ids: selectedProductIds,
                    slot_id: slotId,
                }),
            });

            const data = await response.json();

            if (response.ok) {
                setSuccess(data.message);
                setNewSectionName('');
                setSelectedCategoryId('');
                setSelectedProductIds([]);
                setShowCreateForm(false);
                await loadSections(); // Reload to get updated lists
                // window.location.reload();
                        } else {
                setError(data.error || 'Failed to create section');
            }
        } catch (error) {
            console.error('Create section error:', error);
            setError('Network error. Please try again.');
        } finally {
            setIsLoading(false);
        }
    };

    const toggleDropdown = () => {
        setIsDropdownOpen(!isDropdownOpen);
    };

    const isSectionAssigned = (sectionId: number) => {
        return assignedSections.some(s => s.id === sectionId);
    };

    const availableSections = allSections.filter(section => !isSectionAssigned(section.id));

    const handleClose = () => {
        setError(null);
        setSuccess(null);
        setShowCreateForm(false);
        setNewSectionName('');
        setSelectedCategoryId('');
        setSelectedProductIds([]);
        setSelectedSectionIds([]);
        setIsDropdownOpen(false);
        window.location.reload();
        onClose();
    };

    const handleProductToggle = (productId: string) => {
        setSelectedProductIds(prev =>
            prev.includes(productId)
                ? prev.filter(id => id !== productId)
                : [...prev, productId]
        );
    };

    return (
        <Dialog open={isOpen} onOpenChange={handleClose}>
            <DialogContent className="sm:max-w-4xl max-h-[90vh] overflow-y-auto">
                <DialogHeader>
                    <DialogTitle className="flex items-center gap-2 text-xl">
                        <FolderOpen className="h-6 w-6" />
                        {t('expos.manageSectionsFor')} {expoName}
                    </DialogTitle>
                </DialogHeader>

                <div className="space-y-6">
                    {/* Error/Success Messages */}
                    {error && (
                        <Alert className="border-red-200 bg-red-50 dark:bg-red-900/20 dark:border-red-800">
                            <AlertCircle className="h-4 w-4 text-red-600" />
                            <AlertDescription className="text-red-600">{error}</AlertDescription>
                        </Alert>
                    )}

                    {success && (
                        <Alert className="border-green-200 bg-green-50 dark:bg-green-900/20 dark:border-green-800">
                            <CheckCircle className="h-4 w-4 text-green-600" />
                            <AlertDescription className="text-green-600">{success}</AlertDescription>
                        </Alert>
                    )}

                    {/* Assigned Sections Section */}
                    <div>
                        <h3 className="text-lg font-semibold mb-3 flex items-center gap-2">
                            <CheckCircle className="h-5 w-5 text-green-600" />
                            Assigned Sections ({assignedSections.length})
                        </h3>

                        {assignedSections.length === 0 ? (
                            <div className="text-center py-8 text-gray-500 dark:text-gray-400">
                                <FolderOpen className="h-12 w-12 mx-auto mb-3 opacity-50" />
                                <p>No sections assigned yet.</p>
                                <p className="text-sm">Use the options below to add or create sections.</p>
                            </div>
                        ) : (
                            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-3">
                                {assignedSections.map((section) => (
                                    <div
                                        key={section.id}
                                        className="flex items-center justify-between p-3 bg-green-50 dark:bg-green-900/20 border border-green-200 dark:border-green-800 rounded-lg"
                                    >
                                        <div className="flex-1 min-w-0">
                                            <div className="font-medium text-green-800 dark:text-green-200 truncate">
                                                {section.name_en || section.name}
                                            </div>
                                            {section.category && (
                                                <div className="text-xs text-green-600 dark:text-green-300">
                                                    {section.category.name_en}
                                                </div>
                                            )}
                                        </div>
                                        <Button
                                            size="sm"
                                            variant="destructive"
                                            onClick={() => handleRemoveSection(section.id)}
                                            disabled={isLoading}
                                            className="ml-2 flex-shrink-0"
                                        >
                                            <X className="h-4 w-4" />
                                        </Button>
                                    </div>
                                ))}
                            </div>
                        )}
                    </div>

                    {/* Add Existing Section Section */}
                    <div>
                        <h3 className="text-lg font-semibold mb-3 flex items-center gap-2">
                            <Plus className="h-5 w-5 text-blue-600" />
                            Add Existing Section
                        </h3>

                        <div className="space-y-3">
                            <div className="text-sm font-medium text-gray-700 dark:text-gray-300">
                                Select sections to add ({selectedSectionIds.length} selected):
                            </div>
                            
                            {availableSections.length === 0 ? (
                                <div className="text-sm text-gray-500 dark:text-gray-400 py-4 text-center border border-dashed border-gray-300 dark:border-gray-600 rounded-lg">
                                    No available sections to add.
                                </div>
                            ) : (
                                <div className="space-y-3">
                                    {/* Dropdown for section selection */}
                                    <div className="relative" ref={dropdownRef}>
                                        <button
                                            type="button"
                                            className="flex w-full items-center justify-between rounded-lg border border-gray-300 bg-white px-3 py-2 text-left text-sm text-gray-700 shadow-sm transition-all duration-200 hover:bg-gray-50 focus:ring-2 focus:ring-blue-500 focus:outline-none dark:border-gray-600 dark:bg-gray-800 dark:text-gray-200 dark:hover:bg-gray-700"
                                            onClick={toggleDropdown}
                                            disabled={isLoading}
                                            aria-haspopup="true"
                                            aria-expanded={isDropdownOpen}
                                        >
                                            <span className="truncate">
                                                {selectedSectionIds.length === 0
                                                    ? 'Select sections to add...'
                                                    : `${selectedSectionIds.length} section(s) selected`
                                                }
                                            </span>
                                            <svg
                                                className={`h-4 w-4 transition-transform duration-200 ${isDropdownOpen ? 'rotate-180' : ''}`}
                                                fill="none"
                                                stroke="currentColor"
                                                viewBox="0 0 24 24"
                                            >
                                                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M19 9l-7 7-7-7" />
                                            </svg>
                                        </button>

                                        {isDropdownOpen && (
                                            <div className="absolute z-10 mt-2 max-h-60 w-full overflow-y-auto rounded-lg border border-gray-200 bg-white shadow-xl dark:border-gray-600 dark:bg-gray-800">
                                                <div className="p-2">
                                                    <div className="flex items-center justify-between mb-2 pb-2 border-b border-gray-200 dark:border-gray-600">
                                                        <span className="text-xs font-medium text-gray-500 dark:text-gray-400">
                                                            {availableSections.length} available sections
                                                        </span>
                                                        <div className="flex gap-1">
                                                            <button
                                                                type="button"
                                                                onClick={() => {
                                                                    setSelectedSectionIds(availableSections.map(s => String(s.id)));
                                                                }}
                                                                className="text-xs px-2 py-1 bg-blue-100 text-blue-600 rounded hover:bg-blue-200 dark:bg-blue-900 dark:text-blue-300"
                                                            >
                                                                Select All
                                                            </button>
                                                            <button
                                                                type="button"
                                                                onClick={() => setSelectedSectionIds([])}
                                                                className="text-xs px-2 py-1 bg-gray-100 text-gray-600 rounded hover:bg-gray-200 dark:bg-gray-700 dark:text-gray-300"
                                                            >
                                                                Clear
                                                            </button>
                                                        </div>
                                                    </div>
                                                </div>
                                                <ul className="py-1">
                                                    {availableSections.map((section) => (
                                                        <li
                                                            key={section.id}
                                                            className="flex items-center space-x-3 px-3 py-2 hover:bg-gray-50 dark:hover:bg-gray-700 cursor-pointer"
                                                            onClick={() => handleSectionToggle(String(section.id))}
                                                        >
                                                            <input
                                                                type="checkbox"
                                                                checked={selectedSectionIds.includes(String(section.id))}
                                                                onChange={() => handleSectionToggle(String(section.id))}
                                                                className="h-4 w-4 text-blue-600 focus:ring-blue-500 border-gray-300 rounded"
                                                                onClick={(e) => e.stopPropagation()}
                                                            />
                                                            <div className="flex-1 min-w-0">
                                                                <div className="font-medium text-gray-800 dark:text-gray-200 truncate">
                                                                    {section.name_en || section.name || `Section ${section.id}`}
                                                                </div>
                                                                {section.category && (
                                                                    <div className="text-xs text-gray-500 dark:text-gray-400">
                                                                        {section.category.name_en}
                                                                    </div>
                                                                )}
                                                            </div>
                                                        </li>
                                                    ))}
                                                </ul>
                                            </div>
                                        )}
                                    </div>

                                    {/* Selected sections display */}
                                    {selectedSectionIds.length > 0 && (
                                        <div className="space-y-2">
                                            <div className="text-xs font-medium text-gray-600 dark:text-gray-400">
                                                Selected sections:
                                            </div>
                                            <div className="flex flex-wrap gap-2">
                                                {selectedSectionIds.map((sectionId) => {
                                                    const section = availableSections.find(s => String(s.id) === sectionId);
                                                    return (
                                                        <div
                                                            key={sectionId}
                                                            className="flex items-center gap-1 px-2 py-1 bg-blue-100 text-blue-700 rounded-md text-xs dark:bg-blue-900 dark:text-blue-300"
                                                        >
                                                            <span className="truncate max-w-32">
                                                                {section?.name_en || section?.name || `Section ${sectionId}`}
                                                            </span>
                                                            <button
                                                                type="button"
                                                                onClick={() => handleSectionToggle(sectionId)}
                                                                className="ml-1 hover:bg-blue-200 dark:hover:bg-blue-800 rounded p-0.5"
                                                            >
                                                                <X className="h-3 w-3" />
                                                            </button>
                                                        </div>
                                                    );
                                                })}
                                            </div>
                                        </div>
                                    )}
                                </div>
                            )}
                        </div>

                        {selectedSectionIds.length > 0 && (
                            <div className="mt-3">
                                <Button
                                    onClick={handleAddSections}
                                    disabled={isLoading}
                                    className="w-full"
                                >
                                    {isLoading ? (
                                        <>
                                            <Loader2 className="mr-2 h-4 w-4 animate-spin" />
                                            Adding {selectedSectionIds.length} Section(s)...
                                        </>
                                    ) : (
                                        <>
                                            <Plus className="mr-2 h-4 w-4" />
                                            Add {selectedSectionIds.length} Selected Section{selectedSectionIds.length > 1 ? 's' : ''}
                                        </>
                                    )}
                                </Button>
                            </div>
                        )}
                    </div>
                </div>

                <div className="flex justify-end gap-3 pt-4 border-t">
                    <Button variant="outline" onClick={handleClose} disabled={isLoading}>
                        {t('common.close')}
                    </Button>
                </div>
            </DialogContent>
        </Dialog>
    );
}