# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Common Development Commands

### Environment Setup
```bash
# For Docker environment (when available)
docker-compose up -d
docker-compose exec rails-api rails db:setup
docker-compose exec rails-api rails db:seed

# For local development
cd rails-api && rails db:create db:migrate db:seed
cd ../frontend && npm install && npm run build
```

### Rails API Development
```bash
# Enter Rails container
docker-compose exec rails-api bash

# Run Rails console
rails console

# Run tests
bundle exec rspec

# Generate migration
rails generate migration AddIndexToProducts

# Run specific migration
rails db:migrate:up VERSION=20231201000000
```

### Rust Services Development
```bash
# Build all Rust services
docker-compose exec location-service cargo build --release
docker-compose exec inventory-tracker cargo build --release
docker-compose exec image-processor cargo build --release

# Run tests
docker-compose exec location-service cargo test
docker-compose exec inventory-tracker cargo test
docker-compose exec image-processor cargo test

# Check logs
docker-compose logs -f location-service
docker-compose logs -f inventory-tracker
docker-compose logs -f image-processor
```

### Frontend Development
```bash
# Enter frontend directory
cd frontend

# Install dependencies
npm install

# Run development server
npm run dev

# Build for production
npm run build

# Run Playwright tests
npx playwright test

# Run specific test
npx playwright test tests/home.spec.ts
```

## Architecture Overview

### Hybrid Rails + Rust Approach
This platform uses a distributed architecture with clear service boundaries:

- **Rails API (Port 3000)**: Handles business logic, authentication, order management, and orchestrates Rust services
- **Location Service (Port 3001)**: Rust microservice for high-performance geo-spatial queries and merchant discovery
- **Inventory Tracker (Port 3002)**: Rust microservice for real-time inventory tracking and WebSocket updates
- **Image Processor (Port 3003)**: Rust microservice for image processing and AWS S3/Cloudinary integration
- **Next.js Frontend (Port 3100)**: Mobile-first responsive web application
- **Sidekiq**: Background job processing for Rails

### Database Architecture
- **PostgreSQL + PostGIS**: Primary database with geo-spatial support for location-based queries
- **Redis**: Multi-database setup:
  - DB 0: Rails caching and Sidekiq jobs
  - DB 1: Location service caching
  - DB 2: Inventory service real-time data

### Key Service Communication
- Rails API coordinates with Rust services via HTTP APIs
- Frontend communicates with Rails API and receives real-time updates from Inventory service via WebSocket
- All services share the same PostgreSQL database but have dedicated Redis databases

### Development Environment
- All services run in Docker containers with volume mounts for live code reloading
- PostgreSQL and Redis run as shared services with health checks
- Environment variables are managed through .env file (see .env.example)

### Demo Data Structure
The platform includes comprehensive demo data in `/demo/`:
- 6 merchants across San Francisco neighborhoods
- 10 products with realistic pricing and descriptions
- 6 bundle combinations for various scenarios
- 8 customer profiles with diverse preferences
- Order history showing various statuses and flows

### External Service Integrations
- **Stripe**: Payment processing
- **Twilio**: SMS notifications for order updates
- **AWS S3/Cloudinary**: Image storage and optimization
- **Mapbox**: Maps and location services
- **Sentry/Datadog**: Monitoring and analytics

## Current Implementation Status

### ✅ Completed
- **Rails API**: Full database schema with 7 models and associations
- **Database**: PostgreSQL with PostGIS support, migrations and indexes
- **Models**: Merchant, Customer, Product, Bundle, BundleItem, Order, OrderItem
- **Testing**: RSpec setup with FactoryBot, Shoulda Matchers, and DatabaseCleaner
- **Authentication**: BCrypt password hashing (Devise/JWT not yet configured)
- **Next.js Frontend**: TypeScript setup with Tailwind CSS
- **Demo Data**: 6 merchants, 8 customers, 10 products, 6 bundles loaded via seeds
- **End-to-end Testing**: Playwright configuration for frontend testing

### 🚧 In Progress / TODO
- API endpoints for merchants, customers, products, bundles, orders
- JWT authentication with Devise
- Authorization with Pundit
- Rust microservices (location, inventory, image processing)
- Real-time WebSocket connections
- Payment integration with Stripe
- SMS notifications with Twilio

## Development Notes

- Use local PostgreSQL for development (configured for user `danielmage`)
- Rails API runs on port 3000, Frontend on port 3100
- Demo data includes realistic SF Bay Area merchants and products
- All models include comprehensive validations and business logic
- Follow mobile-first responsive design principles