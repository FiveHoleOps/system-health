#!/bin/bash
# System Health Check Script

# Define Colors
RESET='\033[0m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
ORANGE='\033[38;5;208m'
CYAN='\033[0;36m'

SHOW_CITRIX=false

for arg in "$@"; do
  case $arg in -c|c) SHOW_CITRIX=true ;; esac
done

if [ "$SHOW_CITRIX" = false ]; then
    echo -e "${CYAN}--- CPU Temp ---${RESET}"
    sensors | grep Core | while read -r line; do
        TEMP=$(echo "$line" | grep -oP '\+\K[0-9.]+' | head -n1)
        if [ $(echo "$TEMP < 55.0" | bc) -eq 1 ]; then COLOR=$GREEN
        elif [ $(echo "$TEMP < 65.0" | bc) -eq 1 ]; then COLOR=$YELLOW
        elif [ $(echo "$TEMP < 80.0" | bc) -eq 1 ]; then COLOR=$ORANGE
        else COLOR=$RED; fi
        echo -e "${COLOR}${line}${RESET}"
    done

    # GPU Monitoring - Optimized for Fedora 44 (igt-gpu-tools 2.4)
    if command -v intel_gpu_top &> /dev/null; then
        echo -e "\n${CYAN}--- GPU Performance ---${RESET}"
        # Grabs the second-to-last sample to ensure the tool has "warmed up"
        GPU_RAW=$(sudo timeout 3 intel_gpu_top -l 2>/dev/null | grep -v "Freq" | tail -n 2 | head -n 1 | awk '{print $9}' | cut -d'.' -f1 | tr -d ' ')
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
        WEAR=$(sudo -n smartctl -A /dev/nvme0n1 2>/dev/null | grep -i "Percentage Used" | awk '{print $3}' | tr -d '%')
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
        CURRENT_VER=$(echo "$CURRENT_RAW" | cut -d'.' -f1,2 | tr -d '.')
        if [ -z "$LATEST_VER" ]; then echo -e "Citrix: ${YELLOW}Offline${RESET}"
        elif [ "$LATEST_VER" -gt "$CURRENT_VER" ]; then echo -e "Citrix: ${RED}🚨 Update! ($LATEST_VER)${RESET}"
        else echo -e "Citrix: ${GREEN}Up to date ($CURRENT_RAW)${RESET}"; fi
    else echo -e "Citrix: ${RED}Not Installed${RESET}"; fi
fi
