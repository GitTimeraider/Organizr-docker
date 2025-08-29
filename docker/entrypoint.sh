#!/usr/bin/env bash
set -euo pipefail

# Allow runtime UID/GID remapping to match host, similar to LSIO patterns
PUID=${PUID:-33}
PGID=${PGID:-33}

if [ "$PGID" != "33" ] || [ "$PUID" != "33" ]; then
  groupmod -o -g "$PGID" www-data || true
  usermod -o -u "$PUID" www-data || true
fi

# Ensure /config exists with correct ownership
mkdir -p /config
chown -R www-data:www-data /config

# Apache document root is /var/www/html; ensure it's owned properly
chown -R www-data:www-data /var/www/html || true

# Export BRANCH and FPM for PHP to read via getenv if used by app (support lowercase variants)
export BRANCH=${BRANCH:-${branch:-v2-master}}
export FPM=${FPM:-${fpm:-false}}

exec docker-php-entrypoint "$@"
