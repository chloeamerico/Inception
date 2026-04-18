FROM debian:bookworm

RUN apt-get update \
    && apt-get install -y \
        php8.2-fpm \
        php8.2-mysql \
        php8.2-gd \
        php8.2-curl \
        php8.2-mbstring \
        php8.2-xml \
        php8.2-zip \
        curl \
        mariadb-client \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir -p /run/php /var/www/html

COPY tools/www.conf /etc/php/8.2/fpm/pool.d/www.conf
COPY tools/script.sh /usr/local/bin/script.sh

# donne des drit specifiques
RUN chmod +x /usr/local/bin/script.sh \
    && chown -R www-data:www-data /var/www/html

EXPOSE 9000

ENTRYPOINT ["/usr/local/bin/script.sh"]
