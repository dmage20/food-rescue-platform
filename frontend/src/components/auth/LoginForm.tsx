'use client';

import { useState } from 'react';
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';
import { useRouter } from 'next/navigation';
import Link from 'next/link';
import { useAuthStore } from '@/stores/authStore';
import { UserRole } from '@/types';
import { Button } from '@/components/ui/Button';
import { Input } from '@/components/ui/Input';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/Card';

const loginSchema = z.object({
  email: z.string().email('Please enter a valid email address'),
  password: z.string().min(6, 'Password must be at least 6 characters'),
});

type LoginFormData = z.infer<typeof loginSchema>;

interface LoginFormProps {
  role: UserRole;
  onSuccess?: () => void;
}

export function LoginForm({ role, onSuccess }: LoginFormProps) {
  const router = useRouter();
  const { login, isLoading, error, clearError } = useAuthStore();
  const [showPassword, setShowPassword] = useState(false);

  const {
    register,
    handleSubmit,
    formState: { errors },
  } = useForm<LoginFormData>({
    resolver: zodResolver(loginSchema),
  });

  const onSubmit = async (data: LoginFormData) => {
    try {
      clearError();
      await login(data, role);

      if (onSuccess) {
        onSuccess();
      } else {
        // Redirect based on role
        router.push(role === 'customer' ? '/customer/discover' : '/merchant/dashboard');
      }
    } catch (error) {
      // Error is handled by the auth store
    }
  };

  const roleDisplayName = role === 'customer' ? 'Customer' : 'Merchant';
  const registerPath = role === 'customer' ? '/auth/customer/register' : '/auth/merchant/register';

  return (
    <Card className="w-full max-w-md mx-auto">
      <CardHeader className="space-y-1">
        <CardTitle className="text-2xl text-center">
          {roleDisplayName} Login
        </CardTitle>
        <CardDescription className="text-center">
          Sign in to your {roleDisplayName.toLowerCase()} account
        </CardDescription>
      </CardHeader>
      <CardContent>
        <form onSubmit={handleSubmit(onSubmit)} className="space-y-4">
          <Input
            {...register('email')}
            label="Email"
            type="email"
            placeholder="Enter your email"
            error={errors.email?.message}
            autoComplete="email"
          />

          <div className="relative">
            <Input
              {...register('password')}
              label="Password"
              type={showPassword ? 'text' : 'password'}
              placeholder="Enter your password"
              error={errors.password?.message}
              autoComplete="current-password"
            />
            <button
              type="button"
              className="absolute right-3 top-8 text-gray-400 hover:text-gray-600"
              onClick={() => setShowPassword(!showPassword)}
              tabIndex={-1}
            >
              {showPassword ? (
                <svg className="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M13.875 18.825A10.05 10.05 0 0112 19c-4.478 0-8.268-2.943-9.543-7a9.97 9.97 0 011.563-3.029m5.858.908a3 3 0 114.243 4.243M9.878 9.878l4.242 4.242M9.878 9.878L3 3m6.878 6.878L21 21" />
                </svg>
              ) : (
                <svg className="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z" />
                </svg>
              )}
            </button>
          </div>

          {error && (
            <div className="rounded-lg bg-red-50 p-3 text-sm text-red-700">
              {error}
            </div>
          )}

          <Button
            type="submit"
            className="w-full"
            isLoading={isLoading}
            disabled={isLoading}
          >
            {isLoading ? 'Signing in...' : 'Sign In'}
          </Button>

          <div className="text-center">
            <p className="text-sm text-gray-600">
              Don't have an account?{' '}
              <Link
                href={registerPath}
                className="font-medium text-green-600 hover:text-green-500"
              >
                Sign up
              </Link>
            </p>
          </div>

          {role === 'customer' && (
            <div className="text-center">
              <p className="text-sm text-gray-600">
                Are you a business?{' '}
                <Link
                  href="/auth/merchant/login"
                  className="font-medium text-green-600 hover:text-green-500"
                >
                  Merchant Login
                </Link>
              </p>
            </div>
          )}

          {role === 'merchant' && (
            <div className="text-center">
              <p className="text-sm text-gray-600">
                Looking to order food?{' '}
                <Link
                  href="/auth/customer/login"
                  className="font-medium text-green-600 hover:text-green-500"
                >
                  Customer Login
                </Link>
              </p>
            </div>
          )}
        </form>
      </CardContent>
    </Card>
  );
}