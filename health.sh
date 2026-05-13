#!/bin/bash
# System Health Check Script

# Define Colors
RESET='\033[0m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
ORANGE='\033[38;5;208m'
CYAN='\033[0;36m'

echo -e "${CYAN}--- CPU Temp ---${RESET}"
sensors | grep Core | while read -r line; do
    # Extract ONLY the first temperature number (ignoring high/crit)
    TEMP=$(echo "$line" | grep -oP '\+\K[0-9.]+' | head -n1)
    
    # Determine color based on temperature scale using bc for decimal comparison
    if [ $(echo "$TEMP < 50.0" | bc) -eq 1 ]; then
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
    
echo -e "\n${CYAN}--- Citrix Status ---${RESET}"
# Scrape latest version from Citrix download page
LATEST_VER=$(curl -s --connect-timeout 2 https://www.citrix.com/downloads/workspace-app/linux/workspace-app-for-linux-latest.html | grep -oP 'Citrix Workspace app \K[0-9]{4}' | head -1)
    
# Get currently installed version from RPM
CURRENT_RAW=$(rpm -qa --qf "%{VERSION}" ICAClient)
CURRENT_VER=$(echo $CURRENT_RAW | cut -d'.' -f1,2 | tr -d '.')

if [ -z "$LATEST_VER" ]; then
    echo -e "Citrix: ${YELLOW}Could not reach update server.${RESET}"
elif [ "$LATEST_VER" -gt "$CURRENT_VER" ]; then
    echo -e "Citrix: ${RED}🚨 Update Available ($LATEST_VER)! Current: $CURRENT_RAW${RESET}"
else
    echo -e "Citrix: ${GREEN}Up to date ($CURRENT_RAW)${RESET}"
fi
