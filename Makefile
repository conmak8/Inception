# 📦 Inception Project Makefile

NAME=inception
COMPOSE=docker compose
SRC_DIR=srcs

# 🧱 Default target: Build & start everything
all: init
	@echo "🚀 Starting Docker Compose build..."
	@$(COMPOSE) -f $(SRC_DIR)/docker-compose.yml -p $(NAME) up --build -d --remove-orphans

init:
	@if [ -f .setup_done ]; then \
		echo "✅ Setup already done. Skipping..."; \
	else \
		echo "🔧 Running setup script..."; \
		if [ -x ./startScript/setup_advanced.sh ]; then \
			./startScript/setup_advanced.sh && touch .setup_done; \
		else \
			echo '⚠️  setup_advanced.sh not found or not executable!'; \
		fi \
	fi

# 🛠️ Just build (no run)
build: init
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
	@echo "🧹 Removing local DB/data folders..."
	@sudo rm -rf $${HOME}/data/mariadb $${HOME}/data/wordpress
	@rm -f .setup_done


	# @sudo rm -rf /home/mak/data/mariadb /home/mak/data/wordpress

# 🧹 Super clean: remove containers, volumes, and images
sclean:
	@echo "💥 Nuking containers, volumes, and images..."
	@$(COMPOSE) -f $(SRC_DIR)/docker-compose.yml -p $(NAME) down -v --rmi all --remove-orphans
	@echo "🧹 Removing local DB/data folders..."
	@sudo rm -rf $${HOME}/data/mariadb $${HOME}/data/wordpress
	@rm -f .setup_done

	# @sudo rm -rf /home/mak/data/mariadb /home/mak/data/wordpress 

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


# simple implementation
# setup_dirs:
# 	@echo "📂 Creating persistent data folders if needed..."
# 	@mkdir -p $${HOME}/data/mariadb $${HOME}/data/wordpress

# all: setup_dirs init
# 	@echo "🚀 Starting Docker Compose build..."
# 	@$(COMPOSE) -f $(SRC_DIR)/docker-compose.yml -p $(NAME) up --build -d --remove-orphans
