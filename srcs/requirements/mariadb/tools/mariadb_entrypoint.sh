#!/bin/bash
set -e

echo "Starting MariaDB initialization 🚀"

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

# Environment variables validation
if [ -z "$WP_DB_NAME" ]; then
  echo "❌ Error: WP_DB_NAME is not set!"
  exit 1
fi
if [ -z "$WP_DB_USER" ]; then
  echo "❌ Error: WP_DB_USER is not set!"
  exit 1
fi

echo "📋 Configuration:"
echo "  Database: $WP_DB_NAME"
echo "  User:     $WP_DB_USER"

INIT_MARKER="/var/lib/mysql/.db-initialized"

# 📦 If the DB is not initialized, run the setup
if [ ! -f "/var/lib/mysql/.db-initialized" ]; then
    echo "📦 First boot: initializing database..."
     mysql_install_db --user=mysql --datadir=/var/lib/mysql --rpm

    # Start MariaDB in the background for setup
    mysqld_safe --datadir=/var/lib/mysql --user=mysql &
    sleep 5

    # Create DB and user
mysql -u root <<-EOSQL
    ALTER USER 'root'@'localhost' IDENTIFIED BY '$WP_DB_ROOT_PASSWORD';
    CREATE DATABASE IF NOT EXISTS \`$WP_DB_NAME\` CHARACTER SET utf8 COLLATE utf8_general_ci;
    CREATE USER IF NOT EXISTS '$WP_DB_USER'@'localhost' IDENTIFIED BY '$WP_DB_PASSWORD';
    CREATE USER IF NOT EXISTS '$WP_DB_USER'@'%' IDENTIFIED BY '$WP_DB_PASSWORD';
    GRANT ALL PRIVILEGES ON \`$WP_DB_NAME\`.* TO '$WP_DB_USER'@'localhost';
    GRANT ALL PRIVILEGES ON \`$WP_DB_NAME\`.* TO '$WP_DB_USER'@'%';
    FLUSH PRIVILEGES;
EOSQL


    # Shutdown background MariaDB
    mysqladmin -uroot -p"$WP_DB_ROOT_PASSWORD" shutdown
	touch "$INIT_MARKER"
    echo "✅ Database initialized."
fi

# 🚀 Start MariaDB in foreground (as PID 1)
echo "🌟 Starting MariaDB server in foreground..."
exec mysqld_safe --datadir=/var/lib/mysql --user=mysql