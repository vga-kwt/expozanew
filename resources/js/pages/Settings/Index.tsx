import React, { useState } from 'react';
import { useForm, Head } from '@inertiajs/react';
import { Button } from '../../components/ui/button';
import { Card, CardContent, CardHeader, CardTitle } from '../../components/ui/card';
import { Input } from '../../components/ui/input';
import AppLayout from '../../layouts/app-layout';

interface SettingsProps {
  settings: Record<string, string>;
}

const payoutOptions = [
  { label: 'Every 15 Days', value: '15_days' },
  { label: 'Monthly', value: 'monthly' },
  { label: 'Custom', value: 'custom' },
];

export default function SettingsIndex({ settings }: SettingsProps) {
  const [payoutFrequency, setPayoutFrequency] = useState(settings.payout_frequency || '15_days');
  const { data, setData, post, processing, errors } = useForm({
    payout_frequency: settings.payout_frequency || '15_days',
    custom_payout_date: settings.custom_payout_date || '',
    vendor_commission: settings.vendor_commission || '',
    gateway_fees: settings.gateway_fees || '',
    admin_notifications: settings.admin_notifications === '1' || false,
    delivery_fee_per_km: settings.delivery_fee_per_km || '',
    base_delivery_fee: settings.base_delivery_fee || '',
    free_delivery_threshold: settings.free_delivery_threshold || '',
  });

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    post(route('settings.update'));
  };

  return (
    <div className="container mx-auto px-4 py-8 space-y-8 bg-background min-h-screen">
      <Head title="Platform Settings" />
      <h1 className="text-3xl font-bold mb-6">Platform Settings</h1>
      <form onSubmit={handleSubmit} className="space-y-8">
        <Card>
          <CardHeader>
            <CardTitle>Payout Frequency</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="flex gap-4">
              {payoutOptions.map(opt => (
                <label key={opt.value} className="flex items-center gap-2">
                  <input
                    type="radio"
                    name="payout_frequency"
                    value={opt.value}
                    checked={data.payout_frequency === opt.value}
                    onChange={e => {
                      setData('payout_frequency', opt.value);
                      setPayoutFrequency(opt.value);
                    }}
                  />
                  {opt.label}
                </label>
              ))}
            </div>
            {payoutFrequency === 'custom' && (
              <div className="mt-4">
                <label className="block text-sm font-medium mb-1">Custom Payout Date</label>
                <Input
                  type="date"
                  name="custom_payout_date"
                  value={data.custom_payout_date}
                  onChange={e => setData('custom_payout_date', e.target.value)}
                />
                {errors.custom_payout_date && <div className="text-red-500 text-xs mt-1">{errors.custom_payout_date}</div>}
              </div>
            )}
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle>Default Vendor Commission (%)</CardTitle>
          </CardHeader>
          <CardContent>
            <Input
              type="number"
              name="vendor_commission"
              min={0}
              max={100}
              value={data.vendor_commission}
              onChange={e => setData('vendor_commission', e.target.value)}
              placeholder="e.g. 10"
            />
            {errors.vendor_commission && <div className="text-red-500 text-xs mt-1">{errors.vendor_commission}</div>}
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle>Payment Gateway Fees (%)</CardTitle>
          </CardHeader>
          <CardContent>
            <Input
              type="number"
              name="gateway_fees"
              min={0}
              max={100}
              value={data.gateway_fees}
              onChange={e => setData('gateway_fees', e.target.value)}
              placeholder="e.g. 2.5"
            />
            {errors.gateway_fees && <div className="text-red-500 text-xs mt-1">{errors.gateway_fees}</div>}
          </CardContent>
        </Card>

        {/* <Card>
          <CardHeader>
            <CardTitle>Admin Notifications</CardTitle>
          </CardHeader>
          <CardContent>
            <label className="flex items-center gap-2">
              <input
                type="checkbox"
                name="admin_notifications"
                checked={!!data.admin_notifications}
                onChange={e => setData('admin_notifications', e.target.checked)}
              />
              Enable notifications for admin events
            </label>
            {errors.admin_notifications && <div className="text-red-500 text-xs mt-1">{errors.admin_notifications}</div>}
          </CardContent>
        </Card> */}

        <Card>
          <CardHeader>
            <CardTitle>Delivery Fee Settings</CardTitle>
          </CardHeader>
          <CardContent className="space-y-4">
            <div>
              <label className="block text-sm font-medium mb-1">Base Delivery Fee (KWD)</label>
              <Input
                type="number"
                name="base_delivery_fee"
                min={0}
                step="0.01"
                value={data.base_delivery_fee}
                onChange={e => setData('base_delivery_fee', e.target.value)}
                placeholder="e.g. 1.00"
              />
              <p className="text-xs text-muted-foreground mt-1">Fixed base fee for all deliveries</p>
              {errors.base_delivery_fee && <div className="text-red-500 text-xs mt-1">{errors.base_delivery_fee}</div>}
            </div>
            {/* <div>
              <label className="block text-sm font-medium mb-1">Delivery Fee per KM (KWD)</label>
              <Input
                type="number"
                name="delivery_fee_per_km"
                min={0}
                step="0.01"
                value={data.delivery_fee_per_km}
                onChange={e => setData('delivery_fee_per_km', e.target.value)}
                placeholder="e.g. 0.50"
              />
              <p className="text-xs text-muted-foreground mt-1">Additional fee charged per kilometer</p>
              {errors.delivery_fee_per_km && <div className="text-red-500 text-xs mt-1">{errors.delivery_fee_per_km}</div>}
            </div> */}
            <div>
              <label className="block text-sm font-medium mb-1">Free Delivery Threshold (KWD)</label>
              <Input
                type="number"
                name="free_delivery_threshold"
                min={0}
                step="0.01"
                value={data.free_delivery_threshold}
                onChange={e => setData('free_delivery_threshold', e.target.value)}
                placeholder="e.g. 50.00"
              />
              <p className="text-xs text-muted-foreground mt-1">Order amount above which delivery is free.</p>
              {errors.free_delivery_threshold && <div className="text-red-500 text-xs mt-1">{errors.free_delivery_threshold}</div>}
            </div>
          </CardContent>
        </Card>

        <div className="flex justify-end">
          <Button type="submit" disabled={processing}>
            Save Settings
          </Button>
        </div>
      </form>
    </div>
  );
}

SettingsIndex.layout = (page: React.ReactNode) => <AppLayout children={page} />; 