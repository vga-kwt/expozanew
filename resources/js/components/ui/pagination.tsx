import React from 'react';
import { Button } from '@/components/ui/button';

interface PaginationProps {
  currentPage: number;
  lastPage: number;
  total: number;
  perPage: number;
  links: Array<{
    url: string | null;
    label: string;
    active: boolean;
  }>;
  onPageChange?: (page: number) => void;
}

export function Pagination({ currentPage, lastPage, total, perPage, links, onPageChange }: PaginationProps) {
  const startItem = (currentPage - 1) * perPage + 1;
  const endItem = Math.min(currentPage * perPage, total);

  const handlePageChange = (url: string | null) => {
    if (!url) return;
    if (onPageChange) {
      // Try to extract ?page= or &page= or ?orders_page=2 etc.
      const match = url.match(/([&?](orders_page|products_page|expos_page|page)=)(\d+)/);
      if (match) {
        const page = parseInt(match[3], 10);
        if (!isNaN(page)) {
          onPageChange(page);
          return;
        }
      }
    }
    window.location.href = url;
  };

  return (
    <div className="flex items-center justify-between">
      <div className="text-sm text-gray-700">
        Showing {startItem} to {endItem} of {total} results
      </div>
      
      <div className="flex items-center space-x-2">
        {/* Previous Page */}
        {currentPage > 1 && (
          <Button
            variant="outline"
            size="sm"
            onClick={() => handlePageChange(links.find(link => link.label === '&laquo; Previous')?.url || null)}
          >
            ← Previous
          </Button>
        )}

        {/* Page Numbers */}
        <div className="flex items-center space-x-1">
          {links
            .filter(link => 
              link.label !== '&laquo; Previous' && 
              link.label !== 'Next &raquo;' &&
              link.label !== '...'
            )
            .map((link, index) => (
              <Button
                key={index}
                variant={link.active ? 'default' : 'outline'}
                size="sm"
                onClick={() => handlePageChange(link.url)}
                disabled={!link.url}
                className="min-w-[40px]"
              >
                {link.label}
              </Button>
            ))}
        </div>

        {/* Next Page */}
        {currentPage < lastPage && (
          <Button
            variant="outline"
            size="sm"
            onClick={() => handlePageChange(links.find(link => link.label === 'Next &raquo;')?.url || null)}
          >
            Next →
          </Button>
        )}
      </div>
    </div>
  );
} 