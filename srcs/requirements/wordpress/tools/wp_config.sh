#!/bin/bash

set -e

echo "📦 Starting WordPress setup..."

# ✅ Wait for MariaDB to be ready
# echo "⏳ Waiting for MariaDB..."
# until mysqladmin ping -h"${WORDPRESS_DB_HOST}" --silent; do
#     sleep 2
# done
echo "📡 Pinging ${WORDPRESS_DB_HOST}..."
until mysqladmin ping -h"${WORDPRESS_DB_HOST}" --protocol=tcp --silent; do
  echo "🔁 Waiting for MariaDB to respond..."
  sleep 2
done


# ✅ Download WordPress if not already
if [ ! -f wp-load.php ]; then
    echo "⬇️ Downloading WordPress..."
    wp core download --locale=en_US --allow-root
fi

# ✅ Generate config if not already
if [ ! -f wp-config.php ]; then
    echo "⚙️ Generating wp-config.php..."
    wp config create \
        --dbname="${WORDPRESS_DB_NAME}" \
        --dbuser="${WORDPRESS_DB_USER}" \
        --dbpass="$(cat /run/secrets/db_password)" \
        --dbhost="${WORDPRESS_DB_HOST}" \
        --path=/var/www/html \
        --skip-check \
        --allow-root
fi

# ✅ Install WordPress if not installed
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

# ✅ Fix permissions
chown -R www-data:www-data /var/www/html

# 🚀 Start PHP-FPM
echo "🚀 Launching PHP-FPM..."
exec php-fpm7.4 -F
