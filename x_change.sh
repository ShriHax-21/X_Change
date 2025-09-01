#!/bin/bash

if [ "$EUID" -ne 0 ]; then
  echo "[!] Please run as root. Re-launching with sudo..."
  exec sudo "$0" "$@"
  exit
fi

RED='\033[0;31m'
BLUE='\033[0;34m'
GREEN='\033[0;32m'
PURPLE='\033[0;35m'
YELLOW='\033[1;33m'
NC='\033[0m'

auto_select_interface() {
    iface=$(ip link show | awk -F: '$0 !~ "lo|docker|vir|veth|br-|^[^0-9]"{print $2}' | tr -d ' ' | head -n 1)
    if [ -z "$iface" ]; then
        echo -e "${RED}[!] No suitable network interface found.${NC}"
        exit 1
    fi
    echo -e "${GREEN}[+] Using interface: $iface${NC}"
    ORIG_FILE="/tmp/.orig_ip_mac_$iface"
}

cidr2mask() {
    local cidr=$1
    local mask=""
    local value=$(( 0xffffffff << (32 - cidr) & 0xffffffff ))
    for i in 1 2 3 4; do
        mask+=$(( (value >> (32 - 8 * i)) & 0xff ))
        [ $i -lt 4 ] && mask+=.
    done
    echo $mask
}

calc_broadcast() {
    local ip="$1"
    local mask="$2"
    IFS=. read -r i1 i2 i3 i4 <<< "$ip"
    IFS=. read -r m1 m2 m3 m4 <<< "$mask"
    local b1=$((i1 | (255 - m1)))
    local b2=$((i2 | (255 - m2)))
    local b3=$((i3 | (255 - m3)))
    local b4=$((i4 | (255 - m4)))
    echo "$b1.$b2.$b3.$b4"
}

save_original_ip_mac() {
    if [ ! -f "$ORIG_FILE" ]; then
        orig_mac=$(cat /sys/class/net/$iface/address)
        ip_info=$(ip -4 addr show dev "$iface" | grep 'inet ' | awk '{print $2}' | head -n 1)
        orig_ip="${ip_info%%/*}"
        cidr="${ip_info#*/}"
        if [[ "$orig_ip" == "$ip_info" ]]; then
            cidr="24"
        fi
        orig_netmask=$(cidr2mask "$cidr")
        orig_gateway=$(ip route show default | grep "dev $iface" | awk '{print $3}' | head -n 1)
        {
            echo "MAC=$orig_mac"
            echo "IP=$orig_ip"
            echo "NETMASK=$orig_netmask"
            echo "GATEWAY=$orig_gateway"
        } > "$ORIG_FILE"
        echo -e "${GREEN}[+] Saved original MAC/IP to $ORIG_FILE${NC}"
    fi
}

show_original_ip_mac() {
    if [ -f "$ORIG_FILE" ]; then
        echo -e "${PURPLE}Original values for $iface:${NC}"
        cat "$ORIG_FILE"
    else
        echo -e "${RED}[!] No original values stored yet.${NC}"
    fi
}

ipcalc_prefix() {
    local netmask=$1
    local IFS=.
    local count=0
    for octet in $netmask; do
        case $octet in
            255) count=$((count+8));;
            254) count=$((count+7));;
            252) count=$((count+6));;
            248) count=$((count+5));;
            240) count=$((count+4));;
            224) count=$((count+3));;
            192) count=$((count+2));;
            128) count=$((count+1));;
            0) ;;
            *) echo "Error: Invalid netmask $netmask"; return 1;;
        esac
    done
    echo $count
}

restore_original_ip_mac() {
    if [ ! -f "$ORIG_FILE" ]; then
        echo -e "${RED}[!] No original IP/MAC stored for $iface.${NC}"
        return
    fi

    # Restore MAC first
    orig_mac=$(grep '^MAC=' "$ORIG_FILE" | cut -d= -f2)
    if [ -z "$orig_mac" ]; then
        echo -e "${RED}[!] Original MAC not found.${NC}"
    else
        ip link set $iface down
        ip link set dev $iface address "$orig_mac"
        ip link set $iface up
        echo -e "${GREEN}[+] Restored original MAC: $orig_mac${NC}"
    fi

    # Restore IP
    orig_ip=$(grep '^IP=' "$ORIG_FILE" | cut -d= -f2)
    orig_netmask=$(grep '^NETMASK=' "$ORIG_FILE" | cut -d= -f2)
    orig_gateway=$(grep '^GATEWAY=' "$ORIG_FILE" | cut -d= -f2)
    if [ -z "$orig_ip" ] || [ -z "$orig_netmask" ]; then
        echo -e "${RED}[!] Original IP/netmask not found.${NC}"
        return
    fi

    broadcast=$(calc_broadcast "$orig_ip" "$orig_netmask")
    ip addr flush dev "$iface"
    prefix_len=$(ipcalc_prefix "$orig_netmask")
    ip addr add "$orig_ip/$prefix_len" broadcast "$broadcast" dev "$iface"
    ip route del default 2>/dev/null
    [ -n "$orig_gateway" ] && ip route add default via "$orig_gateway" dev "$iface"

    # Remove any other IPs (DHCP/NetworkManager interference)
    sleep 2
    for ip in $(ip -4 addr show dev "$iface" | grep 'inet ' | awk '{print $2}'); do
        if [ "$ip" != "$orig_ip/$prefix_len" ]; then
            ip addr del "$ip" dev "$iface"
        fi
    done

    echo -e "${GREEN}[+] Restored original IP: $orig_ip, Netmask: $orig_netmask, Gateway: $orig_gateway${NC}"
}

delete_saved_ip_mac_file() {
    if [ -f "$ORIG_FILE" ]; then
        rm "$ORIG_FILE"
        echo -e "${YELLOW}[+] Deleted $ORIG_FILE${NC}"
    else
        echo -e "${RED}[!] No saved file found for $iface.${NC}"
    fi
}

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

change_ip() {
    echo "[*] Changing IP address..."
    old_ip=$(ip -4 addr show dev "$iface" | grep 'inet ' | awk '{print $2}' | head -n 1)
    echo -e "Choose IP configuration:"
    echo -e "${BLUE}1. Random IP${NC} (within a base, e.g. 192.168.100)"
    echo -e "${BLUE}2. Enter IP manually${NC}"
    read -p "Enter your choice [1-2]: " ip_choice
    if [ "$ip_choice" == "1" ]; then
        read -p "Enter IP base (e.g. 192.168.159): " main_ip
        last_octet=$((RANDOM % 254 + 1))
        ip_addr="$main_ip.$last_octet"
        read -p "Enter Gateway [default: ${main_ip}.1]: " gateway
        gateway=${gateway:-$main_ip.1}
        netmask="255.255.255.0"
    elif [ "$ip_choice" == "2" ]; then
        read -p "Enter IP address (e.g. 192.168.159.100): " ip_addr
        read -p "Enter Netmask (e.g. 255.255.255.0): " netmask
        read -p "Enter Gateway [default: ${ip_addr%.*}.1]: " gateway
        gateway=${gateway:-${ip_addr%.*}.1}
    else
        echo -e "${RED}[!] Invalid choice. Cancelling IP change.${NC}"
        return
    fi
    broadcast=$(calc_broadcast "$ip_addr" "$netmask")
    ip addr flush dev "$iface"
    prefix_len=$(ipcalc_prefix "$netmask")
    ip addr add "$ip_addr/$prefix_len" broadcast "$broadcast" dev "$iface"
    ip route del default 2>/dev/null
    ip route add default via "$gateway" dev "$iface"
    # Remove any IPs except the new one (handles DHCP/NetworkManager interference)
    sleep 2
    for ip in $(ip -4 addr show dev "$iface" | grep 'inet ' | awk '{print $2}'); do
        if [ "$ip" != "$ip_addr/$prefix_len" ]; then
            echo -e "${RED}[-] Removing unwanted IP: $ip from $iface${NC}"
            ip addr del "$ip" dev "$iface"
        fi
    done
    echo -e "[+] Old IP: ${BLUE}${old_ip}${NC}"
    echo -e "[+] New IP: ${RED}${ip_addr}${NC}"
    echo -e "[+] Gateway: ${PURPLE}${gateway}${NC}"
    echo -e "[+] Broadcast: ${YELLOW}${broadcast}${NC}"
    echo -e "${GREEN}[+] IP address changed successfully.${NC}"
}

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

change_mac_every_minute() {
    echo -e "${GREEN}[*] Cycling MAC every minute. Press Ctrl+C to stop.${NC}"
    while true; do
        echo -e "${PURPLE}--- $(date) ---${NC}"
        change_mac
        sleep 60
    done
}

change_ip_every_interval() {
    echo "[*] Starting random IP changer every X seconds..."
    read -p "Enter base IP (e.g. 192.168.159): " base_ip
    read -p "Enter interval in seconds: " interval

    gateway="${base_ip}.1"
    netmask="255.255.255.0"
    prefix_len=$(ipcalc_prefix "$netmask")

    while true; do
        last_octet=$((RANDOM % 254 + 1))
        new_ip="$base_ip.$last_octet"
        broadcast=$(calc_broadcast "$new_ip" "$netmask")

        echo -e "\n[*] Changing IP to $new_ip ..."
        ip addr flush dev "$iface"
        ip addr add "$new_ip/$prefix_len" broadcast "$broadcast" dev "$iface"
        ip route del default 2>/dev/null
        ip route add default via "$gateway" dev "$iface"
        sleep 2
        for ip in $(ip -4 addr show dev "$iface" | grep 'inet ' | awk '{print $2}'); do
            if [ "$ip" != "$new_ip/$prefix_len" ]; then
                echo -e "${RED}[-] Removing unwanted IP: $ip from $iface${NC}"
                ip addr del "$ip" dev "$iface"
            fi
        done

        echo -e "${GREEN}[+] New IP set: $new_ip (Gateway: $gateway, Prefix: /$prefix_len, Broadcast: $broadcast)${NC}"
        echo -e "${YELLOW}[*] Next change in $interval seconds... (press 'q' + Enter to quit early)"
        for ((i=0; i<interval; i++)); do
            read -t 1 -n 1 key
            if [[ "$key" == "q" || "$key" == "Q" ]]; then
                echo -e "${GREEN}Exiting IP changer loop.${NC}"
                break 2
            fi
        done
    done
}

main_menu() {
    echo
    NEON='\033[1;92m'
    echo -e "${NEON}1. ${PURPLE}Change MAC address only ${NC}"
    echo -e "${NEON}2. ${PURPLE}Change IP address only ${NC}"
    echo -e "${NEON}3. ${PURPLE}Change both MAC and IP ${NC}"
    echo -e "${NEON}4. ${PURPLE}Remove secondary IPs ${NC}"
    echo -e "${NEON}5. ${PURPLE}Change MAC every minute ${NC}"
    echo -e "${NEON}6. ${PURPLE}Change IP every interval (seconds) ${NC}"
    echo -e "${NEON}7. ${PURPLE}Show original MAC/IP ${NC}"
    echo -e "${NEON}8. ${PURPLE}Restore original IP & MAC ${NC}"
    echo -e "${NEON}9. ${PURPLE}Delete saved IP/MAC file ${NC}"
    echo -e "${NEON}10. ${PURPLE}Exit ${NC}"
    echo -e "${GREEN}===============================${NC}"
    read -p "Choose an option [1-10]: " option
    case $option in
        1) change_mac ;;
        2) change_ip ;;
        3) change_mac; change_ip ;;
        4) remove_secondary_ips ;;
        5) change_mac_every_minute ;;
        6) change_ip_every_interval ;;
        7) show_original_ip_mac ;;
        8) restore_original_ip_mac ;;
        9) delete_saved_ip_mac_file ;;
        10) echo "Goodbye!"; exit 0 ;;
        *) echo -e "${RED}Invalid choice.${NC}" ;;
    esac
}

echo -e "${GREEN}==============================="
echo -e "       x_change.sh"
echo -e "===============================${NC}"

auto_select_interface
save_original_ip_mac

while true; do
    main_menu
done
