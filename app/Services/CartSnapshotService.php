<?php

namespace App\Services;

use App\Models\Cart;
use App\Models\Coupon;
use App\Models\Product;
use App\Models\Setting;
use App\Models\User;

class CartSnapshotService
{
    public function __construct(
        private readonly CouponService $couponService
    ) {
    }

    public function getVariantData($product, $size = null, $color = null)
    {
        $variantPrice = null;
        $variantSalePrice = null;
        $variantSize = null;
        $variantColor = null;

        // Return default values if product is null
        if (!$product) {
            return [
                'price' => 0,
                'sale_price' => 0,
                'size' => $size,
                'color' => $color,
            ];
        }

        if ($product->attributes) {
            $attributes = $product->attributes;
            if (is_array($attributes) && !empty($attributes)) {
                // If size and color provided, find matching variant
                if ($size && $color) {
                    foreach ($attributes as $variant) {
                        // Match by color (size is now in sizeStockPairs)
                        if (
                            isset($variant['color']) &&
                            strtolower(trim((string) $variant['color'])) === strtolower(trim((string) $color))
                        ) {
                            $variantColor = isset($variant['color']) ? trim((string) $variant['color']) : null;

                            // Check if size exists in sizeStockPairs and get price from there
                            if (isset($variant['sizeStockPairs']) && is_array($variant['sizeStockPairs']) && !empty($variant['sizeStockPairs'])) {
                                foreach ($variant['sizeStockPairs'] as $pair) {
                                    if (
                                        isset($pair['size']) &&
                                        strtolower(trim((string) $pair['size'])) === strtolower(trim((string) $size))
                                    ) {
                                        $variantSize = trim((string) $pair['size']);
                                        // Get price from sizeStockPair (new structure)
                                        $variantPrice = isset($pair['price']) ? (float) $pair['price'] : null;
                                        $variantSalePrice = isset($pair['sale_price']) ? (float) $pair['sale_price'] : null;

                                        // Fallback to variant level price if sizeStockPair doesn't have price (backward compatibility)
                                        if ($variantPrice === null) {
                                            $variantPrice = isset($variant['price']) ? (float) $variant['price'] : null;
                                        }
                                        if ($variantSalePrice === null || $variantSalePrice <= 0) {
                                            $variantSalePrice = isset($pair['sale_price']) && $pair['sale_price'] > 0
                                                ? (float) $pair['sale_price']
                                                : ($variantPrice ?? (isset($variant['sale_price']) ? (float) $variant['sale_price'] : null));
                                        }

                                        if ($variantSalePrice === null || $variantSalePrice <= 0) {
                                            $variantSalePrice = $variantPrice;
                                        }

                                        break;
                                    }
                                }

                                // If size not found in sizeStockPairs but variant matched, use variant level price (backward compatibility)
                                if ($variantSize === null && isset($variant['price'])) {
                                    $variantPrice = (float) $variant['price'];
                                    $variantSalePrice = isset($variant['sale_price']) ? (float) $variant['sale_price'] : $variantPrice;
                                    $variantSize = $size;
                                }
                            } else {
                                // If no sizeStockPairs, use variant level price (backward compatibility)
                                $variantPrice = isset($variant['price']) ? (float) $variant['price'] : null;
                                $variantSalePrice = isset($variant['sale_price']) ? (float) $variant['sale_price'] : null;
                                $variantSize = $size;

                                if ($variantSalePrice === null || $variantSalePrice <= 0) {
                                    $variantSalePrice = $variantPrice;
                                }
                            }

                            // Break after finding matching color variant
                            break;
                        }
                    }
                } elseif ($color) {
                    // If only color provided, find matching variant by color
                    // Try to get price from first sizeStockPair if available, otherwise use variant level
                    foreach ($attributes as $variant) {
                        if (
                            isset($variant['color']) &&
                            strtolower(trim((string) $variant['color'])) === strtolower(trim((string) $color))
                        ) {
                            $variantColor = isset($variant['color']) ? trim((string) $variant['color']) : null;

                            // Try to get price from first sizeStockPair
                            if (isset($variant['sizeStockPairs']) && is_array($variant['sizeStockPairs']) && !empty($variant['sizeStockPairs'])) {
                                $firstPair = $variant['sizeStockPairs'][0];
                                $variantPrice = isset($firstPair['price']) ? (float) $firstPair['price'] : null;
                                $variantSalePrice = isset($firstPair['sale_price']) ? (float) $firstPair['sale_price'] : null;

                                // Fallback to variant level if sizeStockPair doesn't have price
                                if ($variantPrice === null) {
                                    $variantPrice = isset($variant['price']) ? (float) $variant['price'] : null;
                                }
                                if ($variantSalePrice === null || $variantSalePrice <= 0) {
                                    $variantSalePrice = $variantPrice ?? (isset($variant['sale_price']) ? (float) $variant['sale_price'] : null);
                                }
                            } else {
                                // Use variant level price (backward compatibility)
                                $variantPrice = isset($variant['price']) ? (float) $variant['price'] : null;
                                $variantSalePrice = isset($variant['sale_price']) ? (float) $variant['sale_price'] : null;
                            }

                            if ($variantSalePrice === null || $variantSalePrice <= 0) {
                                $variantSalePrice = $variantPrice;
                            }
                            break;
                        }
                    }
                } else {
                    // If size/color not provided, use first variant or first sizeStockPair
                    $firstVariant = $attributes[0] ?? null;
                    if ($firstVariant) {
                        $variantColor = isset($firstVariant['color']) ? trim((string) $firstVariant['color']) : null;

                        // Try to get price from first sizeStockPair
                        if (isset($firstVariant['sizeStockPairs']) && is_array($firstVariant['sizeStockPairs']) && !empty($firstVariant['sizeStockPairs'])) {
                            $firstPair = $firstVariant['sizeStockPairs'][0];
                            $variantPrice = isset($firstPair['price']) ? (float) $firstPair['price'] : null;
                            $variantSalePrice = isset($firstPair['sale_price']) ? (float) $firstPair['sale_price'] : null;

                            // Fallback to variant level if sizeStockPair doesn't have price
                            if ($variantPrice === null) {
                                $variantPrice = isset($firstVariant['price']) ? (float) $firstVariant['price'] : null;
                            }
                            if ($variantSalePrice === null || $variantSalePrice <= 0) {
                                $variantSalePrice = $variantPrice ?? (isset($firstVariant['sale_price']) ? (float) $firstVariant['sale_price'] : null);
                            }
                        } else {
                            // Use variant level price (backward compatibility)
                            $variantPrice = isset($firstVariant['price']) ? (float) $firstVariant['price'] : null;
                            $variantSalePrice = isset($firstVariant['sale_price']) ? (float) $firstVariant['sale_price'] : null;
                        }

                        if ($variantSalePrice === null || $variantSalePrice <= 0) {
                            $variantSalePrice = $variantPrice;
                        }
                    }
                }
            }
        }

        // Use variant price if available, otherwise use product price
        if ($variantSalePrice !== null || $variantPrice !== null) {
            $salePrice = $variantSalePrice ?? $variantPrice;
            $regularPrice = $variantPrice ?? $variantSalePrice;
        } else {
            $salePrice = $product->sale_price ?? $product->regular_price ?? 0;
            $regularPrice = $product->regular_price ?? $product->sale_price ?? 0;
        }

        // Ensure we have a valid price
        if ($salePrice <= 0 && $regularPrice > 0) {
            $salePrice = $regularPrice;
        }

        return [
            'price' => $regularPrice,
            'sale_price' => $salePrice,
            'size' => $variantSize ?? $size,
            'color' => $variantColor ?? $color,
        ];
    }

    /**
     * Filter product attributes by color - return only matching color variant
     * 
     * @param array|null $attributes
     * @param string|null $color
     * @return array|null
     */
    public function filterAttributesByColor($attributes, $color = null)
    {
        if (!$attributes || !is_array($attributes) || empty($attributes)) {
            return $attributes;
        }

        // If no color provided, return all attributes
        if (!$color || empty(trim($color))) {
            return $attributes;
        }

        $color = strtolower(trim((string) $color));

        // Find and return only the variant matching the color
        foreach ($attributes as $variant) {
            if (
                isset($variant['color']) &&
                strtolower(trim((string) $variant['color'])) === $color
            ) {
                return [$variant]; // Return only the matching variant
            }
        }

        // If no match found, return empty array (or could return all for backward compatibility)
        return [];
    }

    /**
     * @return array<string, mixed>
     */
    public function build(?Cart $cart, ?User $user = null): array
    {
        if (! $cart) {
            // Get base delivery fee from settings
            $baseDeliveryFee = (float) Setting::where('key', 'base_delivery_fee')->value('value') ?? 0;
            $grandBefore = round($baseDeliveryFee, 2);

            return [
                'cart_id' => null,
                'items' => [],
                'subtotal' => 0,
                'shipping_fee' => $baseDeliveryFee,
                'grand_total_before_discount' => $grandBefore,
                'discount_amount' => 0,
                'grand_total' => $grandBefore,
                'coupon' => null,
            ];
        }

        // Reload cart with items and products
        $cart->load(['items.product', 'coupon']);

        $items = $cart->items->map(function ($item) {
            $product = $item->product;

            // Get variant data from attributes if size/color available
            $variantData = $this->getVariantData($product, $item->size, $item->color);
            $regular_price = $variantData['price'];
            $sale_price = $variantData['sale_price'];

            $discount = $regular_price > 0 ? $regular_price - $sale_price : 0;
            $discount = round($discount + 0.00001, 2);
            $total_price = $sale_price * $item->quantity;

            // Remove vendor from product if present and filter attributes by color
            $productArr = $product ? $product->toArray() : null;
            if ($productArr) {
                if (array_key_exists('vendor', $productArr)) {
                    unset($productArr['vendor']);
                }

                // Filter attributes to only include the variant matching the item's color
                if (isset($productArr['attributes']) && $item->color) {
                    $productArr['attributes'] = $this->filterAttributesByColor($productArr['attributes'], $item->color);
                }
            }

            return [
                'id' => $item->id,
                'product_id' => $item->product_id,
                'product_name' => $product ? $product->name_en : null,
                'size' => $item->size,
                'color' => $item->color,
                'regular_price' => $regular_price,
                'sale_price' => $sale_price,
                'discount' => $discount,
                'quantity' => $item->quantity,
                'total_price' => $total_price,
                'product' => $productArr, // product with all details
            ];
        });

        $subtotal = $items->sum(function ($item) {
            return $item['total_price'];
        });

        // Get base delivery fee and free delivery threshold from settings
        $baseDeliveryFee = (float) Setting::where('key', 'base_delivery_fee')->value('value') ?? 0;
        $freeDeliveryThreshold = (float) Setting::where('key', 'free_delivery_threshold')->value('value') ?? 0;

        // Apply free delivery: if calculated threshold > 0 AND subtotal >= threshold, free delivery
        // If threshold is 0 (disabled), ALWAYS charge base delivery fee
        $shippingFee = ($freeDeliveryThreshold > 0 && $subtotal >= $freeDeliveryThreshold) ? 0 : $baseDeliveryFee;

        $grandBefore = round($subtotal + $shippingFee, 2);
        $discountAmount = 0.0;
        $couponPayload = null;
        $couponNotice = null;

        if ($cart->coupon_id && $user) {
            $coupon = $cart->relationLoaded('coupon') ? $cart->coupon : Coupon::find($cart->coupon_id);
            [$ok, $message, $validCoupon] = $this->couponService->validateForUser($coupon, $user);
            if (! $ok || ! $validCoupon) {
                $cart->update(['coupon_id' => null, 'coupon_code' => null]);
                $couponNotice = $message;
            } else {
                $discountAmount = $this->couponService->computeDiscountAmount($grandBefore, $validCoupon);
                $couponPayload = [
                    'code' => $validCoupon->code,
                    'percentage' => (float) $validCoupon->percentage,
                ];
            }
        }

        $grandTotal = max(0.0, round($grandBefore - $discountAmount, 2));

        $out = [
            'cart_id' => $cart->id,
            'items' => $items,
            'subtotal' => $subtotal,
            'shipping_fee' => $shippingFee,
            'grand_total_before_discount' => $grandBefore,
            'discount_amount' => $discountAmount,
            'grand_total' => $grandTotal,
            'coupon' => $couponPayload,
        ];

        if ($couponNotice) {
            $out['coupon_notice'] = $couponNotice;
        }

        return $out;
    }
}
