FROM debian:11

# 🏗️ Install Nginx + OpenSSL
RUN apt-get update && \
    apt-get install -y nginx openssl && \
    rm -rf /var/lib/apt/lists/* && \
    # 🔐 make sure the cert/key folders exist
    mkdir -p /etc/ssl/cert /etc/ssl/private

# 📄 Global Nginx config
COPY conf/nginx.conf /etc/nginx/nginx.conf

# 🔑 Copy your certificate + key (adjust names if you use different ones)
COPY tools/ssl/cmakario.42.de.crt /etc/ssl/cert/
COPY tools/ssl/cmakario.42.de.key /etc/ssl/private/

# 🌍 Expose both ports
EXPOSE 80 443

CMD ["nginx", "-g", "daemon off;"]
