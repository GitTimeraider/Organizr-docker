# OCI-compliant image for Organizr using Apache + PHP
# Includes common extensions needed by this repo (sqlite, mbstring, curl, ldap, gd, zip)

FROM php:8.2-apache

# Install system deps and PHP extensions
RUN set -eux; \
    apt-get update; \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
      libzip-dev \
      libpng-dev \
      libjpeg-dev \
      libfreetype6-dev \
      libldap2-dev \
      libsqlite3-dev \
      libcurl4-openssl-dev \
      zlib1g-dev \
      ca-certificates \
      curl \
      unzip; \
    docker-php-ext-configure gd --with-freetype --with-jpeg; \
    docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu; \
    docker-php-ext-install -j"$(nproc)" \
      gd \
      mbstring \
      zip \
      pdo_sqlite \
      sqlite3 \
      ldap \
      curl; \
    a2enmod rewrite headers expires; \
    rm -rf /var/lib/apt/lists/*

# Copy source
WORKDIR /var/www/html
COPY . /var/www/html

# Default envs matching older container semantics
ENV PUID=33 \
  PGID=33 \
  FPM=false \
  BRANCH=v2-master

# Prepare persistent config volume at /config and map to app's data path
RUN mkdir -p /config /var/www/html/data \
 && rm -rf /var/www/html/data \
 && ln -s /config /var/www/html/data \
 && chown -R www-data:www-data /config /var/www/html
VOLUME ["/config"]

# Healthcheck to ensure Apache/PHP is serving
HEALTHCHECK --interval=30s --timeout=5s --retries=5 CMD curl -fsS http://127.0.0.1/ || exit 1

EXPOSE 80

# Labels for GHCR/OCI
LABEL org.opencontainers.image.source="https://github.com/GitTimeraider/Organizr-docker" \
      org.opencontainers.image.title="Organizr" \
      org.opencontainers.image.description="Self-hosted front-end to organize your services" \
      org.opencontainers.image.licenses="GPL-3.0-only"

# Entrypoint adjusts UID/GID for www-data when PUID/PGID are provided, then starts Apache
COPY docker/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
CMD ["apache2-foreground"]
