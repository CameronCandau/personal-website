**HyperText Transport Protocol**
# Environment Variables / Setup
```
export IP=192.168.109.10
export PORT=9090
export URL=http://$IP:$PORT
```

# nmap
```
nmap -vv --reason -Pn -T4 -sV -p 9090 --script="banner,(http* or ssl*) and not (brute or broadcast or dos or external or http-slowloris* or fuzzer)"
```

```
PORT     STATE SERVICE REASON         VERSION
9090/tcp open  http    syn-ack ttl 61 Cockpit web service 198 - 220
|_http-csrf: Couldn't find any CSRF vulnerabilities.
|_http-title: Did not follow redirect to https://192.168.109.10:9090/
|_http-wordpress-users: [Error] Wordpress installation was not found. We couldn't find wp-login.php
| http-sitemap-generator: 
|   Directory structure:
|   Longest directory structure:
|     Depth: 0
|     Dir: /
|   Total files found (by extension):
|_    
|_http-malware-host: Host appears to be clean
|_http-stored-xss: Couldn't find any stored XSS vulnerabilities.
| http-methods: 
|_  Supported Methods: GET HEAD
|_http-feed: Couldn't find any feeds.
| http-security-headers: 
|   X_Content_Type_Options: 
|     Header: X-Content-Type-Options: nosniff
|     Description: Will prevent the browser from MIME-sniffing a response away from the declared content-type. 
|   Content_Security_Policy: 
|     Header: Content-Security-Policy: connect-src 'self' https://192.168.109.10:9090 wss://192.168.109.10:9090; form-action 'self' https://192.168.109.10:9090; base-uri 'self' https://192.168.109.10:9090; object-src 'none'; font-src 'self' https://192.168.109.10:9090 data:; img-src 'self' https://192.168.109.10:9090 data:; block-all-mixed-content; default-src 'self' https://192.168.109.10:9090 'unsafe-inline'
|     Description: Define the base uri for relative uri.
|     Description: Define loading policy for all resources type in case of a resource type dedicated directive is not defined (fallback).
|     Description: Define from where the protected resource can load plugins.
|     Description: Define from where the protected resource can load images.
|     Description: Define from where the protected resource can load fonts.
|     Description: Define which URIs the protected resource can load using script interfaces.
|     Description: Define which URIs can be used as the action of HTML form elements.
|     Description: Prevent user agent from loading mixed content.
|   Cache_Control: 
|_    Header: Cache-Control: no-cache, no-store
|_http-devframework: Couldn't determine the underlying framework or CMS. Try increasing 'httpspider.maxpagecount' value to spider more pages.
|_http-chrono: Request times for /; avg: 1198.90ms; min: 1126.79ms; max: 1299.84ms
|_http-comments-displayer: Couldn't find any comments.
| http-enum: 
|_  /blog/: Blog
|_http-fetch: Please enter the complete path of the directory to save data in.
| http-wordpress-enum: 
| Search limited to top 100 themes/plugins
|   plugins
|     contact-form-7
|   themes
|_    twentytwelve
| http-waf-detect: IDS/IPS/WAF detected:
|_192.168.109.10:9090/?p4yl04d2=1%20UNION%20ALL%20SELECT%201,2,3,table_name%20FROM%20information_schema.tables
| http-useragent-tester: 
|   Status for browser useragent: 200
|   Redirected To: https://192.168.109.10:9090/
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
|_http-drupal-enum: Nothing found amongst the top 100 resources,use --script-args number=<number|all> for deeper analysis)
| http-headers: 
|   Content-Type: text/html
|   Location: https://192.168.109.10:9090/
|   Content-Length: 73
|   Connection: close
|   X-DNS-Prefetch-Control: off
|   Referrer-Policy: no-referrer
|   X-Content-Type-Options: nosniff
|   
|_  (Request type: GET)
| http-vhosts: 
|_128 names had status 301
|_http-dombased-xss: Couldn't find any DOM based XSS.
|_http-errors: Couldn't find any error pages.
|_http-jsonp-detection: Couldn't find any JSONP endpoints.
|_http-mobileversion-checker: No mobile version detected.
|_http-referer-checker: Couldn't find any cross-domain scripts.
Service Info: OS: Linux; CPE: cpe:/o:linux:linux_kernel
```

# nikto 
```
nikto -ask=no -Tuning=x4567890ac -nointeractive -host http://192.168.109.10:9090 2>&1
```

```
+ Server: No banner retrieved
+ /: The anti-clickjacking X-Frame-Options header is not present. See: https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/X-Frame-Options
+ Root page / redirects to: https://192.168.109.10/
+ No CGI Directories found (use '-C all' to force check all possible dirs)
+ ERROR: Error limit (20) reached for host, giving up. Last error: error reading HTTP response
+ Scan terminated: 18 error(s) and 1 item(s) reported on remote host
+ End Time:           2025-08-07 16:53:15 (GMT-7) (1773 seconds)
---------------------------------------------------------------------------
+ 1 host(s) tested
```

# Identify Tech Stack
## whatweb
```
whatweb $URL
```

```
http://192.168.109.10:9090 [301 Moved Permanently] Country[RESERVED][ZZ], IP[192.168.109.10], RedirectLocation[https://192.168.109.10:9090/], Title[Moved], UncommonHeaders[x-dns-prefetch-control,referrer-policy,x-content-type-options]
https://192.168.109.10:9090/ [200 OK] Cookies[cockpit], Country[RESERVED][ZZ], HTML5, HttpOnly[cockpit], IP[192.168.109.10], PasswordField, Script, Title[Loading...], UncommonHeaders[content-security-policy,x-dns-prefetch-control,referrer-policy,x-content-type-options]
```

# Manual Enumeration
(Walk application functionality in Burp Suite)

![[Pasted image 20250807163722.png]]

Judging by nmap's fingerprinting and other images online, this appears to be Cockpit

https://cockpit-project.org/guide/latest/authentication

>While cockpit allows you to monitor and administer several servers at the same time, there is always a primary server your browser connects to that runs the Cockpit web service (cockpit-ws) through which connections to additional servers are established.

>The most common way to use Cockpit is to just log directly into the server that you want to access. This can be done if you have direct network access to port 9090 on that server.
>By default the cockpit web service is installed on the base system and socket activated by systemd.

So, this would be the cockpit web service, and access would likely give us some control over the server. The login is controlled by the local account running the service, so it doesn't ship with a default password.

I found an authenticated SSRF vulnerability, CVE-2020-35850, PoC in cockpit: 

PoC: https://github.com/passtheticket/vulnerability-research/blob/main/cockpitProject/README.md
GitHub issue: https://github.com/cockpit-project/cockpit/issues/15077

This could be used to enumerate internal ports and SSH credentials, but isn't critical, so I'll keep looking and return to this later.

# After gaining access as james from [[Archive/OFFSEC - Proving Grounds Writeups/Linux/Cockpit/Service Enumeration/80 HTTP|80 HTTP]]

![[Pasted image 20250807175846.png]]

Under the terminal tab, we have immediate RCE as james!

![[Pasted image 20250807180204.png]]

We'll continue immediately to [[Archive/OFFSEC - Proving Grounds Writeups/Linux/Cockpit/Privilege Escalation]] for privilege escalation.