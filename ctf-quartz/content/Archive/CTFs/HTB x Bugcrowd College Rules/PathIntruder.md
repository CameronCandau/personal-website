>Navigate through restricted areas by cleverly circumventing defenses. Can you find the path less traveled and expose the system's secrets? Note: Read /etc/passwd to get the flag

In the top right corner of the application we have some language settings for English and Japanese. Clicking on either of these options loads their respective PHP page. 

![[Pasted image 20250327065317.png]]

Being able to directly manipulate which file is being loaded from the backed system indicates a potential local file inclusion (LFI) vulnerability, which we may be able to leverage to disclose information about the app or server.

I'm assuming this is a Linux host as we know the challenge is running in a Docker container, but for the sake of being thorough before attempting directory traversal, I'll try to detect the OS version using nmap:
`nmap 83.136.251.19 -p 32689 -O`

```
PORT      STATE SERVICE
32689/tcp open  unknown
Warning: OSScan results may be unreliable because we could not find at least 1 open and 1 closed port
Aggressive OS guesses: Linux 3.2 - 4.14 (93%), Linux 4.15 - 5.19 (93%), Linux 2.6.32 - 3.10 (92%), Linux 2.6.32 - 3.13 (91%), Linux 5.0 - 5.14 (91%), Linux 4.15 (90%), MikroTik RouterOS 7.2 - 7.5 (Linux 5.6.3) (90%), Ubiquiti AirMax NanoStation WAP (Linux 2.6.32) (90%), Linux 3.10 - 4.11 (89%), Linux 3.4 - 3.10 (89%)
No exact OS matches for host (test conditions non-ideal).
Network Distance: 14 hops
```

Knowing the host is running Linux we can try to include `/etc/passwd` with directory traversal. We're met with the following message, informing us that the application is using some sanitization in attempt to stop attacks like this.
![[Pasted image 20250327070808.png]]

However, we see that this can easily be bypassed as the filtering only makes one pass over our input and isn't recursive -- we can structure the URL such that even after `../` is removed from the string, another `../` remains.

In the case of `?lang=....//etc/passwd`, we can presume the application will remove the highlighted substring ../:
?lang=..==../==/etc/passwd
which will leave us with:
?lang=../etc/passwd

![[Pasted image 20250327071406.png]]

Our assumption is correct, as we see the application is telling us the path it's looking for.
Using this, we'll continue traversing until we reach the root and find the `/etc/passwd` file, which happens to be at the next level up.

![[Pasted image 20250327071610.png]]