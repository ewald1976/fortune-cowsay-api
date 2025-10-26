# ---------- Stage 1: Build PHP/Lumen ----------
FROM php:8.3-fpm-trixie AS php-fpm

# Systempakete + Entwickler-Tools
RUN apt-get update && apt-get install -y \
    git bash curl locales \
    fortune-mod cowsay \
    && rm -rf /var/lib/apt/lists/*

# UTF-8 aktivieren
RUN sed -i '/de_DE.UTF-8/s/^# //g' /etc/locale.gen && locale-gen
ENV LANG=de_DE.UTF-8 LANGUAGE=de_DE.UTF-8 LC_ALL=de_DE.UTF-8

WORKDIR /var/www/html
COPY ./lumen-app/ .

# Swagger / OpenAPI
COPY openapi.yaml /var/www/html/public/openapi.yaml
COPY swagger/index.html /var/www/html/public/docs/index.html


# ---------- Stage 2: Final Image ----------
FROM php:8.3-fpm-trixie AS nginx

# Nginx + Supervisor + Tools
RUN apt-get update && apt-get install -y \
    nginx supervisor bash curl \
    fortune-mod cowsay \
    && rm -rf /var/lib/apt/lists/*

# ⬇️ PATH fix
ENV PATH="/usr/games:${PATH}"

# Verzeichnisse
RUN mkdir -p /run/nginx /var/log/supervisor /var/www/html

# App übernehmen
COPY --from=php-fpm /var/www/html /var/www/html

# Nginx & Supervisor-Konfiguration
COPY nginx/default.conf /etc/nginx/conf.d/default.conf
COPY nginx/supervisord.conf /etc/supervisor/supervisord.conf

EXPOSE 8080
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]

