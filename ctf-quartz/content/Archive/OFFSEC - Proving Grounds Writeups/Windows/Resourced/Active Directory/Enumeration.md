---
title: Active Directory Enumeration
---
# Sharphound -> Ingest into Bloodhound
`sudo apt-get install sharphound`
*Copy to target and execute to get zip file*
Set up bloodhound instance on attacking machine:
- https://www.ired.team/offensive-security-experiments/active-directory-kerberos-abuse/abusing-active-directory-with-bloodhound-on-kali-linux

Mark L.Livingstone as owned and starting node, Domain Admins as ending node
![[Pasted image 20250812193403.png]]

![[Pasted image 20250812194612.png]]

We have GenericAll on this computer, which is also the domain controller. Reading Bloodhound's guidance, I learned that this means we essentially have full control over it.

