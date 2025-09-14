# Food Rescue Platform - Development Makefile
# Manages application services (excludes local database)

.PHONY: help start stop restart status logs clean test build setup install

# Default target
help:
	@echo "🥖 Food Rescue Platform - Development Commands"
	@echo ""
	@echo "Usage: make [target]"
	@echo ""
	@echo "Application Management:"
	@echo "  start          Start all application services"
	@echo "  stop           Stop all application services"
	@echo "  restart        Restart all application services"
	@echo "  status         Show status of all services"
	@echo ""
	@echo "Development:"
	@echo "  setup          Initial setup (install dependencies, setup DB)"
	@echo "  install        Install dependencies for all services"
	@echo "  build          Build all services"
	@echo "  test           Run all tests"
	@echo ""
	@echo "Database:"
	@echo "  db-setup       Setup database (migrate and seed)"
	@echo "  db-reset       Reset database (drop, create, migrate, seed)"
	@echo "  db-seed        Seed database with demo data"
	@echo ""
	@echo "Logs & Monitoring:"
	@echo "  logs           Show logs from all services"
	@echo "  logs-rails     Show Rails API logs"
	@echo "  logs-frontend  Show Frontend logs"
	@echo ""
	@echo "Cleanup:"
	@echo "  clean          Clean build artifacts and stop services"
	@echo ""
	@echo "Note: Local PostgreSQL database must be running independently"
	@echo "      Start with: brew services start postgresql"

# Variables
RAILS_DIR := rails-api
FRONTEND_DIR := frontend
RAILS_PID_FILE := tmp/pids/rails.pid
FRONTEND_PID_FILE := tmp/pids/frontend.pid

# Colors for output
GREEN := \033[0;32m
YELLOW := \033[0;33m
RED := \033[0;31m
NC := \033[0m # No Color

# Create tmp/pids directory if it doesn't exist
$(shell mkdir -p tmp/pids)

# Start all application services
start: check-db
	@echo "$(GREEN)🚀 Starting Food Rescue Platform services...$(NC)"
	@$(MAKE) start-rails &
	@$(MAKE) start-frontend &
	@sleep 3
	@echo "$(GREEN)✅ All services started successfully!$(NC)"
	@echo ""
	@echo "Services running at:"
	@echo "  📡 Rails API:  http://localhost:3000"
	@echo "  🌐 Frontend:   http://localhost:3100"
	@echo ""
	@echo "Use 'make logs' to view logs or 'make status' to check service status"

# Start Rails API in background
start-rails:
	@echo "$(YELLOW)Starting Rails API...$(NC)"
	@cd $(RAILS_DIR) && \
		bundle install --quiet && \
		rails server -p 3000 -d -P ../tmp/pids/rails.pid
	@echo "$(GREEN)✅ Rails API started on port 3000$(NC)"

# Start Frontend in background
start-frontend:
	@echo "$(YELLOW)Starting Frontend...$(NC)"
	@cd $(FRONTEND_DIR) && \
		npm install --silent && \
		npm run dev &
	@echo $$! > tmp/pids/frontend.pid
	@echo "$(GREEN)✅ Frontend started on port 3100$(NC)"

# Stop all application services
stop:
	@echo "$(YELLOW)🛑 Stopping Food Rescue Platform services...$(NC)"
	@$(MAKE) stop-rails
	@$(MAKE) stop-frontend
	@echo "$(GREEN)✅ All services stopped$(NC)"

# Stop Rails API
stop-rails:
	@if [ -f $(RAILS_PID_FILE) ]; then \
		echo "$(YELLOW)Stopping Rails API...$(NC)"; \
		kill `cat $(RAILS_PID_FILE)` && rm $(RAILS_PID_FILE); \
		echo "$(GREEN)✅ Rails API stopped$(NC)"; \
	else \
		echo "$(YELLOW)Rails API not running$(NC)"; \
	fi

# Stop Frontend
stop-frontend:
	@if [ -f $(FRONTEND_PID_FILE) ]; then \
		echo "$(YELLOW)Stopping Frontend...$(NC)"; \
		kill `cat $(FRONTEND_PID_FILE)` && rm $(FRONTEND_PID_FILE); \
		echo "$(GREEN)✅ Frontend stopped$(NC)"; \
	else \
		echo "$(YELLOW)Frontend not running$(NC)"; \
	fi
	@pkill -f "next dev" || true

# Restart services
restart: stop start

# Check service status
status:
	@echo "$(GREEN)📊 Service Status:$(NC)"
	@echo ""
	@if [ -f $(RAILS_PID_FILE) ] && kill -0 `cat $(RAILS_PID_FILE)` 2>/dev/null; then \
		echo "$(GREEN)✅ Rails API: Running (PID: `cat $(RAILS_PID_FILE)`)$(NC)"; \
	else \
		echo "$(RED)❌ Rails API: Not running$(NC)"; \
	fi
	@if [ -f $(FRONTEND_PID_FILE) ] && kill -0 `cat $(FRONTEND_PID_FILE)` 2>/dev/null; then \
		echo "$(GREEN)✅ Frontend: Running (PID: `cat $(FRONTEND_PID_FILE)`)$(NC)"; \
	else \
		echo "$(RED)❌ Frontend: Not running$(NC)"; \
	fi
	@echo ""
	@echo "Database status:"
	@if pg_isready >/dev/null 2>&1; then \
		echo "$(GREEN)✅ PostgreSQL: Running$(NC)"; \
	else \
		echo "$(RED)❌ PostgreSQL: Not running$(NC)"; \
		echo "$(YELLOW)   Start with: brew services start postgresql$(NC)"; \
	fi

# Check if database is running
check-db:
	@if ! pg_isready >/dev/null 2>&1; then \
		echo "$(RED)❌ PostgreSQL is not running!$(NC)"; \
		echo "$(YELLOW)Please start PostgreSQL first:$(NC)"; \
		echo "  brew services start postgresql"; \
		echo ""; \
		exit 1; \
	fi

# Initial project setup
setup: check-db install db-setup
	@echo "$(GREEN)🎉 Food Rescue Platform setup complete!$(NC)"
	@echo ""
	@echo "Next steps:"
	@echo "  make start    # Start all services"
	@echo "  make test     # Run tests"

# Install dependencies
install:
	@echo "$(YELLOW)📦 Installing dependencies...$(NC)"
	@echo "Installing Rails dependencies..."
	@cd $(RAILS_DIR) && bundle install
	@echo "Installing Frontend dependencies..."
	@cd $(FRONTEND_DIR) && npm install
	@echo "$(GREEN)✅ Dependencies installed$(NC)"

# Build all services
build:
	@echo "$(YELLOW)🔨 Building all services...$(NC)"
	@echo "Building Rails API..."
	@cd $(RAILS_DIR) && bundle install
	@echo "Building Frontend..."
	@cd $(FRONTEND_DIR) && npm run build
	@echo "$(GREEN)✅ Build complete$(NC)"

# Database setup
db-setup: check-db
	@echo "$(YELLOW)🗄️  Setting up database...$(NC)"
	@cd $(RAILS_DIR) && \
		rails db:create db:migrate db:seed
	@echo "$(GREEN)✅ Database setup complete$(NC)"

# Database reset
db-reset: check-db
	@echo "$(YELLOW)🔄 Resetting database...$(NC)"
	@cd $(RAILS_DIR) && \
		rails db:drop db:create db:migrate db:seed
	@echo "$(GREEN)✅ Database reset complete$(NC)"

# Seed database
db-seed: check-db
	@echo "$(YELLOW)🌱 Seeding database...$(NC)"
	@cd $(RAILS_DIR) && rails db:seed
	@echo "$(GREEN)✅ Database seeded$(NC)"

# Run all tests
test:
	@echo "$(YELLOW)🧪 Running all tests...$(NC)"
	@echo ""
	@echo "Running Rails tests..."
	@cd $(RAILS_DIR) && bundle exec rspec
	@echo ""
	@echo "Running Frontend tests..."
	@cd $(FRONTEND_DIR) && npm test
	@echo ""
	@echo "$(GREEN)✅ All tests completed$(NC)"

# Show logs from all services
logs:
	@echo "$(GREEN)📋 Service Logs:$(NC)"
	@echo ""
	@echo "$(YELLOW)Rails API Logs:$(NC)"
	@tail -n 20 $(RAILS_DIR)/log/development.log 2>/dev/null || echo "No Rails logs found"
	@echo ""
	@echo "$(YELLOW)Frontend Logs:$(NC)"
	@echo "Check terminal where 'make start' was run for frontend logs"

# Show Rails logs
logs-rails:
	@echo "$(GREEN)📋 Rails API Logs:$(NC)"
	@tail -f $(RAILS_DIR)/log/development.log

# Show Frontend logs
logs-frontend:
	@echo "$(GREEN)📋 Frontend Logs:$(NC)"
	@echo "Frontend logs are displayed in the terminal where services were started"
	@echo "Use 'make start' to see live logs"

# Clean up
clean: stop
	@echo "$(YELLOW)🧹 Cleaning up...$(NC)"
	@rm -f tmp/pids/*.pid
	@cd $(RAILS_DIR) && rm -rf tmp/cache/* log/*.log
	@cd $(FRONTEND_DIR) && rm -rf .next node_modules/.cache
	@echo "$(GREEN)✅ Cleanup complete$(NC)"

# Development helpers
dev-rails:
	@echo "$(GREEN)🚀 Starting Rails in development mode...$(NC)"
	@cd $(RAILS_DIR) && bundle exec rails server

dev-frontend:
	@echo "$(GREEN)🚀 Starting Frontend in development mode...$(NC)"
	@cd $(FRONTEND_DIR) && npm run dev

dev-console:
	@echo "$(GREEN)💻 Opening Rails console...$(NC)"
	@cd $(RAILS_DIR) && bundle exec rails console