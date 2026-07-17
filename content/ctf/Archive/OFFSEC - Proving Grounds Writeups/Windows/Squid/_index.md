---
date: 2025-08-24
title: Squid
---

Difficulty: Easy

# Squid Notes & Methodology

## Start Here: [[Archive/OFFSEC - Proving Grounds Writeups/Windows/Squid/Service Discovery|Service Discovery]]

_This includes my mistakes, reasoning, and rabbit holes -- it's not the most direct way to solve the box!_

# Findings

## Vulnerabilities and Suggested Remediation

- The open Squid http proxy allows anyone to enumerate the internal WAMP dashboard running on port 8080 internally, exposing critical server details and administrative capabilities
  - Implement Squid proxy access controls or firewall rules to prevent the proxy from exposing sensitive endpoints
- phpmyadmin uses default credentials which can easily be guessed to gain administrative access
  - Change credentials to use a strong password
- WAMP stack runs as NT Authority/System rather than a dedicated service account, meaning compromise of the web application leads to direct compromise of the entire system
  - Run web services with a dedicated service account

## Flags

```
C:\local.txt: 325ada73456c3a84178762552f5d6acb
C:\Users\Administrator\Desktop\proof.txt: 1831c3d66ff2db78c816574a09c6e26f
```

# OSCP Note Template and Runbooks

[This](https://github.com/CameronCandau/OSCP-Methodology) is my checklist of commands and methodologies to use while taking the OSCP. Feel free to use, adapt for your own use, or open a PR with suggestions!

- Clone [the template](https://github.com/CameronCandau/OSCP-Methodology) and copy/rename for each machine
- Start with 'Service Discovery' and move between the other pages as applicable
