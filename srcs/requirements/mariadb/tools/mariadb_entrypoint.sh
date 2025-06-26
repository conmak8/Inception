#!/bin/bash
set -e

echo "Starting MariaDB initialization "

WP_DB_PASSWORD=$(cat /run/secrets/db_password)
WP_DB_ROOT_PASSWORD=$(cat /run/secrets/db_root_password)

# 1. Start MariaDB in background for setup
mysqld_safe --datadir=/var/lib/mysql --user=mysql &
MYSQL_PID=$!

# 2. Wait for MariaDB to be ready
until mysqladmin ping --silent; do
    sleep 1
done

# 3. Create DB and user
mysql -u root <<-EOSQL

    CREATE DATABASE IF NOT EXISTS \`${WP_DB_NAME}\`;
    CREATE USER IF NOT EXISTS '${WP_DB_USER}'@'%' IDENTIFIED BY '${WP_DB_PASSWORD}';
    GRANT ALL PRIVILEGES ON \`${WP_DB_NAME}\`.* TO '${WP_DB_USER}'@'%';
    FLUSH PRIVILEGES;
EOSQL

# 4. Shut down background MariaDB
mysqladmin -uroot shutdown

# 5. Wait for background process to stop
wait $MYSQL_PID
exec mysqld