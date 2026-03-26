#!/bin/bash
set -eu

#on recuper les mdp
export MYSQL_PASSWORD="$(cat /run/secrets/db_password)"
export WP_ADMIN_PASSWORD="$(cat /run/secrets/wp_admin_password)"
export WP_USER_PASSWORD="$(cat /run/secrets/wp_user_password)"

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

cd /var/www/html

# ÉTAPE CRUCIALE : Attendre que MariaDB soit prêt ET accepte l'utilisateur
# On redirige les erreurs vers /dev/null pour ne pas polluer les logs avec l'erreur 1130 pendant l'attente
echo "Attente de MariaDB (${MYSQL_HOST})..."
until mysqladmin ping -h"${MYSQL_HOST}" -u"${MYSQL_USER}" -p"${MYSQL_PASSWORD}" --silent > /dev/null 2>&1; do
    sleep 2
done
echo "MariaDB est prêt !"

# si premier lancement --> on installe et configure Wordpress
if [ ! -f /var/www/html/wp-config.php ]; then

    # on y telecharge les fichiers du coeur WordPress
	wp core download --allow-root --force

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

	# chown pour changer le propriétaire et/ou le groupe
	chown -R www-data:www-data /var/www/html
fi

echo "WordPress est prêt à servir des requêtes."

# lance PHP-FPM en avant-plan
exec /usr/sbin/php-fpm7.4 -F