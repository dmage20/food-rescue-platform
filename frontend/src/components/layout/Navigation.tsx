'use client';

import { useState } from 'react';
import Link from 'next/link';
import { useRouter } from 'next/navigation';
import { useAuthStore, useCustomer, useMerchant } from '@/stores/authStore';
import { useCartSummary } from '@/stores/cartStore';
import { Button } from '@/components/ui/Button';
import { ShoppingCartIcon, MenuIcon, XIcon, UserIcon } from 'lucide-react';

export function Navigation() {
  const router = useRouter();
  const { isAuthenticated, logout } = useAuthStore();
  const { customer, isCustomer } = useCustomer();
  const { merchant, isMerchant } = useMerchant();
  const { itemCount } = useCartSummary();
  const [isMobileMenuOpen, setIsMobileMenuOpen] = useState(false);

  const handleLogout = async () => {
    await logout();
    router.push('/');
    setIsMobileMenuOpen(false);
  };

  const toggleMobileMenu = () => {
    setIsMobileMenuOpen(!isMobileMenuOpen);
  };

  return (
    <nav className="bg-white shadow-sm border-b border-gray-200">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="flex justify-between items-center h-16">
          {/* Logo */}
          <Link href="/" className="flex items-center">
            <span className="text-2xl font-bold text-green-600">🥖</span>
            <span className="ml-2 text-xl font-semibold text-gray-900 hidden sm:block">
              Food Rescue
            </span>
          </Link>

          {/* Desktop Navigation */}
          <div className="hidden md:flex items-center space-x-4">
            {!isAuthenticated && (
              <>
                <Link
                  href="/auth/customer/login"
                  className="text-gray-600 hover:text-gray-900 px-3 py-2 rounded-md text-sm font-medium"
                >
                  Customer Login
                </Link>
                <Link
                  href="/auth/merchant/login"
                  className="text-gray-600 hover:text-gray-900 px-3 py-2 rounded-md text-sm font-medium"
                >
                  Merchant Login
                </Link>
              </>
            )}

            {isCustomer && (
              <>
                <Link
                  href="/customer/discover"
                  className="text-gray-600 hover:text-gray-900 px-3 py-2 rounded-md text-sm font-medium"
                >
                  Discover
                </Link>
                <Link
                  href="/customer/orders"
                  className="text-gray-600 hover:text-gray-900 px-3 py-2 rounded-md text-sm font-medium"
                >
                  Orders
                </Link>
                <Link
                  href="/customer/profile"
                  className="text-gray-600 hover:text-gray-900 px-3 py-2 rounded-md text-sm font-medium"
                >
                  Profile
                </Link>
                <button
                  className="relative p-2 text-gray-600 hover:text-gray-900"
                  onClick={() => router.push('/customer/cart')}
                >
                  <ShoppingCartIcon className="h-6 w-6" />
                  {itemCount > 0 && (
                    <span className="absolute -top-1 -right-1 bg-green-600 text-white text-xs rounded-full h-5 w-5 flex items-center justify-center">
                      {itemCount}
                    </span>
                  )}
                </button>
              </>
            )}

            {isMerchant && (
              <>
                <Link
                  href="/merchant/dashboard"
                  className="text-gray-600 hover:text-gray-900 px-3 py-2 rounded-md text-sm font-medium"
                >
                  Dashboard
                </Link>
                <Link
                  href="/merchant/products"
                  className="text-gray-600 hover:text-gray-900 px-3 py-2 rounded-md text-sm font-medium"
                >
                  Products
                </Link>
                <Link
                  href="/merchant/orders"
                  className="text-gray-600 hover:text-gray-900 px-3 py-2 rounded-md text-sm font-medium"
                >
                  Orders
                </Link>
                <Link
                  href="/merchant/profile"
                  className="text-gray-600 hover:text-gray-900 px-3 py-2 rounded-md text-sm font-medium"
                >
                  Profile
                </Link>
              </>
            )}

            {isAuthenticated && (
              <div className="flex items-center space-x-2">
                <div className="flex items-center space-x-2 text-sm text-gray-600">
                  <UserIcon className="h-4 w-4" />
                  <span>{customer?.name || merchant?.name}</span>
                </div>
                <Button
                  variant="outline"
                  size="sm"
                  onClick={handleLogout}
                >
                  Logout
                </Button>
              </div>
            )}
          </div>

          {/* Mobile menu button */}
          <div className="md:hidden">
            <button
              onClick={toggleMobileMenu}
              className="inline-flex items-center justify-center p-2 rounded-md text-gray-400 hover:text-gray-500 hover:bg-gray-100"
            >
              {isMobileMenuOpen ? (
                <XIcon className="h-6 w-6" />
              ) : (
                <MenuIcon className="h-6 w-6" />
              )}
            </button>
          </div>
        </div>

        {/* Mobile Navigation */}
        {isMobileMenuOpen && (
          <div className="md:hidden border-t border-gray-200 py-3">
            {!isAuthenticated && (
              <div className="space-y-1">
                <Link
                  href="/auth/customer/login"
                  className="block px-3 py-2 text-gray-600 hover:text-gray-900 hover:bg-gray-50 rounded-md"
                  onClick={() => setIsMobileMenuOpen(false)}
                >
                  Customer Login
                </Link>
                <Link
                  href="/auth/merchant/login"
                  className="block px-3 py-2 text-gray-600 hover:text-gray-900 hover:bg-gray-50 rounded-md"
                  onClick={() => setIsMobileMenuOpen(false)}
                >
                  Merchant Login
                </Link>
              </div>
            )}

            {isCustomer && (
              <div className="space-y-1">
                <Link
                  href="/customer/discover"
                  className="block px-3 py-2 text-gray-600 hover:text-gray-900 hover:bg-gray-50 rounded-md"
                  onClick={() => setIsMobileMenuOpen(false)}
                >
                  Discover
                </Link>
                <Link
                  href="/customer/orders"
                  className="block px-3 py-2 text-gray-600 hover:text-gray-900 hover:bg-gray-50 rounded-md"
                  onClick={() => setIsMobileMenuOpen(false)}
                >
                  Orders
                </Link>
                <Link
                  href="/customer/profile"
                  className="block px-3 py-2 text-gray-600 hover:text-gray-900 hover:bg-gray-50 rounded-md"
                  onClick={() => setIsMobileMenuOpen(false)}
                >
                  Profile
                </Link>
                <Link
                  href="/customer/cart"
                  className="flex items-center px-3 py-2 text-gray-600 hover:text-gray-900 hover:bg-gray-50 rounded-md"
                  onClick={() => setIsMobileMenuOpen(false)}
                >
                  <ShoppingCartIcon className="h-5 w-5 mr-2" />
                  Cart
                  {itemCount > 0 && (
                    <span className="ml-2 bg-green-600 text-white text-xs rounded-full h-5 w-5 flex items-center justify-center">
                      {itemCount}
                    </span>
                  )}
                </Link>
              </div>
            )}

            {isMerchant && (
              <div className="space-y-1">
                <Link
                  href="/merchant/dashboard"
                  className="block px-3 py-2 text-gray-600 hover:text-gray-900 hover:bg-gray-50 rounded-md"
                  onClick={() => setIsMobileMenuOpen(false)}
                >
                  Dashboard
                </Link>
                <Link
                  href="/merchant/products"
                  className="block px-3 py-2 text-gray-600 hover:text-gray-900 hover:bg-gray-50 rounded-md"
                  onClick={() => setIsMobileMenuOpen(false)}
                >
                  Products
                </Link>
                <Link
                  href="/merchant/orders"
                  className="block px-3 py-2 text-gray-600 hover:text-gray-900 hover:bg-gray-50 rounded-md"
                  onClick={() => setIsMobileMenuOpen(false)}
                >
                  Orders
                </Link>
                <Link
                  href="/merchant/profile"
                  className="block px-3 py-2 text-gray-600 hover:text-gray-900 hover:bg-gray-50 rounded-md"
                  onClick={() => setIsMobileMenuOpen(false)}
                >
                  Profile
                </Link>
              </div>
            )}

            {isAuthenticated && (
              <div className="border-t border-gray-200 pt-3 mt-3">
                <div className="px-3 py-2 text-sm text-gray-600">
                  Signed in as {customer?.name || merchant?.name}
                </div>
                <button
                  onClick={handleLogout}
                  className="block w-full text-left px-3 py-2 text-gray-600 hover:text-gray-900 hover:bg-gray-50 rounded-md"
                >
                  Logout
                </button>
              </div>
            )}
          </div>
        )}
      </div>
    </nav>
  );
}