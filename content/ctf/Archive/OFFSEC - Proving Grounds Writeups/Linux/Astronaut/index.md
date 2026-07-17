---
date: 2025-08-19
title: Astronaut
---
Difficulty: Easy
# Environment Setup
`export IP=192.168.148.12`

# Service Enumeration

`nmap -T4 -F $IP`

```
PORT   STATE SERVICE
22/tcp open  ssh
80/tcp open  http
```

`nmap -sC -sV -T4 -Pn -p- -oA full_tcp $IP`

```
PORT   STATE SERVICE VERSION
22/tcp open  ssh     OpenSSH 8.2p1 Ubuntu 4ubuntu0.13 (Ubuntu Linux; protocol 2.0)
| ssh-hostkey:
|   3072 98:4e:5d:e1:e6:97:29:6f:d9:e0:d4:82:a8:f6:4f:3f (RSA)
|   256 57:23:57:1f:fd:77:06:be:25:66:61:14:6d:ae:5e:98 (ECDSA)
|_  256 c7:9b:aa:d5:a6:33:35:91:34:1e:ef:cf:61:a8:30:1c (ED25519)
80/tcp open  http    Apache httpd 2.4.41
| http-ls: Volume /
| SIZE  TIME              FILENAME
| -     2021-03-17 17:46  grav-admin/
|_
|_http-title: Index of /
|_http-server-header: Apache/2.4.41 (Ubuntu)
Service Info: Host: 127.0.0.1; OS: Linux; CPE: cpe:/o:linux:linux_kernel
```

## Port 80 - HTTP 
Directory listing enabled:
![[Pasted image 20250706153016.png]]

![[Pasted image 20250706153103.png]]

![[Pasted image 20250706153158.png]]

Admin panel at /grav-admin/admin

Default credentials of admin:admin don't work.

## Initial Access

Not immediately seeing the version, but found an exploit for version 1.10.7 https://www.exploit-db.com/exploits/49973.

I was able to use this script to gain a reverse shell on the target as www-data.

![[Pasted image 20250707193614.png]]

# Privilege Escalation

We don't have any sudo privileges without the www-data user's password.

While enumerating for SUID binaries, I found that `/usr/bin/php7.4` has SUID enabled, meaning it will run as its owner, root. I referenced [gtfobins](https://gtfobins.github.io/gtfobins/php/#suid) to try gaining a reverse shell but was unsuccessful. Further, after attempting this, the binary somehow lost its SUID bit.
