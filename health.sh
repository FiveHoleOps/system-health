#!/bin/bash
# System Health Check Script

echo "--- CPU Temp ---"
sensors | grep Core

echo "--- Battery ---"
BAT_PATH=$(upower -e | grep BAT | head -n 1)
if [ -n "$BAT_PATH" ]; then
    upower -i "$BAT_PATH" | grep -E "state|percentage|capacity"
fi

echo "--- Network ---"
nmcli device status | grep -E "mullvad|wlp2s0"
    
echo "--- Citrix Status ---"
LATEST_VER=$(curl -s --connect-timeout 2 https://www.citrix.com/downloads/workspace-app/linux/workspace-app-for-linux-latest.html | grep -oP 'Citrix Workspace app \K[0-9]{4}' | head -1)
    
CURRENT_RAW=$(rpm -qa --qf "%{VERSION}" ICAClient)
CURRENT_VER=$(echo $CURRENT_RAW | cut -d'.' -f1,2 | tr -d '.')

if [ -z "$LATEST_VER" ]; then
    echo "Citrix: Could not reach update server."
elif [ "$LATEST_VER" -gt "$CURRENT_VER" ]; then
    echo "Citrix: 🚨 Update Available ($LATEST_VER)! Current: $CURRENT_RAW"
else
    echo "Citrix: Up to date ($CURRENT_RAW)"
fi
