#!/bin/bash
# mariadb_entrypoint.sh

set -e

echo "🚀 Starting MariaDB initialization..."

# 🔐 Load secrets from Docker secrets file mounts
if [ ! -f /run/secrets/db_password ]; then
    echo "❌ Error: db_password secret file not found at /run/secrets/db_password"
    exit 1
fi
if [ ! -f /run/secrets/db_root_password ]; then
    echo "❌ Error: db_root_password secret file not found at /run/secrets/db_root_password"
    exit 1
fi

WP_DB_PASSWORD=$(cat /run/secrets/db_password)
WP_DB_ROOT_PASSWORD=$(cat /run/secrets/db_root_password)

# ✅ Verify environment variables are set (these come from Compose env!)
if [ -z "$WP_DB_NAME" ] || [ -z "$WP_DB_USER" ]; then
    echo "❌ Error: Missing required environment variables!"
    echo "WP_DB_NAME: '$WP_DB_NAME'"
    echo "WP_DB_USER: '$WP_DB_USER'"
    exit 1
fi

# 📦 Check if database is initialized
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "📦 First boot: initializing MariaDB database system..."
    mysql_install_db --user=mysql --datadir=/var/lib/mysql --auth-root-authentication-method=normal

    echo "🔧 Setting up database and users..."

    mysqld --user=mysql --bootstrap --skip-name-resolve --skip-networking <<EOF
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

    echo "✅ MariaDB database initialization complete!"
else
    echo "✅ Database already initialized, starting MariaDB server..."
fi

echo "🌟 Starting MariaDB server..."
exec mysqld --user=mysql --console
