FROM debian:bullseye

# Install nginx and OpenSSL for SSL cert generation
RUN apt-get update && \
    apt-get install -y nginx openssl && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Copy custom nginx.conf and site config
COPY conf/nginx.conf /etc/nginx/nginx.conf
COPY conf/default.conf /etc/nginx/conf.d/default.conf

# Copy SSL cert/key if you want to generate them on host
COPY conf/cmakario.42.de.crt /etc/ssl/certs/
COPY conf/cmakario.42.de.key /etc/ssl/private/

# Copy an entrypoint script to auto-generate certs at container start
COPY tools/nginx_entrypoint.sh /nginx_entrypoint.sh
RUN chmod +x /nginx_entrypoint.sh

EXPOSE 443

ENTRYPOINT ["/nginx_entrypoint.sh"]
