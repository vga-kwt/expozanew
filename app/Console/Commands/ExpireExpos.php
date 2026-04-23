<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use App\Models\Expo;
use Illuminate\Support\Carbon;

class ExpireExpos extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'expos:expire';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Automatically expire expos that have passed their end date';

    /**
     * Execute the console command.
     */
    public function handle()
    {
        $this->info('Starting expo expiry check...');

        $expiredExpos = Expo::where('status', 'active')
            ->where('end_date', '<', Carbon::now())
            ->get();

        if ($expiredExpos->isEmpty()) {
            $this->info('No expos to expire.');
            return 0;
        }

        $count = 0;
        foreach ($expiredExpos as $expo) {
            $expo->update(['status' => 'expired']);
            $this->line("Expired expo: {$expo->name_en} (ID: {$expo->id})");
            $count++;
        }

        $this->info("Successfully expired {$count} expos.");
        return 0;
    }
}
