'use client';

import { useState } from 'react';
import { Product, Bundle } from '@/types';
import { useCartStore } from '@/stores/cartStore';
import { Button } from '@/components/ui/Button';
import { Card, CardContent, CardFooter } from '@/components/ui/Card';
import { formatPrice, formatDate } from '@/lib/utils';
import { ClockIcon, MapPinIcon } from 'lucide-react';

interface ProductCardProps {
  item: Product | Bundle;
  type: 'product' | 'bundle';
}

export function ProductCard({ item, type }: ProductCardProps) {
  const { addItem, canAddItem } = useCartStore();
  const [quantity, setQuantity] = useState(1);
  const [isAdding, setIsAdding] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const handleAddToCart = async () => {
    try {
      setError(null);
      setIsAdding(true);

      if (!canAddItem(item.merchant_id)) {
        setError('Cannot add items from different merchants to the same cart. Please checkout first or clear your cart.');
        return;
      }

      addItem(item, type, quantity);
      setQuantity(1); // Reset quantity after adding
    } catch (err: any) {
      setError(err.message || 'Failed to add item to cart');
    } finally {
      setIsAdding(false);
    }
  };

  const discountPercentage = Math.round(
    ((item.original_price - item.discounted_price) / item.original_price) * 100
  );

  const expiresAt = 'expires_at' in item ? item.expires_at : null;
  const pickupWindow = 'pickup_window_start' in item
    ? `${formatDate(item.pickup_window_start)} - ${formatDate(item.pickup_window_end)}`
    : null;

  return (
    <Card className="h-full flex flex-col">
      <div className="relative">
        {/* Placeholder for image */}
        <div className="w-full h-48 bg-gray-200 rounded-t-lg flex items-center justify-center">
          <span className="text-4xl">
            {type === 'bundle' ? '📦' : '🥖'}
          </span>
        </div>

        {/* Discount badge */}
        {discountPercentage > 0 && (
          <div className="absolute top-2 right-2 bg-green-600 text-white px-2 py-1 rounded-md text-sm font-medium">
            {discountPercentage}% OFF
          </div>
        )}

        {/* Type badge */}
        <div className="absolute top-2 left-2 bg-white/90 backdrop-blur-sm px-2 py-1 rounded-md text-xs font-medium text-gray-600">
          {type === 'bundle' ? 'Bundle' : 'Product'}
        </div>
      </div>

      <CardContent className="flex-grow p-4">
        <h3 className="font-semibold text-lg mb-2 line-clamp-2">{item.name}</h3>
        <p className="text-gray-600 text-sm mb-3 line-clamp-2">{item.description}</p>

        {/* Category and tags */}
        <div className="flex flex-wrap gap-1 mb-3">
          {'category' in item && (
            <span className="bg-blue-100 text-blue-800 text-xs px-2 py-1 rounded-full">
              {item.category}
            </span>
          )}
          {item.dietary_tags.slice(0, 2).map((tag) => (
            <span key={tag} className="bg-green-100 text-green-800 text-xs px-2 py-1 rounded-full">
              {tag}
            </span>
          ))}
          {item.dietary_tags.length > 2 && (
            <span className="bg-gray-100 text-gray-600 text-xs px-2 py-1 rounded-full">
              +{item.dietary_tags.length - 2}
            </span>
          )}
        </div>

        {/* Allergens */}
        {item.allergens.length > 0 && (
          <div className="mb-3">
            <p className="text-xs text-red-600">
              Allergens: {item.allergens.join(', ')}
            </p>
          </div>
        )}

        {/* Pricing */}
        <div className="flex items-center justify-between mb-3">
          <div className="flex items-center space-x-2">
            <span className="text-xl font-bold text-green-600">
              {formatPrice(item.discounted_price)}
            </span>
            {item.original_price > item.discounted_price && (
              <span className="text-sm text-gray-500 line-through">
                {formatPrice(item.original_price)}
              </span>
            )}
          </div>
          <div className="text-sm text-gray-600">
            {item.available_quantity} left
          </div>
        </div>

        {/* Time info */}
        <div className="space-y-1 text-xs text-gray-500">
          {expiresAt && (
            <div className="flex items-center">
              <ClockIcon className="h-3 w-3 mr-1" />
              Expires: {formatDate(expiresAt)}
            </div>
          )}
          {pickupWindow && (
            <div className="flex items-center">
              <MapPinIcon className="h-3 w-3 mr-1" />
              Pickup: {pickupWindow}
            </div>
          )}
        </div>
      </CardContent>

      <CardFooter className="p-4 pt-0">
        {item.available_quantity > 0 ? (
          <div className="w-full space-y-3">
            {/* Quantity selector */}
            <div className="flex items-center justify-between">
              <label className="text-sm font-medium">Quantity:</label>
              <div className="flex items-center space-x-2">
                <button
                  onClick={() => setQuantity(Math.max(1, quantity - 1))}
                  className="w-8 h-8 rounded-md bg-gray-100 hover:bg-gray-200 flex items-center justify-center text-sm font-medium"
                  disabled={quantity <= 1}
                >
                  -
                </button>
                <span className="w-8 text-center text-sm font-medium">{quantity}</span>
                <button
                  onClick={() => setQuantity(Math.min(item.available_quantity, quantity + 1))}
                  className="w-8 h-8 rounded-md bg-gray-100 hover:bg-gray-200 flex items-center justify-center text-sm font-medium"
                  disabled={quantity >= item.available_quantity}
                >
                  +
                </button>
              </div>
            </div>

            {error && (
              <div className="text-xs text-red-600 bg-red-50 p-2 rounded-md">
                {error}
              </div>
            )}

            <Button
              onClick={handleAddToCart}
              className="w-full"
              size="sm"
              isLoading={isAdding}
              disabled={isAdding || quantity <= 0}
            >
              Add to Cart ({formatPrice(item.discounted_price * quantity)})
            </Button>
          </div>
        ) : (
          <div className="w-full text-center py-2 text-gray-500 text-sm">
            Out of Stock
          </div>
        )}
      </CardFooter>
    </Card>
  );
}