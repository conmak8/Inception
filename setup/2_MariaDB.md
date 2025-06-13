
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


# REDO STEP 2 & 3 for security reasons
🚀 Let’s realign your Inception project the **correct 42 way** — with `secrets/` integration like a DevOps pro!
We’ll restructure `.env`, `docker-compose.yml`, and the entrypoint script so everything is **secure**, **subject-compliant**, and **professional**.

---

## ✅ Updated `.env` (Safe for Git, No Passwords)

📄 File: `Inception/srcs/.env`

```env
# Safe values only (non-sensitive)
WP_DB_NAME=wordpress
WP_DB_USER=wp_user
```

---

## 🔐 New `secrets/` Files

📁 Folder: `Inception/secrets/`

```bash
echo "supersecure" > secrets/db_password.txt
echo "evenmoresecure" > secrets/db_root_password.txt
```

(You can also add `credentials.txt` for WordPress admin data later.)

⚠️ Make sure to **add `secrets/` to `.gitignore`** if you’re using Git!

---

## 🧪 Updated `mariadb_entrypoint.sh`

📄 Path: `srcs/requirements/mariadb/tools/mariadb_entrypoint.sh`

```bash
#!/bin/sh

# Load secrets from Docker secrets file mounts
WP_DB_PASSWORD=$(cat /run/secrets/db_password)
WP_DB_ROOT_PASSWORD=$(cat /run/secrets/db_root_password)

if [ ! -d "/var/lib/mysql/${WP_DB_NAME}" ]; then
    echo "📦 First boot: initializing database..."

    mariadbd --user=mysql --bootstrap --console <<EOF
USE mysql;
FLUSH PRIVILEGES;
DELETE FROM mysql.user WHERE User='';
DROP DATABASE IF EXISTS test;
DELETE FROM mysql.db WHERE Db='test';
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
CREATE DATABASE ${WP_DB_NAME};
CREATE USER '${WP_DB_USER}'@'%' IDENTIFIED BY '${WP_DB_PASSWORD}';
GRANT ALL PRIVILEGES ON ${WP_DB_NAME}.* TO '${WP_DB_USER}'@'%';
ALTER USER 'root'@'localhost' IDENTIFIED BY '${WP_DB_ROOT_PASSWORD}';
FLUSH PRIVILEGES;
EOF

else
    echo "✅ Database already initialized. Launching MariaDB..."
    mariadbd --user=mysql --console
fi
```

---

## 🧩 Updated `docker-compose.yml`

📄 Path: `srcs/docker-compose.yml`

```yaml
version: '3.8'

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
      - mariadb_data:/var/lib/mysql

    networks:
      - inception_net

secrets:
  db_password:
    file: ../secrets/db_password.txt
  db_root_password:
    file: ../secrets/db_root_password.txt

volumes:
  mariadb_data:

networks:
  inception_net:
    driver: bridge
```

---

## ✅ Your New Secure Flow

```plaintext
credentials.txt     (for WP admin)
db_password.txt     → container:/run/secrets/db_password
db_root_password.txt→ container:/run/secrets/db_root_password
```

And your container reads them like a pro:

```bash
$(cat /run/secrets/...)
```

---

### 🎉 You now have:

✅ A real `/secrets/` system
✅ Zero sensitive data in `.env`
✅ A powerful, production-like entrypoint
✅ All subject rules respected

Shall we proceed now with the MariaDB `Dockerfile` as the final piece before building & testing? 🛠️


# STEP 4 Dockerfile
🎯 Excellent precision, Mak — and you caught a **very important compliance detail** from the subject!

Yes, the Inception subject says:

> ❗For performance reasons, the containers must be built from either the penultimate stable version of **Alpine** or **Debian**.

You chose:
✅ **Debian** → specifically `debian:11` (codename: *bullseye*)
Let’s adjust accordingly! 🔧

---

## 🔁 Updated MariaDB `Dockerfile` Using `debian:11`

📁 File: `Inception/srcs/requirements/mariadb/Dockerfile`

```Dockerfile
# 🏗️ Use penultimate stable version of Debian (as per 42 subject)
FROM debian:11

# 🧰 Install MariaDB server and dependencies
RUN apt-get update && \
    apt-get install -y mariadb-server && \
    rm -rf /var/lib/apt/lists/*

# 🧪 Copy custom entrypoint script
COPY tools/mariadb_entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/mariadb_entrypoint.sh

# 🛠️ Use our secure startup script
ENTRYPOINT ["/usr/local/bin/mariadb_entrypoint.sh"]
```

---

### ⚠️ A Few Key Notes:

#### ✅ Pros of This Approach:

* Fully subject-compliant (Debian-based build ✅)
* No use of `mariadb:` official image anymore → you control the full image
* You install `mariadb-server` directly

#### ❗BUT This Means:

* You must **manually configure** everything MariaDB needs
* Your `entrypoint.sh` must start `mysqld` (or `mariadbd`) directly

In our case, we already use:

```bash
mariadbd --user=mysql --console
```

✅ So we’re good — but don’t forget: **you're now the sysadmin**, not just using a prepared image!

---

## Optional: Create MariaDB config (`my.cnf`)

If you want to harden MariaDB or tweak its behavior, create:
📁 `srcs/requirements/mariadb/conf/my.cnf`

```ini
[mysqld]
bind-address = 0.0.0.0
port = 3306
skip-host-cache
skip-name-resolve
```

Then add this to your Dockerfile later:

```Dockerfile
COPY conf/my.cnf /etc/mysql/my.cnf
```

Let me know if you want to include that now or keep it minimal for testing.

---

Ready to:

* Build your image using **Debian 11**
* Start testing your MariaDB container?

Let’s go step-by-step through the first launch if you’re ready 🔥

---
#### Explanation
Fantastic — you’re asking the exact questions that transform someone from just “using Docker” into truly **understanding how it works**. Let’s unpack both of your smart questions 👇

---

## 🧹 1️⃣ What is this line doing?

```Dockerfile
rm -rf /var/lib/apt/lists/*
```

### 🧠 In simple terms:

This line **cleans up the temporary cache** that `apt-get` uses while installing packages.

### ⚙️ What happens during `apt-get`?

When you run:

```bash
apt-get update
apt-get install -y mariadb-server
```

The system:

* Downloads **metadata** (package lists) into `/var/lib/apt/lists/`
* Uses that metadata to locate packages
* Installs them into your system

After install, this cache is **no longer needed**.

### ✅ Why we clean it:

| Why clean it?        | What it does                                          |
| -------------------- | ----------------------------------------------------- |
| 🧹 Reduce image size | Cleans 20–50MB of unnecessary files                   |
| 🛡️ Best practice    | Keeps images lean & secure                            |
| 📦 Avoid bloat       | Docker caches every layer — so we want each one tight |

That’s why it’s commonly seen **right after installs** in Dockerfiles.

### 💡 Tip: You could also collapse steps like this:

```Dockerfile
RUN apt-get update && \
    apt-get install -y mariadb-server && \
    rm -rf /var/lib/apt/lists/*
```

This keeps the cleanup in the **same layer** so it actually reduces image size — otherwise it doesn't help.

---

## 🔐 2️⃣ Why might we need `my.cnf`?

### 📄 `my.cnf` is MariaDB’s config file — like its `.conf` brain 🧠

It controls settings like:

* Networking
* Memory
* SQL mode
* Performance
* Security

### 🎯 In our case, here's why we might want this:

```ini
[mysqld]
bind-address = 0.0.0.0     # ✅ Allow external access (for WordPress container)
port = 3306                # ✅ Explicitly expose default MySQL port
skip-host-cache            # ✅ Avoid DNS lookups on hosts (faster)
skip-name-resolve          # ✅ Disable reverse DNS lookups (faster + safer)
```

### ✅ Summary of Why:

| Setting             | Purpose                                                               |
| ------------------- | --------------------------------------------------------------------- |
| `bind-address`      | Must be `0.0.0.0` so **WordPress can connect** from another container |
| `skip-host-cache`   | Slight speedup                                                        |
| `skip-name-resolve` | Prevents unnecessary DNS resolution (and mistakes)                    |

It’s a **small config file**, but improves:

* Inter-container networking 🧱
* Performance ⚡
* Security 🔐

---

## 🔧 Want to include it now?

If yes, here’s what we’ll do:

1. Create `conf/my.cnf`
2. Copy it in `Dockerfile` like this:

   ```Dockerfile
   COPY conf/my.cnf /etc/mysql/my.cnf
   ```

You’ll be 100% production-grade MariaDB ready.

Shall we go ahead and add it now? 😎

---
Updated Version:
Boom 💥! Let’s inject some **professional-grade MariaDB tuning** into your project right now.

---

## ✅ STEP 1: Create the Config File

📄 File: `Inception/srcs/requirements/mariadb/conf/my.cnf`

```ini
[mysqld]
# Allow connections from any IP (important for Docker internal networking)
bind-address = 0.0.0.0

# MariaDB default port
port = 3306

# Disable reverse DNS lookups — better performance & fewer weird bugs
skip-host-cache
skip-name-resolve
```

---

## ✅ STEP 2: Update `Dockerfile` to Use It

📄 File: `Inception/srcs/requirements/mariadb/Dockerfile`

Here’s your updated and annotated version:

```Dockerfile
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
```

---

## 🎯 What You’ve Gained

✅ WordPress will now be able to connect from another container
✅ You’ve hardened and optimized MariaDB
✅ You’re fully aligned with both the **subject** and **real-world production practices**
✅ Your image is still lean and fully under your control

---

Shall we now do a **full build & test of the MariaDB container**?
We can walk through:

* `docker-compose up --build mariadb`
* Inspecting logs
* Accessing the DB to verify everything’s running

Say the word, Captain! 🐳🛠️

