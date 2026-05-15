# System Health Script

A comprehensive Bash utility designed for Fedora Linux to monitor hardware vitals, security, and application status.

## Features
* **CPU Monitoring**: Real-time core temperatures with color-coded alerts.
* **GPU Performance**: Intel GPU load monitoring using `igt-gpu-tools`.
* **Storage Health**: Tracks NVMe/SSD wear levels and partition usage.
* **Network Status**: Monitors active interfaces and Mullvad VPN connectivity.
* **Security**: Scans `journalctl` for failed SSH login attempts in the last 24 hours.
* **Citrix Integration**: Optional flag to check for Citrix Workspace App updates.

## Dependencies
The script requires: `lm_sensors`, `igt-gpu-tools`, `smartmontools`, `upower`, `nmcli`.

## Configuration
Add this to `visudo`:
`ben ALL=(ALL) NOPASSWD: /usr/bin/intel_gpu_top, /usr/sbin/smartctl, /usr/bin/timeout`

## Usage
`./health.sh` or `./health.sh c`