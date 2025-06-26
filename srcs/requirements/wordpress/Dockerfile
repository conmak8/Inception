# Use Debian Bullseye as the base image
FROM debian:bullseye

# Update and install dependencies including PHP 7.4
RUN apt-get update && apt-get install -y \
    php7.4 \
    php7.4-fpm \
    php7.4-mysql \
    curl

# Install WordPress CLI
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x wp-cli.phar && \
    mv wp-cli.phar /usr/local/bin/wp

# Copy the WordPress setup script
COPY ./tools/setup_wp.sh /usr/local/bin/setup_wp.sh
RUN chmod +x /usr/local/bin/setup_wp.sh

# Set the entrypoint to the setup script
CMD ["/usr/local/bin/setup_wp.sh"]