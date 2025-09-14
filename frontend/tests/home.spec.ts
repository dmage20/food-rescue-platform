import { test, expect } from '@playwright/test';

test('homepage displays correctly', async ({ page }) => {
  await page.goto('/');

  // Check title
  await expect(page).toHaveTitle(/Food Rescue Platform/);

  // Check main heading
  await expect(page.getByRole('heading', { name: '🥖 Food Rescue Platform' })).toBeVisible();

  // Check description
  await expect(page.getByText('Connecting bakeries and cafes with customers to reduce food waste')).toBeVisible();

  // Check customer section
  await expect(page.getByRole('heading', { name: 'For Customers' })).toBeVisible();
  await expect(page.getByText('🗺️ Discover nearby merchants')).toBeVisible();

  // Check merchant section
  await expect(page.getByRole('heading', { name: 'For Merchants' })).toBeVisible();
  await expect(page.getByText('📊 Reduce food waste')).toBeVisible();

  // Check development message
  await expect(page.getByText('Platform is in development. Check back soon! 🌱')).toBeVisible();
});