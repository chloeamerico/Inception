FROM debian:bookworm

RUN apt-get update \
    && apt-get install -y nginx openssl \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir -p /etc/nginx/ssl /var/run/nginx

COPY tools/nginx.conf /etc/nginx/nginx.conf
COPY tools/script.sh /usr/local/bin/script.sh

RUN chmod +x /usr/local/bin/script.sh

EXPOSE 443

ENTRYPOINT ["/usr/local/bin/script.sh"]
