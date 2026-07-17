# Initial Setup & Information Gathering

## Host Information
```
Target IP: 192.168.159.24
Operating System: Linux
Domain/Hostname: Ubuntu 22.04
Difficulty: Easy
```

## Environment Variables / Setup
```
export IP=192.168.159.24
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
PORT     STATE SERVICE REASON         VERSION
22/tcp   open  ssh     syn-ack ttl 61 OpenSSH 8.9p1 Ubuntu 3 (Ubuntu Linux; protocol 2.0)
| ssh-hostkey: 
|   256 b9:bc:8f:01:3f:85:5d:f9:5c:d9:fb:b6:15:a0:1e:74 (ECDSA)
| ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBBYESg2KmNLhFh1KJaN2UFCVAEv6MWr58pqp2fIpCSBEK2wDJ5ap2XVBVGLk9Po4eKBbqTo96yttfVUvXWXoN3M=
|   256 53:d9:7f:3d:22:8a:fd:57:98:fe:6b:1a:4c:ac:79:67 (ED25519)
|_ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBdIs4PWZ8yY2OQ6Jlk84Ihd5+15Nb3l0qvpf1ls3wfa
8000/tcp open  http    syn-ack ttl 61 WSGIServer 0.2 (Python 3.10.6)
|_http-title: Gerapy
|_http-cors: GET POST PUT DELETE OPTIONS PATCH
| http-methods: 
|_  Supported Methods: GET OPTIONS
Device type: general purpose|router
Running: Linux 5.X, MikroTik RouterOS 7.X
OS CPE: cpe:/o:linux:linux_kernel:5 cpe:/o:mikrotik:routeros:7 cpe:/o:linux:linux_kernel:5.6.3
OS details: Linux 5.0 - 5.14, MikroTik RouterOS 7.2 - 7.5 (Linux 5.6.3)
TCP/IP fingerprint:
OS:SCAN(V=7.95%E=4%D=8/22%OT=22%CT=1%CU=31999%PV=Y%DS=4%DC=T%G=Y%TM=68A8990
OS:5%P=x86_64-pc-linux-gnu)SEQ(SP=104%GCD=1%ISR=10E%TI=Z%CI=Z%TS=A)OPS(O1=M
OS:578ST11NW7%O2=M578ST11NW7%O3=M578NNT11NW7%O4=M578ST11NW7%O5=M578ST11NW7%
OS:O6=M578ST11)WIN(W1=FE88%W2=FE88%W3=FE88%W4=FE88%W5=FE88%W6=FE88)ECN(R=Y%
OS:DF=Y%T=40%W=FAF0%O=M578NNSNW7%CC=Y%Q=)T1(R=Y%DF=Y%T=40%S=O%A=S+%F=AS%RD=
OS:0%Q=)T2(R=N)T3(R=N)T4(R=Y%DF=Y%T=40%W=0%S=A%A=Z%F=R%O=%RD=0%Q=)T5(R=Y%DF
OS:=Y%T=40%W=0%S=Z%A=S+%F=AR%O=%RD=0%Q=)T6(R=Y%DF=Y%T=40%W=0%S=A%A=Z%F=R%O=
OS:%RD=0%Q=)T7(R=N)U1(R=Y%DF=N%T=40%IPL=164%UN=0%RIPL=G%RID=G%RIPCK=G%RUCK=
OS:G%RUD=G)IE(R=Y%DFI=N%T=40%CD=S)

Uptime guess: 17.137 days (since Tue Aug  5 06:03:26 2025)
Network Distance: 4 hops
TCP Sequence Prediction: Difficulty=260 (Good luck!)
IP ID Sequence Generation: All zeros
Service Info: OS: Linux; CPE: cpe:/o:linux:linux_kernel

TRACEROUTE (using port 554/tcp)
HOP RTT       ADDRESS
1   104.50 ms 192.168.45.1
2   103.58 ms 192.168.45.254
3   103.62 ms 192.168.251.1
4   101.41 ms 192.168.159.24

```

# Phase 2: Service Enumeration Priority

Based on discovered services, follow this priority order:
- [x] [[Archive/OFFSEC - Proving Grounds Writeups/Linux/Levram/Service Enumeration/22 SSH|22 SSH]]
- [x] [[Archive/OFFSEC - Proving Grounds Writeups/Linux/Levram/Service Enumeration/8000 HTTP|8000 HTTP]]

