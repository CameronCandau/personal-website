---
date: 2025-08-19
title: BlackGate
tags:
  - Linux
  - Privilege-Escalation
  - Redis
---
Difficulty: Hard
# Environment Setup
`export IP=192.168.126.176`

# Service Enumeration
([v-scan.sh](https://github.com/CameronCandau/OSCP-Automation/blob/main/bin/v-scan.sh))

`nmap --min-rate 4500 --max-rtt-timeout 1500ms -p- -Pn -oG all_ports.gnmap 192.168.126.176`

Only sees SSH open on port 22 and redis on 6379.

`nmap -sC -sV -T4 -Pn -p22,6379 192.168.126.176 -oA full_tcp`

```
PORT     STATE SERVICE VERSION
22/tcp   open  ssh     OpenSSH 8.3p1 Ubuntu 1ubuntu0.1 (Ubuntu Linux; p
rotocol 2.0)
| ssh-hostkey:
|   3072 37:21:14:3e:23:e5:13:40:20:05:f9:79:e0:82:0b:09 (RSA)
|   256 b9:8d:bd:90:55:7c:84:cc:a0:7f:a8:b4:d3:55:06:a7 (ECDSA)
|_  256 07:07:29:7a:4c:7c:f2:b0:1f:3c:3f:2b:a1:56:9e:0a (ED25519)
6379/tcp open  redis   Redis key-value store 4.0.14
```


## Port 6379 - Redis
Searching for version 4.0.14 on exploitdb, I found two metasploit modules. One of them is EDB-ID 47195 https://www.exploit-db.com/exploits/47195

The source references https://2018.zeronights.ru/wp-content/uploads/materials/15-redis-post-exploitation.pdf, which is no longer available but can be found archived most recently at https://web.archive.org/web/20241226210850/https://2018.zeronights.ru/wp-content/uploads/materials/15-redis-post-exploitation.pdf.

Since I'm trying to avoid Metasploit, I kept researching for other exploits for this version and found [Redis-Rogue-Server](https://github.com/n0b0dyCN/redis-rogue-server) which lists [that same PDF](https://2018.zeronights.ru/wp-content/uploads/materials/15-redis-post-exploitation.pdf) as its inspiration. This seems promising!

# Initial Access

I cloned the repo and was able to follow its usage instructions to get a reverse shell on the target as prudence.

![[Pasted image 20250713080809.png]]

*At first I tried using the repo's makefile to compile the .so and experienced compilation errors, but the .so file and default usage worked fine anyways.*

I found the first flag in /home/prudence/local.txt.
# Privilege Escalation

/home/prudence/notes.txt:

```
[✔] Setup redis server
[✖] Turn on protected mode
[✔] Implementation of the redis-status
[✔] Allow remote connections to the redis server
```

Protected mode sounds like it should be enabled ideally... this is likely why the service was exposed to us, but doesn't seem like a privilege escalation vector.

`sudo -l` shows that we can run /usr/local/bin/redis-status as sudo without a password.

I tried this, but it requires an authorization string.

![[Pasted image 20250713084358.png]]

In `strings /usr/local/bin/redis-status` I found a potential auth key, although it seems to have failed. Let's test it anyways.
```
Authorization Key:
ClimbingParrotKickingDonkey321
/usr/bin/systemctl status redis
Wrong Authorization Key!
Incident has been reported!
```

This actually works and displays the service's status as root! Further, since this is running in `less` as the pager, we can actually just type `!bash` to drop into a shell as root.

![[Pasted image 20250713085403.png]]

The final flag is in /root/proof.txt.
