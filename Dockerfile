# Build stage
FROM php:8.1-apache as builder

# Install system dependencies for building
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    libzip-dev \
    zip \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Install PHP extensions
RUN docker-php-ext-install \
    pdo_mysql \
    mbstring \
    exif \
    pcntl \
    bcmath \
    gd \
    zip

# Copy source code for processing
COPY . /app/
WORKDIR /app

# Production stage
FROM php:8.1-apache as production

# Labels for metadata
LABEL org.opencontainers.image.title="Organizr Docker"
LABEL org.opencontainers.image.description="HTPC/Homelab Services Organizer - Written in PHP"
LABEL org.opencontainers.image.url="https://github.com/GitTimeraider/Organizr-docker"
LABEL org.opencontainers.image.source="https://github.com/GitTimeraider/Organizr-docker"
LABEL org.opencontainers.image.vendor="GitTimeraider"
LABEL org.opencontainers.image.licenses="GPL-3.0"

# Set working directory
WORKDIR /var/www/html

# Install runtime dependencies only
RUN apt-get update && apt-get install -y \
    libpng16-16 \
    libonig5 \
    libxml2 \
    libzip4 \
    cron \
    gosu \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

# Copy PHP extensions from builder stage
COPY --from=builder /usr/local/lib/php/extensions/ /usr/local/lib/php/extensions/
COPY --from=builder /usr/local/etc/php/conf.d/ /usr/local/etc/php/conf.d/

# Enable Apache modules
RUN a2enmod rewrite headers

# Configure Apache
ENV APACHE_DOCUMENT_ROOT /var/www/html
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf \
    && sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

# Copy application files
COPY --from=builder /app/ /var/www/html/

# Create necessary directories
RUN mkdir -p /config \
    && mkdir -p /var/log/organizr \
    && touch /var/log/organizr/organizr.log

# Environment variables with defaults
ENV PUID=1000 \
    PGID=1000 \
    FPM=false \
    BRANCH=v2-master \
    TZ=UTC

# Create entrypoint script
COPY <<'EOF' /entrypoint.sh
#!/bin/bash
set -e

# Handle timezone
if [ ! -z "$TZ" ]; then
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime
    echo $TZ > /etc/timezone
fi

# Handle user/group ID changes
if [ "$PUID" != "1000" ] || [ "$PGID" != "1000" ]; then
    echo "Updating user/group IDs..."
    groupmod -g $PGID www-data
    usermod -u $PUID -g $PGID www-data
fi

# Ensure proper permissions
chown -R www-data:www-data /var/www/html /config /var/log/organizr
chmod -R 755 /var/www/html
chmod -R 775 /config /var/log/organizr

# Setup cron if cron.php exists
if [ -f /var/www/html/cron.php ]; then
    echo "Setting up cron job..."
    echo "*/5 * * * * www-data /usr/local/bin/php /var/www/html/cron.php >> /var/log/organizr/cron.log 2>&1" > /etc/cron.d/organizr-cron
    chmod 0644 /etc/cron.d/organizr-cron
    crontab /etc/cron.d/organizr-cron
    service cron start
fi

# Create symlink for config if it doesn't exist
if [ ! -L /var/www/html/api/config/config.php ] && [ ! -f /var/www/html/api/config/config.php ]; then
    if [ -f /config/config.php ]; then
        ln -sf /config/config.php /var/www/html/api/config/config.php
    fi
fi

echo "Starting Organizr..."
exec gosu www-data apache2-foreground
EOF

RUN chmod +x /entrypoint.sh

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:80/ || exit 1

# Expose port
EXPOSE 80

# Create volume mount points
VOLUME ["/config"]

# Set entrypoint
ENTRYPOINT ["/entrypoint.sh"]
