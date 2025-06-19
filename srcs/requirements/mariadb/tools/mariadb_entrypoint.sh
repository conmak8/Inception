#!/bin/bash
# mariadb_entrypoint.sh
# Custom MariaDB initialization for 42 Inception project

set -e  # Exit on any error

echo "🚀 Starting MariaDB initialization..."

# 🔐 Load secrets from Docker secrets file mounts
if [ ! -f /run/secrets/db_password ]; then
    echo "❌ Error: db_password secret file not found at /run/secrets/db_password"
    echo "💡 Check: docker-compose.yml secrets section and ../secrets/db_password.txt"
    exit 1
fi

if [ ! -f /run/secrets/db_root_password ]; then
    echo "❌ Error: db_root_password secret file not found at /run/secrets/db_root_password"
    echo "💡 Check: docker-compose.yml secrets section and ../secrets/db_root_password.txt"
    exit 1
fi

WP_DB_PASSWORD=$(cat /run/secrets/db_password)
WP_DB_ROOT_PASSWORD=$(cat /run/secrets/db_root_password)

# 🔍 Verify passwords were loaded
if [ -z "$WP_DB_PASSWORD" ]; then
    echo "❌ Error: db_password is empty!"
    exit 1
fi

if [ -z "$WP_DB_ROOT_PASSWORD" ]; then
    echo "❌ Error: db_root_password is empty!"
    exit 1
fi

echo "✅ Secrets loaded successfully"

# ✅ Verify environment variables are set
if [ -z "$WP_DB_NAME" ] || [ -z "$WP_DB_USER" ]; then
    echo "❌ Error: Missing required environment variables!"
    echo "WP_DB_NAME: '$WP_DB_NAME'"
    echo "WP_DB_USER: '$WP_DB_USER'"
    exit 1
fi

echo "📋 Configuration:"
echo "  Database: $WP_DB_NAME"
echo "  User: $WP_DB_USER"
echo "  Host permissions: $(ls -la /var/lib/mysql | head -2)"

# 📂 Check if we can write to the mysql directory
if [ ! -w "/var/lib/mysql" ]; then
    echo "❌ Error: Cannot write to /var/lib/mysql"
    echo "💡 Tip: Make sure host directory has correct permissions (chown 999:999)"
    exit 1
fi

# 🔍 Check if the database is already initialized
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "📦 First boot: initializing database system..."
    
    # 🏗️ Initialize the MySQL data directory
    mysql_install_db --user=mysql --datadir=/var/lib/mysql --auth-root-authentication-method=normal
    
    echo "🔧 Setting up database and users..."
    
    # 🚀 Start MariaDB in bootstrap mode to run initial setup
    mysqld --user=mysql --bootstrap --verbose=0 --skip-name-resolve --skip-networking <<EOF
USE mysql;

-- 🧹 Clean up default users and test database
FLUSH PRIVILEGES;
DELETE FROM mysql.user WHERE User='';
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
DROP DATABASE IF EXISTS test;
DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';

-- 🗄️ Create the WordPress database
CREATE DATABASE IF NOT EXISTS \`${WP_DB_NAME}\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- 👤 Create the WordPress user
CREATE USER IF NOT EXISTS '${WP_DB_USER}'@'%' IDENTIFIED BY '${WP_DB_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${WP_DB_NAME}\`.* TO '${WP_DB_USER}'@'%';

-- 🔑 Set root password
ALTER USER 'root'@'localhost' IDENTIFIED BY '${WP_DB_ROOT_PASSWORD}';

-- 🌐 Allow root connections from Docker network
CREATE USER IF NOT EXISTS 'root'@'%' IDENTIFIED BY '${WP_DB_ROOT_PASSWORD}';
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION;

-- 💾 Apply all changes
FLUSH PRIVILEGES;
EOF

    echo "✅ Database initialization complete!"
else
    echo "✅ Database already initialized, starting server..."
fi

# 🚀 Start MariaDB normally
echo "🌟 Starting MariaDB server..."
exec mysqld --user=mysql --console