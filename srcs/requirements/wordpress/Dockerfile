# ✅ Base image
FROM debian:11

# 🔧 Install PHP, MariaDB client, WP-CLI dependencies
RUN apt-get update && apt-get install -y \
    php php-fpm php-mysql php-curl php-gd php-mbstring php-xml php-intl php-zip \
    mariadb-client curl less unzip wget tar \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# 🧙 Install WP-CLI
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x wp-cli.phar && \
    mv wp-cli.phar /usr/local/bin/wp && \
    wp --info

# 📁 Create WordPress working directory
RUN mkdir -p /var/www/html
WORKDIR /var/www/html

# 🧠 Add custom entrypoint logic
COPY tools/wp_config.sh /usr/local/bin/wp_config.sh
RUN chmod +x /usr/local/bin/wp_config.sh

# ⚙️ PHP-FPM config fix: allow external connections
RUN sed -i "s|listen = /run/php/php.*-fpm.sock|listen = 9000|" \
    /etc/php/*/fpm/pool.d/www.conf || true

# 🚪 Expose FPM port (default PHP-FPM port)
EXPOSE 9000

# 🧠 Run the script
ENTRYPOINT ["/usr/local/bin/wp_config.sh"]