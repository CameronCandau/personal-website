# Host information

```
Operating System: Ubuntu 4ubuntu0.5
```

# Environment Variables / Setup

```
export IP=192.168.109.10
mkdir nmap && cd nmap
```

# Scans

## AutoRecon
https://github.com/Tib3rius/AutoRecon
Results filled on respective pages within Service Enumeration.
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
PORT     STATE SERVICE VERSION
22/tcp   open  ssh     OpenSSH 8.2p1 Ubuntu 4ubuntu0.5 (Ubuntu Linux; protocol 2.0)
| ssh-hostkey:
|   3072 98:4e:5d:e1:e6:97:29:6f:d9:e0:d4:82:a8:f6:4f:3f (RSA)
|   256 57:23:57:1f:fd:77:06:be:25:66:61:14:6d:ae:5e:98 (ECDSA)
|_  256 c7:9b:aa:d5:a6:33:35:91:34:1e:ef:cf:61:a8:30:1c (ED25519)
80/tcp   open  http    Apache httpd 2.4.41 ((Ubuntu))
|_http-server-header: Apache/2.4.41 (Ubuntu)
|_http-title: blaze
9090/tcp open  http    Cockpit web service 198 - 220
|_http-title: Did not follow redirect to https://192.168.109.10:9090/
Service Info: OS: Linux; CPE: cpe:/o:linux:linux_kernel
```

### UDP Scan

```
nmap -sU --top-ports 100 -T4 -Pn $IP -oA top_udp
```

```
PORT      STATE         SERVICE
162/udp   open|filtered snmptrap
445/udp   open|filtered microsoft-ds
5060/udp  open|filtered sip
10000/udp open|filtered ndmp
```