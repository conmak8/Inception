FROM debian:11

# Install MariaDB server 
RUN apt-get update && \
    apt-get install -y mariadb-server pwgen curl && \
    rm -rf /var/lib/apt/lists/*

# Create and set proper permissions for MariaDB data directory
RUN mkdir -p /var/lib/mysql && \
    chown -R mysql:mysql /var/lib/mysql && \
    chmod 755 /var/lib/mysql

# Set up the working directory 
WORKDIR /usr/local/bin

# Copy your custom entrypoint script
COPY tools/mariadb_entrypoint.sh /usr/local/bin/mariadb_entrypoint.sh
RUN chmod +x /usr/local/bin/mariadb_entrypoint.sh


ENTRYPOINT ["/usr/local/bin/mariadb_entrypoint.sh"]

# Test that is running
# --------------------------------------------
# docker compose build mariadb
# docker compose up mariadb
# docker logs mariadb
# docker exec -it mariadb mysql -u wp_user -p
