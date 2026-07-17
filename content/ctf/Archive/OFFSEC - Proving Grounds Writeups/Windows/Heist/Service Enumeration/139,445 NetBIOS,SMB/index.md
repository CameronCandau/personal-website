# With Null Credentials

## nmap 

```
nmap --script=smb-enum* -p 139,445 DC01.heist.offsec
```

```
PORT    STATE SERVICE
139/tcp open  netbios-ssn
|_smb-enum-services: ERROR: Script execution failed (use -d to debug)
445/tcp open  microsoft-ds
|_smb-enum-services: ERROR: Script execution failed (use -d to debug)
```

## netexec 

Enumerate host
```
netexec smb DC01.heist.offsec
```

```
SMB         192.168.247.165 445    DC01             [*] Windows 10 / Server 2019 Build 17763 x64 (name:DC01) (domain:heist.offsec) (signing:True) (SMBv1:False)
```

No anonymous access but this gives more specific info on the OS version. Added to [[Archive/OFFSEC - Proving Grounds Writeups/Windows/Heist/Findings|Findings]].

## enum4linux-ng 

```
enum4linux-ng -A $IP
```

```
...
[!] Aborting remainder of tests since sessions failed, rerun with valid credentials
```

# Continue: [[8080 HTTP(S)]]

---

# With enox:california

## netexec 

Enumerate host
```
netexec smb DC01.heist.offsec
```

```
SMB         192.168.109.165 445    DC01             [*] Windows 10 / Server 2019 Build 17763 x64 (name:DC01) (domain:heist.offsec) (signing:True) (SMBv1:False)
SMB         192.168.109.165 445    DC01             [+] heist.offsec\enox:california
```

This confirms our credentials are valid. Can we list shares?

`smbclient -U enox --password 'california' -L '\\192.168.159.165'`

```
Sharename       Type      Comment
---------       ----      -------
ADMIN$          Disk      Remote Admin
C$              Disk      Default share
IPC$            IPC       Remote IPC
NETLOGON        Disk      Logon server share
SYSVOL          Disk      Logon server share
```

SYSVOL seems like it could be promising. I'll download it for offline searching:

```
smbclient -U enox --password 'california' '\\192.168.159.165\SYSVOL' -c "prompt OFF; recurse ON;mget *"
```

`tree .`

```
.
├── DfsrPrivate
├── Policies
│   ├── {31B2F340-016D-11D2-945F-00C04FB984F9}
│   │   ├── GPT.INI
│   │   ├── MACHINE
│   │   │   ├── Microsoft
│   │   │   │   └── Windows NT
│   │   │   │       └── SecEdit
│   │   │   │           └── GptTmpl.inf
│   │   │   └── Registry.pol
│   │   └── USER
│   └── {6AC1786C-016F-11D2-945F-00C04fB984F9}
│       ├── GPT.INI
│       ├── MACHINE
│       │   └── Microsoft
│       │       └── Windows NT
│       │           └── SecEdit
│       │               └── GptTmpl.inf
│       └── USER
└── scripts
```

The GptTmpl.inf files are interesting and reveal some information about the domain's group policies, including password policy, but none of it directly contributes to us gaining more privileged access.

# Continue: [[5985, 47001 WinRM#With enox california credentials]]


# References
- https://0xdf.gitlab.io/cheatsheets/smb-enum