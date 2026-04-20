*This project has been created as part of the 42 curriculum by camerico.*

## Description

 qui présente clairement le projet, y compris son objectif et un
bref aperçu.

## Instructions

toutes les informations pertinentes sur la compilation, l'
installation et/ou l'exécution.

## Resources

répertoriant les références classiques liées au sujet (documentation,
articles, tutoriels, etc.), ainsi qu'une description de la manière dont l'IA a été utilisée, en
précisant pour quelles tâches et quelles parties du projet.

## Project description

 expliquer l'utilisation de Docker et les sources
incluses dans le projet. Elle doit indiquer les principaux choix de conception, ainsi qu'une
comparaison entre :
◦ Machines virtuelles vs Docker
◦ Secrets vs variables d'environnement
◦ Réseau Docker vs réseau hôte
◦ Volumes Docker vs montages liés


Inception

## Description

Inception is a project involves deploying a complete web infrastructure using Docker Compose to manually building three containers (services): 
    
    ◦ NGINX : a web server that acts as the only entry point to the infrastructure, accessible via HTTPS on port 443 using TLS 1.2 or 1.3.
              It's used as a reverse proxy

    ◦ WordPress : a content management system running with PHP-FPM, connected to the database

    ◦ MariaDB : a database that stores all the wordPress data


Each service runs in its own dedicated container built from a Debian base image. Each container communicates with the others via a private Docker bridge network (called “inception”; see the docker-compose.yml file). Data is persisted on the host machine using volumes (check volumes with "docker volume ls" ), so it survives container restarts.

The project is built without using any pre-made Docker images for the services (only the base Debian image). Each Dockerfile is written from scratch, installing and configuring the service manually.

For sensitive data such as passwords, they are managed using Docker secrets rather than simple environment variables.
This ensures that passwords do not appear in the .env file, providing additional security.

Virtual machines emulate a full operating system with their own kernel, which makes them heavier and slower to start. Docker containers share the host kernel and only isolate the processes, which makes them much lighter and faster. For this project, Docker is a better fit because the goal is to run isolated services efficiently, not to emulate full operating systems.



## Project description

*VMs vs Docker*

A VM simulates an entire computer with its own operating system, which makes it resource-intensive and slow to start up. Docker shares the host machine’s kernel, so containers are much lighter (a few MB vs. several GB) and start up in just a few seconds

*Secrets vs Environment Variables*

Secrets vs. Environment Variables — Environment variables are useful but risky: they are visible in clear via `docker inspect [container]`. Docker secrets are mounted in memory (/run/secrets/) and are accessible only to the container in question, which is much more secure for passwords

*Docker Network vs Host Network*
Docker Network vs Host Network — With a Docker bridge network, each container has its own isolated network interface and communicates only through explicitly exposed ports. Host mode removes this isolation: the container directly shares the host machine’s network stack, which is more efficient but significantly less secure.

*Docker Volumes vs Bind Mounts*

In the case of a Docker volume, the source is the Docker volume (e.g., srcs_wordpress in srcs_wordpress:/var/www/html). This volume is managed entirely by Docker.
The advantages:
- Portable: works on any machine
- Persists after a `docker stop`, `docker restart`, or `make re`
- You can cleanly remove it with `docker volume rm` or `docker volume down -v`



## Instructions

*Requirements*

    ◦  Docker installed

    ◦  sudo access

    ◦  The domain camerico.42.fr must point to 127.0.0.1 in /etc/hosts

    ◦  VirtualBox 7.0 (tested with 7.0.26)


*Setup and run*

    ◦  Open the VM on virtual box,
    ◦  Clone the repository (git clone)
    ◦  If necessary, add the domain to `/etc/hosts`
            with echo "127.0.0.1 camerico.42.fr" | sudo tee -a /etc/hosts
    ◦  make 

This will create the required data directories, build the Docker images, and start the containers. The site will be accessible at:

https://camerico.42.fr

*Available commands*

bash
make          # build and start everything
make down     # stop and remove containers
make stop     # pause containers without removing them
make start    # restart paused containers
make re       # full rebuild from scratch (removes all data)
make logs     # follow container logs
make ps       # show running containers


*Notes*

The TLS certificate is self-signed, so Firefox will show a security warning. TYou should click on "Advanced" to  visit the website.


## Resources

Docker documentation

https://docs.docker.com/

https://youtu.be/mspEJzb8LC4?si=P8SsbaB-mDyhOqUx

https://youtu.be/ES4BcZcsBdU?si=L_nnCsxAcOQA4ihw



*Use of AI*

AI (Claude via Perplexity) was used during this project for the following tasks:

    ◦  Debugging configuration issues, in particular the MariaDB connection errors during WordPress initialization

    ◦  Understanding how PHP-FPM and nginx communicate via FastCGI

    ◦  To clarify some Docker concepts and better understand how to use the commands found in the script



