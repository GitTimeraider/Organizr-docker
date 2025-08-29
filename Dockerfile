FROM php:8.4-apache

# Labels for metadata
LABEL org.opencontainers.image.title="Organizr Docker"
LABEL org.opencontainers.image.description="HTPC/Homelab Services Organizer - Written in PHP"
LABEL org.opencontainers.image.url="https://github.com/GitTimeraider/Organizr-docker"
LABEL org.opencontainers.image.source="https://github.com/GitTimeraider/Organizr-docker"
LABEL org.opencontainers.image.vendor="GitTimeraider"
LABEL org.opencontainers.image.licenses="GPL-3.0"

# Set working directory
WORKDIR /var/www/html

FROM php:8.4-apache

# Labels for metadata
LABEL org.opencontainers.image.title="Organizr Docker"
LABEL org.opencontainers.image.description="HTPC/Homelab Services Organizer - Written in PHP"
LABEL org.opencontainers.image.url="https://github.com/GitTimeraider/Organizr-docker"
LABEL org.opencontainers.image.source="https://github.com/GitTimeraider/Organizr-docker"
LABEL org.opencontainers.image.vendor="GitTimeraider"
LABEL org.opencontainers.image.licenses="GPL-3.0"

# Set working directory
WORKDIR /var/www/html

# Install only essential packages - no compilation
RUN apt-get update && apt-get install -y --no-install-recommends \
    cron \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Enable Apache modules
RUN a2enmod rewrite headers

# Copy application files
COPY . /var/www/html/

# Create necessary directories and set permissions
RUN mkdir -p /config /var/log/organizr \
    && chown -R www-data:www-data /var/www/html /config /var/log/organizr \
    && chmod -R 755 /var/www/html

# Environment variables
ENV PUID=1000 \
    PGID=1000 \
    FPM=false \
    BRANCH=v2-master \
    TZ=UTC

# Simple entrypoint script
RUN echo '#!/bin/bash\n\
set -e\n\
echo "Starting Organizr..."\n\
chown -R www-data:www-data /config\n\
exec apache2-foreground' > /entrypoint.sh && chmod +x /entrypoint.sh

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
    CMD curl -f http://localhost/ || exit 1

# Expose port
EXPOSE 80

# Volume for config
VOLUME ["/config"]

# Set entrypoint
ENTRYPOINT ["/entrypoint.sh"]
