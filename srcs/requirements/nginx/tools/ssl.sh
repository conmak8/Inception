#!/bin/sh
# # 💡 Generate a self-signed certificate valid for 365 days

# # 📁 Create local test dir for certs
# mkdir -p ./tmp_certs

# echo "🔐 Generating SSL cert..."
# openssl req -x509 -nodes -days 365 \
#   -subj "/C=DE/ST=BW/L=Heilbronn/O=42/CN=localhost" \
#   -newkey rsa:2048 \
#   -keyout ./tmp_certs/key.pem \
#   -out ./tmp_certs/cert.pem

# echo "✅ Certs written to ./tmp_certs/"

# OUTDIR=${1:-/tmp/certs}
# mkdir -p "$OUTDIR"

# openssl req -x509 -nodes -days 365 \
#   -newkey rsa:2048 \
#   -keyout "$OUTDIR/key.pem" \
#   -out "$OUTDIR/cert.pem" \
#   -subj "/C=DE/ST=BW/L=Heilbronn/O=42Inception/CN=localhost"

# echo "✅ Certs written to $OUTDIR"




# ✅ Flexible output directory (default: /tmp/certs)
OUTDIR=${1:-/tmp/certs}
DOMAIN=${2:-cmakario.42.de}

mkdir -p "$OUTDIR"

# ✅ Generate key + cert for specified domain
openssl req -x509 -nodes -days 365 \
  -newkey rsa:2048 \
  -keyout "$OUTDIR/${DOMAIN}.key" \
  -out "$OUTDIR/${DOMAIN}.crt" \
  -subj "/C=DE/ST=BW/L=Heilbronn/O=42Inception/CN=${DOMAIN}"

echo "✅ TLS certificate generated for https://${DOMAIN}"
echo "🔑 Private Key: $OUTDIR/${DOMAIN}.key"
echo "📄 Certificate: $OUTDIR/${DOMAIN}.crt"
