# Asynchronous Full Transfer (Zone Transfer)

```
dig @DC01.heist.offsec -t AXFR heist.offsec
```

```
; <<>> DiG 9.20.9-1-Debian <<>> @DC01.heist.offsec -t AXFR heist.offsec
; (1 server found)
;; global options: +cmd
; Transfer failed.
```


```
dnsrecon -d heist.offsec -t axfr -n DC01.heist.offsec
```

```
[*] Checking for Zone Transfer for heist.offsec name servers
[*] Resolving SOA Record
[+]      SOA dc01.heist.offsec 192.168.247.165
[*] Resolving NS Records
[*] NS Servers found:
[+]      NS dc01.heist.offsec 192.168.247.165
[*] Removing any duplicate NS server IP Addresses...
[*]
[*] Trying NS server 192.168.247.165
[+] 192.168.247.165 Has port 53 TCP Open
[-] Zone Transfer Failed (Zone transfer error: REFUSED)
```

# Continue: [[Archive/OFFSEC - Proving Grounds Writeups/Windows/Heist/Service Enumeration/389,636 LDAP(S)|389,636 LDAP(S)]]
