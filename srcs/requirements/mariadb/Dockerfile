# Use Debian Bullseye as the base image
FROM debian:bullseye

# Update and install MariaDB server
RUN apt-get update && apt-get install -y mariadb-server

# Copy the database initialization script
COPY ./tools/initial_db.sh /usr/local/bin/initial_db.sh
RUN chmod +x /usr/local/bin/initial_db.sh

# Set the entrypoint to the initialization script
CMD ["/usr/local/bin/initial_db.sh"]