Summary from existing writeups:
- https on :8081, rconfig version 3.9.4
- unauthenticated sqli -> dump admin password hash from database -> `admin:abgrtyu`
- authenticated rce
- find has SUID bit set -> gtfobins -> root