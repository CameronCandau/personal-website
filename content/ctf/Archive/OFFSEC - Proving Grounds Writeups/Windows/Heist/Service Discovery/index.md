# Host information

```
Operating System: Windows
```

# Environment Variables / Setup

```
export IP=192.168.247.165
mkdir nmap && cd nmap
```

# Scans

## AutoRecon
https://github.com/Tib3rius/AutoRecon
## nmap 

Either use [v-scan.sh](https://github.com/CameronCandau/OSCP-Automation/blob/main/bin/v-scan.sh) or the following commands.
### Fast Scan
Quickly discover open ports to expedite future scans.

```
nmap --min-rate 4500 --max-rtt-timeout 1500ms -p- -Pn $IP -oG all_ports.gnmap
```

Get list of open ports:
```
TCP_PORTS=$(grep -oP '\d+/open' all_ports.gnmap | cut -d/ -f1 | paste -sd, -)
```


### Full TCP Scan + Scripts 

```
nmap -sC -sV -T4 -Pn -p$TCP_PORTS $IP -oA full_tcp
```


```
PORT      STATE SERVICE       VERSION
53/tcp    open  domain        Simple DNS Plus
88/tcp    open  kerberos-sec  Microsoft Windows Kerberos (server time: 2025-08-03 16:53:57Z)
135/tcp   open  msrpc         Microsoft Windows RPC
139/tcp   open  netbios-ssn   Microsoft Windows netbios-ssn
389/tcp   open  ldap          Microsoft Windows Active Directory LDAP (Domain: heist.offsec0., Site: Default-First-Site-Name)
445/tcp   open  microsoft-ds?
464/tcp   open  kpasswd5?
593/tcp   open  ncacn_http    Microsoft Windows RPC over HTTP 1.0
636/tcp   open  tcpwrapped
3268/tcp  open  ldap          Microsoft Windows Active Directory LDAP (Domain: heist.offsec0., Site: Default-First-Site-Name)
3269/tcp  open  tcpwrapped
3389/tcp  open  ms-wbt-server Microsoft Terminal Services
|_ssl-date: 2025-08-03T16:55:26+00:00; 0s from scanner time.
| rdp-ntlm-info:
|   Target_Name: HEIST
|   NetBIOS_Domain_Name: HEIST
|   NetBIOS_Computer_Name: DC01
|   DNS_Domain_Name: heist.offsec
|   DNS_Computer_Name: DC01.heist.offsec
|   DNS_Tree_Name: heist.offsec
|   Product_Version: 10.0.17763
|_  System_Time: 2025-08-03T16:54:47+00:00
| ssl-cert: Subject: commonName=DC01.heist.offsec
| Not valid before: 2025-08-02T16:51:08
|_Not valid after:  2026-02-01T16:51:08
5985/tcp  open  http          Microsoft HTTPAPI httpd 2.0 (SSDP/UPnP)
|_http-server-header: Microsoft-HTTPAPI/2.0
|_http-title: Not Found
8080/tcp  open  http          Werkzeug httpd 2.0.1 (Python 3.9.0)
|_http-server-header: Werkzeug/2.0.1 Python/3.9.0
|_http-title: Super Secure Web Browser
9389/tcp  open  mc-nmf        .NET Message Framing
49666/tcp open  msrpc         Microsoft Windows RPC
49668/tcp open  msrpc         Microsoft Windows RPC
49673/tcp open  ncacn_http    Microsoft Windows RPC over HTTP 1.0
49674/tcp open  msrpc         Microsoft Windows RPC
49677/tcp open  msrpc         Microsoft Windows RPC
49703/tcp open  msrpc         Microsoft Windows RPC
Service Info: Host: DC01; OS: Windows; CPE: cpe:/o:microsoft:windows

Host script results:
| smb2-time:
|   date: 2025-08-03T16:54:51
|_  start_date: N/A
| smb2-security-mode:
|   3:1:1:
|_    Message signing enabled and required
```

### UDP Scan

```
nmap -sU --top-ports 100 -T4 -Pn $IP -oA top_udp
```

```
PORT    STATE SERVICE
53/udp  open  domain
88/udp  open  kerberos-sec
123/udp open  ntp
```

# Continue: [[Archive/OFFSEC - Proving Grounds Writeups/Windows/Heist/Service Enumeration/53 DNS|53 DNS]]

---
Checklist

~~53~~ 
88
135
~~139~~
389 (no anon)
445 (no anon)
464
593
636 (no anon)
3268
3269
3389
5985, 47001 ([internal](https://morgansimonsen.com/2009/12/10/winrm-and-tcp-ports/)) - WinRM (available but need creds)
8080 - HTTP Browser App -> SSRF
9389
49666
49668
49673
49674
49677
49703