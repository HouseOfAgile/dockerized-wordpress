ARG WP_VERSION=4.9.8
ARG PHP_VERSION=7.2

FROM wordpress:${WP_VERSION}-php${PHP_VERSION}-fpm

# Use archive.debian.org for Debian Stretch
RUN echo "deb http://archive.debian.org/debian stretch main" > /etc/apt/sources.list && \
    echo "deb http://archive.debian.org/debian-security stretch/updates main" >> /etc/apt/sources.list && \
    apt-get update && \
    apt-get install -y --no-install-recommends --allow-unauthenticated pwgen curl && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Create /app/${PROJECT_NAME} directory
RUN mkdir -p /app/${PROJECT_NAME} && \
    chown www-data:www-data /app/${PROJECT_NAME}