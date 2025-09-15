'use client';

import { useRouter } from 'next/navigation';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { ProtectedRoute } from '@/components/layout/ProtectedRoute';
import { DashboardStats } from '@/components/merchant/DashboardStats';
import { RecentOrders } from '@/components/merchant/RecentOrders';
import { useMerchant } from '@/stores/authStore';
import { merchantApi } from '@/lib/api';
import { Button } from '@/components/ui/Button';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/Card';
import { PlusIcon, PackageIcon, ShoppingBagIcon } from 'lucide-react';

export default function MerchantDashboard() {
  const router = useRouter();
  const queryClient = useQueryClient();
  const { merchant } = useMerchant();

  // Fetch orders
  const { data: orders = [], isLoading: ordersLoading } = useQuery({
    queryKey: ['merchant-orders'],
    queryFn: merchantApi.getOrders,
  });

  // Fetch products
  const { data: products = [], isLoading: productsLoading } = useQuery({
    queryKey: ['merchant-products'],
    queryFn: merchantApi.getProducts,
  });

  // Fetch bundles
  const { data: bundles = [], isLoading: bundlesLoading } = useQuery({
    queryKey: ['merchant-bundles'],
    queryFn: merchantApi.getBundles,
  });

  // Update order status mutation
  const updateOrderMutation = useMutation({
    mutationFn: ({ orderId, status }: { orderId: number; status: string }) =>
      merchantApi.updateOrder(orderId, status),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['merchant-orders'] });
    },
  });

  const handleViewOrder = (orderId: number) => {
    router.push(`/merchant/orders/${orderId}`);
  };

  const handleUpdateOrderStatus = async (orderId: number, status: string) => {
    try {
      await updateOrderMutation.mutateAsync({ orderId, status });
    } catch (error) {
      console.error('Failed to update order status:', error);
    }
  };

  // Calculate dashboard stats
  const today = new Date();
  const todayStart = new Date(today.getFullYear(), today.getMonth(), today.getDate());
  const weekStart = new Date(today.getTime() - 7 * 24 * 60 * 60 * 1000);

  const todayOrders = orders.filter((order: any) =>
    new Date(order.created_at) >= todayStart
  );

  const weeklyOrders = orders.filter((order: any) =>
    new Date(order.created_at) >= weekStart
  );

  const stats = {
    todayOrders: todayOrders.length,
    todayRevenue: todayOrders.reduce((sum: number, order: any) => sum + order.total_amount, 0),
    activeProducts: products.filter((p: any) => p.available_quantity > 0).length,
    activeBundles: bundles.filter((b: any) => b.available_quantity > 0).length,
    weeklyOrders: weeklyOrders.length,
    weeklyRevenue: weeklyOrders.reduce((sum: number, order: any) => sum + order.total_amount, 0),
    averageOrderValue: weeklyOrders.length > 0
      ? weeklyOrders.reduce((sum: number, order: any) => sum + order.total_amount, 0) / weeklyOrders.length
      : 0,
    wasteReduced: 45, // Mock data - would come from API
  };

  const recentOrders = orders
    .sort((a: any, b: any) => new Date(b.created_at).getTime() - new Date(a.created_at).getTime())
    .slice(0, 5);

  const isLoading = ordersLoading || productsLoading || bundlesLoading;

  return (
    <ProtectedRoute requiredRole="merchant">
      <div className="min-h-screen bg-gray-50">
        {/* Header */}
        <div className="bg-white border-b border-gray-200">
          <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-6">
            <div className="flex flex-col md:flex-row md:items-center md:justify-between">
              <div>
                <h1 className="text-2xl font-bold text-gray-900">
                  Welcome back, {merchant?.name || 'Merchant'}!
                </h1>
                <p className="mt-1 text-gray-600">
                  Here's what's happening with your business today
                </p>
              </div>

              <div className="mt-4 md:mt-0 flex space-x-3">
                <Button
                  onClick={() => router.push('/merchant/products/new')}
                  className="flex items-center"
                >
                  <PlusIcon className="h-4 w-4 mr-2" />
                  Add Product
                </Button>
                <Button
                  variant="outline"
                  onClick={() => router.push('/merchant/bundles/new')}
                  className="flex items-center"
                >
                  <PlusIcon className="h-4 w-4 mr-2" />
                  Add Bundle
                </Button>
              </div>
            </div>
          </div>
        </div>

        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
          {isLoading ? (
            <div className="text-center py-12">
              <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-green-600 mx-auto"></div>
              <p className="mt-4 text-gray-600">Loading dashboard...</p>
            </div>
          ) : (
            <div className="space-y-8">
              {/* Stats */}
              <DashboardStats stats={stats} />

              {/* Quick Actions */}
              <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
                <Card className="cursor-pointer hover:shadow-md transition-shadow"
                      onClick={() => router.push('/merchant/products')}>
                  <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                    <CardTitle className="text-sm font-medium">Products</CardTitle>
                    <PackageIcon className="h-4 w-4 text-gray-600" />
                  </CardHeader>
                  <CardContent>
                    <div className="text-2xl font-bold">{products.length}</div>
                    <p className="text-xs text-gray-600">
                      {stats.activeProducts} available
                    </p>
                  </CardContent>
                </Card>

                <Card className="cursor-pointer hover:shadow-md transition-shadow"
                      onClick={() => router.push('/merchant/bundles')}>
                  <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                    <CardTitle className="text-sm font-medium">Bundles</CardTitle>
                    <PackageIcon className="h-4 w-4 text-gray-600" />
                  </CardHeader>
                  <CardContent>
                    <div className="text-2xl font-bold">{bundles.length}</div>
                    <p className="text-xs text-gray-600">
                      {stats.activeBundles} available
                    </p>
                  </CardContent>
                </Card>

                <Card className="cursor-pointer hover:shadow-md transition-shadow"
                      onClick={() => router.push('/merchant/orders')}>
                  <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                    <CardTitle className="text-sm font-medium">Orders</CardTitle>
                    <ShoppingBagIcon className="h-4 w-4 text-gray-600" />
                  </CardHeader>
                  <CardContent>
                    <div className="text-2xl font-bold">{orders.length}</div>
                    <p className="text-xs text-gray-600">
                      {todayOrders.length} today
                    </p>
                  </CardContent>
                </Card>
              </div>

              {/* Recent Orders */}
              <RecentOrders
                orders={recentOrders}
                onViewOrder={handleViewOrder}
                onUpdateOrderStatus={handleUpdateOrderStatus}
              />
            </div>
          )}
        </div>
      </div>
    </ProtectedRoute>
  );
}