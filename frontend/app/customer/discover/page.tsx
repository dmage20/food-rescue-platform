'use client';

import { useState, useEffect } from 'react';
import { useQuery } from '@tanstack/react-query';
import { ProtectedRoute } from '@/components/layout/ProtectedRoute';
import { ProductCard } from '@/components/customer/ProductCard';
import { FilterBar } from '@/components/customer/FilterBar';
import { customerApi } from '@/lib/api';
import { ProductFilters, Product, Bundle } from '@/types';
import { Button } from '@/components/ui/Button';

export default function DiscoverPage() {
  const [filters, setFilters] = useState<ProductFilters>({
    available_only: true,
    radius: 10,
  });
  const [view, setView] = useState<'products' | 'bundles'>('products');

  // Fetch products
  const {
    data: products = [],
    isLoading: productsLoading,
    error: productsError,
    refetch: refetchProducts,
  } = useQuery({
    queryKey: ['products', filters],
    queryFn: () => customerApi.browseProducts(filters),
    enabled: view === 'products',
  });

  // Fetch bundles
  const {
    data: bundles = [],
    isLoading: bundlesLoading,
    error: bundlesError,
    refetch: refetchBundles,
  } = useQuery({
    queryKey: ['bundles', filters],
    queryFn: () => customerApi.browseBundles(filters),
    enabled: view === 'bundles',
  });

  const handleFiltersChange = (newFilters: ProductFilters) => {
    setFilters(newFilters);
  };

  const handleClearFilters = () => {
    setFilters({
      available_only: true,
      radius: 10,
    });
  };

  const isLoading = view === 'products' ? productsLoading : bundlesLoading;
  const error = view === 'products' ? productsError : bundlesError;
  const items = view === 'products' ? products : bundles;

  return (
    <ProtectedRoute requiredRole="customer">
      <div className="min-h-screen bg-gray-50">
        {/* Header */}
        <div className="bg-white border-b border-gray-200">
          <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-6">
            <div className="flex flex-col md:flex-row md:items-center md:justify-between">
              <div>
                <h1 className="text-2xl font-bold text-gray-900">Discover Food</h1>
                <p className="mt-1 text-gray-600">
                  Find fresh goods at discounted prices near you
                </p>
              </div>

              {/* View toggle */}
              <div className="mt-4 md:mt-0">
                <div className="flex bg-gray-100 rounded-lg p-1">
                  <button
                    onClick={() => setView('products')}
                    className={`px-4 py-2 rounded-md text-sm font-medium transition-colors ${
                      view === 'products'
                        ? 'bg-white text-gray-900 shadow-sm'
                        : 'text-gray-600 hover:text-gray-900'
                    }`}
                  >
                    Products
                  </button>
                  <button
                    onClick={() => setView('bundles')}
                    className={`px-4 py-2 rounded-md text-sm font-medium transition-colors ${
                      view === 'bundles'
                        ? 'bg-white text-gray-900 shadow-sm'
                        : 'text-gray-600 hover:text-gray-900'
                    }`}
                  >
                    Bundles
                  </button>
                </div>
              </div>
            </div>
          </div>
        </div>

        {/* Filters */}
        <FilterBar
          filters={filters}
          onFiltersChange={handleFiltersChange}
          onClearFilters={handleClearFilters}
        />

        {/* Content */}
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
          {isLoading && (
            <div className="text-center py-12">
              <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-green-600 mx-auto"></div>
              <p className="mt-4 text-gray-600">Loading {view}...</p>
            </div>
          )}

          {error && (
            <div className="text-center py-12">
              <div className="bg-red-50 rounded-lg p-6 max-w-md mx-auto">
                <h3 className="text-lg font-medium text-red-800 mb-2">
                  Error Loading {view}
                </h3>
                <p className="text-red-600 mb-4">
                  {error instanceof Error ? error.message : 'Something went wrong'}
                </p>
                <Button
                  onClick={() => view === 'products' ? refetchProducts() : refetchBundles()}
                  variant="outline"
                >
                  Try Again
                </Button>
              </div>
            </div>
          )}

          {!isLoading && !error && (
            <>
              {/* Results summary */}
              <div className="flex items-center justify-between mb-6">
                <p className="text-gray-600">
                  {items.length} {view} found
                </p>

                {/* TODO: Add sort options */}
                <select className="border border-gray-300 rounded-md px-3 py-2 text-sm bg-white">
                  <option>Sort by relevance</option>
                  <option>Price: Low to High</option>
                  <option>Price: High to Low</option>
                  <option>Expiring Soon</option>
                  <option>Newest</option>
                </select>
              </div>

              {/* Items grid */}
              {items.length > 0 ? (
                <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6">
                  {items.map((item: Product | Bundle) => (
                    <ProductCard
                      key={`${view}-${item.id}`}
                      item={item}
                      type={view === 'products' ? 'product' : 'bundle'}
                    />
                  ))}
                </div>
              ) : (
                <div className="text-center py-12">
                  <div className="text-gray-400 text-6xl mb-4">
                    {view === 'products' ? '🥖' : '📦'}
                  </div>
                  <h3 className="text-lg font-medium text-gray-900 mb-2">
                    No {view} found
                  </h3>
                  <p className="text-gray-600 mb-4">
                    Try adjusting your filters or check back later for new listings.
                  </p>
                  <Button onClick={handleClearFilters} variant="outline">
                    Clear Filters
                  </Button>
                </div>
              )}
            </>
          )}
        </div>
      </div>
    </ProtectedRoute>
  );
}