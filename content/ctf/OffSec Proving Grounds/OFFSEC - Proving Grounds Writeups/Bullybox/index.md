Summary from existing writeups:
- add bullybox.local to /etc/hosts, to access web on :80 via vhost
- find :80/.git -> download with curl/wget/git-dumper -> find creds admin:Playing-Unstylish7-Provided in bb-config.php
	- validate and sign in at /bb-admin
- authenticated rce: https://www.exploit-db.com/exploits/51108, get shell as yuki
- `sudo -l` shows yuki can run all as root without password -> `sudo su`