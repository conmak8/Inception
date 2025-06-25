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

# 📦 If the DB is not initialized, run the setup
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "📦 First boot: initializing database..."
    
    # 🔧 FIXED: Use MariaDB's initialization method
    mysql_install_db --user=mysql --datadir=/var/lib/mysql --rpm --auth-root-authentication-method=normal
    
    # Start MariaDB in the background for setup
    mysqld_safe --datadir=/var/lib/mysql --user=mysql &
    
    # 🕐 Wait for MariaDB to be ready (more robust waiting)
    echo "⏳ Waiting for MariaDB to start..."
    for i in {30..0}; do
        if mysqladmin ping --silent; then
            break
        fi
        echo "⏳ MariaDB is unavailable - sleeping ($i seconds remaining)"
        sleep 1
    done
    
    if [ "$i" = 0 ]; then
        echo "❌ MariaDB startup timeout!"
        exit 1
    fi
    
    echo "✅ MariaDB is ready!"
    
    # Create DB and user
    mysql -u root <<-EOSQL
        SET @@SESSION.SQL_LOG_BIN=0;
        ALTER USER 'root'@'localhost' IDENTIFIED BY '$WP_DB_ROOT_PASSWORD';
        
        CREATE DATABASE IF NOT EXISTS \`$WP_DB_NAME\` CHARACTER SET utf8 COLLATE utf8_general_ci;
        
        CREATE USER IF NOT EXISTS '$WP_DB_USER'@'localhost' IDENTIFIED BY '$WP_DB_PASSWORD';
        CREATE USER IF NOT EXISTS '$WP_DB_USER'@'%' IDENTIFIED BY '$WP_DB_PASSWORD';
        
        GRANT ALL PRIVILEGES ON \`$WP_DB_NAME\`.* TO '$WP_DB_USER'@'localhost';
        GRANT ALL PRIVILEGES ON \`$WP_DB_NAME\`.* TO '$WP_DB_USER'@'%';
        
        FLUSH PRIVILEGES;
EOSQL

    # Shutdown background MariaDB gracefully
    echo "🛑 Shutting down temporary MariaDB instance..."
    mysqladmin -uroot -p"$WP_DB_ROOT_PASSWORD" shutdown
    
    echo "✅ Database initialized successfully!"
else
    echo "📂 Database already exists, skipping initialization"
fi

# 🚀 Start MariaDB in foreground (as PID 1)
echo "🌟 Starting MariaDB server in foreground..."
exec mysqld_safe --datadir=/var/lib/mysql --user=mysql