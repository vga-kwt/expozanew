import React, { useState, useEffect, useRef } from 'react';
import { useLanguage } from '@/components/language-context';
import { Dialog, DialogContent, DialogHeader, DialogTitle } from '@/components/ui/dialog';
import { Button } from '@/components/ui/button';
import { Badge } from '@/components/ui/badge';
import { Alert, AlertDescription } from '@/components/ui/alert';
import { Loader2, X, Plus, Package, CheckCircle, AlertCircle } from 'lucide-react';

interface Product {
    id: number;
    name_en: string;
    name_ar?: string;
    category_id?: number;
    category?: {
        id: number;
        name_en: string;
    };
    status?: string;
    assigned_at?: string;
}

interface ManageProductsModalProps {
    isOpen: boolean;
    onClose: () => void;
    expoId: number;
    expoName: string;
    maxProducts: number;
    slotId: number;
}

export default function ManageProductsModal({
    isOpen,
    onClose,
    expoId,
    expoName,
    maxProducts,
    slotId
}: ManageProductsModalProps) {
    const { t, language } = useLanguage();
    const [isLoading, setIsLoading] = useState(false);
    const [isDropdownOpen, setIsDropdownOpen] = useState(false);
    const [allProducts, setAllProducts] = useState<Product[]>([]);
    const [assignedProducts, setAssignedProducts] = useState<Product[]>([]);
    const [error, setError] = useState<string | null>(null);
    const [success, setSuccess] = useState<string | null>(null);
    const dropdownRef = useRef<HTMLDivElement>(null);
    const [selectedProductIds, setSelectedProductIds] = useState<number[]>([]);
    const [slotProductCounts, setSlotProductCounts] = useState({
        directProducts: 0,
        sectionProducts: 0,
        totalProducts: 0
    });

    // Load products when modal opens or slot changes
    useEffect(() => {
        if (isOpen) {
            loadProducts();
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

    const loadProducts = async () => {
        setIsLoading(true);
        setError(null);

        try {
            const response = await fetch(`/vendor/expos/${expoId}/products?slot_id=${slotId}`);
            const data = await response.json();

            if (response.ok) {
                setAllProducts(data.all_products || []);
                setAssignedProducts(data.assigned_products || []);
                
                // Calculate slot product counts
                const directProducts = data.assigned_products?.length || 0;
                const sectionProducts = data.section_products_count || 0;
                const totalProducts = directProducts + sectionProducts;
                
                setSlotProductCounts({
                    directProducts,
                    sectionProducts,
                    totalProducts
                });
            } else {
                setError(data.error || t('expos.failedToLoadProducts'));
            }
        } catch (error) {
            console.error('Load products error:', error);
            setError(t('expos.networkErrorRetry'));
        } finally {
            setIsLoading(false);
        }
    };

    const handleAddProducts = async () => {
        if (selectedProductIds.length === 0) return;

        setIsLoading(true);
        setError(null);
        setSuccess(null);

        try {
            const response = await fetch(`/vendor/expos/${expoId}/add-product`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'X-CSRF-TOKEN': document.querySelector('meta[name="csrf-token"]')?.getAttribute('content') || '',
                },
                body: JSON.stringify({ product_ids: selectedProductIds, slot_id: slotId }),
            });

            const data = await response.json();

            if (response.ok) {
                setSuccess(data.message);
                setSelectedProductIds([]);
                await loadProducts(); // Reload to get updated lists
                // window.location.reload();

            } else {
                setError(data.error || t('expos.failedToAddProduct'));
            }
        } catch (error) {
            console.error('Add product error:', error);
            setError(t('expos.networkErrorRetry'));
        } finally {
            setIsLoading(false);
        }
    };

    const handleRemoveProduct = async (productId: number) => {
        setIsLoading(true);
        setError(null);
        setSuccess(null);

        try {
            const response = await fetch(`/vendor/expos/${expoId}/remove-product/${productId}?slot_id=${slotId}`, {
                method: 'DELETE',
                headers: {
                    'X-CSRF-TOKEN': document.querySelector('meta[name="csrf-token"]')?.getAttribute('content') || '',
                },
            });

            const data = await response.json();

            if (response.ok) {
                setSuccess(data.message);
                await loadProducts(); // Reload to get updated lists
                // window.location.reload();

            } else {
                setError(data.error || t('expos.failedToRemoveProduct'));
            }
        } catch (error) {
            console.error('Remove product error:', error);
            setError(t('expos.networkErrorRetry'));
        } finally {
            setIsLoading(false);
        }
    };

    const toggleDropdown = () => {
        setIsDropdownOpen(!isDropdownOpen);
    };

    // Handle product selection
    const toggleProductSelection = (productId: number) => {
        setSelectedProductIds((prev) =>
            prev.includes(productId)
                ? prev.filter((id) => id !== productId) // unselect
                : [...prev, productId] // select
        );
    };

    const isProductAssigned = (productId: number) => {
        return assignedProducts.some(p => p.id === productId);
    };

    const availableProducts = allProducts.filter(product => !isProductAssigned(product.id));

    const handleClose = () => {
        setError(null);
        setSuccess(null);
        setSelectedProductIds([]);
        setIsDropdownOpen(false);
        window.location.reload();
        onClose();
    };

    // Filter products for this slot only
    const slotProducts = assignedProducts.filter((p: any) => p.slot_number === slotId);

    return (
        <Dialog open={isOpen} onOpenChange={handleClose}>
            <DialogContent className="sm:max-w-4xl max-h-[90vh] overflow-y-auto">
                <DialogHeader>
                    <DialogTitle className="flex items-center gap-2 text-xl">
                        <Package className="h-6 w-6" />
                        {language === 'ar' ? `${expoName} — ${t('expos.manageProducts')}` : `${t('expos.manageProductsFor')} ${expoName}`}
                    </DialogTitle>
                    <div className="text-sm text-blue-700 dark:text-blue-300 font-semibold mt-1">
                        {t('expos.slotLabel')} {slotId}
                    </div>
                </DialogHeader>

                <div className="space-y-6">
                    {/* Product Limit Info */}
                    <div className="flex items-center justify-between p-4 bg-blue-50 dark:bg-blue-900/20 rounded-lg">
                        <div className="flex flex-col gap-1">
                            <div className="flex items-center gap-2">
                                <CheckCircle className="h-5 w-5 text-blue-600" />
                                <span className="text-sm font-medium text-blue-800 dark:text-blue-200">
                                    {t('expos.totalProductsInSlot')} {slotId}: {slotProductCounts.totalProducts} / {maxProducts}
                                </span>
                            </div>
                            <div className="text-xs text-blue-600 dark:text-blue-300 ml-7">
                                {t('expos.directProductsLabel')}: {slotProductCounts.directProducts} | {t('expos.sectionProductsLabel')}: {slotProductCounts.sectionProducts}
                            </div>
                        </div>
                        <Badge variant="secondary" className="bg-blue-100 text-blue-800 dark:bg-blue-900 dark:text-blue-200">
                            {t('expos.slotLimitLabel')} {maxProducts}
                        </Badge>
                    </div>

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

                    {/* Add Product Section */}
                    {slotProductCounts.totalProducts < maxProducts ? (
                        <div>
                            <h3 className="text-lg font-semibold mb-3 flex items-center gap-2">
                                <Plus className="h-5 w-5 text-blue-600" />
                                {t('expos.addDirectProducts')}
                            </h3>
                            
                            <div className="mb-3 p-3 bg-blue-50 dark:bg-blue-900/20 border border-blue-200 dark:border-blue-800 rounded-lg">
                                <div className="text-sm text-blue-800 dark:text-blue-200">
                                    <strong>{t('expos.availableLabel')}:</strong> {maxProducts - slotProductCounts.totalProducts} {t('expos.availableMoreProductsHint')}
                                </div>
                            </div>

                            <div className="relative" ref={dropdownRef}>
                                <button
                                    type="button"
                                    className="flex w-full items-center justify-between rounded-lg border border-gray-300 bg-white px-3 py-2 text-left text-sm text-gray-700 shadow-sm transition-all duration-200 hover:bg-gray-50 focus:ring-2 focus:ring-blue-500 focus:outline-none dark:border-gray-600 dark:bg-gray-800 dark:text-gray-200 dark:hover:bg-gray-700"
                                    onClick={toggleDropdown}
                                    disabled={isLoading || availableProducts.length === 0}
                                    aria-haspopup="true"
                                    aria-expanded={isDropdownOpen}
                                >
                                    <span className="truncate">
                                        {selectedProductIds.length > 0
                                            ? (() => {
                                                const selected = availableProducts.filter((p) => selectedProductIds.includes(p.id));
                                                const names = selected.map((p) => p.name_en);
                                                if (names.length > 3) {
                                                    return names.slice(0, 3).join(', ') + ', ...';
                                                }
                                                return names.join(', ');
                                            })()
                                            : t('expos.selectProductsToAdd')}
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
                                        <ul className="py-1">
                                            {availableProducts.length === 0 ? (
                                                <li className="px-4 py-2 text-gray-500 dark:text-gray-400">
                                                    {t('expos.noAvailableProductsToAdd')}
                                                </li>
                                            ) : (
                                                availableProducts.map((product) => {
                                                    const isSelected = selectedProductIds.includes(product.id);
                                                    return (
                                                        <li
                                                            key={product.id}
                                                            className={`flex items-center justify-between px-4 py-2 cursor-pointer hover:bg-gray-50 dark:hover:bg-gray-700 ${isSelected ? 'bg-gray-100 dark:bg-gray-700' : ''
                                                                }`}
                                                            onClick={() => toggleProductSelection(product.id)}
                                                        >
                                                            <div className="flex-1 min-w-0">
                                                                <div className="font-medium text-gray-800 dark:text-gray-200 truncate">
                                                                    {product.name_en}
                                                                </div>
                                                                {product.category && (
                                                                    <div className="text-xs text-gray-500 dark:text-gray-400">
                                                                        {product.category.name_en}
                                                                    </div>
                                                                )}
                                                            </div>
                                                            {isSelected && (
                                                                <svg
                                                                    className="w-4 h-4 text-blue-500 ml-2"
                                                                    fill="none"
                                                                    stroke="currentColor"
                                                                    viewBox="0 0 24 24"
                                                                >
                                                                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={3} d="M5 13l4 4L19 7" />
                                                                </svg>
                                                            )}
                                                        </li>
                                                    );
                                                })
                                            )}
                                        </ul>
                                    </div>
                                )}
                            </div>

                            {selectedProductIds.length > 0 && (
                                <div className="mt-3">
                                    <Button
                                        onClick={handleAddProducts}
                                        disabled={isLoading}
                                        className="w-full"
                                    >
                                        {isLoading ? (
                                            <>
                                                <Loader2 className="mr-2 h-4 w-4 animate-spin" />
                                                {t('expos.addingProduct')}
                                            </>
                                        ) : (
                                            <>
                                                <Plus className="mr-2 h-4 w-4" />
                                                {t('expos.addSelectedProduct')}
                                            </>
                                        )}
                                    </Button>
                                </div>
                            )}
                        </div>
                    ) : (
                        <div className="text-center py-8 text-gray-500 dark:text-gray-400">
                            <Package className="h-12 w-12 mx-auto mb-3 opacity-50" />
                            <p>{t('expos.slotAtMaxCapacity').replace('{max}', String(maxProducts))}</p>
                            <p className="text-sm">{t('expos.noMoreDirectProducts')}</p>
                        </div>
                    )}
                    {/* Assigned Products Section */}
                    <div>
                        <h3 className="text-lg font-semibold mb-3 flex items-center gap-2">
                            <CheckCircle className="h-5 w-5 text-green-600" />
                            {t('expos.directProductsCount')} ({slotProductCounts.directProducts})
                        </h3>
                        
                        {slotProductCounts.sectionProducts > 0 && (
                            <div className="mb-3 p-3 bg-yellow-50 dark:bg-yellow-900/20 border border-yellow-200 dark:border-yellow-800 rounded-lg">
                                <div className="text-sm text-yellow-800 dark:text-yellow-200">
                                    <strong>{t('expos.noteLabel')}</strong> {t('expos.noteSectionProducts').replace('{count}', String(slotProductCounts.sectionProducts))}
                                </div>
                            </div>
                        )}

                        {slotProductCounts.directProducts === 0 ? (
                            <div className="text-center py-8 text-gray-500 dark:text-gray-400">
                                <Package className="h-12 w-12 mx-auto mb-3 opacity-50" />
                                <p>{t('expos.noDirectProductsAssigned')}</p>
                                <p className="text-sm">{t('expos.useDropdownToAdd')}</p>
                            </div>
                        ) : (
                            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-3">
                                {assignedProducts.map((product) => (
                                    <div
                                        key={product.id}
                                        className="flex items-center justify-between p-3 bg-green-50 dark:bg-green-900/20 border border-green-200 dark:border-green-800 rounded-lg"
                                    >
                                        <div className="flex-1 min-w-0">
                                            <div className="font-medium text-green-800 dark:text-green-200 truncate">
                                                {product.name_en}
                                            </div>
                                            {product.category && (
                                                <div className="text-xs text-green-600 dark:text-green-300">
                                                    {product.category.name_en}
                                                </div>
                                            )}
                                        </div>
                                        <Button
                                            size="sm"
                                            variant="destructive"
                                            onClick={() => handleRemoveProduct(product.id)}
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