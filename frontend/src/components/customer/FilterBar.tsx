'use client';

import { useState } from 'react';
import { Button } from '@/components/ui/Button';
import { Input } from '@/components/ui/Input';
import { ProductFilters } from '@/types';
import { FilterIcon, XIcon } from 'lucide-react';

interface FilterBarProps {
  filters: ProductFilters;
  onFiltersChange: (filters: ProductFilters) => void;
  onClearFilters: () => void;
}

export function FilterBar({ filters, onFiltersChange, onClearFilters }: FilterBarProps) {
  const [showFilters, setShowFilters] = useState(false);

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

  const handleFilterChange = (key: keyof ProductFilters, value: any) => {
    onFiltersChange({
      ...filters,
      [key]: value,
    });
  };

  const handleArrayFilterToggle = (key: 'dietary_tags' | 'exclude_allergens', value: string) => {
    const currentArray = filters[key] || [];
    const newArray = currentArray.includes(value)
      ? currentArray.filter(item => item !== value)
      : [...currentArray, value];

    handleFilterChange(key, newArray);
  };

  const hasActiveFilters = Object.keys(filters).some(key => {
    const value = filters[key as keyof ProductFilters];
    return value !== undefined && value !== null && value !== '' &&
           (Array.isArray(value) ? value.length > 0 : true);
  });

  return (
    <div className="bg-white border-b border-gray-200 sticky top-16 z-10">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        {/* Filter toggle bar */}
        <div className="flex items-center justify-between py-4">
          <Button
            variant="outline"
            onClick={() => setShowFilters(!showFilters)}
            className="flex items-center space-x-2"
          >
            <FilterIcon className="h-4 w-4" />
            <span>Filters</span>
            {hasActiveFilters && (
              <span className="bg-green-600 text-white text-xs rounded-full px-2 py-0.5">
                Active
              </span>
            )}
          </Button>

          {hasActiveFilters && (
            <Button
              variant="ghost"
              size="sm"
              onClick={onClearFilters}
              className="flex items-center space-x-1"
            >
              <XIcon className="h-4 w-4" />
              <span>Clear Filters</span>
            </Button>
          )}
        </div>

        {/* Expanded filters */}
        {showFilters && (
          <div className="pb-6 space-y-6">
            {/* Search and Location */}
            <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Search
                </label>
                <Input
                  placeholder="Search products..."
                  value={filters.search || ''}
                  onChange={(e) => handleFilterChange('search', e.target.value)}
                />
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Max Distance (miles)
                </label>
                <Input
                  type="number"
                  placeholder="5"
                  value={filters.radius || ''}
                  onChange={(e) => handleFilterChange('radius', Number(e.target.value) || undefined)}
                />
              </div>
              <div className="flex items-end">
                <label className="flex items-center space-x-2">
                  <input
                    type="checkbox"
                    checked={filters.available_only || false}
                    onChange={(e) => handleFilterChange('available_only', e.target.checked)}
                    className="rounded border-gray-300 text-green-600 focus:ring-green-500"
                  />
                  <span className="text-sm font-medium text-gray-700">Available only</span>
                </label>
              </div>
            </div>

            {/* Price Range */}
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Price Range
              </label>
              <div className="grid grid-cols-2 gap-4 max-w-xs">
                <Input
                  type="number"
                  placeholder="Min $"
                  value={filters.min_price || ''}
                  onChange={(e) => handleFilterChange('min_price', Number(e.target.value) || undefined)}
                />
                <Input
                  type="number"
                  placeholder="Max $"
                  value={filters.max_price || ''}
                  onChange={(e) => handleFilterChange('max_price', Number(e.target.value) || undefined)}
                />
              </div>
            </div>

            {/* Categories */}
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Category
              </label>
              <div className="flex flex-wrap gap-2">
                {categories.map((category) => (
                  <button
                    key={category}
                    onClick={() => handleFilterChange('category',
                      filters.category === category ? undefined : category
                    )}
                    className={`px-3 py-1 rounded-full text-sm font-medium transition-colors ${
                      filters.category === category
                        ? 'bg-green-600 text-white'
                        : 'bg-gray-100 text-gray-700 hover:bg-gray-200'
                    }`}
                  >
                    {category.replace('_', ' ')}
                  </button>
                ))}
              </div>
            </div>

            {/* Dietary Preferences */}
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Dietary Preferences
              </label>
              <div className="flex flex-wrap gap-2">
                {dietaryTags.map((tag) => (
                  <button
                    key={tag}
                    onClick={() => handleArrayFilterToggle('dietary_tags', tag)}
                    className={`px-3 py-1 rounded-full text-sm font-medium transition-colors ${
                      filters.dietary_tags?.includes(tag)
                        ? 'bg-green-600 text-white'
                        : 'bg-gray-100 text-gray-700 hover:bg-gray-200'
                    }`}
                  >
                    {tag.replace('-', ' ')}
                  </button>
                ))}
              </div>
            </div>

            {/* Exclude Allergens */}
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Exclude Allergens
              </label>
              <div className="flex flex-wrap gap-2">
                {allergens.map((allergen) => (
                  <button
                    key={allergen}
                    onClick={() => handleArrayFilterToggle('exclude_allergens', allergen)}
                    className={`px-3 py-1 rounded-full text-sm font-medium transition-colors ${
                      filters.exclude_allergens?.includes(allergen)
                        ? 'bg-red-600 text-white'
                        : 'bg-gray-100 text-gray-700 hover:bg-gray-200'
                    }`}
                  >
                    {allergen}
                  </button>
                ))}
              </div>
            </div>
          </div>
        )}
      </div>
    </div>
  );
}