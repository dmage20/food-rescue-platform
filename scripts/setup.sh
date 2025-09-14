#!/bin/bash

# Food Rescue Platform - Development Setup Script
# This script sets up the complete development environment

set -e  # Exit on any error

echo "🥖 Food Rescue Platform - Development Setup"
echo "==========================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header() {
    echo -e "\n${BLUE}=== $1 ===${NC}"
}

# Check if required tools are installed
check_prerequisites() {
    print_header "Checking Prerequisites"

    if ! command -v docker &> /dev/null; then
        print_error "Docker is not installed. Please install Docker Desktop."
        echo "Visit: https://www.docker.com/products/docker-desktop"
        exit 1
    fi
    print_status "Docker is installed ✓"

    if ! command -v docker-compose &> /dev/null; then
        print_error "Docker Compose is not installed."
        exit 1
    fi
    print_status "Docker Compose is installed ✓"

    # Check if ports are available
    if lsof -i :3000 &> /dev/null; then
        print_warning "Port 3000 is in use. Please stop any services running on this port."
    fi

    if lsof -i :3100 &> /dev/null; then
        print_warning "Port 3100 is in use. Please stop any services running on this port."
    fi

    if lsof -i :5432 &> /dev/null; then
        print_warning "Port 5432 is in use. This might conflict with PostgreSQL."
    fi
}

# Set up environment variables
setup_environment() {
    print_header "Setting up Environment Variables"

    if [ ! -f .env ]; then
        print_status "Creating .env file from .env.example"
        cp .env.example .env

        # Generate secure random keys
        print_status "Generating secure random keys..."

        # Generate Rails secret key base (128 characters)
        SECRET_KEY_BASE=$(openssl rand -hex 64)
        sed -i.bak "s/your_secret_key_base_here/$SECRET_KEY_BASE/g" .env

        # Generate JWT secret (64 characters)
        JWT_SECRET=$(openssl rand -hex 32)
        sed -i.bak "s/your_jwt_secret_key/$JWT_SECRET/g" .env

        # Clean up backup file
        rm .env.bak 2>/dev/null || true

        print_status "Environment file created with secure keys"
        print_warning "Please edit .env and add your API keys for external services:"
        print_warning "  - Stripe keys for payments"
        print_warning "  - Twilio credentials for SMS"
        print_warning "  - AWS/Cloudinary for image storage"
        print_warning "  - Mapbox token for maps"
    else
        print_status ".env file already exists"
    fi
}

# Build and start Docker services
start_services() {
    print_header "Building and Starting Services"

    print_status "Building Docker images (this may take a few minutes)..."
    docker-compose build --parallel

    print_status "Starting all services..."
    docker-compose up -d

    print_status "Waiting for services to be ready..."
    sleep 10

    # Wait for PostgreSQL to be ready
    print_status "Waiting for PostgreSQL to be ready..."
    while ! docker-compose exec -T postgres pg_isready -U postgres &> /dev/null; do
        sleep 2
    done

    # Wait for Redis to be ready
    print_status "Waiting for Redis to be ready..."
    while ! docker-compose exec -T redis redis-cli ping &> /dev/null; do
        sleep 2
    done

    print_status "All services are ready ✓"
}

# Set up the Rails application
setup_rails() {
    print_header "Setting up Rails Application"

    print_status "Installing gems..."
    docker-compose exec rails-api bundle install

    print_status "Setting up database..."
    docker-compose exec rails-api rails db:setup

    print_status "Running database migrations..."
    docker-compose exec rails-api rails db:migrate

    print_status "Loading demo data..."
    docker-compose exec rails-api rails db:seed:demo

    print_status "Rails application setup complete ✓"
}

# Set up the frontend
setup_frontend() {
    print_header "Setting up Frontend Application"

    print_status "Installing npm dependencies..."
    docker-compose exec frontend npm install

    print_status "Frontend application setup complete ✓"
}

# Verify installation
verify_setup() {
    print_header "Verifying Installation"

    # Check if Rails API responds
    print_status "Checking Rails API..."
    if curl -f http://localhost:3000/api/health &> /dev/null; then
        print_status "Rails API is responding ✓"
    else
        print_warning "Rails API might not be ready yet. Check logs with: docker-compose logs rails-api"
    fi

    # Check if frontend responds
    print_status "Checking Frontend..."
    if curl -f http://localhost:3100 &> /dev/null; then
        print_status "Frontend is responding ✓"
    else
        print_warning "Frontend might not be ready yet. Check logs with: docker-compose logs frontend"
    fi

    # Show service status
    print_status "Service status:"
    docker-compose ps
}

# Print success message and next steps
print_success() {
    print_header "Setup Complete! 🎉"

    echo -e "${GREEN}"
    echo "Your Food Rescue Platform is now running!"
    echo ""
    echo "🌐 Access your applications:"
    echo "  • Frontend:         http://localhost:3100"
    echo "  • Rails API:        http://localhost:3000"
    echo "  • Location Service: http://localhost:3001"
    echo "  • Inventory Service: http://localhost:3002"
    echo "  • Image Processor:  http://localhost:3003"
    echo ""
    echo "🔧 Useful commands:"
    echo "  • View all logs:     docker-compose logs -f"
    echo "  • Stop services:     docker-compose down"
    echo "  • Restart services:  docker-compose restart"
    echo "  • Rails console:     docker-compose exec rails-api rails console"
    echo "  • Run tests:         docker-compose exec rails-api bundle exec rspec"
    echo ""
    echo "📚 Next steps:"
    echo "  1. Edit .env with your API keys for external services"
    echo "  2. Check TODOS.md for development roadmap"
    echo "  3. Visit the frontend to see the demo data in action"
    echo ""
    echo -e "${NC}"
}

# Handle script interruption
cleanup() {
    print_warning "Setup interrupted. Cleaning up..."
    docker-compose down &> /dev/null || true
    exit 1
}

trap cleanup INT TERM

# Main execution
main() {
    check_prerequisites
    setup_environment
    start_services
    setup_rails
    setup_frontend
    verify_setup
    print_success
}

# Run only if script is executed directly (not sourced)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi