# Anonymous Login

```
ftp $IP -a
```

Confirmed!

![[Pasted image 20250828072213.png]]

# Recursively Download Files
```
wget -r ftp://192.168.144.127/
```

This seems to be a ruby application. I'm not sure where or if it's being served yet. I want to see if we can upload. If we can, and if this is actually being served, we would likely be able to execute arbitrary ruby code to establish a shell on the server.

I'll continue enumerating services to find whether this is being served and could potentially lead to RCE by uploading and executing a malicious ruby file.

# Continue: [[45332 HTTP]]

