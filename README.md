---

### ✅ `README.md` for `X_Change`

```markdown
# 🔁 X_Change

**X_Change** is an advanced and colorful Bash tool to randomly change your **IP** and **MAC address** in Kali Linux – useful for pentesters, CTF players, or anyone who wants to spoof and shuffle their network identity easily.

---

## ⚡ Features

- 🔐 **Auto sudo**: Elevates automatically if not run as root
- ⚙️ **Interface auto-detection**: Skips `lo`, `docker`, and virtual NICs
- 🔁 **Random IP address** (192.168.1.x) assignment
- 🎭 **Random or custom MAC address**
- 🧹 **Remove secondary IPs** (to clean dynamic leftovers)
- 🌈 **Color-coded UI** for clean terminal display
- ⚡ Super lightweight – pure Bash + macchanger

---

## 🧪 Preview

```

\===============================
Kali Linux IP & MAC Changer
===========================

\[+] Using interface: eth0

1. Change MAC address only
2. Change IP address only (random)
3. Change both MAC and IP
4. Remove secondary IPs
5. Exit

````

---

## 🚀 Setup

### 📦 Requirements

Install required packages (if not already installed):
```bash
sudo apt update
sudo apt install macchanger net-tools -y
````

### 📂 Make Executable

```bash
chmod +x X_Change.sh
```

---

## 🧠 Usage

### 🏃‍♂️ Run Directly

```bash
./X_Change.sh
```

If you want to avoid typing `sudo` or long paths every time:

### 🔗 Set Alias (Optional)

Add this to your `~/.bashrc` or `~/.zshrc`:

```bash
alias ipcng='/full/path/to/X_Change.sh'
```

Reload your shell:

```bash
source ~/.bashrc
```

Now just run:

```bash
ipcng
```

---

## 🎨 Color Key (Terminal)

* 🔵 **Old IP / MAC** – Blue
* 🔴 **New IP / MAC** – Red
* 🟢 **Menu** – Cyan & Neon Green

---

## 📜 License

MIT License
Use it. Fork it. Modify it. Just don’t use it for evil. 😈

---

## 🤘 Author

Made with ❤️ by [ShriHax](https://github.com/ShriHax-21)

---

> Stay stealthy. Stay sharp.
> — *X\_Change: Your network identity shapeshifter.*

```