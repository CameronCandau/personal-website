---
date: 2025-08-19
title: Hub
---
Difficulty: Easy
# Hub Notes & Methodology
## Start Here: [[Archive/OFFSEC - Proving Grounds Writeups/Linux/Hub/Service Discovery|Service Discovery]]
*This includes my mistakes, reasoning, and rabbit holes -- it's not the most direct way to solve the box!*

# Findings

## Vulnerabilities and Suggested Remediation
- The FuguHub instance was not initialized with an admin user, allowing anyone to create the admin account.
	- Create the admin user with a strong password.
- The FuguHub instance is vulnerable to CVE-2023-24078, allowing for remote code execution. Because the service is running as root, this allows direct code execution as root.
	- Update FuguHub to a non-vulnerable version.

## Flags
```
/root/proof.txt: bf19205b33d1545178aaca10ca29b879
```

# OSCP Note Template and Runbooks
[This](https://github.com/CameronCandau/OSCP-Methodology) is my checklist of commands and methodologies to use while taking the OSCP. Feel free to use, adapt for your own use, or open a PR with suggestions!

- Clone [the template](https://github.com/CameronCandau/OSCP-Methodology) and copy/rename for each machine
- Start with 'Service Discovery' and move between the other pages as applicable


# Resources Inspiring this Cheatsheet Template
- [Red Team Manual: Services Cheat Sheet](https://docs.google.com/document/d/17W30A0wpB7lVTDb7SCjWs0lb9bMAjVR4B7Dp_c2rU2g/edit?tab=t.0#heading=h.aoia5laf4167)
- [Windows Commands Cheat Sheet](https://docs.google.com/document/d/1CGgADAOZQuMXAyzXVeXRNhQ_PPBYliMXCy-4RNE0UMw/edit?tab=t.0)
- [Linux Commands Cheat Sheet](https://docs.google.com/document/d/1vJxoHrjW607NJDLC1Zln1llrEIqrS6Ea3j9ihJTdblg/edit?tab=t.0#heading=h.daugsj3oqt1)
- [OSCP Secret Sauce - eins.li](https://eins.li/posts/oscp-secret-sauce/) - *UDP scanning, NetExec usage, pspy monitoring*
- [Netexec](https://pentesting.site/cheat-sheets/netexec/)
- [GTFOBins](https://gtfobins.github.io/)
- [PayloadsAllTheThings](https://github.com/swisskyrepo/PayloadsAllTheThings)
- [HackTricks](https://book.hacktricks.xyz/)
