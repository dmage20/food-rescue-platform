# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Common Development Commands

### Quick Start with Makefile
```bash
# Initial setup (first time only)
make setup

# Start all services
make start

# Check service status
make status

# Stop all services
make stop

# View all available commands
make help
```

### Environment Setup
```bash
# For Docker environment (when available)
docker-compose up -d
docker-compose exec rails-api rails db:setup
docker-compose exec rails-api rails db:seed

# For local development with Makefile
make setup              # Install deps, setup DB, seed data
make start             # Start Rails API + Frontend
make stop              # Stop all services

# Manual local development
cd rails-api && rails db:create db:migrate db:seed
cd ../frontend && npm install && npm run build
```

### Rails API Development
```bash
# Using Makefile commands
make dev-console        # Rails console
make test              # Run all tests
make db-reset          # Reset database with fresh data
make logs-rails        # View Rails logs

# Direct Rails commands
cd rails-api

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
# Using Makefile commands
make dev-frontend       # Start frontend in development mode
make build             # Build all services including frontend
make logs-frontend     # View frontend logs

# Direct frontend commands
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
- **Models**: Merchant, Customer, Product, Bundle, BundleItem, Order, OrderItem with comprehensive validations
- **Authentication**: Devise with JWT authentication for both merchants and customers
- **API Endpoints**: Complete REST API for merchants, customers, products, bundles, orders, and browsing
- **Testing**: RSpec setup with FactoryBot, comprehensive model tests
- **Frontend Application**: Complete Next.js app with TypeScript, mobile-responsive design
- **Authentication UI**: Login/register forms for both merchants and customers with JWT integration
- **Customer Interface**: Product discovery, shopping cart, checkout flow, order management
- **Merchant Dashboard**: Business metrics, product management, order tracking, inventory control
- **Demo Data**: 6 merchants, 8 customers, 10 products, 6 bundles loaded via seeds
- **End-to-end Testing**: Playwright E2E testing infrastructure (13 pages created)
- **Service Management**: Makefile-based orchestration for development workflow
- **Production Ready**: Both frontend and backend compile successfully for production deployment

### 🚧 In Progress / TODO
- Authorization with Pundit (basic structure in place)
- Rust microservices (location, inventory, image processing)
- Real-time WebSocket connections
- Payment integration with Stripe
- SMS notifications with Twilio
- E2E test alignment with new UI components
- PWA features and offline capabilities

## API Endpoints

### Authentication
```
POST /api/merchants/sign_in     # Merchant login (JWT)
POST /api/merchants/sign_up     # Merchant registration
DELETE /api/merchants/sign_out  # Merchant logout

POST /api/customers/sign_in     # Customer login (JWT)
POST /api/customers/sign_up     # Customer registration
DELETE /api/customers/sign_out  # Customer logout
```

### Merchant Management
```
GET /api/merchant              # Get current merchant profile
PATCH /api/merchant            # Update merchant profile

GET /api/products              # List merchant's products
POST /api/products             # Create new product
GET /api/products/:id          # Get specific product
PATCH /api/products/:id        # Update product
DELETE /api/products/:id       # Delete product

GET /api/bundles               # List merchant's bundles
POST /api/bundles              # Create new bundle
GET /api/bundles/:id           # Get specific bundle
PATCH /api/bundles/:id         # Update bundle
DELETE /api/bundles/:id        # Delete bundle

GET /api/orders                # List merchant's orders
GET /api/orders/:id            # Get specific order
PATCH /api/orders/:id          # Update order status
```

### Customer Browsing
```
GET /api/customer              # Get current customer profile
PATCH /api/customer            # Update customer profile

GET /api/browse/merchants      # Find nearby merchants
GET /api/browse/products       # Browse available products
GET /api/browse/bundles        # Browse available bundles

POST /api/orders               # Create new order
GET /api/orders                # List customer's orders
GET /api/orders/:id            # Get specific order
```

### Query Parameters
- **Location filtering**: `?latitude=37.7749&longitude=-122.4194&radius=5`
- **Product filtering**: `?category=bakery&min_price=5&max_price=20&search=croissant`
- **Bundle filtering**: `?min_price=10&max_price=50&search=breakfast`

## Frontend Application Structure

### 📱 **Pages Created (13 total)**
```
/                                    # Landing page
/auth/customer/login                 # Customer authentication
/auth/customer/register              # Customer registration
/auth/merchant/login                 # Merchant authentication
/auth/merchant/register              # Merchant registration
/customer/discover                   # Product discovery interface
/customer/cart                       # Shopping cart management
/customer/checkout                   # Order placement flow
/customer/orders                     # Order history and tracking
/merchant/dashboard                  # Business metrics and overview
/merchant/products                   # Product management interface
/merchant/products/new               # Add new product form
```

### 🛠 **Technical Stack**
- **Framework**: Next.js 15 with App Router
- **Language**: TypeScript with comprehensive type safety
- **Styling**: Tailwind CSS with mobile-first responsive design
- **State Management**: Zustand for client state, TanStack Query for server state
- **Authentication**: JWT tokens with secure cookie storage
- **Forms**: React Hook Form with Zod validation schemas
- **Testing**: Playwright E2E testing across multiple device types
- **Build**: Optimized production builds with code splitting

### 🎯 **Key Features Implemented**
- **Authentication System**: Complete login/register flows for both user types
- **Role-Based Access**: Protected routes and role-specific navigation
- **Mobile-First Design**: Touch-friendly interfaces optimized for all screen sizes
- **Real-Time UI**: Loading states, error handling, and smooth interactions
- **Shopping Experience**: Product discovery, cart management, and checkout flow
- **Business Management**: Merchant dashboard with analytics and product management
- **API Integration**: Complete integration with Rails JWT API endpoints

## Development Notes

- Use local PostgreSQL for development (configured for user `danielmage`)
- Rails API runs on port 3000, Frontend on port 3100
- Demo data includes realistic SF Bay Area merchants and products
- All models include comprehensive validations and business logic
- Follow mobile-first responsive design principles
- JWT tokens are required for authenticated endpoints
- All API responses follow consistent JSON structure with status/data/errors