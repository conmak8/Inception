FROM debian:11

# Install PHP, extensions, and dependencies
RUN apt-get update && \
    apt-get install -y php php-fpm php-mysql curl less unzip wget tar mariadb-client && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Install WP-CLI
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x wp-cli.phar && mv wp-cli.phar /usr/local/bin/wp

# Create working directory for WordPress files
RUN mkdir -p /var/www/html
WORKDIR /var/www/html

# Copy custom entrypoint script
COPY tools/wp_entrypoint.sh /usr/local/bin/wp_entrypoint.sh
RUN chmod +x /usr/local/bin/wp_entrypoint.sh

EXPOSE 9000

ENTRYPOINT ["/usr/local/bin/wp_entrypoint.sh"]
