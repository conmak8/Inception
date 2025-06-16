# 1/
`before we run and build it
explain me. this one
--dbpass="$(cat /run/secrets/db_password)" \
why we use the folder run? it is not. in my skeleton.`

💥 That’s a **super good question**, Mak. This shows you’re not just following steps — you're understanding how the Docker sausage is made 🧠🌭

Let’s unpack this:

---

## 🧩 `--dbpass="$(cat /run/secrets/db_password)"`

This line means:

> 👇 “Read the contents of this file and pass it as a value”

```bash
--dbpass="supersecure"
```

But instead of writing the password directly, we do:

```bash
--dbpass="$(cat /run/secrets/db_password)"
```

So it runs `cat` on that file to get the value.

---

## 📁 Why `/run/secrets/...`?

This is **Docker’s built-in path** when you use:

```yaml
secrets:
  db_password:
    file: ../secrets/db_password.txt
```

What Docker does **under the hood** is this:

1. When the container starts,
2. Docker takes `../secrets/db_password.txt`,
3. Mounts it inside the container as a **read-only file** at:

   ```
   /run/secrets/db_password
   ```

🧠 So:

> You don’t create `/run/secrets` yourself.
> Docker creates and manages it automatically **inside the container**
> if you use `secrets:` in `docker-compose.yml`.

---

## 🔐 Why is this good?

* ✅ **No passwords in Dockerfile**
* ✅ **No passwords in `.env`**
* ✅ **Only root-readable by default inside container**
* ✅ **42 and real companies love this for security**

---

### 🤓 So in summary:

You don’t see `/run/secrets/...` on your host or in your skeleton.
It's not your job to create it.

> Docker secretly whispers to the container:
> “Psst... here’s a file with a secret. Don’t tell anyone.” 🕵️‍♀️

---

Let me know if you'd like to print all the secrets inside your container for debug (securely), or if we build and test WordPress next! 🧪💻
