import * as React from "react";
import { Select, SelectTrigger, SelectValue, SelectContent, SelectItem } from "./select";

export type StatusOption = {
  value: string;
  label: string;
};

const defaultStatusOptions: StatusOption[] = [
  { value: "all", label: "All Statuses" },
  { value: "pending", label: "Pending" },
  { value: "confirmed", label: "Confirmed" },
  { value: "processing", label: "Processing" },
  { value: "ready_for_pickup", label: "Ready for Pickup" },
  { value: "shipped", label: "Shipped" },
  { value: "out_for_delivery", label: "Out for Delivery" },
  { value: "delivered", label: "Delivered" },
  { value: "cancelled", label: "Cancelled" },
  { value: "returned", label: "Returned" },
  { value: "failed", label: "Failed" },
];

interface StatusFilterProps {
  value: string;
  onChange: (value: string) => void;
  placeholder?: string;
  statusOptions?: StatusOption[];
  className?: string;
}

export const StatusFilter: React.FC<StatusFilterProps> = ({
  value,
  onChange,
  placeholder = "Filter by status",
  statusOptions = defaultStatusOptions,
  className,
}) => {
  // If value is '' or 'all', show placeholder
  const showPlaceholder = !value || value === 'all';
  return (
    <Select value={showPlaceholder ? '' : value} onValueChange={onChange}>
      <SelectTrigger className={className || "w-[180px]"}>
        <SelectValue placeholder={placeholder} />
      </SelectTrigger>
      <SelectContent>
        {statusOptions.map((option) => (
          <SelectItem key={option.value} value={option.value}>
            {option.label}
          </SelectItem>
        ))}
      </SelectContent>
    </Select>
  );
}; 