#!/bin/bash
# System Health Check Script

# Define Colors
RESET=$'\033[0m'
RED=$'\033[0;31m'
GREEN=$'\033[0;32m'
YELLOW=$'\033[0;33m'
ORANGE=$'\033[38;5;208m'
CYAN=$'\033[0;36m'

SHOW_CITRIX=false

for arg in "$@"; do
  case $arg in -c|c) SHOW_CITRIX=true ;; esac
done

if [ "$SHOW_CITRIX" = false ]; then
    echo -e "${CYAN}--- CPU Temp ---${RESET}"
    sensors | awk -v g="$GREEN" -v y="$YELLOW" -v o="$ORANGE" -v r="$RED" -v res="$RESET" '
    /Core/ {
        temp = $3
        gsub(/[^0-9.]/, "", temp)
        temp = temp + 0
        if (temp < 55.0) color = g
        else if (temp < 65.0) color = y
        else if (temp < 80.0) color = o
        else color = r
        print color $0 res
    }'

    # GPU Monitoring - Optimized for Fedora 44 (igt-gpu-tools 2.4)
    if command -v intel_gpu_top &> /dev/null; then
        echo -e "\n${CYAN}--- GPU Performance ---${RESET}"
        # Grabs the second-to-last sample to ensure the tool has "warmed up"
        GPU_RAW=$(sudo timeout 3 intel_gpu_top -l 2>/dev/null | awk '!/Freq/ && NF>=9 {prev=curr; curr=$9} END {print int(prev)}')
        GPU_LOAD=${GPU_RAW:-0}  
        echo -e "Intel GPU Load: ${GREEN}${GPU_LOAD}%${RESET}"
    fi

    echo -e "\n${CYAN}--- Battery ---${RESET}"
    BAT_PATH=$(upower -e | grep BAT | head -n 1)
    [ -n "$BAT_PATH" ] && upower -i "$BAT_PATH" | grep -E "state|percentage|capacity"

    echo -e "\n${CYAN}--- Network ---${RESET}"
    nmcli device status | grep -E "mullvad|wlp2s0"

    echo -e "\n${CYAN}--- Storage ---${RESET}"
    df -h / /home | grep -v Filesystem
    
    # SSD Wear Level
    if command -v smartctl &> /dev/null; then
        WEAR=$(sudo -n smartctl -A /dev/nvme0n1 2>/dev/null | awk 'tolower($0) ~ /percentage used/ {gsub("%", ""); print $3}')
        if [ -n "$WEAR" ]; then
            if [ "$WEAR" -lt 10 ]; then COLOR=$GREEN; elif [ "$WEAR" -lt 50 ]; then COLOR=$YELLOW; else COLOR=$RED; fi
            echo -e "${COLOR}SSD Wear Level: ${WEAR}% used${RESET}"
        fi
    fi

    echo -e "\n${CYAN}--- Security ---${RESET}"
    FAILED_LOGINS=$(journalctl _SYSTEMD_UNIT=sshd.service --since "24h ago" 2>/dev/null | grep -c "Failed password")
    echo "Failed SSH logins (24h): $FAILED_LOGINS"
fi

if [ "$SHOW_CITRIX" = true ]; then
    echo -e "${CYAN}--- Citrix Status ---${RESET}"
    LATEST_VER=$(curl -s --connect-timeout 2 https://www.citrix.com/downloads/workspace-app/linux/workspace-app-for-linux-latest.html | grep -oP 'Citrix Workspace app \K[0-9]{4}' | head -1)
    CURRENT_RAW=$(rpm -qa --qf "%{VERSION}" ICAClient)
    if [ -n "$CURRENT_RAW" ]; then
        CURRENT_VER=$(echo "$CURRENT_RAW" | awk -F. '{print $1$2}')
        if [ -z "$LATEST_VER" ]; then echo -e "Citrix: ${YELLOW}Offline${RESET}"
        elif [ "$LATEST_VER" -gt "$CURRENT_VER" ]; then echo -e "Citrix: ${RED}🚨 Update! ($LATEST_VER)${RESET}"
        else echo -e "Citrix: ${GREEN}Up to date ($CURRENT_RAW)${RESET}"; fi
    else echo -e "Citrix: ${RED}Not Installed${RESET}"; fi
fi
