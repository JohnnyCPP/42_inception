NAME = inception


all: ${NAME}

${NAME}:
	mkdir -p /home/jonnavar/data/wp_files
	mkdir -p /home/jonnavar/data/wp_db
	docker compose -f srcs/docker-compose.yml build
	docker compose -f srcs/docker-compose.yml up -d

clean:
	docker compose -f srcs/docker-compose.yml down

fclean: clean
	docker system prune -af
	rm -rf /home/jonnavar/data

re: fclean all


.PHONY: all clean fclean re
