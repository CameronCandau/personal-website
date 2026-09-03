Summary from existing writeups:
- :6789 http 
- directory brute force -> discover /files
- discover /terminal -> code execution as www-data
- `ps` or `ss` -> find zabbix running on the target. in maintenance mode, so only accessible from localhost
- port forward, access from kali
- find creds in zabbix config file, use to access mysql db to dump admin user password hash. crack with rockyou.txt
- sign into zabbix web ui as admin with cracked password
- zabbix authenticated rce https://medium.com/@ducanhbui/n1ctf-2020-zabbix-fun-writeup-6f5b9ec24f64
- `sudo -l` -> zabbix can run rsync as root -> gtfobins -> root
