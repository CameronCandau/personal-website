# System Information
OS: Ubuntu
IP: 192.168.112.214

# Local Users/Credentials

---
# Service Enumeration
## 22/tcp SSH

OpenSSH 9.6p1 Ubuntu 3ubuntu13.9

Guess:
- anonymous:anonymous
- spidersociety:spidersociety

## 80/tcp HTTP

Apache/2.4.58 

![[Pasted image 20260827231440.png]]

Bottom of the page has email address: contact@spidersociety.offsec.lab

Add spidersociety.offsec.lab to /etc/hosts.

Totally overlooked.... apparently, supposed to then directory fuzz with DirBuster-2007_directory-list-lowercase-2.3-medium.txt........ to find /libspider........ 
*I guess this is a lesson to always go deeper and circle back with a bigger wordlist if findings are dry, but this just feels a bit silly for a lab.*

Brings us to an admin panel.

![[Pasted image 20260827233447.png]]

Guess creds successfully as admin:admin.

Click the "Communications" button on http://spidersociety.offsec.lab/libspider/control-panel.php

![[Pasted image 20260827233619.png]]


```
Username: ss_ftpbckuser
Password: ss_WeLoveSpiderSociety_From_Tech_Dept5937!
```

Continue in 2121.


## 2121/tcp Service

vsftpd 3.0.5

Continued from 80.

Recursively download all contents:
`wget -r ftp://ss_ftpbckuser:ss_WeLoveSpiderSociety_From_Tech_Dept5937\!@$IP:2121/`

This missed a hidden file in libspider/ because we don't have permission to download it or view the contents.

Instead, once we learn that the file exists, we can try requesting it with HTTP:

![[Pasted image 20260827235531.png]]

```
FTP_BACKUP_USER=ss_ftpbckuser
FTP_BACKUP_PASS=ss_WeLoveSpiderSociety_From_Tech_Dept5937!

DB_CONNECT_USER=spidey
DB_CONNECT_PASS=WithGreatPowerComesGreatSecurity99!
```

# Initial Access

`ssh spidey@$IP` with password `WithGreatPowerComesGreatSecurity99!`

# Privilege Escalation

```
sudo -l
Matching Defaults entries for spidey on spidersociety:
    env_reset, mail_badpass, secure_path=/usr/local/sbin\:/usr/local/bin\:/usr/sbin\:/usr/bin\:/sbin\:/bin\:/snap/bin, use_pty

User spidey may run the following commands on spidersociety:
    (ALL) NOPASSWD: /bin/systemctl restart spiderbackup.service
    (ALL) NOPASSWD: /bin/systemctl daemon-reload
    (ALL) !/bin/bash, !/bin/sh, !/bin/su, !/usr/bin/sudo
```

`systemctl show spiderbackup.service` shows that it runs `/usr/local/bin/spiderbackup.sh`, which we cannot edit.

Find the service file, check permissions:
```
find / -type f -name spiderbackup.service -exec ls -l {} \; 2>/dev/null
-rw-rw-r-- 1 spidey spidey 193 Apr 14  2025 /etc/systemd/system/spiderbackup.service
```

Create /tmp/shell.sh with reverse shell payload, use `chmod +x`, and then modify the service file to execute it instead of the original command.

![[Pasted image 20260828000754.png]]


# Proof Screenshots (local.txt / proof.txt)
`type` or `cat` flag and [include IP address in screenshot](https://help.offsec.com/hc/en-us/articles/360040165632-OSCP-Exam-Guide#screenshot-requirements)

![[Pasted image 20260828000829.png]]
