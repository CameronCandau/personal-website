---
tags:
  - Forensics
  - Wireshark
---
![[Pasted image 20250614132557.png]]

1. Opened the provided `.pcap` file in Wireshark.
2. Went to `File > Export Objects > HTTP` and selected **Save All** to extract HTTP-transferred files.
3. Found a file named `login` among the exported objects. It contained the following text, giving us the password which the user entered. 

```
username=ironpotatoadmin&password=C1%7Bmaybe_TLS_would_be_nice%7D
```
We can URL decode it to get the flag:
`C1{maybe_TLS_would_be_nice}`