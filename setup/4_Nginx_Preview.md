🧠 **Let’s talk about Nginx like we’re explaining it to our non-coding grandma — but with pro-level detail for your 42 brain.**
Then we’ll go full turbo into the setup. Buckle up. 🏁

---

## 🌐 What is NGINX? (TL;DR version)

**Nginx (pronounced "engine-x")** is a super lightweight and powerful **web server** — but it’s so much more:

### It can act as:

| Role              | What it does                                                                     |
| ----------------- | -------------------------------------------------------------------------------- |
| 🛰️ Web Server    | Serves static content (HTML, CSS, JS, images) FAST.                              |
| 🕹️ Reverse Proxy | Forwards requests to another service (like WordPress’s PHP backend).             |
| 🔐 SSL Terminator | Handles HTTPS so your backend doesn’t have to deal with encryption.              |
| 🧩 Load Balancer  | Distributes traffic across multiple servers (not needed in Inception, but cool). |

---

### 💡 In Your Project (Inception):

Nginx will be the **“face” of your application**. It will:

1. **Listen on port 443** (HTTPS)
2. Accept incoming browser requests (like `https://localhost`)
3. Pass those requests to **PHP-FPM in your WordPress container** on port 9000

---

## 🧱 Your Container System Right Now

```plaintext
┌────────────┐       forwards to      ┌────────────┐        serves from      ┌──────────────┐
│   NGINX    │  ───────────────────▶  │ WordPress  │  ───────────────────▶   │   MariaDB    │
│ (port 443) │                        │ (port 9000)│                         │ (port 3306)   │
└────────────┘                        └────────────┘                         └──────────────┘
      ↑
  Handles SSL
```

---

## 🚦 What We’re Going to Do (Nginx Steps)

### 🧰 Folder Prep:

You're already ahead, but double-check this:

```
srcs/requirements/nginx/
├── Dockerfile
├── .dockerignore
├── tools/
│   ├── ssl.sh
│   └── nginx_entrypoint.sh
├── conf/
│   ├── nginx.conf         ← Main config
│   ├── default.conf       ← Site config with `fastcgi_pass`
│   ├── cert.pem           ← TLS cert (generated)
│   └── key.pem            ← TLS key (generated)
```

### ✅ Step-by-Step Plan

| Step | What We’ll Do                             | Why                           |
| ---- | ----------------------------------------- | ----------------------------- |
| 🔹 1 | Generate SSL cert (or reuse yours)        | Required by subject           |
| 🔹 2 | Write `default.conf` (Nginx virtual host) | Forwards to WordPress         |
| 🔹 3 | Write `nginx.conf` (global config)        | Base settings                 |
| 🔹 4 | Write Dockerfile                          | Install & copy everything     |
| 🔹 5 | Write `nginx_entrypoint.sh`               | Auto-generate cert if missing |
| 🔹 6 | Add service to `docker-compose.yml`       | Run the whole system          |

---
