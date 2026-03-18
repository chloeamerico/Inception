#!/bin/bash
set -e

# on recup les 3 secrets / mdp
export MYSQL_PASSWORD="$(cat /run/secrets/db_password)"
export WP_ADMIN_PASSWORD="$(cat /run/secrets/wp_admin_password)"
export WP_USER_PASSWORD="$(cat /run/secrets/wp_user_password)"

#   on cree le dossier pour stocker le certificat SSL s'il n'existe pas encore.
mkdir -p /etc/nginx/ssl

#   on genere un certificat SSL autosigne (-x509) , valable 365 jours avec une cle RSA 2048 bits
#   Certificat SSL ->  chiffrer la connexion navigateur <=> serveur
#   NGINX utilise la cle privée (inception.key) et le certificat (inception.crt) pr activer le https
#   securise l’acces a NGINX sur le port 443

openssl req -x509 -nodes -days 365 \
    -newkey rsa:2048 \
    -keyout /etc/nginx/ssl/inception.key \
    -out /etc/nginx/ssl/inception.crt \ 
    -subj "/C=FR/ST=IDF/L=Paris/O=42/OU=42/CN=${DOMAIN_NAME}"

#   on demarre nginx comme processus principal,(PID 1)
#   "daemon off" = pas en arriere plan 
#   on remplace remplace ${DOMAIN_NAME} par le vrai nom de domaine car NGINX ne le remplace pas tout seul

sed "s|\${DOMAIN_NAME}|${DOMAIN_NAME}|g" /etc/nginx/nginx.conf > /tmp/nginx.conf
exec nginx -c /tmp/nginx.conf -g "daemon off;"
