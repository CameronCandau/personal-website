**HyperText Transport Protocol**

# Manual Enumeration/Exploitation

This is an instance of BarracudaDrive server. When visiting the page, it prompts to set the administrator account credentials.

![[Pasted image 20250828070712.png]]

I'll set admin:Password123.

The About page '/rtl/about.lsp' shows that this instance is running version 6.5.

![[Pasted image 20250828071105.png]]

Searching exploitdb, I found a privilege escalation method for 6.5 which I'll keep in mind for later: 
https://www.exploit-db.com/exploits/48789
https://github.com/boku7/BarracudaDrivev6.5-LocalPrivEsc

The fileserver looks familiar and reminds me of the [[Archive/OFFSEC - Proving Grounds Writeups/Linux/Hub/index|Hub]] machine where we were able to gain RCE through upload capabilities.

It turns out the fileserver gives us read/write access to the entire C drive, allowing us to directly read the local.txt and proof.txt flags... this is a massive misconfiguration.

http://medjed:8000/fs/C/Users/Jerren/Desktop/local.txt

![[Pasted image 20250828080436.png]]

C:\Users\Jerren\Desktop\local.txt: 79006f3c0484d4c1ff76c2670b81090e

http://medjed:8000/fs/C/Users/Administrator/Desktop/proof.txt

![[Pasted image 20250828080521.png]]

C:\Users\Administrator\Desktop\proof.txt: 5b49119e3ab854b8275211e9d7384edc

