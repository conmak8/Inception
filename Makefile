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

# 🏁 Build & start everything (depends on dirs & perms)
all: setup_dirs fix_perms
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
