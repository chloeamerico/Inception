#!/bin/bash
set -e

# dossier où seront stockes les fichiers runtime de PHP-FPM(php) puis WordPress (html)
mkdir -p /run/php
mkdir -p /var/www/html


# telecharger WP-CLI que si il n'existe pas deja dans le conteneur
# WP-CLI = WordPress Command Line Interface --> outil pr piloter WordPress via terminal au lieu de passer par l’interface web d’administration
if [ ! -f /usr/local/bin/wp ]; then
	curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
	chmod +x wp-cli.phar
	mv wp-cli.phar /usr/local/bin/wp
fi

chown -R www-data:www-data /var/www/html

# essaye en boucle jusqu'a ce que Mariadb reponde avec les identifiants
until mysqladmin ping -h"${MYSQL_HOST}" -u"${MYSQL_USER}" -p"${MYSQL_PASSWORD}" --silent; do
	sleep 2
done

# si premier lancement --> on installe et configure Wordpress
if [ ! -f /var/www/html/wp-config.php ]; then
	
    # /var/www/html = dossier du site WordPress
    cd /var/www/html

    # on y telecharge les fichiers du coeur WordPress
	wp core download --allow-root

    # on cree le fichier ​qui contient les infos de connexion a la base de donnees
	wp config create \
		--allow-root \
		--dbname="${MYSQL_DATABASE}" \
		--dbuser="${MYSQL_USER}" \
		--dbpass="${MYSQL_PASSWORD}" \
		--dbhost="${MYSQL_HOST}" \
		--path='/var/www/html'

    # installation du site WP
	wp core install \
		--allow-root \
		--url="${DOMAIN_NAME}" \
		--title="${WP_TITLE}" \
		--admin_user="${WP_ADMIN_USER}" \
		--admin_password="${WP_ADMIN_PASSWORD}" \
		--admin_email="${WP_ADMIN_EMAIL}" \
		--skip-email

    # creation du second utilisateur ( comme demande dans le sujet), on lui donne le role d'auteur
	wp user create "${WP_USER}" "${WP_USER_EMAIL}" \
		--allow-root \
		--user_pass="${WP_USER_PASSWORD}" \
		--role=author

	chown -R www-data:www-data /var/www/html
fi

# lance PHP-FPM en avant-plan
exec /usr/sbin/php-fpm7.4 -F