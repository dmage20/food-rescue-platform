import { test, expect } from '@playwright/test';

test.describe('Authentication', () => {
  test('customer login page displays correctly', async ({ page }) => {
    await page.goto('/auth/customer/login');

    // Check title and form elements
    await expect(page.getByRole('heading', { name: 'Customer Login' })).toBeVisible();
    await expect(page.getByText('Sign in to your customer account')).toBeVisible();

    // Check form fields
    await expect(page.getByLabel('Email')).toBeVisible();
    await expect(page.getByLabel('Password')).toBeVisible();
    await expect(page.getByRole('button', { name: 'Sign In' })).toBeVisible();

    // Check navigation links
    await expect(page.getByText('Don\'t have an account?')).toBeVisible();
    await expect(page.getByRole('link', { name: 'Sign up' })).toBeVisible();
    await expect(page.getByRole('link', { name: 'Merchant Login' })).toBeVisible();
  });

  test('merchant login page displays correctly', async ({ page }) => {
    await page.goto('/auth/merchant/login');

    // Check title and form elements
    await expect(page.getByRole('heading', { name: 'Merchant Login' })).toBeVisible();
    await expect(page.getByText('Sign in to your merchant account')).toBeVisible();

    // Check form fields
    await expect(page.getByLabel('Email')).toBeVisible();
    await expect(page.getByLabel('Password')).toBeVisible();
    await expect(page.getByRole('button', { name: 'Sign In' })).toBeVisible();

    // Check navigation links
    await expect(page.getByText('Don\'t have an account?')).toBeVisible();
    await expect(page.getByRole('link', { name: 'Sign up' })).toBeVisible();
    await expect(page.getByRole('link', { name: 'Customer Login' })).toBeVisible();
  });

  test('customer registration page displays correctly', async ({ page }) => {
    await page.goto('/auth/customer/register');

    // Check title and form elements
    await expect(page.getByRole('heading', { name: 'Customer Registration' })).toBeVisible();
    await expect(page.getByText('Create your customer account')).toBeVisible();

    // Check form fields
    await expect(page.getByLabel('Full Name')).toBeVisible();
    await expect(page.getByLabel('Email')).toBeVisible();
    await expect(page.getByLabel('Phone Number (Optional)')).toBeVisible();
    await expect(page.getByLabel('Password')).toBeVisible();
    await expect(page.getByLabel('Confirm Password')).toBeVisible();
    await expect(page.getByRole('button', { name: 'Create Account' })).toBeVisible();

    // Check navigation links
    await expect(page.getByText('Already have an account?')).toBeVisible();
    await expect(page.getByRole('link', { name: 'Sign in' })).toBeVisible();
  });

  test('merchant registration page displays correctly', async ({ page }) => {
    await page.goto('/auth/merchant/register');

    // Check title and form elements
    await expect(page.getByRole('heading', { name: 'Merchant Registration' })).toBeVisible();
    await expect(page.getByText('Create your merchant account')).toBeVisible();

    // Check form fields
    await expect(page.getByLabel('Full Name')).toBeVisible();
    await expect(page.getByLabel('Email')).toBeVisible();
    await expect(page.getByLabel('Phone Number (Optional)')).toBeVisible();
    await expect(page.getByLabel('Business Name')).toBeVisible();
    await expect(page.getByLabel('Business Type')).toBeVisible();
    await expect(page.getByLabel('Business Address')).toBeVisible();
    await expect(page.getByLabel('Password')).toBeVisible();
    await expect(page.getByLabel('Confirm Password')).toBeVisible();
    await expect(page.getByRole('button', { name: 'Create Account' })).toBeVisible();
  });

  test('form validation works on login forms', async ({ page }) => {
    await page.goto('/auth/customer/login');

    // Try to submit empty form
    await page.getByRole('button', { name: 'Sign In' }).click();

    // Check for validation errors
    await expect(page.getByText('Please enter a valid email address')).toBeVisible();
    await expect(page.getByText('Password must be at least 6 characters')).toBeVisible();
  });

  test('form validation works on registration forms', async ({ page }) => {
    await page.goto('/auth/customer/register');

    // Try to submit empty form
    await page.getByRole('button', { name: 'Create Account' }).click();

    // Check for validation errors
    await expect(page.getByText('Name must be at least 2 characters')).toBeVisible();
    await expect(page.getByText('Please enter a valid email address')).toBeVisible();
    await expect(page.getByText('Password must be at least 6 characters')).toBeVisible();
  });

  test('password confirmation validation works', async ({ page }) => {
    await page.goto('/auth/customer/register');

    // Fill form with mismatched passwords
    await page.getByLabel('Full Name').fill('Test User');
    await page.getByLabel('Email').fill('test@example.com');
    await page.getByLabel('Password').fill('password123');
    await page.getByLabel('Confirm Password').fill('different123');

    await page.getByRole('button', { name: 'Create Account' }).click();

    // Check for password mismatch error
    await expect(page.getByText('Passwords don\'t match')).toBeVisible();
  });

  test('navigation between auth pages works', async ({ page }) => {
    await page.goto('/auth/customer/login');

    // Navigate to customer registration
    await page.getByRole('link', { name: 'Sign up' }).click();
    await expect(page).toHaveURL('/auth/customer/register');
    await expect(page.getByRole('heading', { name: 'Customer Registration' })).toBeVisible();

    // Navigate to merchant registration
    await page.getByRole('link', { name: 'Merchant Registration' }).click();
    await expect(page).toHaveURL('/auth/merchant/register');
    await expect(page.getByRole('heading', { name: 'Merchant Registration' })).toBeVisible();

    // Navigate to merchant login
    await page.getByRole('link', { name: 'Sign in' }).click();
    await expect(page).toHaveURL('/auth/merchant/login');
    await expect(page.getByRole('heading', { name: 'Merchant Login' })).toBeVisible();

    // Navigate back to customer login
    await page.getByRole('link', { name: 'Customer Login' }).click();
    await expect(page).toHaveURL('/auth/customer/login');
    await expect(page.getByRole('heading', { name: 'Customer Login' })).toBeVisible();
  });
});

test.describe('Protected Routes', () => {
  test('customer routes redirect to login when not authenticated', async ({ page }) => {
    // Try to access customer-only pages
    await page.goto('/customer/discover');
    await expect(page).toHaveURL('/auth/customer/login');

    await page.goto('/customer/cart');
    await expect(page).toHaveURL('/auth/customer/login');

    await page.goto('/customer/orders');
    await expect(page).toHaveURL('/auth/customer/login');
  });

  test('merchant routes redirect to login when not authenticated', async ({ page }) => {
    // Try to access merchant-only pages
    await page.goto('/merchant/dashboard');
    await expect(page).toHaveURL('/auth/merchant/login');

    await page.goto('/merchant/products');
    await expect(page).toHaveURL('/auth/merchant/login');

    await page.goto('/merchant/products/new');
    await expect(page).toHaveURL('/auth/merchant/login');
  });
});

test.describe('Navigation', () => {
  test('navigation bar displays correctly on homepage', async ({ page }) => {
    await page.goto('/');

    // Check logo and title
    await expect(page.getByText('🥖')).toBeVisible();
    await expect(page.getByText('Food Rescue')).toBeVisible();

    // Check navigation links for unauthenticated users
    await expect(page.getByRole('link', { name: 'Customer Login' })).toBeVisible();
    await expect(page.getByRole('link', { name: 'Merchant Login' })).toBeVisible();
  });

  test('mobile navigation works', async ({ page }) => {
    // Set mobile viewport
    await page.setViewportSize({ width: 375, height: 667 });
    await page.goto('/');

    // Check that mobile menu button is visible
    await expect(page.getByRole('button').filter({ hasText: 'Menu' })).toBeVisible();

    // Click mobile menu button
    await page.getByRole('button').filter({ hasText: 'Menu' }).click();

    // Check that mobile menu items are visible
    await expect(page.getByRole('link', { name: 'Customer Login' })).toBeVisible();
    await expect(page.getByRole('link', { name: 'Merchant Login' })).toBeVisible();
  });
});

test.describe('Homepage', () => {
  test('homepage displays correctly with all sections', async ({ page }) => {
    await page.goto('/');

    // Check main heading and description
    await expect(page.getByRole('heading', { name: '🥖 Food Rescue Platform' })).toBeVisible();
    await expect(page.getByText('Connecting bakeries and cafes with customers to reduce food waste')).toBeVisible();

    // Check customer section
    await expect(page.getByRole('heading', { name: 'For Customers' })).toBeVisible();
    await expect(page.getByText('🗺️ Discover nearby merchants')).toBeVisible();
    await expect(page.getByRole('button', { name: 'Customer Login' })).toBeVisible();
    await expect(page.getByRole('button', { name: 'Sign Up as Customer' })).toBeVisible();

    // Check merchant section
    await expect(page.getByRole('heading', { name: 'For Merchants' })).toBeVisible();
    await expect(page.getByText('📊 Reduce food waste')).toBeVisible();
    await expect(page.getByRole('button', { name: 'Merchant Login' })).toBeVisible();
    await expect(page.getByRole('button', { name: 'Sign Up as Merchant' })).toBeVisible();

    // Check call to action
    await expect(page.getByText('Join the movement to reduce food waste while saving money! 🌱')).toBeVisible();
  });

  test('homepage buttons navigate to correct auth pages', async ({ page }) => {
    await page.goto('/');

    // Test customer login button
    await page.getByRole('button', { name: 'Customer Login' }).click();
    await expect(page).toHaveURL('/auth/customer/login');

    await page.goBack();

    // Test customer signup button
    await page.getByRole('button', { name: 'Sign Up as Customer' }).click();
    await expect(page).toHaveURL('/auth/customer/register');

    await page.goto('/');

    // Test merchant login button
    await page.getByRole('button', { name: 'Merchant Login' }).click();
    await expect(page).toHaveURL('/auth/merchant/login');

    await page.goBack();

    // Test merchant signup button
    await page.getByRole('button', { name: 'Sign Up as Merchant' }).click();
    await expect(page).toHaveURL('/auth/merchant/register');
  });
});