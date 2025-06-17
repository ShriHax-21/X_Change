# X_Change

**X_Change** is a colorful and advanced Bash tool to randomly change your **IP** and **MAC address** on Kali Linux. It’s perfect for pentesters, CTF players, or anyone seeking to spoof or shuffle their network identity quickly and safely.

---

## ⚡ Features

- 🔐 **Auto sudo**: Automatically elevates privileges if not run as root
- ⚙️ **Interface auto-detection**: Skips `lo`, `docker`, and virtual NICs
- 🔁 **Random or custom IP address** assignment (in the 192.168.1.x range)
- 🎭 **Random or custom MAC address** support
- 🧹 **Removes secondary IPs** for a clean setup
- ⚡ **Super lightweight** — pure Bash + macchanger

---
## Main Menu
```bash
===============================
 Kali Linux IP & MAC Changer                                                                
===============================                                                             
[+] Using interface: eth0

1. Change MAC address only 
2. Change IP address only 
3. Change both MAC and IP 
4. Remove secondary IPs 
5. Exit 
===============================
Choose an option [1-5]:
```
After that in IP changer
```bash
[*] Changing IP address...
Choose IP configuration:
1. Random IP (you choose the range, e.g. 192.168.100)
2. Enter IP manually
Enter your choice [1-2]:
```
In Random
```bash
Enter IP range (e.g. 192.168.159):
Enter Gateway for this range (e.g. 192.168.159.1): 
```
In IP range make sure to enter 3 octal which ranges you want it to be
in gateway you can either use default or manual
## 🚀 Setup

### 📦 Requirements

Install the required packages if you haven’t already:

```bash
sudo apt update
sudo apt install macchanger net-tools -y
```
---
# 👉 get the file 
```bash
git clone https://github.com/ShriHax-21/X_Change.git
```

### 📂 Make Executable

```bash
cd X_Change

chmod +x X_Change.sh
```

---

## 🧠 Usage

### 🏃‍♂️ Run Directly

```bash
sudo ./X_Change.sh
```
## OPTIONAL
Or, set up a convenient alias:

Add this line to your `~/.bashrc` or `~/.zshrc`:
```bash
vi ~/.bashrc or ~/.zshrc

alias xcng='/full/path/to/X_Change.sh'
```
Reload your shell:
```bash
source ~/.bashrc
```
Now you can just run:
```bash
xcng
```

---

## 🎨 Color Key

- 🔵 **Old IP / MAC** — Blue
- 🔴 **New IP / MAC** — Red
- 🟣 **Menu** — Purple

---

## 🤘 Author

Made with ❤️ by [ShriHax](https://github.com/ShriHax-21)

---