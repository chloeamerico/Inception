NAME = inception

.DEFAULT_GOAL := all


# Docker Compose
ENV_FILE = ./srcs/.env
COMPOSE_FILE = ./srcs/docker-compose.yml
DOCKER_COMPOSE = docker compose --env-file $(ENV_FILE) -f $(COMPOSE_FILE)

COMPOSE = docker compose -f srcs/docker-compose.yml

LOGIN ?= $(shell id -un)
DATA_DIR = /home/$(LOGIN)/data

prepare:
	@mkdir -p $(DATA_DIR)/wordpress $(DATA_DIR)/mariadb

all: up

build: prepare
	@echo "$(GREEN)Building containers...$(RESET)"
	$(DOCKER_COMPOSE) build


up:	build
	$(DOCKER_COMPOSE) up -d

#	ca arrete les conteneurs sans les supprimer
stop:
	$(COMPOSE) stop

#	redemarre des conteneurs deje existants qui sont arretes
#	attention : ca ne rebuild pas, ne recre pas, ca relance juste ce qui existe deja
start:
	$(COMPOSE) start


restart: stop start


clean: down
	@echo "$(RED)Removing containers, networks, and volumes...$(RESET)"
	$(DOCKER_COMPOSE) down -v --rmi all --remove-orphans


fclean: clean
	@docker system prune -a -f --volumes
	@sudo rm -rf $(DATA_DIR)/db $(DATA_DIR)/wordpress
	@mkdir -p $(DATA_DIR)/db $(DATA_DIR)/wordpress

down:
	$(DOCKER_COMPOSE) down

re: fclean all

logs:
	$(DOCKER_COMPOSE) logs

ps:
	$(DOCKER_COMPOSE) ps

config:
	$(DOCKER_COMPOSE) config

status: ps

.PHONY: all prepare build up down stop start restart clean fclean re logs ps config status
