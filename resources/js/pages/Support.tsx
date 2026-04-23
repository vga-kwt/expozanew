import { Button } from '@/components/ui/button';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Textarea } from '@/components/ui/textarea';
import InputError from '@/components/input-error';
import { Head, useForm, usePage } from '@inertiajs/react';
import { Mail, MessageSquare, Send } from 'lucide-react';
import { FormEventHandler } from 'react';
import toast from 'react-hot-toast';
import { type SharedData } from '@/types';
import { route } from 'ziggy-js';

export default function Support() {
    const { flash } = usePage<SharedData>().props;

    const { data, setData, post, errors, processing, reset } = useForm({
        name: '',
        subject: '',
        message: '',
        contact_info: '',
    });

    const submit: FormEventHandler = (e) => {
        e.preventDefault();
        post(route('support.store'), {
            preserveScroll: true,
            onSuccess: () => {
                toast.success('Thank you! Your message has been sent successfully. Our support team will contact you shortly.');
                reset();
            },
            onError: () => {
                toast.error('Failed to submit support request. Please check the form and try again.');
            },
        });
    };

    return (
        <>
            <Head title="Support" />
            <div className="flex min-h-screen items-center justify-center bg-gray-50 p-6 dark:bg-gray-900">
                <div className="w-full max-w-2xl">
                    <Card>
                        <CardHeader className="text-center space-y-4">
                            <div className="mx-auto flex flex-col items-center gap-3">
                                <div className="flex h-20 w-20 items-center justify-center rounded-2xl ">
                                    <img 
                                        src={`${window.location.origin}/Group.svg`} 
                                        alt="Expoza Logo" 
                                        className="h-12 w-12 object-contain"
                                    />
                                </div>
                                <div>
                                    <CardTitle className="text-3xl font-bold bg-gradient-to-r from-primary to-primary/70 bg-clip-text text-transparent">
                                        Expoza
                                    </CardTitle>
                                </div>
                            </div>
                            <CardDescription className="mt-2 text-base text-muted-foreground">
                                We're here to help! If you have any questions, concerns, or need assistance, please reach out to us.
                            </CardDescription>
                        </CardHeader>
                        <CardContent>
                            <form onSubmit={submit} className="space-y-4">
                                <div className="grid gap-2">
                                    <Label htmlFor="name">Your Name *</Label>
                                    <Input
                                        id="name"
                                        value={data.name}
                                        onChange={(e) => setData('name', e.target.value)}
                                        required
                                        placeholder="Enter your full name"
                                    />
                                    <InputError message={errors.name} />
                                </div>

                                <div className="grid gap-2">
                                    <Label htmlFor="contact_info">Email or Phone *</Label>
                                    <Input
                                        id="contact_info"
                                        type="text"
                                        value={data.contact_info}
                                        onChange={(e) => setData('contact_info', e.target.value)}
                                        required
                                        placeholder="your@email.com or +1234567890"
                                    />
                                    <InputError message={errors.contact_info} />
                                </div>

                                <div className="grid gap-2">
                                    <Label htmlFor="subject">Subject *</Label>
                                    <Input
                                        id="subject"
                                        value={data.subject}
                                        onChange={(e) => setData('subject', e.target.value)}
                                        required
                                        placeholder="What is this regarding?"
                                    />
                                    <InputError message={errors.subject} />
                                </div>

                                <div className="grid gap-2">
                                    <Label htmlFor="message">Message *</Label>
                                    <Textarea
                                        id="message"
                                        value={data.message}
                                        onChange={(e) => setData('message', e.target.value)}
                                        required
                                        placeholder="Please describe your issue or question in detail..."
                                        rows={6}
                                        className="resize-none"
                                    />
                                    <InputError message={errors.message} />
                                </div>

                              

                                <Button type="submit" className="w-full" disabled={processing}>
                                    {processing ? (
                                        <>
                                            <span className="mr-2">Sending...</span>
                                        </>
                                    ) : (
                                        <>
                                            <Send className="mr-2 h-4 w-4" />
                                            Send Message
                                        </>
                                    )}
                                </Button>
                            </form>
                        </CardContent>
                    </Card>
                </div>
            </div>
        </>
    );
}

