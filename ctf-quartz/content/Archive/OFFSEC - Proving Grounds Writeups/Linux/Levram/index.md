---
title: Levram
---
Difficulty: Easy
# Levram Notes & Methodology
## Start Here: [[Archive/OFFSEC - Proving Grounds Writeups/Linux/Levram/Service Discovery|Service Discovery]]

*This includes my mistakes, reasoning, and rabbit holes -- it's not the most direct way to solve the box!*

# Findings
## Vulnerabilities and Remediation
- Web service admin panels (for both Django and Gerapy) use default credentials admin:admin
	- Change credentials from default
- Python3.10 has capabilities set, allowing a user to elevate their privileges to root
	- Use more granular permissions and capabilities

## Flags
```
/home/app/local.txt: c8041b9100165c635168244c8e290463
/root/proof.txt: 664c1ceb0e7d3422c8917d50beb86c86
```

# OSCP Note Template and Runbooks
[This](https://github.com/CameronCandau/OSCP-Methodology) is my checklist of commands and methodologies to use while taking the OSCP. Feel free to use, adapt for your own use, or open a PR with suggestions!

- Clone [the template](https://github.com/CameronCandau/OSCP-Methodology) and copy/rename for each machine
- Start with 'Service Discovery' and move between the other pages as applicable
