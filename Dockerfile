# ---------- Stage 1: PHP-FPM ----------
FROM php:8.3-fpm-bullseye AS php-fpm

# Verhindert Mac FS-Cache Bugs
ENV COMPOSER_ALLOW_SUPERUSER=1

RUN apt-get update && \
    apt-get install -y cowsay fortune-mod fortunes-de locales && \
    echo "de_DE.UTF-8 UTF-8" > /etc/locale.gen && \
    locale-gen && \
    update-locale LANG=de_DE.UTF-8 && \
    ln -s /usr/games/fortune /usr/local/bin/fortune && \
    ln -s /usr/games/cowsay /usr/local/bin/cowsay && \
    rm -rf /var/lib/apt/lists/*

ENV LANG=de_DE.UTF-8
ENV LC_ALL=de_DE.UTF-8

WORKDIR /var/www/html
COPY ./lumen-app/ .
# Swagger/OpenAPI statisch einbinden
COPY openapi.yaml /var/www/html/public/openapi.yaml
COPY swagger/index.html /var/www/html/public/docs/index.html

RUN chown -R www-data:www-data /var/www/html

# ---------- Stage 2: Nginx ----------
FROM nginx:1.27-alpine AS nginx

# Nginx Konfiguration
COPY nginx/default.conf /etc/nginx/conf.d/default.conf

# Lumen-App aus Stage 1 übernehmen
COPY --from=php-fpm /var/www/html /var/www/html

EXPOSE 8080
CMD ["nginx", "-g", "daemon off;"]

