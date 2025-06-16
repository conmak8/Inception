# 🛠️ Step-by-Step for WordPress Container

1. **Create a `Dockerfile`** for WordPress using `debian:11`
2. **Install PHP & WordPress dependencies** (apache2, php, etc.)
3. **Connect to MariaDB using env vars** (DB name, user, pass)
4. **Create a persistent volume for wp-content**
5. **Expose WordPress on port 9000 internally**
6. **Test in browser through curl or container logs**

🐳
---
## 🎯 TL;DR: WordPress + MariaDB + Nginx Flow

Let’s visualize your full setup (eventually), but **focus on WordPress for now**:

```
🌍 Client (Browser)
    |
    v
📦 Nginx (Container)
    - Reverse Proxy / HTTPS
    - Listens on Port 443 (SSL) / 80
    |
    v
📦 WordPress (Container)
    - PHP App (FPM or Apache)
    - Listens on Port 9000 (internal)
    |
    v
📦 MariaDB (Container)
    - Database engine
    - Listens on Port 3306
```

---
## 📦 How WordPress Container Works

### 1. 🔌 Connects to MariaDB

* Fetches blog posts, users, admin logins, etc.
* All dynamic data is stored in DB.

### 2. 📂 WordPress Files

* `/var/www/html/` contains all PHP files.
* `wp-content` holds themes, uploads, and plugins — we’ll **mount that as a volume** to persist it.

### 3. ⚙️ Environment Variables

WordPress reads the following at boot:

| ENV Variable            | Purpose                                      | Source  |
| ----------------------- | -------------------------------------------- | ------- |
| `WORDPRESS_DB_HOST`     | IP/hostname of MariaDB (`mariadb:3306`)      | Compose |
| `WORDPRESS_DB_NAME`     | Name of your DB (`wordpress`)                | .env    |
| `WORDPRESS_DB_USER`     | DB username (`wp_user`)                      | .env    |
| `WORDPRESS_DB_PASSWORD` | DB password (from `secrets/db_password.txt`) | secrets |

All these are used inside `wp-config.php`.

---

## 🔐 Secrets Recap

We’ll *not* hardcode passwords. Instead, we’ll:

```yml
secrets:
  db_password:
    file: ../secrets/db_password.txt
```

---

## 📁 Folder Skeleton

Your updated `srcs/requirements/wordpress/` should look like this:

```
wordpress/
├── Dockerfile
├── wp-config.php          # Config file with env logic
├── tools/
│   └── wp_entrypoint.sh   # Bash script to install WordPress (if needed)
└── conf/                  # (Optional) For custom PHP-FPM config
```

And we’ll **mount `/var/www/html/wp-content` to persist uploads/themes**.

---

## 🚀 Compose Wiring Preview

```yaml
services:
  wordpress:
    build: ./requirements/wordpress
    depends_on:
      - mariadb
    ports:
      - "9000"
    environment:
      WORDPRESS_DB_HOST: mariadb:3306
      WORDPRESS_DB_NAME: ${WP_DB_NAME}
      WORDPRESS_DB_USER: ${WP_DB_USER}
    secrets:
      - db_password
    volumes:
      - wordpress_data:/var/www/html/wp-content
    networks:
      - inception_net
```

---
# 1.Dockerfile
`Version 1`

```Dockerfile
# ✅ Base image - matches Inception requirement (penultimate Debian)
FROM debian:11

# 🧑‍💻 Maintainer (optional)
LABEL maintainer="mak@42inception"

# 🧰 Install dependencies
RUN apt-get update && apt-get install -y \
    php php-fpm php-mysql php-curl php-gd php-mbstring php-xml php-xmlrpc php-soap php-intl php-zip \
    curl wget tar unzip less vim \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# 📁 Create necessary WordPress dir
RUN mkdir -p /var/www/html

# ⬇️ Download latest WordPress
WORKDIR /tmp
RUN curl -o wordpress.tar.gz https://wordpress.org/latest.tar.gz && \
    tar -xzf wordpress.tar.gz && \
    mv wordpress/* /var/www/html && \
    rm -rf wordpress wordpress.tar.gz

# 🔐 Copy custom config file & entrypoint
COPY wp-config.php /var/www/html/wp-config.php
COPY tools/wp_config.sh /usr/local/bin/wp_config.sh

# 📜 Ensure permissions & execution
RUN chmod +x /usr/local/bin/wp_config.sh && \
    chown -R www-data:www-data /var/www/html

# 🔁 Set working directory for the container
WORKDIR /var/www/html

# 🚪 Expose internal port (FPM style)
EXPOSE 9000

# 🚀 Entrypoint
ENTRYPOINT ["wp_config.sh"]
```

### explanation and improved dockerfile:
Great question! Let's break this down Docker-style 🐳✨

---

## 🧠 TL;DR

The subject *requires only WordPress with php-fpm*, **no web server like Nginx or Apache inside the WordPress container**.
So yes, **you must install `php-fpm`**, but the rest (like `php-curl`, `vim`, `less`, etc.) are *optional* and should be installed **only if needed by WordPress** or your workflow.

---

## 🔍 What does the subject want?

From the subject:

> A Docker container that contains WordPress with **php-fpm (it must be installed and configured) only, without nginx.**

👉 That means:

* ✅ `php-fpm`: must be there to process PHP.
* ✅ WordPress itself (PHP files + config).
* 🚫 No NGINX or Apache inside this container.
* 🚫 No unnecessary tools (keep it minimal, lightweight).

---

## ✅ What do you *actually* need?

Here are the PHP extensions that WordPress [recommends](https://wordpress.org/about/requirements/) and that are commonly required by themes/plugins:

```Dockerfile
RUN apt-get update && apt-get install -y \
    php php-fpm \
    php-mysql \
    php-xml php-mbstring php-curl \
    php-gd php-intl php-soap php-zip
```

📝 **Explain like I'm 5**:

* `php-mysql`: to talk to MariaDB.
* `php-xml`: for processing XML (used by plugins).
* `php-mbstring`: for UTF-8 string handling.
* `php-curl`: WordPress uses it to fetch remote content.
* `php-gd`: for image manipulation (needed by media uploads).
* `php-intl`: for internationalization.
* `php-soap`: sometimes needed by WooCommerce or APIs.
* `php-zip`: for ZIP file handling (import/export plugins).

---

## ❌ What to drop (unless you know why):

These are *not needed* in a production WordPress container:

```Dockerfile
curl wget tar unzip less vim
```

👉 They're dev tools or system utilities. Keep them out unless you're debugging or working interactively.

---
`Version 2`
## 🧽 Final Recommended Line

If you're aiming for a clean, lean container just for WordPress with php-fpm:

```Dockerfile
RUN apt-get update && apt-get install -y \
    php php-fpm \
    php-mysql \
    php-xml php-mbstring php-curl \
    php-gd php-intl php-soap php-zip \
    && apt-get clean && rm -rf /var/lib/apt/lists/*
```

That’s your sweet spot: ✔️ covers most needs, ❌ no bloat.

---

## 💡 Bonus: Use `.dockerignore` and multistage builds

To keep images light and tidy, don’t forget:

```dockerignore
*.log
*.sql
*.env
node_modules/
```
`Version 3`
# ✅ Base image (required by subject)
FROM debian:11

# 🔧 Install PHP, MariaDB client, WP-CLI dependencies
RUN apt-get update && apt-get install -y \
    php php-fpm php-mysql php-curl php-gd php-mbstring php-xml php-intl php-zip \
    mariadb-client curl less unzip wget tar \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# 🧙 Install WP-CLI
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x wp-cli.phar && \
    mv wp-cli.phar /usr/local/bin/wp && \
    wp --info

# 📁 Create WordPress working directory
RUN mkdir -p /var/www/html
WORKDIR /var/www/html

# 🧠 Add custom entrypoint logic
COPY tools/wp_config.sh /usr/local/bin/wp_config.sh
RUN chmod +x /usr/local/bin/wp_config.sh

# ⚙️ PHP-FPM config fix: allow external connections
RUN sed -i "s|listen = /run/php/php.*-fpm.sock|listen = 9000|" \
    /etc/php/*/fpm/pool.d/www.conf || true

# 🚪 Expose FPM port (default PHP-FPM port)
EXPOSE 9000

# 🧠 Run the script
ENTRYPOINT ["/usr/local/bin/wp_config.sh"]


# 2) wp_config.sh
```sh
#!/bin/bash

set -e

echo "📦 Starting WordPress setup..."

# ✅ Wait for MariaDB to be ready
echo "⏳ Waiting for MariaDB..."
until mysqladmin ping -h"${WORDPRESS_DB_HOST}" --silent; do
    sleep 2
done

# ✅ Download WordPress if not already
if [ ! -f wp-load.php ]; then
    echo "⬇️ Downloading WordPress..."
    wp core download --locale=en_US --allow-root
fi

# ✅ Generate config if not already
if [ ! -f wp-config.php ]; then
    echo "⚙️ Generating wp-config.php..."
    wp config create \
        --dbname="${WORDPRESS_DB_NAME}" \
        --dbuser="${WORDPRESS_DB_USER}" \
        --dbpass="$(cat /run/secrets/db_password)" \
        --dbhost="${WORDPRESS_DB_HOST}" \
        --path=/var/www/html \
        --skip-check \
        --allow-root
fi

# ✅ Install WordPress if not installed
if ! wp core is-installed --allow-root; then
    echo "🧱 Installing WordPress..."
    wp core install \
        --url="${WP_URL}" \
        --title="${WP_TITLE}" \
        --admin_user="${WP_ADMIN_USER}" \
        --admin_password="${WP_ADMIN_PASSWORD}" \
        --admin_email="${WP_ADMIN_EMAIL}" \
        --skip-email \
        --allow-root
fi

# ✅ Fix permissions
chown -R www-data:www-data /var/www/html

# 🚀 Start PHP-FPM
echo "🚀 Launching PHP-FPM..."
exec php-fpm7.4 -F
```

# 3) Required .env Variables (non-secret part)
Add to your srcs/.env:
```
WORDPRESS_DB_NAME=wordpress
WORDPRESS_DB_USER=wp_user
WORDPRESS_DB_HOST=mariadb

WP_URL=https://localhost
WP_TITLE="Mak's Docker Site"
WP_ADMIN_USER=admin
WP_ADMIN_PASSWORD=adminpass
WP_ADMIN_EMAIL=admin@example.com
```
# 4) Update .Yaml file

```yaml
services:
  mariadb:
    build: ./requirements/mariadb
    container_name: mariadb
    restart: unless-stopped

    environment:
      WP_DB_NAME: ${WP_DB_NAME}
      WP_DB_USER: ${WP_DB_USER}

    secrets:
      - db_password
      - db_root_password

    volumes:
      - /home/mak/data/mariadb:/var/lib/mysql

    networks:
      - inception_net

    healthcheck:
      test: ["CMD", "mysqladmin", "ping", "-h", "localhost"]
      timeout: 20s
      retries: 10

  wordpress:
    build: ./requirements/wordpress
    container_name: wordpress
    restart: unless-stopped

    depends_on:
      - mariadb

    environment:
      - WORDPRESS_DB_NAME=${WORDPRESS_DB_NAME}
      - WORDPRESS_DB_USER=${WORDPRESS_DB_USER}
      - WORDPRESS_DB_HOST=${WORDPRESS_DB_HOST}
      - WP_URL=${WP_URL}
      - WP_TITLE=${WP_TITLE}
      - WP_ADMIN_USER=${WP_ADMIN_USER}
      - WP_ADMIN_PASSWORD=${WP_ADMIN_PASSWORD}
      - WP_ADMIN_EMAIL=${WP_ADMIN_EMAIL}
      
    secrets:
      - db_password

    volumes:
      - wordpress_data:/var/www/html

    networks:
      - inception_net

secrets:
  db_password:
    file: ../secrets/db_password.txt
  db_root_password:
    file: ../secrets/db_root_password.txt

networks:
  inception_net:
    driver: bridge

volumes:
  wordpress_data:

```

# 5) Update previous env pass
🚀 Awesome Mak! Let's build your `.env` file like true Docker wizards 🧙‍♂️
This file helps you **avoid hardcoding values** in `docker-compose.yml`, especially sensitive info or config that may change per environment (e.g. dev vs production).

---

## 📁 File: `srcs/.env`

Here’s what you need 👇

```dotenv
# 🌐 WordPress DB Settings
WORDPRESS_DB_NAME=wordpress
WORDPRESS_DB_USER=wp_user
WORDPRESS_DB_HOST=mariadb

# 🌍 WordPress Site Info
WP_URL=https://localhost         # or http:// if no SSL yet
WP_TITLE="Mak's Epic Site"

# 👤 WordPress Admin Credentials (for now testing only)
WP_ADMIN_USER=admin
WP_ADMIN_PASSWORD=adminpass
WP_ADMIN_EMAIL=admin@example.com
```

---

## 🔐 Secret Passwords

Remember! Passwords like:

* DB user password → in `secrets/db_password.txt`
* MariaDB root password → in `secrets/db_root_password.txt`

are **not** stored in `.env`, because we’re using Docker **secrets** 💡.

So `wp_config.sh` will get them by reading from:

```bash
cat /run/secrets/db_password
```

✅ Clean, secure, and modular.
Eval likes this. The real world loves it.

---

## 🧪 Quick Sanity Check

To test if `.env` is loading properly:

```bash
cd srcs/
docker compose config
```

It will render a full, resolved config file with variables replaced.
If you see blank values like:

```yaml
WORDPRESS_DB_USER: ""
```

...you forgot to export or write them.

---

Ready to run it and build WordPress?
Or shall we walk through `wp_config.sh` line-by-line before launching? 🛠️
