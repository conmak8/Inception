FROM debian:11

# 🔧 Install Nginx + OpenSSL
RUN apt-get update && apt-get install -y \
  nginx openssl && \
  apt-get clean && rm -rf /var/lib/apt/lists/*

# 🧰 Create necessary dirs
RUN mkdir -p /etc/ssl/certs /etc/ssl/private

# 📥 Copy config + tools
COPY conf/default.conf /etc/nginx/sites-available/default
COPY tools/ssl.sh /usr/local/bin/ssl.sh
COPY tools/nginx_entrypoint.sh /usr/local/bin/nginx_entrypoint.sh

# 📥 Copy certificates
COPY conf/cmakario.42.de.crt /etc/ssl/certs/
COPY conf/cmakario.42.de.key /etc/ssl/private/


# 🔐 Make scripts executable
RUN chmod +x /usr/local/bin/ssl.sh /usr/local/bin/nginx_entrypoint.sh

# 🔁 Forward logs to Docker stdout/stderr
RUN ln -sf /dev/stdout /var/log/nginx/access.log \
 && ln -sf /dev/stderr /var/log/nginx/error.log

# 🚪 Expose HTTPS port
EXPOSE 443

# 🚀 Entrypoint
ENTRYPOINT ["/usr/local/bin/nginx_entrypoint.sh"]


