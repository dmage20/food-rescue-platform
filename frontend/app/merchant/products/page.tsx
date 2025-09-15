'use client';

import { useState } from 'react';
import { useRouter } from 'next/navigation';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { ProtectedRoute } from '@/components/layout/ProtectedRoute';
import { merchantApi } from '@/lib/api';
import { Product } from '@/types';
import { Button } from '@/components/ui/Button';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/Card';
import { formatPrice, formatDate } from '@/lib/utils';
import { PlusIcon, EditIcon, TrashIcon, EyeIcon } from 'lucide-react';

export default function ProductsPage() {
  const router = useRouter();
  const queryClient = useQueryClient();
  const [deletingId, setDeletingId] = useState<number | null>(null);

  const { data: products = [], isLoading, error } = useQuery({
    queryKey: ['merchant-products'],
    queryFn: merchantApi.getProducts,
  });

  const deleteProductMutation = useMutation({
    mutationFn: merchantApi.deleteProduct,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['merchant-products'] });
      setDeletingId(null);
    },
    onError: (error) => {
      console.error('Failed to delete product:', error);
      setDeletingId(null);
    },
  });

  const handleDeleteProduct = async (productId: number) => {
    if (confirm('Are you sure you want to delete this product? This action cannot be undone.')) {
      setDeletingId(productId);
      try {
        await deleteProductMutation.mutateAsync(productId);
      } catch (error) {
        // Error handled by mutation
      }
    }
  };

  const getStatusColor = (product: Product) => {
    if (product.available_quantity === 0) {
      return 'bg-red-100 text-red-800';
    }
    const expiresAt = new Date(product.expires_at);
    const now = new Date();
    const hoursUntilExpiry = (expiresAt.getTime() - now.getTime()) / (1000 * 60 * 60);

    if (hoursUntilExpiry < 2) {
      return 'bg-red-100 text-red-800';
    } else if (hoursUntilExpiry < 6) {
      return 'bg-yellow-100 text-yellow-800';
    } else {
      return 'bg-green-100 text-green-800';
    }
  };

  const getStatusText = (product: Product) => {
    if (product.available_quantity === 0) {
      return 'Out of Stock';
    }
    const expiresAt = new Date(product.expires_at);
    const now = new Date();
    const hoursUntilExpiry = (expiresAt.getTime() - now.getTime()) / (1000 * 60 * 60);

    if (hoursUntilExpiry < 0) {
      return 'Expired';
    } else if (hoursUntilExpiry < 2) {
      return 'Expires Soon';
    } else if (hoursUntilExpiry < 6) {
      return 'Expires Today';
    } else {
      return 'Available';
    }
  };

  return (
    <ProtectedRoute requiredRole="merchant">
      <div className="min-h-screen bg-gray-50">
        {/* Header */}
        <div className="bg-white border-b border-gray-200">
          <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-6">
            <div className="flex flex-col md:flex-row md:items-center md:justify-between">
              <div>
                <h1 className="text-2xl font-bold text-gray-900">Products</h1>
                <p className="mt-1 text-gray-600">
                  Manage your product listings and inventory
                </p>
              </div>

              <div className="mt-4 md:mt-0">
                <Button
                  onClick={() => router.push('/merchant/products/new')}
                  className="flex items-center"
                >
                  <PlusIcon className="h-4 w-4 mr-2" />
                  Add Product
                </Button>
              </div>
            </div>
          </div>
        </div>

        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
          {isLoading && (
            <div className="text-center py-12">
              <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-green-600 mx-auto"></div>
              <p className="mt-4 text-gray-600">Loading products...</p>
            </div>
          )}

          {error && (
            <div className="text-center py-12">
              <div className="bg-red-50 rounded-lg p-6 max-w-md mx-auto">
                <h3 className="text-lg font-medium text-red-800 mb-2">
                  Error Loading Products
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
              {products.length === 0 ? (
                <div className="text-center py-16">
                  <div className="text-gray-400 text-6xl mb-4">🥖</div>
                  <h2 className="text-xl font-medium text-gray-900 mb-2">
                    No products yet
                  </h2>
                  <p className="text-gray-600 mb-6">
                    Start by adding your first product to reduce food waste.
                  </p>
                  <Button onClick={() => router.push('/merchant/products/new')}>
                    <PlusIcon className="h-4 w-4 mr-2" />
                    Add Your First Product
                  </Button>
                </div>
              ) : (
                <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
                  {products.map((product: Product) => (
                    <Card key={product.id} className="h-full flex flex-col">
                      <CardHeader className="pb-3">
                        <div className="flex items-start justify-between">
                          <CardTitle className="text-lg line-clamp-2 flex-grow">
                            {product.name}
                          </CardTitle>
                          <span className={`inline-flex items-center px-2 py-1 rounded-full text-xs font-medium ml-2 flex-shrink-0 ${getStatusColor(product)}`}>
                            {getStatusText(product)}
                          </span>
                        </div>
                      </CardHeader>

                      <CardContent className="flex-grow">
                        <p className="text-gray-600 text-sm mb-3 line-clamp-2">
                          {product.description}
                        </p>

                        <div className="space-y-2 mb-4">
                          <div className="flex items-center justify-between">
                            <span className="text-sm text-gray-500">Category:</span>
                            <span className="text-sm font-medium capitalize">
                              {product.category.replace('_', ' ')}
                            </span>
                          </div>

                          <div className="flex items-center justify-between">
                            <span className="text-sm text-gray-500">Price:</span>
                            <div className="flex items-center space-x-2">
                              <span className="font-medium text-green-600">
                                {formatPrice(product.discounted_price)}
                              </span>
                              {product.original_price > product.discounted_price && (
                                <span className="text-xs text-gray-500 line-through">
                                  {formatPrice(product.original_price)}
                                </span>
                              )}
                            </div>
                          </div>

                          <div className="flex items-center justify-between">
                            <span className="text-sm text-gray-500">Quantity:</span>
                            <span className="text-sm font-medium">
                              {product.available_quantity} left
                            </span>
                          </div>

                          <div className="flex items-center justify-between">
                            <span className="text-sm text-gray-500">Expires:</span>
                            <span className="text-sm font-medium">
                              {formatDate(product.expires_at)}
                            </span>
                          </div>
                        </div>

                        {/* Tags */}
                        {(product.dietary_tags.length > 0 || product.allergens.length > 0) && (
                          <div className="mb-4">
                            <div className="flex flex-wrap gap-1">
                              {product.dietary_tags.slice(0, 2).map((tag) => (
                                <span key={tag} className="bg-green-100 text-green-800 text-xs px-2 py-1 rounded-full">
                                  {tag}
                                </span>
                              ))}
                              {product.allergens.slice(0, 2).map((allergen) => (
                                <span key={allergen} className="bg-red-100 text-red-800 text-xs px-2 py-1 rounded-full">
                                  {allergen}
                                </span>
                              ))}
                              {(product.dietary_tags.length + product.allergens.length) > 4 && (
                                <span className="bg-gray-100 text-gray-600 text-xs px-2 py-1 rounded-full">
                                  +{(product.dietary_tags.length + product.allergens.length) - 4}
                                </span>
                              )}
                            </div>
                          </div>
                        )}
                      </CardContent>

                      <CardContent className="pt-0">
                        <div className="flex items-center space-x-2">
                          <Button
                            variant="outline"
                            size="sm"
                            onClick={() => router.push(`/merchant/products/${product.id}`)}
                            className="flex-1"
                          >
                            <EyeIcon className="h-4 w-4 mr-1" />
                            View
                          </Button>
                          <Button
                            variant="outline"
                            size="sm"
                            onClick={() => router.push(`/merchant/products/edit/${product.id}`)}
                            className="flex-1"
                          >
                            <EditIcon className="h-4 w-4 mr-1" />
                            Edit
                          </Button>
                          <Button
                            variant="outline"
                            size="sm"
                            onClick={() => handleDeleteProduct(product.id)}
                            disabled={deletingId === product.id}
                            className="text-red-600 hover:text-red-700 hover:bg-red-50"
                          >
                            {deletingId === product.id ? (
                              <div className="animate-spin rounded-full h-4 w-4 border-b-2 border-red-600"></div>
                            ) : (
                              <TrashIcon className="h-4 w-4" />
                            )}
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