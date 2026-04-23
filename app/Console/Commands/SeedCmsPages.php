<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use Database\Seeders\CmsPageSeeder;

class SeedCmsPages extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'seed:cms-pages {--fresh : Truncate the table before seeding}';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Seed CMS pages with sample data';

    /**
     * Execute the console command.
     */
    public function handle()
    {
        $this->info('Starting CMS pages seeding...');

        if ($this->option('fresh')) {
            $this->warn('Truncating cms_pages table...');
            \App\Models\CmsPage::truncate();
            $this->info('Table truncated successfully.');
        }

        try {
            $seeder = new CmsPageSeeder();
            $seeder->run();
            
            $this->info('CMS pages seeded successfully!');
            $this->info('You can now view the CMS pages in the admin panel.');
            
        } catch (\Exception $e) {
            $this->error('Error seeding CMS pages: ' . $e->getMessage());
            return 1;
        }

        return 0;
    }
}
