#!/bin/bash
# mariadb_entrypoint.sh
# Custom MariaDB initialization for 42 Inception project

set -e  # Exit on any error

echo "🚀 Starting MariaDB initialization..."

# Load secrets from Docker secrets file mounts
if [ ! -f /run/secrets/db_password ] || [ ! -f /run/secrets/db_root_password ]; then
    echo "❌ Error: Secret files not found!"
    exit 1
fi

WP_DB_PASSWORD=$(cat /run/secrets/db_password)
WP_DB_ROOT_PASSWORD=$(cat /run/secrets/db_root_password)

# Verify environment variables are set
if [ -z "$WP_DB_NAME" ] || [ -z "$WP_DB_USER" ]; then
    echo "❌ Error: Missing required environment variables!"
    echo "WP_DB_NAME: '$WP_DB_NAME'"
    echo "WP_DB_USER: '$WP_DB_USER'"
    exit 1
fi

echo "📋 Configuration:"
echo "  Database: $WP_DB_NAME"
echo "  User: $WP_DB_USER"

# Ensure MySQL data directory exists and has correct permissions
mkdir -p /var/lib/mysql
chown -R mysql:mysql /var/lib/mysql

# Check if the database directory already exists
if [ ! -d "/var/lib/mysql/$WP_DB_NAME" ]; then
    echo "📦 First boot: initializing database..."
    
    # Initialize the MySQL data directory
    mysql_install_db --user=mysql --datadir=/var/lib/mysql
    
    # Start MariaDB in bootstrap mode to run initial setup
    mysqld --user=mysql --bootstrap --verbose=0 <<EOF
USE mysql;

-- Clean up default users and test database
FLUSH PRIVILEGES;
DELETE FROM mysql.user WHERE User='';
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
DROP DATABASE IF EXISTS test;
DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';

-- Create the WordPress database
CREATE DATABASE IF NOT EXISTS \`${WP_DB_NAME}\`;

-- Create the WordPress user
CREATE USER IF NOT EXISTS '${WP_DB_USER}'@'%' IDENTIFIED BY '${WP_DB_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${WP_DB_NAME}\`.* TO '${WP_DB_USER}'@'%';

-- Set root password
ALTER USER 'root'@'localhost' IDENTIFIED BY '${WP_DB_ROOT_PASSWORD}';

-- Ensure root can connect from anywhere within the Docker network
CREATE USER IF NOT EXISTS 'root'@'%' IDENTIFIED BY '${WP_DB_ROOT_PASSWORD}';
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION;

FLUSH PRIVILEGES;
EOF

    echo "✅ Database initialization complete!"
else
    echo "✅ Database already initialized, skipping setup..."
fi

# Start MariaDB normally
echo "🚀 Starting MariaDB server..."
exec mysqld --user=mysql --console