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

```bash
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
