# 📦 Inception Project Makefile

NAME=inception
COMPOSE=docker compose
SRC_DIR=srcs

# Path variables
DATA_DIR := /home/mak/data
MARIADB_DIR := $(DATA_DIR)/mariadb
WORDPRESS_DIR := $(DATA_DIR)/wordpress


# 🧱 Default target: Build & start everything
all: init
	@$(COMPOSE) -f $(SRC_DIR)/docker-compose.yml -p $(NAME) up --build -d --remove-orphans

init:
	@echo "🛠️  Checking data directories..."
	@if [ ! -d "$(MARIADB_DIR)" ]; then \
		echo "📁 Creating $(MARIADB_DIR)"; \
		mkdir -p $(MARIADB_DIR); \
		sudo chown -R 999:999 $(MARIADB_DIR); \
	else \
		echo "✅ $(MARIADB_DIR) already exists"; \
	fi
	@if [ ! -d "$(WORDPRESS_DIR)" ]; then \
		echo "📁 Creating $(WORDPRESS_DIR)"; \
		mkdir -p $(WORDPRESS_DIR); \
		sudo chown -R 33:33 $(WORDPRESS_DIR); \
	else \
		echo "✅ $(WORDPRESS_DIR) already exists"; \
	fi

# 🛠️ Just build (no run)
build:
	@$(COMPOSE) -f $(SRC_DIR)/docker-compose.yml -p $(NAME) build

# 🚀 Start already-built containers
up:
	@$(COMPOSE) -f $(SRC_DIR)/docker-compose.yml -p $(NAME) up -d

# 🛑 Stop and remove containers & networks
clean:
	@$(COMPOSE) -f $(SRC_DIR)/docker-compose.yml -p $(NAME) down

# 💣 Remove containers, networks, volumes
fclean:
	@$(COMPOSE) -f $(SRC_DIR)/docker-compose.yml -p $(NAME) down -v
	sudo rm -rf $(MARIADB_DIR) $(WORDPRESS_DIR)

# 🔁 Full rebuild from scratch
re: fclean all

# 🕵️ Validate and print merged config
config:
	@$(COMPOSE) -f $(SRC_DIR)/docker-compose.yml config

# 🌐 Show network info
network:
	@docker network inspect $(NAME)_inception

# 🧠 Debug: open shell inside main container
inspect:
	@docker exec -it $(NAME) sh

# 📄 Nginx error logs
nginx_logs:
	@docker exec -it nginx cat /var/log/nginx/error.log

# 📄 WordPress PHP error logs
wp_logs:
	@docker exec -it wordpress cat /var/log/php82/error.log

# 📄 Middle container logs (for bonus service)
middle_logs:
	@docker exec -it read-me-from-middle.com cat /var/log/thttpd/thttpd.log

# 🧾 Check local /etc/hosts
hosts:
	@cat /etc/hosts

.PHONY: all build up clean fclean re config network inspect nginx_logs wp_logs middle_logs hosts