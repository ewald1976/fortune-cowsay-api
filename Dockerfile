# ---------- Stage: Runtime (NGINX + PHP-FPM + Composer + Fortunes) ----------
FROM php:8.3-fpm-trixie

# --- Systempakete ---
RUN apt-get update && apt-get install -y \
    git bash curl locales unzip \
    nginx supervisor \
    fortune-mod cowsay \
    fortunes-de fortunes-debian-hints \
    && rm -rf /var/lib/apt/lists/*

# --- Composer ---
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# --- Locale (de_DE.UTF-8) ---
RUN sed -i '/de_DE.UTF-8/s/^# //g' /etc/locale.gen && locale-gen
ENV LANG=de_DE.UTF-8 LANGUAGE=de_DE.UTF-8 LC_ALL=de_DE.UTF-8

# --- PATH-Erweiterung ---
ENV PATH="/usr/games:${PATH}"
RUN echo 'env[PATH] = /usr/games:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin' \
    >> /usr/local/etc/php-fpm.d/www.conf

WORKDIR /var/www/html

# --- App-Code ---
COPY ./lumen-app/ .

# --- PHP Dependencies ---
RUN composer install --no-dev --optimize-autoloader --no-interaction --no-progress

# --- Swagger / OpenAPI Docs ---
COPY openapi.yaml /var/www/html/public/openapi.yaml
COPY swagger /var/www/html/public/docs

# --- Retro UI (Samples) ---
COPY samples /var/www/html/public/samples

# --- Englische Fortunes (lokale Erweiterungen) ---
COPY docker/fortunes/en/ /usr/share/games/fortunes/en/
RUN for f in /usr/share/games/fortunes/en/*; do \
      if [ -f "$f" ]; then strfile "$f" "$f.dat" || true; fi; \
    done

# --- Nginx + Supervisor ---
COPY nginx/default.conf /etc/nginx/conf.d/default.conf
COPY nginx/supervisord.conf /etc/supervisor/supervisord.conf
RUN mkdir -p /run/nginx /var/log/supervisor

EXPOSE 8080
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]
