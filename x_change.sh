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
PURPLE='\033[0;35m'
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

# Change IP address (random or manual)
change_ip() {
    echo "[*] Changing IP address..."
    old_ip=$(ip -4 addr show dev "$iface" | grep 'inet ' | awk '{print $2}' | head -n 1)

    echo -e "Choose IP configuration:"
    echo -e "${BLUE}1. Random IP${NC} (you choose the range, e.g. 192.168.100)"
    echo -e "${BLUE}2. Enter IP manually${NC}"
    read -p "Enter your choice [1-2]: " ip_choice

    if [ "$ip_choice" == "1" ]; then
        echo -e -n "${BLUE}Enter IP range (e.g. 192.168.159): ${NC}"
        read base_ip
        last_octet=$((RANDOM % 254 + 1))
        ip_addr="$base_ip.$last_octet"
        read -e -p "$(echo -e ${BLUE}Enter Gateway for this range \(${base_ip}.1\): ${NC})" gateway
        gateway=${gateway:-$base_ip.1}

        netmask="255.255.255.0"

    elif [ "$ip_choice" == "2" ]; then
        echo -e -n "${BLUE}Enter IP address (e.g. 192.168.159.100): ${NC}"
        read ip_addr
        echo -e -n "${BLUE}Enter Netmask (e.g. 255.255.255.0): ${NC}"
        read netmask
        read -e -p "$(echo -e ${BLUE}Enter Gateway for this range \(${base_ip}.1\): ${NC})" gateway
        gateway=${gateway:-$base_ip.1}

    else
        echo -e "${RED}[!] Invalid choice. Cancelling IP change.${NC}"
        return
    fi

    ip addr flush dev $iface
    ifconfig $iface $ip_addr netmask $netmask up
    route add default gw $gateway 2>/dev/null

    echo -e "[+] Old IP: ${BLUE}${old_ip}${NC}"
    echo -e "[+] New IP: ${RED}${ip_addr}${NC}"
    echo -e "[+] Gateway: ${PURPLE}${gateway}${NC}"
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

# Main menu
# Main menu
main_menu() {
    echo -e "${GREEN}==============================="
    echo -e " Kali Linux IP & MAC Changer"
    echo -e "===============================${NC}"
    auto_select_interface
    echo

    NEON='\033[1;92m'

    echo -e "${NEON}1. ${PURPLE}Change MAC address only ${NC}"
    echo -e "${NEON}2. ${PURPLE}Change IP address only ${NC}"
    echo -e "${NEON}3. ${PURPLE}Change both MAC and IP ${NC}"
    echo -e "${NEON}4. ${PURPLE}Remove secondary IPs ${NC}"
    echo -e "${NEON}5. ${PURPLE}Exit ${NC}"
    echo -e "${GREEN}===============================${NC}"

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
            echo -e "${RED}Invalid choice.${NC}"
            ;;
    esac
}


# Run the menu
main_menu
