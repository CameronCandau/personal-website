# DNS Reverse Lookup

Timed out.

We know FQDN is  ResourceDC.resourced.local from [[Archive/OFFSEC - Proving Grounds Writeups/Windows/Resourced/Service Discovery|Service Discovery]] nmap script for enumerating RDP.

# Asynchronous Full Transfer (Zone Transfer)

```
dig @ResourceDC.resourced.local -t AXFR ResourceDC.resourced.local
```

Failed. Nothing much here, so we'll move on.

# Continue: [[Archive/OFFSEC - Proving Grounds Writeups/Windows/Resourced/Service Enumeration/389,636 LDAP(S)|389,636 LDAP(S)]]