import { Link } from '@inertiajs/react';
import { Button } from './ui/button';

const CreateButton = ({ btnName, href, onClick }: { btnName: string; href?: string; onClick?: () => void }) => {
    return (
        <>
            {href ? (
                <Link href={route(`${href}`)}>
                    <Button variant="default">{btnName}</Button>
                </Link>
            ) : (
                <Button onClick={onClick}>{btnName}</Button>
            )}
        </>
    );
};

export default CreateButton;
