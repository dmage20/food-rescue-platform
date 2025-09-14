# Demo Data

This directory contains realistic demo data for the Food Rescue Platform to help with development, testing, and demonstrations.

## Overview

The demo data represents a realistic scenario of 6 bakeries and cafes in San Francisco selling discounted items to prevent food waste, along with 8 customers and their order history.

## Data Structure

### Merchants (`merchants/merchants.json`)
- 6 different bakery/cafe types across SF neighborhoods
- Business hours, contact info, and pickup instructions
- Specialties ranging from artisan breads to French pastries
- Geographic distribution across different SF districts

### Products (`products/products.json`)
- 10 individual products across different categories
- Realistic pricing with 50% average discounts
- Allergen and dietary information
- Expiration times within 24-48 hours
- Categories: pastries, bread, sandwiches, muffins, desserts, donuts

### Bundles (`products/bundles.json`)
- 6 bundle combinations for better value
- Mix of individual products in themed packages
- "Morning Pastry Box", "Healthy Lunch Combo", etc.
- Significant savings over individual purchases

### Customers (`customers/customers.json`)
- 8 diverse customer profiles
- Different dietary preferences and restrictions
- Varying search radii (1.5km to 6km)
- Favorite categories based on preferences

### Orders (`orders/orders.json`)
- 8 sample orders with different statuses:
  - `completed` - Successfully picked up
  - `ready_for_pickup` - Awaiting customer pickup
  - `pending` - Order placed, being prepared
  - `cancelled` - Customer cancellation
- Realistic pickup windows (2-3 hour windows)
- Mix of individual products and bundle orders

## Geographic Distribution

All merchants are located in San Francisco:
- **Downtown**: Sunrise Bakery
- **Mission District**: Corner Café, Artisan Breads Co.
- **Nob Hill**: Sweet Dreams Patisserie
- **Castro District**: Daily Grind Coffee
- **Sunset District**: Golden Gate Donuts

## Usage

### For Development
Use this data to:
- Populate local databases during development
- Test search and filtering functionality
- Validate business logic and calculations
- Demo the complete user experience

### For Testing
- Test edge cases (expired items, out of stock)
- Validate order flow with different scenarios
- Test dietary filtering and allergen warnings
- Performance testing with realistic data volumes

### Loading Demo Data
The included `seed.rb` script can be used to load this data into your Rails application:

```bash
cd rails-api
rails db:seed:demo
```

## Data Realism Features

- **Pricing**: Realistic original prices with meaningful discounts
- **Geography**: Actual SF neighborhoods and realistic distances
- **Business Hours**: Varied schedules reflecting real bakery operations
- **Dietary Info**: Comprehensive allergen and dietary preference tracking
- **Order Timing**: Realistic pickup windows and ordering patterns
- **Inventory**: Varied quantities reflecting end-of-day availability

## Image Placeholders

The `images/` directories contain placeholders for:
- Merchant storefronts and logos
- Individual product photos (multiple angles)
- Bundle presentation photos
- These would be replaced with actual images in production

## Extending Demo Data

To add more demo data:
1. Follow existing JSON structure
2. Ensure geographic coordinates are realistic
3. Keep pricing and timing realistic
4. Update seed scripts accordingly
5. Add corresponding image placeholders

This demo data provides a solid foundation for development and testing of the food waste prevention platform.