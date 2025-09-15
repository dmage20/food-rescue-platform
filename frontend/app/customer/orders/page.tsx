'use client';

import { useQuery } from '@tanstack/react-query';
import { ProtectedRoute } from '@/components/layout/ProtectedRoute';
import { customerApi } from '@/lib/api';
import { Order } from '@/types';
import { Button } from '@/components/ui/Button';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/Card';
import { formatPrice, formatDate } from '@/lib/utils';
import { ClockIcon, CheckIcon, ShoppingBagIcon, MapPinIcon } from 'lucide-react';

export default function CustomerOrdersPage() {
  const { data: orders = [], isLoading, error } = useQuery({
    queryKey: ['customer-orders'],
    queryFn: customerApi.getOrders,
  });

  const getStatusColor = (status: Order['status']) => {
    switch (status) {
      case 'pending':
        return 'bg-yellow-100 text-yellow-800';
      case 'confirmed':
        return 'bg-blue-100 text-blue-800';
      case 'ready':
        return 'bg-green-100 text-green-800';
      case 'completed':
        return 'bg-gray-100 text-gray-800';
      case 'cancelled':
        return 'bg-red-100 text-red-800';
      default:
        return 'bg-gray-100 text-gray-800';
    }
  };

  const getStatusIcon = (status: Order['status']) => {
    switch (status) {
      case 'pending':
        return <ClockIcon className="h-4 w-4" />;
      case 'confirmed':
      case 'ready':
      case 'completed':
        return <CheckIcon className="h-4 w-4" />;
      default:
        return null;
    }
  };

  const getStatusDescription = (status: Order['status']) => {
    switch (status) {
      case 'pending':
        return 'Waiting for merchant confirmation';
      case 'confirmed':
        return 'Order confirmed, being prepared';
      case 'ready':
        return 'Ready for pickup!';
      case 'completed':
        return 'Order completed';
      case 'cancelled':
        return 'Order was cancelled';
      default:
        return '';
    }
  };

  return (
    <ProtectedRoute requiredRole="customer">
      <div className="min-h-screen bg-gray-50">
        {/* Header */}
        <div className="bg-white border-b border-gray-200">
          <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-6">
            <div>
              <h1 className="text-2xl font-bold text-gray-900">Your Orders</h1>
              <p className="mt-1 text-gray-600">
                Track your orders and pickup history
              </p>
            </div>
          </div>
        </div>

        <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
          {isLoading && (
            <div className="text-center py-12">
              <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-green-600 mx-auto"></div>
              <p className="mt-4 text-gray-600">Loading your orders...</p>
            </div>
          )}

          {error && (
            <div className="text-center py-12">
              <div className="bg-red-50 rounded-lg p-6 max-w-md mx-auto">
                <h3 className="text-lg font-medium text-red-800 mb-2">
                  Error Loading Orders
                </h3>
                <p className="text-red-600 mb-4">
                  {error instanceof Error ? error.message : 'Something went wrong'}
                </p>
                <Button onClick={() => window.location.reload()} variant="outline">
                  Try Again
                </Button>
              </div>
            </div>
          )}

          {!isLoading && !error && (
            <>
              {orders.length === 0 ? (
                <div className="text-center py-16">
                  <ShoppingBagIcon className="mx-auto h-16 w-16 text-gray-400 mb-4" />
                  <h2 className="text-xl font-medium text-gray-900 mb-2">
                    No orders yet
                  </h2>
                  <p className="text-gray-600 mb-6">
                    Start discovering fresh goods at discounted prices from local merchants.
                  </p>
                  <Button onClick={() => window.location.href = '/customer/discover'}>
                    Start Shopping
                  </Button>
                </div>
              ) : (
                <div className="space-y-6">
                  {orders
                    .sort((a: Order, b: Order) => new Date(b.created_at).getTime() - new Date(a.created_at).getTime())
                    .map((order: Order) => (
                      <Card key={order.id}>
                        <CardHeader>
                          <div className="flex items-center justify-between">
                            <div className="flex items-center space-x-3">
                              <CardTitle className="text-lg">
                                Order #{order.id}
                              </CardTitle>
                              <span className={`inline-flex items-center space-x-1 px-3 py-1 rounded-full text-sm font-medium ${getStatusColor(order.status)}`}>
                                {getStatusIcon(order.status)}
                                <span className="capitalize">{order.status}</span>
                              </span>
                            </div>
                            <div className="text-right">
                              <div className="font-medium text-lg text-green-600">
                                {formatPrice(order.total_amount)}
                              </div>
                              <div className="text-sm text-gray-500">
                                {formatDate(order.created_at)}
                              </div>
                            </div>
                          </div>
                        </CardHeader>

                        <CardContent>
                          {/* Status description */}
                          <div className="mb-4 p-3 bg-gray-50 rounded-lg">
                            <p className="text-sm text-gray-700">
                              {getStatusDescription(order.status)}
                            </p>
                          </div>

                          {/* Merchant info */}
                          <div className="mb-4 flex items-center space-x-2 text-sm text-gray-600">
                            <MapPinIcon className="h-4 w-4" />
                            <span>From: {order.merchant?.business_name || order.merchant?.name}</span>
                          </div>

                          {/* Pickup info */}
                          <div className="mb-4 p-3 bg-blue-50 rounded-lg">
                            <div className="flex items-center space-x-2 text-sm text-blue-700">
                              <ClockIcon className="h-4 w-4" />
                              <span className="font-medium">
                                Pickup Time: {formatDate(order.pickup_time)}
                              </span>
                            </div>
                            {order.status === 'ready' && (
                              <p className="text-xs text-blue-600 mt-1">
                                Your order is ready! Please pick it up on time.
                              </p>
                            )}
                          </div>

                          {/* Order items */}
                          <div className="space-y-3">
                            <h4 className="font-medium text-gray-900">Order Items:</h4>
                            {order.items.map((item, index) => (
                              <div key={index} className="flex items-center justify-between py-2 border-b border-gray-100 last:border-b-0">
                                <div className="flex items-center space-x-3">
                                  <div className="w-10 h-10 bg-gray-200 rounded-lg flex items-center justify-center">
                                    <span className="text-lg">
                                      {item.bundle ? '📦' : '🥖'}
                                    </span>
                                  </div>
                                  <div>
                                    <div className="font-medium text-gray-900">
                                      {item.product?.name || item.bundle?.name}
                                    </div>
                                    <div className="text-sm text-gray-600">
                                      {formatPrice(item.unit_price)} × {item.quantity}
                                    </div>
                                  </div>
                                </div>
                                <div className="font-medium">
                                  {formatPrice(item.unit_price * item.quantity)}
                                </div>
                              </div>
                            ))}
                          </div>

                          {/* Special instructions */}
                          {order.special_instructions && (
                            <div className="mt-4 p-3 bg-gray-50 rounded-lg">
                              <div className="text-sm">
                                <span className="font-medium text-gray-700">Special Instructions: </span>
                                <span className="text-gray-600">{order.special_instructions}</span>
                              </div>
                            </div>
                          )}

                          {/* Action buttons */}
                          <div className="mt-4 flex space-x-3">
                            {order.status === 'ready' && (
                              <Button className="flex-1">
                                View Pickup Details
                              </Button>
                            )}
                            {(order.status === 'completed' || order.status === 'cancelled') && (
                              <Button variant="outline" className="flex-1">
                                Reorder Items
                              </Button>
                            )}
                            <Button variant="outline">
                              Contact Merchant
                            </Button>
                          </div>
                        </CardContent>
                      </Card>
                    ))}
                </div>
              )}
            </>
          )}
        </div>
      </div>
    </ProtectedRoute>
  );
}