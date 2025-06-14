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

# # 🚀 Launch MariaDB securely
# ENTRYPOINT ["/usr/local/bin/mariadb_entrypoint.sh"]

# Use Debian Bullseye as base image
FROM debian:bullseye

# Update package lists and install MariaDB server
RUN apt-get update && \
    apt-get install -y mariadb-server && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Create the mysqld run directory and set proper permissions
RUN mkdir -p /run/mysqld && \
    chown mysql:mysql /run/mysqld && \
    chmod 755 /run/mysqld

# Create the MariaDB data directory if it doesn't exist
RUN mkdir -p /var/lib/mysql && \
    chown mysql:mysql /var/lib/mysql

# Copy the configuration script
COPY tools/mariadb_config.sh /usr/local/bin/mariadb_config.sh

# Make the script executable
RUN chmod +x /usr/local/bin/mariadb_config.sh

# Expose the MariaDB port
EXPOSE 3306

# Set the user to mysql (security best practice)
USER mysql

# Run the configuration script
CMD ["/usr/local/bin/mariadb_config.sh"]