# ---------- Stage: Runtime (NGINX + PHP-FPM + Composer) ----------
FROM php:8.3-fpm-trixie

RUN apt-get update && apt-get install -y \
    git bash curl locales unzip \
    nginx supervisor \
    fortune-mod cowsay \
    && rm -rf /var/lib/apt/lists/*

# Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Locale
RUN sed -i '/de_DE.UTF-8/s/^# //g' /etc/locale.gen && locale-gen
ENV LANG=de_DE.UTF-8 LANGUAGE=de_DE.UTF-8 LC_ALL=de_DE.UTF-8

WORKDIR /var/www/html

# App-Code kopieren
COPY ./lumen-app/ .

# Dependencies installieren
RUN composer install --no-dev --optimize-autoloader

# Swagger / OpenAPI
COPY openapi.yaml /var/www/html/public/openapi.yaml
COPY swagger/index.html /var/www/html/public/docs/index.html

# Nginx + Supervisor Konfigs
COPY nginx/default.conf /etc/nginx/conf.d/default.conf
COPY nginx/supervisord.conf /etc/supervisor/supervisord.conf

EXPOSE 8080
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]

