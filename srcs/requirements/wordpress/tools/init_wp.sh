#!/bin/bash
set -e

echo "🚀 Starting WordPress setup..."

# Read database password
DB_PASSWORD=$(cat /run/secrets/db_password)

# Wait for database
echo "⏳ Waiting for database..."
while ! mysqladmin ping -h"$WORDPRESS_DB_HOST" --silent; do
    echo "🔄 Database not ready, waiting..."
    sleep 2
done

echo "✅ Database is ready!"

# Download WordPress if not exists
if [ ! -f wp-config.php ]; then
    echo "📥 Downloading WordPress..."
    wp core download --allow-root
    
    echo "⚙️ Creating wp-config.php..."
    wp config create --allow-root \
        --dbname="$WORDPRESS_DB_NAME" \
        --dbuser="$WORDPRESS_DB_USER" \
        --dbpass="$DB_PASSWORD" \
        --dbhost="$WORDPRESS_DB_HOST"
    
    echo "🎯 Installing WordPress..."
    wp core install --allow-root \
        --url="$WORDPRESS_URL" \
        --title="$WORDPRESS_TITLE" \
        --admin_user="$WORDPRESS_ADMIN_USER" \
        --admin_password="$WORDPRESS_ADMIN_PASSWORD" \
        --admin_email="$WORDPRESS_ADMIN_EMAIL"
    
    echo "✅ WordPress installed!"
else
    echo "♻️ WordPress already installed, skipping setup..."
fi

# Fix permissions
chown -R www-data:www-data /var/www/html

echo "🌟 Starting PHP-FPM..."
exec php-fpm7.4 -F