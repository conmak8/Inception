#!/bin/bash
set -e

echo "🚀 Starting MariaDB initialization..."

# Read secrets
DB_PASSWORD=$(cat /run/secrets/db_password)
DB_ROOT_PASSWORD=$(cat /run/secrets/db_root_password)

# Initialize database if not exists
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "📦 Installing database..."
    mysql_install_db --user=mysql --datadir=/var/lib/mysql
    
    echo "🔧 Starting temporary MySQL server..."
    mysqld_safe --user=mysql --datadir=/var/lib/mysql &
    
    # Wait for MySQL to be ready
    while ! mysqladmin ping --silent; do
        echo "⏳ Waiting for MySQL..."
        sleep 1
    done
    
    echo "👤 Creating database and user..."
    mysql -u root <<EOF
SET @@SESSION.SQL_LOG_BIN=0;
DELETE FROM mysql.user WHERE user NOT IN ('mysql.sys', 'mysqlxsys', 'root') OR host NOT IN ('localhost');
SET PASSWORD FOR 'root'@'localhost'=PASSWORD('${DB_ROOT_PASSWORD}');
GRANT ALL ON *.* TO 'root'@'localhost' WITH GRANT OPTION;
FLUSH PRIVILEGES;

CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${DB_PASSWORD}';
GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';
FLUSH PRIVILEGES;
EOF
    
    echo "🛑 Stopping temporary server..."
    mysqladmin shutdown -p${DB_ROOT_PASSWORD}
    
    echo "✅ Database initialized!"
fi

echo "🌟 Starting MariaDB server..."
exec mysqld_safe --user=mysql --datadir=/var/lib/mysql