---
date: 2025-08-19
title: Medjed
---
Difficulty: Intermediate
# Medjed Notes & Methodology
**Start Here**: [[Archive/OFFSEC - Proving Grounds Writeups/Windows/Medjed/Service Discovery|Service Discovery]]
*This includes my mistakes, reasoning, and rabbit holes -- it's not the most direct way to solve the box!*

# Summary of Findings
## Domain/Host Name
Add to /etc/hosts

```
192.168.144.127 medjed
```

## Vulnerabilities and Suggested Remediation
- BarracudaDrive file server allows the admin to read and write anywhere under the C drive
	- Reconfigure to only expose necessary locations, rather than the whole drive

## Flags
```
C:\Users\Jerren\Desktop\local.txt: 79006f3c0484d4c1ff76c2670b81090e

C:\Users\Administrator\Desktop\proof.txt: 5b49119e3ab854b8275211e9d7384edc
```

# OSCP Note Template and Runbooks
[This](https://github.com/CameronCandau/OSCP-Methodology) is my checklist of commands and methodologies to use while taking the OSCP. Feel free to use, adapt for your own use, or open a PR with suggestions!

- Clone [the template](https://github.com/CameronCandau/OSCP-Methodology) and copy/rename for each machine
- Start with 'Service Discovery' and move between the other pages as applicable
