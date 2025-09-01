# Kali Linux IP & MAC Changer

**Kali Linux IP & MAC Changer** is an advanced, colorful Bash tool to randomly or manually change your **IP** and **MAC address** on Kali Linux. Ideal for pentesters, CTF players, or anyone needing to spoof, rotate, or clean up network identities.

---

## ⚡ Features

- 🔐 **Auto sudo**: Elevates privileges if not run as root
- ⚙️ **Interface auto-detection**: Skips `lo`, `docker`, and virtual NICs for hassle-free selection
- 🔁 **Random or custom IP address** assignment (choose your own range)
- 🎭 **Random or custom MAC address** support
- 🧹 **Removes secondary IPs** for a clean single-IP setup
- 🔄 **Change MAC or IP at timed intervals** (minutes or seconds!)
- 🧬 **Restore original IP & MAC** (saves your initial config)
- ⚡ **Super lightweight** — pure Bash + macchanger
- 🖌️ **Colorful output** for easy reading

---

## Main Menu Example

```bash
===============================
 Kali Linux IP & MAC Changer
===============================
[+] Using interface: eth0

1. Change MAC address only 
2. Change IP address only 
3. Change both MAC and IP 
4. Remove secondary IPs 
5. Change MAC every minute
6. Change IP every interval (seconds)
7. Show original MAC/IP
8. Restore original IP & MAC
9. Delete saved IP/MAC file
10. Exit
===============================
Choose an option [1-10]:
```

After choosing "Change IP address only":

```bash
[*] Changing IP address...
Choose IP configuration:
1. Random IP (within a base, e.g. 192.168.100)
2. Enter IP manually
Enter your choice [1-2]:
```

If you pick random:
```bash
Enter IP base (e.g. 192.168.159):
Enter Gateway [default: BASE.1]:
```
- **Tip:** Enter the first three octets as your IP base (e.g. `192.168.159`).  
- Gateway is auto-suggested, but you can enter manually.

---

## 🚀 Setup

### 📦 Requirements

Install the required packages if you haven’t already:

```bash
sudo apt update
sudo apt install macchanger net-tools -y
```

---

### 👉 Get the File

```bash
git clone https://github.com/ShriHax-21/X_Change.git
```

### 📂 Make Executable

```bash
cd X_Change

chmod +x kali-ip-mac-changer.sh
```

---

## 🧠 Usage

### 🏃‍♂️ Run Directly

```bash
sudo ./kali-ip-mac-changer.sh
```

## OPTIONAL

Set up a convenient alias:

Add this line to your `~/.bashrc` or `~/.zshrc`:
```bash
alias xcng='/full/path/to/kali-ip-mac-changer.sh'
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
- 🟢 **Success** — Green
- 🟡 **Warnings** — Yellow

---

## 🤘 Author

Made with ❤️ by [ShriHax](https://github.com/ShriHax-21)

---