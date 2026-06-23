**HyperText Transport Protocol**

# Manual Enumeration
![[Pasted image 20250822174724.png]]

## Technology Stack Identification

### whatweb
```
whatweb $URL
```

```
WhatWeb report for http://192.168.174.25:80
Status    : 403 Forbidden
Title     : 403 Forbidden
IP        : 192.168.174.25
Country   : RESERVED, ZZ

Summary   : HTTPServer[nginx/1.18.0], nginx[1.18.0]

Detected Plugins:
[ HTTPServer ]
	HTTP server header string. This plugin also attempts to
	identify the operating system from the server header.

	String       : nginx/1.18.0 (from server string)

[ nginx ]
	Nginx (Engine-X) is a free, open-source, high-performance
	HTTP server and reverse proxy, as well as an IMAP/POP3
	proxy server.

	Version      : 1.18.0
	Website     : http://nginx.net/

HTTP Headers:
	HTTP/1.1 403 Forbidden
	Server: nginx/1.18.0
	Date: Sat, 23 Aug 2025 00:20:26 GMT
	Content-Type: text/html
	Transfer-Encoding: chunked
	Connection: close
	Content-Encoding: gzip
```

We'll come back later to directory fuzz if we don't find anything else.

# Continue [[8082 HTTP]]