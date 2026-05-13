# System Health

A lightweight, color-coded Bash script to monitor system vitals, security, and Citrix Workspace versions on Fedora.

## Features
*   **CPU Temperature:** Multi-stage color scale (Green/Yellow/Orange/Red) using `lm_sensors`.
*   **Battery Status:** Tracks state, percentage, and capacity.
*   **Network:** Monitors `wlp2s0` and `mullvad` VPN interfaces.
*   **Storage:** Quick view of `/` and `/home` usage.
*   **Security:** Reports failed SSH login attempts from `journalctl`.
*   **Citrix Tracker (Optional):** Scrapes Citrix downloads to compare your local RPM version with the latest online.

## Requirements
*   `lm_sensors` (for CPU temps)
*   `bc` (for decimal math)
*   `upower` (for battery)
*   `curl` (for Citrix scraping)

## Installation
1. Clone the repository:
   git clone https://github.com/FiveHoleOps/system-health.git ~/scripts/system-health

2. Make it executable:
   chmod +x ~/scripts/system-health/health.sh

3. Add an alias to your ~/.bashrc:
   alias health='/home/ben/scripts/system-health/health.sh'

## Usage
| Command | Description |
| :--- | :--- |
| health | Displays full system dashboard (CPU, Battery, Network, Storage, Security). |
| health -c | Displays only the Citrix Workspace update status. |
