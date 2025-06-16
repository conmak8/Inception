#!/bin/sh

# 📢 Entry script for Nginx with SSL

# ✅ Generate SSL certs if missing
if [ ! -f /etc/ssl/certs/cert.pem ] || [ ! -f /etc/ssl/private/key.pem ]; then
  echo "🔐 Generating SSL certificates..."
  /usr/local/bin/ssl.sh
else
  echo "🔐 SSL certificates already exist"
fi

# 🚀 Start Nginx
echo "🟢 Launching Nginx..."
exec nginx -g "daemon off;"
