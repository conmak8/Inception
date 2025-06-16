# 📦 Inception Project Makefile

NAME=inception
COMPOSE=docker compose
SRC_DIR=srcs

# 🧱 Default target: Build & start everything
all:
	@$(COMPOSE) -f $(SRC_DIR)/docker-compose.yml -p $(NAME) up --build -d --remove-orphans

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