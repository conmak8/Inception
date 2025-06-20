#!/bin/bash

# Define source and destination paths
SOURCE_SECRETS="/home/mak/Desktop/extraFiles/secrets/"
DEST_SECRETS="/home/mak/Desktop/InceptionV2/"

SOURCE_ENV="/home/mak/Desktop/extraFiles/.env"
DEST_ENV="/home/mak/Desktop/InceptionV2/srcs/"

# Copy secrets folder
echo "Copying secrets folder..."
cp -r "$SOURCE_SECRETS" "$DEST_SECRETS"

echo "Files copied successfully!"

# -------------------- #
# Define variables for better readability and easier modification
MARIADB_DATA_DIR="/home/mak/data/mariadb"
WORDPRESS_DATA_DIR="/home/mak/data/wordpress"
MARIADB_UID_GID="999:999" # Common UID:GID for mariadb in containers
WORDPRESS_USER_GROUP="www-data:www-data" # Standard user:group for web servers

echo "--- Setting up data directories ---"

# Create directories if they don't exist
if [ ! -d "$MARIADB_DATA_DIR" ]; then
  echo "Creating directory: $MARIADB_DATA_DIR"
  sudo mkdir -p "$MARIADB_DATA_DIR" || { echo "Error: Failed to create $MARIADB_DATA_DIR"; exit 1; }
else
  echo "$MARIADB_DATA_DIR already exists."
fi

if [ ! -d "$WORDPRESS_DATA_DIR" ]; then
  echo "Creating directory: $WORDPRESS_DATA_DIR"
  sudo mkdir -p "$WORDPRESS_DATA_DIR" || { echo "Error: Failed to create $WORDPRESS_DATA_DIR"; exit 1; }
else
  echo "$WORDPRESS_DATA_DIR already exists."
fi

# Set correct ownership
echo "Setting ownership for $MARIADB_DATA_DIR to $MARIADB_UID_GID"
sudo chown -R "$MARIADB_UID_GID" "$MARIADB_DATA_DIR" || { echo "Error: Failed to set ownership for $MARIADB_DATA_DIR"; exit 1; }

echo "Setting ownership for $WORDPRESS_DATA_DIR to $WORDPRESS_USER_GROUP"
sudo chown -R "$WORDPRESS_USER_GROUP" "$WORDPRESS_DATA_DIR" || { echo "Error: Failed to set ownership for $WORDPRESS_DATA_DIR"; exit 1; }

# Set proper permissions
echo "Setting permissions for $MARIADB_DATA_DIR to 755"
sudo chmod -R 755 "$MARIADB_DATA_DIR" || { echo "Error: Failed to set permissions for $MARIADB_DATA_DIR"; exit 1; }

# For WordPress, 755 for directories and 644 for files are standard best practices.
echo "Setting permissions for $WORDPRESS_DATA_DIR (directories to 755, files to 644)"
sudo find "$WORDPRESS_DATA_DIR" -type d -exec sudo chmod 755 {} \; || { echo "Error: Failed to set directory permissions for $WORDPRESS_DATA_DIR"; exit 1; }
sudo find "$WORDPRESS_DATA_DIR" -type f -exec sudo chmod 644 {} \; || { echo "Error: Failed to set file permissions for $WORDPRESS_DATA_DIR"; exit 1; }

echo "--- Data directory setup complete ---"

# -------------------- #
# Create .env file inside srcs if it doesn't already exist
ENV_FILE="$DEST_ENV/.env"
if [ ! -f "$ENV_FILE" ]; then
  echo "--- Creating .env file ---"
  cat <<EOL > "$ENV_FILE"
# 💾 MariaDB Configuration - Safe values only (non-sensitive)
WP_DB_NAME=wordpress
WP_DB_USER=wp_user

# 🌐 WordPress DB Settings
WORDPRESS_DB_NAME=wordpress
WORDPRESS_DB_USER=wp_user
WORDPRESS_DB_HOST=mariadb

# 🌍 WordPress Site Info
WP_URL=https://cmakario.42.de         # or http:// if no SSL yet
WP_TITLE="Mak's Epic Site"

# 👤 WordPress Admin Credentials (for now testing only)
WP_ADMIN_USER=admin
WP_ADMIN_PASSWORD=adminpass
WP_ADMIN_EMAIL=admin@example.com

# 🔐 Security Note: Change these passwords to strong, unique values!
# Use a password generator for production environments
EOL
  echo ".env file created at $ENV_FILE"
else
  echo ".env file already exists at $ENV_FILE"
fi

echo "--- Script completed successfully ---"
