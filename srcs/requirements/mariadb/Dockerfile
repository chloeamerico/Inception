# bullseye = debian version 11
FROM debian:bullseye

RUN apt-get update \
    && apt-get install -y mariadb-server \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir -p /run/mysqld /var/lib/mysql \
    && rm -rf /var/lib/mysql/*

# copie des fichiers de config depuis la vm vers l'image
COPY tools/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf
COPY tools/script.sh /usr/local/bin/script.sh

#donne les permissions pour executer le script
RUN chmod +x /usr/local/bin/script.sh

EXPOSE 3306

ENTRYPOINT ["/usr/local/bin/script.sh"]
