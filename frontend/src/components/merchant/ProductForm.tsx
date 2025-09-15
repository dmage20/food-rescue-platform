'use client';

import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';
import { Product } from '@/types';
import { Button } from '@/components/ui/Button';
import { Input } from '@/components/ui/Input';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/Card';

const productSchema = z.object({
  name: z.string().min(2, 'Product name must be at least 2 characters'),
  description: z.string().min(10, 'Description must be at least 10 characters'),
  category: z.string().min(1, 'Please select a category'),
  original_price: z.number().min(0.01, 'Price must be greater than 0'),
  discounted_price: z.number().min(0.01, 'Discounted price must be greater than 0'),
  available_quantity: z.number().min(1, 'Quantity must be at least 1'),
  expires_at: z.string().min(1, 'Please set an expiration date and time'),
  allergens: z.array(z.string()).optional(),
  dietary_tags: z.array(z.string()).optional(),
}).refine((data) => data.discounted_price <= data.original_price, {
  message: "Discounted price must be less than or equal to original price",
  path: ["discounted_price"],
});

type ProductFormData = z.infer<typeof productSchema>;

interface ProductFormProps {
  product?: Product;
  onSubmit: (data: ProductFormData) => Promise<void>;
  isSubmitting?: boolean;
  submitButtonText?: string;
}

export function ProductForm({
  product,
  onSubmit,
  isSubmitting = false,
  submitButtonText = 'Save Product'
}: ProductFormProps) {
  const {
    register,
    handleSubmit,
    watch,
    setValue,
    formState: { errors },
  } = useForm<ProductFormData>({
    resolver: zodResolver(productSchema),
    defaultValues: product ? {
      name: product.name,
      description: product.description,
      category: product.category,
      original_price: product.original_price,
      discounted_price: product.discounted_price,
      available_quantity: product.available_quantity,
      expires_at: product.expires_at ? new Date(product.expires_at).toISOString().slice(0, 16) : '',
      allergens: product.allergens,
      dietary_tags: product.dietary_tags,
    } : {
      allergens: [],
      dietary_tags: [],
    },
  });

  const categories = [
    'bread', 'pastries', 'cakes', 'sandwiches', 'salads',
    'beverages', 'dairy', 'produce', 'prepared_foods', 'other'
  ];

  const dietaryTags = [
    'vegetarian', 'vegan', 'gluten-free', 'dairy-free',
    'nut-free', 'organic', 'keto', 'low-carb'
  ];

  const allergens = [
    'gluten', 'dairy', 'eggs', 'nuts', 'peanuts',
    'soy', 'fish', 'shellfish', 'sesame'
  ];

  const originalPrice = watch('original_price');
  const discountedPrice = watch('discounted_price');
  const discountPercentage = originalPrice && discountedPrice
    ? Math.round(((originalPrice - discountedPrice) / originalPrice) * 100)
    : 0;

  const handleArrayToggle = (field: 'allergens' | 'dietary_tags', value: string) => {
    const currentValue = watch(field) || [];
    const newValue = currentValue.includes(value)
      ? currentValue.filter(item => item !== value)
      : [...currentValue, value];
    setValue(field, newValue);
  };

  return (
    <form onSubmit={handleSubmit(onSubmit)} className="space-y-6">
      <Card>
        <CardHeader>
          <CardTitle>Basic Information</CardTitle>
        </CardHeader>
        <CardContent className="space-y-4">
          <Input
            {...register('name')}
            label="Product Name"
            placeholder="e.g., Fresh Croissants"
            error={errors.name?.message}
          />

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Description
            </label>
            <textarea
              {...register('description')}
              placeholder="Describe your product in detail..."
              className="flex min-h-[80px] w-full rounded-lg border border-gray-300 bg-white px-3 py-2 text-sm ring-offset-white placeholder:text-gray-400 focus:border-green-500 focus:outline-none focus:ring-2 focus:ring-green-500 focus:ring-offset-2 disabled:cursor-not-allowed disabled:opacity-50"
              rows={3}
            />
            {errors.description && (
              <p className="text-sm text-red-600 mt-1" role="alert">
                {errors.description.message}
              </p>
            )}
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Category
            </label>
            <select
              {...register('category')}
              className="flex h-10 w-full rounded-lg border border-gray-300 bg-white px-3 py-2 text-sm ring-offset-white focus:border-green-500 focus:outline-none focus:ring-2 focus:ring-green-500 focus:ring-offset-2"
            >
              <option value="">Select a category</option>
              {categories.map((category) => (
                <option key={category} value={category}>
                  {category.replace('_', ' ')}
                </option>
              ))}
            </select>
            {errors.category && (
              <p className="text-sm text-red-600 mt-1" role="alert">
                {errors.category.message}
              </p>
            )}
          </div>
        </CardContent>
      </Card>

      <Card>
        <CardHeader>
          <CardTitle>Pricing & Inventory</CardTitle>
        </CardHeader>
        <CardContent className="space-y-4">
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <Input
              {...register('original_price', { valueAsNumber: true })}
              label="Original Price"
              type="number"
              step="0.01"
              min="0"
              placeholder="0.00"
              error={errors.original_price?.message}
            />

            <Input
              {...register('discounted_price', { valueAsNumber: true })}
              label="Discounted Price"
              type="number"
              step="0.01"
              min="0"
              placeholder="0.00"
              error={errors.discounted_price?.message}
              helperText={discountPercentage > 0 ? `${discountPercentage}% discount` : undefined}
            />
          </div>

          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <Input
              {...register('available_quantity', { valueAsNumber: true })}
              label="Available Quantity"
              type="number"
              min="0"
              placeholder="0"
              error={errors.available_quantity?.message}
            />

            <Input
              {...register('expires_at')}
              label="Expiration Date & Time"
              type="datetime-local"
              error={errors.expires_at?.message}
            />
          </div>
        </CardContent>
      </Card>

      <Card>
        <CardHeader>
          <CardTitle>Dietary Information</CardTitle>
        </CardHeader>
        <CardContent className="space-y-4">
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              Dietary Tags
            </label>
            <div className="flex flex-wrap gap-2">
              {dietaryTags.map((tag) => (
                <button
                  key={tag}
                  type="button"
                  onClick={() => handleArrayToggle('dietary_tags', tag)}
                  className={`px-3 py-1 rounded-full text-sm font-medium transition-colors ${
                    (watch('dietary_tags') || []).includes(tag)
                      ? 'bg-green-600 text-white'
                      : 'bg-gray-100 text-gray-700 hover:bg-gray-200'
                  }`}
                >
                  {tag.replace('-', ' ')}
                </button>
              ))}
            </div>
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              Allergens
            </label>
            <div className="flex flex-wrap gap-2">
              {allergens.map((allergen) => (
                <button
                  key={allergen}
                  type="button"
                  onClick={() => handleArrayToggle('allergens', allergen)}
                  className={`px-3 py-1 rounded-full text-sm font-medium transition-colors ${
                    (watch('allergens') || []).includes(allergen)
                      ? 'bg-red-600 text-white'
                      : 'bg-gray-100 text-gray-700 hover:bg-gray-200'
                  }`}
                >
                  {allergen}
                </button>
              ))}
            </div>
            <p className="text-xs text-gray-500 mt-2">
              Select all allergens present in this product
            </p>
          </div>
        </CardContent>
      </Card>

      <div className="flex justify-end space-x-4">
        <Button
          type="button"
          variant="outline"
          onClick={() => window.history.back()}
        >
          Cancel
        </Button>
        <Button
          type="submit"
          isLoading={isSubmitting}
          disabled={isSubmitting}
        >
          {submitButtonText}
        </Button>
      </div>
    </form>
  );
}