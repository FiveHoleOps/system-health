# System Health

A lightweight Bash script to monitor local system vitals and specific application statuses on Fedora.

## Features
*   **CPU Temperature:** Monitors core temps via `lm_sensors`.
*   **Battery Status:** Tracks state, percentage, and capacity via `upower`.
*   **Network:** Checks status for specific interfaces (WiFi and Mullvad VPN) via `nmcli`.
*   **Citrix Workspace Tracker:** Scrapes the Citrix download page to compare the latest available version against the locally installed RPM version.

## Requirements
Ensure the following packages are installed:
*   `lm_sensors`
*   `upower`
*   `NetworkManager`
*   `curl`

## Installation
1. Clone the repository:
   ```bash
   git clone <your-repo-url> ~/scripts/system-health
