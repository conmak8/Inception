Excellent observation 🔍 and you're absolutely right to ask:

> 🗂️ **Why does the subject require a `/secrets/` folder** if we’re already using `.env`?

---

### 🧠 What’s the Deal with `/secrets/`?

According to the 42 Inception subject, you're **required to avoid storing any passwords inside `.env`**, even though Compose allows it. Instead, you're expected to **mount sensitive info from outside the container** — like real DevOps pros do in production.

---

### 🔐 Why is This a Good Practice?

In the real world (☁️ AWS, GCP, Kubernetes), passwords are:

* 📄 Mounted from secret files (`/run/secrets/...`)
* 📦 Stored securely in Vaults or encrypted volumes
* 🛡️ Never **hardcoded** in Dockerfiles, shell scripts, or `.env` files that may accidentally be version-controlled

---

## ✅ Correct Usage in 42 Inception

* `.env` → safe mappings like:

  ```
  WP_DB_NAME=wordpress
  WP_DB_USER=wp_user
  ```
* `/secrets/` folder:

  ```
  secrets/
  ├── db_password.txt
  ├── db_root_password.txt
  └── credentials.txt
  ```

---

## 🚀 How We’ll Use Them

Let’s say in `docker-compose.yml` we define:

```yaml
    secrets:
      - db_password
      - db_root_password

secrets:
  db_password:
    file: ../secrets/db_password.txt
  db_root_password:
    file: ../secrets/db_root_password.txt
```

And then **inside your `mariadb_entrypoint.sh`**, we use:

```bash
WP_DB_PASSWORD=$(cat /run/secrets/db_password)
WP_DB_ROOT_PASSWORD=$(cat /run/secrets/db_root_password)
```

🚨 This only works if you declare `secrets:` in the service and in `docker-compose.yml` — don't worry, we’ll handle it.

---

## 🔁 So What’s Next?

I’ll now:

* ✅ Move the passwords out of `.env` and into `/secrets/`
* ✅ Update the `docker-compose.yml` to use **Docker secrets**
* ✅ Update your `mariadb_entrypoint.sh` to `cat` those secrets properly
* ✅ Recheck your skeleton to **fully comply with subject & real-life best practice**

Ready for that full re-alignment step? 😎
