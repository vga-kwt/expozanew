/* eslint-disable @typescript-eslint/no-explicit-any */
import { useLanguage } from '@/components/language-context';
import { Button } from '@/components/ui/button';
import {
    Dialog,
    DialogContent,
    DialogFooter,
    DialogHeader,
    DialogTitle,
} from '@/components/ui/dialog';
import { Check, ChevronDown } from 'lucide-react';
import { useState, useEffect, useRef } from 'react';
import { Input } from '../ui/input';
import {
    Select,
    SelectContent,
    SelectItem,
    SelectTrigger,
    SelectValue,
} from '../ui/select';

interface Section {
    id?: number;
    name: string;
    category_id: number | null;
    status: 'active' | 'suspended';
    product_ids: string[] | null;
}

interface DialogProps<T> {
    open: boolean;
    onOpenChange: (open: boolean) => void;
    formData: Section;
    setFormData: (key: keyof T, value: any) => void;
    errors?: Partial<Record<keyof T, string>>;
    onConfirm: (e: React.FormEvent) => void;
    resetForm: () => void;
    categories: Array<{ id: number; name_en: string }>;
    products: Array<{ id: number; name_en: string; category_id: number }>;
}

const SectionFormModal: React.FC<DialogProps<Section>> = ({
    open,
    onOpenChange,
    formData,
    setFormData,
    errors,
    onConfirm,
    resetForm,
    categories,
    products,
}) => {
    const { t } = useLanguage();
    const [isDropdownOpen, setIsDropdownOpen] = useState<boolean>(false);
    const dropdownRef = useRef<HTMLDivElement>(null);
    const [showConfirmClose, setShowConfirmClose] = useState<boolean>(false);

    // Handle clicks outside the dropdown to close it
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

    const handleProductCheckboxChange = (product: { id: number; name_en: string }) => {
        const currentSelectedIds = formData.product_ids ? [...formData.product_ids] : [];
        const productIdString = String(product.id);

        if (currentSelectedIds.includes(productIdString)) {
            setFormData(
                'product_ids',
                currentSelectedIds.filter((id) => id !== productIdString)
            );
        } else {
            setFormData('product_ids', [...currentSelectedIds, productIdString]);
        }
    };

    const toggleDropdown = () => {
        setIsDropdownOpen(!isDropdownOpen);
    };

    const isProductSelected = (product: { id: number }) => {
        return formData.product_ids?.includes(String(product.id)) || false;
    };

    const selectedProductCount = formData.product_ids?.length || 0;

    // ✅ Filter products based on selected category
    const filteredProducts = formData.category_id
        ? products.filter((p) => p.category_id === formData.category_id)
        : products;

    // Debug information
    // console.log('Modal Debug:', {
    //     totalProducts: products.length,
    //     selectedCategoryId: formData.category_id,
    //     filteredProductsCount: filteredProducts.length,
    //     products: products.map(p => ({ id: p.id, name: p.name_en, category_id: p.category_id }))
    // });

    const handleCloseModal = () => {
        // Check if form has data that would be lost
        const hasData = formData.name || formData.category_id || (formData.product_ids && formData.product_ids.length > 0);
        
        if (hasData && !formData.id) {
            // Show confirmation dialog for unsaved changes
            setShowConfirmClose(true);
        } else {
            // No data to lose, close immediately
            resetForm();
            onOpenChange(false);
            setIsDropdownOpen(false);
        }
    };

    const confirmClose = () => {
        resetForm();
        onOpenChange(false);
        setIsDropdownOpen(false);
        setShowConfirmClose(false);
    };

    const cancelClose = () => {
        setShowConfirmClose(false);
    };

    return (
        <>
            <Dialog
                open={open}
                onOpenChange={(isOpen) => {
                    if (!isOpen) {
                        handleCloseModal();
                    }
                }}
            >
            <DialogContent className="w-full max-w-md">
                <DialogHeader>
                    <DialogTitle>{formData.id ? t('sections.updateSection') : t('sections.createSection')}</DialogTitle>
                </DialogHeader>
                <form onSubmit={onConfirm} className="space-y-4">
                    <div>
                        <label htmlFor="name" className="text-sm font-medium">
                            {t('sections.sectionNameRequired')}
                        </label>
                        <Input
                            id="name"
                            value={formData.name}
                            onChange={(e) => setFormData('name', e.target.value)}
                            className={errors?.name ? 'border-red-500' : ''}
                        />
                        {errors?.name && (
                            <div className="mt-1 text-xs text-red-500">{errors.name}</div>
                        )}
                    </div>

                    <div>
                        <label htmlFor="category_id" className="text-sm font-medium">
                            {t('sections.category')} *
                        </label>
                        <Select
                            value={formData.category_id ? String(formData.category_id) : ''}
                            onValueChange={(value) => {
                                setFormData('category_id', Number(value));
                                setFormData('product_ids', []); // clear selected products on category change
                            }}
                        >
                            <SelectTrigger>
                                <SelectValue placeholder={t('sections.selectCategory')} />
                            </SelectTrigger>
                            <SelectContent>
                                {categories.map((cat) => (
                                    <SelectItem key={cat.id} value={String(cat.id)}>
                                        {cat.name_en}
                                    </SelectItem>
                                ))}
                            </SelectContent>
                        </Select>
                        {errors?.category_id && (
                            <div className="mt-1 text-xs text-red-500">{errors.category_id}</div>
                        )}
                    </div>

                    <div className="relative" ref={dropdownRef}>
                        <label htmlFor="product_ids" className="text-sm font-medium">
                            {t('sections.selectProducts')}
                        </label>

                        {/* Debug info - remove after fixing */}
                        {/* <div className="mb-2 text-xs text-gray-500">
                            Total Products: {products.length} |
                            Selected Category: {formData.category_id} |
                            Filtered Products: {filteredProducts.length}
                        </div> */}

                        <button
                            type="button"
                            className="flex w-full items-center justify-between rounded-lg border border-gray-300 bg-white px-3 py-2 text-left text-sm text-gray-700 shadow-sm transition-all duration-200 hover:bg-gray-50 focus:ring-2 focus:ring-[#d4d4d4] focus:outline-none dark:border-[#262626] dark:bg-transparent dark:text-[#a1a1a1] focus:dark:ring-[#262626]"
                            onClick={toggleDropdown}
                            aria-haspopup="true"
                            aria-expanded={isDropdownOpen}
                        >
                            <span>
                                {selectedProductCount > 0
                                    ? `${selectedProductCount} ${t('sections.productsSelected')}`
                                    : t('sections.selectProducts')}
                            </span>
                            <ChevronDown
                                className={`h-4 w-4 transition-transform duration-200 !text-[#737373] ${isDropdownOpen ? 'rotate-180' : ''
                                    }`}
                            />
                        </button>

                        {isDropdownOpen && (
                            <div className="no-vertical-scrollbar absolute z-10 mt-2 max-h-60 w-full overflow-y-auto rounded-lg border border-gray-200 bg-white shadow-xl dark:border-[#262626] dark:bg-[#0a0a0a]">
                                <ul className="py-1">
                                    {filteredProducts.length === 0 ? (
                                        <li className="px-4 py-2 text-gray-500 dark:text-gray-400">
                                            {formData.category_id
                                                ? t('sections.noProductsForCategory')
                                                : t('sections.selectCategoryFirst')}
                                        </li>
                                    ) : (
                                        filteredProducts.map((product) => (
                                            <li
                                                key={product.id}
                                                className="flex cursor-pointer items-center justify-between px-4 py-2 hover:bg-gray-50 dark:hover:bg-gray-800"
                                                onClick={() => handleProductCheckboxChange(product)}
                                            >
                                                <label className="flex flex-grow cursor-pointer items-center">
                                                    <input
                                                        type="checkbox"
                                                        checked={isProductSelected(product)}
                                                        onChange={() =>
                                                            handleProductCheckboxChange(product)
                                                        }
                                                        className="form-checkbox h-4 w-4 rounded border-gray-300 text-blue-600 focus:ring-[#262626] dark:border-gray-600 dark:bg-gray-900 dark:checked:border-[#262626]"
                                                        onClick={(e) => e.stopPropagation()}
                                                    />
                                                    <span className="ml-3 text-sm font-medium text-gray-800 dark:text-gray-100">
                                                        {product.name_en}
                                                    </span>
                                                </label>
                                                {isProductSelected(product) && (
                                                    <Check className="ml-2 h-4 w-4 text-blue-600 dark:text-blue-400" />
                                                )}
                                            </li>
                                        ))
                                    )}
                                </ul>
                            </div>
                        )}
                        {errors?.product_ids && (
                            <div className="mt-1 text-xs text-red-500">{errors.product_ids}</div>
                        )}
                    </div>

                    <div>
                        <label htmlFor="status" className="text-sm font-medium">
                            {t('common.status')} *
                        </label>
                        <Select
                            value={formData.status}
                            onValueChange={(value: 'active' | 'suspended') =>
                                setFormData('status', value)
                            }
                        >
                            <SelectTrigger className={errors?.status ? 'border-red-500' : ''}>
                                <SelectValue placeholder={t('sections.selectStatus')} />
                            </SelectTrigger>
                            <SelectContent>
                                <SelectItem value="active">{t('expos.active')}</SelectItem>
                                <SelectItem value="suspended">{t('expos.suspended')}</SelectItem>
                            </SelectContent>
                        </Select>
                        {errors?.status && (
                            <div className="mt-1 text-xs text-red-500">{errors.status}</div>
                        )}
                    </div>

                    <DialogFooter>
                        <Button
                            variant="outline"
                            onClick={handleCloseModal}
                        >
                            {t('common.cancel')}
                        </Button>
                        <Button type="submit">{formData.id ? t('common.save') : t('common.save')}</Button>
                    </DialogFooter>
                </form>
            </DialogContent>
        </Dialog>

        {/* Confirmation Dialog for Unsaved Changes */}
        <Dialog open={showConfirmClose} onOpenChange={setShowConfirmClose}>
            <DialogContent className="sm:max-w-md">
                <DialogHeader>
                    <DialogTitle>{t('sections.unsavedChanges')}</DialogTitle>
                </DialogHeader>
                <div className="py-4">
                    <p className="text-sm text-gray-600 dark:text-gray-300">
                        {t('sections.unsavedChangesMessage')}
                    </p>
                </div>
                <DialogFooter>
                    <Button variant="outline" onClick={cancelClose}>
                        {t('sections.continueEditing')}
                    </Button>
                    <Button variant="destructive" onClick={confirmClose}>
                        {t('sections.closeWithoutSaving')}
                    </Button>
                </DialogFooter>
            </DialogContent>
            </Dialog>
        </>
    );
};

export default SectionFormModal;
