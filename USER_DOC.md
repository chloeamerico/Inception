//User documentation This file must explain, in clear and simple
terms, how an end user or administrator can:
◦ Understand what services are provided by the stack.
◦ Start and stop the project.
◦ Access the website and the administration panel.
◦ Locate and manage credentials.
◦ Check that the services are running correctly.


## What services are provided?

The Inception project infrastructure runs three services coordinated via Docker Compose:

    ◦ NGINX : The only entry point to the infrastructure. It acts as a reverse proxy and serves the website via HTTPS (TLSv1.2/1.3) on port 443.

    ◦ WordPress : A fully configured WordPress site running on PHP-FPM, accessible via NGINX. It's link to the database mariadb

    ◦ MariaDB : The database server that stores all WordPress data. It is not directly accessible from outside the Docker network.


## Start and stop the project

When you are at the root directory of the project, you can use the following commands :

    ◦ 'make'  (Build and start all containers)
    ◦ 'make down'   (Stop and remove all containers, networks and volumes)
    ◦ 'make re'     (Rebuild everything from scratch)
    ◦ 'make ps'     (Check the status of running containers)
    ◦ 'make logs'   Check the logs of running containers  

## Access the website and the administration panel

Once the program is running, open the browser and go to:

    Website → https://camerico.42.fr
    Admin acces → https://camerico.42.fr/wp-admin
    
        the login : camerico
        password : /secrets/wp_admin_password

As the SSL certificate is self-signed, your browser will display a security warning. Click “Advanced” and then “Accept the risk and continue” to access to the website.

## Locate and manage credentials

Credentials are stored split across two locations : in the srcs/.env and srcs/secrets/

Since both of them contains sensitive data, they are included in the .gitignore file to keep secrets out of the repository.

srcs/.env ==> General configuration

MYSQL_HOST     |        mariadb     |       Database container hostname
MYSQL_DATABASE  |       wordpress   |       WordPress database name    
MYSQL_USER      |       wpuser      |      Database user for WordPress       

DOMAIN_NAME     |       camerico.42.fr  |       Site domain
WP_TITLE        |       Inception       |       WordPress site title
WP_ADMIN_USER   |       camerico        |       WordPress admin username 
WP_ADMIN_EMAIL  |   admin@example.com   |       WordPress admin email

# 2eme user
WP_USER         |       user42         |    WordPress secondary user
WP_USER_EMAIL   |   user42@example.com  |   Secondary user email

Passwords — `srcs/secrets/`

db_root_password.txt    |       MariaDB root password
db_password.txt         |       Password for wpuser
wp_admin_password.txt   |       WordPress admin password
wp_user_password.txt    |       WordPress secondary user password


## Check that the services are running correctly.


    ◦ After running `make`, verify that all containers are up:

with `make ps` or `docker ps`

    ◦ You can also check the logs of a specific container

docker logs nginx
docker logs wordpress
docker logs mariadb

    ◦ Check the Volumes

`docker volume ls`

    You should see:
        - srcs_wordpress
        - srcs_db

    ◦ Check the site is accessible

Open a browser inside the VM and go to: https://camerico.42.fr

