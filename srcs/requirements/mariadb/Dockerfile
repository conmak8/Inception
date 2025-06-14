# # 🏗️ Use the official Debian base (penultimate stable per subject)
# FROM debian:11

# # 🧰 Install MariaDB
# RUN apt-get update && \
#     apt-get install -y mariadb-server && \
#     rm -rf /var/lib/apt/lists/*

# # 🔧 Copy custom config file
# COPY conf/my.cnf /etc/mysql/my.cnf

# # 📂 Copy secure entrypoint script
# COPY tools/mariadb_entrypoint.sh /usr/local/bin/
# RUN chmod +x /usr/local/bin/mariadb_entrypoint.sh

# # # Ensure correct ownership for MariaDB data directory at build-time
# # RUN mkdir -p /var/lib/mysql && chown -R 999:999 /var/lib/mysql

# # Make a new clean directory, Docker won't override it with a volume
# # RUN mkdir -p /var/lib/mysql-files && chown -R 999:999 /var/lib/mysql-files

# RUN mkdir -p /var/lib/mysql /var/lib/mysql-files /run/mysqld \
#     && chown -R mysql:mysql /var/lib/mysql /var/lib/mysql-files /run/mysqld


# # 🚀 Launch MariaDB securely
# ENTRYPOINT ["/usr/local/bin/mariadb_entrypoint.sh"]

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

# 🏗️ Create necessary directories with proper ownership
RUN mkdir -p /var/lib/mysql /var/lib/mysql-files /run/mysqld /var/log/mysql \
    && chown -R mysql:mysql /var/lib/mysql /var/lib/mysql-files /run/mysqld /var/log/mysql \
    && chmod 755 /var/lib/mysql /var/lib/mysql-files /run/mysqld

# 🔐 Expose the MariaDB port
EXPOSE 3306

# 🚀 Launch MariaDB securely
ENTRYPOINT ["/usr/local/bin/mariadb_entrypoint.sh"]