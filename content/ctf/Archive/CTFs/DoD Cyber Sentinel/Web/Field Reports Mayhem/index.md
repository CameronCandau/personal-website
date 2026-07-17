---
tags:
  - Web/IDOR
---
![[Pasted image 20250614080319.png]]

After logging in with the provided credentials, I checked each page's text and HTML source (CTRL+U) for comments that might contain the hardcoded flag, but no luck.

![[Pasted image 20250614080726.png]]

![[Pasted image 20250614081618.png]]

![[Pasted image 20250614081655.png]]


I noticed that there's a URL parameter "id" which specifies the current user. Taking a guess based off of the prompt mentioning "leet", I tried changing this value to 1337 and was able to access that agent's reports. This constitutes an IDOR vulnerability. 

I found the flag in report GH56IJ.

![[Pasted image 20250614081414.png]]