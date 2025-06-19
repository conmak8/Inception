#!/bin/bash
# wp_config.sh - WordPress setup script for 42 Inception project

set -e  # Exit on any error

echo "📦 Starting WordPress setup..."

# 🔐 Load database password from secrets
if [ ! -f /run/secrets/db_password ]; then
    echo "❌ Error: Database password secret not found!"
    exit 1
fi

WORDPRESS_DB_PASSWORD=$(cat /run/secrets/db_password)

# ✅ Verify required environment variables
required_vars=("WORDPRESS_DB_NAME" "WORDPRESS_DB_USER" "WORDPRESS_DB_HOST" "WP_ADMIN_USER" "WP_ADMIN_PASSWORD" "WP_ADMIN_EMAIL")
for var in "${required_vars[@]}"; do
    if [ -z "${!var}" ]; then
        echo "❌ Error: Required environment variable $var is not set!"
        exit 1
    fi
done

echo "📋 Configuration:"
echo "  Database: $WORDPRESS_DB_NAME"
echo "  DB User: $WORDPRESS_DB_USER"  
echo "  DB Host: $WORDPRESS_DB_HOST"
echo "  WP Admin: $WP_ADMIN_USER"

# 🏠 Navigate to WordPress directory
cd /var/www/html

# 📡 Wait for MariaDB to be ready
echo "📡 Waiting for MariaDB to be ready..."
timeout=60
while ! mysqladmin ping -h"$WORDPRESS_DB_HOST" --silent; do
    timeout=$((timeout - 1))
    if [ $timeout -eq 0 ]; then
        echo "❌ Timeout waiting for MariaDB!"
        exit 1
    fi
    echo "⏳ Waiting for database... ($timeout seconds remaining)"
    sleep 2
done

echo "✅ MariaDB is ready!"

# 📥 Download WordPress if not present
if [ ! -f wp-config.php ]; then
    echo "⬇️ Downloading WordPress..."
    wp core download --allow-root
    
    echo "⚙️ Generating wp-config.php..."
    wp config create \
        --dbname="$WORDPRESS_DB_NAME" \
        --dbuser="$WORDPRESS_DB_USER" \
        --dbpass="$WORDPRESS_DB_PASSWORD" \
        --dbhost="$WORDPRESS_DB_HOST" \
        --allow-root
    
    # 🧱 Install WordPress if not installed
    if ! wp core is-installed --allow-root; then
        echo "🧱 Installing WordPress..."
        wp core install \
            --url="$WP_URL" \
            --title="$WP_TITLE" \
            --admin_user="$WP_ADMIN_USER" \
            --admin_password="$WP_ADMIN_PASSWORD" \
            --admin_email="$WP_ADMIN_EMAIL" \
            --allow-root
        
        echo "✅ WordPress installation completed!"
    else
        echo "✅ WordPress already installed!"
    fi
else
    echo "✅ WordPress configuration already exists!"
fi

# 🔧 Set proper permissions
chown -R www-data:www-data /var/www/html
chmod -R 755 /var/www/html

# 🚀 Start PHP-FPM
echo "🚀 Starting PHP-FPM..."
exec php-fpm7.4 -F