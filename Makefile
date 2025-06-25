NAME = inception
COMPOSE_FILE = srcs/docker-compose.yml
DATA_DIR = $(HOME)/data

.PHONY: all build up down clean fclean re ssl setup_dirs

# Create necessary directories
setup_dirs:
	@echo "📁 Creating data directories..."
	@mkdir -p $(DATA_DIR)/mariadb $(DATA_DIR)/wordpress
	@sudo chown -R 999:999 $(DATA_DIR)/mariadb
	@sudo chown -R 33:33 $(DATA_DIR)/wordpress
	@echo "✅ Directories ready!"

# Generate SSL certificates
ssl:
	@echo "🔐 Generating SSL certificates..."
	@mkdir -p srcs/requirements/nginx/tools/ssl/cert
	@mkdir -p srcs/requirements/nginx/tools/ssl/private
	@openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
		-keyout srcs/requirements/nginx/tools/ssl/private/cmakario.42.de.key \
		-out srcs/requirements/nginx/tools/ssl/cert/cmakario.42.de.crt \
		-subj "/C=DE/ST=Baden-Wuerttemberg/L=Heilbronn/O=42/OU=student/CN=cmakario.42.de"
	@echo "✅ SSL certificates generated!"

# Build all services
build: setup_dirs ssl
	@echo "🔨 Building services..."
	@docker compose -f $(COMPOSE_FILE) build

# Start all services
up: build
	@echo "🚀 Starting services..."
	@docker compose -f $(COMPOSE_FILE) up -d

# Stop services
down:
	@echo "⏹️ Stopping services..."
	@docker compose -f $(COMPOSE_FILE) down

# Clean containers and networks
clean: down
	@echo "🧹 Cleaning up..."
	@docker compose -f $(COMPOSE_FILE) down -v --remove-orphans
	@docker system prune -f

# Full cleanup including data
fclean: clean
	@echo "💥 Full cleanup..."
	@sudo rm -rf $(DATA_DIR)
	@docker system prune -af --volumes

# Rebuild everything
re: fclean all

# Default target
all: up

# Show logs
logs:
	@docker compose -f $(COMPOSE_FILE) logs -f

# Check status
status:
	@docker compose -f $(COMPOSE_FILE) ps