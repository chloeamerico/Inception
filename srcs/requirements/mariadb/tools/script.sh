#!/bin/bash
set -e

#on recup les mdp
export MYSQL_PASSWORD="$(cat /run/secrets/db_password)"
export MYSQL_ROOT_PASSWORD="$(cat /run/secrets/db_root_password)"

mkdir -p /run/mysqld
chown -R mysql:mysql /run/mysqld /var/lib/mysql

# est ce que Mariadb a deja ete initialise. si non --> on initialise/prepare les bases de donnees  
if [ ! -d "/var/lib/mysql/mysql" ]; then
    mysql_install_db --user=mysql --datadir=/var/lib/mysql > /dev/null
fi

# on demarre MariaDB temporairement poru pouvoir installer les commandes suivantes
mysqld --user=mysql --skip-networking --socket=/run/mysqld/mysqld.sock &
MYSQL_PID=$!

# on attend que Mdb ait termine son initialisation interne pour recevoir des connections 
until mysqladmin --socket=/run/mysqld/mysqld.sock ping --silent 2>/dev/null; do
    sleep 1
done

# on envoit un lot de commandes SQL (de config) au serveur tmp de Mariadb
mysql --socket=/run/mysqld/mysqld.sock << EOF
-- supp les user anonymes/sans noms 
DELETE FROM mysql.user WHERE User='';

-- supp la base de test, iinstallee par default
DROP DATABASE IF EXISTS test;

-- cree la base de données
CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;

-- cree un user/ compte MDB ( avec le nom qui est dans MYSQL_USER) // '@'%' connection depuis n'importe quelle machine
-- il a tous les droits sur cette base de donnees
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';

-- on definit le mot de passe root
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';

-- on charge tous les privileges pour qu'ils soient pris en compte
FLUSH PRIVILEGES;
EOF

# arret propre du serveur tmp de MDB - en s'identifiant - et on attend que le serveur MDB lance en arriere plan soit termine
mysqladmin --socket=/run/mysqld/mysqld.sock -p"${MYSQL_ROOT_PASSWORD}" shutdown
wait $MYSQL_PID

# relande MariaDB en process principal (plus en arriere plan)
exec mysqld --user=mysql