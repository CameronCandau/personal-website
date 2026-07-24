# SNMP Enumeration (161)

## Run nmap SNMP scripts
```bash
nmap -sU -p 161 --script=snmp-* $IP
```

## Test common community strings with snmpwalk
```bash
snmpwalk -c public -v1 $IP
snmpwalk -c private -v2c $IP
```

## Use snmpbulkwalk
```bash
snmpbulkwalk -c public -v2c $IP .
```

## Brute force community strings
```bash
onesixtyone -c /usr/share/seclists/Discovery/SNMP/common-snmp-community-strings.txt $IP
```

## Get basic system info
```bash
snmpwalk -c public -v1 $IP 1.3.6.1.2.1.1.1.0
snmpwalk -c public -v1 $IP 1.3.6.1.2.1.1.5.0
```

## Get interfaces, routes, and ARP
```bash
snmpwalk -c public -v1 $IP 1.3.6.1.2.1.2.2.1.2
snmpwalk -c public -v1 $IP 1.3.6.1.2.1.4.21.1.1
snmpwalk -c public -v1 $IP 1.3.6.1.2.1.4.22.1.2
```

## Get Windows users, processes, and software
```bash
snmpwalk -c public -v1 $IP 1.3.6.1.4.1.77.1.2.25
snmpwalk -c public -v1 $IP 1.3.6.1.2.1.25.4.2.1.2
snmpwalk -c public -v1 $IP 1.3.6.1.2.1.25.6.3.1.2
```

## Run snmpcheck
```bash
snmpcheck -t $IP -c public
```

## Test a write community string carefully
```bash
snmpset -c private -v1 $IP 1.3.6.1.2.1.1.4.0 s "test"
```
