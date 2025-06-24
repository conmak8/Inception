FROM debian:11

# Install MariaDB server 
RUN apt-get update && \
    apt-get install -y mariadb-server pwgen curl && \
    rm -rf /var/lib/apt/lists/*

# Set up the working directory 
WORKDIR /usr/local/bin

# Copy your custom entrypoint script
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# 🐳 Tell Docker this script is the entrypoint!
ENTRYPOINT ["/usr/local/bin/mariadb_entrypoint.sh"]
