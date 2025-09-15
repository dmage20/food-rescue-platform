'use client';

import { useEffect } from 'react';
import { useRouter } from 'next/navigation';
import { useAuthStore } from '@/stores/authStore';
import { UserRole } from '@/types';

interface ProtectedRouteProps {
  children: React.ReactNode;
  requiredRole?: UserRole;
  redirectTo?: string;
}

export function ProtectedRoute({
  children,
  requiredRole,
  redirectTo
}: ProtectedRouteProps) {
  const router = useRouter();
  const { isAuthenticated, role, isLoading, initialize } = useAuthStore();

  useEffect(() => {
    // Initialize auth state from stored tokens
    initialize();
  }, [initialize]);

  useEffect(() => {
    if (!isLoading) {
      if (!isAuthenticated) {
        // Not authenticated, redirect to appropriate login
        const loginPath = requiredRole
          ? `/auth/${requiredRole}/login`
          : '/auth/customer/login';
        router.push(redirectTo || loginPath);
        return;
      }

      if (requiredRole && role !== requiredRole) {
        // Wrong role, redirect to appropriate dashboard
        const dashboardPath = role === 'customer'
          ? '/customer/discover'
          : '/merchant/dashboard';
        router.push(dashboardPath);
        return;
      }
    }
  }, [isAuthenticated, role, isLoading, requiredRole, router, redirectTo]);

  // Show loading spinner while checking auth
  if (isLoading) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-gray-50">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-green-600 mx-auto"></div>
          <p className="mt-4 text-gray-600">Loading...</p>
        </div>
      </div>
    );
  }

  // Don't render children until auth is verified
  if (!isAuthenticated || (requiredRole && role !== requiredRole)) {
    return null;
  }

  return <>{children}</>;
}