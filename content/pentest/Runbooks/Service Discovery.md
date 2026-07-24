# Initial Service Discovery

## Create a working directory for one target
```bash
mkdir -p $IP/{nmap,web,exploit,loot}
cd $IP
```

## Run AutoRecon
```bash
autorecon $IP --only-scans-dir
```

## Run a fast TCP sweep
```bash
nmap --min-rate 4500 --max-rtt-timeout 1500ms -p- -Pn $IP -oG nmap/all_tcp.gnmap
```

## Extract open TCP ports
```bash
TCP_PORTS=$(grep -oP '\d+/open' nmap/all_tcp.gnmap | cut -d/ -f1 | paste -sd, -)
echo "$TCP_PORTS"
```

## Run service detection on open TCP ports
```bash
nmap -sC -sV -T4 -Pn -p "$TCP_PORTS" $IP -oA nmap/full_tcp
```

## Scan top 100 UDP ports
```bash
nmap -sU --top-ports 100 -T4 -Pn $IP -oA nmap/top_udp
```

## What to open next
```text
HTTP/HTTPS -> [[80, 443 HTTP]]
SMB -> [[139,445 SMB]]
FTP -> [[20,21 FTP]]
SSH -> [[22 SSH]]
DNS -> [[53 DNS]]
Kerberos -> [[88 Kerberos]]
LDAP -> [[389,636 LDAP(S)]]
MSRPC -> [[135 WMI,MSRPC]]
WinRM -> [[5985, 5986 WinRM]]
MSSQL -> [[1433 MSSQL]]
MySQL -> [[3306 MySQL]]
RDP -> [[3389 RDP]]
SMTP -> [[25,587 SMTP]]
SNMP -> [[161 SNMP]]
NFS -> [[2049 NFS]]
```
