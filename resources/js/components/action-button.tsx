import { MouseEventHandler } from 'react';
import { Button } from './ui/button';

const ActionButtonSuspend = ({
    disabled,
    btnTitle,
    onClick,
    variant,
}: {
    disabled?: boolean;
    btnTitle: string;
    onClick?: MouseEventHandler;
    variant: 'default' | 'link' | 'destructive' | 'outline' | 'secondary' | 'ghost';
}) => {
    return (
        <Button size="sm" variant={variant} onClick={onClick} disabled={disabled}>
            {btnTitle}
        </Button>
    );
};
const ActionButtonDelete = ({ btnTitle, onClick }: { btnTitle: string; onClick?: MouseEventHandler }) => {
    return (
        <Button size="sm" variant="destructive" onClick={onClick}>
            {btnTitle}
        </Button>
    );
};

export { ActionButtonDelete, ActionButtonSuspend };
// onClick={() => openDeleteDialog(expo)}
