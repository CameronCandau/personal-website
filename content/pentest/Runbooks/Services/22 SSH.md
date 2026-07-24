## Enumerate SSH with nmap
```bash
nmap --script=ssh2-enum-algos,ssh-hostkey,ssh-auth-methods -p 22 $IP
```

## Audit SSH with ssh-audit
```bash
ssh-audit $IP -p 22
```

## Convert SSH key for John
```bash
ssh2john id_rsa > id_rsa.hash
```

## Test username behavior
```bash
ssh -o PreferredAuthentications=none username@$IP
```

## Pivoting
```text
Use [[Tunneling]].
```
