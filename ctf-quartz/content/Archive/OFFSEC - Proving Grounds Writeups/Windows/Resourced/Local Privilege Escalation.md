```
net user
ipconfig /all
```

```
systeminfo | findstr /B /C:"OS Name" /C:"OS Version"
```

Access Denied

```
whoami /priv
```

```
Privilege Name                Description                    State
============================= ============================== =======
SeMachineAccountPrivilege     Add workstations to domain     Enabled
SeChangeNotifyPrivilege       Bypass traverse checking       Enabled
SeIncreaseWorkingSetPrivilege Increase a process working set Enabled
```


```
net user
```

```
Administrator            D.Durant                 G.Goldberg
Guest                    J.Johnson                K.Keen
krbtgt                   L.Livingstone            M.Mason
P.Parker                 R.Robinson               S.Swanson
V.Ventz
```

# powerview.ps1
`cp $(locate powerview.ps1) ./scripts`

*From target, as L.Livingstone*
```
upload scripts/powerview.ps1
powershell -qp bypass
. .\powerview.ps1

```

# WinPEAS
`cp $(locate winPEASx64) ./scripts`

*From target, as L.Livingstone*
```
.\winPEASx64.exe | Tee-Object -FilePath ".\output.txt"
```

Nothing notable.
# Continue: [[Enumeration|Enumeration]]
# References
- https://sirensecurity.io/blog/adref-active-directory-reference/
- https://github.com/PowerShellMafia/PowerSploit
- [Conda Windows Methodology Video/Cheatsheet](https://youtu.be/Qfy-traJwIs?si=j-AKW5AbJ7dad8cD)