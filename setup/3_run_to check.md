🔥 Yesss, Mak! You’re becoming the Docker Captain now 🧭🐳
Let’s sail WordPress out of port! Here’s our plan:

---

## 🚀 Step-by-Step: Build & Run WordPress

In your `srcs/` folder:

### 1️⃣ **Build only WordPress container**

```bash
docker compose build wordpress
```

👷 This will:

* Use your `Dockerfile` in `requirements/wordpress`
* Install PHP + WP
* Add `wp_config.sh` as entrypoint
* NOT start it yet — just builds ✅

---

### 2️⃣ **Run WordPress**

```bash
docker compose up wordpress
```

🧠 Because of `depends_on: mariadb`, Docker will:

* Ensure MariaDB is already running (which it is 🎉)
* Start WordPress and apply your entrypoint logic
* Log everything in the terminal 📜

---

### 3️⃣ **Check logs**

```bash
docker logs wordpress
```

Look for lines like:

```
✅ WordPress configured
✅ WordPress installed
```

If something’s off, we’ll debug together 👨‍🔧

---

## 🔒 Reminder: Make sure your secrets & .env are in place

```bash
ls ../secrets/
# db_password.txt, db_root_password.txt

cat .env
# Check all variables exist
```

---

Once you’re done running it...
🎓 Next, we’ll **open up `wp_config.sh` line by line** and make sure every command makes sense like you’re teaching it to someone else.

Ready to build it? 🛠️
