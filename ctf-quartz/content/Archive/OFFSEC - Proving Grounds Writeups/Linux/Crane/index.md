---
title: Crane
---

Difficulty: Intermediate

# Notes & Methodology

**Start Here**: [[Archive/OFFSEC - Proving Grounds Writeups/Linux/Crane/Service Discovery|Service Discovery]]
_This includes my mistakes, reasoning, and rabbit holes -- it's not the most direct way to solve the box!_

# Summary of Findings

## Vulnerabilities and Suggested Remediation

- SuiteCRM uses simple, easy-to-guess credentials (admin:admin)
  - Set a strong password for the admin user
- SuiteCRM version 7.12.3 is vulnerable to CVE-2022-23940, allowing for authenticated remote code execution.
  - Upgrade to a more recent version, at least 7.15.
- www-data user can run /usr/sbin/service without a password as root, which can be abused to escalate privileges

## Credentials

```
admin:admin (SuiteCRM)
admin: (/ical_server.php)
```

## Flags

```
/var/www/local.txt: f76f9651c1aef18def542f34cb34bf03
/root/proof.txt: 907907e1630d55a774cbe7f9b8dcc38b
```

# OSCP Note Template and Runbooks

[This](https://github.com/CameronCandau/OSCP-Methodology) is my checklist of commands and methodologies to use while taking the OSCP. Feel free to use, adapt for your own use, or open a PR with suggestions!

- Clone [the template](https://github.com/CameronCandau/OSCP-Methodology) and copy/rename for each machine
- Start with 'Service Discovery' and move between the other pages as applicable
