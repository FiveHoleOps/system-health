# System Health Script

A comprehensive Bash utility designed for Fedora Linux to monitor hardware vitals, security, and application status.

## Features
* **CPU Monitoring**: Real-time core temperatures with color-coded alerts.
* **Memory**: Displays current RAM and Swap utilization.
* **GPU Performance**: Intel GPU load monitoring and kernel driver details (requires `-g` flag).
* **Storage Health**: Tracks NVMe/SSD wear levels and partition usage.
* **Network Status**: Monitors active interfaces and Mullvad VPN connectivity.
* **Security**: Scans `journalctl` for failed SSH login attempts in the last 24 hours.
* **Citrix Integration**: Optional flag to check for Citrix Workspace App updates.
* **GDrive Sync**: Monitors the rclone bisync systemd timer and recent logs (requires `-s` flag).

## Dependencies
The script requires: `lm_sensors`, `igt-gpu-tools`, `smartmontools`, `upower`, `nmcli`, `pciutils`.

## Configuration
Add this to `visudo`:
`ben ALL=(ALL) NOPASSWD: /usr/bin/intel_gpu_top, /usr/sbin/smartctl, /usr/bin/timeout`

## Usage
`./health.sh` 
`./health.sh c` (Citrix Status)
`./health.sh g` (GPU & Video Info)
`./health.sh s` (GDrive Sync Status)