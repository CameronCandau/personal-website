# Initial Setup & Information Gathering

## Host Information
```
Target IP: 192.168.159.146
Operating System: Linux (Debian)
Difficulty: Intermediate
Start Time:
```

## Environment Variables / Setup
```
export IP=192.168.159.146
mkdir $IP && cd $IP
mkdir {nmap,web,smb,ftp,exploit,loot}
```

# Phase 1: Port Discovery

## AutoRecon 
`autorecon $IP --only-scans-dir`

`cat results/$IP/scans/_full_tcp_nmap.txt`

```
PORT      STATE SERVICE REASON         VERSION
22/tcp    open  ssh     syn-ack ttl 61 OpenSSH 7.9p1 Debian 10+deb10u2 (protocol 2.0)
| ssh-hostkey: 
|   2048 37:80:01:4a:43:86:30:c9:79:e7:fb:7f:3b:a4:1e:dd (RSA)
| ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDBCcfKYKMXuTWeyLKlFNHgmebcXbFAjSpbr39R8GFHYRmc/mZXKNgEoa5gkFAVr8kVVul4X6//DcnRuHtrCpHcnTIZLT9g1DPB09VsLzsjT0TpmqkcDYtZazo1mjnBZdaM+AxoDMghZd8AXiNrCl7jCN+vRjUQc8T1wD4PoC02XjeCAI8Yha++Mv9ZrSPZ+/gBvgZPL3pdQhVGUSUHOmXod4xcdm5ReNiZRNZklOhhscbGfSCqQIdJogegZfMrlueeG3EY7Kkf5CxAUDH/9ir2dEDDifIpqKV8W7ncKEpsZiqgDh36OdMX4LPJ0NmZiT/g8CvINx7k4HWj3ksT+5C7
|   256 b6:18:a1:e1:98:fb:6c:c6:87:55:45:10:c6:d4:45:b9 (ECDSA)
| ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBEK0B9iLJQztyEpGiNffHgQuGcxZRO/BOi+r0j/P8Hkz02pIWW2hFrArbzehUNQ46ZmFwMhxxmrIOLBpUt9ZGBw=
|   256 ab:8f:2d:e8:a2:04:e7:b7:65:d3:fe:5e:93:1e:03:67 (ED25519)
|_ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOAlO2qlRhyMwzzf3xAK4wOGz1UD5t9+QQO5J3QjTkaZ
80/tcp    open  http    syn-ack ttl 61 Apache httpd 2.4.38 ((Debian))
| http-cookie-flags: 
|   /: 
|     PHPSESSID: 
|_      httponly flag not set
|_http-server-header: Apache/2.4.38 (Debian)
|_http-favicon: Unknown favicon MD5: ED9A8C7810E8C9FB7035B6C3147C9A3A
| http-title: SuiteCRM
|_Requested resource was index.php?action=Login&module=Users
| http-robots.txt: 1 disallowed entry 
|_/
| http-methods: 
|_  Supported Methods: GET HEAD POST OPTIONS
3306/tcp  open  mysql   syn-ack ttl 61 MySQL (unauthorized)
33060/tcp open  mysqlx  syn-ack ttl 61 MySQL X protocol listener
Device type: general purpose|router
Running: Linux 5.X, MikroTik RouterOS 7.X
OS CPE: cpe:/o:linux:linux_kernel:5 cpe:/o:mikrotik:routeros:7 cpe:/o:linux:linux_kernel:5.6.3
OS details: Linux 5.0 - 5.14, MikroTik RouterOS 7.2 - 7.5 (Linux 5.6.3)
TCP/IP fingerprint:
OS:SCAN(V=7.95%E=4%D=8/24%OT=22%CT=1%CU=30223%PV=Y%DS=4%DC=T%G=Y%TM=68AB811
OS:4%P=x86_64-pc-linux-gnu)SEQ(SP=105%GCD=1%ISR=10D%TI=Z%CI=Z%TS=A)SEQ(SP=F
OS:D%GCD=1%ISR=10F%TI=Z%CI=Z%TS=A)SEQ(SP=FF%GCD=1%ISR=107%TI=Z%CI=Z%TS=D)OP
OS:S(O1=M578ST11NW7%O2=M578ST11NW7%O3=M578NNT11NW7%O4=M578ST11NW7%O5=M578ST
OS:11NW7%O6=M578ST11)WIN(W1=FE88%W2=FE88%W3=FE88%W4=FE88%W5=FE88%W6=FE88)EC
OS:N(R=Y%DF=Y%T=40%W=FAF0%O=M578NNSNW7%CC=Y%Q=)T1(R=Y%DF=Y%T=40%S=O%A=O%F=A
OS:P%RD=0%Q=)T1(R=Y%DF=Y%T=40%S=O%A=S+%F=AS%RD=0%Q=)T2(R=N)T3(R=N)T4(R=Y%DF
OS:=Y%T=40%W=0%S=A%A=Z%F=R%O=%RD=0%Q=)T5(R=Y%DF=Y%T=40%W=0%S=Z%A=S+%F=AR%O=
OS:%RD=0%Q=)T6(R=Y%DF=Y%T=40%W=0%S=A%A=Z%F=R%O=%RD=0%Q=)T7(R=N)U1(R=Y%DF=N%
OS:T=40%IPL=164%UN=0%RIPL=G%RID=G%RIPCK=G%RUCK=G%RUD=G)IE(R=Y%DFI=N%T=40%CD
OS:=S)

Uptime guess: 12.841 days (since Mon Aug 11 18:04:53 2025)
Network Distance: 4 hops
TCP Sequence Prediction: Difficulty=261 (Good luck!)
IP ID Sequence Generation: All zeros
Service Info: OS: Linux; CPE: cpe:/o:linux:linux_kernel

TRACEROUTE (using port 993/tcp)
HOP RTT       ADDRESS
1   167.58 ms 192.168.45.1
2   167.57 ms 192.168.45.254
3   167.53 ms 192.168.251.1
4   108.41 ms 192.168.159.146

```

## Manual Scanning 

### Fast Port Discovery
```
nmap --min-rate 4500 --max-rtt-timeout 1500ms -p- -Pn $IP -oG nmap/all_ports.gnmap
```

Extract open ports:
```
TCP_PORTS=$(grep -oP '\d+/open' nmap/all_ports.gnmap | cut -d/ -f1 | paste -sd, -)
echo "Open TCP ports: $TCP_PORTS"
```

### Service Detection & Scripts
```
nmap -sC -sV -T4 -Pn -p$TCP_PORTS $IP -oA nmap/full_tcp
```

### UDP Top Ports
```
nmap -sU --top-ports 100 -T4 -Pn $IP -oA nmap/top_udp

# If time permits, scan more UDP ports
nmap -sU --top-ports 1000 -T4 -Pn $IP -oA nmap/extended_udp
```

```
PORT      STATE         SERVICE
427/udp   open|filtered svrloc
443/udp   open|filtered https
996/udp   open|filtered vsinet
1025/udp  open|filtered blackjack
2048/udp  open|filtered dls-monitor
2223/udp  open|filtered rockwell-csp2
32769/udp open|filtered filenet-rpc
49181/udp open|filtered unknown
49186/udp open|filtered unknown
```

# Phase 2: Service Enumeration Priority

Based on discovered services, follow this priority order:

## Critical Services (Immediate Focus)
- [ ] [[Archive/OFFSEC - Proving Grounds Writeups/Linux/Crane/80 HTTP|80 HTTP]]
- [ ] [[OSCP Preparation/OffSec Proving Grounds/Linux/Intermediate/Crane/Service Enumeration/22 SSH|22 SSH]]

## Database Services
- [ ] [[OSCP Preparation/OffSec Proving Grounds/Linux/Intermediate/Crane/Service Enumeration/3306 MySQL|3306 MySQL]]

