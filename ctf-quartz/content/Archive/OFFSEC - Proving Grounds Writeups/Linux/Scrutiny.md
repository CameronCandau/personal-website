---
date: 2025-11-16
---
Difficulty: Intermediate
# Service Discovery

## Open Ports & Priority
TCP Ports:
- [x] 80
- [ ] 25
- [ ] 22

# Service Enumeration
## 80
Server: nginx/1.18.0, Ubuntu

![[Pasted image 20251116151136.png]]

Expanding the top right menu button shows a Login button, which redirects to http://teams.onlyrands.com/. I'll add this to my /etc/hosts and retry.

![[Pasted image 20251116151703.png]]

Googling the software name/version, TeamCity Version 2023.05.4 brought me to a few potential vulnerabilities.

Jetbrains' Privacy and Security center was helpful for locating vulnerabilities and determining the order of releases. https://www.jetbrains.com/privacy-security/issues-fixed/?product=TeamCity&version=2023.11.4

CVE-2023-42793 was patched by this version. https://blog.jetbrains.com/teamcity/2023/09/cve-2023-42793-vulnerability-post-mortem/

CVE-2024-27198 was later patched in 2023.11.4 which was released after 2023.05.4, so this instance may be vulnerable. I'll try a POC from exploit-db: https://www.exploit-db.com/exploits/52411

![[Pasted image 20251116152957.png]]

That was rather straightforward... did it actually work?
Yes, we're in!
![[Pasted image 20251116153049.png]]

Administration > Backup allows us to create and download a zip backup of server config data... database_dump/users contains TeamCity user bcrypt hashes but nothing immediately useful, from what I can tell.

Looking through the projects though, I'm able to view the git history for each freelancer. Marco committed and later removed a private key, id_rsa.

![[Pasted image 20251116161911.png]]

I'll download it, use ssh2john to check for a password, then crack it with john.

![[Pasted image 20251116165643.png]]

Now we have ssh access as marcot!

![[Pasted image 20251116165907.png]]

...I have mail?... that's a new message to me.
Looking into this message a bit, I came to /var/mail, which contains a file for marcot.

In this plaintext file, I find the password for Matthew, IdealismEngineAshen476.
![[Pasted image 20251116180614.png]]


# Privilege Escalation
`sudo -l` requires marcot's password, and cheer works here as well, but we marcot can't run anything with sudo.

I'll switch matthewa with `su mattthewa`, as the email from him was a strong hint to check his environment.

`ls -al /home/freelancers/matthewa` shows an unusual file named .~

It contains Dach's password, RefriedScabbedWasting502. 
![[Pasted image 20251116182753.png]]

/var/mail/matthewa contains some messages between matthewa and Dach, showing that Dach's username is briand@onlyrands.com

I'll switch to briand and restart enumeration once again.

briand can run:
`(root) NOPASSWD: /usr/bin/systemctl status teamcity-server.service`

GTFOBins shows that because many of systemctl's functionalities allow us to open the system's pager, usually `less`, we can then use `!/bin/bash` to open a shell as root.
https://gtfobins.github.io/gtfobins/systemctl/#sudo

# Proof Screenshots (local.txt / proof.txt)
`type` or `cat` flag and [include IP address in screenshot](https://help.offsec.com/hc/en-us/articles/360040165632-OSCP-Exam-Guide#screenshot-requirements)

/root/proof.txt
26cdf3004772e60050a2253ec1f21f8a

![[Pasted image 20251116183148.png]]
