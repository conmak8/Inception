# #!/bin/sh

# # 📢 Entry script for Nginx with SSL

# # ✅ Generate SSL certs if missing
# if [ ! -f /etc/ssl/certs/cert.pem ] || [ ! -f /etc/ssl/private/key.pem ]; then
#   echo "🔐 Generating SSL certificates..."
#   /usr/local/bin/ssl.sh
# else
#   echo "🔐 SSL certificates already exist"
# fi

# # 🚀 Start Nginx
# echo "🟢 Launching Nginx..."
# exec nginx -g "daemon off;"


#!/bin/sh

echo "🔐 Generating SSL cert..."

# Temp dir for generation
TMP_CERTS="/tmp/certs"
mkdir -p "$TMP_CERTS"

# Run the generator into tmp
sh /usr/local/bin/ssl.sh "$TMP_CERTS"

# Then move to nginx expected location
mv "$TMP_CERTS/cert.pem" /etc/ssl/certs/cert.pem
mv "$TMP_CERTS/key.pem" /etc/ssl/private/key.pem

echo "✅ Moved certs to /etc/ssl/{certs,private}"

# 🚀 Start Nginx
echo "🟢 Launching Nginx..."
exec nginx -g "daemon off;"
