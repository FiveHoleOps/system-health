#!/bin/bash
# System Health Check Script

# Define Colors
RESET='\033[0m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
ORANGE='\033[38;5;208m'
CYAN='\033[0;36m'

# Default toggle
SHOW_CITRIX=false

# Parse flags
while getopts "c" opt; do
  case $opt in
    c) SHOW_CITRIX=true ;;
    *) echo "Usage: health [-c]"; exit 1 ;;
  esac
done

# Show system vitals ONLY if -c was NOT passed
if [ "$SHOW_CITRIX" = false ]; then
    echo -e "${CYAN}--- CPU Temp ---${RESET}"
    sensors | grep Core | while read -r line; do
        TEMP=$(echo "$line" | grep -oP '\+\K[0-9.]+' | head -n1)
        if [ $(echo "$TEMP < 55.0" | bc) -eq 1 ]; then
            COLOR=$GREEN
        elif [ $(echo "$TEMP < 65.0" | bc) -eq 1 ]; then
            COLOR=$YELLOW
        elif [ $(echo "$TEMP < 80.0" | bc) -eq 1 ]; then
            COLOR=$ORANGE
        else
            COLOR=$RED
        fi
        echo -e "${COLOR}${line}${RESET}"
    done

    echo -e "\n${CYAN}--- Battery ---${RESET}"
    BAT_PATH=$(upower -e | grep BAT | head -n 1)
    if [ -n "$BAT_PATH" ]; then
        upower -i "$BAT_PATH" | grep -E "state|percentage|capacity"
    fi

    echo -e "\n${CYAN}--- Network ---${RESET}"
    nmcli device status | grep -E "mullvad|wlp2s0"

    echo -e "\n${CYAN}--- Storage ---${RESET}"
    df -h / /home | grep -v Filesystem

    echo -e "\n${CYAN}--- Security ---${RESET}"
    FAILED_LOGINS=$(journalctl _SYSTEMD_UNIT=sshd.service | grep -c "Failed password")
    echo "Failed SSH logins: $FAILED_LOGINS"
fi

# Show Citrix Status if -c was passed
if [ "$SHOW_CITRIX" = true ]; then
    echo -e "${CYAN}--- Citrix Status ---${RESET}"
    LATEST_VER=$(curl -s --connect-timeout 2 https://www.citrix.com/downloads/workspace-app/linux/workspace-app-for-linux-latest.html | grep -oP 'Citrix Workspace app \K[0-9]{4}' | head -1)
    CURRENT_RAW=$(rpm -qa --qf "%{VERSION}" ICAClient)
    CURRENT_VER=$(echo $CURRENT_RAW | cut -d'.' -f1,2 | tr -d '.')

    if [ -z "$LATEST_VER" ]; then
        echo -e "Citrix: ${YELLOW}Could not reach update server.${RESET}"
    elif [ "$LATEST_VER" -gt "$CURRENT_VER" ]; then
        echo -e "Citrix: ${RED}🚨 Update Available ($LATEST_VER)! Current: $CURRENT_RAW${RESET}"
    else
        echo -e "Citrix: ${GREEN}Up to date ($CURRENT_RAW)${RESET}"
    fi
fi
