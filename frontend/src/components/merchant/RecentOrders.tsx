'use client';

import { Order } from '@/types';
import { Button } from '@/components/ui/Button';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/Card';
import { formatPrice, formatDate } from '@/lib/utils';
import { EyeIcon, CheckIcon, ClockIcon, ShoppingBagIcon } from 'lucide-react';

interface RecentOrdersProps {
  orders: Order[];
  onViewOrder: (orderId: number) => void;
  onUpdateOrderStatus: (orderId: number, status: Order['status']) => void;
}

export function RecentOrders({ orders, onViewOrder, onUpdateOrderStatus }: RecentOrdersProps) {
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
        return <ClockIcon className="h-3 w-3" />;
      case 'confirmed':
      case 'ready':
        return <CheckIcon className="h-3 w-3" />;
      default:
        return null;
    }
  };

  return (
    <Card>
      <CardHeader>
        <CardTitle>Recent Orders</CardTitle>
      </CardHeader>
      <CardContent>
        {orders.length === 0 ? (
          <div className="text-center py-8 text-gray-500">
            <ShoppingBagIcon className="h-12 w-12 mx-auto mb-4 text-gray-300" />
            <p>No recent orders</p>
          </div>
        ) : (
          <div className="space-y-4">
            {orders.map((order) => (
              <div
                key={order.id}
                className="flex items-center justify-between p-4 border border-gray-200 rounded-lg hover:bg-gray-50 transition-colors"
              >
                <div className="flex-grow">
                  <div className="flex items-center justify-between mb-2">
                    <div className="flex items-center space-x-3">
                      <span className="font-medium text-gray-900">
                        Order #{order.id}
                      </span>
                      <span className={`inline-flex items-center space-x-1 px-2 py-1 rounded-full text-xs font-medium ${getStatusColor(order.status)}`}>
                        {getStatusIcon(order.status)}
                        <span>{order.status}</span>
                      </span>
                    </div>
                    <span className="font-medium text-green-600">
                      {formatPrice(order.total_amount)}
                    </span>
                  </div>

                  <div className="flex items-center justify-between text-sm text-gray-600">
                    <div>
                      <span className="font-medium">{order.customer?.name}</span>
                      <span className="mx-2">•</span>
                      <span>{order.items.length} item{order.items.length === 1 ? '' : 's'}</span>
                    </div>
                    <div className="flex items-center space-x-4">
                      <span>Pickup: {formatDate(order.pickup_time)}</span>
                    </div>
                  </div>

                  {order.special_instructions && (
                    <div className="mt-2 text-sm text-gray-600 bg-gray-50 p-2 rounded">
                      <span className="font-medium">Instructions: </span>
                      {order.special_instructions}
                    </div>
                  )}
                </div>

                <div className="flex items-center space-x-2 ml-4">
                  <Button
                    variant="outline"
                    size="sm"
                    onClick={() => onViewOrder(order.id)}
                  >
                    <EyeIcon className="h-4 w-4 mr-1" />
                    View
                  </Button>

                  {order.status === 'pending' && (
                    <Button
                      size="sm"
                      onClick={() => onUpdateOrderStatus(order.id, 'confirmed')}
                    >
                      Confirm
                    </Button>
                  )}

                  {order.status === 'confirmed' && (
                    <Button
                      size="sm"
                      onClick={() => onUpdateOrderStatus(order.id, 'ready')}
                    >
                      Ready
                    </Button>
                  )}

                  {order.status === 'ready' && (
                    <Button
                      size="sm"
                      onClick={() => onUpdateOrderStatus(order.id, 'completed')}
                    >
                      Complete
                    </Button>
                  )}
                </div>
              </div>
            ))}
          </div>
        )}
      </CardContent>
    </Card>
  );
}