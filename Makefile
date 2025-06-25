# 📦 Inception Project Makefile

NAME = inception
COMPOSE = docker compose
SRC_DIR = srcs
DATA_DIR = $(HOME)/data

# 📂 Ensure persistent data folders (MariaDB & WordPress) exist and have proper permissions
setup_dirs:
	mkdir -p $(DATA_DIR)/mariadb $(DATA_DIR)/wordpress
	@echo "✅ Data directories ready."

# 🔑 Fix permissions for MariaDB and WordPress (999 is mysql, 33 is www-data)
fix_perms:
	sudo chown -R 999:999 $(DATA_DIR)/mariadb
	sudo chown -R 33:33 $(DATA_DIR)/wordpress
	@echo "🔒 Permissions fixed."

# 🔐 SSL certificate auto-generation
ssl:
	@if [ ! -f srcs/requirements/nginx/tools/ssl/cmakario.42.de.crt ]; then \
		echo "🔐 Generating self-signed SSL cert for NGINX..."; \
		mkdir -p srcs/requirements/nginx/tools/ssl/cert; \
		mkdir -p srcs/requirements/nginx/tools/ssl/private; \
		openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
			-keyout srcs/requirements/nginx/tools/ssl/private/cmakario.42.de.key \
			-out srcs/requirements/nginx/tools/ssl/cert/cmakario.42.de.crt \
			-subj "/C=DE/ST=Baden-Wuerttemberg/L=Heilbronn/O=42/OU=student/CN=cmakario.42.de"; \
		echo "✅ SSL certificate created!"; \
	else \
		echo "🔑 SSL certificate already exists, skipping..."; \
	fi

# 🏁 Build & start everything (depends on dirs & perms)
all: ssl setup_dirs fix_perms
	@echo "🚀 Building and starting containers..."
	@$(COMPOSE) -f $(SRC_DIR)/docker-compose.yml -p $(NAME) up --build -d --remove-orphans

# 🧹 Stop and remove everything
clean:
	@$(COMPOSE) -f $(SRC_DIR)/docker-compose.yml -p $(NAME) down

# 💣 Remove everything including volumes
fclean:
	@$(COMPOSE) -f $(SRC_DIR)/docker-compose.yml -p $(NAME) down -v

prune:
	@echo "🧹 Pruning all unused Docker stuff (images, stopped containers, networks, build cache)..."
	@docker system prune -af --volumes
	@echo "✅ Docker system pruned!"

reset_data:
	@echo "💥 Deleting ALL host data for MariaDB and WordPress! (Irreversible!)"
	rm -rf $(DATA_DIR)/mariadb $(DATA_DIR)/wordpress
	@echo "📁 Recreating data directories..."
	mkdir -p $(DATA_DIR)/mariadb $(DATA_DIR)/wordpress
	sudo chown 999:999 $(DATA_DIR)/mariadb
	sudo chown 33:33 $(DATA_DIR)/wordpress
	@echo "✅ Host data wiped and folders ready!"

# 🔁 Full rebuild
re: fclean all
