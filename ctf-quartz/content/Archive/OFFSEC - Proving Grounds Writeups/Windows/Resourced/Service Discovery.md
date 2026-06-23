# Host information

```
Operating System:Windows 10 / Server 2019 Build 17763
Hostname: ResourceDC.resourced.local (add to /etc/hosts)
```

# Environment Variables / Setup

```
export IP=192.168.230.175
mkdir nmap && cd nmap
```


---
# Scans

## AutoRecon
https://github.com/Tib3rius/AutoRecon

`autorecon $IP`

### Quick TCP Scan + Scripts 
(From autorecon)
```
nmap --privileged -vv --reason -Pn -T4 -sV -sC --version-all -A --osscan-guess -p-
```

```
PORT      STATE SERVICE       REASON          VERSION
53/tcp    open  domain        syn-ack ttl 125 (generic dns response: SERVFAIL)
| fingerprint-strings: 
|   DNS-SD-TCP: 
|     _services
|     _dns-sd
|     _udp
|_    local
88/tcp    open  kerberos-sec  syn-ack ttl 125 Microsoft Windows Kerberos (server time: 2025-08-08 14:21:03Z)
135/tcp   open  msrpc         syn-ack ttl 125 Microsoft Windows RPC
139/tcp   open  netbios-ssn   syn-ack ttl 125 Microsoft Windows netbios-ssn
389/tcp   open  ldap          syn-ack ttl 125 Microsoft Windows Active Directory LDAP (Domain: resourced.local0., Site: Default-First-Site-Name)
445/tcp   open  microsoft-ds? syn-ack ttl 125
464/tcp   open  kpasswd5?     syn-ack ttl 125
593/tcp   open  ncacn_http    syn-ack ttl 125 Microsoft Windows RPC over HTTP 1.0
636/tcp   open  tcpwrapped    syn-ack ttl 125
3268/tcp  open  ldap          syn-ack ttl 125 Microsoft Windows Active Directory LDAP (Domain: resourced.local0., Site: Default-First-Site-Name)
3269/tcp  open  tcpwrapped    syn-ack ttl 125
3389/tcp  open  ms-wbt-server syn-ack ttl 125 Microsoft Terminal Services
| ssl-cert: Subject: commonName=ResourceDC.resourced.local
| Issuer: commonName=ResourceDC.resourced.local
| Public Key type: rsa
| Public Key bits: 2048
| Signature Algorithm: sha256WithRSAEncryption
| Not valid before: 2025-08-07T14:16:53
| Not valid after:  2026-02-06T14:16:53
| MD5:   ffe3:6d99:6999:9df0:9522:0b40:d32c:1ffa
| SHA-1: f204:a981:a715:a9cf:b8b4:2d18:aac9:9e85:b22d:dc26
| -----BEGIN CERTIFICATE-----
| MIIC+DCCAeCgAwIBAgIQLKXr7ULy/7JEvo2OwUE/+zANBgkqhkiG9w0BAQsFADAl
| MSMwIQYDVQQDExpSZXNvdXJjZURDLnJlc291cmNlZC5sb2NhbDAeFw0yNTA4MDcx
| NDE2NTNaFw0yNjAyMDYxNDE2NTNaMCUxIzAhBgNVBAMTGlJlc291cmNlREMucmVz
| b3VyY2VkLmxvY2FsMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAl58A
| sfuQPfLUvAkXaPGF5KPtj5DZyj9OG5S2XU+hykPZkx2NsqrYH4SyMK+m7kx+9wlU
| bp6QxookOCdncVO0GVojBmy9fb5Ede/2KMphWvObOXYtJMWQbLlOgv6TYJCDD9di
| IpCYyiwUfIbek0s01E5QiGGp7mPIBXNMTpoNyKpaA6gY+3uqMtkoqMzPufduRKuf
| HkSmkkwwHuH21FtB+bw5hj1rTU9N+7zlY1u36h/lMlnRemcqxuqrJz1qm3Tw60VE
| an0ffy/jGN5mzYmU6dcg+ky7zIqKjlKvN7Jjncz6xwPNJ9YMeAeo+aUd9ZkuGbMy
| DLMmKx2Q5u4eWVqYeQIDAQABoyQwIjATBgNVHSUEDDAKBggrBgEFBQcDATALBgNV
| HQ8EBAMCBDAwDQYJKoZIhvcNAQELBQADggEBAB34H5XLws9netnR/aBdXfnHjO2Y
| pW80jZNim81TKA2uzOJjzknp+FUxUnD5jkAeq8jnEpduufBqoeQ841zoZsJciyrF
| 8w3W+bkooeQl9cVh2qlFL06ntI4UluVJhQvJNTRsuPWPV7QM0HHqO7kOLsL6Fpr6
| lTCF3kH4E43L/oJ7+IY+6lHXOBmM1bjBZ1tclXH5cnGNcqFCJkvqCQopiIoHMaUB
| LKoG+79zIgbg4yaj0Ul/DRYMRsaB8SoNLI9PHNz9QXjePC+U9t7yyVhztfx/PNSW
| T65+QVJSvx0LgVca+lfb8g5m5yFNS2ebTL6fc6hR7w+ISegEoPNSQscUAUk=
|_-----END CERTIFICATE-----
| rdp-ntlm-info: 
|   Target_Name: resourced
|   NetBIOS_Domain_Name: resourced
|   NetBIOS_Computer_Name: RESOURCEDC
|   DNS_Domain_Name: resourced.local
|   DNS_Computer_Name: ResourceDC.resourced.local
|   DNS_Tree_Name: resourced.local
|   Product_Version: 10.0.17763
|_  System_Time: 2025-08-08T14:29:27+00:00
|_ssl-date: 2025-08-08T14:30:07+00:00; +1s from scanner time.
5985/tcp  open  http          syn-ack ttl 125 Microsoft HTTPAPI httpd 2.0 (SSDP/UPnP)
|_http-server-header: Microsoft-HTTPAPI/2.0
|_http-title: Not Found
9389/tcp  open  mc-nmf        syn-ack ttl 125 .NET Message Framing
49666/tcp open  msrpc         syn-ack ttl 125 Microsoft Windows RPC
49667/tcp open  msrpc         syn-ack ttl 125 Microsoft Windows RPC
49674/tcp open  ncacn_http    syn-ack ttl 125 Microsoft Windows RPC over HTTP 1.0
49675/tcp open  msrpc         syn-ack ttl 125 Microsoft Windows RPC
49693/tcp open  msrpc         syn-ack ttl 125 Microsoft Windows RPC
49712/tcp open  msrpc         syn-ack ttl 125 Microsoft Windows RPC
1 service unrecognized despite returning data. If you know the service/version, please submit the following fingerprint at https://nmap.org/cgi-bin/submit.cgi?new-service :
SF-Port53-TCP:V=7.95%I=9%D=8/8%Time=689607DD%P=x86_64-pc-linux-gnu%r(DNS-S
SF:D-TCP,30,"\0\.\0\0\x80\x82\0\x01\0\0\0\0\0\0\t_services\x07_dns-sd\x04_
SF:udp\x05local\0\0\x0c\0\x01");
Warning: OSScan results may be unreliable because we could not find at least 1 open and 1 closed port
Device type: general purpose
Running (JUST GUESSING): Microsoft Windows 2019|10 (92%)
OS CPE: cpe:/o:microsoft:windows_server_2019 cpe:/o:microsoft:windows_10
OS fingerprint not ideal because: Missing a closed TCP port so results incomplete
Aggressive OS guesses: Windows Server 2019 (92%), Microsoft Windows 10 1903 - 21H1 (85%), Microsoft Windows 10 1607 (85%)
No exact OS matches for host (test conditions non-ideal).
TCP/IP fingerprint:
SCAN(V=7.95%E=4%D=8/8%OT=53%CT=%CU=%PV=Y%DS=4%DC=T%G=N%TM=689609F2%P=x86_64-pc-linux-gnu)
SEQ(SP=104%GCD=1%ISR=10E%TI=I%TS=U)
SEQ(SP=105%GCD=1%ISR=10B%TI=I%TS=U)
OPS(O1=M578NW8NNS%O2=M578NW8NNS%O3=M578NW8%O4=M578NW8NNS%O5=M578NW8NNS%O6=M578NNS)
WIN(W1=FFFF%W2=FFFF%W3=FFFF%W4=FFFF%W5=FFFF%W6=FF70)
ECN(R=Y%DF=Y%TG=80%W=FFFF%O=M578NW8NNS%CC=Y%Q=)
T1(R=Y%DF=Y%TG=80%S=O%A=S+%F=AS%RD=0%Q=)
T2(R=N)
T3(R=N)
T4(R=N)
U1(R=N)
IE(R=N)

Network Distance: 4 hops
TCP Sequence Prediction: Difficulty=260 (Good luck!)
IP ID Sequence Generation: Incremental
Service Info: Host: RESOURCEDC; OS: Windows; CPE: cpe:/o:microsoft:windows

Host script results:
| p2p-conficker: 
|   Checking for Conficker.C or higher...
|   Check 1 (port 7441/tcp): CLEAN (Timeout)
|   Check 2 (port 23532/tcp): CLEAN (Timeout)
|   Check 3 (port 50295/udp): CLEAN (Timeout)
|   Check 4 (port 28653/udp): CLEAN (Timeout)
|_  0/4 checks are positive: Host is CLEAN or ports are blocked
| smb2-security-mode: 
|   3:1:1: 
|_    Message signing enabled and required
| smb2-time: 
|   date: 2025-08-08T14:29:31
|_  start_date: N/A
|_clock-skew: mean: 0s, deviation: 0s, median: 0s

TRACEROUTE (using port 3389/tcp)
HOP RTT       ADDRESS
1   120.74 ms 192.168.45.1
2   120.59 ms 192.168.45.254
3   120.84 ms 192.168.251.1
4   121.24 ms 192.168.230.175
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


# Continue: [[Archive/OFFSEC - Proving Grounds Writeups/Windows/Resourced/Service Enumeration/53 DNS|53 DNS]]
