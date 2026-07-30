---
title: What is Windows.old?
date: 2026-07-30
---
C:\Windows.old is a backup of system data created when upgrading Windows... which may contains registry hives and could help with local privilege escalation (SAM and SYSTEM -> SecretsDump). 

www.neowin.net/guides/guide-what-is-the-windowsold-folder-and-can-i-delete-it/

The lesson is that **one should always check `Get-ChildItem C:\ -Force` when credential harvesting for privilege escalation.**

I haven't seen many PE methodology guides or checklists account for this. It's not even mentioned anywhere in the 1024 page-long PEN-200 course PDF.

https://steflan-security.com/windows-privilege-escalation-credential-harvesting/ covers Windows.old and has a good list of other paths and commands for credential harvesting. I will be borrowing some to add to my own runbook.

[This article](https://www.kaspersky.com/blog/windows-downgrade-downdate-protection/52005/) also led me to discover [CVE-2024-38202](https://msrc.microsoft.com/update-guide/en-US/advisory/CVE-2024-38202), which would allow an attacker to replace Windows.old to create a vulnerable system backup. This could result in disabling VBS, for instance (beyond the scope of OSCP -- just an interesting fact).