# System Information
OS:
IP: 192.168.206.41

---
# Service Enumeration

## 5353/udp Zeroconf

## 22/tcp SSH

OpenSSH 5.3p1 Debian 3ubuntu7 

Limited cipher suite. Use `ssh -o HostKeyAlgorithms\ ssh-rsa ...`

## 23/tcp Service

CUPS 1.4

https://www.exploit-db.com/exploits/34152 ?

## 80/tcp HTTP

Apache/2.2.14 (Ubuntu)

![[Pasted image 20260828171344.png]]

Feroxbuster finds /test:

![[Pasted image 20260828172724.png]]

Comment in line 100 of the HTML source reveals version as 1.4.1.4

`<!-- zenphoto version 1.4.1.4 [8157] (Official Build) THEME: default (index.php) GRAPHICS LIB: PHP GD library 2.0 { memory: 128M } PLUGINS: class-video colorbox deprecated-functions hitcounter security-logger tiny_mce zenphoto_news zenphoto_sendmail zenphoto_seo  -->`

# Initial Access

Find CVE-2011-4825 , RCE in ZenPhoto 1.4.1.4. 

https://www.exploit-db.com/exploits/18083

![[Pasted image 20260828173730.png]]

Jump to Privilege Escalation.


## 3306/tcp MySQL

ERROR 1130 (HY000): Host '192.168.45.194' is not allowed to connect to this MySQL server

# Privilege Escalation

LinPEAS reports that the target is vulnerable CVE-2010-3904 for local privilege escalation.

https://www.exploit-db.com/exploits/15285

Download the C source code, transfer to target (with wget, as curl doesn't seem to be available), compile with `gcc 15285.c -o 15285`, and run `./15285` to get root.

# Proof Screenshots (local.txt / proof.txt)
`type` or `cat` flag and [include IP address in screenshot](https://help.offsec.com/hc/en-us/articles/360040165632-OSCP-Exam-Guide#screenshot-requirements)

![[Pasted image 20260828182519.png]]