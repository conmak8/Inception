# 🏗️ Use the official Debian base (penultimate stable per subject)
FROM debian:11

# 🧰 Install MariaDB
RUN apt-get update && \
    apt-get install -y mariadb-server && \
    rm -rf /var/lib/apt/lists/*

# 🔧 Copy custom config file
COPY conf/my.cnf /etc/mysql/my.cnf

# 📂 Copy secure entrypoint script
COPY tools/mariadb_entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/mariadb_entrypoint.sh

# # Ensure correct ownership for MariaDB data directory at build-time
# RUN mkdir -p /var/lib/mysql && chown -R 999:999 /var/lib/mysql

# Make a new clean directory, Docker won't override it with a volume
RUN mkdir -p /var/lib/mysql-files && chown -R 999:999 /var/lib/mysql-files

# 🚀 Launch MariaDB securely
ENTRYPOINT ["/usr/local/bin/mariadb_entrypoint.sh"]
