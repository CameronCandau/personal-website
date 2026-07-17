# Initial Setup & Information Gathering

## Host Information
```
Target IP:192.168.159.189
Operating System:Windows 2016 x64
Domain/Hostname:Squid
Difficulty: Easy
```

## Environment Variables / Setup
```
export IP=192.168.159.189
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
PORT      STATE SERVICE       REASON          VERSION
135/tcp   open  msrpc         syn-ack ttl 125 Microsoft Windows RPC
139/tcp   open  netbios-ssn   syn-ack ttl 125 Microsoft Windows netbios-ssn
445/tcp   open  microsoft-ds? syn-ack ttl 125
3128/tcp  open  http-proxy    syn-ack ttl 125 Squid http proxy 4.14
|_http-title: ERROR: The requested URL could not be retrieved
|_http-server-header: squid/4.14
49666/tcp open  msrpc         syn-ack ttl 125 Microsoft Windows RPC
49667/tcp open  msrpc         syn-ack ttl 125 Microsoft Windows RPC
Warning: OSScan results may be unreliable because we could not find at least 1 open and 1 closed port
Device type: general purpose
Running (JUST GUESSING): Microsoft Windows 2019 (92%)
OS CPE: cpe:/o:microsoft:windows_server_2019
OS fingerprint not ideal because: Missing a closed TCP port so results incomplete
Aggressive OS guesses: Windows Server 2019 (92%)
No exact OS matches for host (test conditions non-ideal).
TCP/IP fingerprint:
SCAN(V=7.95%E=4%D=8/24%OT=135%CT=%CU=%PV=Y%DS=4%DC=T%G=N%TM=68AB22DB%P=x86_64-pc-linux-gnu)
SEQ(SP=101%GCD=1%ISR=10D%TS=U)
SEQ(SP=F7%GCD=2%ISR=10E%TS=U)
OPS(O1=M578NW8NNS%O2=M578NW8NNS%O3=M578NW8%O4=M578NW8NNS%O5=M578NW8NNS%O6=M578NNS)
WIN(W1=FFFF%W2=FFFF%W3=FFFF%W4=FFFF%W5=FFFF%W6=FF70)
ECN(R=Y%DF=Y%TG=80%W=FFFF%O=M578NW8NNS%CC=Y%Q=)
T1(R=Y%DF=Y%TG=80%S=O%A=S+%F=AS%RD=0%Q=)
T2(R=N)
T3(R=N)
T3(R=Y%DF=Y%TG=80%W=FFFF%S=O%A=O%F=AS%O=M578NW8NNS%RD=0%Q=)
T4(R=N)
U1(R=N)
IE(R=N)

Network Distance: 4 hops
TCP Sequence Prediction: Difficulty=247 (Good luck!)
IP ID Sequence Generation: Busy server or unknown class
Service Info: OS: Windows; CPE: cpe:/o:microsoft:windows

Host script results:
| p2p-conficker: 
|   Checking for Conficker.C or higher...
|   Check 1 (port 32092/tcp): CLEAN (Timeout)
|   Check 2 (port 64473/tcp): CLEAN (Timeout)
|   Check 3 (port 61318/udp): CLEAN (Timeout)
|   Check 4 (port 48817/udp): CLEAN (Timeout)
|_  0/4 checks are positive: Host is CLEAN or ports are blocked
| smb2-time: 
|   date: 2025-08-24T14:33:27
|_  start_date: N/A
|_clock-skew: 0s
| smb2-security-mode: 
|   3:1:1: 
|_    Message signing enabled but not required

TRACEROUTE (using port 135/tcp)
HOP RTT       ADDRESS
1   111.60 ms 192.168.45.1
2   110.54 ms 192.168.45.254
3   110.01 ms 192.168.251.1
4   108.45 ms 192.168.159.189
```

### UDP Top Ports
```
nmap -sU --top-ports 100 -T4 -Pn $IP -oA nmap/top_udp
```

(None)

# Phase 2: Service Enumeration Priority

Based on discovered services, follow this priority order:

- [ ] [[3128 HTTP|3128 HTTP]]
- [ ] [[OSCP Preparation/OffSec Proving Grounds/Windows/Easy/Squid/Service Enumeration/139,445 SMB|139,445 SMB]]
- [ ] [[OSCP Preparation/OffSec Proving Grounds/Windows/Easy/Squid/Service Enumeration/135 WMI,MSRPC|135 WMI,MSRPC]]

