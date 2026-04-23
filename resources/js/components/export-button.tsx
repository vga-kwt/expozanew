import { Download } from 'lucide-react';
import { MouseEventHandler, useState } from 'react';
import { Button } from './ui/button';

interface ExportButtonProps {
    title: string;
    onClick: MouseEventHandler;
    disabled?: boolean;
    className?: string;
}

const ExportButton = ({ title, onClick, disabled = false, className = '' }: ExportButtonProps) => {
    const [isExporting, setIsExporting] = useState(false);

    const handleClick = async (e: React.MouseEvent) => {
        setIsExporting(true);
        try {
            await onClick(e);
        } finally {
            setIsExporting(false);
        }
    };

    return (
        <Button onClick={handleClick} variant="outline" disabled={disabled || isExporting} className={className}>
            <Download className="mr-2 h-4 w-4" />
            {isExporting ? 'Exporting...' : title}
        </Button>
    );
};

export default ExportButton;
