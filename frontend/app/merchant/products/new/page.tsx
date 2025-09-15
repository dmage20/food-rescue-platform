'use client';

import { useRouter } from 'next/navigation';
import { useMutation } from '@tanstack/react-query';
import { ProtectedRoute } from '@/components/layout/ProtectedRoute';
import { ProductForm } from '@/components/merchant/ProductForm';
import { merchantApi } from '@/lib/api';
import { ArrowLeftIcon } from 'lucide-react';
import { Button } from '@/components/ui/Button';

export default function NewProductPage() {
  const router = useRouter();

  const createProductMutation = useMutation({
    mutationFn: merchantApi.createProduct,
    onSuccess: () => {
      router.push('/merchant/products');
    },
    onError: (error) => {
      console.error('Failed to create product:', error);
    },
  });

  const handleSubmit = async (data: any) => {
    try {
      await createProductMutation.mutateAsync({
        ...data,
        expires_at: new Date(data.expires_at).toISOString(),
      });
    } catch (error) {
      // Error handled by mutation
    }
  };

  return (
    <ProtectedRoute requiredRole="merchant">
      <div className="min-h-screen bg-gray-50">
        {/* Header */}
        <div className="bg-white border-b border-gray-200">
          <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-6">
            <div className="flex items-center">
              <Button
                variant="ghost"
                onClick={() => router.push('/merchant/products')}
                className="mr-4 p-2"
              >
                <ArrowLeftIcon className="h-5 w-5" />
              </Button>
              <div>
                <h1 className="text-2xl font-bold text-gray-900">Add New Product</h1>
                <p className="mt-1 text-gray-600">
                  Create a new product listing to reduce food waste
                </p>
              </div>
            </div>
          </div>
        </div>

        <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
          {createProductMutation.error && (
            <div className="mb-6 p-4 bg-red-50 border border-red-200 rounded-lg">
              <p className="text-sm text-red-700">
                {createProductMutation.error instanceof Error
                  ? createProductMutation.error.message
                  : 'Failed to create product. Please try again.'}
              </p>
            </div>
          )}

          <ProductForm
            onSubmit={handleSubmit}
            isSubmitting={createProductMutation.isPending}
            submitButtonText="Create Product"
          />
        </div>
      </div>
    </ProtectedRoute>
  );
}