---
title: Extplorer
---
Difficulty: Intermediate
# Notes & Methodology
**Start Here**: [[Archive/OFFSEC - Proving Grounds Writeups/Linux/Extplorer/Service Discovery|Service Discovery]]
*This includes my mistakes, reasoning, and rabbit holes -- it's not the most direct way to solve the box!*

# Summary of Findings

## Vulnerabilities and Suggested Remediation
- Extplorer instance on /filemanager uses default credentials (admin:admin)
	- Change credentials to non-default
- Extplorer configuration allows read/write access to the entire webroot
	- Use principle of least privilege to scope access 
- Dora has password reuse between extplorer and the host, allowing www-data to access their password hash
	- Use unique passwords between services
- Dora's membership in the "disk" allows her to read the root filesystem, including /etc/shadow
	- Don't grant membership to disk unless necessary, ideally only for administrative users with strong passwords
- Dora and root use passwords which are weak against dictionary attacks
	- Increase password length or complexity

## Flags
```
/home/dora/local.txt: d7d1198f67e8e44cf0a15bc1ac5f8d39
/root/proof.txt: b1a3481469bfd0eec70d42211273a43d
```


# OSCP Note Template and Runbooks
[This](https://github.com/CameronCandau/OSCP-Methodology) is my checklist of commands and methodologies to use while taking the OSCP. Feel free to use, adapt for your own use, or open a PR with suggestions!

- Clone [the template](https://github.com/CameronCandau/OSCP-Methodology) and copy/rename for each machine
- Start with 'Service Discovery' and move between the other pages as applicable
