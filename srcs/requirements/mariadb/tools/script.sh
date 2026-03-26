#!/bin/bash
set -eu

# Récupération des mots de passe
export MYSQL_PASSWORD="$(cat /run/secrets/db_password)"
export MYSQL_ROOT_PASSWORD="$(cat /run/secrets/db_root_password)"

mkdir -p /run/mysqld
chown -R mysql:mysql /run/mysqld /var/lib/mysql

if [ ! -d "/var/lib/mysql/mysql" ]; then
    mysql_install_db --user=mysql --datadir=/var/lib/mysql

    # Démarrage temporaire
    mysqld --user=mysql --skip-networking --socket=/run/mysqld/mysqld.sock &
    MYSQL_PID=$!

    until mysqladmin --socket=/run/mysqld/mysqld.sock ping --silent; do
        sleep 1
    done

    # Commandes SQL
    # Note : On utilise 'root'@'%' pour s'assurer que même root peut administrer à distance si besoin
    mysql --protocol=socket --socket=/run/mysqld/mysqld.sock -u root << EOF
FLUSH PRIVILEGES;
DELETE FROM mysql.user WHERE User='';
DROP DATABASE IF EXISTS test;
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');

CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';

-- Sécurisation du root et accès distant si nécessaire
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
-- Optionnel : permettre à root de se connecter depuis le réseau (utile pour le debug)
CREATE USER IF NOT EXISTS 'root'@'%' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION;

FLUSH PRIVILEGES;
EOF

    # Arrêt propre
    mysqladmin --protocol=socket --socket=/run/mysqld/mysqld.sock -u root -p"${MYSQL_ROOT_PASSWORD}" shutdown
    wait $MYSQL_PID
fi

# Lancement final (le 50-server.cnf gère le bind-address=0.0.0.0)
exec mysqld --user=mysql
