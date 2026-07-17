![[Pasted image 20250321230137.png]]

Though I'm familiar with .kbdx as KeePass database files, I'll start by viewing file info and metadata:
![[Pasted image 20250321230536.png]]

We'll likely be able to use KeePass2John to be able to convert the KeePass hash into a format that can be easily used by password cracking tools like John The Ripper.
![[Pasted image 20250321231643.png]]

Surely enough, we get a successful result pretty quickly using Rockyou as our wordlist.
![[Pasted image 20250321231859.png]]

Next I'll just download KeePassXC and use the discovered password "goblue1" to open the vault and manually look through the contents for our flag.
![[Pasted image 20250321232159.png]]
![[Pasted image 20250321232257.png]]