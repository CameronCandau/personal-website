---
tags:
  - Windows
---
Difficulty: Easy
# Environment Setup
`export IP=192.168.124.65`

# Service Enumeration
`nmap -T4 -F $IP`

```
PORT    STATE SERVICE
21/tcp  open  ftp
80/tcp  open  http
135/tcp open  msrpc
139/tcp open  netbios-ssn
445/tcp open  microsoft-d
```

```
PORT      STATE SERVICE       VERSION
21/tcp    open  ftp           Microsoft ftpd
| ftp-anon: Anonymous FTP login allowed (FTP code 230)
| 04-29-20  10:31PM       <DIR>          ImapRetrieval
| 06-26-25  06:05PM       <DIR>          Logs
| 04-29-20  10:31PM       <DIR>          PopRetrieval
|_04-29-20  10:32PM       <DIR>          Spool
| ftp-syst:
|_  SYST: Windows_NT
80/tcp    open  http          Microsoft IIS httpd 10.0
|_http-server-header: Microsoft-IIS/10.0
| http-methods:
|_  Potentially risky methods: TRACE
|_http-title: IIS Windows
135/tcp   open  msrpc         Microsoft Windows RPC
139/tcp   open  netbios-ssn   Microsoft Windows netbios-ssn
445/tcp   open  microsoft-ds?
5040/tcp  open  unknown
9998/tcp  open  http          Microsoft HTTPAPI httpd 2.0 (SSDP/UPnP)
| http-title: Site doesn't have a title (text/html; charset=utf-8).
|_Requested resource was /interface/root
| uptime-agent-info: HTTP/1.1 400 Bad Request\x0D
| Content-Type: text/html; charset=us-ascii\x0D
| Server: Microsoft-HTTPAPI/2.0\x0D
| Date: Fri, 27 Jun 2025 01:20:21 GMT\x0D
| Connection: close\x0D
| Content-Length: 326\x0D
| \x0D
| <!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN""http://www.w3.org/TR/html4/strict.dtd">\x0D
| <HTML><HEAD><TITLE>Bad Request</TITLE>\x0D
| <META HTTP-EQUIV="Content-Type" Content="text/html; charset=us-ascii"></HEAD>\x0D
| <BODY><h2>Bad Request - Invalid Verb</h2>\x0D
| <hr><p>HTTP Error 400. The request verb is invalid.</p>\x0D
|_</BODY></HTML>\x0D
|_http-server-header: Microsoft-IIS/10.0
17001/tcp open  remoting      MS .NET Remoting services
49664/tcp open  msrpc         Microsoft Windows RPC
49665/tcp open  msrpc         Microsoft Windows RPC
49666/tcp open  msrpc         Microsoft Windows RPC
49667/tcp open  msrpc         Microsoft Windows RPC
49668/tcp open  msrpc         Microsoft Windows RPC
49669/tcp open  msrpc         Microsoft Windows RPC
Service Info: OS: Windows; CPE: cpe:/o:microsoft:windows

Host script results:
| smb2-time:
|   date: 2025-06-27T01:20:16
|_  start_date: N/A
| smb2-security-mode:
|   3:1:1:
|_    Message signing enabled but not required
```

## Port 21 - FTP
Nmap scan shows anonymous login is allowed for FTP. I'll use this to download all available contents:
`wget -m --no-passive ftp://$IP`

The log files in /Logs confirm there is a user with name "admin".

Otherwise nothing much useful

## Ports 445 - SMB
Nmap scripts didn't find anything.
`nmap --script=smb-enum* -p 139,445 $IP`

## Port 9998 - HTTP
![[Pasted image 20250626183317.png]]

## Initial Access & Flag

Default credentials of admin:admin don't work.

By looking in the page's source, we can see that the server is running build 6919. 

Using ExploitDB I found 2019-7214 and an RCE exploit: https://www.exploit-db.com/exploits/49216

I modified the variables at the start of this script to suit our environment (HOST, LHOST), started a listener on the specified LPORT (`nc -lnvp 4444`) and ran the script to receive a connection as nt authority\system.

I found proof.txt at C:\Users\Administrator\Desktop\proof.txt.

![[Pasted image 20250626185145.png]]
