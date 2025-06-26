# Use Debian Bullseye as the base image
FROM debian:bullseye

# Update and install Nginx and OpenSSL
RUN apt-get update && apt-get install -y nginx openssl

# Generate a self-signed SSL certificate
RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/ssl/private/nginx-selfsigned.key \
    -out /etc/ssl/certs/nginx-selfsigned.crt \
    -subj "/C=DE/ST=BW/L=Heilbronn/O=42/CN=cmakario.42.de"

# Copy the Nginx configuration file
COPY ./conf/nginx.conf /etc/nginx/sites-available/default

# Set the entrypoint to start Nginx
CMD ["nginx", "-g", "daemon off;"]