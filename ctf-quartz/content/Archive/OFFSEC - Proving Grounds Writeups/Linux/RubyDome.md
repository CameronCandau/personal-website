---
date: 2025-11-16
---
Difficulty: Easy
# Service Discovery

## Open Ports & Priority
TCP Ports:
- [x] 3000
- [ ] 22

# Service Enumeration
## 3000
HTTP
Server: WEBrick/1.7.0 (Ruby/3.0.2/2021-07-07)

Searching for the server version online, I found CVE-2011-3187, https://www.exploit-db.com/exploits/35352
However with a closer look into it, it doesn't seem applicable to our case; the effects are mostly client-side attacks and only affects requests sent from clients on the same subnet as the server. The base CVSS is only a 4.3 as well.

![[Pasted image 20251116191348.png]]

I copy/pasted this title into google and found an exploit for pdfkit: https://github.com/UNICORDev/exploit-CVE-2022-25765

I'll take a closer look at the application and keep this in mind.

I tried guessing a local resource to submit -- maybe this is an opportunity for SSRF by tricking the server into converting internal webpages to PDFs?
http://localhost/index.html

![[Pasted image 20251116192133.png]]

That request seemed to fail, and in a very revealing manner. Now we *know* the server is running PDFKit for its conversions, though we don't have a version confirmed.

Still, it seems worth a try at this point. I'll use the exploit's -s option to generate a reverse shell payload.
![[Pasted image 20251116193039.png]]

The app has frontend validation preventing me from submitting this. Can we bypass the frontend validation? Maybe it will be accepted by the backend blidly.
![[Pasted image 20251116193126.png]]

I'll use Burp Suite's proxy to replay the request I sent earlier which passed the frontend validation, and just change the "url" parameter to the URL-encoding of this new payload.
![[Pasted image 20251116193330.png]]

The response shows a code 500, but I caught a shell on my listener!
![[Pasted image 20251116193401.png]]
# Privilege Escalation
We gain access as andrew, who we can immediately see is a member of the sudo group.

`sudo -l` shows:
`(ALL) NOPASSWD: /usr/bin/ruby /home/andrew/app/app.rb`

This is an easy win. I'll make a copy of the app as a backup, replace the original app.rb with a shell, and run it with sudo:
![[Pasted image 20251116194416.png]]

app.rb (found on GTFOBins: https://gtfobins.github.io/gtfobins/ruby/#shell)
```
exec '/bin/bash'
```

# Proof Screenshots (local.txt / proof.txt)
`type` or `cat` flag and [include IP address in screenshot](https://help.offsec.com/hc/en-us/articles/360040165632-OSCP-Exam-Guide#screenshot-requirements)

/root/proof.txt
e0d2f2eea22ad1f6b3b61a16903258a1

/home/andrew/local.txt
bbf435f0d3e94fad36740ab9925b677a

![[Pasted image 20251116194845.png]]