# System Information
OS: Linux
IP: Debian

---
# Service Enumeration
## 22/tcp SSH
OpenSSH 7.4p1 Debian 10+deb9u7 (protocol 2.0)


## 113/tcp Service

## 5432/tcp Service

## 8080/tcp HTTP

WEBrick/1.4.2 (Ruby/2.6.6/2020-03-31)


## 10000/tcp Service
nmap exposes usernames:
- nobody
- eleanor (jump to initial access)
- root

# Initial Access

guess ssh login: eleanor:eleanor

# Privilege Escalation

We drop into a restricted shell environment, only having access to /home/eleanor/bin on the path.

![[Pasted image 20260830131740.png]]

Search online for rbash and "restricted: cannot specify..."

We can find all executables on the path with `compgen -c`

Notice `ed` is available, find in GTFObins
https://gtfobins.org/gtfobins/ed/#shell

```
ed
!/bin/bash
```

linpeas points out docker container engine and that eleanor is a member of the docker group

https://gtfobins.org/gtfobins/docker/#shell

`docker run -v /:/mnt --rm -it redmine chroot /mnt /bin/sh`

![[Pasted image 20260830133159.png]]

# Proof Screenshots (local.txt / proof.txt)
`type` or `cat` flag and [include IP address in screenshot](https://help.offsec.com/hc/en-us/articles/360040165632-OSCP-Exam-Guide#screenshot-requirements)

![[Pasted image 20260830133436.png]]
