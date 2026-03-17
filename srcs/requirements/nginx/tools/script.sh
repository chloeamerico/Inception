#!/bin/bash
set -e

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

exec nginx -g "daemon off;"