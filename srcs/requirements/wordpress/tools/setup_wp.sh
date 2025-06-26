#!/bin/bash

# Wait for MariaDB to be ready
while ! mysql -h mariadb -u ${DB_USER} -p${DB_PASSWORD} ${DB_NAME} &>/dev/null; do
    echo "Waiting for MariaDB..."
    sleep 1
done

# Create the web directory if it doesn't exist
mkdir -p /var/www/html

# Download and configure WordPress if not already present
if [ ! -f "/var/www/html/wp-config.php" ]; then
    wp core download --path=/var/www/html --allow-root
    wp config create --dbname=${DB_NAME} --dbuser=${DB_USER} --dbpass=${DB_PASSWORD} --dbhost=mariadb --path=/var/www/html --allow-root
    wp core install --url=${WP_URL} --title="Inception" --admin_user=${WP_ADMIN_USER} --admin_password=${WP_ADMIN_PASSWORD} --admin_email=${WP_ADMIN_EMAIL} --path=/var/www/html --allow-root
fi

# Start PHP-FPM 7.4 in the foreground
/usr/sbin/php-fpm7.4 -F