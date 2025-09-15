'use client';

import { useState } from 'react';
import { useRouter } from 'next/navigation';
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';
import { useMutation } from '@tanstack/react-query';
import { ProtectedRoute } from '@/components/layout/ProtectedRoute';
import { useCartStore, useCartSummary } from '@/stores/cartStore';
import { customerApi } from '@/lib/api';
import { Button } from '@/components/ui/Button';
import { Input } from '@/components/ui/Input';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/Card';
import { formatPrice } from '@/lib/utils';
import { ArrowLeftIcon, CalendarIcon, ClockIcon } from 'lucide-react';

const checkoutSchema = z.object({
  pickup_date: z.string().min(1, 'Please select a pickup date'),
  pickup_time: z.string().min(1, 'Please select a pickup time'),
  special_instructions: z.string().optional(),
});

type CheckoutFormData = z.infer<typeof checkoutSchema>;

export default function CheckoutPage() {
  const router = useRouter();
  const { items, total, isEmpty } = useCartSummary();
  const { clearCart } = useCartStore();
  const [isProcessing, setIsProcessing] = useState(false);

  const {
    register,
    handleSubmit,
    formState: { errors },
  } = useForm<CheckoutFormData>({
    resolver: zodResolver(checkoutSchema),
  });

  const createOrderMutation = useMutation({
    mutationFn: customerApi.createOrder,
    onSuccess: (order) => {
      clearCart();
      router.push(`/customer/orders/${order.id}`);
    },
    onError: (error) => {
      console.error('Order creation failed:', error);
    },
  });

  const onSubmit = async (data: CheckoutFormData) => {
    if (isEmpty) {
      router.push('/customer/cart');
      return;
    }

    setIsProcessing(true);

    try {
      // Combine date and time for pickup_time
      const pickupDateTime = new Date(`${data.pickup_date}T${data.pickup_time}`);

      const orderData = {
        merchant_id: items[0].merchant_id,
        pickup_time: pickupDateTime.toISOString(),
        special_instructions: data.special_instructions,
        items: items.map(item => ({
          [`${item.type}_id`]: item.id,
          quantity: item.quantity,
          unit_price: item.item.discounted_price,
        })),
      };

      await createOrderMutation.mutateAsync(orderData);
    } catch (error) {
      console.error('Checkout failed:', error);
    } finally {
      setIsProcessing(false);
    }
  };

  // Redirect if cart is empty
  if (isEmpty) {
    router.push('/customer/cart');
    return null;
  }

  // Get minimum pickup date (today + 1 hour)
  const now = new Date();
  const minPickupDate = new Date(now.getTime() + 60 * 60 * 1000);
  const minDateString = minPickupDate.toISOString().split('T')[0];
  const minTimeString = minPickupDate.toTimeString().slice(0, 5);

  return (
    <ProtectedRoute requiredRole="customer">
      <div className="min-h-screen bg-gray-50">
        {/* Header */}
        <div className="bg-white border-b border-gray-200">
          <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-6">
            <div className="flex items-center">
              <Button
                variant="ghost"
                onClick={() => router.push('/customer/cart')}
                className="mr-4 p-2"
              >
                <ArrowLeftIcon className="h-5 w-5" />
              </Button>
              <div>
                <h1 className="text-2xl font-bold text-gray-900">Checkout</h1>
                <p className="mt-1 text-gray-600">
                  Complete your order and arrange pickup
                </p>
              </div>
            </div>
          </div>
        </div>

        <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
          <form onSubmit={handleSubmit(onSubmit)}>
            <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
              {/* Checkout form */}
              <div className="lg:col-span-2 space-y-6">
                {/* Pickup details */}
                <Card>
                  <CardHeader>
                    <CardTitle className="flex items-center">
                      <CalendarIcon className="h-5 w-5 mr-2" />
                      Pickup Details
                    </CardTitle>
                  </CardHeader>
                  <CardContent className="space-y-4">
                    <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                      <Input
                        {...register('pickup_date')}
                        label="Pickup Date"
                        type="date"
                        min={minDateString}
                        error={errors.pickup_date?.message}
                      />
                      <Input
                        {...register('pickup_time')}
                        label="Pickup Time"
                        type="time"
                        min={minTimeString}
                        error={errors.pickup_time?.message}
                      />
                    </div>

                    <div>
                      <label className="block text-sm font-medium text-gray-700 mb-1">
                        Special Instructions (Optional)
                      </label>
                      <textarea
                        {...register('special_instructions')}
                        placeholder="Any special requests or pickup instructions..."
                        className="flex min-h-[80px] w-full rounded-lg border border-gray-300 bg-white px-3 py-2 text-sm ring-offset-white placeholder:text-gray-400 focus:border-green-500 focus:outline-none focus:ring-2 focus:ring-green-500 focus:ring-offset-2 disabled:cursor-not-allowed disabled:opacity-50"
                        rows={3}
                      />
                    </div>

                    <div className="bg-blue-50 p-4 rounded-lg">
                      <div className="flex items-start">
                        <ClockIcon className="h-5 w-5 text-blue-600 mt-0.5 mr-2 flex-shrink-0" />
                        <div className="text-sm text-blue-700">
                          <p className="font-medium mb-1">Pickup Guidelines:</p>
                          <ul className="space-y-1 text-xs">
                            <li>• Please arrive within 15 minutes of your scheduled time</li>
                            <li>• Bring a reusable bag if possible</li>
                            <li>• Contact the merchant if you're running late</li>
                            <li>• Have your order confirmation ready</li>
                          </ul>
                        </div>
                      </div>
                    </div>
                  </CardContent>
                </Card>

                {/* Order items review */}
                <Card>
                  <CardHeader>
                    <CardTitle>Order Review</CardTitle>
                  </CardHeader>
                  <CardContent>
                    <div className="space-y-3">
                      {items.map((item) => (
                        <div key={`${item.type}-${item.id}`} className="flex items-center justify-between py-2 border-b border-gray-100 last:border-b-0">
                          <div className="flex items-center space-x-3">
                            <div className="w-12 h-12 bg-gray-200 rounded-lg flex items-center justify-center">
                              <span className="text-xl">
                                {item.type === 'bundle' ? '📦' : '🥖'}
                              </span>
                            </div>
                            <div>
                              <h4 className="font-medium text-gray-900">{item.item.name}</h4>
                              <p className="text-sm text-gray-600">
                                {formatPrice(item.item.discounted_price)} × {item.quantity}
                              </p>
                            </div>
                          </div>
                          <div className="font-medium">
                            {formatPrice(item.item.discounted_price * item.quantity)}
                          </div>
                        </div>
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
                    <div className="space-y-2">
                      <div className="flex justify-between text-sm">
                        <span className="text-gray-600">Subtotal</span>
                        <span>{formatPrice(total)}</span>
                      </div>
                      <div className="flex justify-between text-sm">
                        <span className="text-gray-600">Tax</span>
                        <span>$0.00</span>
                      </div>
                      <div className="flex justify-between text-sm">
                        <span className="text-gray-600">Pickup Fee</span>
                        <span>$0.00</span>
                      </div>
                    </div>

                    <div className="border-t border-gray-200 pt-4">
                      <div className="flex justify-between text-lg font-medium">
                        <span>Total</span>
                        <span className="text-green-600">{formatPrice(total)}</span>
                      </div>
                    </div>

                    <div className="text-xs text-gray-500 bg-gray-50 p-3 rounded-lg">
                      <p className="font-medium mb-1">About Pricing:</p>
                      <p>
                        These are discounted prices to help reduce food waste.
                        No additional fees are charged for pickup orders.
                      </p>
                    </div>
                  </CardContent>

                  <CardContent className="pt-0">
                    {createOrderMutation.error && (
                      <div className="mb-4 p-3 bg-red-50 border border-red-200 rounded-lg">
                        <p className="text-sm text-red-700">
                          {createOrderMutation.error instanceof Error
                            ? createOrderMutation.error.message
                            : 'Failed to place order. Please try again.'}
                        </p>
                      </div>
                    )}

                    <Button
                      type="submit"
                      className="w-full"
                      size="lg"
                      isLoading={isProcessing || createOrderMutation.isPending}
                      disabled={isProcessing || createOrderMutation.isPending}
                    >
                      {isProcessing || createOrderMutation.isPending ? 'Processing...' : 'Place Order'}
                    </Button>

                    <p className="text-xs text-gray-500 text-center mt-3">
                      By placing this order, you agree to pick up your items at the scheduled time.
                    </p>
                  </CardContent>
                </Card>
              </div>
            </div>
          </form>
        </div>
      </div>
    </ProtectedRoute>
  );
}