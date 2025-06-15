#!/bin/bash

# Ensure script is run with sudo/root
if [ "$EUID" -ne 0 ]; then
  echo "[!] Please run as root. Re-launching with sudo..."
  exec sudo "$0" "$@"
  exit
fi

# Colors
RED='\033[0;31m'
BLUE='\033[0;34m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Auto-select interface, ignoring lo, docker, vir, etc.
auto_select_interface() {
    iface=$(ip link show | awk -F: '$0 !~ "lo|docker|vir|veth|br-|^[^0-9]"{print $2}' | tr -d ' ' | head -n 1)
    if [ -z "$iface" ]; then
        echo -e "${RED}[!] No suitable network interface found.${NC}"
        exit 1
    fi
    echo -e "${GREEN}[+] Using interface: $iface${NC}"
}

# Change MAC address
change_mac() {
    echo "[*] Changing MAC address..."
    old_mac=$(cat /sys/class/net/$iface/address)

    ip link set $iface down
    new_mac=$(macchanger -r $iface | grep 'New MAC' | awk '{print $3}')
    ip link set $iface up

    echo -e "[+] Old MAC: ${BLUE}${old_mac}${NC}"
    echo -e "[+] New MAC: ${RED}${new_mac}${NC}"
    echo -e "${GREEN}[+] MAC address changed successfully.${NC}"
}

# Change IP address to random 192.168.1.X
change_ip() {
    echo "[*] Changing IP address..."
    old_ip=$(ip -4 addr show dev "$iface" | grep 'inet ' | awk '{print $2}' | head -n 1)
    random_ip="192.168.1.$((RANDOM % 254 + 1))"
    netmask="255.255.255.0"
    gateway="192.168.1.1"

    ip addr flush dev $iface
    ifconfig $iface $random_ip netmask $netmask up
    route add default gw $gateway 2>/dev/null

    echo -e "[+] Old IP: ${BLUE}${old_ip}${NC}"
    echo -e "[+] New IP: ${RED}${random_ip}${NC}"
    echo -e "${GREEN}[+] IP address changed successfully.${NC}"
}

# Remove secondary IPs
remove_secondary_ips() {
    echo "[*] Removing secondary IPs from $iface..."
    all_ips=$(ip -4 addr show dev "$iface" | grep 'inet ' | awk '{print $2}')
    primary_ip=$(echo "$all_ips" | head -n 1)

    for ip in $all_ips; do
        if [ "$ip" != "$primary_ip" ]; then
            echo -e "${RED}[-] Removing secondary IP: $ip${NC}"
            ip addr del "$ip" dev "$iface"
        fi
    done

    echo -e "${GREEN}[+] Cleanup complete. Remaining IPs:${NC}"
    ip -4 addr show dev "$iface" | grep 'inet '
}

#main menus
main_menu() {
    CYAN='\033[0;36m'
    NEON='\033[1;92m'
    NC='\033[0m'  # No Color

    echo -e "==============================="
    echo -e " Kali Linux IP & MAC Changer"
    echo -e "==============================="
    auto_select_interface
    echo

    echo -e "${CYAN}1.${NEON} Change MAC address only${NC}"
    echo -e "${CYAN}2.${NEON} Change IP address only (random)${NC}"
    echo -e "${CYAN}3.${NEON} Change both MAC and IP${NC}"
    echo -e "${CYAN}4.${NEON} Remove secondary IPs${NC}"
    echo -e "${CYAN}5.${NEON} Exit${NC}"
    echo -e "==============================="

    read -p "Choose an option [1-5]: " option
    case $option in
        1)
            change_mac
            ;;
        2)
            change_ip
            ;;
        3)
            change_mac
            change_ip
            ;;
        4)
            remove_secondary_ips
            ;;
        5)
            echo "Goodbye!"
            exit 0
            ;;
        *)
            echo "Invalid choice."
            ;;
    esac
}


# Run the menu
main_menu
