## Reverse lookup
```bash
dig -p 53 -x $IP @$IP
```

## Attempt zone transfer
```bash
dig @$IP -t AXFR $DOMAIN
```

## Run standard dnsrecon
```bash
dnsrecon -d $DOMAIN -t std -n $IP
```

## Brute force subdomains
```bash
dnsrecon -d $DOMAIN -D /usr/share/seclists/Discovery/DNS/subdomains-top1million-110000.txt -t brt -n $IP
```

## Query specific record types
```bash
dig @$IP $DOMAIN A
dig @$IP $DOMAIN MX
dig @$IP _ldap._tcp.dc._msdcs.$DOMAIN SRV
```
