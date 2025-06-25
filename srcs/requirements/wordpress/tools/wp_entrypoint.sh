#!/bin/bash
set -e

if [ -f /run/secrets/db_password ]; then
    WORDPRESS_DB_PASSWORD=$(cat /run/secrets/db_password)
else
    echo "❌ db_password secret not found!"
    exit 1
fi

# Wait for MariaDB 
echo "📡 Pinging ${WORDPRESS_DB_HOST}..."
until mysqladmin ping -h"${WORDPRESS_DB_HOST}" --protocol=tcp --silent; do
  echo "🔁 Waiting for MariaDB to respond..."
  sleep 2
done

# If WordPress not installed, install it!
if [ ! -f /var/www/html/wp-config.php ]; then
  echo "📦 Setting up WordPress..."

  wp core download --allow-root

  wp config create --allow-root \
    --dbname="${WORDPRESS_DB_NAME}" \
    --dbuser="${WORDPRESS_DB_USER}" \
    --dbpass="${WORDPRESS_DB_PASSWORD}" \
    --dbhost="${WORDPRESS_DB_HOST}"

  wp core install --allow-root \
    --url="${WP_URL}" \
    --title="${WP_TITLE}" \
    --admin_user="${WP_ADMIN_USER}" \
    --admin_password="${WP_ADMIN_PASSWORD}" \
    --admin_email="${WP_ADMIN_EMAIL}"

  echo "✅ WordPress installed!"
else
  echo "🔁 WordPress already configured, skipping install."
fi

# Start PHP-FPM in the foreground
php-fpm7.4 -F
