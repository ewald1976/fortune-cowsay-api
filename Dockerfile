# ---------- Stage: Runtime (NGINX + PHP-FPM + Composer + Fortunes) ----------
FROM php:8.3-fpm-trixie

# Systempakete + Tools
RUN apt-get update && apt-get install -y \
    git bash curl locales unzip \
    nginx supervisor \
    fortune-mod cowsay \
    && rm -rf /var/lib/apt/lists/*

# Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# UTF-8 Locale
RUN sed -i '/de_DE.UTF-8/s/^# //g' /etc/locale.gen && locale-gen
ENV LANG=de_DE.UTF-8 LANGUAGE=de_DE.UTF-8 LC_ALL=de_DE.UTF-8

# PATH-Erweiterung (Cowsay + Fortune)
ENV PATH="/usr/games:${PATH}"
RUN echo 'env[PATH] = /usr/games:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin' \
    >> /usr/local/etc/php-fpm.d/www.conf

WORKDIR /var/www/html

# --- App-Code ---
COPY ./lumen-app/ .

# --- Composer Dependencies ---
RUN composer install --no-dev --optimize-autoloader --no-interaction --no-progress

# --- Swagger / OpenAPI Docs ---
COPY openapi.yaml /var/www/html/public/openapi.yaml
COPY swagger /var/www/html/public/docs

# --- Retro-UI (Samples) ---
COPY samples /var/www/html/public/samples

# --- Zusätzliche Fortunes (Deutsch & Englisch) ---
# lokale Verzeichnisse z. B. ./docker/fortunes/en/  und ./docker/fortunes/de/
COPY docker/fortunes/en/ /usr/share/games/fortunes/en/
COPY docker/fortunes/de/ /usr/share/games/fortunes/de/

# index-Dateien erzeugen (.dat)
RUN for f in /usr/share/games/fortunes/en/* /usr/share/games/fortunes/de/*; do \
      if [ -f "$f" ]; then strfile "$f" "$f.dat" || true; fi; \
    done

# --- Nginx + Supervisor Configs ---
COPY nginx/default.conf /etc/nginx/conf.d/default.conf
COPY nginx/supervisord.conf /etc/supervisor/supervisord.conf

# Laufzeitverzeichnisse
RUN mkdir -p /run/nginx /var/log/supervisor

EXPOSE 8080
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]
