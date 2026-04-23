import { useLanguage } from '@/components/language-context';
import { Dialog, DialogContent, DialogHeader, DialogTitle } from '@/components/ui/dialog';

interface ProductData {
    name_en: string;
    regular_price: string;
    stock: number;
    status: string;
}

const SectionProductViewModal = ({
    open,
    onOpenChange,
    data,
}: {
    open: boolean;
    onOpenChange: (open: boolean) => void;
    data: ProductData[] | null;
}) => {
    const { t } = useLanguage();
    return (
        <Dialog open={open} onOpenChange={onOpenChange}>
            <DialogContent className="w-[98vw] max-w-[98vw] p-4 sm:w-[1000px] sm:max-w-[1200px] sm:p-6">
                <DialogHeader>
                    <DialogTitle>{t('sections.productDetails')}</DialogTitle>
                </DialogHeader>
                <table className="min-w-full border">
                    <thead>
                        <tr>
                            <th className="border px-4 py-2 text-center">{t('sections.name')}</th>
                            <th className="border px-4 py-2 text-center">{t('products.price')}</th>
                            <th className="border px-4 py-2 text-center">{t('products.stock')}</th>
                            <th className="border px-4 py-2 text-center">{t('common.status')}</th>
                        </tr>
                    </thead>
                    <tbody>
                        {data?.map((ep: ProductData, index: number) => (
                            <tr key={index}>
                                <td className="border px-4 py-2 text-center">{ep?.name_en || '-'}</td>
                                <td className="border px-4 py-2 text-center">{ep?.regular_price ?? '-'}</td>
                                <td className="border px-4 py-2 text-center">{ep?.stock || '-'}</td>
                                <td className="border px-4 py-2 text-center capitalize">{ep?.status || '-'}</td>
                            </tr>
                        ))}
                    </tbody>
                </table>
            </DialogContent>
        </Dialog>
    );
};

export default SectionProductViewModal;
