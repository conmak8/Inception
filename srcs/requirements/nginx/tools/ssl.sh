#!/bin/sh

# 💡 Generate a self-signed certificate valid for 365 days
openssl req -x509 -nodes -days 365 \
  -subj "/C=DE/ST=BW/L=Heilbronn/O=42/CN=localhost" \
  -newkey rsa:2048 \
  -keyout /etc/ssl/private/key.pem \
  -out /etc/ssl/certs/cert.pem
