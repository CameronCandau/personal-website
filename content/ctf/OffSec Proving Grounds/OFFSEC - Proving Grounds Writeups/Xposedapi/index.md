Summary from existing writeups:
- :13337 http -> Remote Software Management API docs
- making a request to a route such as /logs is blocked and gives a response suggesting setting "X-Forwarded-For:localhost" in the request, to make it appear as coming from localhost
- LFI: `curl http://<IP>:13337/logs?file=/etc/passwd -H "X-Forwarded-For:localhost"`
- RFI: /update to download .elf from our own http server -> download revshell payload 
- request to /restart -> load downloaded payload
- wget owned by root and has SUID bit set -> gtfobins -> root