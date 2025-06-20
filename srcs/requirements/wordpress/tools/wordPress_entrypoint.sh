#!/bin/bash
set -e

echo "📦 Starting WordPress setup..."

# Defensive: Ensure DB password secret is present
if [ -f /run/secrets/db_password ]; then
    WP_DB_PASSWORD=$(cat /run/secrets/db_password)
else
    echo "❌ db_password secret not found!"
    exit 1
fi

# Check required env variables
for VAR in WORDPRESS_DB_HOST WORDPRESS_DB_NAME WORDPRESS_DB_USER WP_URL WP_TITLE WP_ADMIN_USER WP_ADMIN_PASSWORD WP_ADMIN_EMAIL
do
  if [ -z "${!VAR}" ]; then
    echo "❌ Missing environment variable: $VAR"
    exit 1
  fi
done

# Wait for MariaDB to be ready
echo "📡 Pinging ${WORDPRESS_DB_HOST}..."
until mysqladmin ping -h"${WORDPRESS_DB_HOST}" --protocol=tcp --silent; do
  echo "🔁 Waiting for MariaDB to respond..."
  sleep 2
done

cd /var/www/html

# Download WordPress if not already present
if [ ! -f wp-load.php ]; then
    echo "⬇️ Downloading WordPress with wp-cli..."
    wp core download --locale=en_US --allow-root
fi

# Create wp-config.php if not present
if [ ! -f wp-config.php ]; then
    echo "⚙️ Generating wp-config.php..."
    wp config create \
        --dbname="${WORDPRESS_DB_NAME}" \
        --dbuser="${WORDPRESS_DB_USER}" \
        --dbpass="${WP_DB_PASSWORD}" \
        --dbhost="${WORDPRESS_DB_HOST}" \
        --path=/var/www/html \
        --skip-check \
        --allow-root
fi

# Install WordPress if not installed
if ! wp core is-installed --allow-root; then
    echo "🧱 Installing WordPress..."
    wp core install \
        --url="${WP_URL}" \
        --title="${WP_TITLE}" \
        --admin_user="${WP_ADMIN_USER}" \
        --admin_password="${WP_ADMIN_PASSWORD}" \
        --admin_email="${WP_ADMIN_EMAIL}" \
        --skip-email \
        --allow-root
fi

# Permissions fix
chown -R www-data:www-data /var/www/html

echo "✅ WordPress ready! Starting PHP-FPM..."

mkdir -p /run/php
exec php-fpm7.4 -F
# If you use a different PHP version, adjust as needed
