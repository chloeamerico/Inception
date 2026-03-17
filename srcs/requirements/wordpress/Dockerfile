FROM debian:bullseye

RUN apt-get update \
    && apt-get install -y \
        php7.4-fpm \
        php7.4-mysql \
        php7.4-gd \
        php7.4-curl \
        php7.4-mbstring \
        php7.4-xml \
        php7.4-zip \
        curl \
        mariadb-client \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir -p /run/php /var/www/html

COPY tools/www.conf /etc/php/7.4/fpm/pool.d/www.conf
COPY tools/script.sh /usr/local/bin/script.sh

# donne des drit specifiques
RUN chmod +x /usr/local/bin/script.sh \
    && chown -R www-data:www-data /var/www/html

EXPOSE 9000

ENTRYPOINT ["/usr/local/bin/script.sh"]