---
title: Resourced
---
Difficulty: Intermediate
# Notes & Methodology
## Start Here: [[Archive/OFFSEC - Proving Grounds Writeups/Windows/Resourced/Service Discovery|Service Discovery]]
*This includes my mistakes, reasoning, and rabbit holes -- it's not the most direct way to solve the box!*

# Findings
*Summary of important findings.*
## Domain/Host Name
Add to /etc/hosts

```
ResourceDC.resourced.local 
```

## Summary
We gained an initial foothold by enumerating [[135 MSRPC]] as an anonymous user, which exposed V.Ventz’s plaintext Active Directory password stored in their Description field. From a security perspective, the Description field in LDAP is effectively public to anyone with read access via LDAP or MSRPC; ideally it should never contain passwords, even temporarily.

After testing V.Ventz’s password, we used their account to enumerate [[139,445 SMB|SMB]] on the target. As a null user, we previously had no access. We discovered and were able to read a share named `Password Audit` containing a copy of the domain's `ntds.dit` file as well as the `SYSTEM` and `SECURITY` registry hives. From these files, we extracted NTLM hashes for all domain users. 

Using Pass-the-Hash, we authenticated to multiple services and successfully gained remote access as L.Livingstone via WinRM. 

During [[Enumeration]] with SharpHound/BloodHound, we discovered that L.Livingstone had `GenericAll` permissions on the target computer, giving us full control. We then executed a Resource-Based Constrained Delegation (RBCD) attack: we created a new computer account with a chosen password, delegated control over the domain controller, requested the Administrator account’s service ticket, and authenticated via Pass-the-Ticket (PTT), ultimately achieving `NT AUTHORITY\SYSTEM` on the domain controller.

## Vulnerabilities
- Credentials stored insecurely in user V.Ventz’s Description field: [[135 MSRPC]]
- Insecure storage of `ntds.dit` and `SYSTEM`/`SECURITY` registry hives
- Excessive permissions granted to unprivileged account L.Livingstone

## Hashes

```
L.Livingstone:19a3a7550ce8c505c2d46b5e39d6f808
```

## Credentials

```
v.ventz:HotelCalifornia194!
```


## Flags
(Use https://github.com/vivami/SauronEye)
```
C:\Users\L.Livingstone\Desktop\local.txt: 3ce0746e76df5672b9a4b82caaa91033
C:\Users\Administrator\Desktop\proof.txt: 1c92f9215ce680355348bcae79600182
```

# OSCP Note Template and Runbooks
[This](https://github.com/CameronCandau/OSCP-Methodology) is my checklist of commands and methodologies to use while taking the OSCP. Feel free to use, adapt for your own use, or open a PR with suggestions!

- Clone [the template](https://github.com/CameronCandau/OSCP-Methodology) and copy/rename for each machine
- Start with 'Service Discovery' and move between the other pages as applicable