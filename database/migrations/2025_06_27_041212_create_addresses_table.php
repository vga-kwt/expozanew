<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        Schema::create('addresses', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->onDelete('cascade');
            $table->string('role_name'); // e.g. Users, Expos, etc
            $table->string('full_name');
            $table->string('line_1');
            $table->string('line_2')->nullable();
            $table->unsignedBigInteger('country_id');
            $table->unsignedBigInteger('state_id')->nullable();
            $table->string('city');
            $table->string('pincode')->nullable();
            $table->boolean('is_default')->default(false);
            $table->string('phone', 20);
            $table->string('status')->default('active');
            $table->timestamps();
            $table->softDeletes();

        });
    }

    public function down()
    {
        Schema::dropIfExists('addresses');
    }
};