#!/bin/bash
set -e

echo "Starting MariaDB initialization "

WP_DB_PASSWORD=$(cat /run/secrets/db_password)
WP_DB_ROOT_PASSWORD=$(cat /run/secrets/db_root_password)

sevice mariadb start

until mariadb-admin ping --silent; do
    sleep 1
done

    # Create DB and user
mysql -u root <<-EOSQL

    CREATE DATABASE IF NOT EXISTS \`${WP_DB_NAME}\`;
    CREATE USER IF NOT EXISTS '${WP_DB_USER}'@'%' IDENTIFIED BY '${WP_DB_PASSWORD}';
    GRANT ALL PRIVILEGES ON \`${WP_DB_NAME}\`.* TO '${WP_DB_USER}'@'%';
    FLUSH PRIVILEGES;
EOSQL


mysqladmin shutdown --socket=/var/run/mysqld/mysqld.sock -u root

exec mysqld