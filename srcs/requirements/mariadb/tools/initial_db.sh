#!/bin/bash

# Start the MariaDB service in the background
mysqld_safe --datadir=/var/lib/mysql &

# Wait for MariaDB to be ready
while ! mysqladmin ping --silent; do
    sleep 1
done

# Create database and user for WordPress
mysql -u root -e "CREATE DATABASE IF NOT EXISTS ${DB_NAME};"
mysql -u root -e "CREATE USER IF NOT EXISTS '${DB_USER}'@'%' IDENTIFIED BY '${DB_PASSWORD}';"
mysql -u root -e "GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'%';"
mysql -u root -e "FLUSH PRIVILEGES;"

# Set root password
mysql -u root -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASSWORD}';"

# Bring the background MariaDB process to the foreground to keep the container running
wait