---
title: Inventory
showDate: true
showReadingTime: false
showWordCount: false
showAuthor: false
build:
  list: never
date: 2025-12-24
---
# Infrastructure Inventory

## Network

- **Subnet**: 192.168.100.0/24 (internal VM network)
- **Gateway**: 192.168.100.1 (Proxmox vmbr1)
- **DNS**: 192.168.100.53 (bind9)
- **Remote Access**: Tailscale subnet router at 192.168.100.100

## Virtual Machines

| Name | IP | CPU | RAM | OS Disk | Data Disk | Boot Order | Role |
|------|-----|-----|-----|---------|-----------|------------|------|
| tailscale | 192.168.100.100 | 1 | 2GB | 10G | - | 1 | network |
| dns | 192.168.100.53 | 1 | 4GB | 20G | - | 2 | dns |
| traefik | 192.168.100.80 | 1 | 2GB | 20G | - | 3 | infrastructure |
| immich | 192.168.100.21 | 2 | 8GB | 20G | 200G | 4 | production |
| jellyfin | 192.168.100.22 | 2 | 6GB | 20G | 150G | 4 | production |
| nextcloud | 192.168.100.20 | 2 | 4GB | 20G | 100G | 4 | production |
| uptime-kuma | 192.168.100.90 | 1 | 1GB | 10G | - | 5 | monitoring |

## Services

### Infrastructure

- **DNS** (192.168.100.53) - BIND9 with DNS-over-TLS
- **Traefik** (192.168.100.80) - Reverse proxy, TLS termination, Let's Encrypt
- **Tailscale** (192.168.100.100) - Subnet router for remote access
- **Uptime Kuma** (192.168.100.90) - Service monitoring dashboard

### Core Services

- **Nextcloud** (192.168.100.20) - File sync, calendar, contacts
- **Immich** (192.168.100.21) - Photo management
- **Jellyfin** (192.168.100.22) - Media server

