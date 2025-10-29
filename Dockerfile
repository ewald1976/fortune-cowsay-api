# ---------- Stage 1: Build PHP/Lumen ----------
FROM php:8.3-fpm-trixie AS php-fpm

# Systempakete + Tools
RUN apt-get update && apt-get install -y \
    git bash curl locales nginx supervisor \
    fortune-mod cowsay fortunes-de fortunes-debian-hints \
    && rm -rf /var/lib/apt/lists/*

# UTF-8 aktivieren
RUN sed -i '/de_DE.UTF-8/s/^# //g' /etc/locale.gen && locale-gen
ENV LANG=de_DE.UTF-8 LANGUAGE=de_DE.UTF-8 LC_ALL=de_DE.UTF-8

WORKDIR /var/www/html
COPY ./lumen-app/ .

# 🔽 Composer installieren + Dependencies auflösen
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
RUN composer install --no-dev --optimize-autoloader
# Swagger / OpenAPI
COPY openapi.yaml /var/www/html/public/openapi.yaml
COPY swagger/index.html /var/www/html/public/docs/index.html


# ---------- Stage 2A: NGINX + PHP-FPM ----------
FROM php-fpm AS nginx

RUN apt-get update && apt-get install -y \
    nginx supervisor bash curl \
    fortune-mod cowsay fortunes-de fortunes-debian-hints \
    && rm -rf /var/lib/apt/lists/*

ENV PATH="/usr/games:${PATH}"

RUN echo 'env[PATH] = /usr/games:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin' \
    >> /usr/local/etc/php-fpm.d/www.conf

RUN mkdir -p /run/nginx /var/log/supervisor /var/www/html

COPY --from=php-fpm /var/www/html /var/www/html
COPY nginx/default.conf /etc/nginx/conf.d/default.conf
COPY nginx/supervisord.conf /etc/supervisor/supervisord.conf
# ---------- Fortunes einbinden ----------
# Kopiert alle lokalen Fortune-Dateien (englisch & deutsch)
COPY docker/fortunes /usr/share/games/fortunes

# Erzeuge .dat-Dateien für fortune (Index)
# -> strfile erzeugt für jede Textdatei eine Indexdatei, die fortune benötigt
RUN find /usr/share/games/fortunes \
    -type f ! -name "*.dat" ! -name "*.u8" \
    -exec strfile {} \; \
    && ls -1 /usr/share/games/fortunes | wc -l \
    && echo "✅ Fortunes wurden erfolgreich indiziert."


EXPOSE 8080
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]
