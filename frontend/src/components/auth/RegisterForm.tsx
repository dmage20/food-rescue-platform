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

const baseRegisterSchema = z.object({
  name: z.string().min(2, 'Name must be at least 2 characters'),
  email: z.string().email('Please enter a valid email address'),
  password: z.string().min(6, 'Password must be at least 6 characters'),
  password_confirmation: z.string(),
  phone: z.string().optional(),
}).refine((data) => data.password === data.password_confirmation, {
  message: "Passwords don't match",
  path: ["password_confirmation"],
});

const customerRegisterSchema = baseRegisterSchema;

const merchantRegisterSchema = z.object({
  name: z.string().min(2, 'Name must be at least 2 characters'),
  email: z.string().email('Please enter a valid email address'),
  password: z.string().min(6, 'Password must be at least 6 characters'),
  password_confirmation: z.string(),
  phone: z.string().optional(),
  business_name: z.string().min(2, 'Business name must be at least 2 characters'),
  business_type: z.string().min(1, 'Please select a business type'),
  address: z.string().min(5, 'Please enter a complete address'),
  description: z.string().optional(),
}).refine((data) => data.password === data.password_confirmation, {
  message: "Passwords don't match",
  path: ["password_confirmation"],
});

type CustomerRegisterData = z.infer<typeof customerRegisterSchema>;
type MerchantRegisterData = z.infer<typeof merchantRegisterSchema>;

interface RegisterFormProps {
  role: UserRole;
  onSuccess?: () => void;
}

export function RegisterForm({ role, onSuccess }: RegisterFormProps) {
  const router = useRouter();
  const { register: registerUser, isLoading, error, clearError } = useAuthStore();
  const [showPassword, setShowPassword] = useState(false);

  const schema = role === 'customer' ? customerRegisterSchema : merchantRegisterSchema;

  const {
    register,
    handleSubmit,
    formState: { errors },
  } = useForm<any>({
    resolver: zodResolver(schema),
  });

  const onSubmit = async (data: CustomerRegisterData | MerchantRegisterData) => {
    try {
      clearError();
      await registerUser(data, role);

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
  const loginPath = role === 'customer' ? '/auth/customer/login' : '/auth/merchant/login';

  const businessTypes = [
    'Bakery',
    'Cafe',
    'Restaurant',
    'Grocery Store',
    'Deli',
    'Catering',
    'Food Truck',
    'Other',
  ];

  return (
    <Card className="w-full max-w-md mx-auto">
      <CardHeader className="space-y-1">
        <CardTitle className="text-2xl text-center">
          {roleDisplayName} Registration
        </CardTitle>
        <CardDescription className="text-center">
          Create your {roleDisplayName.toLowerCase()} account
        </CardDescription>
      </CardHeader>
      <CardContent>
        <form onSubmit={handleSubmit(onSubmit)} className="space-y-4">
          <Input
            {...register('name')}
            label="Full Name"
            placeholder="Enter your full name"
            error={errors.name?.message as string}
            autoComplete="name"
          />

          <Input
            {...register('email')}
            label="Email"
            type="email"
            placeholder="Enter your email"
            error={errors.email?.message as string}
            autoComplete="email"
          />

          <Input
            {...register('phone')}
            label="Phone Number (Optional)"
            type="tel"
            placeholder="Enter your phone number"
            error={errors.phone?.message as string}
            autoComplete="tel"
          />

          {role === 'merchant' && (
            <>
              <Input
                {...register('business_name')}
                label="Business Name"
                placeholder="Enter your business name"
                error={errors.business_name?.message as string}
              />

              <div className="space-y-1">
                <label className="block text-sm font-medium text-gray-700">
                  Business Type
                </label>
                <select
                  {...register('business_type')}
                  className="flex h-10 w-full rounded-lg border border-gray-300 bg-white px-3 py-2 text-sm ring-offset-white placeholder:text-gray-400 focus:border-green-500 focus:outline-none focus:ring-2 focus:ring-green-500 focus:ring-offset-2 disabled:cursor-not-allowed disabled:opacity-50"
                >
                  <option value="">Select business type</option>
                  {businessTypes.map((type) => (
                    <option key={type} value={type}>
                      {type}
                    </option>
                  ))}
                </select>
                {errors.business_type && (
                  <p className="text-sm text-red-600" role="alert">
                    {errors.business_type.message as string}
                  </p>
                )}
              </div>

              <Input
                {...register('address')}
                label="Business Address"
                placeholder="Enter your business address"
                error={errors.address?.message as string}
                autoComplete="street-address"
              />

              <div className="space-y-1">
                <label className="block text-sm font-medium text-gray-700">
                  Business Description (Optional)
                </label>
                <textarea
                  {...register('description')}
                  placeholder="Tell customers about your business"
                  className="flex min-h-[80px] w-full rounded-lg border border-gray-300 bg-white px-3 py-2 text-sm ring-offset-white placeholder:text-gray-400 focus:border-green-500 focus:outline-none focus:ring-2 focus:ring-green-500 focus:ring-offset-2 disabled:cursor-not-allowed disabled:opacity-50"
                  rows={3}
                />
                {errors.description && (
                  <p className="text-sm text-red-600" role="alert">
                    {errors.description.message as string}
                  </p>
                )}
              </div>
            </>
          )}

          <div className="relative">
            <Input
              {...register('password')}
              label="Password"
              type={showPassword ? 'text' : 'password'}
              placeholder="Create a password"
              error={errors.password?.message as string}
              autoComplete="new-password"
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

          <Input
            {...register('password_confirmation')}
            label="Confirm Password"
            type="password"
            placeholder="Confirm your password"
            error={errors.password_confirmation?.message as string}
            autoComplete="new-password"
          />

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
            {isLoading ? 'Creating account...' : 'Create Account'}
          </Button>

          <div className="text-center">
            <p className="text-sm text-gray-600">
              Already have an account?{' '}
              <Link
                href={loginPath}
                className="font-medium text-green-600 hover:text-green-500"
              >
                Sign in
              </Link>
            </p>
          </div>

          {role === 'customer' && (
            <div className="text-center">
              <p className="text-sm text-gray-600">
                Are you a business?{' '}
                <Link
                  href="/auth/merchant/register"
                  className="font-medium text-green-600 hover:text-green-500"
                >
                  Merchant Registration
                </Link>
              </p>
            </div>
          )}

          {role === 'merchant' && (
            <div className="text-center">
              <p className="text-sm text-gray-600">
                Looking to order food?{' '}
                <Link
                  href="/auth/customer/register"
                  className="font-medium text-green-600 hover:text-green-500"
                >
                  Customer Registration
                </Link>
              </p>
            </div>
          )}
        </form>
      </CardContent>
    </Card>
  );
}