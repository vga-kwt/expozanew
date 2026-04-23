import React from 'react';
import { cn } from '@/lib/utils';

interface TrackingEvent {
  status: string;
  location: string;
  description: string;
  timestamp: string;
  is_ready: boolean;
  is_dispatched: boolean;
  in_transit: boolean;
  is_delivered: boolean;
  is_rto: boolean;
  is_rto_recieved: boolean;
}

interface StatusFlagProps {
  label: string;
  value: boolean;
}

function StatusFlag({ label, value }: StatusFlagProps) {
  return (
    <div className="mr-4">
      <span className="text-xs font-semibold text-gray-700">{label}:</span>
      <span className="text-xs text-gray-500 ml-1">{value ? 'Yes' : 'No'}</span>
    </div>
  );
}

export function TrackingTimeline() {
  // Dummy event for UI preview
  const event = {
    status: 'Delivered',
    location: 'Warehouse',
    description: 'Order delivered to customer',
    timestamp: new Date().toISOString(),
    is_ready: true,
    is_dispatched: false,
    in_transit: false,
    is_delivered: false,
    is_rto: false,
    is_rto_recieved: false,
  };
  return (
    <div className="relative pl-6 border-l-2 border-blue-300">
      <div className="mb-8 flex items-start">
        <span
          style={{ left: '-9px', top: '10px' }}
          className={cn(
            'absolute mt-1 h-4 w-4 rounded-full border-2',
            'bg-blue-500 border-blue-700'
          )}
        />
        <div className="ml-4">
          <div className="mt-2 flex flex-col items-start space-y-2">
            <StatusFlag label="Ready" value={event.is_ready} />
            <StatusFlag label="Dispatched" value={event.is_dispatched} />
            <StatusFlag label="In Transit" value={event.in_transit} />
            <StatusFlag label="Delivered" value={event.is_delivered} />
            <StatusFlag label="RTO" value={event.is_rto} />
            <StatusFlag label="RTO Received" value={event.is_rto_recieved} />
            <div className="mr-4">
              <span className="text-xs font-semibold text-gray-700">RTO:</span>
              <span className="text-xs text-gray-500 ml-1">Yes</span>
            </div>
            <div>
              <span className="text-xs font-semibold text-gray-700">RTO Received:</span>
              <span className="text-xs text-gray-500 ml-1">Yes</span>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
