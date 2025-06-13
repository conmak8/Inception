> ! ALWAYS SAVE STATE during doing development never shut off!

# Modify User Account ()
	1) su <-> (alone automatically go to roor account)
	2) /user/sbin/usermod -aG sudo mak (i added sudo to be run by mak)
	3) su mak

# Install an SSH command on Debian

```bash
sudo apt update && sudo apt install openssh-server
sudo systemctl enable ssh
sudo systemctl start ssh
```

- go to VM settings(netwrok-advanced) and port forward the port of Vm(ex 4242) to 4242 (for example) of the host machine
- then ssh to it ` ssh mak@localhost -p 4242`
- we cannot use the port 22 coz is already assigned
- lsof -i to see all running ports (use sudo also to be able to see evertyhing)
- sudo service sshd restart
- (3664  cd ~/.ssh
- 3665  vim known_hosts) 

# Install Docker
from page : https://docs.docker.com/engine/install/debian/#install-using-the-repository

1) set up dockers repo
```bash
# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
	```

2) Install Docker packages

```bash
	sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

3) Verify that the installation is successful by running the hello-world image:

```bash
	sudo docker run hello-world
```
This command downloads a test image and runs it in a container. When the container runs, it prints a confirmation message and exits.

# Connect my GitHub through ssh

- `cd .ssh` + `ls -la` check if there is an ssh key
Alright Bac, let’s give your Debian VM the power to push and pull like a GitHub superhero — **via SSH**. 🦸‍♂️💻
No more typing usernames or passwords every time you `git push`!

---

#### 🧠 TL;DR – Summary First

To SSH into GitHub from your Debian VM:

```bash
# 1. Generate SSH key
ssh-keygen -t ed25519 -C "your@email.com"

# 2. Copy the public key
cat ~/.ssh/id_ed25519.pub

# 3. Add it to GitHub → Settings → SSH and GPG keys

# 4. Test it
ssh -T git@github.com

# 5. Set your GitHub remote to use SSH
git remote set-url origin git@github.com:yourusername/yourrepo.git
```
---

## 🧱 Step-by-Step Guide

### 📦 1. **Install Git and SSH (if not already)**

```bash
sudo apt update
sudo apt install git openssh-client
```

---

### 🔐 2. **Generate an SSH key**

```bash
ssh-keygen -t ed25519 -C "your@email.com"
```

* When asked for file path, just press **Enter** (default is `~/.ssh/id_ed25519`)
* You can add a **passphrase** or leave it empty for now

---

### 📋 3. **Copy your public key**

```bash
cat ~/.ssh/id_ed25519.pub
```

**Copy that whole string!** Starts with `ssh-ed25519` and ends with your email.

---

### 🌐 4. **Add SSH key to GitHub**

1. Go to [GitHub → Settings → SSH and GPG keys](https://github.com/settings/keys)
2. Click “**New SSH key**”
3. Give it a name (e.g. *Debian VM*)
4. Paste the public key you copied earlier

---

### 🧪 5. **Test SSH connection to GitHub**

Run:

```bash
ssh -T git@github.com
```

You should see:

> Hi yourusername! You've successfully authenticated...

If it says something about "Are you sure you want to continue connecting?", type **yes**.

---

### 🔄 6. **Set remote to use SSH (not HTTPS!)**

Check current remote:

```bash
git remote -v
```

If it shows `https://github.com/...`, you need to switch to SSH:

```bash
git remote set-url origin git@github.com:yourusername/yourrepo.git
```

---

### ✅ 7. **Try a Push or Pull**

```bash
git pull origin main
git push origin main
```

🎉 No username/password prompts! SSH does the talking.

---

## 🛑 Common Mistakes

| 😬 Problem                      | 💡 Fix                                                     |
| ------------------------------- | ---------------------------------------------------------- |
| `Permission denied (publickey)` | You didn’t add the SSH key to GitHub                       |
| Still asking for username       | You're using HTTPS URL, not SSH                            |
| Key not used                    | Run `ssh-add ~/.ssh/id_ed25519` or check `ssh-agent` setup |

---
Wanna make it even smoother with `ssh-agent` auto-loading at login or managing multiple GitHub accounts.Check if needed.


