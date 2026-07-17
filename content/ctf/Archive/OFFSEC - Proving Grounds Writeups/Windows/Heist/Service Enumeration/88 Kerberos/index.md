# Kerberoasting
- Are there any service accounts (Accounts that have a ServicePrincipalName)?
(powerview.ps1)
`Get-NetUser -SPN` only returns krbtgt.

# AS-REP Roasting
`Get-ADUser -Filter {DoesNotRequirePreAuth -eq $true} -Property DoesNotRequirePreAuth` -- no output.

# Continue: [[Enox -> svc_apache$]]