FROM wordpress:cli

RUN apk add --no-cache mariadb-client && \
    mkdir -p /backup && \
    chown -R www-data:www-data /backup && \
    chmod -R 755 /backup

WORKDIR /backup