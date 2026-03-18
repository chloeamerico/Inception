COMPOSE = docker compose -f srcs/docker-compose.yml

#	s'execute quand on fait make
#	cree les 2 dossiers necessaires (que si ils n'existent pas -p)
#	--build rebuild les images si necessaire avant de lancer les conteneurs
all:
	mkdir -p /home/camerico/data/db /home/camerico/data/wordpress
	$(COMPOSE) up -d --build

up:
	mkdir -p /home/camerico/data/db /home/camerico/data/wordpress
	$(COMPOSE) up -d --build

#	pour arreter le projet
down:
	$(COMPOSE) down

#	redemarre des conteneurs deje existants qui sont arretes
#	attention : ca ne rebuild pas, ne recre pas, ca relance juste ce qui existe deja
start:
	$(COMPOSE) start

#	ca arrete les conteneurs sans les supprimer
stop:
	$(COMPOSE) stop

restart: stop start

#	affiche les logs de tous les services, (WordPress, MariaDB, NGINX),  utile pour voir ce qui crash
logs:
	$(COMPOSE) logs

#	affiche l’etat des conteneurs : en cours d’execution, arretes, port expose, etc...
ps:
	$(COMPOSE) ps

#	supprime les conteneurs , volumes utilises par Compose (-v), 
clean:
	$(COMPOSE) down -v

#	supprime conteneurs, volumes, images Docker construites pour le projet (--rmi all)
fclean:
	$(COMPOSE) down -v --rmi all

#	comme restart mais plus fort
#	make re = reset complet du projet
re: fclean all

.PHONY: all up down start stop restart logs ps clean fclean re