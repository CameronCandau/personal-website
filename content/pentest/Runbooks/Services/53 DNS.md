## Reverse lookup
```bash
dig -p 53 -x $IP @$IP
```

## Attempt zone transfer
```bash
dig @$IP -t AXFR domain.local
```

## Run standard dnsrecon
```bash
dnsrecon -d domain.local -t std -n $IP
```

## Brute force subdomains
```bash
dnsrecon -d domain.local -D /usr/share/seclists/Discovery/DNS/subdomains-top1million-110000.txt -t brt -n $IP
```

## Query specific record types
```bash
dig @$IP domain.local A
dig @$IP domain.local MX
dig @$IP _ldap._tcp.dc._msdcs.domain.local SRV
```
