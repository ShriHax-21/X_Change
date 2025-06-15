# 🔁 X_Change

**X_Change** is a colorful and advanced Bash tool to randomly change your **IP** and **MAC address** on Kali Linux. It’s perfect for pentesters, CTF players, or anyone seeking to spoof or shuffle their network identity quickly and safely.

---

## ⚡ Features

- 🔐 **Auto sudo**: Automatically elevates privileges if not run as root
- ⚙️ **Interface auto-detection**: Skips `lo`, `docker`, and virtual NICs
- 🔁 **Random IP address** assignment (in the 192.168.1.x range)
- 🎭 **Random or custom MAC address** support
- 🧹 **Removes secondary IPs** for a clean setup
- 🌈 **Color-coded UI** for better terminal clarity
- ⚡ Super lightweight — pure Bash + macchanger

---

## 🧪 Preview

```
===============================
Kali Linux IP & MAC Changer
===========================

[+] Using interface: eth0

1. Change MAC address only
2. Change IP address only (random)
3. Change both MAC and IP
4. Remove secondary IPs
5. Exit
```

---

## 🚀 Setup

### 📦 Requirements

Install the required packages if you haven’t already:
```bash
sudo apt update
sudo apt install macchanger net-tools -y
```

### 📂 Make Executable

```bash
chmod +x X_Change.sh
```

---

## 🧠 Usage

### 🏃‍♂️ Run Directly

```bash
sudo ./X_Change.sh
```

Or, set up a convenient alias (optional):

Add this line to your `~/.bashrc` or `~/.zshrc`:
```bash
alias xcng='/full/path/to/X_Change.sh'
```
Reload your shell:
```bash
source ~/.bashrc
```
Now you can just run:
```bash
ipcng
```

---

## 🎨 Color Key

- 🔵 **Old IP / MAC** — Blue
- 🔴 **New IP / MAC** — Red
- 🟢 **Menu** — Cyan & Neon Green

---

## 📜 License

MIT License  
Use it. Fork it. Modify it. Just don’t use it for evil. 😈

---

## 🤘 Author

Made with ❤️ by [ShriHax](https://github.com/ShriHax-21)

---

> Stay stealthy. Stay sharp.  
> — *X_Change: Your network identity shapeshifter.*