FROM debian:bullseye

# 🧰 Install PHP, extensions, MariaDB client, and WP-CLI deps
RUN apt-get update && apt-get install -y \
    php php-fpm php-mysql php-curl php-gd php-mbstring php-xml php-intl php-zip \
    mariadb-client curl less unzip wget tar \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# 🧙 Install WP-CLI (optional, but nice for scripting)
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x wp-cli.phar && mv wp-cli.phar /usr/local/bin/wp

# 📁 Create working directory for WordPress
RUN mkdir -p /var/www/html

# 🔑 Make sure /run/secrets exists for Docker secrets
RUN mkdir -p /run/secrets

# 👾 Copy custom entrypoint script (handles download/config/setup)
COPY tools/wordPress_entrypoint.sh /usr/local/bin/wordPress_entrypoint.sh
RUN chmod +x /usr/local/bin/wordPress_entrypoint.sh

# ⚙️ Adjust PHP-FPM for Docker networking
RUN sed -i "s|listen = /run/php/php.*-fpm.sock|listen = 9000|" \
    /etc/php/*/fpm/pool.d/www.conf || true

# 📁 Set recommended permissions for www-data
RUN chown -R www-data:www-data /var/www/html

EXPOSE 9000

ENTRYPOINT ["/usr/local/bin/wordPress_entrypoint.sh"]
