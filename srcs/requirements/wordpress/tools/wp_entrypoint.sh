#!/bin/bash
set -e

# 🔑 Load DB password from Docker secret
if [ -f /run/secrets/db_password ]; then
    WORDPRESS_DB_PASSWORD=$(cat /run/secrets/db_password)
else
    echo "❌ db_password secret not found!"
    exit 1
fi

# 🔑 Load admin/user passwords
if [ -f /run/secrets/wp_admin_password ]; then
    WP_ADMIN_PASSWORD=$(cat /run/secrets/wp_admin_password)
fi
if [ -f /run/secrets/wp_user_password ]; then
    WP_USER_PASSWORD=$(cat /run/secrets/wp_user_password)
fi

# Wait for MariaDB to be ready
echo "📡 Pinging ${WORDPRESS_DB_HOST}..."
until mysqladmin ping -h"${WORDPRESS_DB_HOST}" --protocol=tcp --silent; do
  echo "🔁 Waiting for MariaDB to respond..."
  sleep 2
done

chmod -R 755 /var/www/html

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

  wp theme install twentytwentyfour --activate --allow-root

  if [ ! -z "$WP_USER_EMAIL" ] && [ ! -z "$WP_USER_NAME" ] && [ ! -z "$WP_USER_PASSWORD" ]; then
    wp user create "$WP_USER_NAME" "$WP_USER_EMAIL" \
      --user_pass="$WP_USER_PASSWORD" \
      --role="${WP_USER_ROLE:-author}" --allow-root
  fi

  chown -R www-data:www-data /var/www/html
  echo "✅ WordPress installed!"
else
  echo "🔁 WordPress already configured, skipping install."
fi

# Fix FPM listen port
sed -i 's|listen = .*|listen = 9000|' /etc/php/7.4/fpm/pool.d/www.conf
mkdir -p /run/php
php-fpm7.4 -F
