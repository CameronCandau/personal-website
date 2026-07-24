# WMI / MSRPC Enumeration (135)

## Run nmap RPC scripts
```bash
nmap -p 135 --script=msrpc-enum,rpc-grind $IP
```

## Enumerate RPC endpoints
```bash
rpcinfo -p $IP
impacket-rpcmap $IP
```

## Connect with rpcclient anonymously
```bash
rpcclient -U "" -N $IP
```

## Enumerate users and groups with rpcclient
```bash
rpcclient -U "" -N $IP -c enumdomusers
rpcclient -U "" -N $IP -c enumdomgroups
rpcclient -U "" -N $IP -c querydominfo
rpcclient -U "" -N $IP -c netshareenum
```

## RID brute with NetExec
```bash
netexec smb $IP -u guest -p '' --rid-brute
```

## Enumerate with lookupsid
```bash
impacket-lookupsid guest@$IP
```

## Query WMI with credentials
```bash
impacket-wmiquery domain.local/username:password@$IP "SELECT * FROM Win32_Service"
impacket-wmiquery domain.local/username:password@$IP "SELECT * FROM Win32_Process"
```

## Execute with WMI or DCOM
```bash
impacket-wmiexec domain.local/username:password@$IP
impacket-dcomexec domain.local/username:password@$IP
```

## Query registry remotely
```bash
impacket-reg domain.local/username:password@$IP query -keyName HKLM\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Run
```
