//Developer documentation This file must describe how a devel-
oper can:
◦ Set up the environment from scratch (prerequisites, configuration files, se-
crets).
◦ Build and launch the project using the Makefile and Docker Compose.
◦ Use relevant commands to manage the containers and volumes.
◦ Identify where the project data is stored and how it persists

pour voir la base de donnees :
1- on entre dans le conteneur mariadb :
        ◦ docker exec -it mariadb bash

2- On connecte root a la db
        ◦ mariadb -u root -p -h 127.0.0.1

(3)- affiche tous les utilisateurs de MariaDB et depuis quel hote ils peuvent se connecter
        ◦ SELECT user, host FROM mysql.user;

(4)- liste toutes les bases de donnees qui existent
        ◦ SHOW DATABASES;

5- selectionne la base de donnees wordpress pour travailler dedans
        ◦ USE wordpress

6- liste toutes les tables de la db
        ◦ SHOW TABLES

7- ex : pour voir combien il y a d'utilisateurs :
        ◦ SELECT COUNT(*) FROM wp_users;


pour changer de port :
une fois qu'on a change dans le .yml et .conf, pour rendre le site accessible en 8443 :

docker exec -it wordpress bash
wp option update siteurl 'https://camerico.42.fr:8443' --allow-root --path=/var/www/html
wp option update home 'https://camerico.42.fr:8443' --allow-root --path=/var/www/html

puis pour le remettre en 443:

wp option update siteurl 'https://camerico.42.fr' --allow-root --path=/var/www/html
wp option update home 'https://camerico.42.fr' --allow-root --path=/var/www/html