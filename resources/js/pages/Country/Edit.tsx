import { Button } from '@/components/ui/button';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Input } from '@/components/ui/input';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select';
import AppLayout from '@/layouts/app-layout';
import { Head, Link, router, useForm, usePage } from '@inertiajs/react';
import { useEffect } from 'react';
import { toast } from 'react-hot-toast';

interface Country {
    id: number;
    name_en: string;
    name_ar: string;
    status: 'active' | 'suspended';
}

interface Props {
    country: Country;
    flash?: {
        success?: string;
        error?: string;
    };
}

const EditCountry = () => {
    const { country, flash } = usePage<Props>().props;

    const { data, setData, processing, errors, reset } = useForm({
        name_en: country.name_en,
        name_ar: country.name_ar,
        status: country.status,
    });

    useEffect(() => {
        if (flash?.success) {
            toast.success(flash.success);
        }
        if (flash?.error) {
            toast.error(flash.error);
        }
    }, [flash]);

    const handleSubmit = (e: React.FormEvent) => {
        e.preventDefault();
        
        router.put(route('country.update', country.id), data, {
            onSuccess: () => {
                toast.success('Country updated successfully');
            },
            onError: (errors) => {
                toast.error('Please fix the errors below');
            },
        });
    };

    return (
        <AppLayout>
            <Head title={`Edit ${country.name_en} - Expoza`} />
            
            <div className="p-6">
                <div className="mb-6">
                    <nav className="flex items-center space-x-2 text-sm text-gray-600 dark:text-gray-400">
                        <Link href={route('country.index')} className="hover:text-gray-900 dark:hover:text-gray-100">
                            Countries
                        </Link>
                        <span>/</span>
                        <span className="text-gray-900 dark:text-gray-100">Edit {country.name_en}</span>
                    </nav>
                    <h1 className="mt-2 text-2xl font-bold">Edit Country</h1>
                </div>

                <Card className="mx-auto max-w-2xl">
                    <CardHeader>
                        <CardTitle>Edit Country Information</CardTitle>
                    </CardHeader>
                    <CardContent>
                        <form onSubmit={handleSubmit} className="space-y-6">
                            <div>
                                <label htmlFor="name_en" className="block text-sm font-medium text-gray-700 dark:text-gray-300">
                                    Country Name (English) *
                                </label>
                                <Input
                                    id="name_en"
                                    type="text"
                                    value={data.name_en}
                                    onChange={(e) => setData('name_en', e.target.value)}
                                    className={`mt-1 ${errors.name_en ? 'border-red-500' : ''}`}
                                    placeholder="Enter country name in English"
                                />
                                {errors.name_en && (
                                    <div className="mt-1 text-sm text-red-600">{errors.name_en}</div>
                                )}
                            </div>

                            <div>
                                <label htmlFor="name_ar" className="block text-sm font-medium text-gray-700 dark:text-gray-300">
                                    Country Name (Arabic)
                                </label>
                                <Input
                                    id="name_ar"
                                    type="text"
                                    value={data.name_ar}
                                    onChange={(e) => setData('name_ar', e.target.value)}
                                    className={`mt-1 ${errors.name_ar ? 'border-red-500' : ''}`}
                                    placeholder="أدخل اسم البلد بالعربية"
                                    dir="rtl"
                                />
                                {errors.name_ar && (
                                    <div className="mt-1 text-sm text-red-600">{errors.name_ar}</div>
                                )}
                            </div>

                            <div>
                                <label htmlFor="status" className="block text-sm font-medium text-gray-700 dark:text-gray-300">
                                    Status *
                                </label>
                                <Select
                                    value={data.status}
                                    onValueChange={(value: 'active' | 'suspended') => setData('status', value)}
                                >
                                    <SelectTrigger className={`mt-1 ${errors.status ? 'border-red-500' : ''}`}>
                                        <SelectValue placeholder="Select status" />
                                    </SelectTrigger>
                                    <SelectContent>
                                        <SelectItem value="active">Active</SelectItem>
                                        <SelectItem value="suspended">Suspended</SelectItem>
                                    </SelectContent>
                                </Select>
                                {errors.status && (
                                    <div className="mt-1 text-sm text-red-600">{errors.status}</div>
                                )}
                            </div>

                            <div className="flex justify-end space-x-3">
                                <Button
                                    type="button"
                                    variant="outline"
                                    onClick={() => router.get(route('country.index'))}
                                >
                                    Cancel
                                </Button>
                                <Button type="submit" disabled={processing}>
                                    {processing ? 'Updating...' : 'Update Country'}
                                </Button>
                            </div>
                        </form>
                    </CardContent>
                </Card>
            </div>
        </AppLayout>
    );
};

export default EditCountry; 