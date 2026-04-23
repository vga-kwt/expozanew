import { Head } from '@inertiajs/react';

interface CmsPage {
    id: number;
    title_en: string;
    title_ar: string;
    slug: string;
    content_en: string;
    content_ar: string;
    status: string;
    meta_title?: string;
    meta_description?: string;
    meta_keywords?: string;
}

interface Props {
    page: CmsPage;
}

export default function CmsPageView({ page }: Props) {
    return (
        <>
            <Head title={page.meta_title || page.title_en} />
            <div className="bg-background min-h-svh flex flex-col">
                {/* Top header with logo and description */}
                <header className="flex flex-col items-center gap-4 px-4 pt-10 text-center">
                    <div className="mb-1 flex h-10 w-10 items-center justify-center rounded-md">
                        <img src={`${window.location.origin}/Group.svg`} alt="logo" />
                    </div>
                    <div className="space-y-1">
                        <h1 className="text-2xl font-semibold">{page.title_en}</h1>
                        {page.meta_description && (
                            <p className="text-muted-foreground text-sm max-w-2xl mx-auto">
                                {page.meta_description}
                            </p>
                        )}
                    </div>
                </header>

                {/* Main content */}
                <main className="flex-1 px-4 pb-16 pt-8 md:px-12 lg:px-24">
                    <div className="w-full space-y-8">
                        {/* Section titles row */}
                        <div className="grid grid-cols-1 gap-4 border-b pb-4 md:grid-cols-2">
                            <div>
                                <h2 className="text-xl font-bold">{page.title_en}</h2>
                            </div>
                            {page.title_ar && (
                                <div 
                                    className="text-right" 
                                    dir="rtl"
                                    style={{
                                        fontFamily: '"Noto Sans Arabic", "Segoe UI", Tahoma, Arial, sans-serif',
                                        direction: 'rtl',
                                        textAlign: 'right',
                                        unicodeBidi: 'embed'
                                    }}
                                >
                                    <h2 className="text-xl font-bold" style={{ direction: 'rtl', textAlign: 'right' }}>{page.title_ar}</h2>
                                </div>
                            )}
                        </div>

                        {/* Two column content - full width */}
                        <div className="grid grid-cols-1 gap-8 md:grid-cols-2">
                            {/* English content */}
                            <div className="prose prose-base max-w-none dark:prose-invert prose-headings:font-bold prose-p:text-justify prose-p:leading-relaxed">
                                <div
                                    className="space-y-4"
                                    dangerouslySetInnerHTML={{ __html: page.content_en || '' }}
                                />
                            </div>

                            {/* Arabic content */}
                            {page.content_ar && (
                                <div 
                                    className="max-w-none" 
                                    dir="rtl"
                                    style={{
                                        fontFamily: '"Noto Sans Arabic", "Segoe UI", Tahoma, Arial, sans-serif',
                                        direction: 'rtl',
                                        textAlign: 'right'
                                    }}
                                >
                                    <style>{`
                                        [dir="rtl"] p {
                                            text-align: right !important;
                                            direction: rtl !important;
                                            margin-bottom: 1rem;
                                            line-height: 1.75;
                                        }
                                        [dir="rtl"] h1, [dir="rtl"] h2, [dir="rtl"] h3, [dir="rtl"] h4, [dir="rtl"] h5, [dir="rtl"] h6 {
                                            text-align: right !important;
                                            direction: rtl !important;
                                            font-weight: bold;
                                            margin-bottom: 1rem;
                                        }
                                        [dir="rtl"] ul, [dir="rtl"] ol {
                                            text-align: right !important;
                                            direction: rtl !important;
                                            padding-right: 1.5rem;
                                            padding-left: 0;
                                            margin-right: 0;
                                        }
                                        [dir="rtl"] li {
                                            text-align: right !important;
                                            direction: rtl !important;
                                            margin-bottom: 0.5rem;
                                        }
                                        [dir="rtl"] div {
                                            direction: rtl !important;
                                            text-align: right !important;
                                        }
                                    `}</style>
                                    <div
                                        className="space-y-4"
                                        style={{
                                            direction: 'rtl',
                                            textAlign: 'right',
                                            lineHeight: '1.75',
                                            fontSize: '1rem'
                                        }}
                                        dangerouslySetInnerHTML={{ __html: page.content_ar }}
                                    />
                                </div>
                            )}
                        </div>
                    </div>
                </main>
            </div>
        </>
    );
}

