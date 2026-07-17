# Service Enumeration Priority

- [x] [[Archive/OFFSEC - Proving Grounds Writeups/Linux/Extplorer/Service Enumeration/80 HTTP|80 HTTP]]

# Initial Setup & Information Gathering

## Host Information
Target IP: 192.168.127.16
Operating System: Ubuntu Linux
Domain/Hostname: 
Difficulty: Intermediate

## Environment Variables / Setup
```
export IP=192.168.127.16
mkdir $IP && cd $IP
mkdir {nmap,web,smb,ftp,exploit,loot}
```

# Phase 1: Port Discovery

## Fast Port Discovery
```
nmap --min-rate 4500 --max-rtt-timeout 1500ms -p- -Pn $IP -oG nmap/all_ports.gnmap
```

```
PORT   STATE SERVICE
22/tcp open  ssh
80/tcp open  http
```

## Extract open ports:
```
TCP_PORTS=$(grep -oP '\d+/open' nmap/all_ports.gnmap | cut -d/ -f1 | paste -sd, -)
echo "Open TCP ports: $TCP_PORTS"
```

## Service Detection & Scripts
```
nmap -sC -sV -T4 -Pn -p$TCP_PORTS $IP -oA nmap/full_tcp
```

```
PORT   STATE SERVICE VERSION
22/tcp open  ssh     OpenSSH 8.2p1 Ubuntu 4ubuntu0.5 (Ubuntu Linux; protocol 2.0)
| ssh-hostkey:
|   3072 98:4e:5d:e1:e6:97:29:6f:d9:e0:d4:82:a8:f6:4f:3f (RSA)
|   256 57:23:57:1f:fd:77:06:be:25:66:61:14:6d:ae:5e:98 (ECDSA)
|_  256 c7:9b:aa:d5:a6:33:35:91:34:1e:ef:cf:61:a8:30:1c (ED25519)
80/tcp open  http    Apache httpd 2.4.41 ((Ubuntu))
|_http-server-header: Apache/2.4.41 (Ubuntu)
Service Info: OS: Linux; CPE: cpe:/o:linux:linux_kernel
```
