
# 🧱 STEP 1: `mariadb_entrypoint.sh`

📁 Path: `srcs/requirements/mariadb/tools/mariadb_entrypoint.sh`
This is our custom script that initializes the MariaDB server **only on first boot**, and applies secure settings.

### 🔧 Content + Annotations:

```bash
#!/bin/sh
# mariadb_entrypoint.sh
# Custom MariaDB initialization logic using bootstrap mode

# Check if the database directory already exists (i.e. first boot or not)
if [ ! -d "/var/lib/mysql/${WP_DB_NAME}" ]; then
    echo "📦 First boot: initializing database..."

    # Use bootstrap mode to run SQL directly *before* full MariaDB starts
    mariadbd --user=mysql --bootstrap --console <<EOF

-- Switch to system DB
USE mysql;

-- Clean up any default insecure stuff
FLUSH PRIVILEGES;
DELETE FROM mysql.user WHERE User='';
DROP DATABASE IF EXISTS test;
DELETE FROM mysql.db WHERE Db='test';
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');

-- Create the app DB and user
CREATE DATABASE ${WP_DB_NAME};
CREATE USER '${WP_DB_USER}'@'%' IDENTIFIED BY '${WP_DB_PASSWORD}';
GRANT ALL PRIVILEGES ON ${WP_DB_NAME}.* TO '${WP_DB_USER}'@'%';

-- Set root password
ALTER USER 'root'@'localhost' IDENTIFIED BY '${WP_DB_ROOT_PASSWORD}';
FLUSH PRIVILEGES;
EOF

else
    echo "✅ Database already initialized, starting normally..."
    mariadbd --user=mysql --console
fi
```

---

## 🧠 What’s Happening?

| Line                             | What it does                                                                          |
| -------------------------------- | ------------------------------------------------------------------------------------- |
| `if [ ! -d /var/lib/mysql/... ]` | Checks if MariaDB is starting for the first time                                      |
| `mariadbd --bootstrap`           | Runs MariaDB with no networking, just for setup                                       |
| SQL block inside `EOF`           | - Sets up root user<br>- Deletes insecure defaults<br>- Creates WordPress DB and user |
| `else ... mariadbd`              | If the DB exists already, skip setup and run normally                                 |

---

## 🔐 Uses Secure `.env` Variables

You’ll define:

```dotenv
WP_DB_NAME=wordpress
WP_DB_USER=wp_user
WP_DB_PASSWORD=supersecret
WP_DB_ROOT_PASSWORD=evenmoresecret
```

Those will be passed in from `docker-compose.yml`.

---

#### why .env

💡 Excellent point Mak — let's fix the oversight and dive deeper into **why and where** those environment variables come in, even if the subject doesn’t mention them *explicitly*.

---

## 📌 First: Where to Put the `.env` File

You were 100% right ✅ to place `.env` here:

```
Inception/srcs/.env
```

Why? Because:

* Your `docker-compose.yml` (also in `srcs/`) will automatically **load that `.env` file** from the same directory.
* Docker Compose supports `.env` natively **without needing to declare it manually**.

So: ✅ **Correct location. Do not move it.**

---

## 🧠 Second: Why Do We Need These `.env` Variables?

Let’s break it down Feynman-style:

### ⚙️ What we *could* do (not best):

Hardcode everything in `docker-compose.yml`:

```yaml
environment:
  WP_DB_USER: wp_user
  WP_DB_PASSWORD: supersecret
```

### 🛡️ What we *should* do (secure, clean):

Use `.env` like this:

```env
WP_DB_USER=wp_user
WP_DB_PASSWORD=supersecret
```

Then in Compose:

```yaml
environment:
  WP_DB_USER: ${WP_DB_USER}
  WP_DB_PASSWORD: ${WP_DB_PASSWORD}
```

### 🚨 Why this matters (even if subject doesn’t mention it):

The subject **implies** clean configuration separation and security:

> *"You must secure credentials, organize logic clearly, and allow flexibility between builds."*

So while it doesn’t say “use .env” in big bold letters, it *assumes* you know how to:

* 🔐 Avoid hardcoded passwords
* 🧹 Keep your config clean
* ⚙️ Allow for different setups without rewriting files

So using `.env` for:

```env
WP_DB_NAME
WP_DB_USER
WP_DB_PASSWORD
WP_DB_ROOT_PASSWORD
```

…is **best practice** in Docker and totally 42-compliant ✅

---

## 🧾 Summary

| What           | Where                                | Why it's right                         |
| -------------- | ------------------------------------ | -------------------------------------- |
| `.env` file    | `srcs/.env`                          | Auto-loaded by Docker Compose ✅        |
| Variable usage | Inside Compose + entrypoint.sh       | Keeps secrets flexible and centralized |
| Subject-proof? | ✅ Yes, even if not explicitly stated | It's secure, organized, and scalable   |

---

Perfect — let’s create your `.env` file and connect it to your Docker Compose stack 🧩🔐

---

# 🧾 STEP 2: Create `.env` with Secure Variables

📁 File: `Inception/srcs/.env`

```dotenv
# 💾 MariaDB Configuration
WP_DB_NAME=wordpress
WP_DB_USER=wp_user
WP_DB_PASSWORD=supersecure
WP_DB_ROOT_PASSWORD=evenmoresecure

# (Optional for WordPress later)
WP_ADMIN_USER=admin
WP_ADMIN_PASSWORD=adminpass
WP_ADMIN_EMAIL=admin@example.com
```

### 🔐 Why This File Matters

* Docker Compose **automatically reads** this file when in the same directory
* Keeps all secrets out of Git and out of your code
* Easy to switch credentials in production vs development

---

# 🔧 STEP 3: Connect to `docker-compose.yml`

Let’s now write the MariaDB part of your Compose file with comments so it’s crystal clear:

📁 File: `Inception/srcs/docker-compose.yml`
🧱 Add this block for `mariadb` service:

```yaml
version: '3.8'

services:
  mariadb:
    build: ./requirements/mariadb
    container_name: mariadb
    restart: unless-stopped

    # 🔐 Environment from .env file
    environment:
      WP_DB_NAME: ${WP_DB_NAME}
      WP_DB_USER: ${WP_DB_USER}
      WP_DB_PASSWORD: ${WP_DB_PASSWORD}
      WP_DB_ROOT_PASSWORD: ${WP_DB_ROOT_PASSWORD}

    volumes:
      - mariadb_data:/var/lib/mysql

    networks:
      - inception_net

volumes:
  mariadb_data:

networks:
  inception_net:
    driver: bridge
```

---

### 🧠 What Happens Now?

* At `docker-compose up`, Compose reads `.env`
* Those variables are passed into the container's environment
* Your `mariadb_entrypoint.sh` script uses those vars securely
* Database is initialized **without hardcoding any credentials**

---


