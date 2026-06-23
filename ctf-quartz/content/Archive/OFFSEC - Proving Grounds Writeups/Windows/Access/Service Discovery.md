# Host information

```
Operating System: Windows
```

# Environment Variables / Setup

```
export IP=192.168.213.187
mkdir nmap && cd nmap
```


# nmap 

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
80/tcp    open  http          Apache httpd 2.4.48 ((Win64) OpenSSL/1.1.1k PHP/8.0.7)
|_http-server-header: Apache/2.4.48 (Win64) OpenSSL/1.1.1k PHP/8.0.7
| http-methods:
|_  Potentially risky methods: TRACE
|_http-title: Access The Event
88/tcp    open  kerberos-sec  Microsoft Windows Kerberos (server time: 2025-07-25 13:49:45Z)
135/tcp   open  msrpc         Microsoft Windows RPC
139/tcp   open  netbios-ssn   Microsoft Windows netbios-ssn
389/tcp   open  ldap          Microsoft Windows Active Directory LDAP (Domain: access.offsec0., Site: Default-First-Site-Name)
443/tcp   open  ssl/http      Apache httpd 2.4.48 ((Win64) OpenSSL/1.1.1k PHP/8.0.7)
| ssl-cert: Subject: commonName=localhost
| Not valid before: 2009-11-10T23:48:47
|_Not valid after:  2019-11-08T23:48:47
|_ssl-date: TLS randomness does not represent time
|_http-title: Access The Event
| tls-alpn:
|_  http/1.1
|_http-server-header: Apache/2.4.48 (Win64) OpenSSL/1.1.1k PHP/8.0.7
| http-methods:
|_  Potentially risky methods: TRACE
445/tcp   open  microsoft-ds?
464/tcp   open  kpasswd5?
593/tcp   open  ncacn_http    Microsoft Windows RPC over HTTP 1.0
636/tcp   open  tcpwrapped
3268/tcp  open  ldap          Microsoft Windows Active Directory LDAP (Domain: access.offsec0., Site: Default-First-Site-Name)
3269/tcp  open  tcpwrapped
5985/tcp  open  http          Microsoft HTTPAPI httpd 2.0 (SSDP/UPnP)
|_http-server-header: Microsoft-HTTPAPI/2.0
|_http-title: Not Found
9389/tcp  open  mc-nmf        .NET Message Framing
47001/tcp open  http          Microsoft HTTPAPI httpd 2.0 (SSDP/UPnP)
|_http-server-header: Microsoft-HTTPAPI/2.0
|_http-title: Not Found
49664/tcp open  msrpc         Microsoft Windows RPC
49665/tcp open  msrpc         Microsoft Windows RPC
49666/tcp open  msrpc         Microsoft Windows RPC
49668/tcp open  msrpc         Microsoft Windows RPC
49669/tcp open  ncacn_http    Microsoft Windows RPC over HTTP 1.0
49670/tcp open  msrpc         Microsoft Windows RPC
49673/tcp open  msrpc         Microsoft Windows RPC
49678/tcp open  msrpc         Microsoft Windows RPC
49691/tcp open  msrpc         Microsoft Windows RPC
49701/tcp open  msrpc         Microsoft Windows RPC
49719/tcp open  msrpc         Microsoft Windows RPC
Service Info: Host: SERVER; OS: Windows; CPE: cpe:/o:microsoft:windows

Host script results:
| smb2-time:
|   date: 2025-07-25T13:50:39
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
PORT      STATE         SERVICE
53/udp    open          domain
88/udp    open          kerberos-sec
123/udp   open          ntp
137/udp   open|filtered netbios-ns
138/udp   open|filtered netbios-dgm
139/udp   open|filtered netbios-ssn
500/udp   open|filtered isakmp
998/udp   open|filtered puparp
1645/udp  open|filtered radius
1812/udp  open|filtered radius
2048/udp  open|filtered dls-monitor
2222/udp  open|filtered msantipiracy
4500/udp  open|filtered nat-t-ike
5000/udp  open|filtered upnp
5353/udp  open|filtered zeroconf
9200/udp  open|filtered wap-wsp
32768/udp open|filtered omad
32771/udp open|filtered sometimes-rpc6
49201/udp open|filtered unknown
```

# Priorities
1. [[Archive/OFFSEC - Proving Grounds Writeups/Windows/Access/Service Enumeration/80 HTTP|HTTP]]
2. FTP
3. SMB