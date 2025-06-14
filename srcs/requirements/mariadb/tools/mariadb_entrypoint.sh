#!/bin/sh
# mariadb_entrypoint.sh
# Custom MariaDB initialization logic using bootstrap mode

# Load secrets from Docker secrets file mounts
WP_DB_PASSWORD=$(cat /run/secrets/db_password)
WP_DB_ROOT_PASSWORD=$(cat /run/secrets/db_root_password)

# echo "📦 [INIT] Fixing volume ownership..."
# chown -R 999:999 /var/lib/mysql

# Check if the database directory already exists (i.e. first boot or not)
if [ ! -d "/var/lib/mysql/${WP_DB_NAME}" ]; then
    echo "📦 First boot: initializing database..."

    # Use bootstrap mode to run SQL directly *before* full MariaDB starts
    mariadbd --user=mysql --bootstrap --console <<EOF

-- Switch to system DB
USE mysql;

-- Clean up any default insecure stuff
FLUSH PRIVILEGES;
DELETE FROM mysql.user WHERE User='';
DROP DATABASE IF EXISTS test;
DELETE FROM mysql.db WHERE Db='test';
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');

-- Create the app DB and user
CREATE DATABASE ${WP_DB_NAME};
CREATE USER '${WP_DB_USER}'@'%' IDENTIFIED BY '${WP_DB_PASSWORD}';
GRANT ALL PRIVILEGES ON ${WP_DB_NAME}.* TO '${WP_DB_USER}'@'%';

-- Set root password
ALTER USER 'root'@'localhost' IDENTIFIED BY '${WP_DB_ROOT_PASSWORD}';
FLUSH PRIVILEGES;
EOF

else
    echo "✅ Database already initialized, starting normally..."
    mariadbd --user=mysql --console
fi
