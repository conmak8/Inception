# 🏗️ Use Debian Bullseye as base image
FROM debian:bullseye

# 🧰 Update package lists and install MariaDB server
RUN apt-get update && \
    apt-get install -y mariadb-server && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# 🔧 Create necessary directories and set permissions BEFORE switching user
RUN mkdir -p /run/mysqld /var/lib/mysql && \
    chown -R mysql:mysql /run/mysqld /var/lib/mysql && \
    chmod 755 /run/mysqld

# 📁 Copy custom configuration
COPY conf/my.cnf /etc/mysql/my.cnf

# 📋 Copy the entrypoint script
COPY tools/mariadb_entrypoint.sh /usr/local/bin/mariadb_entrypoint.sh
RUN chmod +x /usr/local/bin/mariadb_entrypoint.sh

# 🚪 Expose MariaDB port
EXPOSE 3306

# 👤 Switch to mysql user for security
USER mysql

# 🚀 Use the entrypoint script
ENTRYPOINT ["/usr/local/bin/mariadb_entrypoint.sh"]
