---
title: Codo
---
Difficulty: Easy
# Codo Notes & Methodology
## Start Here: [[Archive/OFFSEC - Proving Grounds Writeups/Linux/Codo/Service Discovery|Service Discovery]]

*This includes my mistakes, reasoning, and rabbit holes -- it's not the most direct way to solve the box!*

# Findings
## Vulnerabilities and Suggested Remediation

- Codoforum uses weak, default credentials (admin:admin)
	- Change credentials to be strong and non-default
- Codoforum version is vulnerable to RCE by CVE-2022-31854
	- Update Codoforum version
- Root password is weak and exposed in the application's config.php
	- The root password should be unique and complex

## Credentials

```
admin:admin (http://$IP/admin default credentials)
root:FatPanda123 (discovered in /var/www/html/sites/default/config.php)
```

## Flags
```
/root/proof.txt: a90f47b544fbb19e56ca100dd358be
```

# OSCP Note Template and Runbooks
[This](https://github.com/CameronCandau/OSCP-Methodology) is my checklist of commands and methodologies to use while taking the OSCP. Feel free to use, adapt for your own use, or open a PR with suggestions!

- Clone [the template](https://github.com/CameronCandau/OSCP-Methodology) and copy/rename for each machine
- Start with 'Service Discovery' and move between the other pages as applicable

