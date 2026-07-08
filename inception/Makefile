ifneq ($(wildcard srcs/.env),)
    include srcs/.env
else
    $(warning [make] srcs/.env file not found)
endif

MYSQL_USER ?= mysql_user
MYSQL_PASSWORD ?= mysql_pass
MYSQL_DATABASE ?= mysql_db
MYSQL_ROOT_PASSWORD ?= mysql_pass


# ============================================================================ #
#                                VARIABLES                                     #
# ============================================================================ #

NAME         := inception

NGINX        := nginx
WORDPRESS    := wordpress
MARIADB      := mariadb
CONTAINERS   := ${NGINX} ${WORDPRESS} ${MARIADB}

TAG          := 1.0

NGINX_IMG    := ${NGINX}:${TAG}
WP_IMG       := ${WORDPRESS}:${TAG}
MARIADB_IMG  := ${MARIADB}:${TAG}
IMAGES       := ${NGINX_IMG} ${WP_IMG} ${MARIADB_IMG}

COMPOSE_FILE := srcs/docker-compose.yml
COMPOSE      := docker compose -f ${COMPOSE_FILE}

DATA_DIR     := /home/jonnavar/data
DB_DIR       := ${DATA_DIR}/wp_db
WP_DIR       := ${DATA_DIR}/wp_files

DB_VOL       := wp_db
WP_VOL       := wp_files
VOLUMES      := ${DB_VOL} ${WP_VOL}

NETWORK      := inception

# ============================================================================ #
#                                FUNCTIONS                                     #
# ============================================================================ #

define volumes_exist
	$(shell docker volume ls --format "{{.Name}}" | grep -qE "^(${DB_VOL}|${WP_VOL})$$" && echo "yes" || echo "no")
endef

define network_exists
	$(shell docker network ls --format "{{.Name}}" | grep -q "^${1}$$" && echo "yes" || echo "no")
endef

define image_exists
	$(shell docker images --format "{{.Repository}}:{{.Tag}}" | grep -q "^${1}$$" && echo "yes" || echo "no")
endef

define images_exist
	$(shell docker images --format "{{.Repository}}:{{.Tag}}" | grep -qE "^(${NGINX_IMG}|${WP_IMG}|${MARIADB_IMG})$$" && echo "yes" || echo "no")
endef

define container_exists
	$(shell docker ps -a --format "{{.Names}}" | grep -q "^${1}$$" && echo "yes" || echo "no")
endef

define container_running
	$(shell docker ps --format "{{.Names}}" | grep -q "^${1}$$" && echo "yes" || echo "no")
endef

define containers_exist
	$(shell docker ps -a --format "{{.Names}}" | grep -qE "^(${NGINX}|${WORDPRESS}|${MARIADB})$$" && echo "yes" || echo "no")
endef

define containers_running
	$(shell docker ps --format "{{.Names}}" | grep -qE "^(${NGINX}|${WORDPRESS}|${MARIADB})$$" && echo "yes" || echo "no")
endef

# ============================================================================ #
#                                MAIN TARGETS                                  #
# ============================================================================ #

all: ${NAME}

${NAME}: directories build create start

clean:
	@if [ "$(strip $(call containers_exist))" = "yes" ] && [ "$(strip $(call containers_running))" = "no" ]; then \
		make -s rm_containers; \
	else \
		make -s down; \
	fi
	@make -s rm_images

fclean:
	@if [ "$(strip $(call containers_exist))" = "yes" ] && [ "$(strip $(call containers_running))" = "no" ]; then \
		make -s rm_containers; \
	else \
		make -s down; \
	fi
	@make -s rm_vol_content
	@make -s rm_volumes

re: fclean all

help:
	@echo
	@echo "Main commands"
	@echo
	@echo "  make all                - build images and run containers"
	@echo "  make clean              - stop and remove containers"
	@echo "  make fclean             - stop and remove containers, remove volumes and their directories"
	@echo "  make help               - list commands of the project"
	@echo "  make re                 - stop and remove everything, then build images and run containers"
	@echo
	@echo "Volume management"
	@echo
	@echo "  make directories        - create directories for volumes"
	@echo "  make rm_vol_content     - empty volumes of the project"
	@echo "  make rm_volumes         - remove volumes of the project"
	@echo "  make vol                - list all volumes"
	@echo "  make volmnt             - list all mount points"
	@echo
	@echo "Network management"
	@echo
	@echo "  make hostnet            - list listening network interfaces"
	@echo "  make net                - list all networks"
	@echo "  make netips             - show ip addresses of containers"
	@echo "  make port-<container>   - list open ports of <container>"
	@echo
	@echo "Image management"
	@echo
	@echo "  make build              - build images"
	@echo "  make build-<image>      - build <image>"
	@echo "  make img                - list all images"
	@echo "  make rebuild            - build images without checking if they already exist"
	@echo "  make rm_images          - remove images of the project"
	@echo
	@echo "Container management"
	@echo
	@echo "  make create             - create volumes, network, and containers"
	@echo "  make down               - stop and remove containers"
	@echo "  make ps-<container>     - list active processes of <container>"
	@echo "  make restart            - restart containers"
	@echo "  make rm_containers      - remove containers of the project"
	@echo "  make shell-<container>  - open a shell session in <container>"
	@echo "  make start              - run containers in the background"
	@echo "  make status             - list all containers"
	@echo "  make stop               - stop containers"
	@echo "  make up                 - run containers in the background"
	@echo
	@echo "Log management"
	@echo
	@echo "  make log                - follow logs from all containers"
	@echo "  make log-<container>    - follow logs from <container>"
	@echo
	@echo "MariaDB"
	@echo
	@echo "  make login              - login mariadb"
	@echo

# ============================================================================ #
#                               VOLUME MANAGEMENT                              #
# ============================================================================ #

directories:
	@if [ -d "${WP_DIR}" ] && [ -d "${DB_DIR}" ]; then \
		echo "[make] Volume directories ${WP_DIR} and ${DB_DIR} already exist, skipping directory creation"; \
	else \
		@echo "[make] Creating directories of docker volumes"; \
		mkdir -p ${WP_DIR}; \
		mkdir -p ${DB_DIR}; \
		@echo "[make] Assigning ownership of directories"; \
		sudo chown $$USER:$$USER ${DATA_DIR}; \
	fi

rm_volumes:
	@if [ "$(strip $(call volumes_exist))" = "no" ]; then \
		echo "[make] Volumes ${VOLUMES} do not exist, unable to remove"; \
	else \
		echo "[make] Removing docker volumes"; \
		docker volume rm ${VOLUMES} || true; \
	fi

rm_vol_content:
	@if [ "$(strip $(call volumes_exist))" = "no" ]; then \
		echo "[make] Volumes ${VOLUMES} do not exist, unable to remove"; \
	else \
		echo "[make] Deleting content of docker volumes"; \
		make -s build-${NGINX}:${TAG}; \
		docker run --rm -v ${DB_VOL}:/mnt nginx:1.0 sh -c "rm -rf /mnt/* /mnt/.[!.]*" || true; \
		docker run --rm -v ${WP_VOL}:/mnt nginx:1.0 sh -c "rm -rf /mnt/* /mnt/.[!.]*" || true; \
		make -s rm_images; \
	fi

vol:
	@echo "[make] Listing docker volumes"
	docker volume ls

volmnt:
	@echo "[make] Listing mount points"
	docker volume ls -q | xargs -I {} sh -c 'echo "{}: $$(docker volume inspect {} --format={{.Options.device}})"'

# ============================================================================ #
#                               NETWORK MANAGEMENT                             #
# ============================================================================ #

net:
	@echo "[make] Listing all networks"
	docker network ls --no-trunc

hostnet:
	@echo "[make] Listing listening network interfaces"
	sudo netstat -tulpn | grep LISTEN

netips:
	@if [ "$(strip $(call network_exists,${NETWORK}))" = "no" ]; then \
		echo "[make] Network ${NETWORK} does not exist, unable to list container IP addresses"; \
	else \
		echo "[make] Listing container IP addresses"; \
		docker network inspect inception --format='{{range .Containers}}{{.Name}} - {{.IPv4Address}}{{println}}{{end}}'; \
	fi

port-%:
	@if [ "$(strip $(call container_exists,$*))" = "no" ]; then \
		echo "[make] Container $* does not exist, unable to list open ports"; \
	elif [ "$(strip $(call container_running,$*))" = "no" ]; then \
		echo "[make] Container $* is not running, unable to list open ports"; \
	else \
		echo "[make] Listing open ports of container $*"; \
		docker port $*; \
	fi

# ============================================================================ #
#                                IMAGE MANAGEMENT                              #
# ============================================================================ #

build:
	@if [ "$(strip $(call images_exist))" = "yes" ]; then \
		echo "[make] Images ${IMAGES} already exist, skipping build"; \
	else \
		echo "[make] Building docker images: ${IMAGES}"; \
		${COMPOSE} build; \
	fi

build-%:
	@if [ "$(strip $(call image_exists,$(subst :${TAG},,$*):${TAG}))" = "yes" ]; then \
		echo "[make] Image $(subst :${TAG},,$*):${TAG} already exists, skipping build"; \
	else \
		echo "[make] Building docker image $(subst :${TAG},,$*):${TAG}"; \
		${COMPOSE} build $(subst :${TAG},,$*); \
	fi

img:
	@echo "[make] Listing docker images"
	docker image ls -a

rebuild:
	@echo "[make] Building docker images: ${IMAGES}"
	${COMPOSE} build

rm_images:
	@if [ "$(strip $(call images_exist))" = "no" ]; then \
		echo "[make] Images ${IMAGES} do not exist, unable to remove"; \
	else \
		echo "[make] Removing docker images: ${IMAGES}"; \
		docker image rm ${IMAGES} 2>/dev/null || true; \
	fi

# ============================================================================ #
#                              CONTAINER MANAGEMENT                            #
# ============================================================================ #

create:
	@if [ "$(strip $(call containers_exist))" = "yes" ]; then \
		echo "[make] Containers ${CONTAINERS} already exist, skipping creation"; \
	else \
		echo "[make] Creating volumes, network, and containers: ${CONTAINERS}"; \
		${COMPOSE} create; \
	fi

up:
	@if [ "$(strip $(call containers_running))" = "yes" ]; then \
		echo "[make] Containers ${CONTAINERS} are already running, skipping execution"; \
	else \
		echo "[make] Starting containers: ${CONTAINERS}"; \
		${COMPOSE} up -d; \
	fi

start:
	@if [ "$(strip $(call containers_running))" = "yes" ]; then \
		echo "[make] Containers ${CONTAINERS} are already running, skipping execution"; \
	else \
		echo "[make] Starting containers: ${CONTAINERS}"; \
		${COMPOSE} start; \
	fi

stop:
	@if [ "$(strip $(call containers_exist))" = "no" ]; then \
		echo "[make] Containers do not exist, unable to stop"; \
	elif [ "$(strip $(call containers_running))" = "no" ]; then \
		echo "[make] Containers are not running, unable to stop"; \
	else \
		echo "[make] Stopping containers: ${CONTAINERS}"; \
		${COMPOSE} stop; \
	fi

down:
	@if [ "$(strip $(call containers_exist))" = "no" ]; then \
		echo "[make] Containers do not exist, unable to stop"; \
	elif [ "$(strip $(call containers_running))" = "no" ]; then \
		echo "[make] Containers are not running, unable to stop"; \
	else \
		echo "[make] Stopping and removing containers: ${CONTAINERS}"; \
		${COMPOSE} down; \
	fi

restart:
	@if [ "$(strip $(call containers_exist))" = "no" ]; then \
		echo "[make] Containers do not exist, unable to restart"; \
	elif [ "$(strip $(call containers_running))" = "no" ]; then \
		echo "[make] Containers are not running, unable to restart"; \
	else \
		echo "[make] Restarting containers: ${CONTAINERS}"; \
		${COMPOSE} restart; \
	fi

rm_containers:
	@if [ "$(strip $(call containers_exist))" = "no" ]; then \
		echo "[make] Containers ${CONTAINERS} do not exist, unable to remove"; \
	else \
		echo "[make] Removing containers: ${CONTAINERS}"; \
		docker container rm ${CONTAINERS}; \
	fi

status:
	@echo "[make] Listing docker containers"
	docker container ls -a --format "table {{.ID}}\t{{.Names}}\t{{.Image}}\t{{.Ports}}\t{{.Networks}}\t{{.Mounts}}\t{{.State}}\t{{.HealthStatus}}"

ps-%:
	@if [ "$(strip $(call container_exists,$*))" = "no" ]; then \
		echo "[make] Container $* does not exist, unable to list processes"; \
	elif [ "$(strip $(call container_running,$*))" = "no" ]; then \
		echo "[make] Container $* is not running, unable to list processes"; \
	else \
		echo "[make] Listing active processes of container $*"; \
		docker exec -it $* ps aux; \
	fi

shell-%:
	@if [ "$(strip $(call container_exists,$*))" = "no" ]; then \
		echo "[make] Container $* does not exist, unable to open shell session"; \
	elif [ "$(strip $(call container_running,$*))" = "no" ]; then \
		echo "[make] Container $* is not running, unable to open shell session"; \
	else \
		echo "[make] Opening a shell session in container $*"; \
		docker exec -it $* /bin/sh; \
	fi

# ============================================================================ #
#                                 LOG MANAGEMENT                               #
# ============================================================================ #

log:
	@if [ "$(strip $(call containers_exist))" = "no" ]; then \
		echo "[make] Containers do not exist, unable to follow logs"; \
	elif [ "$(strip $(call containers_running))" = "no" ]; then \
		echo "[make] Containers are not running, unable to follow logs"; \
	else \
		echo "[make] Following logs from containers: ${CONTAINERS}"; \
		${COMPOSE} logs -f; \
	fi

log-%:
	@if [ "$(strip $(call container_exists,$*))" = "no" ]; then \
		echo "[make] Container $* does not exist, unable to follow logs"; \
	elif [ "$(strip $(call container_running,$*))" = "no" ]; then \
		echo "[make] Container $* is not running, unable to follow logs"; \
	else \
		echo "[make] Following logs from container: $*"; \
		${COMPOSE} logs -f $*; \
	fi

# ============================================================================ #
#                               DATABASE MANAGEMENT                            #
# ============================================================================ #

login:
	@if [ "$(strip $(call container_exists,${MARIADB}))" = "no" ]; then \
		echo "[make] Container ${MARIADB} does not exist, unable to login in database"; \
	elif [ "$(strip $(call container_running,${MARIADB}))" = "no" ]; then \
		echo "[make] Container ${MARIADB} is not running, unable to login in database"; \
	else \
		echo "[make] Login in database of container ${MARIADB}"; \
		docker exec -it ${MARIADB} mariadb -u ${MYSQL_USER} -p${MYSQL_PASSWORD}; \
	fi


.PHONY: all clean fclean help re \
	directories rm_vol_content rm_volumes vol volmnt \
	hostnet net netips port-% \
        build build-% img rebuild rm_images \
	create down ps-% restart rm_containers shell-% start status stop up \
	log log-% \
	login
