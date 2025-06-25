#!/bin/bash
set -e

echo "Starting MariaDB initialization "

# 🔑 Load secrets from Docker secrets (file mounts)
if [ -f /run/secrets/db_password ]; then
    WP_DB_PASSWORD=$(cat /run/secrets/db_password)
else
    echo "❌ db_password secret not found!"
    exit 1
fi

if [ -f /run/secrets/db_root_password ]; then
    WP_DB_ROOT_PASSWORD=$(cat /run/secrets/db_root_password)
else
    echo "❌ db_root_password secret not found!"
    exit 1
fi

# Environment variables
if [ -z "$WP_DB_NAME" ]; then
  echo "❌ Error: WP_DB_NAME is not set!"
  exit 1
fi
if [ -z "$WP_DB_USER" ]; then
  echo "❌ Error: WP_DB_USER is not set!"
  exit 1
fi
# v.2
# : "${WP_DB_NAME?Missing WP_DB_NAME}"
# : "${WP_DB_USER?Missing WP_DB_USER}"

echo "📋 Configuration:"
echo "  Database: $WP_DB_NAME"
echo "  User:     $WP_DB_USER"

# 📦 If the DB is not initialized, run the setup
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "📦 First boot: initializing database..."
    mysqld --initialize-insecure --user=mysql --datadir=/var/lib/mysql

    # Start MariaDB in the background for setup
    mysqld_safe --datadir=/var/lib/mysql &
    sleep 5

    # Create DB and user
    mysql -u root <<-EOSQL
        ALTER USER 'root'@'localhost' IDENTIFIED BY '$WP_DB_ROOT_PASSWORD';
        CREATE DATABASE IF NOT EXISTS \`$WP_DB_NAME\`;
		CREATE USER IF NOT EXISTS '$WP_DB_USER'@'localhost' IDENTIFIED BY '$WP_DB_PASSWORD';
        CREATE USER IF NOT EXISTS '$WP_DB_USER'@'%' IDENTIFIED BY '$WP_DB_PASSWORD';
		GRANT ALL PRIVILEGES ON \`$WP_DB_NAME\`.* TO '$WP_DB_USER'@'localhost';
        GRANT ALL PRIVILEGES ON \`$WP_DB_NAME\`.* TO '$WP_DB_USER'@'%';
        FLUSH PRIVILEGES;
EOSQL

    # Shutdown background MariaDB
    mysqladmin -uroot -p"$WP_DB_ROOT_PASSWORD" shutdown
    echo "✅ Database initialized."
fi

# Start MariaDB in foreground (as PID 1)
echo "Starting MariaDB server..."
exec mysqld_safe --datadir=/var/lib/mysql
