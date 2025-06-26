all:
	cd srcs && docker-compose up -d

down:
	cd srcs && docker-compose down

clean:
	cd srcs && docker-compose down -v
	docker system prune -af

re: clean all

.PHONY: all down clean re