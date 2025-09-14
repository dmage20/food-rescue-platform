# Food Rescue Platform 🥖🌱

A mobile-first marketplace connecting bakeries and cafes with customers to sell fresh goods at discounted prices, preventing food waste while helping merchants recoup costs.

## 🎯 Mission

Transform food waste into opportunity by creating a platform where:
- **Merchants** can easily sell surplus fresh goods at discounted prices
- **Customers** can discover and purchase quality food at great values
- **Communities** reduce food waste and support local businesses

---

## 🏗️ Architecture

### Hybrid Rails + Rust Approach
- **Rails API**: Business logic, authentication, order management
- **Rust Microservices**: High-performance geo queries, inventory tracking, image processing
- **Next.js Frontend**: Mobile-first responsive web application

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   Next.js       │    │    Rails API     │    │ Rust Services   │
│   Frontend      │◄──►│  (Business Logic)│◄──►│ (Performance)   │
│  (Mobile-First) │    │                  │    │                 │
└─────────────────┘    └──────────────────┘    └─────────────────┘
                              │                         │
                              ▼                         ▼
                       ┌──────────────┐         ┌─────────────┐
                       │ PostgreSQL   │         │   Redis     │
                       │   + PostGIS  │         │  (Caching)  │
                       └──────────────┘         └─────────────┘
```

---

## 🚀 Quick Start

### Prerequisites
- Docker & Docker Compose
- Node.js 18+ (for local frontend development)
- Ruby 3.2+ (for local Rails development)
- Rust 1.70+ (for local Rust development)

### Development Setup

1. **Clone and enter the project**:
   ```bash
   git clone <repository-url>
   cd food-rescue-platform
   ```

2. **Set up environment variables**:
   ```bash
   cp .env.example .env
   # Edit .env with your configuration
   ```

3. **Start all services**:
   ```bash
   docker-compose up -d
   ```

4. **Initialize the database with demo data**:
   ```bash
   docker-compose exec rails-api rails db:setup
   docker-compose exec rails-api rails db:seed:demo
   ```

5. **Access the application**:
   - Frontend: http://localhost:3100
   - Rails API: http://localhost:3000
   - Location Service: http://localhost:3001
   - Inventory Service: http://localhost:3002
   - Image Processor: http://localhost:3003

---

## 📱 Features

### For Customers
- **Location-based discovery** of nearby merchants
- **Real-time inventory** with automatic updates
- **Smart filtering** by dietary preferences and allergens
- **Bundle deals** for better value
- **Flexible pickup windows** with confirmation codes
- **Order history** and favorite merchants

### For Merchants
- **Quick listing** with camera integration
- **Bundle creation** for multiple items
- **Inventory management** with automatic expiration
- **Order notifications** and status updates
- **Sales analytics** and waste reduction metrics
- **Simple pickup confirmation** system

### Platform Features
- **Mobile-first design** optimized for smartphones
- **Real-time updates** via WebSocket connections
- **PWA support** for app-like experience
- **Offline capability** for core features
- **Secure payments** via Stripe integration
- **SMS notifications** for order updates

---

## 🛠️ Technology Stack

### Backend
- **Rails 7.2+**: API server, authentication, business logic
- **PostgreSQL + PostGIS**: Database with geo-spatial support
- **Redis**: Caching and real-time message passing
- **Sidekiq**: Background job processing

### Rust Microservices
- **Axum**: Fast HTTP framework
- **SQLx**: Async database driver
- **Tokio**: Async runtime
- **Redis**: Caching and pub/sub

### Frontend
- **Next.js 14**: React framework with SSR/SSG
- **TypeScript**: Type-safe development
- **Tailwind CSS**: Utility-first styling
- **Zustand**: Lightweight state management
- **React Query**: Data fetching and caching

### External Services
- **Stripe**: Payment processing
- **Twilio**: SMS notifications
- **AWS S3/Cloudinary**: Image storage and optimization
- **Mapbox**: Maps and location services

---

## 📊 Demo Data

The platform includes comprehensive demo data:
- **6 merchants** across San Francisco neighborhoods
- **10 products** with realistic pricing and descriptions
- **6 bundle combinations** for various scenarios
- **8 customer profiles** with diverse preferences
- **Order history** showing various statuses and flows

See `/demo/README.md` for detailed information about the demo data structure.

---

## 🚀 Development Workflow

### Rails API Development
```bash
# Enter Rails container
docker-compose exec rails-api bash

# Run tests
bundle exec rspec

# Run console
rails console

# Generate migration
rails generate migration AddIndexToProducts

# Run specific migration
rails db:migrate:up VERSION=20231201000000
```

### Rust Services Development
```bash
# Build all Rust services
docker-compose exec location-service cargo build --release

# Run tests
docker-compose exec location-service cargo test

# Check logs
docker-compose logs -f location-service
```

### Frontend Development
```bash
# Enter frontend container
docker-compose exec frontend bash

# Run tests
npm test

# Build for production
npm run build

# Type checking
npm run type-check
```

---

## 📋 Project Status

See [TODOS.md](./TODOS.md) for the complete development roadmap and current progress.

### Current Phase: Foundation Setup ✅
- [x] Project structure created
- [x] Demo data generated
- [x] Docker environment configured
- [ ] Rails API implementation (In Progress)

---

## 🎯 Core User Flows

### Customer Journey
1. **Discover**: Browse nearby merchants by location
2. **Select**: Choose products or bundles with real-time availability
3. **Order**: Quick checkout with pickup time selection
4. **Pickup**: Arrive during window, show confirmation code
5. **Enjoy**: Rate experience and save favorites

### Merchant Journey
1. **List**: Quick photo + description for products
2. **Bundle**: Create value packages for better sales
3. **Manage**: Update quantities and pricing throughout day
4. **Fulfill**: Receive orders, prepare items, confirm pickup
5. **Analyze**: View sales data and waste reduction metrics

---

## 🔒 Security & Privacy

- **Authentication**: JWT tokens with secure refresh mechanism
- **Authorization**: Role-based access control (customers/merchants/admin)
- **Data Protection**: GDPR compliant with data retention policies
- **Payment Security**: PCI DSS compliant via Stripe integration
- **API Security**: Rate limiting, input validation, HTTPS everywhere

---

## 🌍 Environmental Impact

### Food Waste Reduction
- Track items saved from landfills
- Calculate CO2 emissions prevented
- Merchant waste reduction reports
- Community impact metrics

### Sustainability Features
- Promote local commerce
- Reduce transportation needs
- Encourage conscious consumption
- Support small businesses

---

## 🤝 Contributing

1. Check [TODOS.md](./TODOS.md) for current priorities
2. Create feature branch from main
3. Follow existing code conventions
4. Write tests for new features
5. Submit pull request with clear description

### Development Guidelines
- Mobile-first responsive design
- API-first development approach
- Comprehensive testing coverage
- Security best practices
- Performance optimization

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 📞 Support

- **Issues**: Create GitHub issue for bugs or feature requests
- **Documentation**: See `/docs` directory for detailed guides
- **Community**: Join our Discord for development discussions

---

**Let's reduce food waste together! 🌱**