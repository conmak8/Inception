FROM debian:11

RUN apt-get update && \
    apt-get install -y nginx openssl && \
    rm -rf /var/lib/apt/lists/*

# Copy config and SSL certs
COPY conf/nginx.conf /etc/nginx/nginx.conf
COPY tools/ssl/ /etc/ssl/

CMD ["nginx", "-g", "daemon off;"]

EXPOSE 443
