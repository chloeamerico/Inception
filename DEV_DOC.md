//Developer documentation This file must describe how a devel-
oper can:
◦ Set up the environment from scratch (prerequisites, configuration files, se-
crets).
◦ Build and launch the project using the Makefile and Docker Compose.
◦ Use relevant commands to manage the containers and volumes.
◦ Identify where the project data is stored and how it persists





## Set up the environment from scratch


*Prerequisites*

    ◦ VirtualBox 7.0 (tested with 7.0.26)
    ◦ Docker installed inside the VM
    ◦ sudo access
    ◦ Git


*Setup and run*

    ◦  Open the VM on virtual box,
    ◦  Clone the repository (git clone)
    ◦  If necessary, add the domain to `/etc/hosts`
            with echo "127.0.0.1 camerico.42.fr" | sudo tee -a /etc/hosts
    ◦  make 


*configuration files*

Sensitive data is split across two locations, both ignored by git: in the srcs/.env and srcs/secrets/


## Build and launch the project using the Makefile and Docker Compose

        make

This will:
1. Create the required data directories on the host (/home/camerico/data/)
2. Build the Docker images from the Dockerfiles
3. Start all three containers via Docker Compose

The site will be available at: https://camerico.42.fr

When you are at the root directory of the project, you can use the following commands :

    ◦ 'make'  (Build and start all containers)
    ◦ 'make down'   (Stop and remove all containers, networks and volumes)
    ◦ 'make re'     (Rebuild everything from scratch)
    ◦ 'make ps'     (Check the status of running containers)
    ◦ 'make logs'   Check the logs of running containers 


## Use relevant commands to manage the containers and volumes.


*Check Running Containers*

`docker ps`

Expected output : 3 containers running:
        - nginx ==> Reverse proxy, HTTPS entry point (port 443)
        - wordpress ==> PHP-FPM application server
        - mariadb ==> Database


*View Logs of each container*

docker logs nginx
docker logs wordpress
docker logs mariadb


## Data Storage and Persistence

*Where data lives*

All persistent data is stored on the host machine at:
/home/camerico/data/

*Docker Volumes*

`docker volume ls`
srcs_wordpress
srcs_db

*Check if data persists after*

`docker stop` / `docker start`
==> Container restarts

Data is deleted only if we run:
sudo rm -rf /home/camerico/data/


## Database Access


to view the database :
1- We enter the mariadb container :
        ◦ docker exec -it mariadb bash

2- Connect as root to the database
        ◦ mariadb -u root -p -h 127.0.0.1

(3)- displays all MariaDB users and the hosts from which they can connect
        ◦ SELECT user, host FROM mysql.user;

(4)- lists all existing databases
        ◦ SHOW DATABASES;

5- Select the WordPress database to work with
        ◦ USE wordpress

6- list all tables in the database
        ◦ SHOW TABLES

7- ex : to see how many users there are:
        ◦ SELECT COUNT(*) FROM wp_users;


## to change ports :

Once you've made the changes in the .yml and .conf files to make the site accessible on port 8443:

docker exec -it wordpress bash
wp option update siteurl 'https://camerico.42.fr:8443' --allow-root --path=/var/www/html
wp option update home 'https://camerico.42.fr:8443' --allow-root --path=/var/www/html

and then set it back to 443:

wp option update siteurl 'https://camerico.42.fr' --allow-root --path=/var/www/html
wp option update home 'https://camerico.42.fr' --allow-root --path=/var/www/html