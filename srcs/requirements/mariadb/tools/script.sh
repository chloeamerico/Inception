#!/bin/bash
set -e

#on recupere les mots de passe
export MYSQL_PASSWORD="$(cat /run/secrets/db_password)"
export MYSQL_ROOT_PASSWORD="$(cat /run/secrets/db_root_password)"

# creation dossier /run/mysqld qui contiendra apres mysqld.pid et mysqld.sock (fichiers temporaires de runtime)  // -p (ne pas echouer si le dossier existe deja)
# chown : change le proprietaire (le proprio de /run/mysqld et /var/lib/mysql passe de root a mysql) ==> mysql pourra donc ecrire dedans 
mkdir -p /run/mysqld
chown -R mysql:mysql /run/mysqld /var/lib/mysql

# si premier lancement -> monte sur le datadir /var/lib/mysql (le volume de la db)
# on rempli /var/lib/mysql/ avec la structure interne de MariaDB
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "Initialisation de MariaDB..."
    mysql_install_db --user=mysql --datadir=/var/lib/mysql
fi

# si le fichier .initialized (qui veut dire que ca a deja ete init) n'existe pas...
# ...demarre mysqld
if [ ! -f "/var/lib/mysql/.initialized" ]; then
    echo "Création des users et de la base..."
    mysqld --user=mysql --datadir=/var/lib/mysql --bootstrap << EOF

-- on recharge/synchronique les droits (entre le cache et le dique)
FLUSH PRIVILEGES;

-- on sup les user anonymes crees par défaut
DELETE FROM mysql.user WHERE User='';

-- on sup la base test creee par défaut
DROP DATABASE IF EXISTS test;

-- on garde que root en local
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');

-- on cree la base de donnees (avec le nm qui est dans le .env)
CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;

--on cree le user wp (% pour dire que c;est de n'importe quelle ip --> car WP est dans un autre conteneur)
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';

ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
FLUSH PRIVILEGES;
EOF
    touch /var/lib/mysql/.initialized
    echo "Init terminée."
fi

#le processus mysqld charge/cree tous les fichiers presents dans 50-server.cnf en tant que user : mysql
# lance en avant-plan (mysqld devient le PID 1)
exec mysqld --user=mysql