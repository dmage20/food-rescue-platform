'use client';

import { CartItem as CartItemType } from '@/types';
import { useCartStore } from '@/stores/cartStore';
import { formatPrice } from '@/lib/utils';
import { Button } from '@/components/ui/Button';
import { MinusIcon, PlusIcon, TrashIcon } from 'lucide-react';

interface CartItemProps {
  item: CartItemType;
}

export function CartItem({ item }: CartItemProps) {
  const { updateQuantity, removeItem } = useCartStore();

  const handleQuantityChange = (newQuantity: number) => {
    updateQuantity(item.type, item.id, newQuantity);
  };

  const handleRemove = () => {
    removeItem(item.type, item.id);
  };

  const itemTotal = item.item.discounted_price * item.quantity;

  return (
    <div className="flex items-center space-x-4 py-4 border-b border-gray-200 last:border-b-0">
      {/* Item image placeholder */}
      <div className="flex-shrink-0 w-16 h-16 bg-gray-200 rounded-lg flex items-center justify-center">
        <span className="text-2xl">
          {item.type === 'bundle' ? '📦' : '🥖'}
        </span>
      </div>

      {/* Item details */}
      <div className="flex-grow min-w-0">
        <h3 className="font-medium text-gray-900 truncate">{item.item.name}</h3>
        <p className="text-sm text-gray-500 line-clamp-2">{item.item.description}</p>

        {/* Price */}
        <div className="flex items-center space-x-2 mt-1">
          <span className="font-medium text-green-600">
            {formatPrice(item.item.discounted_price)}
          </span>
          {item.item.original_price > item.item.discounted_price && (
            <span className="text-xs text-gray-500 line-through">
              {formatPrice(item.item.original_price)}
            </span>
          )}
        </div>

        {/* Allergens */}
        {item.item.allergens.length > 0 && (
          <div className="mt-1">
            <p className="text-xs text-red-600">
              Allergens: {item.item.allergens.join(', ')}
            </p>
          </div>
        )}
      </div>

      {/* Quantity controls */}
      <div className="flex items-center space-x-2">
        <Button
          size="sm"
          variant="outline"
          onClick={() => handleQuantityChange(item.quantity - 1)}
          disabled={item.quantity <= 1}
          className="h-8 w-8 p-0"
        >
          <MinusIcon className="h-4 w-4" />
        </Button>

        <span className="w-8 text-center text-sm font-medium">
          {item.quantity}
        </span>

        <Button
          size="sm"
          variant="outline"
          onClick={() => handleQuantityChange(item.quantity + 1)}
          disabled={item.quantity >= item.item.available_quantity}
          className="h-8 w-8 p-0"
        >
          <PlusIcon className="h-4 w-4" />
        </Button>
      </div>

      {/* Item total and remove */}
      <div className="text-right">
        <div className="font-medium text-gray-900">
          {formatPrice(itemTotal)}
        </div>
        <Button
          size="sm"
          variant="ghost"
          onClick={handleRemove}
          className="mt-1 text-red-600 hover:text-red-700 hover:bg-red-50 h-6 w-6 p-0"
        >
          <TrashIcon className="h-4 w-4" />
        </Button>
      </div>
    </div>
  );
}