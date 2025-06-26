all:
	@docker-compose -f srcs/docker-compose.yml up --build -d

down:
	@docker-compose -f srcs/docker-compose.yml down

clean:
	@docker-compose -f srcs/docker-compose.yml down -v --rmi all
	@docker system prune -af

re: clean all

.PHONY: all down clean re