<?php

namespace App\Services;

use App\Models\Product;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;

class InventoryService
{
    /**
     * Decrease stock from product variants and main stock
     * Supports sizeStockPairs structure
     * 
     * @param Product $product
     * @param int $quantity
     * @param string|null $size
     * @param string|null $color
     * @return bool
     */
    public function decreaseStock(Product $product, int $quantity, ?string $size = null, ?string $color = null): bool
    {
        try {
            DB::beginTransaction();

            // Get current attributes (variants)
            $attributes = $product->attributes ?? [];
            $stockDecreased = false;
            
            // If size and color are provided, decrease stock from specific variant
            if ($size !== null && $color !== null && !empty($attributes)) {
                foreach ($attributes as $index => $variant) {
                    // Match by color (size is now in sizeStockPairs)
                    if (
                        isset($variant['color']) &&
                        strtolower(trim((string)$variant['color'])) === strtolower(trim((string)$color))
                    ) {
                        // First, check sizeStockPairs if size is provided
                        if ($size !== null && isset($variant['sizeStockPairs']) && is_array($variant['sizeStockPairs'])) {
                            foreach ($variant['sizeStockPairs'] as $pairIndex => $pair) {
                                if (
                                    isset($pair['size']) &&
                                    strtolower(trim((string)$pair['size'])) === strtolower(trim((string)$size))
                                ) {
                                    $currentStock = (int)($pair['stock'] ?? 0);
                                    if ($currentStock < $quantity) {
                                        DB::rollBack();
                                        throw new \Exception("Insufficient stock for Size {$size}, Color {$color}. Available: {$currentStock}, Requested: {$quantity}");
                                    }
                                    
                                    // Decrease stock from sizeStockPairs
                                    $attributes[$index]['sizeStockPairs'][$pairIndex]['stock'] = $currentStock - $quantity;
                                    $stockDecreased = true;
                                    break;
                                }
                            }
                        }
                        
                        // If not found in sizeStockPairs, check variant stock
                        if (!$stockDecreased) {
                            $currentStock = (int)($variant['stock'] ?? 0);
                            if ($currentStock < $quantity) {
                                DB::rollBack();
                                throw new \Exception("Insufficient stock for variant Color {$color}. Available: {$currentStock}, Requested: {$quantity}");
                            }
                            
                            // Decrease variant stock
                            $attributes[$index]['stock'] = $currentStock - $quantity;
                            $stockDecreased = true;
                        }
                        break;
                    }
                }
                
                if (!$stockDecreased) {
                    Log::warning("Variant not found for product {$product->id}: Size {$size}, Color {$color}");
                }
            }
            
            // Decrease main product stock (always decrease from main stock as well)
            $currentMainStock = (int)$product->stock;
            if ($currentMainStock < $quantity) {
                DB::rollBack();
                throw new \Exception("Insufficient main stock. Available: {$currentMainStock}, Requested: {$quantity}");
            }
            
            // Update product
            $product->stock = $currentMainStock - $quantity;
            
            // Update attributes if modified
            if ($size !== null && $color !== null && !empty($attributes) && $stockDecreased) {
                $product->attributes = $attributes;
            }
            
            $product->save();
            
            DB::commit();
            return true;
            
        } catch (\Exception $e) {
            DB::rollBack();
            Log::error("Inventory decrease failed for product {$product->id}: " . $e->getMessage());
            throw $e;
        }
    }

    /**
     * Increase stock (for refunds/cancellations)
     * Supports sizeStockPairs structure
     * 
     * @param Product $product
     * @param int $quantity
     * @param string|null $size
     * @param string|null $color
     * @return bool
     */
    public function increaseStock(Product $product, int $quantity, ?string $size = null, ?string $color = null): bool
    {
        try {
            DB::beginTransaction();

            // Get current attributes (variants)
            $attributes = $product->attributes ?? [];
            $stockIncreased = false;
            
            // If size and color are provided, increase stock in specific variant
            if ($size !== null && $color !== null && !empty($attributes)) {
                foreach ($attributes as $index => $variant) {
                    // Match by color (size is now in sizeStockPairs)
                    if (
                        isset($variant['color']) &&
                        strtolower(trim((string)$variant['color'])) === strtolower(trim((string)$color))
                    ) {
                        // First, check sizeStockPairs if size is provided
                        if ($size !== null && isset($variant['sizeStockPairs']) && is_array($variant['sizeStockPairs'])) {
                            foreach ($variant['sizeStockPairs'] as $pairIndex => $pair) {
                                if (
                                    isset($pair['size']) &&
                                    strtolower(trim((string)$pair['size'])) === strtolower(trim((string)$size))
                                ) {
                                    $currentStock = (int)($pair['stock'] ?? 0);
                                    $attributes[$index]['sizeStockPairs'][$pairIndex]['stock'] = $currentStock + $quantity;
                                    $stockIncreased = true;
                                    break;
                                }
                            }
                        }
                        
                        // If not found in sizeStockPairs, increase variant stock
                        if (!$stockIncreased) {
                            $currentStock = (int)($variant['stock'] ?? 0);
                            $attributes[$index]['stock'] = $currentStock + $quantity;
                            $stockIncreased = true;
                        }
                        break;
                    }
                }
            }
            
            // Increase main product stock
            $product->stock = (int)$product->stock + $quantity;
            
            // Update attributes if modified
            if ($size !== null && $color !== null && !empty($attributes) && $stockIncreased) {
                $product->attributes = $attributes;
            }
            
            $product->save();
            
            DB::commit();
            return true;
            
        } catch (\Exception $e) {
            DB::rollBack();
            Log::error("Inventory increase failed for product {$product->id}: " . $e->getMessage());
            throw $e;
        }
    }

    /**
     * Check if product has enough stock
     * Supports sizeStockPairs structure
     * 
     * @param Product $product
     * @param int $quantity
     * @param string|null $size
     * @param string|null $color
     * @return bool
     */
    public function hasEnoughStock(Product $product, int $quantity, ?string $size = null, ?string $color = null): bool
    {
        // Check main stock first
        if ((int)$product->stock < $quantity) {
            return false;
        }
        
        // If variant specified, check variant stock or sizeStockPairs
        if ($size !== null && $color !== null) {
            $attributes = $product->attributes ?? [];
            foreach ($attributes as $variant) {
                // Match by color (size is now in sizeStockPairs)
                if (
                    isset($variant['color']) &&
                    strtolower(trim((string)$variant['color'])) === strtolower(trim((string)$color))
                ) {
                    // First, check sizeStockPairs if size is provided
                    if ($size !== null && isset($variant['sizeStockPairs']) && is_array($variant['sizeStockPairs'])) {
                        foreach ($variant['sizeStockPairs'] as $pair) {
                            if (
                                isset($pair['size']) &&
                                strtolower(trim((string)$pair['size'])) === strtolower(trim((string)$size))
                            ) {
                                $pairStock = (int)($pair['stock'] ?? 0);
                                return $pairStock >= $quantity;
                            }
                        }
                    }
                    
                    // If not found in sizeStockPairs, check variant stock
                    $variantStock = (int)($variant['stock'] ?? 0);
                    return $variantStock >= $quantity;
                }
            }
            // Variant not found, but main stock is enough
            return true;
        }
        
        return true;
    }
}

