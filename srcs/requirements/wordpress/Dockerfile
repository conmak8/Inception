# ✅ Base image
FROM debian:11

# 🧰 Install dependencies
RUN apt-get update && apt-get install -y \
    php php-fpm php-mysql php-curl php-gd php-mbstring php-xml php-xmlrpc php-soap php-intl php-zip \
    curl wget tar unzip less vim \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# 📁 Create necessary WordPress dir
RUN mkdir -p /var/www/html

# ⬇️ Download latest WordPress
WORKDIR /tmp
RUN curl -o wordpress.tar.gz https://wordpress.org/latest.tar.gz && \
    tar -xzf wordpress.tar.gz && \
    mv wordpress/* /var/www/html && \
    rm -rf wordpress wordpress.tar.gz

# 🔐 Copy custom config file & entrypoint
COPY wp-config.php /var/www/html/wp-config.php
COPY tools/wp_config.sh /usr/local/bin/wp_config.sh

# 📜 Ensure permissions & execution
RUN chmod +x /usr/local/bin/wp_config.sh && \
    chown -R www-data:www-data /var/www/html

# 🔁 Set working directory for the container
WORKDIR /var/www/html

# 🚪 Expose internal port (FPM style)
EXPOSE 9000

# 🚀 Entrypoint
ENTRYPOINT ["wp_config.sh"]
