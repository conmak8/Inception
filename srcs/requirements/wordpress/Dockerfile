FROM debian:11

# Install PHP, extensions, and dependencies
RUN apt-get update && \
    apt-get install -y php php-mysql php7.4-fpm curl mariadb-client && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Install WP-CLI
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x wp-cli.phar && mv wp-cli.phar /usr/local/bin/wp

# Create a working directory
RUN mkdir -p /var/www/html
# All following commands run in /var/www/html
WORKDIR /var/www/html

# Copy custom entrypoint
COPY tools/wp_entrypoint.sh /usr/local/bin/wp_entrypoint.sh
RUN chmod +x /usr/local/bin/wp_entrypoint.sh

ENTRYPOINT ["/usr/local/bin/wp_entrypoint.sh"]
