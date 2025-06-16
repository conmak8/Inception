# 💡 Generate a self-signed certificate valid for 365 days
#!/bin/sh

# 📁 Create local test dir for certs
mkdir -p ./tmp_certs

echo "🔐 Generating SSL cert..."
openssl req -x509 -nodes -days 365 \
  -subj "/C=DE/ST=BW/L=Heilbronn/O=42/CN=localhost" \
  -newkey rsa:2048 \
  -keyout ./tmp_certs/key.pem \
  -out ./tmp_certs/cert.pem

echo "✅ Certs written to ./tmp_certs/"
