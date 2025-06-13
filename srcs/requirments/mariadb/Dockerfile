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

# 🚀 Launch MariaDB securely
ENTRYPOINT ["/usr/local/bin/mariadb_entrypoint.sh"]
