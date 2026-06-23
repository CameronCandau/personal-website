# Initial Setup & Information Gathering

## Host Information
```
Target IP:192.168.174.25
Operating System: Linux
Difficulty: Easy 
```

## Environment Variables / Setup
```
export IP=192.168.174.25
mkdir $IP && cd $IP
mkdir {nmap,web,smb,ftp,exploit,loot}
```

# Phase 1: Port Discovery

## AutoRecon (Recommended for comprehensive enum)
```
autorecon $IP --only-scans-dir
```


`cat results/$IP/scans/_full_tcp_nmap.txt`

```
PORT     STATE SERVICE  REASON         VERSION
22/tcp   open  ssh      syn-ack ttl 61 OpenSSH 8.4p1 Debian 5+deb11u1 (protocol 2.0)
| ssh-hostkey: 
|   3072 c9:c3:da:15:28:3b:f1:f8:9a:36:df:4d:36:6b:a7:44 (RSA)
| ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDNEbgprJqVJa8R95Wkbo3cemB4fdRzos+v750LtPEnRs+IJQn5jcg5l89Tx4junU+AXzLflrMVo55gbuKeNTDtFRU9ltlIu4AU+f7lRlUlvAHlNjUbU/z3WBZ5ZU9j7Xc9WKjh1Ov7chC0UnDdyr5EGrIwlLzgk8zrWx364+S4JqLtER2/n0rhVxa9RCw0tR/oL24kMep4q7rFK6dThiRtQ9nsJFhh6yw8Fmdg7r4uohqH70UJurVwVNwFqtr/86e4VSSoITlMQPZrZFVvoSsjyL8LEODt1qznoLWudMD95Eo1YFSPID5VcS0kSElfYigjSr+9bNSdlzAof1mU6xJA67BggGNu6qITWWIJySXcropehnDAt2nv4zaKAUKc/T0ij9wkIBskuXfN88cEmZbu+gObKbLgwQSRQJIpQ+B/mA8CD4AiaTmEwGSWz1dVPp5Fgb6YVy6E4oO9ASuD9Q1JWuRmnn8uiHF/nPLs2LC2+rh3nPLXlV+MG/zUfQCrdrE=
|   256 26:03:2b:f6:da:90:1d:1b:ec:8d:8f:8d:1e:7e:3d:6b (ECDSA)
| ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBCUhhvrIBs53SApXKZYHWBlpH50KO3POt8Y+WvTvHZ5YgRagAEU5eSnGkrnziCUvDWNShFhLHI7kQv+mx+4R6Wk=
|   256 fb:43:b2:b0:19:2f:d3:f6:bc:aa:60:67:ab:c1:af:37 (ED25519)
|_ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIN4MSEXnpONsc0ANUT6rFQPWsoVmRW4hrpSRq++xySM9
80/tcp   open  http     syn-ack ttl 61 nginx 1.18.0
| http-methods: 
|_  Supported Methods: GET HEAD
|_http-title: 403 Forbidden
|_http-server-header: nginx/1.18.0
8082/tcp open  http     syn-ack ttl 61 Barracuda Embedded Web Server
|_http-title: Home
| http-webdav-scan: 
|   Server Date: Sat, 23 Aug 2025 00:34:40 GMT
|   WebDAV type: Unknown
|   Server Type: BarracudaServer.com (Posix)
|_  Allowed Methods: OPTIONS, GET, HEAD, PROPFIND, PATCH, POST, PUT, COPY, DELETE, MOVE, MKCOL, PROPFIND, PROPPATCH, LOCK, UNLOCK
|_http-server-header: BarracudaServer.com (Posix)
|_http-favicon: Unknown favicon MD5: FDF624762222B41E2767954032B6F1FF
| http-methods: 
|   Supported Methods: OPTIONS GET HEAD PROPFIND PATCH POST PUT COPY DELETE MOVE MKCOL PROPPATCH LOCK UNLOCK
|_  Potentially risky methods: PROPFIND PATCH PUT COPY DELETE MOVE MKCOL PROPPATCH LOCK UNLOCK
9999/tcp open  ssl/http syn-ack ttl 61 Barracuda Embedded Web Server
| ssl-cert: Subject: commonName=FuguHub/stateOrProvinceName=California/countryName=US
| Subject Alternative Name: DNS:FuguHub, DNS:FuguHub.local, DNS:localhost
| Issuer: commonName=Real Time Logic Root CA/organizationName=Real Time Logic LLC/countryName=US/organizationalUnitName=SharkSSL/emailAddress=ginfo@realtimelogic.com
| Public Key type: rsa
| Public Key bits: 2048
| Signature Algorithm: sha256WithRSAEncryption
| Not valid before: 2019-07-16T19:15:09
| Not valid after:  2074-04-18T19:15:09
| MD5:   6320:2067:19be:be32:18ce:3a61:e872:cc3f
| SHA-1: 503c:a62d:8a8c:f8c1:6555:ec50:77d1:73cc:0865:ec62
| -----BEGIN CERTIFICATE-----
| MIIEfDCCA2SgAwIBAgIBEDANBgkqhkiG9w0BAQsFADCBiDELMAkGA1UEBhMCVVMx
| HDAaBgNVBAoTE1JlYWwgVGltZSBMb2dpYyBMTEMxETAPBgNVBAsTCFNoYXJrU1NM
| MSAwHgYDVQQDExdSZWFsIFRpbWUgTG9naWMgUm9vdCBDQTEmMCQGCSqGSIb3DQEJ
| ARYXZ2luZm9AcmVhbHRpbWVsb2dpYy5jb20wIBcNMTkwNzE2MTkxNTA5WhgPMjA3
| NDA0MTgxOTE1MDlaMDQxCzAJBgNVBAYTAlVTMRMwEQYDVQQIDApDYWxpZm9ybmlh
| MRAwDgYDVQQDDAdGdWd1SHViMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKC
| AQEA2uaLiecelbCvdPpZcmweQmK+rcxjFwKKx+ButcLc/vgDTbbDDsg9Pfn78RNE
| hrM1WsvkGXKgJY2M9tzTB6o27pUipwfYAA8a4mV7wfM+YGOVuC05t3oh3+GtSciQ
| ZNDEX3cSZ5XanKPNe9vNBNtFiC5ujadbsLWJxC4mHR9fnx3fPlhQO25QBcX+0M1h
| vOwsidZaqyl+R1zMOi/6IpJJobTJMRKT23N61q3ZKeJnZM2JK9H2srC8tRlIidpf
| Iu3Sv7St3Hg2VzbtlEDpGdISZTwpB+MIgvcZ2Z5IVfnhYJlQlNGHbg8jnegA07VE
| AsfkNlyMfVO88TCo5fLhE6wZLwIDAQABo4IBQDCCATwwHQYDVR0OBBYEFI5fqYOD
| ozZher2qQbU3//9gzTIyMIG1BgNVHSMEga0wgaqAFHlYmIP3mqIAiKOI3DxqZo3k
| KQKGoYGOpIGLMIGIMQswCQYDVQQGEwJVUzEcMBoGA1UEChMTUmVhbCBUaW1lIExv
| Z2ljIExMQzERMA8GA1UECxMIU2hhcmtTU0wxIDAeBgNVBAMTF1JlYWwgVGltZSBM
| b2dpYyBSb290IENBMSYwJAYJKoZIhvcNAQkBFhdnaW5mb0ByZWFsdGltZWxvZ2lj
| LmNvbYIBADAJBgNVHRMEAjAAMAsGA1UdDwQEAwIDqDAdBgNVHSUEFjAUBggrBgEF
| BQcDAgYIKwYBBQUHAwEwLAYDVR0RBCUwI4IHRnVndUh1YoINRnVndUh1Yi5sb2Nh
| bIIJbG9jYWxob3N0MA0GCSqGSIb3DQEBCwUAA4IBAQBsn2vzaK/2bKmWJ52FiRVw
| K3NxCqQrxHjXp2nJFc0S05XnCUqN5RbTgyhv0a8ODniaiJbXAaJC34Ot+v6UMeWE
| CHmZgjbZUvsrQiEUz+i0fegtwp+zgSOlb6t+g3lPGTzBjlFUfb0gaRSxSoI42apG
| QBwoN1haaHhm6THC7DIYmFiOgRiQfitiTf9FtbwTTfrLnVm3e3dCuwCmkcDgBZE1
| Q0M4pGSS3vWTQxF6oyYNe7mhtvGeG7qYE6amtF9iuiUt0MrH4hXTMfHcjHdRULgc
| 1a3vVPwl5CZsQRz40OPrQVtF7rcXRNWsU/1ze9r1sgeLxvjWmbW0GByKJ+jnHALy
|_-----END CERTIFICATE-----
|_http-title: Home
|_http-favicon: Unknown favicon MD5: FDF624762222B41E2767954032B6F1FF
| http-methods: 
|   Supported Methods: OPTIONS GET HEAD PROPFIND PATCH POST PUT COPY DELETE MOVE MKCOL PROPPATCH LOCK UNLOCK
|_  Potentially risky methods: PROPFIND PATCH PUT COPY DELETE MOVE MKCOL PROPPATCH LOCK UNLOCK
|_http-server-header: BarracudaServer.com (Posix)
Device type: general purpose|router
Running: Linux 5.X, MikroTik RouterOS 7.X
OS CPE: cpe:/o:linux:linux_kernel:5 cpe:/o:mikrotik:routeros:7 cpe:/o:linux:linux_kernel:5.6.3
OS details: Linux 5.0 - 5.14, MikroTik RouterOS 7.2 - 7.5 (Linux 5.6.3)
TCP/IP fingerprint:
OS:SCAN(V=7.95%E=4%D=8/22%OT=22%CT=1%CU=35754%PV=Y%DS=4%DC=T%G=Y%TM=68A90CA
OS:D%P=x86_64-pc-linux-gnu)SEQ(SP=106%GCD=1%ISR=107%TI=Z%CI=Z%TS=A)OPS(O1=M
OS:578ST11NW7%O2=M578ST11NW7%O3=M578NNT11NW7%O4=M578ST11NW7%O5=M578ST11NW7%
OS:O6=M578ST11)WIN(W1=FE88%W2=FE88%W3=FE88%W4=FE88%W5=FE88%W6=FE88)ECN(R=Y%
OS:DF=Y%T=40%W=FAF0%O=M578NNSNW7%CC=Y%Q=)T1(R=Y%DF=Y%T=40%S=O%A=S+%F=AS%RD=
OS:0%Q=)T2(R=N)T3(R=N)T4(R=Y%DF=Y%T=40%W=0%S=A%A=Z%F=R%O=%RD=0%Q=)T5(R=Y%DF
OS:=Y%T=40%W=0%S=Z%A=S+%F=AR%O=%RD=0%Q=)T6(R=Y%DF=Y%T=40%W=0%S=A%A=Z%F=R%O=
OS:%RD=0%Q=)T7(R=N)U1(R=Y%DF=N%T=40%IPL=164%UN=0%RIPL=G%RID=G%RIPCK=G%RUCK=
OS:G%RUD=G)IE(R=Y%DFI=N%T=40%CD=S)

Uptime guess: 28.518 days (since Fri Jul 25 05:08:18 2025)
Network Distance: 4 hops
TCP Sequence Prediction: Difficulty=262 (Good luck!)
IP ID Sequence Generation: All zeros
Service Info: OS: Linux; CPE: cpe:/o:linux:linux_kernel

TRACEROUTE (using port 1723/tcp)
HOP RTT       ADDRESS
1   158.07 ms 192.168.45.1
2   157.82 ms 192.168.45.254
3   157.27 ms 192.168.251.1
4   157.30 ms 192.168.174.25
```

### UDP Top Ports
```
# UDP scan is ESSENTIAL - many fail OSCP by skipping this
nmap -sU --top-ports 100 -T4 -Pn $IP -oA nmap/top_udp
```

(None)

# Phase 2: Service Enumeration Priority

Based on discovered services, follow this priority order:

## Critical Services (Immediate Focus)
- [ ] [[Archive/OFFSEC - Proving Grounds Writeups/Linux/Hub/Service Enumeration/80 HTTP|80 HTTP]]
- [ ] [[8082 HTTP]]
- [ ] [[9999 HTTP]]
- [ ] [[OSCP Preparation/OffSec Proving Grounds/Linux/Easy/Hub/Service Enumeration/22 SSH|22 SSH]]
