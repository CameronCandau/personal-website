---
title: ClamAV
date: 2026-08-09
---
# System Information
OS: Linux

---
# Service Discovery

## 199/tcp Service
SMUX?

## 445/tcp SMB

## 60000/tcp Service

nc -nv shows `SSH-2.0-OpenSSH_3.8.1p1 Debian-8.sarge.6`

## 22/tcp SSH

SSH-2.0-OpenSSH_3.8.1p1 Debian-8.sarge.6

## 25/tcp SMTP
Sendmail 8.13.4/8.13.4/Debian-3

## 139/tcp SMB

## 80/tcp HTTP



# Initial Access
By searching for a combination of the open ports, service names, and "clamav", I came across a POC on GitHub: https://github.com/Strikoder-Premium/sendmail-clamav-exploit-CVE-2007-4560

Running this exploit against the target opens a bind shell, giving us immediate root access once connected. The script's default port, 1001, didn't work, presumably due to firewall rules on the target. Modifying the source code to use 443 was enough to bypass and connect.

# Proof Screenshots (local.txt / proof.txt)
`type` or `cat` flag and [include IP address in screenshot](https://help.offsec.com/hc/en-us/articles/360040165632-OSCP-Exam-Guide#screenshot-requirements)

![[Pasted image 20260809221233.png]]