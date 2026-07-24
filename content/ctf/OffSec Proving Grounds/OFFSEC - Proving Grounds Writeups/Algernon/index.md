# System Information
OS: Windows

Architecture: x64

---
# Service Discovery

`scan --autorecon`

## Open Ports & Priority

### 21/tcp FTP

Sever: Microsoft ftpd

Able to access as anonymous:anonymous.

`ftp anonymous@$IP`

Download all contents recursively:
 
 `wget -r ftp://anonymous:anonymous@$IP/`

Logs/ exposes some info:
- xmpp installed
- Webmail user `admin` exists

### 80/tcp HTTP

Server: IIS/10.0

Default IIS Installation. No interesting Feroxbuster files/dirs.

### 9998/tcp HTTP

Server: IIS/10.0

![[Pasted image 20260721215843.png]]

Interesting, non-default content. This might be the XMPP site we saw referenced in logs from FTP earlier.

![[Pasted image 20260721220046.png]]

SmarterMail

Version seems to be in HTML response? 

var stProductVersion = "100.0.6919";
var stProductBuild = "6919 (Dec 11, 2018)";

![[Pasted image 20260721220224.png]]

Google `StarterMail CVE`, find 9.8 for auth bypass in password reset API, builds prior to 9511. The build seems to be 6919, so this may be vulnerable.

Find POC: https://github.com/MaxMnMl/smartermail-CVE-2026-23760-poc

No luck:

![[Pasted image 20260721221254.png]]

Find an older exploit closer to this build, for CVE 2019-7214 : https://www.exploit-db.com/exploits/49216

Download, update HOST, LHOST, LPORT variables at the top. 

Start reverse shell handler:

`penelope -p 80 -O`

Run exploit, receive connection on shell as nt authority/system:

`python3 49216.py`

![[Pasted image 20260721222127.png]]

# Proof Screenshots (local.txt / proof.txt)
`type` or `cat` flag and [include IP address in screenshot](https://help.offsec.com/hc/en-us/articles/360040165632-OSCP-Exam-Guide#screenshot-requirements)

![[Pasted image 20260721222402.png]]