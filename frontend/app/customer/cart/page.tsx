'use client';

import { useRouter } from 'next/navigation';
import { ProtectedRoute } from '@/components/layout/ProtectedRoute';
import { CartItem } from '@/components/customer/CartItem';
import { useCartStore, useCartSummary } from '@/stores/cartStore';
import { Button } from '@/components/ui/Button';
import { Card, CardContent, CardFooter, CardHeader, CardTitle } from '@/components/ui/Card';
import { formatPrice } from '@/lib/utils';
import { ArrowLeftIcon, ShoppingBagIcon } from 'lucide-react';

export default function CartPage() {
  const router = useRouter();
  const { clearCart } = useCartStore();
  const { items, total, isEmpty } = useCartSummary();

  const handleContinueShopping = () => {
    router.push('/customer/discover');
  };

  const handleProceedToCheckout = () => {
    router.push('/customer/checkout');
  };

  const handleClearCart = () => {
    if (confirm('Are you sure you want to clear your cart?')) {
      clearCart();
    }
  };

  return (
    <ProtectedRoute requiredRole="customer">
      <div className="min-h-screen bg-gray-50">
        {/* Header */}
        <div className="bg-white border-b border-gray-200">
          <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-6">
            <div className="flex items-center">
              <Button
                variant="ghost"
                onClick={handleContinueShopping}
                className="mr-4 p-2"
              >
                <ArrowLeftIcon className="h-5 w-5" />
              </Button>
              <div>
                <h1 className="text-2xl font-bold text-gray-900">Shopping Cart</h1>
                <p className="mt-1 text-gray-600">
                  {isEmpty ? 'Your cart is empty' : `${items.length} item${items.length === 1 ? '' : 's'} in your cart`}
                </p>
              </div>
            </div>
          </div>
        </div>

        <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
          {isEmpty ? (
            /* Empty cart state */
            <div className="text-center py-16">
              <ShoppingBagIcon className="mx-auto h-16 w-16 text-gray-400 mb-4" />
              <h2 className="text-xl font-medium text-gray-900 mb-2">
                Your cart is empty
              </h2>
              <p className="text-gray-600 mb-6">
                Discover fresh goods at discounted prices from local merchants.
              </p>
              <Button onClick={handleContinueShopping}>
                Start Shopping
              </Button>
            </div>
          ) : (
            /* Cart with items */
            <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
              {/* Cart items */}
              <div className="lg:col-span-2">
                <Card>
                  <CardHeader className="flex flex-row items-center justify-between">
                    <CardTitle>Cart Items</CardTitle>
                    <Button
                      variant="ghost"
                      size="sm"
                      onClick={handleClearCart}
                      className="text-red-600 hover:text-red-700"
                    >
                      Clear Cart
                    </Button>
                  </CardHeader>
                  <CardContent className="p-0">
                    <div className="px-6">
                      {items.map((item) => (
                        <CartItem key={`${item.type}-${item.id}`} item={item} />
                      ))}
                    </div>
                  </CardContent>
                </Card>
              </div>

              {/* Order summary */}
              <div className="lg:col-span-1">
                <Card className="sticky top-24">
                  <CardHeader>
                    <CardTitle>Order Summary</CardTitle>
                  </CardHeader>
                  <CardContent className="space-y-4">
                    {/* Item breakdown */}
                    <div className="space-y-2">
                      {items.map((item) => (
                        <div key={`${item.type}-${item.id}`} className="flex justify-between text-sm">
                          <span className="text-gray-600">
                            {item.item.name} × {item.quantity}
                          </span>
                          <span className="font-medium">
                            {formatPrice(item.item.discounted_price * item.quantity)}
                          </span>
                        </div>
                      ))}
                    </div>

                    <div className="border-t border-gray-200 pt-4">
                      <div className="flex justify-between text-base font-medium">
                        <span>Total</span>
                        <span className="text-green-600">{formatPrice(total)}</span>
                      </div>
                      <p className="text-sm text-gray-500 mt-1">
                        Tax and pickup details will be calculated at checkout
                      </p>
                    </div>
                  </CardContent>
                  <CardFooter className="flex flex-col space-y-3">
                    <Button
                      onClick={handleProceedToCheckout}
                      className="w-full"
                      size="lg"
                    >
                      Proceed to Checkout
                    </Button>
                    <Button
                      variant="outline"
                      onClick={handleContinueShopping}
                      className="w-full"
                    >
                      Continue Shopping
                    </Button>
                  </CardFooter>
                </Card>
              </div>
            </div>
          )}
        </div>
      </div>
    </ProtectedRoute>
  );
}